require_relative "boot"
require "rails/all"
Bundler.require(*Rails.groups)

module App
  class Application < Rails::Application
    config.load_defaults 8.1
    config.autoload_lib(ignore: %w[assets tasks])
    config.eager_load_paths << Rails.root.join("app/services")
    config.time_zone = "Tokyo"
    config.active_record.default_timezone = :local
    config.i18n.default_locale = :ja
    config.middleware.delete Rack::Runtime
    config.action_view.field_error_proc = proc { |html_tag, _instance| html_tag }
    config.session_store :cookie_store,
                         key: "_app",
                         domain: :all,
                         tld_length: 2,
                         same_site: :lax,
                         secure: Rails.env.production?,
                         httponly: true
  end
end
