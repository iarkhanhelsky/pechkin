module Pechkin
  # Common code for all configuration loaders. To use this code just include
  # module in user class.
  module ConfigurationLoader
    def check_field(object, field, file)
      contains = object.key?(field)

      raise ConfigurationError, "#{file}: '#{field}' is missing" unless contains

      object[field]
    end

    def create_connector(bot)
      case bot.connector
      when 'tg', 'telegram'
        Connector::Telegram.new(bot.token, bot.name)
      when 'slack'
        Connector::Slack.new(bot.token, bot.name)
      when 'slack_dm'
        Connector::SlackDM.new(bot.token, bot.name)
      else
        raise "Unknown connector #{bot.connector} for #{bot.name}"
      end
    end

    def yaml_load(file)
      YAML.safe_load(IO.read(file))
    end
  end
end
