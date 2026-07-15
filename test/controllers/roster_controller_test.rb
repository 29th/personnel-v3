require "test_helper"

class RosterControllerTest < ActionDispatch::IntegrationTest
  setup do
    # find_root expects an active combat unit with no parent
    @battalion = create(:unit, name: "Battalion HQ", abbr: "Bn. HQ",
      classification: :combat)
    @squad = create(:unit, parent: @battalion, name: "First Squad",
      abbr: "S1", classification: :combat)

    @user = create(:user, last_name: "Hopper", rank_abbr: "Cpl.")
    @position = create(:position, name: "Rifleman")
    create(:assignment, user: @user, unit: @squad, position: @position)
  end

  test "index shows the unit tree with active members" do
    get roster_url

    assert_response :success
    assert_match @squad.name, response.body
    assert_match @user.full_name, response.body
    assert_match @position.name, response.body
  end

  test "squad.xml lists active members with unit and position for ArmA" do
    get "/roster/squad.xml"

    assert_response :success
    body = response.body
    assert_match "<squad nick=\"29th ID\">", body
    assert_match "id=\"#{@user.steam_id}\"", body
    assert_match @user.full_name_last_first, body
    assert_match "<icq>#{@squad.abbr}</icq>", body
    assert_match "<remark>#{@position.name}</remark>", body
  end
end
