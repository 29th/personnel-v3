ActiveAdmin.register Assignment do
  includes :unit, :position, user: :rank

  # controller do
    # def scoped_collection
      # super.includes user: :rank
      # super.includes({:user => :rank})
    # end
  # end

  filter :unit
  filter :user, collection: proc { User.includes(:rank) } # Doesn't seem to respect includes above
  filter :position
  filter :start_date
  filter :end_date

  scope :active, default: true
  scope :all

  index do
    selectable_column
    column :unit
    column :user
    column :position
    column :start_date
    column :end_date
    actions
  end
end
