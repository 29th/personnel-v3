ActiveAdmin.register Rank do
  actions :index, :show, :edit, :update, :new, :create
  permit_params :order, :abbr, :name, :grade, :image, :description, :remove_image
  
  filter :name_cont
  filter :abbr_cont

  index do
    selectable_column
    column :order
    column :abbr
    column :name
    column :grade
    column :filename do |rank|
      image_tag rank.image_url if rank.image.present?
    end
    column :description
    actions
  end

  show do
    attributes_table do
      row :name
      row :abbr
      row :grade
      row :order
      row :image do |rank|
        image_tag rank.image_url if rank.image.present?
      end
      row :description
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)
    f.inputs do
      input :name
      input :abbr
      input :grade
      input :order
      input :image, as: :hidden, input_html: {value: object.cached_image_data}
      input :image, as: :file
      input :remove_image, as: :boolean if object.image.present?
      input :description
    end
    f.actions
  end

  before_save do |rank|
    rank.image_derivatives! if rank.image_changed?
  end
end
