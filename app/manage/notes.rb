ActiveAdmin.register Note do
  belongs_to :user, optional: true, finder: :find_by_slug
  actions :index, :show, :edit, :update, :new, :create
  includes user: :rank, author: :rank
  permit_params :user, :access, :subject, :content, :member_id

  # scope :all, default: true

  filter :user, as: :searchable_select, ajax: true
  filter :date_add
  filter :access, as: :select

  index do
    column :date_add
    column :date_mod
    column :user
    column :author
    column :access
    column :subject
    actions
  end

  show do
    attributes_table do
      row :user
      row :author
      row :date_add
      row :date_mod
      row :access
      row :subject
      row :content do |note|
        simple_format note.content
      end
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)
    f.inputs do
      input :user, as: :searchable_select, ajax: true
      input :access, as: :select, collection: Note.accesses.map(&:reverse)
      input :subject
      input :content
    end
    f.actions
  end

  config.sort_order = "date_mod_desc"

  before_create do |note|
    note.author = current_user
  end
end
