require 'grape'
require 'json'

module Pechkin # :nodoc:
  # Generates all routes based on configuration
  module Generator
    def configure(config)
      base_path = config['base_path']
      resource base_path do
        create_chanels(config['chanels'], config['bots'])
      end

      self
    end

    def create_chanels(chanels, bots)
      chanels.each do |chanel_name, chanel_desc|
        bot = bots[chanel_desc['bot']]
        connector = create_connector(bot)

        chat_ids = chanel_desc['chat_ids']
        channel = Chanel.new(connector, chat_ids)
        channel.logger = logger
        resource chanel_name do
          create_chanel(channel, chanel_desc)
        end
      end
    end

    def create_connector(bot)
      case bot['connector']
      when 'tg', 'telegram'
        TelegramConnector.new(bot['token'])
      when 'slack'
        SlackConnector.new(bot['token'])
      end
    end

    def create_chanel(channel, chanel_desc)
      chanel_desc['messages'].each do |message_name, message_desc|
        generate_endpoint(channel, message_name, message_desc)
      end
    end

    # rubocop:disable Metrics/AbcSize
    def generate_endpoint(channel, message_name, message_desc)
      params do
        # TODO: Can't extract this code to method because this block is
        # evaluated in separate scope
        (message_desc['filters'] || []).each do |field, filter|
          filter.match(%r{^/(.*)/$}) do |m|
            requires field.to_sym, type: String, regexp: Regexp.new(m[1])
          end
        end
      end
      post message_name do
        template = message_desc['template']
        opts = message_desc['options'] || {}
        # Some services will send json, but without correct content-type, then
        # params will be parsed weirdely. So we try parse request body as json
        params = ensure_json(request.body.read, params)
        logger.info "Received message #{params.to_json}"
        logger.info "Will render template file #{template}"
        # If message description contains any variables will merge them with
        # received parameters.
        params = (message_desc['variables'] || {}).merge(params)

        channel.send_message(template, params, opts)
      end
      # rubocop:enable Metrics/AbcSize
    end
  end

  module Helpers # :nodoc:
    def ensure_json(body, params)
      if headers['Content-Type'] == 'application/json'
        params # Expected content type. Do nothing, just return basic params
      else
        JSON.parse(body) # Try parse body as json. If it possible will return as
        # params
      end
    rescue JSON::JSONError => _e
      params
    end

    def logger
      PechkinAPI.logger
    end
  end

  # Base class for all pechkin apps
  class PechkinAPI < Grape::API
    extend Generator
    helpers Helpers
  end

  class << self
    def create(config)
      Class.new(PechkinAPI).configure(config)
    end
  end
end
