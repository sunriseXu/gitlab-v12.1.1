class AddLastWikiSyncedAtToProjectRegistry < ActiveRecord::Migration[4.2]
  DOWNTIME = false

  def change
    add_column :project_registry, :last_wiki_synced_at, :datetime
    add_column :project_registry, :last_wiki_successful_sync_at, :datetime
  end
end
