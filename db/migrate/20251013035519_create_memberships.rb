class CreateMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :business, null: false, foreign_key: true
      t.string :membership_type
      t.string :status
      t.datetime :started_at
      t.datetime :expires_at
      t.boolean :auto_renew
      t.string :stripe_subscription_id
      t.decimal :price
      t.string :billing_interval
      t.jsonb :benefits

      t.timestamps
    end
  end
end
