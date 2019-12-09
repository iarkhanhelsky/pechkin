module Pechkin
  # Configuration loader for bot descriptions
  class ConfigurationLoaderChannels
    include ConfigurationLoader

    attr_reader :bots

    def initialize(bots, views)
      @bots = bots
      @views = views
    end

    def load_from_directory(working_directory)
      channels = {}
      load_channels_configuration(working_directory, channels)

      channels
    end

    private

    def load_channels_configuration(working_dir, channels)
      channels_dir = File.join(working_dir, 'channels')

      unless File.directory?(channels_dir)
        raise ConfigurationError, "'#{channels_dir}' is not a directory"
      end

      Dir["#{channels_dir}/*"].each do |channel_dir|
        next unless File.directory?(channel_dir)

        name = File.basename(channel_dir)
        channels[name] = load_channel_configuration(channel_dir)
      end
    end

    def load_channel_configuration(channel_dir)
      channel_file = File.join(channel_dir, '_channel.yml')

      msg = "_channel.yml not found at #{channel_dir}"
      raise ConfigurationError, msg unless File.exist?(channel_file)

      channel_config = yaml_load(channel_file)

      bot = check_field(channel_config, 'bot', channel_file)
      chat_ids = check_field(channel_config, 'chat_ids', channel_file)
      chat_ids = [chat_ids] unless chat_ids.is_a?(Array)
      messages = load_messages_configuration(channel_dir)

      msg = "#{channel_file}: bot '#{bot}' not found"
      raise ConfigurationError, msg unless bots.key?(bot)

      connector = create_connector(bots[bot])
      Channel.new(connector: connector, chat_ids: chat_ids, messages: messages)
    end

    def load_messages_configuration(channel_dir)
      messages = {}

      Dir["#{channel_dir}/*.yml"].each do |file|
        next if File.basename(file) == '_channel.yml'

        message_config = YAML.safe_load(IO.read(file))
        name = File.basename(file, '.yml')

        if message_config.key?('template')
          message_config['template'] = get_template(message_config['template'])
        end

        messages[name] = message_config
      end

      messages
    end

    def get_template(path)
      msg = "Can't find template: #{path}"
      raise ConfigurationError, msg unless @views.key?(path)

      @views[path]
    end
  end
end
