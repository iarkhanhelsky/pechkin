module Pechkin
  # Configuration loader for bot descriptions
  class ConfigurationLoaderBots
    include ConfigurationLoader

    def load_from_directory(working_directory)
      bots = {}
      load_bots_configuration(working_directory, bots)

      bots
    end

    private

    def load_bots_configuration(working_dir, bots)
      bots_dir = File.join(working_dir, 'bots')

      raise ConfigurationError, "'#{bots_dir}' is not a directory" unless File.directory?(bots_dir)

      Dir["#{bots_dir}/*.yml"].each do |bot_file|
        name = File.basename(bot_file, '.yml')
        bot = load_bot_configuration(bot_file)
        bot.name = name
        bots[name] = bot
      end
    end

    def load_bot_configuration(bot_file)
      bot_configuration = yaml_load(bot_file)

      token = fetch_value_from_env(bot_configuration, 'token_env', bot_file)
      connector = fetch_field(bot_configuration, 'connector', bot_file)

      Bot.new(token: token, connector: connector)
    end
  end
end
