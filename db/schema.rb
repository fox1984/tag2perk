# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2025_10_13_172707) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "account_invitations", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.bigint "invited_by_id"
    t.string "name", null: false
    t.jsonb "roles", default: {}, null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "email"], name: "index_account_invitations_on_account_id_and_email", unique: true
    t.index ["invited_by_id"], name: "index_account_invitations_on_invited_by_id"
    t.index ["token"], name: "index_account_invitations_on_token", unique: true
  end

  create_table "account_users", force: :cascade do |t|
    t.bigint "account_id"
    t.datetime "created_at", null: false
    t.jsonb "roles", default: {}, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["account_id", "user_id"], name: "index_account_users_on_account_id_and_user_id", unique: true
  end

  create_table "accounts", force: :cascade do |t|
    t.integer "account_users_count", default: 0
    t.string "billing_email"
    t.datetime "created_at", null: false
    t.string "domain"
    t.text "extra_billing_info"
    t.string "instagram_user_id"
    t.string "instagram_username"
    t.string "name", null: false
    t.bigint "owner_id"
    t.boolean "personal", default: false
    t.string "subdomain"
    t.datetime "updated_at", null: false
    t.index ["owner_id"], name: "index_accounts_on_owner_id"
  end

  create_table "action_text_embeds", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "fields"
    t.datetime "updated_at", null: false
    t.string "url"
  end

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", precision: nil, null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", precision: nil, null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "announcements", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "kind"
    t.datetime "published_at", precision: nil
    t.string "title"
    t.datetime "updated_at", null: false
  end

  create_table "api_tokens", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", precision: nil
    t.datetime "last_used_at", precision: nil
    t.jsonb "metadata"
    t.string "name"
    t.string "token"
    t.boolean "transient", default: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["token"], name: "index_api_tokens_on_token", unique: true
    t.index ["user_id"], name: "index_api_tokens_on_user_id"
  end

  create_table "businesses", force: :cascade do |t|
    t.string "accent_color"
    t.bigint "account_id", null: false
    t.text "address"
    t.decimal "birthday_bonus_amount", precision: 10, scale: 2, default: "10.0"
    t.boolean "birthday_bonus_enabled", default: false
    t.string "brand_color", default: "#3B82F6"
    t.jsonb "business_hours", default: {}
    t.decimal "click_reward_amount", precision: 10, scale: 2, default: "0.5"
    t.boolean "click_reward_enabled", default: true
    t.datetime "created_at", null: false
    t.string "email"
    t.string "instagram_handle"
    t.decimal "latitude", precision: 10, scale: 6
    t.string "location"
    t.string "logo_url"
    t.decimal "longitude", precision: 10, scale: 6
    t.jsonb "membership_multipliers", default: {"vip" => 2.0, "basic" => 1.0, "premium" => 1.5}
    t.string "name", null: false
    t.string "phone"
    t.boolean "points_enabled", default: true
    t.integer "points_per_dollar", default: 10
    t.integer "points_to_dollars_rate", default: 100
    t.decimal "referral_bonus_amount", precision: 10, scale: 2, default: "5.0"
    t.boolean "referral_bonus_enabled", default: true
    t.jsonb "reward_settings", default: {}
    t.string "slug"
    t.string "status", default: "active", null: false
    t.boolean "streak_bonus_enabled", default: false
    t.decimal "streak_bonus_per_day", precision: 10, scale: 2, default: "0.5"
    t.integer "streak_points_per_day", default: 5
    t.jsonb "tier_multipliers", default: {"gold" => 2.0, "bronze" => 1.0, "silver" => 1.5}
    t.jsonb "tier_requirements", default: {"gold" => {"earned" => 200, "points" => 1000, "visits" => 20}, "silver" => {"earned" => 50, "points" => 250, "visits" => 5}}
    t.datetime "updated_at", null: false
    t.string "website_url"
    t.index ["account_id"], name: "index_businesses_on_account_id"
    t.index ["business_hours"], name: "index_businesses_on_business_hours", using: :gin
    t.index ["latitude", "longitude"], name: "index_businesses_on_latitude_and_longitude"
    t.index ["membership_multipliers"], name: "index_businesses_on_membership_multipliers", using: :gin
    t.index ["reward_settings"], name: "index_businesses_on_reward_settings", using: :gin
    t.index ["slug"], name: "index_businesses_on_slug", unique: true
    t.index ["status"], name: "index_businesses_on_status"
    t.index ["tier_multipliers"], name: "index_businesses_on_tier_multipliers", using: :gin
    t.index ["tier_requirements"], name: "index_businesses_on_tier_requirements", using: :gin
  end

  create_table "challenge_completions", force: :cascade do |t|
    t.datetime "approved_at"
    t.bigint "challenge_id", null: false
    t.datetime "created_at", null: false
    t.bigint "gift_card_id", null: false
    t.datetime "rejected_at"
    t.string "rejection_reason"
    t.text "review_notes"
    t.datetime "reviewed_at"
    t.bigint "reviewed_by_id"
    t.decimal "reward_amount_earned", precision: 10, scale: 2
    t.integer "reward_points_earned"
    t.string "status", default: "pending", null: false
    t.jsonb "submission_data", default: {}, null: false
    t.text "submission_notes"
    t.string "submission_type"
    t.string "submission_url"
    t.datetime "submitted_at"
    t.bigint "transaction_id"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["approved_at"], name: "index_challenge_completions_on_approved_at"
    t.index ["challenge_id", "user_id", "status"], name: "index_one_pending_per_user_per_challenge", unique: true, where: "((status)::text = 'pending'::text)"
    t.index ["challenge_id", "user_id"], name: "index_completions_on_challenge_user"
    t.index ["challenge_id"], name: "index_challenge_completions_on_challenge_id"
    t.index ["gift_card_id"], name: "index_challenge_completions_on_gift_card_id"
    t.index ["reviewed_by_id"], name: "index_challenge_completions_on_reviewed_by_id"
    t.index ["status"], name: "index_challenge_completions_on_status"
    t.index ["submission_data"], name: "index_challenge_completions_on_submission_data", using: :gin
    t.index ["submitted_at"], name: "index_challenge_completions_on_submitted_at"
    t.index ["transaction_id"], name: "index_challenge_completions_on_transaction_id"
    t.index ["user_id", "status"], name: "index_challenge_completions_on_user_id_and_status"
    t.index ["user_id"], name: "index_challenge_completions_on_user_id"
  end

  create_table "challenges", force: :cascade do |t|
    t.bigint "business_id", null: false
    t.string "challenge_type"
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "ends_at"
    t.integer "pending_completions_count", default: 0, null: false
    t.decimal "reward_amount"
    t.integer "reward_points"
    t.datetime "starts_at"
    t.string "status"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["business_id"], name: "index_challenges_on_business_id"
  end

  create_table "connected_accounts", force: :cascade do |t|
    t.string "access_token"
    t.string "access_token_secret"
    t.jsonb "auth"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "expires_at", precision: nil
    t.bigint "owner_id"
    t.string "owner_type"
    t.string "provider"
    t.string "refresh_token"
    t.string "uid"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["owner_id", "owner_type"], name: "index_connected_accounts_on_owner_id_and_owner_type"
  end

  create_table "gift_cards", force: :cascade do |t|
    t.bigint "business_id", null: false
    t.string "card_number"
    t.datetime "created_at", null: false
    t.string "status"
    t.string "tier"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["business_id"], name: "index_gift_cards_on_business_id"
    t.index ["user_id"], name: "index_gift_cards_on_user_id"
  end

  create_table "inbound_webhooks", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
  end

  create_table "memberships", force: :cascade do |t|
    t.boolean "auto_renew"
    t.jsonb "benefits"
    t.string "billing_interval"
    t.bigint "business_id", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at"
    t.string "membership_type"
    t.decimal "price"
    t.datetime "started_at"
    t.string "status"
    t.string "stripe_subscription_id"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["business_id"], name: "index_memberships_on_business_id"
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "noticed_events", force: :cascade do |t|
    t.bigint "account_id"
    t.datetime "created_at", null: false
    t.integer "notifications_count"
    t.jsonb "params"
    t.bigint "record_id"
    t.string "record_type"
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_noticed_events_on_account_id"
    t.index ["record_type", "record_id"], name: "index_noticed_events_on_record"
  end

  create_table "noticed_notifications", force: :cascade do |t|
    t.bigint "account_id"
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.datetime "read_at", precision: nil
    t.bigint "recipient_id", null: false
    t.string "recipient_type", null: false
    t.datetime "seen_at", precision: nil
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_noticed_notifications_on_account_id"
    t.index ["event_id"], name: "index_noticed_notifications_on_event_id"
    t.index ["recipient_type", "recipient_id"], name: "index_noticed_notifications_on_recipient"
  end

  create_table "notification_tokens", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "platform", null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_notification_tokens_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "interacted_at", precision: nil
    t.jsonb "params"
    t.datetime "read_at", precision: nil
    t.bigint "recipient_id", null: false
    t.string "recipient_type", null: false
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_notifications_on_account_id"
    t.index ["recipient_type", "recipient_id"], name: "index_notifications_on_recipient_type_and_recipient_id"
  end

  create_table "pay_charges", force: :cascade do |t|
    t.integer "amount", null: false
    t.integer "amount_refunded"
    t.integer "application_fee_amount"
    t.datetime "created_at", precision: nil, null: false
    t.string "currency"
    t.bigint "customer_id"
    t.jsonb "data"
    t.jsonb "metadata"
    t.jsonb "object"
    t.string "processor_id", null: false
    t.string "stripe_account"
    t.integer "subscription_id"
    t.string "type"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["customer_id", "processor_id"], name: "index_pay_charges_on_customer_id_and_processor_id", unique: true
  end

  create_table "pay_customers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "data"
    t.boolean "default"
    t.datetime "deleted_at", precision: nil
    t.jsonb "object"
    t.bigint "owner_id"
    t.string "owner_type"
    t.string "processor"
    t.string "processor_id"
    t.string "stripe_account"
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["owner_type", "owner_id", "deleted_at"], name: "customer_owner_processor_index"
    t.index ["processor", "processor_id"], name: "index_pay_customers_on_processor_and_processor_id"
  end

  create_table "pay_merchants", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "data"
    t.boolean "default"
    t.bigint "owner_id"
    t.string "owner_type"
    t.string "processor"
    t.string "processor_id"
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["owner_type", "owner_id", "processor"], name: "index_pay_merchants_on_owner_type_and_owner_id_and_processor"
  end

  create_table "pay_payment_methods", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "customer_id"
    t.jsonb "data"
    t.boolean "default"
    t.string "payment_method_type"
    t.string "processor_id"
    t.string "stripe_account"
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["customer_id", "processor_id"], name: "index_pay_payment_methods_on_customer_id_and_processor_id", unique: true
  end

  create_table "pay_subscriptions", id: :serial, force: :cascade do |t|
    t.decimal "application_fee_percent", precision: 8, scale: 2
    t.datetime "created_at", precision: nil
    t.datetime "current_period_end"
    t.datetime "current_period_start"
    t.bigint "customer_id"
    t.jsonb "data"
    t.datetime "ends_at", precision: nil
    t.jsonb "metadata"
    t.boolean "metered"
    t.string "name", null: false
    t.jsonb "object"
    t.string "pause_behavior"
    t.datetime "pause_resumes_at"
    t.datetime "pause_starts_at"
    t.string "payment_method_id"
    t.string "processor_id", null: false
    t.string "processor_plan", null: false
    t.integer "quantity", default: 1, null: false
    t.string "status"
    t.string "stripe_account"
    t.datetime "trial_ends_at", precision: nil
    t.string "type"
    t.datetime "updated_at", precision: nil
    t.index ["customer_id", "processor_id"], name: "index_pay_subscriptions_on_customer_id_and_processor_id", unique: true
    t.index ["metered"], name: "index_pay_subscriptions_on_metered"
    t.index ["pause_starts_at"], name: "index_pay_subscriptions_on_pause_starts_at"
  end

  create_table "pay_webhooks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "event"
    t.string "event_type"
    t.string "processor"
    t.datetime "updated_at", null: false
  end

  create_table "plans", force: :cascade do |t|
    t.integer "amount", default: 0, null: false
    t.string "braintree_id"
    t.boolean "charge_per_unit"
    t.string "contact_url"
    t.datetime "created_at", precision: nil, null: false
    t.string "currency"
    t.string "description"
    t.jsonb "details"
    t.string "fake_processor_id"
    t.boolean "hidden"
    t.string "interval", null: false
    t.integer "interval_count", default: 1
    t.string "lemon_squeezy_id"
    t.string "name", null: false
    t.string "paddle_billing_id"
    t.string "paddle_classic_id"
    t.string "stripe_id"
    t.integer "trial_period_days", default: 0
    t.string "unit_label"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "stream_posts", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.boolean "approved"
    t.text "caption"
    t.datetime "created_at", null: false
    t.string "instagram_media_id"
    t.string "media_url"
    t.string "permalink"
    t.datetime "timestamp"
    t.datetime "updated_at", null: false
    t.string "username"
    t.index ["account_id"], name: "index_stream_posts_on_account_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.bigint "business_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.bigint "gift_card_id", null: false
    t.jsonb "metadata", default: {}, null: false
    t.integer "points", default: 0, null: false
    t.integer "source_id"
    t.string "source_type"
    t.string "status", default: "completed", null: false
    t.string "transaction_type", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["business_id"], name: "index_transactions_on_business_id"
    t.index ["created_at"], name: "index_transactions_on_created_at"
    t.index ["gift_card_id", "created_at"], name: "index_transactions_on_card_and_date"
    t.index ["gift_card_id"], name: "index_transactions_on_gift_card_id"
    t.index ["metadata"], name: "index_transactions_on_metadata", using: :gin
    t.index ["source_type", "source_id"], name: "index_transactions_on_source"
    t.index ["status"], name: "index_transactions_on_status"
    t.index ["transaction_type"], name: "index_transactions_on_transaction_type"
    t.index ["user_id", "business_id"], name: "index_transactions_on_user_business"
    t.index ["user_id"], name: "index_transactions_on_user_id"
    t.check_constraint "amount <> 0::numeric", name: "amount_not_zero"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "accepted_privacy_at", precision: nil
    t.datetime "accepted_terms_at", precision: nil
    t.boolean "admin"
    t.datetime "announcements_read_at", precision: nil
    t.datetime "confirmation_sent_at", precision: nil
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name"
    t.string "instagram_user_id"
    t.string "instagram_username"
    t.datetime "invitation_accepted_at", precision: nil
    t.datetime "invitation_created_at", precision: nil
    t.integer "invitation_limit"
    t.datetime "invitation_sent_at", precision: nil
    t.string "invitation_token"
    t.integer "invitations_count", default: 0
    t.bigint "invited_by_id"
    t.string "invited_by_type"
    t.string "last_name"
    t.integer "last_otp_timestep"
    t.virtual "name", type: :string, as: "(((first_name)::text || ' '::text) || (COALESCE(last_name, ''::character varying))::text)", stored: true
    t.text "otp_backup_codes"
    t.boolean "otp_required_for_login"
    t.string "otp_secret"
    t.jsonb "preferences"
    t.string "preferred_language"
    t.datetime "remember_created_at", precision: nil
    t.datetime "reset_password_sent_at", precision: nil
    t.string "reset_password_token"
    t.string "time_zone"
    t.string "unconfirmed_email"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by_type_and_invited_by_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "wallet_passes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.bigint "gift_card_id", null: false
    t.datetime "installed_at"
    t.datetime "last_updated_at"
    t.jsonb "metadata"
    t.string "platform"
    t.string "push_token"
    t.string "serial_number"
    t.string "status"
    t.datetime "updated_at", null: false
    t.index ["gift_card_id"], name: "index_wallet_passes_on_gift_card_id"
  end

  add_foreign_key "account_invitations", "accounts"
  add_foreign_key "account_invitations", "users", column: "invited_by_id"
  add_foreign_key "account_users", "accounts"
  add_foreign_key "account_users", "users"
  add_foreign_key "accounts", "users", column: "owner_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "api_tokens", "users"
  add_foreign_key "businesses", "accounts"
  add_foreign_key "challenge_completions", "challenges"
  add_foreign_key "challenge_completions", "gift_cards"
  add_foreign_key "challenge_completions", "transactions"
  add_foreign_key "challenge_completions", "users"
  add_foreign_key "challenge_completions", "users", column: "reviewed_by_id"
  add_foreign_key "challenges", "businesses"
  add_foreign_key "gift_cards", "businesses"
  add_foreign_key "gift_cards", "users"
  add_foreign_key "memberships", "businesses"
  add_foreign_key "memberships", "users"
  add_foreign_key "pay_charges", "pay_customers", column: "customer_id"
  add_foreign_key "pay_payment_methods", "pay_customers", column: "customer_id"
  add_foreign_key "pay_subscriptions", "pay_customers", column: "customer_id"
  add_foreign_key "stream_posts", "accounts"
  add_foreign_key "transactions", "businesses"
  add_foreign_key "transactions", "gift_cards"
  add_foreign_key "transactions", "users"
  add_foreign_key "wallet_passes", "gift_cards"
end
