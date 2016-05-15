# Be sure to restart your server when you modify this file.
APP_CONFIG = YAML.load_file("#{Rails.root}/config/config.yml")["general"]
ENV_CONFIG = YAML.load_file("#{Rails.root}/config/config.yml")[ENV['RAILS_ENV']]
APP_CONFIG.merge!(ENV_CONFIG)