require "application_system_test_case"

class EnlistmentsTest < ApplicationSystemTestCase
  setup do
    @user = create(:user)
  end

  test "shows previous units section when yes is selected" do
    visit new_enlistment_path

    click_on "Sign in (dev)"
    fill_in "Forum member id", with: @user.id
    click_on "Sign In"

    choose "Yes"
    assert_text "Previous Units"

    click_on "Add previous unit"
    assert_text "Reason for leaving"
  end
end
