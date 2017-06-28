# Our variables for testing
ENV['RACK_ENV'] = 'test'
ENV['SHOPIFY_API_KEY'] = 'KEY'
ENV['SHOPIFY_API_SECRET'] = 'PASSWORD'
ENV['SHOPIFY_API_SCOPE'] = 'read_products,write_products'
ENV['SHOPIFY_APP_REDIRECT_AFTER_AUTH'] = '/admin'

# Start SimpleCov
require 'simplecov'
unless ENV['NO_COVERAGE']
  SimpleCov.start do
    add_filter '/test/'
  end
end

# Dependancies
require 'test_app'
require 'minitest/autorun'
require 'rack/test'
require 'webmock/minitest'
require 'sinatra/activerecord'
require 'uri'
