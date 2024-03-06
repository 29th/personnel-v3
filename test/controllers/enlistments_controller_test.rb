require "test_helper"

class EnlistmentsControllerTest < ActionDispatch::IntegrationTest
  class New < EnlistmentsControllerTest
    test "anonymous user accessing new is shown error" do
      get new_enlistment_url
      assert_select ".reason", 1
      assert_select "form#new_enlistment", 0
    end

    test "unregistered user accessing new is shown form" do
      sign_in_as(build(:user, :unregistered))
      get new_enlistment_url
      assert_select "form#new_enlistment", 1
    end

    test "existing user accessing new is shown form" do
      sign_in_as(create(:user))
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

  class Create < EnlistmentsControllerTest
    setup do
      country = create(:country)
      @valid_enlistment_attrs = {
        age: "20", timezone: "est", game: "rs2", ingame_name: "jdo",
        recruiter: "Pvt Pyle", experience: "Yes", comments: "",
        previous_units: [
          {unit: "1st LOL", game: "Tetris", name: "jdo", rank: "", reason: "Disbanded"}
        ]
      }
      @valid_user_attrs = {
        first_name: "Jane", middle_name: "Adelade", last_name: "Doe",
        steam_id: "123456789", country_id: country.id, time_zone: "Europe/London"
      }
    end

    test "uses existing member record when one exists" do
      user = create(:user)
      sign_in_as(user)
      CreateEnlistmentForumTopicJob.expects(:perform_now)

      assert_difference(-> { User.count } => 0, -> { Enlistment.count } => 1) do
        post enlistments_url, params: {enlistment: @valid_enlistment_attrs, user: @valid_user_attrs}
      end

      new_enlistment = Enlistment.last
      assert_redirected_to enlistment_url(new_enlistment)
      assert_equal user, new_enlistment.user
    end

    test "creates member record for unregistered user" do
      unregistered_user = build(:user, :unregistered)
      sign_in_as(unregistered_user)
      CreateEnlistmentForumTopicJob.expects(:perform_now)

      assert_difference(-> { User.count } => 1, -> { Enlistment.count } => 1) do
        post enlistments_url, params: {enlistment: @valid_enlistment_attrs, user: @valid_user_attrs}
      end

      new_enlistment = Enlistment.last
      assert_redirected_to enlistment_url(new_enlistment)
      assert_equal User.last, new_enlistment.user
    end

    test "combines form data with session data when enlisting as unregistered user" do
      unregistered_user = build(:user, :unregistered)
      sign_in_as(unregistered_user)
      CreateEnlistmentForumTopicJob.expects(:perform_now)

      post enlistments_url, params: {enlistment: @valid_enlistment_attrs, user: @valid_user_attrs}

      new_enlistment = Enlistment.last
      new_user = User.last
      assert_equal new_user, new_enlistment.user
      assert_equal unregistered_user.forum_member_id, new_user.forum_member_id
      assert_equal unregistered_user.email, new_user.email
      assert_equal @valid_user_attrs[:last_name], new_user.last_name
      assert_equal @valid_user_attrs[:time_zone], new_user.time_zone
    end

    test "does not allow user attributes to be updated when enlisting as existing user" do
      uk = create(:country, name: "UK")
      user = create(:user, last_name: "Delphi", steam_id: "888", country: uk)
      sign_in_as(user)
      CreateEnlistmentForumTopicJob.expects(:perform_now)

      # @valid_user_attrs has a different last_name, steam_id, and country
      post enlistments_url, params: {enlistment: @valid_enlistment_attrs, user: @valid_user_attrs}

      new_enlistment = Enlistment.last
      assert_equal user, new_enlistment.user
      assert_equal "Delphi", new_enlistment.user.last_name
      assert_equal "888", new_enlistment.user.steam_id
      assert_equal "UK", new_enlistment.country.name
    end

    test "copies user attributes to legacy enlistment fields for unregistered users" do
      unregistered_user = build(:user, :unregistered)
      sign_in_as(unregistered_user)
      CreateEnlistmentForumTopicJob.expects(:perform_now)

      post enlistments_url, params: {enlistment: @valid_enlistment_attrs, user: @valid_user_attrs}

      new_enlistment = Enlistment.last
      new_user = User.last
      assert_equal new_user.first_name, new_enlistment.first_name
      assert_equal new_user.middle_name, new_enlistment.middle_name
      assert_equal new_user.last_name, new_enlistment.last_name
      assert_equal new_user.steam_id, new_enlistment.steam_id
      assert_equal new_user.country, new_enlistment.country
    end

    test "copies user attributes to legacy enlistment fields for existing users" do
      user = create(:user, middle_name: "Foo", country: build(:country))
      sign_in_as(user)
      CreateEnlistmentForumTopicJob.expects(:perform_now)

      post enlistments_url, params: {enlistment: @valid_enlistment_attrs, user: @valid_user_attrs}

      new_enlistment = Enlistment.last
      assert_equal user.first_name, new_enlistment.first_name
      assert_equal user.middle_name, new_enlistment.middle_name
      assert_equal user.last_name, new_enlistment.last_name
      assert_equal user.steam_id, new_enlistment.steam_id
      assert_equal user.country, new_enlistment.country
    end

    test "signs in as newly created user" do
      unregistered_user = build(:user, :unregistered)
      sign_in_as(unregistered_user)
      CreateEnlistmentForumTopicJob.expects(:perform_now)

      post enlistments_url, params: {enlistment: @valid_enlistment_attrs, user: @valid_user_attrs}

      new_user = User.last
      assert_equal new_user.id, session[:user_id]
    end

    test "does not create member record if enlistment is invalid" do
      user = build(:user, :unregistered)
      sign_in_as(user)
      CreateEnlistmentForumTopicJob.expects(:perform_now).never

      invalid_enlistment_attrs = {**@valid_enlistment_attrs, ingame_name: nil}
      assert_difference(-> { User.count } => 0, -> { Enlistment.count } => 0) do
        post enlistments_url, params: {enlistment: invalid_enlistment_attrs, user: @valid_user_attrs}
      end
    end
  end
end
