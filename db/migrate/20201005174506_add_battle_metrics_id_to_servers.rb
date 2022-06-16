class AddBattleMetricsIdToServers < ActiveRecord::Migration[6.0]
  def change
    add_column :servers, :battle_metrics_id, :string, limit: 16
  end
end
