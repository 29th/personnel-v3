ActiveAdmin.register Award do
  permit_params :code, :title, :game, :description, :image,
                :thumbnail, :bar, :display_filename, :mini_filename,
                :order, :active

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
    column :display_filename do |award|
      if award.display_filename
        image_tag "awards/display/#{award.display_filename}"
      end
    end
    column :mini_filename do |award|
      if award.mini_filename
        image_tag "awards/mini/#{award.mini_filename}"
      end
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
      row :display_filename do |award|
        if award.display_filename
          image_tag "awards/display/#{award.display_filename}"
        end
      end
      row :mini_filename do |award|
        if award.mini_filename
          image_tag "awards/mini/#{award.mini_filename}"
        end
      end
    end
  end
end
