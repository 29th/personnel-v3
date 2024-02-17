require "test_helper"

class EnlistmentsControllerTest < ActionDispatch::IntegrationTest
  test "anonymous user accessing new is shown error" do
    get new_enlistment_url
    assert_select ".reason", 1
    assert_select "form#new_enlistment", 0
  end

  test "unregistered user accessing new is shown form" do
    sign_in_as(build(:unregistered_user))
    get new_enlistment_url
    assert_select "form#new_enlistment", 1
  end

  test "existing user accessing new is shown form" do
    sign_in_as(build(:user))
    get new_enlistment_url
    assert_select "form#new_enlistment", 1
  end

  test "member accessing new is shown error" do
    user = create(:user)
    unit = create(:unit, classification: :combat)
    create(:assignment, user: user, unit: unit)
    sign_in_as(user)
    get new_enlistment_url
    assert_select ".reason", 1
    assert_select "form#new_enlistment", 0
  end

  test "user assigned to training unit accessing new is shown error and linked to existing enlistment" do
    user = create(:user)
    tp = create(:unit, classification: :training)
    create(:assignment, user: user, unit: tp)
    create(:enlistment, user: user, status: :accepted)
    sign_in_as(user)
    get new_enlistment_url
    assert_select ".reason", 1
    assert_select "form#new_enlistment", 0
    assert_select "a", "View your enlistment", 1
  end

  test "user with pending enlistment accessing new is shown error and linked to existing enlistment" do
    user = create(:user)
    create(:enlistment, user: user, status: :pending)
    sign_in_as(user)
    get new_enlistment_url
    assert_select ".reason", 1
    assert_select "form#new_enlistment", 0
    assert_select "a", "View your enlistment", 1
  end
end
