# frozen_string_literal: true

module Maintenance
  class GenerateMissingCoatsTask < MaintenanceTasks::Task
    def collection
      User
        .where(id: User.active.select(:id), service_coat_data: nil)
        .or(
          User.where(id: User.honorably_discharged.select(:id),
            service_coat_data: nil)
        )
    end

    def process(user)
      GenerateServiceCoatJob.perform_now(user)
    end
  end
end
