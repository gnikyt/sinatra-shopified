require "sinatra"
require "sinatra/shopified"
require "sinatra/activerecord"

configure do
  enable :sessions
  set :database, {adapter: "sqlite3", database: File.expand_path("../db/test.sqlite3", File.dirname(__FILE__))}
end

register Sinatra::Shopified

get "/" do
  "Hello world!"
end

get "/admin" do
  authorize_shop
  "We are in admin"
end