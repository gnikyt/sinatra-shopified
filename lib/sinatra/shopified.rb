require "shopify_api"
require "sinatra/base"
require "sinatra/activerecord"
require "sinatra/shopified/version"
require "sinatra/shopified/helpers"
require "sinatra/shopified/models"

# Sinatra module namespace
module Sinatra
  # This Gem's module namespace
  module Shopified
    # Register the module with Sinatra
    # @param [Object] app the Sinatra App
    def self.registered(app)
      # Register the helpers for this Gem
      app.helpers Shopified::Helpers
      
      # Disable iFrame protection (for ESDK)
      app.set :protection, except: :frame_options
      
      # Setup Shopify session with the app's credentials
      ShopifyAPI::Session.setup(api_key: ENV["SHOPIFY_API_KEY"], secret: ENV["SHOPIFY_API_SECRET"])
      
      # Auth controller which handles creating shop sessions,
      # hanlding app permissions, and more
      app.get "/auth" do
        api_session = ShopifyAPI::Session.new params[:shop]

        # Setup our session
        session[:shopify_domain] = params[:shop]

        if params.key? "code"
          # Create the shop if its new, update the token, and activate the session
          Models::Shop.create(shop: session[:shopify_domain]) unless current_shop
          current_shop.update_attribute :token, api_session.request_token(params)
          shopify_session_activate
          
          redirect to(ENV["SHOPIFY_APP_REDIRECT_AFTER_AUTH"])
        else
          # No code, lets ask for app permissions
          redirect api_session.create_permission_url(ENV["SHOPIFY_API_SCOPE"].split(","), to("/auth", true))
        end
      end
    end
  end
  
  register Shopified
end
