module Sinatra
  module Shopified
    # Helper module for the Gem
    module Helpers
      # Instance variable for storing shop object
      attr_reader :shop
      
      # Grab the current shop from the database
      # @return [Object, nil] the shop object
      def current_shop
        return nil if session[:shopify_domain] == nil
        @shop ||= Models::Shop.find_by(shop: session[:shopify_domain])
      end

      # Activates Shopify session
      def shopify_session_activate
        api_session = ShopifyAPI::Session.new current_shop.shop, current_shop.token
        ShopifyAPI::Base.activate_session api_session
      end

      # Clears all sessions
      def shopify_session_clear
        session[:shopify_domain] = nil
        ShopifyAPI::Base.clear_session
      end
      
      # Allowing using a temporary session for a shop
      # @param [Object] shop the shop's object
      # @example
      #   shop = Shopify::Models::Shop.find(shop: 'coolshop.myshopify.com')
      #   shopify_session_with shop do
      #     ShopifyAPI::Product.find 42
      #   end
      def shopify_session_with(shop, &block)
        ShopifyAPI::Session.temp shop.shop, shop.token, &block
      end
        
      # Clears session and reidrects to auth
      def authorize_shop_fallback
        shopify_session_clear
        redirect to("/auth?shop=#{params[:shop]}")
      end
      
      # Check if shop is authorized to view a page.
      # If they are, we activate the Shopify session.
      # If not, they are redirected to auth.
      def authorize_shop
        if current_shop == nil
          # No session yet, or shop domains are different
          authorize_shop_fallback.call
        end
        
        if params[:shop] and session[:shopify_domain] != params[:shop]
          # Shops are different
          authorize_shop_fallback.call
        end
        
        # Activate the session
        shopify_session_activate
      end
  
      # Forces a redirect to get out of the iFrame for embedded apps
      # @param [String] redirect_url the URL to redirect to
      # @return [String] the Javascript for redirecting
      # @example
      #  esdk_redirect '/admin/products'
      def esdk_redirect(redirect_url)
        "<script type='text/javascript'>top.window.location.href = '#{redirect_url}';</script>"
      end
    end
  end
end
