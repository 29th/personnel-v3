class FinancesController < ApplicationController
  def index
    authorize FinanceRecord, :ledger?
    @balance = FinanceRecord.balance
    @finance_records = FinanceRecord
      .includes(user: :rank)
      .order(date: :desc, id: :desc)
      .page(params[:page])
  end
end
