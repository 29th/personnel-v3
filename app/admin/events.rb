ActiveAdmin.register Event do
  includes :unit
  includes :server

  permit_params :bulk_dates, :time, :unit_id, :type, :mandatory, :server_id

  filter :datetime
  filter :unit, collection: -> { Unit.for_dropdown }
  filter :type, as: :select, collection: -> { Event::TYPES }

  index do
    selectable_column
    column "Start time", :datetime
    column :unit
    column :type
    actions
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)
    f.inputs do
      if f.object.persisted?
        input :datetime, as: :date_time_picker, label: "Start time"
      else
        input :bulk_dates, as: :date_picker, label: "Date(s)", input_html: {
          "data-controller": "flatpickr",
          "data-flatpickr-mode": "multiple"
        }
        input :time, as: :time_picker
      end
      input :unit, collection: Unit.for_dropdown
      input :type, as: :select, collection: Event::TYPES
      input :server, collection: Server.for_dropdown.map { |server| ["#{Server.games[server.game]} - #{server.name}", server.id] }
      input :mandatory
    end
    actions
  end

  show do
    attributes_table do
      row("Start time") { |row| row.datetime }
      row :unit
      row :type
      row :server
      row :mandatory
      row :reporter
      row :report_posting_date
      row :report_edit_date
      row :report do |event|
        safe_bbcode(event.report).html_safe if event.report.present?
      end
    end
  end

  action_item :view, only: :show do
    link_to "View on site", event_path(event)
  end

  config.sort_order = "datetime_desc"
  config.create_another = true

  # Allow creating multiple events at once
  # See: https://github.com/activeadmin/inherited_resources#overwriting-actions
  controller do
    def create
      bulk_dates = permitted_params[:event][:bulk_dates].split(", ").first(20) # Restrict over-loading
      base_event = build_resource # ActiveAdmin method. Applies authorization etc.

      resource_class.transaction do
        bulk_dates.each do |date|
          @event = base_event.dup
          @event.date = date
          create_resource!(@event)
        end
      end

      count = bulk_dates.count
      location = count === 1 ? smart_resource_url : smart_collection_url
      redirect_to location, notice: batch_created_notice(count)
    rescue ActiveRecord::RecordInvalid, ActiveRecord::Rollback
      render :new
    end

    # copied from active_admin and inherited_resources, with ! added to save
    def create_resource!(object)
      run_create_callbacks object do
        run_save_callbacks object do
          object.save!
        end
      end
    end

    def batch_created_notice(count)
      I18n.t(
        "active_admin.batch_actions.successfully_created",
        count: count,
        model: active_admin_config.resource_label.downcase,
        plural_model: active_admin_config.plural_resource_label(count: count).downcase
      )
    end
  end
end
