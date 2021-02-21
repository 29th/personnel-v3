ActiveAdmin.register Award do
  permit_params :code, :title, :game, :description, :order, :active,
                :display_image, :mini_image

  scope :active, default: true
  scope :all

  filter :title
  filter :game, as: :select

  config.sort_order = 'order_desc'

  index do
    selectable_column
    column :title
    column :code
    column :game
    column :display_image do |award|
      image_tag award.display_image_url unless award.display_image.nil?
    end
    column :mini_image do |award|
      image_tag award.mini_image_url unless award.mini_image.nil?
    end
    column :description
    column 'User awards' do |award|
      link_to award.user_awards.count, admin_award_user_awards_path(award)
    end
    actions
  end

  show do
    attributes_table do
      row :title
      row :code
      row :game
      row :description
      row 'User awards' do |award|
        link_to award.user_awards.count, admin_award_user_awards_path(award)
      end
      row :display_image do |award|
        image_tag award.display_image_url unless award.display_image.nil?
      end
      row :mini_image do |award|
        image_tag award.mini_image_url unless award.mini_image.nil?
      end
    end
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs do
      input :code
      input :title
      input :description
      input :game
      input :active
      input :order

      input :display_image, as: :hidden, input_html: { value: object.cached_display_image_data }
      input :display_image, as: :file

      input :mini_image, as: :hidden, input_html: { value: object.cached_mini_image_data }
      input :mini_image, as: :file
    end
    f.actions
  end
end
