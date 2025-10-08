class WebhooksController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [:instagram]
    
    # GET endpoint for webhook verification
    def instagram
        # Try this instead
        verify_token = Rails.application.credentials.facebook[:webhook_verify_token]
        
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
    
    def handle_tagged_media(data)
      # When someone tags your business
      media_id = data['media_id']
      # Trigger verification check or notification
    end
    
    def handle_mention(data)
      # When someone @mentions your business
    end
    
    def handle_comment(data)
      # When someone comments
    end
  end