# app/models/challenge_completion.rb
class ChallengeCompletion < ApplicationRecord
    # Relationships
    belongs_to :challenge, counter_cache: :completions_count
    belongs_to :user
    belongs_to :gift_card
    belongs_to :reward_transaction, class_name: 'Transaction', foreign_key: 'transaction_id', optional: true
    belongs_to :reviewed_by, class_name: 'User', optional: true
    
    # Validations
    validates :status, inclusion: { in: %w[pending approved rejected expired] }
    validates :submission_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid URL" }, allow_blank: true
    
    validate :user_can_participate, on: :create
    validate :challenge_is_active, on: :create
    
    # Callbacks
    before_validation :set_submitted_at, on: :create
    after_create :increment_attempts_count
    after_update :create_reward_transaction, if: :just_approved?
    after_update :update_pending_count, if: :saved_change_to_status?
    
    # Scopes
    scope :pending, -> { where(status: 'pending') }
    scope :approved, -> { where(status: 'approved') }
    scope :rejected, -> { where(status: 'rejected') }
    scope :recent, -> { order(submitted_at: :desc) }
    scope :needs_review, -> { pending.order(submitted_at: :asc) }
    
    # Status checks
    def pending?
      status == 'pending'
    end
    
    def approved?
      status == 'approved'
    end
    
    def rejected?
      status == 'rejected'
    end
    
    # Actions
    def approve!(reviewed_by_user: nil)
      return false unless pending?
      
      ActiveRecord::Base.transaction do
        update!(
          status: 'approved',
          reviewed_at: Time.current,
          approved_at: Time.current,
          reviewed_by: reviewed_by_user
        )
        
        true
      end
    end
    
    def reject!(reason:, reviewed_by_user: nil)
      return false unless pending?
      
      update!(
        status: 'rejected',
        rejection_reason: reason,
        reviewed_at: Time.current,
        rejected_at: Time.current,
        reviewed_by: reviewed_by_user
      )
    end
    
    def auto_approve!
      approve! if challenge.auto_approve && pending?
    end
    
    # Submission data helpers
    def instagram_url
      submission_data['instagram_url']
    end
    
    def photo_urls
      submission_data['photo_urls'] || []
    end
    
    def has_proof?
      submission_url.present? || photo_urls.any?
    end
    
    private
    
    def set_submitted_at
      self.submitted_at ||= Time.current
    end
    
    def user_can_participate
      unless challenge.can_participate?(user)
        errors.add(:base, "You cannot participate in this challenge")
      end
    end
    
    def challenge_is_active
      unless challenge.active?
        errors.add(:base, "This challenge is not currently active")
      end
    end
    
    def increment_attempts_count
      challenge.increment!(:attempts_count)
    end
    
    def just_approved?
      saved_change_to_status? && status == 'approved' && status_before_last_save == 'pending'
    end
    
    def create_reward_transaction
      # Calculate rewards (with tier multiplier)
      base_amount = challenge.reward_amount
      base_points = challenge.reward_points
      
      # Apply tier multiplier
      multiplier = gift_card.earn_multiplier
      final_amount = (base_amount * multiplier).round(2)
      final_points = (base_points * multiplier).to_i
      
      # Create the transaction
      tx = TransactionBuilder.new(gift_card: gift_card)
        .earn_from_challenge(
          challenge,
          amount: final_amount,
          points: final_points
        )
        .save!
      
      # Link transaction to this completion
      update_column(:transaction_id, tx.id)
      update_columns(
        reward_amount_earned: final_amount,
        reward_points_earned: final_points
      )
    end
    
    def update_pending_count
      if status_before_last_save == 'pending' && status != 'pending'
        challenge.decrement!(:pending_completions_count)
      elsif status == 'pending' && status_before_last_save != 'pending'
        challenge.increment!(:pending_completions_count)
      end
    end
  end