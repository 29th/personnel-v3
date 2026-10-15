require "test_helper"

class FinanceRecordPolicyTest < ActiveSupport::TestCase
  test "ledger permits active member" do
    user = create(:user)
    create(:assignment, user: user)

    assert_permit user, FinanceRecord, :ledger
  end

  test "ledger permits honourably discharged member" do
    user = create(:user)
    create(:assignment, user: user, start_date: 1.year.ago, end_date: 1.month.ago)
    create(:discharge, user: user, type: :honorable, date: 1.month.ago)

    assert_permit user, FinanceRecord, :ledger
  end

  test "ledger denies generally discharged member" do
    user = create(:user)
    create(:assignment, user: user, start_date: 1.year.ago, end_date: 1.month.ago)
    create(:discharge, user: user, type: :general, date: 1.month.ago)

    refute_permit user, FinanceRecord, :ledger
  end

  test "ledger denies user who never served" do
    refute_permit create(:user), FinanceRecord, :ledger
  end

  test "ledger denies anonymous visitor" do
    refute_permit nil, FinanceRecord, :ledger
  end

  test "index denies honourably discharged member" do
    user = create(:user)
    create(:assignment, user: user, start_date: 1.year.ago, end_date: 1.month.ago)
    create(:discharge, user: user, type: :honorable, date: 1.month.ago)

    refute_permit user, FinanceRecord, :index
  end
end
