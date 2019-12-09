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

      unless File.directory?(bots_dir)
        raise ConfigurationError, "'#{bots_dir}' is not a directory"
      end

      Dir["#{bots_dir}/*.yml"].each do |bot_file|
        name = File.basename(bot_file, '.yml')
        bot = load_bot_configuration(bot_file)
        bot.name = name
        bots[name] = bot
      end
    end

    def load_bot_configuration(bot_file)
      bot_configuration = yaml_load(bot_file)

      token = check_field(bot_configuration, 'token', bot_file)
      connector = check_field(bot_configuration, 'connector', bot_file)

      Bot.new(token: token, connector: connector)
    end
  end
end
