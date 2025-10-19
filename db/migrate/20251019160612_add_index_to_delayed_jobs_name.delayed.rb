# This migration comes from delayed (originally 3)
class AddIndexToDelayedJobsName < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    if connection.adapter_name == "PostgreSQL"
      add_index :delayed_jobs, :name, algorithm: :concurrently
    else
      add_index :delayed_jobs, :name
    end
  end
end
