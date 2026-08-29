# frozen_string_literal: true

module StimulusTableFilter
  class Engine < ::Rails::Engine
    initializer 'stimulus_table_filter.helpers' do
      ActiveSupport.on_load(:action_view) { include StimulusTableFilter::ViewHelper }
    end

    initializer 'stimulus_table_filter.assets' do |app|
      if app.config.respond_to?(:assets)
        app.config.assets.paths << root.join('app/assets/javascripts')
        app.config.assets.paths << root.join('app/assets/stylesheets')
      end
    end

    initializer 'stimulus_table_filter.importmap', before: 'importmap' do |app|
      if app.config.respond_to?(:importmap)
        app.config.importmap.paths << root.join('config/importmap.rb')
        app.config.importmap.cache_sweepers << root.join('app/assets/javascripts')
      end
    end
  end
end
