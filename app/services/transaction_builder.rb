# app/services/transaction_builder.rb
class TransactionBuilder
    attr_reader :transaction
    
    def initialize(gift_card:, user: nil, business: nil)
      @gift_card = gift_card
      @user = user || gift_card.user
      @business = business || gift_card.business
      @transaction = Transaction.new(
        gift_card: @gift_card,
        user: @user,
        business: @business
      )
    end
    
    # Earnings
    def earn_from_challenge(challenge, amount: nil, points: nil)
      # Use challenge's reward or business defaults
      final_amount = amount || challenge.reward_amount
      final_points = points || challenge.reward_points || calculate_points(final_amount)
      
      @transaction.assign_attributes(
        amount: final_amount,
        points: final_points,
        transaction_type: 'earned_challenge',
        source: challenge,
        description: "Completed challenge: #{challenge.title}",
        metadata: {
          challenge_id: challenge.id,
          challenge_name: challenge.title,
          reward_amount: final_amount,
          base_amount: final_amount # Before multiplier
        }
      )
      
      @transaction.apply_tier_multiplier!
      self
    end
    
    def earn_from_click(post_url:, amount: nil)
      # Get click reward from business settings
      final_amount = amount || @business.click_reward_amount
      final_points = calculate_points(final_amount)
      
      @transaction.assign_attributes(
        amount: final_amount,
        points: final_points,
        transaction_type: 'earned_click',
        description: "Clicked business post",
        metadata: {
          post_url: post_url,
          clicked_at: Time.current
        }
      )
      self
    end
    
    def earn_from_attribution(code:, order_amount:, commission_rate: nil)
      # Use code's commission rate
      rate = commission_rate || code.commission_rate
      commission = (order_amount * rate).round(2)
      points = calculate_points(commission)
      
      @transaction.assign_attributes(
        amount: commission,
        points: points,
        transaction_type: 'earned_attribution',
        source: code,
        description: "Commission from code: #{code.code}",
        metadata: {
          attribution_code: code.code,
          order_amount: order_amount,
          commission_rate: rate,
          commission_amount: commission
        }
      )
      self
    end
    
    def earn_referral_bonus(referred_user:, amount: nil)
      # Get referral bonus from business settings
      final_amount = amount || @business.referral_bonus_amount
      final_points = calculate_points(final_amount)
      
      @transaction.assign_attributes(
        amount: final_amount,
        points: final_points,
        transaction_type: 'earned_referral',
        description: "Referral bonus for bringing #{referred_user.instagram_handle}",
        metadata: {
          referred_user_id: referred_user.id,
          referred_user_handle: referred_user.instagram_handle
        }
      )
      self
    end
    
    def earn_membership_bonus(membership:, amount: nil)
      # Get membership bonus from membership settings
      final_amount = amount || membership.benefits['monthly_bonus'] || 0
      return self if final_amount.zero?
      
      final_points = calculate_points(final_amount)
      
      @transaction.assign_attributes(
        amount: final_amount,
        points: final_points,
        transaction_type: 'earned_membership',
        source: membership,
        description: "#{membership.membership_type.titleize} member monthly bonus",
        metadata: {
          membership_id: membership.id,
          membership_type: membership.membership_type
        }
      )
      self
    end
    
    def earn_streak_bonus(streak_days:, amount: nil)
      # Calculate streak bonus from business settings
      final_amount = amount || @business.calculate_streak_bonus(streak_days)
      final_points = @business.streak_points_per_day * streak_days
      
      @transaction.assign_attributes(
        amount: final_amount,
        points: final_points,
        transaction_type: 'earned_streak',
        description: "#{streak_days} day visit streak bonus!",
        metadata: {
          streak_days: streak_days
        }
      )
      self
    end
    
    # Redemptions
    def redeem(amount:, staff_id: nil)
      @transaction.assign_attributes(
        amount: -amount.abs, # Ensure negative
        points: 0,
        transaction_type: 'redeemed',
        description: "Redeemed at checkout",
        metadata: {
          redeemed_by_staff_id: staff_id,
          redeemed_at: Time.current
        }
      )
      self
    end
    
    # Adjustments
    def adjust(amount:, reason:, adjusted_by: nil)
      @transaction.assign_attributes(
        amount: amount,
        points: 0,
        transaction_type: 'adjusted',
        description: "Balance adjustment: #{reason}",
        metadata: {
          adjustment_reason: reason,
          adjusted_by_id: adjusted_by&.id
        }
      )
      self
    end
    
    def refund(original_transaction:, reason:)
      @transaction.assign_attributes(
        amount: original_transaction.amount.abs,
        points: original_transaction.points,
        transaction_type: 'refunded',
        source: original_transaction,
        description: "Refund: #{reason}",
        metadata: {
          original_transaction_id: original_transaction.id,
          refund_reason: reason
        }
      )
      self
    end
    
    def bonus(amount:, reason:, given_by: nil, points: nil)
      final_points = points || calculate_points(amount)
      
      @transaction.assign_attributes(
        amount: amount,
        points: final_points,
        transaction_type: 'bonus',
        description: "Bonus: #{reason}",
        metadata: {
          bonus_reason: reason,
          given_by_id: given_by&.id
        }
      )
      self
    end
    
    # Special
    def convert_points_to_dollars(points_spent:, conversion_rate: nil)
      # Get conversion rate from business settings
      rate = conversion_rate || @business.points_to_dollars_rate
      dollars = (points_spent / rate.to_f).round(2)
      
      @transaction.assign_attributes(
        amount: dollars,
        points: -points_spent,
        transaction_type: 'points_conversion',
        description: "Converted #{points_spent} points to $#{dollars}",
        metadata: {
          points_spent: points_spent,
          conversion_rate: rate,
          dollars_received: dollars
        }
      )
      self
    end
    
    # Save and return
    def save
      @transaction.save
    end
    
    def save!
      @transaction.save!
    end
    
    def with_status(status)
      @transaction.status = status
      self
    end
    
    private
    
    # Calculate points based on dollars using business settings
    def calculate_points(amount)
      return 0 if amount.zero?
      
      # Get business's points-per-dollar ratio
      ratio = @business.points_per_dollar || 10 # Default fallback
      (amount * ratio).to_i
    end
  end