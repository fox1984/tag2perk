class CreateWalletPasses < ActiveRecord::Migration[8.1]
  def change
    create_table :wallet_passes do |t|
      t.references :gift_card, null: false, foreign_key: true
      t.string :platform
      t.string :serial_number
      t.string :status
      t.datetime :installed_at
      t.datetime :last_updated_at
      t.datetime :deleted_at
      t.string :push_token
      t.jsonb :metadata

      t.timestamps
    end
  end
end
