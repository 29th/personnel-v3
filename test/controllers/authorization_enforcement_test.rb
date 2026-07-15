require "test_helper"

# ApplicationController requires every action to run a Pundit authorization
# check (verify_authorized). These tests guard the guard: if that after_action
# is ever disabled again, the first test below starts failing.
#
# They use ActionController::TestCase with a private route set so the fake
# controllers don't touch the application's real routes.
module AuthorizationEnforcement
  class ForgetfulPagesController < ApplicationController
    def show
      head :ok
    end
  end

  class PublicPagesController < ApplicationController
    def show
      skip_authorization
      head :ok
    end
  end

  ROUTES = ActionDispatch::Routing::RouteSet.new.tap do |routes|
    routes.draw do
      get "forgetful_page" => "authorization_enforcement/forgetful_pages#show"
      get "public_page" => "authorization_enforcement/public_pages#show"
    end
  end

  class ForgetfulPagesControllerTest < ActionController::TestCase
    setup { @routes = ROUTES }

    test "an action that never calls authorize raises instead of serving the page" do
      assert_raises Pundit::AuthorizationNotPerformedError do
        get :show
      end
    end
  end

  class PublicPagesControllerTest < ActionController::TestCase
    setup { @routes = ROUTES }

    test "an action that explicitly skips authorization is served" do
      get :show

      assert_response :success
    end
  end
end
