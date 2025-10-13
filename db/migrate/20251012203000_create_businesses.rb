# db/migrate/xxx_create_businesses.rb
class CreateBusinesses < ActiveRecord::Migration[7.0]
  def change
    create_table :businesses do |t|
      # Relationships
      t.references :account, null: false, foreign_key: true
      
      # Basic info
      t.string :name, null: false
      t.string :slug
      
      # Location
      t.string :location
      t.text :address
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      
      # Contact
      t.string :phone
      t.string :email
      t.string :instagram_handle
      t.string :website_url
      
      # Branding
      t.string :logo_url
      t.string :brand_color, default: '#3B82F6'
      t.string :accent_color
      
      # Status
      t.string :status, default: 'active', null: false
      
      # Business hours
      t.jsonb :business_hours, default: {}
      
      # ========== REWARD SETTINGS ==========
      
      # Click rewards
      t.decimal :click_reward_amount, precision: 10, scale: 2, default: 0.50
      t.boolean :click_reward_enabled, default: true
      
      # Referral rewards
      t.decimal :referral_bonus_amount, precision: 10, scale: 2, default: 5.00
      t.boolean :referral_bonus_enabled, default: true
      
      # Points system
      t.integer :points_per_dollar, default: 10
      t.integer :points_to_dollars_rate, default: 100
      t.boolean :points_enabled, default: true
      
      # Streak bonuses
      t.boolean :streak_bonus_enabled, default: false
      t.decimal :streak_bonus_per_day, precision: 10, scale: 2, default: 0.50
      t.integer :streak_points_per_day, default: 5
      
      # Birthday bonuses
      t.boolean :birthday_bonus_enabled, default: false
      t.decimal :birthday_bonus_amount, precision: 10, scale: 2, default: 10.00
      
      # Tier configuration
      t.jsonb :tier_multipliers, default: {
        'bronze' => 1.0,
        'silver' => 1.5,
        'gold' => 2.0
      }
      
      t.jsonb :tier_requirements, default: {
        'silver' => { 'earned' => 50, 'points' => 250, 'visits' => 5 },
        'gold' => { 'earned' => 200, 'points' => 1000, 'visits' => 20 }
      }
      
      t.jsonb :membership_multipliers, default: {
        'basic' => 1.0,
        'premium' => 1.5,
        'vip' => 2.0
      }
      
      t.jsonb :reward_settings, default: {}
      
      t.timestamps
      
      # Indexes
      t.index :slug, unique: true
      t.index :status
      t.index [:latitude, :longitude]
      t.index :business_hours, using: :gin
      t.index :tier_multipliers, using: :gin
      t.index :tier_requirements, using: :gin
      t.index :membership_multipliers, using: :gin
      t.index :reward_settings, using: :gin
    end
  end
end