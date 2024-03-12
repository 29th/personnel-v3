ActiveAdmin.register Unit, as: "Training Platoon" do
  controller do
    def scoped_collection
      end_of_association_chain.training_platoons
    end

    def find_resource
      scoped_collection.friendly.find(params[:id])
    end
  end

  actions :index
  includes :events, :assignments

  scope :active, default: true
  scope :all, default: true

  filter :abbr
  filter :game, as: :select, collection: -> { Unit.games }
  filter :timezone, as: :select, collection: -> { Unit.timezones }

  index do
    column :abbr
    column :active
    column :game do |tp|
      Unit.games[tp.game]
    end
    column :timezone do |tp|
      Unit.timezones[tp.timezone]
    end
    column :dates do |tp|
      span timestamp_tag(tp.events.last.starts_at_local, "%F")
      span " - "
      span timestamp_tag(tp.events.first.starts_at_local, "%F")
    end
    column :recruits do |tp|
      tp.assignments.size
    end
    # actions defaults: false do |tp|
    #   item "View", manage_training_platoon_path(tp)
    # end
  end
end
