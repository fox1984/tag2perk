class AddInstagramToAccounts < ActiveRecord::Migration[8.1]
  def change
    add_column :accounts, :instagram_user_id, :string
    add_column :accounts, :instagram_username, :string
  end
end
