# db/migrate/[timestamp]_create_transactions.rb
class CreateTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :transactions do |t|
      # Core relationships
      t.references :gift_card, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :business, null: false, foreign_key: true
      
      # The money/points
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.integer :points, default: 0, null: false
      
      # What type of transaction
      t.string :transaction_type, null: false
      
      # What caused it (polymorphic)
      t.integer :source_id
      t.string :source_type
      
      # Flexible data storage
      t.jsonb :metadata, default: {}, null: false
      
      # Human-readable description
      t.text :description
      
      # Processing status
      t.string :status, default: 'completed', null: false
      
      t.timestamps
      
      # Indexes for performance
      t.index [:gift_card_id, :created_at], name: 'index_transactions_on_card_and_date'
      t.index [:user_id, :business_id], name: 'index_transactions_on_user_business'
      t.index [:source_type, :source_id], name: 'index_transactions_on_source'
      t.index :transaction_type
      t.index :status
      t.index :created_at
      t.index :metadata, using: :gin
      
      # Check constraint: amount cannot be zero
      t.check_constraint 'amount != 0', name: 'amount_not_zero'
    end
  end
end