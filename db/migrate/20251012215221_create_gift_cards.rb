class CreateGiftCards < ActiveRecord::Migration[8.1]
  def change
    create_table :gift_cards do |t|
      t.references :user, null: false, foreign_key: true
      t.references :business, null: false, foreign_key: true
      t.string :card_number
      t.string :status
      t.string :tier

      t.timestamps
    end
  end
end
