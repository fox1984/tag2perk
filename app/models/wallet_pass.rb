# app/models/wallet_pass.rb
class WalletPass < ApplicationRecord
  belongs_to :gift_card
  
  # Delegates to gift card
  delegate :user, :business, :balance, :points_balance, :tier, to: :gift_card
  
  # Validations
  validates :platform, inclusion: { in: %w[apple google sms email physical] }
  validates :serial_number, presence: true, uniqueness: true
  validates :status, inclusion: { in: %w[pending installed active deleted] }
  
  # Scopes
  scope :active, -> { where(status: %w[installed active]) }
  scope :apple, -> { where(platform: 'apple') }
  scope :google, -> { where(platform: 'google') }
  
  # Callbacks
  before_validation :generate_serial_number, on: :create
  after_create :generate_pass_file
  after_update :push_update, if: :should_push_update?
  
  # Generate the actual pass file
  def generate_pass_file
    case platform
    when 'apple'
      ApplePassGenerator.new(self).generate
    when 'google'
      GooglePassGenerator.new(self).generate
    end
  end
  
  # Push update to device
  def push_update
    return unless active? && push_token.present?
    
    case platform
    when 'apple'
      ApplePassNotifier.notify(self)
    when 'google'
      GooglePassNotifier.notify(self)
    end
    
    touch(:last_updated_at)
  end
  
  # Mark as installed (called by Apple/Google webhook)
  def mark_installed!
    update!(
      status: 'installed',
      installed_at: Time.current
    )
  end
  
  # Mark as deleted (called by webhook)
  def mark_deleted!
    update!(
      status: 'deleted',
      deleted_at: Time.current
    )
  end
  
  private
  
  def generate_serial_number
    self.serial_number ||= SecureRandom.uuid
  end
  
  def should_push_update?
    saved_change_to_attribute?(:metadata) ||
      gift_card.balance_changed? ||
      gift_card.tier_changed?
  end
end