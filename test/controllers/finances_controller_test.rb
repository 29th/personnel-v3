require "test_helper"

class FinancesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @unit = create(:unit)
    @user = create(:user)
    create(:assignment, user: @user, unit: @unit)
  end

  test "should get index with donations and expenses" do
    donor = create(:user)
    create(:finance_record, user: donor, amount_received: 25, fee: 1.36, notes: "Thanks")
    create(:finance_record, :expense, vendor: :nuclear_fallout, amount_paid: 166.48)

    sign_in_as @user
    get finances_url

    assert_response :success
    assert_select "table.finance-ledger tbody tr", 2
    assert_select "td a", text: donor.short_name
    assert_select "td", text: "Nuclear Fallout"
    assert_select "td", text: "$166.48"
    assert_select "td", text: "Thanks"
    assert_select "a", text: "Manage", count: 0
  end

  test "should show manage button to user with finance_add" do
    create(:permission, abbr: "finance_add", unit: @unit)

    sign_in_as @user
    get finances_url

    assert_select "a[href=?]", manage_finance_records_path, text: "Manage"
  end

  test "should deny anonymous visitor" do
    get finances_url

    assert_response :redirect
  end
end
