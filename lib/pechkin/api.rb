require 'grape'
require_relative 'telegram'
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
        bot_token = bots[chanel_desc['bot']]
        chat_ids = chanel_desc['chat_ids']
        bot = Telegram::Chanel.new(bot_token, chat_ids)
        resource chanel_name do
          create_chanel(bot, chanel_desc)
        end
      end
    end

    def create_chanel(bot, chanel_desc)
      chanel_desc['messages'].each do |message_name, message_desc|
        post message_name do
          template = message_desc['template']
          opts = { markup: 'HTML' }.update(message_desc['options'] || {})
          # Some services will send json, but without correct content-type, then
          # params will be parsed weirdely. So we try parse request body as json
          params = ensure_json(request.body.read, params)
          # If message description contains any variables will merge them with
          # received parameters.
          params = message_desc['variables'].merge(params) if message_desc.key?('variables')
          bot.send_message(template, params, opts)
        end
      end
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
    rescue JSON::JSONError => _error
      params
    end
  end

  class << self
    def create(config)
      klazz = Class.new(Grape::API) do
        extend Generator
        helpers Helpers
      end

      klazz.configure(config)
    end
  end
end
