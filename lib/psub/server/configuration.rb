module Psub
  module Server
    class Configuration
      attr_accessor :logger
      attr_accessor :psub, :use_faye
      attr_accessor :worker_pool_size

      def initialize
        @worker_pool_size = 4
      end

      # Returns constant of subscription adapter specified in config/psub.yml.
      # If the adapter cannot be found, this will default to the Redis adapter.
      # Also makes sure proper dependencies are required.
      def pubsub_adapter
        adapter = psub.fetch('adapter') { 'redis' }
        path_to_adapter = "psub/subscription_adapter/#{adapter}"
        begin
          require path_to_adapter
        rescue Gem::LoadError => e
          raise Gem::LoadError, "Specified '#{adapter}' for Psub pubsub adapter, but the gem is not loaded. Add `gem '#{e.name}'` to your Gemfile (and ensure its version is at the minimum required by Psub)."
        rescue LoadError => e
          raise LoadError, "Could not load '#{path_to_adapter}'. Make sure that the adapter in config/psub.yml is valid. If you use an adapter other than 'postgresql' or 'redis' add the necessary adapter gem to the Gemfile.", e.backtrace
        end

        adapter = adapter.camelize
        "Psub::SubscriptionAdapter::#{adapter}".constantize
      end

      def event_loop_class
        if use_faye
          Psub::Server::FayeEventLoop
        else
          Psub::Server::StreamEventLoop
        end
      end
    end
  end
end