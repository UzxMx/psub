module Psub
  module SubscriptionAdapter
    class SubscriberMap

      attr_reader :logger, :server

      def initialize(server)
        @server = server
        @logger = @server.logger
        @subscribers = Hash.new { |h,k| h[k] = [] }
        @sync = Mutex.new
      end

      def add_subscriber(channel, subscriber, on_success)
        @sync.synchronize do
          new_channel = !@subscribers.key?(channel)

          logger.debug "subscriber to be added: #{subscriber}"

          @subscribers[channel] << subscriber

          if new_channel
            add_channel channel, on_success
          elsif on_success
            on_success.call
          end
        end
      end

      def remove_subscriber(channel, subscriber)
        @sync.synchronize do
          logger.debug "subscriber to be removed: #{subscriber}"
          logger.debug "#{channel} count: #{@subscribers[channel].size}"
          @subscribers[channel].delete(subscriber)
          logger.debug "#{channel} count: #{@subscribers[channel].size}"

          if @subscribers[channel].empty?
            @subscribers.delete channel
            remove_channel channel
          end
        end
      end

      def broadcast(channel, message)
        list = @sync.synchronize { @subscribers[channel].dup }
        list.each do |subscriber|
          invoke_callback(subscriber, message)
        end
      end

      def add_channel(channel, on_success)
        on_success.call if on_success
      end

      def remove_channel(channel)
      end

      def invoke_callback(callback, message)
        callback.call message
      end
    end
  end
end
