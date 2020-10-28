ActiveAdmin.register Award do
  permit_params :code, :title, :game, :description, :image,
                :thumbnail, :bar, :order, :active

  scope :active, default: true
  scope :all

  filter :title
  filter :game, as: :select

  index do
    selectable_column
    column :title
    column :code
    column :game
    column :image do |award|
      image_tag award.image
    end
    column :thumbnail do |award|
      image_tag award.thumbnail
    end
    column :bar do |award|
      image_tag award.bar
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
      row :image do |award|
        image_tag award.image
      end
      row :thumbnail do |award|
        image_tag award.thumbnail
      end
      row :bar do |award|
        image_tag award.bar
      end
    end
  end
end
