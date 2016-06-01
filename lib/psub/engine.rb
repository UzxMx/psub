require 'rails'
require 'psub'
require "active_support/core_ext/hash/indifferent_access"

module Psub
  class Engine < Rails::Engine
    config.psub = ActiveSupport::OrderedOptions.new

    initializer "psub.logger" do
      ActiveSupport.on_load(:psub) do
        self.logger ||= ::Rails.logger
      end
    end

    initializer "psub.set_configs" do |app|
      options = app.config.psub

      app.paths.add "config/psub", with: "config/psub.yml"

      ActiveSupport.on_load(:psub) do
        if (config_path = Pathname.new(app.config.paths["config/psub"].first)).exist?
          self.psub = Rails.application.config_for(config_path).with_indifferent_access
        end

        options.each { |k,v| send("#{k}=", v) }
      end
    end

    initializer "psub.after_initialize" do
      config.after_initialize do |app|
        Psub.server
      end
    end
  end
end