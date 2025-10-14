=begin #require 'omniauth-oauth2'

puts "Loading Instagram OmniAuth strategy..."

# module OmniAuth
#   module Strategies
#     class Instagram < ::OmniAuth::Strategies::OAuth2
#       option :name, 'instagram'

      option :client_options, {
        site: 'https://api.instagram.com',
        authorize_url: 'https://api.instagram.com/oauth/authorize',
        token_url: 'https://api.instagram.com/oauth/access_token'
      }

      option :verify_token, nil

      option :scope, 'user_profile,user_media'

      uid { raw_info['id'] }

      info do
        {
          nickname: raw_info['username'],
          name: raw_info['username'],
          image: nil, # Instagram Basic Display doesn't provide profile picture
          bio: nil,
          website: nil
        }
      end

      extra do
        {
          raw_info: raw_info
        }
      end

      def raw_info
        @raw_info ||= access_token.get('https://graph.instagram.com/me?fields=id,username,account_type,media_count').parsed
      end

      def callback_url
        full_host + script_name + callback_path
      end
    end
  end
end