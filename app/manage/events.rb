ActiveAdmin.register Event do
  includes :unit
  includes :server

  permit_params :starts_at_local, :bulk_dates, :time, :unit_id, :type, :mandatory,
    :server_id, :time_zone

  batch_create by_param: :bulk_dates, max: 20, separator: ", " do |date|
    @event.starts_at = helpers.build_time(time_zone: @event.time_zone,
      date: date, time: @event.time)
  end

  before_update do |event|
    event.starts_at = helpers.build_time(time_zone: event.time_zone,
      date_time: event.starts_at_local)
  end

  filter :datetime
  filter :unit, collection: -> { Unit.for_dropdown }
  filter :type, as: :select, collection: -> { Event::TYPES }

  index do
    column "Starts at" do |event|
      timestamp_tag event.starts_at_local
    end
    column :unit do |event|
      link_to event.unit.subtree_abbr, manage_unit_path(event.unit)
    end
    column :type
    actions defaults: false do |event|
      item "View", manage_event_path(event)
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)
    f.inputs "data-controller": "time-zone-comparison" do
      if f.object.persisted?
        input :starts_at_local, as: :date_time_picker, label: "Starts at", input_html: {
          "data-controller": "jquery-shim",
          "data-time-zone-comparison-target": "startsAt",
          "data-action": "$change->time-zone-comparison#update"
        }
      else
        input :bulk_dates, as: :date_picker, label: "Date(s)", input_html: {
          "data-controller": "flatpickr",
          "data-flatpickr-mode": "multiple",
          "data-time-zone-comparison-target": "bulkDates",
          "data-action": "time-zone-comparison#update"
        }
        input :time, as: :date_time_picker, input_html: {
          "data-controller": "jquery-shim",
          "data-time-zone-comparison-target": "time",
          "data-action": "$change->time-zone-comparison#update"
        }, picker_options: {datepicker: false, format: "H:i"}
      end
      input :time_zone, as: :select, collection: timezone_dropdown_options, input_html: {
        "data-controller": "jquery-shim",
        "data-time-zone-comparison-target": "timeZone",
        "data-action": "$change->time-zone-comparison#update"
      }
      li "", "data-time-zone-comparison-target" => "comparisons"
      input :unit, collection: Unit.for_dropdown(f.object&.unit)
      input :type, as: :select, collection: Event::TYPES
      input :server, collection: Server.for_dropdown.map { |server| ["#{Server.games[server.game]} - #{server.name}", server.id] }
      input :mandatory
    end
    actions
  end

  show do
    attributes_table do
      row "Starts at" do |event|
        timestamp_tag event.starts_at_local
      end
      row :time_zone do |event|
        ActiveSupport::TimeZone[event.time_zone].name
      end
      row :unit do |event|
        link_to event.unit.name, manage_unit_path(event.unit)
      end
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

  config.sort_order = "starts_at_desc"
  config.create_another = true
end
