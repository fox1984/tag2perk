class AddInstagramToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :instagram_username, :string
    add_column :users, :instagram_user_id, :string
  end
end
