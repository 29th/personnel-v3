require "test_helper"

# Walks the entire member lifecycle end-to-end: a visitor signs in via
# Discourse SSO, enlists, is accepted into a training platoon, and graduates
# into a squad as a full member. Each stage has focused tests elsewhere; this
# one guards the seams between them.
class MemberLifecycleTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  DISCOURSE_URL = Settings.discourse.base_url.internal

  setup do
    # Reference data
    create(:position, name: "Recruit")
    @rifleman = create(:position, name: "Rifleman")
    @pfc = create(:rank, abbr: "Pfc.", name: "Private First Class", order: 2)
    @graduation_award = create(:award, code: "gradaward", title: "Graduation ribbon")
    @country = create(:country)

    # Staff member who processes the enlistment and graduation
    hq = create(:unit, name: "Headquarters", abbr: "HQ")
    create(:permission, abbr: "manage", unit: hq)
    create(:permission, abbr: "admin", unit: hq)
    @staff = create(:user)
    create(:assignment, user: @staff, unit: hq)

    @training_platoon = create(:unit, classification: :training,
      name: "Training Platoon Alpha", abbr: "TP A")
    @squad = create(:unit, name: "First Squad", abbr: "S1")
  end

  test "a recruit enlists, is accepted into a training platoon, and graduates into a squad" do
    # --- 1. A visitor signs in via Discourse SSO and enlists ---
    applicant = build(:user, :unregistered)
    sign_in_as applicant

    stub_request(:get, "#{DISCOURSE_URL}/admin/users/#{applicant.forum_member_id}.json")
      .to_return(status: 200, headers: {"Content-Type" => "application/json"},
        body: {username: "jane_doe", groups: []}.to_json)
    forum_topic_request = stub_request(:post, "#{DISCOURSE_URL}/posts.json")
      .to_return(status: 200, headers: {"Content-Type" => "application/json"},
        body: {topic_id: 4242}.to_json)

    post enlistments_url, params: {
      enlistment: {age: "20", timezone: "est", game: "rs2",
                   ingame_name: "jdoe", experience: "Played a lot of RS2",
                   recruiter: "", comments: ""},
      user: {first_name: "Jane", last_name: "Doe", steam_id: "123456789",
             country_id: @country.id, time_zone: "Europe/London"}
    }

    enlistment = Enlistment.last
    assert_redirected_to enlistment_url(enlistment)

    recruit = enlistment.user
    assert recruit.has_pending_enlistment?
    assert_requested forum_topic_request
    assert_equal 4242, enlistment.topic_id, "enlistment should link to its forum topic"

    # --- 2. Staff accepts the enlistment into the training platoon ---
    sign_in_as @staff
    patch process_enlistment_manage_enlistment_url(enlistment), params: {
      enlistment: {status: "accepted", unit_id: @training_platoon.id}
    }
    assert_redirected_to manage_enlistment_url(enlistment)

    assert enlistment.reload.accepted?
    recruit = User.find(recruit.id)
    assert recruit.cadet?, "recruit should be a cadet after acceptance"
    refute recruit.member?
    assert recruit.assigned_to_unit?(@training_platoon)

    # --- 3. The cadet graduates into a squad ---
    clear_enqueued_jobs
    post graduate_manage_training_platoon_url(@training_platoon), params: {
      forms_graduation: {
        assignments_attributes: {
          "0" => {"member_id" => recruit.id.to_s, "unit_id" => @squad.id.to_s}
        },
        award_ids: [@graduation_award.id],
        rank_id: @pfc.id,
        position_id: @rifleman.id,
        topic_id: 555
      }
    }
    assert_redirected_to manage_training_platoon_url(@training_platoon)

    member = User.find(recruit.id)
    assert member.member?, "graduate should now be a full member"
    assert member.assigned_to_unit?(@squad)
    refute member.assigned_to_unit?(@training_platoon),
      "training assignment should have ended"
    assert_equal "Pfc.", member.rank.abbr
    assert_equal [@graduation_award], member.awards.to_a
    assert_equal 1, member.promotions.count
    refute @training_platoon.reload.active,
      "training platoon should be deactivated after graduation"
  end
end
