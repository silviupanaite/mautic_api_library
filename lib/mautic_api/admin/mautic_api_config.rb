require "oauth"
require "redis"

if defined?(ActiveAdmin)
  ActiveAdmin.register_page "Mautic Api Config" do
    
    content do
      render partial: "mautic_api_form"
    end
    
    controller do
      
      def index
        @config = {
          url: redis.get('mautic_api:url'),
          key: redis.get('mautic_api:app_key'),
          secret: redis.get('mautic_api:app_secret'),
          token: redis.get('mautic_api:access_token')
        }
      end
      
      private
      
      def redis
        @redis ||= Redis.new
      end
      
      def consumer
        url     = redis.get('mautic_api:url')
        key     = redis.get('mautic_api:app_key')
        secret  = redis.get('mautic_api:app_secret')
        
        return OAuth::Consumer.new(key, secret, {
          :site => url,
          :request_token_path => '/oauth/v1/request_token',
          :authorize_path     => '/oauth/v1/authorize',
          :access_token_path  => '/oauth/v1/access_token'
        })
      end
      
      def callback_url
        public_send("#{ActiveAdmin.application.default_namespace}_mautic_api_config_oauth_callback_url", locale: nil)
      end
    end
    
    page_action :auth, method: :post do
      begin
        redis.set('mautic_api:url', params[:mautic_api][:url])
        redis.set('mautic_api:app_key', params[:mautic_api][:key])
        redis.set('mautic_api:app_secret', params[:mautic_api][:secret])
        redis.set('mautic_api:access_token', "") # Reset token
      
        redirect_to public_send("#{ActiveAdmin.application.default_namespace}_mautic_api_config_path"), notice: "key was set"
      rescue OAuth::Unauthorized
        redirect_to public_send("#{ActiveAdmin.application.default_namespace}_mautic_api_config_path"), notice: "Não autorizado."
      end
    end
    
    page_action :oauth, method: :post do
      begin
        @request_token = consumer.get_request_token(:oauth_callback => callback_url)

        redis.set('mautic_api:oauth_token', @request_token.token)
        redis.set('mautic_api:oauth_token_secret', @request_token.secret)
      
        redirect_to @request_token.authorize_url(:oauth_callback => callback_url)
      rescue OAuth::Unauthorized
        redirect_to public_send("#{ActiveAdmin.application.default_namespace}_mautic_api_config_path"), notice: "Não autorizado."
      end
    end
    
    page_action :oauth_callback, method: :get do
      
      begin
        oauth_token = redis.get('mautic_api:oauth_token')
        oauth_token_secret = redis.get('mautic_api:oauth_token_secret')
      
        hash = { 
          oauth_token: oauth_token, 
          oauth_token_secret: oauth_token_secret
        }
      
        request_token  = OAuth::RequestToken.from_hash(consumer, hash)
        access_token = request_token.get_access_token({
          oauth_verifier: params[:oauth_verifier],
          oauth_callback: callback_url
        })
      
        redis.set('mautic_api:access_token', access_token.token)
      
        redirect_to public_send("#{ActiveAdmin.application.default_namespace}_mautic_api_config_path"), notice: "token was set"
      rescue OAuth::Unauthorized
        redirect_to public_send("#{ActiveAdmin.application.default_namespace}_mautic_api_config_path"), notice: "Não autorizado."
      end
    end

  end
end