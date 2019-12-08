require 'yaml'

module Pechkin
  Bot = Struct.new(:token, :connector, :name, keyword_init: true)
  Channel = Struct.new(:chat_ids, :bot, :messages, keyword_init: true)

  # Pechkin reads its configuration from provided directory structure. Basic
  # layout expected to be as follows:
  #   .
  #   | - bots/                  <= Bots configuration
  #   |   | - marvin.yml         <= Each bot described by yaml file
  #   |   | - bender.yml
  #   |
  #   | - channels/              <= Channels description
  #   |   | - slack-repository-feed
  #   |       | - commit-hg.yml
  #   |       | - commit-svn.yml
  #   |
  #   | - views/                 <= Template storage
  #       | - commit-hg.erb
  #       | - commit-svn.erb
  #
  # Bots
  #  Bots described in YAML files in `bots` directory. Bot described by
  #  following fields:
  #    - token - API token used to authorize when doing requests to messenger
  #              API
  #    - connector - Connector name to instantiate. For exapmle: 'telegram' or
  #      'slack'
  # Channels
  #  Channel is a description of message group. It used to describe group of
  #  messages that sould be send to sepceific channel or user. Each
  #  channel configuration is stored in its own folder. This folder name
  #  is channel internal id. Channel is described by `_channel.yml` file,
  #  Channel has following fields to configure:
  #    - chat_ids - list of ids to send all containing messages. It may be
  #      single item or list of ids.
  #    - bot - bot istance to use when messages are handled.
  #  Other `*.yml` files in channel folder are message descriptions. Message
  #  description has following fields to configure:
  #    - template - path to template relative to views/ folder. If no template
  #      specified then noop template will be used. No-op template returns empty
  #      string for each render request.
  #    - variables - predefined variables to use in template rendering. This is
  #      especialy useful when one wants to use same template in different
  #      channels. For exapmle when you need to render repository commit and
  #      want to substitute correct repository link
  #    - filters - list of rules which allows to deny some messages based on
  #      their content. For example we do not want to post commit messages from
  #      branches other than `master`.
  #
  #  And other connector speceific fields. For example:
  #    - telegram_parse_mode
  #    - slack_attachments
  #
  # Views
  #   'views' folder contains erb templates to render when data arives.
  class Configuration
    attr_accessor :bots, :channels, :views, :working_dir

    def initialize(working_dir)
      @working_dir = working_dir

      load_configuration
    end

    def list
      puts "Working dir: #{working_dir}\nBots:"

      bots.each do |name, bot|
        puts "  #{name}(#{bot.connector}): #{bot.token}"
      end

      puts "\nChannels:"
      channels.each do |channel_name, channel|
        puts "  - name #{channel_name}"
        puts "    bot: #{channel.bot.name}"
        puts '    messages: '
        channel.messages.each do |message_name, _message|
          puts "     - /#{channel_name}/#{message_name}"
        end
        puts
      end
    end

    private

    def load_configuration
      load_bots_configuration
      load_views_configuration
      load_channels_configuration
    end

    def load_bots_configuration
      bots_dir = File.join(working_dir, 'bots')

      unless File.directory?(bots_dir)
        raise ConfigurationError, "'#{bots_dir}' is not a directory"
      end

      @bots = {}

      Dir["#{bots_dir}/*.yml"].each do |bot_file|
        name = File.basename(bot_file, '.yml')
        bot = load_bot_configuration(bot_file)
        bot.name = name
        @bots[name] = bot
      end
    end

    def load_bot_configuration(bot_file)
      bot_configuration = YAML.safe_load(IO.read(bot_file))

      token = check_field(bot_configuration, 'token', bot_file)
      connector = check_field(bot_configuration, 'connector', bot_file)

      Bot.new(token: token, connector: connector)
    end

    def check_field(object, field, file)
      contains = object.key?(field)

      raise ConfigurationError, "#{file}: '#{field}' is missing" unless contains

      object[field]
    end

    def load_views_configuration
      views_dir = File.join(working_dir, 'views')

      unless File.directory?(views_dir)
        raise ConfigurationError, "'#{views_dir}' is not a directory"
      end

      @views = {}

      Dir["#{views_dir}/**/*"].each do |f|
        relative_path = t["#{views_dir}/".length..-1]
        @views[relative_path] = MessageTemplate.new(IO.read(f))
      end
    end

    def load_channels_configuration
      channels_dir = File.join(working_dir, 'channels')

      unless File.directory?(channels_dir)
        raise ConfigurationError, "'#{channels_dir}' is not a directory"
      end

      @channels = {}

      Dir["#{channels_dir}/*"].each do |channel_dir|
        next unless File.directory?(channel_dir)

        name = File.basename(channel_dir)
        @channels[name] = load_channel_configuration(channel_dir)
      end
    end

    def load_channel_configuration(channel_dir)
      channel_file = File.join(channel_dir, '_channel.yml')

      msg = "_channel.yml not found at #{channel_dir}"
      raise ConfigurationError, msg unless File.exist?(channel_file)

      channel_config = YAML.safe_load(IO.read(channel_file))

      bot = check_field(channel_config, 'bot', channel_file)
      chat_ids = check_field(channel_config, 'chat_ids', channel_file)
      chat_ids = [chat_ids] unless chat_ids.is_a?(Array)
      messages = load_messages_configuration(channel_dir)

      msg = "#{channel_file}: bot '#{bot}' not found"
      raise ConfigurationError, msg unless bots.key?(bot)

      Channel.new(bot: bots[bot], chat_ids: chat_ids, messages: messages)
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
