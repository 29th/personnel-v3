require "test_helper"

class UnitsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @company = create(:unit, abbr: "Able Co. HQ", name: "Able Company", game: :rs2)
    @squad = create(:unit, parent: @company, abbr: "Able 1-1", name: "First Squad")

    @member = create(:user, last_name: "Memberton")
    create(:assignment, user: @member, unit: @squad)
  end

  test "show renders the roster for the unit subtree" do
    get unit_url(@company)

    assert_response :success
    assert_match @squad.name, response.body
    assert_match @member.short_name, response.body
  end

  test "attendance lists past events with stats" do
    event = create(:event, unit: @squad, mandatory: true,
      starts_at: 1.week.ago, type: "Squad Drills")
    create(:attendance_record, user: @member, event: event, attended: true)

    sign_in_as @member
    get unit_attendance_url(@company)

    assert_response :success
    assert_match "Squad Drills", response.body
    assert_match "Last 30 days:", response.body
  end

  test "awols groups recent awols by user" do
    event = create(:event, unit: @squad, mandatory: true, starts_at: 1.week.ago)
    create(:attendance_record, user: @member, event: event,
      attended: false, excused: false)

    sign_in_as @member
    get unit_awols_url(@company)

    assert_response :success
    assert_match @member.short_name, response.body
  end

  test "missing_awards lists users owed service medals" do
    create(:permission, abbr: "awarding_add", unit: @company)
    awarder = create(:user)
    create(:assignment, user: awarder, unit: @company)

    veteran = create(:user, last_name: "Veteranson")
    create(:assignment, user: veteran, unit: @squad, start_date: 8.months.ago)

    sign_in_as awarder
    get unit_missing_awards_url(@company)

    assert_response :success
    assert_match veteran.short_name, response.body
    assert_match "Army of Occupation", response.body
  end

  test "missing_awards refuses members without awarding_add" do
    sign_in_as @member
    get unit_missing_awards_url(@company)

    assert_redirected_to root_url
    assert_match(/not authorized/, flash[:alert])
  end

  test "stats shows members with attendance and standards progress" do
    sign_in_as @member
    get unit_stats_url(@company)

    assert_response :success
    assert_match @member.short_name, response.body
    assert_match "Unit Statistics", response.body
  end

  test "discharges lists members discharged from the subtree" do
    dischargee = create(:user, last_name: "Dischargeson")
    date = 2.months.ago.to_date
    create(:assignment, user: dischargee, unit: @squad,
      start_date: 1.year.ago, end_date: date)
    create(:discharge, user: dischargee, date: date, type: :honorable)

    sign_in_as @member
    get unit_discharges_url(@company)

    assert_response :success
    assert_match dischargee.short_name, response.body
    assert_match "Honorable", response.body
  end

  test "recruits lists enlistments recruited by subtree members" do
    recruit = create(:user, last_name: "Recruitson")
    create(:enlistment, status: :accepted, user: recruit, recruiter_user: @member)

    sign_in_as @member
    get unit_recruits_url(@company)

    assert_response :success
    assert_match recruit.short_name, response.body
    assert_match "Accepted", response.body
  end

  test "member-only pages refuse non-members" do
    non_member = create(:user)

    sign_in_as non_member
    get unit_attendance_url(@company)

    assert_redirected_to root_url
    assert_match(/not authorized/, flash[:alert])
  end
end
