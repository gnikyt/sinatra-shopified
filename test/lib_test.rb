require "test_helper"

# Extend the Hash class in Ruby
class Hash
  # Converts hash to query string
  def to_query(encode = false)
    query = self.map{|k, v| "#{k}=#{v}"}.join("&")
    return URI.encode(query) if encode
    query
  end
end

class MyTest < MiniTest::Test
  include Rack::Test::Methods
  include Sinatra::Shopified::Helpers
  
  def setup
    @shop_domain          = "mycoolshop.myshopify.com"
    @existing_shop_domain = "existing_shop.myshopify.com"
  end
  
  def app
    Sinatra::Application
  end

  def test_hello_world
    # Simple test to ensure Sinatra itself is running ok
    get "/"
    assert last_response.ok?
    assert_equal "Hello world!", last_response.body
  end
  
  def test_unauthorized_shop_should_be_redirected_to_auth
    # /admin should redirect to /auth
    get "/admin", shop: @shop_domain
    follow_redirect!
    
    # Grab the session from the request
    assert_equal @shop_domain, last_request.env['rack.session'][:shopify_domain]
    
    # Go ahead and move to next redirect (should be auth page for Shopify)
    follow_redirect!
    
    # Redirect to Shopify should match
    assert_equal "https://mycoolshop.myshopify.com/admin/oauth/authorize?client_id=#{ENV["SHOPIFY_API_KEY"]}&scope=#{CGI.escape(ENV["SHOPIFY_API_SCOPE"])}&redirect_uri=#{CGI.escape("http://example.org/auth")}", last_request.url
  end
  
  def test_shop_not_existing_should_be_created_on_auth
    # Create dummy params and signature
    params    = {code: "a_code", timestamp: Time.now.to_i}
    signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA256.new, ShopifyAPI::Session.secret, params.to_query)
    params.merge!({hmac: signature})
    
    # Stub the token request
    stub_request(:post, /.*\/admin\/oauth\/access_token/).to_return(body: '{"access_token": "a_token"}')
    
    # Go to auth page with our code and signature
    get "/auth", params, {"rack.session" => {:shopify_domain => @shop_domain}}

    # Assert shop was created and we go to redirect setting
    assert Sinatra::Shopified::Models::Shop.find_by(shop: @shop_domain)
    assert last_response.headers["Location"].include? ENV["SHOPIFY_APP_REDIRECT_AFTER_AUTH"]
  end
  
  def test_shops_not_matching_should_redirect_to_reauth
    # Go to admin as existing shop in test db
    get "/admin", {}, {"rack.session" => {:shopify_domain => @existing_shop_domain}}
    assert_equal "We are in admin", last_response.body
    
    # Now, going as different shop
    get "/admin", shop: "nonexisting_shop.myshopify.com"
    follow_redirect!
    
    assert_equal "http://example.org/auth?shop=nonexisting_shop.myshopify.com", last_request.url
  end
  
  def test_shop_session_with
    # Stub the count request
    stub_request(:get, /.*\/admin\/products\/count.json/).to_return(status: 200, body: '{"count": 1}')
    
    # Grab the shop, run a product count
    shop = Sinatra::Shopified::Models::Shop.find_by(shop: @existing_shop_domain)
    shopify_session_with(shop) do
      assert_equal 1, ShopifyAPI::Product.count
    end
  end
  
  def test_esdk_redirect
    assert_equal "<script type='text/javascript'>top.window.location.href = '/admin/products';</script>", esdk_redirect("/admin/products")
  end
end
