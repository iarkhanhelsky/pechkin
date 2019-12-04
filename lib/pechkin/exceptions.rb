module Pechkin
  class ChannelNotFoundError < StandardError # :nodoc:
    def initialize(channel_name)
      super("No such channel #{channel_name}")
    end
  end
  class MessageNotFoundError < StandardError; end
  class MessageContentIsEmptyError < StandardError; end
end
