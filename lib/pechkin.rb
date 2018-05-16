require 'grape'

require_relative 'pechkin/config'
require_relative 'pechkin/telegram'

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
          bot.send_message(template, params, opts)
        end
      end
    end
  end

  class << self
    def create(config)
      klazz = Class.new(Grape::API) do
        extend Generator
      end

      klazz.configure(config)
    end
  end
end
