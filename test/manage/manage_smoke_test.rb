require "test_helper"

# Smoke-tests every registered ActiveAdmin resource so that renamed columns,
# broken filters, missing includes, or ransack allowlist mistakes are caught
# even for resources with no dedicated tests. New resources are picked up
# automatically.
module Manage
  class SmokeTest < ActionDispatch::IntegrationTest
    ActiveAdmin.application.load!
    RESOURCES = ActiveAdmin.application.namespaces[:manage].resources.to_a
      .reject { |resource| resource.controller.controller_path == "manage/comments" } # disabled feature, no table

    setup do
      # The forum role dropdowns and columns fetch role names from Discourse
      stub_request(:get, %r{#{Settings.discourse.base_url.internal}/groups\.json.*})
        .to_return(status: 200, headers: {"Content-Type" => "application/json"},
          body: {groups: [], total_rows_groups: 0}.to_json)

      admin_unit = create(:unit, name: "Admin Office", abbr: "Adm.")
      create(:permission, abbr: "manage", unit: admin_unit)
      create(:permission, abbr: "admin", unit: admin_unit)
      # new? on these policies requires the specific permission; admin is not enough
      create(:permission, abbr: "assignment_add_any", unit: admin_unit)
      create(:permission, abbr: "discharge_add_any", unit: admin_unit)
      @admin = create(:user)
      create(:assignment, user: @admin, unit: admin_unit)

      seed_one_of_everything
      sign_in_as @admin
    end

    RESOURCES.each do |resource|
      controller_path = resource.controller.controller_path

      if resource.controller.action_methods.include?("index")
        test "#{controller_path} index renders" do
          get url_for(controller: "/#{controller_path}", action: "index")
          assert_response :success
        end
      end

      if resource.controller.action_methods.include?("new")
        test "#{controller_path} new form renders" do
          get url_for(controller: "/#{controller_path}", action: "new")
          assert_response :success
        end
      end
    end

    private

    # One record per resource so the index tables actually render rows
    def seed_one_of_everything
      member = create(:user)
      squad = create(:unit, name: "First Squad", abbr: "S1")
      create(:assignment, user: member, unit: squad)

      create(:ait_qualification, user: member) # also creates an AIT standard
      create(:ban_log)
      create(:demerit, user: member)
      create(:discharge, user: member)
      create(:event, unit: squad)
      create(:extended_loa, user: member)
      create(:finance_record, user: member)
      create(:note, user: member)
      create(:pass, user: member)
      create(:permission, unit: squad, abbr: "some_ability")
      create(:promotion, user: member)
      create(:restricted_name, name: "Reservedname") # fixed name so Faker can't collide
      create(:server)
      create(:special_forum_role)
      create(:special_forum_role, forum_id: :vanilla)
      create(:unit_forum_role, unit: squad)
      create(:unit_forum_role, forum_id: :vanilla, unit: squad)
      create(:user_award, user: member)

      tp = create(:unit, classification: :training,
        name: "Training Platoon Alpha", abbr: "TP A")
      create(:event, unit: tp)
      create(:enlistment, unit: tp, status: :accepted)
    end
  end
end
