require "test_helper"

class EnlistmentsControllerTest < ActionDispatch::IntegrationTest
  class New < EnlistmentsControllerTest
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

  class Create < EnlistmentsControllerTest
    setup do
      create(:rank, name: "Recruit")
      country = create(:country)
      @valid_attrs = {first_name: "Jane", middle_name: "Adelade", last_name: "Doe",
                      age: "20", country_id: country.id, timezone: "est", game: "rs2",
                      ingame_name: "jdo", steam_id: "123456789", recruiter: "Pvt Pyle",
                      experience: "Yes", comments: "", previous_units: [
                        {unit: "1st LOL", game: "Tetris", name: "jdo", rank: "", reason: "Disbanded"}
                      ]}
    end

    test "uses existing member record when one exists" do
      user = create(:user)
      sign_in_as(user)
      CreateEnlistmentForumTopicJob.expects(:perform_now)

      assert_difference(-> { User.count } => 0, -> { Enlistment.count } => 1) do
        post enlistments_url, params: {enlistment: @valid_attrs}
      end

      new_enlistment = Enlistment.last
      assert_redirected_to enlistment_url(new_enlistment)
      assert_equal user, new_enlistment.user
    end

    test "creates member record for unregistered user" do
      user = build(:unregistered_user)
      sign_in_as(user)
      CreateEnlistmentForumTopicJob.expects(:perform_now)

      assert_difference(-> { User.count } => 1, -> { Enlistment.count } => 1) do
        post enlistments_url, params: {enlistment: @valid_attrs}
      end

      new_enlistment = Enlistment.last
      assert_redirected_to enlistment_url(new_enlistment)
      assert_equal User.last, new_enlistment.user
    end

    test "signs in as newly created user" do
      user = build(:unregistered_user)
      sign_in_as(user)
      CreateEnlistmentForumTopicJob.expects(:perform_now)

      post enlistments_url, params: {enlistment: @valid_attrs}

      new_user = User.last
      assert_equal new_user.id, session[:user_id]
    end

    test "does not create member record if enlistment is invalid" do
      user = build(:unregistered_user)
      sign_in_as(user)
      CreateEnlistmentForumTopicJob.expects(:perform_now).never

      invalid_attrs = {**@valid_attrs, ingame_name: nil}
      assert_difference(-> { User.count } => 0, -> { Enlistment.count } => 0) do
        post enlistments_url, params: {enlistment: invalid_attrs}
      end
    end
  end
end
