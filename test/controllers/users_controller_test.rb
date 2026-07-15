require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @subject = create(:user)

    @user = create(:user)
    create(:assignment, user: @user)
  end

  test "should get profile" do
    get user_url(@subject)
    assert_response :success
  end

  test "service record shows each kind of record grouped by year" do
    create(:assignment, user: @subject, unit: create(:unit, name: "First Squad"),
      start_date: 6.months.ago)
    create(:user_award, user: @subject, award: create(:award, title: "Shiny medal"))
    create(:promotion, user: @subject, rank_abbr: "Cpl.")
    create(:demerit, user: @subject)
    create(:discharge, user: @subject, type: :honorable)
    create(:enlistment, user: @subject, status: :accepted)

    get user_service_record_url(@subject)

    assert_response :success
    assert_match "Assigned to", response.body
    assert_match "First Squad", response.body
    assert_match "Shiny medal", response.body
    assert_match "Promoted to", response.body
    assert_match "a demerit", response.body
    assert_match "Honorably discharged", response.body
    assert_match "Enlisted", response.body
    assert_select "h2", text: Date.current.year.to_s
  end

  test "should get attendance" do
    sign_in_as @user
    get user_attendance_url(@subject)
    assert_response :success
  end

  test "should get qualifications" do
    sign_in_as @user
    get user_qualifications_url(@subject)
    assert_response :success
  end

  test "should get extended loas" do
    sign_in_as @user
    get user_extended_loas_url(@subject)
    assert_response :success
  end

  test "recruits lists accepted enlistments recruited by the user" do
    accepted_recruit = create(:user, last_name: "Acceptedson")
    create(:enlistment, status: :accepted, user: accepted_recruit,
      recruiter_user: @subject)
    pending_recruit = create(:user, last_name: "Pendingson")
    create(:enlistment, status: :pending, user: pending_recruit,
      recruiter_user: @subject)

    get user_recruits_url(@subject)

    assert_response :success
    assert_match "Total: 1", response.body
    assert_match accepted_recruit.short_name, response.body
    refute_match pending_recruit.short_name, response.body
  end

  test "reprimands lists demerits and awols" do
    demerit = create(:demerit, user: @subject, reason: "Insubordination")
    create(:attendance_record, :absent, :mandatory, user: @subject,
      event_starts_at: 3.days.ago)

    sign_in_as @user
    get user_reprimands_url(@subject)

    assert_response :success
    assert_match demerit.reason, response.body
    assert_select ".awols li", 1
  end

  test "reprimands is not available to non-members" do
    non_member = create(:user)

    sign_in_as non_member
    get user_reprimands_url(@subject)

    assert_redirected_to root_url
  end
end
