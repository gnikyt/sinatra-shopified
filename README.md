# Sinatra::Shopify

This is a work-in-progress extension for Sinatra which provides some basic helpers and routes to create a Sinatra-powered Shopify application.

## Installation

### Gem Installation

Add this line to your application's Gemfile:

``` ruby
gem "sinatra-shopified", git: "git@github.com:tyler-king/guts.git"
```

Then, execute `bundle` to install then Gem.

### Sinatra Installation

This assumes you have ActiveRecord up and running and you are using a modular-style Sinatra application.

In your Sinatra application, load the Gem:

``` ruby
require "sinatra/shopified"
```

Now, register it. As an example:

``` ruby
require "sinatra/base"
require "sinatra/shopified"

class MyCoolApp < Sinatra::Base
  # ...
  register Sinatra::Shopified
  # ...
end
```

#### ActiveRecord / Database Installation

This Gem provides a model of Shop which contains a couple of basic columns (shop domain and token).

Here is the migration for ActiveRecord if you wish to use it:

``` ruby
class Shop < ActiveRecord::Migration
  def up
    create_table :shops do |t|
      t.string :shop
      t.string :token, null: true
    end
  end

  def down
    drop_table :shops
  end
end
```

Alternatively, you can just load in the SQL:

``` 
CREATE TABLE `shops` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `shop` text NOT NULL,
  `token` text NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
```

You can extends the built-in Shop model if need-be by doing the following in your own app:

``` ruby
module YourApp
  module Models
    class Shop < Sinatra::Shopified::Models::Shop
      # Your extra code here
    end
  end
end
```

## Configuration

This Gem uses environment variables (`ENV`) for the Shopify config. [dotenv](https://rubygems.org/gems/dotenv) Gem is a great way to manage environment variables.

Here is a guide for all required environment variables you can set:

``` bash
SHOPIFY_API_KEY='YOUR APP API KEY'
SHOPIFY_API_SECRET='YOUR APP API PASSWORD'
SHOPIFY_API_SCOPE='YOUR APP SCOPES' # Comma-separated example: "read_themes,write_themes"
SHOPIFY_APP_REDIRECT_AFTER_AUTH='/' # Where to redirect after authentication is completed (example: /admin)
```

## Code Documentation

YARD is used for documentation. Simply run `bundle exec yardoc` to generate the documentation of the code and open `doc/index.html` in your browser.

## Usage

There are a couple noteable helper methods.

#### current_shop

This will return the current authenticated shop from your database

``` ruby
You are <%= current_shop.shop %>
```

#### authorize_shop

This is a helper method you can run which will ensure the shop can access the page. If it can, it will activate the shop's session with Shopify. If it can not, it will redirect the shop to the auth page.

You can place this anywhere you need to use the Shopify API, such as at the top of a route.

``` ruby
class PendingController < Sinatra::Base
  # ...
  register Sinatra::Shopified
  # ...
  get "/admin" do
    authorize_shop

    product = ShopifyAPI::Product.find 1787887
    # ...
  end
  # ...
end
```

or, use it in a before filter:

``` ruby
# ...
before do
  authorize_shop if request.path.include? "/admin"
end
# ...
```

#### esdk_redirect

If you are using ESDK and need to escape the iFrame to do a redirect (maybe go to /admin/products, an off-site link) this method can help.

``` ruby
  return esdk_redirect "https://#{current_shop.shop}/admin/products"
```

#### shopify_session_with

Useful for if you wish to temporarily use the Shopify API with another shop.

``` ruby
shop = Shopified::Models::Shop.find_by(shop: "coolshop.myshopify.com")
shopify_session_with shop do
  ShopifyAPI::Product.find 42
end
```

## Routes

This module adds one route.

#### /auth

With the use of `authorize_shop` or simply visting `/auth`. When creating your app in the Partner section, set this as the `redirect_uri`.

## Todo

+ Write unit tests

## License

The Gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

