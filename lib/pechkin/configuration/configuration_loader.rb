module Pechkin
  # Common code for all configuration loaders. To use this code just include
  # module in user class.
  module ConfigurationLoader
    def fetch_field(object, field, file)
      contains = object.key?(field)

      raise ConfigurationError, "#{file}: '#{field}' is missing" unless contains

      object[field]
    end

    # Fetch token from environment variable defined in configuration file.
    def fetch_value_from_env(object, token_field, file)
      raise ConfigurationError, "#{file}: '#{token_field}' is missing in configuration" unless object.key?(token_field)

      env_var = object[token_field]
      token = ENV.fetch(env_var, nil)

      if token.to_s.strip.empty?
        raise ConfigurationError,
              "#{file}: environment variable '#{env_var}' (from '#{token_field}') is not set"
      end

      token
    end

    def create_connector(bot)
      case bot.connector
      when 'tg', 'telegram'
        Connector::Telegram.new(bot.token, bot.name)
      when 'slack'
        Connector::Slack.new(bot.token, bot.name)
      else
        raise "Unknown connector #{bot.connector} for #{bot.name}"
      end
    end

    def yaml_load(file)
      YAML.safe_load(IO.read(file))
    end
  end
end
