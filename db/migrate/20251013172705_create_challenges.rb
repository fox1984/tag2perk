class CreateChallenges < ActiveRecord::Migration[8.1]
  def change
    create_table :challenges do |t|
      # Relationships
      t.references :business, null: false, foreign_key: true
      
      # Basic info
      t.string :title, null: false
      t.text :description
      t.string :slug
      
      # Challenge type
      t.string :challenge_type, null: false
      # post_photo, post_video, check_in, review, bring_friend, visit_streak, etc.
      
      # Rewards
      t.decimal :reward_amount, precision: 10, scale: 2, default: 0, null: false
      t.integer :reward_points, default: 0, null: false
      
      # Status
      t.string :status, default: 'draft', null: false
      # draft, active, paused, completed, expired
      
      # Timing
      t.datetime :starts_at
      t.datetime :ends_at
      
      # Limits
      t.integer :max_completions # nil = unlimited
      t.integer :max_completions_per_user, default: 1
      t.integer :completions_count, default: 0, null: false # counter cache
      
      # Requirements (JSONB for flexibility)
      t.jsonb :requirements, default: {}, null: false
      
      # Approval settings
      t.boolean :requires_approval, default: true, null: false
      t.boolean :auto_approve, default: false, null: false
      
      # Display
      t.string :image_url
      t.string :icon
      t.integer :priority, default: 0
      
      # Tracking
      t.integer :views_count, default: 0
      t.integer :attempts_count, default: 0
      
      # Metadata
      t.jsonb :metadata, default: {}, null: false
      
      t.timestamps
      
      # Indexes
      t.index :slug
      t.index :challenge_type
      t.index :status
      t.index [:starts_at, :ends_at], name: 'index_challenges_on_active_period'
      t.index :priority
      t.index :requirements, using: :gin
      t.index :metadata, using: :gin
      
      # Check constraints
      t.check_constraint 'reward_amount >= 0', name: 'reward_amount_non_negative'
      t.check_constraint 'reward_points >= 0', name: 'reward_points_non_negative'
      t.check_constraint 'max_completions_per_user > 0', name: 'max_per_user_positive'
    end
  end
end
