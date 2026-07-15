require "test_helper"

module Manage
  class FinanceRecordsControllerTest < ActionDispatch::IntegrationTest
    include ActiveJob::TestHelper

    setup do
      unit = create(:unit)
      create(:permission, abbr: "manage", unit: unit)
      create(:permission, abbr: "finance_add", unit: unit)

      @user = create(:user)
      create(:assignment, user: @user, unit: unit)

      @donor = create(:user)

      sign_in_as @user
      clear_enqueued_jobs
    end

    test "recording a donation regenerates the donor's service coat" do
      assert_difference("FinanceRecord.count") do
        assert_enqueued_with(job: GenerateServiceCoatJob, args: [@donor]) do
          post manage_finance_records_url, params: {
            finance_record: {
              member_id: @donor.id,
              date: Date.current,
              vendor: "notapplicable",
              amount_received: 10,
              notes: ""
            }
          }
        end
      end
    end

    test "recording an expense with no user does not regenerate any coat" do
      assert_difference("FinanceRecord.count") do
        post manage_finance_records_url, params: {
          finance_record: {
            date: Date.current,
            vendor: "digital_ocean",
            amount_paid: 20,
            notes: "server bill"
          }
        }
      end

      assert_no_enqueued_jobs only: GenerateServiceCoatJob
    end

    test "deleting a donation regenerates the donor's service coat" do
      finance_record = create(:finance_record, user: @donor)

      assert_difference("FinanceRecord.count", -1) do
        assert_enqueued_with(job: GenerateServiceCoatJob, args: [@donor]) do
          delete manage_finance_record_url(finance_record)
        end
      end
    end
  end
end
