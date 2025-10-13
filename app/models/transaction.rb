# app/models/transaction.rb
class Transaction < ApplicationRecord
  # Relationships
  belongs_to :gift_card
  belongs_to :user
  belongs_to :business
  belongs_to :source, polymorphic: true, optional: true
  
  # Delegates
  delegate :tier, :tier_multipliers, to: :gift_card
  
  # Validations
  validates :amount, presence: true, numericality: { other_than: 0 }
  validates :points, numericality: { only_integer: true }
  validates :transaction_type, presence: true, inclusion: { in: :valid_types }
  validates :status, inclusion: { in: %w[pending completed failed reversed] }
  validates :description, length: { maximum: 1000 }
  
  # Transaction types
  TYPES = {
    # Earning transactions (positive amounts)
    earning: %w[
      earned_challenge
      earned_click
      earned_attribution
      earned_referral
      earned_membership
      earned_streak
      earned_bonus
      earned_tier_upgrade
    ],
    
    # Spending transactions (negative amounts)
    spending: %w[
      redeemed
    ],
    
    # Adjustments (can be positive or negative)
    adjustment: %w[
      adjusted
      refunded
      reversed
      expired
      bonus
    ],
    
    # Special
    special: %w[
      points_conversion
      tier_bonus
      birthday_bonus
    ]
  }.freeze
  
  ALL_TYPES = TYPES.values.flatten.freeze
  
  # Scopes
  scope :completed, -> { where(status: 'completed') }
  scope :pending, -> { where(status: 'pending') }
  scope :failed, -> { where(status: 'failed') }
  
  scope :earnings, -> { where('amount > 0') }
  scope :redemptions, -> { where('amount < 0') }
  scope :adjustments, -> { where(transaction_type: TYPES[:adjustment]) }
  
  scope :recent, -> { order(created_at: :desc) }
  scope :today, -> { where('created_at >= ?', Time.current.beginning_of_day) }
  scope :this_week, -> { where('created_at >= ?', Time.current.beginning_of_week) }
  scope :this_month, -> { where('created_at >= ?', Time.current.beginning_of_month) }
  
  scope :by_type, ->(type) { where(transaction_type: type) }
  scope :for_user_at_business, ->(user, business) { 
    where(user: user, business: business) 
  }
  
  # Callbacks
  after_create :update_gift_card_tier, if: :completed?
  after_create :notify_wallet_passes, if: :completed?
  after_create :check_milestones, if: :completed?
  after_create :update_account_fees, if: -> { completed? && earned? }
  
  # Class methods
  def self.valid_types
    ALL_TYPES
  end
  
  # Instance methods
  def earned?
    amount.positive?
  end
  
  def redeemed?
    amount.negative?
  end
  
  def completed?
    status == 'completed'
  end
  
  def pending?
    status == 'pending'
  end
  
  # Mark as completed
  def complete!
    update!(status: 'completed')
  end
  
  # Reverse this transaction
  def reverse!(reason:)
    return if status == 'reversed'
    
    Transaction.create!(
      gift_card: gift_card,
      user: user,
      business: business,
      amount: -amount,
      points: -points,
      transaction_type: 'reversed',
      source: self,
      description: "Reversed: #{description} - Reason: #{reason}",
      metadata: metadata.merge(
        reversed_transaction_id: id,
        reversal_reason: reason
      )
    )
    
    update!(status: 'reversed')
  end
  
  # Apply tier multiplier
  def apply_tier_multiplier!
    return unless earned? && gift_card
    
    multiplier = gift_card.earn_multiplier
    
    if multiplier != 1.0
      self.metadata ||= {}
      self.metadata['base_amount'] = amount
      self.metadata['tier_multiplier'] = multiplier
      self.amount = (amount * multiplier).round(2)
    end
  end
  
  private
  
  def update_gift_card_tier
    gift_card.check_tier_upgrade!
  end
  
  def notify_wallet_passes
    gift_card.wallet_passes.active.each do |pass|
      WalletPassUpdateJob.perform_async(pass.id)
    end
  end
  
  def check_milestones
    TransactionMilestoneChecker.new(self).check!
  end
  
  def update_account_fees
    # Add platform fee to account's pending fees
    business.account.add_platform_fee(amount)
  end
end