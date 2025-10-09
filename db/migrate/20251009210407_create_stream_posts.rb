class CreateStreamPosts < ActiveRecord::Migration[8.1]
  def change
    create_table :stream_posts do |t|
      t.references :account, null: false, foreign_key: true
      t.string :instagram_media_id
      t.string :username
      t.string :media_url
      t.string :permalink
      t.text :caption
      t.datetime :timestamp
      t.boolean :approved

      t.timestamps
    end
  end
end
