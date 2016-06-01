require 'monitor'

module Psub
  module Server
    class Base
      include Psub::Server::Broadcasting
      
      cattr_accessor(:config, instance_accessor: true) { Psub::Server::Configuration.new }

      def self.logger; config.logger; end
      delegate :logger, to: :config

      attr_reader :mutex

      def initialize
        @mutex = Monitor.new
        @event_loop = @worker_pool = @pubsub = nil
      end

      def subscribe(channel, message_callback)
        handler = worker_pool_handler(message_callback)

        event_loop.post do
          pubsub.subscribe(channel, handler,
            lambda do
              logger.info "subscribe #{channel} succeed"
            end
          )
        end

        puts handler

        handler
      end

      def unsubscribe(channel, wrapped_callback)
        puts 'wrapped_callback'
        puts wrapped_callback
        event_loop.post do
          pubsub.unsubscribe(channel, wrapped_callback)
        end
      end

      def pubsub
        @pubsub || @mutex.synchronize { @pubsub ||= config.pubsub_adapter.new(self) }
      end

      # The worker pool is where we run connection callbacks and channel actions. We do as little as possible on the server's main thread.
      # The worker pool is an executor service that's backed by a pool of threads working from a task queue. The thread pool size maxes out
      # at 4 worker threads by default. Tune the size yourself with config.action_cable.worker_pool_size.
      #
      # Using Active Record, Redis, etc within your channel actions means you'll get a separate connection from each thread in the worker pool.
      # Plan your deployment accordingly: 5 servers each running 5 Puma workers each running an 8-thread worker pool means at least 200 database
      # connections.
      #
      # Also, ensure that your database connection pool size is as least as large as your worker pool size. Otherwise, workers may oversubscribe
      # the db connection pool and block while they wait for other workers to release their connections. Use a smaller worker pool or a larger
      # db connection pool instead.
      def worker_pool
        @worker_pool || @mutex.synchronize { @worker_pool ||= Psub::Server::Worker.new(max_size: config.worker_pool_size) }
      end

      def event_loop
        @event_loop || @mutex.synchronize { @event_loop ||= config.event_loop_class.new }
      end

      private

        def worker_pool_handler(message_callback)
          handler = message_handler(message_callback)

          -> message do
            begin
              worker_pool.async_invoke handler, :call, message              
            rescue Exception => e
              puts e
            end
          end
        end

        def message_handler(message_callback, coder: ActiveSupport::JSON)
          -> message do
            message_callback.send :call, coder.decode(message)
          end
        end

    end

    ActiveSupport.run_load_hooks(:psub, Base.config)
  end
end