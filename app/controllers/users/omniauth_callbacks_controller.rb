class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  include Jumpstart::Omniauth::Callbacks

  # Called after Facebook account is connected
  def facebook_connected(connected_account)
    auth = request.env['omniauth.auth']
    access_token = connected_account.access_token
    
    # Try to fetch Instagram Business account
    instagram_business = fetch_instagram_business_account(access_token)
    
    if instagram_business
      # Business flow - save to Account
      current_account.update(
        instagram_user_id: instagram_business['id'],
        instagram_username: instagram_business['username']
      )
      
      Rails.logger.info "Connected business Instagram: @#{instagram_business['username']}"
    else
      # Customer flow - save to User (for verification)
      # Get basic Instagram info if available
      instagram_user = fetch_instagram_basic(access_token)
      
      if instagram_user
        current_user.update(
          instagram_username: instagram_user['username'],
          instagram_user_id: instagram_user['id']
        )
        
        Rails.logger.info "Connected customer Instagram: @#{instagram_user['username']}"
      else
        Rails.logger.warn "No Instagram account found for user"
      end
    end
  end
  
  private
  
  def fetch_instagram_business_account(access_token)
    # Get Facebook Pages
    response = HTTParty.get(
      'https://graph.facebook.com/v18.0/me/accounts',
      query: {
        fields: 'instagram_business_account{id,username}',
        access_token: access_token
      }
    )
    
    # Extract Instagram Business account from first page
    page_with_instagram = response['data']&.find { |page| page['instagram_business_account'].present? }
    page_with_instagram&.dig('instagram_business_account')
  rescue => e
    Rails.logger.error "Failed to fetch Instagram Business: #{e.message}"
    nil
  end
  
  def fetch_instagram_basic(access_token)
    # Try to get basic Instagram info (for personal accounts linked to Facebook)
    response = HTTParty.get(
      'https://graph.facebook.com/v18.0/me',
      query: {
        fields: 'id,name',
        access_token: access_token
      }
    )
    
    # This won't actually give us Instagram for personal accounts
    # without instagram_basic scope, but framework is here
    nil
  rescue => e
    Rails.logger.error "Failed to fetch Instagram Basic: #{e.message}"
    nil
  end
end