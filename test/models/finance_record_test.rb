require "test_helper"

class FinanceRecordTest < ActiveSupport::TestCase
  test "requires either an amount received or an amount paid, not both" do
    neither = build(:finance_record, amount_received: nil, amount_paid: nil)
    both = build(:finance_record, amount_received: 10, amount_paid: 10)
    received = build(:finance_record, amount_received: 10, amount_paid: nil)
    paid = build(:finance_record, amount_received: nil, amount_paid: 10)

    refute neither.valid?
    refute both.valid?
    assert received.valid?
    assert paid.valid?
  end

  test "user_donated sums the user's income records only" do
    user = create(:user)
    create(:finance_record, user: user, amount_received: 10)
    create(:finance_record, user: user, amount_received: 5)
    create(:finance_record, :expense, user: user) # expense, not a donation
    create(:finance_record, amount_received: 25) # another user

    assert_equal 15, FinanceRecord.user_donated(user)
  end

  test "balance is income minus expenses and fees" do
    create(:finance_record, amount_received: 100, fee: 3)
    create(:finance_record, :expense, amount_paid: 20)

    assert_equal 77, FinanceRecord.balance
  end
end
