ActiveAdmin.register FinanceRecord do
  belongs_to :user, optional: true, finder: :find_by_slug
  includes user: :rank

  permit_params :date, :member_id, :forum_id, :topic_id, :notes,
    :amount_received, :amount_paid, :fee, :vendor

  scope :all, default: true
  scope :income
  scope :expenses

  filter :user, as: :searchable_select, ajax: true
  filter :vendor, as: :select, collection: FinanceRecord.vendors.map(&:reverse)
  filter :date
  filter :amount_received
  filter :amount_paid

  config.sort_order = "date_desc"

  sidebar :balance, only: :index do
    span number_to_currency(FinanceRecord.balance)
  end

  index do
    selectable_column
    column :date
    column :user
    column :vendor
    column :amount_received do |record|
      number_to_currency(record.amount_received)
    end
    column :amount_paid do |record|
      number_to_currency(record.amount_paid)
    end
    column :fee do |record|
      number_to_currency(record.fee)
    end
    column :notes do |finance_record|
      finance_record.notes.truncate 75, omission: "…"
    end
    actions
  end

  show do
    attributes_table do
      row :date
      row :user
      row :vendor
      row :amount_received do |record|
        number_to_currency(record.amount_received)
      end
      row :amount_paid do |record|
        number_to_currency(record.amount_paid)
      end
      row :fee do |record|
        number_to_currency(record.fee)
      end
      row :forum_id
      row :topic_id
      row :notes
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)
    f.inputs do
      f.input :date
      f.input :user, as: :searchable_select, ajax: true
      f.input :vendor, as: :select, collection: FinanceRecord.vendors.map(&:reverse)
      f.input :amount_received
      f.input :amount_paid
      f.input :fee
      f.input :forum_id, as: :select, collection: FinanceRecord.forum_ids.map(&:reverse)
      f.input :topic_id, label: "Topic ID"
      f.input :notes
    end
    f.actions
  end

  after_save do |finance_record|
    GenerateServiceCoatJob.perform_later(finance_record.user) if finance_record.user.present?
  end

  after_destroy do |finance_record|
    GenerateServiceCoatJob.perform_later(finance_record.user) if finance_record.user.present?
  end
end
