class WebhooksController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [:instagram]
    
    # GET endpoint for webhook verification
    def instagram
        verify_token = Rails.application.credentials.dig(:omniauth, :facebook, :webhook_verify_token)        
        Rails.logger.info "Verify token: #{verify_token.inspect}"
        
        if params['hub.mode'] == 'subscribe' && 
           params['hub.verify_token'] == verify_token
          render plain: params['hub.challenge'], status: :ok
        else
          Rails.logger.info "Token mismatch. Expected: #{verify_token}, Got: #{params['hub.verify_token']}"
          render plain: 'Forbidden', status: :forbidden
        end
      end
    
    # POST endpoint for webhook events
    def instagram_events
      payload = JSON.parse(request.body.read)
      
      # Log the webhook event
      Rails.logger.info "Instagram Webhook: #{payload.inspect}"
      
      # Process the webhook
      process_instagram_webhook(payload)
      
      render json: { success: true }, status: :ok
    rescue => e
      Rails.logger.error "Webhook error: #{e.message}"
      render json: { error: e.message }, status: :ok # Return 200 to prevent retries
    end
    
    private
    
    def process_instagram_webhook(payload)
      payload['entry']&.each do |entry|
        entry['changes']&.each do |change|
          case change['field']
          when 'mentions'
            handle_mention(change['value'])
          when 'tagged_media'
            handle_tagged_media(change['value'])
          when 'comments'
            handle_comment(change['value'])
          end
        end
      end
    end
    
    def handle_tagged_media(instagram_user_id, data)
        # Find the business this belongs to
        business = Business.find_by(instagram_user_id: instagram_user_id)
        return unless business
        
        media_id = data['media_id']
        
        # Fetch full media details from API
        media_data = fetch_media_details(media_id, business.instagram_access_token)
        
        # Create stream post record
        StreamPost.create!(
          business: business,
          instagram_media_id: media_id,
          username: media_data['username'],
          media_url: media_data['media_url'],
          permalink: media_data['permalink'],
          caption: media_data['caption'],
          timestamp: media_data['timestamp'],
          approved: false # Requires moderation
        )
        
        Rails.logger.info "Tagged media saved: #{media_id} by #{media_data['username']}"
      end
    
    
      def fetch_media_details(media_id, access_token)
        response = HTTParty.get(
          "https://graph.instagram.com/#{media_id}",
          query: {
            fields: 'id,username,media_url,media_type,permalink,caption,timestamp',
            access_token: access_token
          }
        )
        response.parsed_response
      rescue => e
        Rails.logger.error "Failed to fetch media #{media_id}: #{e.message}"
        {}
      end
    
  end