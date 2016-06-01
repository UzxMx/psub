module Psub
  module Server
    extend ActiveSupport::Autoload

    eager_autoload do
      autoload :Base
      autoload :Broadcasting
      autoload :Configuration
      autoload :Worker
      autoload :FayeEventLoop
      autoload :StreamEventLoop
    end
  end
end