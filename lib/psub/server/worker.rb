require 'concurrent'

module Psub
  module Server
    class Worker

      attr_reader :executor

      def initialize(max_size: 5)
        @executor = Concurrent::ThreadPoolExecutor.new(min_threads: 1, max_threads: max_size, max_queue: 0)
      end

      # Stop processing work: any work that has not already started
      # running will be discarded from the queue
      def halt
        @executor.kill
      end

      def stopping?
        @executor.shuttingdown?
      end

      def async_invoke(receiver, method, *args)
        @executor.post do
          invoke(receiver, method, *args)
        end
      end

      def invoke(receiver, method, *args)
        begin
          receiver.send method, *args
        rescue Exception => e
          logger.error "There was an exception - #{e.class}(#{e.message})"
          logger.error e.backtrace.join("\n")

          receiver.handle_exception if receiver.respond_to?(:handle_exception)
        end
      end

      private

        def logger
          Psub.server.logger
        end
    end
  end
end