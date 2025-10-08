class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  include Jumpstart::Omniauth::Callbacks

  # Called after Facebook account is connected
  def facebook_connected(connected_account)
    auth = request.env['omniauth.auth']
    
    # Fetch Instagram username from Facebook Graph API
    instagram_username = fetch_instagram_username(connected_account.access_token)
    
    if instagram_username
      current_user.update(
        instagram_username: instagram_username,
        instagram_user_id: auth.uid # Save this too for verification
      )
    end
  end
  
  private
  
  def fetch_instagram_username(access_token)
    # Query Facebook Graph API to get Instagram account
    response = HTTParty.get(
      'https://graph.facebook.com/v18.0/me/accounts',
      query: {
        fields: 'instagram_business_account{username,id}',
        access_token: access_token
      }
    )
    
    # Extract Instagram username from response
    instagram_account = response.dig('data', 0, 'instagram_business_account')
    instagram_account&.dig('username')
  rescue => e
    Rails.logger.error "Failed to fetch Instagram: #{e.message}"
    nil
  end
end