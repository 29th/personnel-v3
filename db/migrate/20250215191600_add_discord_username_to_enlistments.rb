class AddDiscordUsernameToEnlistments < ActiveRecord::Migration[7.1]
  def change
    add_column :enlistments, :discord_username, :string
  end
end
