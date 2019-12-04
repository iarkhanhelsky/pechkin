module Pechkin
  # Processes feeded data chunks and sends them via connectors to needed IM
  # services. Can skip some requests acording to filters.
  class Handler
    attr_reader :connectors, :channels

    def initialize(connectors, channels)
      @connectors = connectors
      @channels = channels
    end

    # Handles message request. Each request has three parameters: channel id,
    # message id, and data object. By channel id we determine where to send
    # data, by message id we determine how to transform this data to real
    # message.
    # @param channel_id [String] channel name from configuration. This name is
    #  obtained from directory structure we have in configuration directory.
    # @param msg_id [String] message name from configuration. This name is
    #  references yml file with message description
    # @param data [Object] data object to render via template. This is usualy
    #  deserialized json.
    # @see Configuration
    def handle(channel_id, msg_id, data)
      channel_config = fetch_channel(channel_id)
      # Find message and try substitute values to message parameters.
      message_config = substitute(data, fetch_message(channel_config, msg_id))

      data = (message_config['parameters'] || {}).merge(data)
      template = message_config['template']

      text = ''
      text = template.render(data) unless template.nil?

      connector = connectors[channel_config.bot]

      channel_config.chat_ids.map do |chat_id|
        connector.send_message(chat_id, text, message_config)
      end
    end

    private

    # Find channel by it's id or trow ChannelNotFoundError
    def fetch_channel(channel_id)
      raise ChannelNotFoundError, channel_id unless channels.key?(channel_id)

      channels[channel_id]
    end

    # Find message config by it's id or throw MessageNotFoundError
    def fetch_message(channel_config, msg_id)
      message_list = channel_config.messages
      raise MessageNotFoundError, msg_id unless message_list.key?(msg_id)

      message_list[msg_id]
    end

    def create_connector(bot)
      case bot.connector
      when 'tg', 'telegram'
        TelegramConnector.new(bot.token)
      when 'slack'
        SlackConnector.new(bot.token)
      else
        raise 'Unknown connector ' + bot.connector + ' for ' + bot.name
      end
    end

    def substitute(data, message_desc)
      substitute_recursive(Substitute.new(data), message_desc)
    end

    def substitute_recursive(substitutions, object)
      case object
      when String
        substitutions.process(object)
      when Array
        object.map { |o| substitute_recursive(substitutions, o) }
      when Hash
        r = {}
        object.each { |k, v| r[k] = substitute_recursive(substitutions, v) }
        r
      else
        object
      end
    end
  end
end
