# app/models/gift_card.rb
class GiftCard < ApplicationRecord
  belongs_to :user
  belongs_to :business
  has_many :transactions, dependent: :destroy
  has_many :wallet_passes, dependent: :destroy
  
  # Callbacks
  before_validation :generate_card_number, on: :create
  
  # Balance calculation
  def balance
    transactions.completed.sum(:amount)
  end
  
  def points_balance
    transactions.completed.sum(:points)
  end
  
  # No wallet-specific logic here
  # That's in WalletPass model
  
  private
  
  def generate_card_number
    self.card_number ||= loop do
      number = "TAG2-#{SecureRandom.alphanumeric(4).upcase}-" \
               "#{SecureRandom.random_number(10000).to_s.rjust(4, '0')}-" \
               "#{SecureRandom.alphanumeric(4).upcase}"
      break number unless GiftCard.exists?(card_number: number)
    end
  end
end