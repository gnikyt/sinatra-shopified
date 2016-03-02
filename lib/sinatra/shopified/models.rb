module Sinatra
  module Shopified
    # Models for the Gem
    module Models
      # Base Shop model
      class Shop < ActiveRecord::Base
        validates_uniqueness_of :shop
        validates_presence_of :shop
        after_initialize :init
  
        private
        # Initializer for a Shop
        def init
          self[:token] ||= nil
        end
      end
    end
  end
end