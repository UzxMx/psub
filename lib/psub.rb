require 'active_support'
require 'active_support/rails'
require 'psub/engine'

module Psub
  extend ActiveSupport::Autoload

  module_function def server
    @server ||= Psub::Server::Base.new
  end

  autoload :Server
  autoload :SubscriptionAdapter
end