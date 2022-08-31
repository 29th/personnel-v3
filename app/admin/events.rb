ActiveAdmin.register Event do
  includes :unit
  includes :server

  permit_params :datetime, :bulk_dates, :time, :unit_id, :type, :mandatory,
    :server_id

  batch_create by_param: :bulk_dates, max: 20, separator: ", " do |date|
    @event.date = date
  end

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
end
