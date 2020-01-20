require 'yaml'

require_relative 'configuration/model'
require_relative 'configuration/configuration_loader'
require_relative 'configuration/configuration_loader_bots'
require_relative 'configuration/configuration_loader_channels'
require_relative 'configuration/configuration_loader_views'

module Pechkin
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
    class << self
      def load_from_directory(working_dir)
        bots = ConfigurationLoaderBots.new.load_from_directory(working_dir)
        views = ConfigurationLoaderViews.new.load_from_directory(working_dir)

        channel_loader = ConfigurationLoaderChannels.new(bots, views)
        channels = channel_loader.load_from_directory(working_dir)

        Configuration.new(working_dir, bots, views, channels)
      end
    end

    attr_accessor :bots, :channels, :views, :working_dir

    def initialize(working_dir, bots, views, channels)
      @working_dir = working_dir
      @bots = bots
      @views = views
      @channels = channels
    end
  end
end
