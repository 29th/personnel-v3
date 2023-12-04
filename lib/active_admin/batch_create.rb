module ActiveAdmin
  module BatchCreate
    module DSL
      # Call this inside your resource definition to support creating
      # multiple records from a single form.
      #
      # Example:
      #
      # #app/admin/events.rb
      #
      # permit_params :dates
      # ActiveAdmin.register Event do
      #   batch_create by_param: :dates, separator: ", " do |date|
      #     @event.date = date
      #   end
      # end
      #
      # Example:
      #
      # #app/admin/awards.rb
      #
      # permit_params user_ids: []
      # ActiveAdmin.register Award do
      #   batch_create by_param: :user_ids, max: 5 do |user_id|
      #     @award.user_id = user_id
      #   end
      # end
      def batch_create(options = {}, &block)
        controller do
          define_method(:create) do
            params = resource_params[0]
            batch_param = options[:by_param]
            separator = options[:separator]
            max_records = options[:max]

            batch_values = separator ?
              params[batch_param].split(separator) :
              Array.wrap(params[batch_param])
            batch_values = batch_values.select(&:present?)
            batch_values = batch_values.first(max_records) if max_records.present?

            base_resource = build_resource_without_authorizing

            resource_class.transaction do
              batch_values.each do |value|
                resource = base_resource.dup
                set_resource_ivar(resource)
                instance_exec(value, &block) if block
                authorize_resource!(resource)
                create_resource!(resource)
              end
            end

            count = batch_values.count
            location = (count === 1) ? smart_resource_url : smart_collection_url
            redirect_to location, notice: batch_created_notice(count)
          rescue ActiveRecord::RecordInvalid,
            ActiveRecord::Rollback
            render :new
          end

          # we don't want to authorize with batch values; we do that after
          define_method(:build_resource_without_authorizing) do
            resource = build_new_resource
            resource = apply_decorations(resource)
            resource = assign_attributes(resource, resource_params)
            run_build_callbacks resource
            resource
          end

          define_method(:create_resource!) do |object|
            run_create_callbacks(object) do
              run_save_callbacks(object) do
                object.save!
              end
            end
          end

          define_method(:batch_created_notice) do |count|
            I18n.t(
              "active_admin.batch_actions.successfully_created",
              count: count,
              model: active_admin_config.resource_label.downcase,
              plural_model: active_admin_config.plural_resource_label(count: count).downcase
            )
          end
        end
      end
    end
  end
end
