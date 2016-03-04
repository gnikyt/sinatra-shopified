begin
  require "bundler/setup"
rescue LoadError
  puts "You must `gem install bundler` and `bundle install` to run rake tasks"
end

Bundler::GemHelper.install_tasks

require "sinatra/activerecord/rake"
require "rake/testtask"

namespace :db do
  task :load_config do
    require "./test/test_app"
  end
end

Rake::TestTask.new(:test) do |t|
  t.libs << "lib"
  t.libs << "test"
  t.pattern = "test/*_test.rb"
  t.verbose = false
end

task default: :test