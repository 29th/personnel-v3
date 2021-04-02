ActiveAdmin.register Award do
  permit_params :code, :title, :game, :description, :order, :active,
    :presentation_image, :ribbon_image,
    :remove_presentation_image, :remove_ribbon_image

  scope :active, default: true
  scope :all

  filter :title
  filter :game, as: :select

  config.sort_order = "order_desc"

  index do
    selectable_column
    column :title
    column :code
    column :game
    column :presentation_image do |award|
      image_tag award.presentation_image_url unless award.presentation_image.nil?
    end
    column :ribbon_image do |award|
      image_tag award.ribbon_image_url unless award.ribbon_image.nil?
    end
    column :description
    column "User awards" do |award|
      link_to award.user_awards.count, [:admin, :user_awards, q: {award_id_eq: award.id}]
    end
    actions
  end

  show do
    attributes_table do
      row :title
      row :code
      row :game
      row :description
      row "User awards" do |award|
        link_to award.user_awards.count, admin_award_user_awards_path(award)
      end
      row :presentation_image do |award|
        image_tag award.presentation_image_url unless award.presentation_image.nil?
      end
      row :ribbon_image do |award|
        image_tag award.ribbon_image_url unless award.ribbon_image.nil?
      end
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)
    f.inputs do
      input :code
      input :title
      input :description
      input :game
      input :active
      input :order

      input :presentation_image, as: :hidden, input_html: {value: object.cached_presentation_image_data}
      input :presentation_image, as: :file
      input :remove_presentation_image, as: :boolean if object.presentation_image.present?

      input :ribbon_image, as: :hidden, input_html: {value: object.cached_ribbon_image_data}
      input :ribbon_image, as: :file
      input :remove_ribbon_image, as: :boolean if object.ribbon_image.present?
    end
    f.actions
  end
end
