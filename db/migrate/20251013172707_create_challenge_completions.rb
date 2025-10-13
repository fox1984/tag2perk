# db/migrate/[timestamp]_create_challenge_completions.rb
class CreateChallengeCompletions < ActiveRecord::Migration[7.0]
  def change
    create_table :challenge_completions do |t|
      # Relationships
      t.references :challenge, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :gift_card, null: false, foreign_key: true
      t.references :transaction, foreign_key: true
      t.references :reviewed_by, foreign_key: { to_table: :users }
      
      # Status
      t.string :status, default: 'pending', null: false
      
      # Submission details
      t.text :submission_notes
      t.string :submission_url
      t.string :submission_type
      
      # Proof/Evidence (JSONB)
      t.jsonb :submission_data, default: {}, null: false
      
      # Review tracking
      t.datetime :submitted_at
      t.datetime :reviewed_at
      t.datetime :approved_at
      t.datetime :rejected_at
      t.text :review_notes
      t.string :rejection_reason
      
      # Reward tracking
      t.decimal :reward_amount_earned, precision: 10, scale: 2
      t.integer :reward_points_earned
      
      t.timestamps
      
      # Indexes
      t.index [:challenge_id, :user_id], name: 'index_completions_on_challenge_user'
      t.index [:user_id, :status]
      t.index :status
      t.index :submitted_at
      t.index :approved_at
      t.index :submission_data, using: :gin
      
      # Prevent duplicate pending submissions
      t.index [:challenge_id, :user_id, :status], 
              unique: true,
              where: "status = 'pending'",
              name: 'index_one_pending_per_user_per_challenge'
    end
    
    # Add counter cache to challenges
    add_column :challenges, :pending_completions_count, :integer, default: 0, null: false
  end
end