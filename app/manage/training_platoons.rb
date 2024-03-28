ActiveAdmin.register Unit, as: "Training Platoon" do
  controller do
    def scoped_collection
      # the usual includes config doesn't seem to apply to show pages
      # so we're doing it here instead
      super.includes(:events, enlistments: [user: :rank])
    end

    def find_resource
      scoped_collection.friendly.find(params[:id])
    end

    private

    def graduation_params
      params.require(:forms_graduation).permit(
        :rank_id,
        :position_id,
        :topic_id,
        award_ids: [],
        assignments_attributes: [
          :member_id,
          :unit_id
        ]
      )
    end
  end

  scope_to do
    Unit.training_platoons
  end

  actions :index, :show

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
      if tp.events.any?
        span timestamp_tag(tp.events.last.starts_at_local, "%F")
        span " - "
        span timestamp_tag(tp.events.first.starts_at_local, "%F")
      end
    end
    column :recruits do |tp|
      tp.enlistments.count(&:accepted?)
    end
    actions defaults: false do |tp|
      item "View", manage_training_platoon_path(tp)
    end
  end

  show do
    attributes_table do
      row :id
      row :name
      row :game do |tp|
        Unit.games[tp.game]
      end
      row :timezone do |tp|
        Unit.timezones[tp.timezone]
      end
    end

    panel "Recruits" do
      table_for training_platoon.enlistments do
        column :user
        tag_column :status
        column "" do |enlistment|
          link_to "View Enlistment", manage_enlistment_path(enlistment)
        end
      end
    end
  end

  action_item :edit_unit, only: :show,
    if: proc { authorized?(:edit, training_platoon) } do
    link_to "Edit Unit", manage_unit_path(training_platoon)
  end

  action_item :graduate, only: :show,
    if: proc { authorized?(:graduate, training_platoon) } do
    link_to "Graduate", graduate_manage_training_platoon_path(training_platoon)
  end

  member_action :graduate, method: [:get, :post] do
    @squads = Unit.ordered_squads
    @awards = Award.active.order(:title)
    @ranks = Rank.all
    @positions = Position.active
    @enlistments_by_user = resource.enlistments
      .accepted
      .with_recruiter_details
      .index_by(&:member_id)

    if request.post?
      @graduation = Forms::Graduation.new(training_platoon: resource, **graduation_params)
      if @graduation.save
        redirect_to resource_path, notice: "Graduation processed"
      else
        render :graduate
      end
    else
      @graduation = Forms::Graduation.new(training_platoon: resource)
      render :graduate
    end
  end
end
