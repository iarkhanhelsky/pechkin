module Pechkin
  class MessageMatchError < StandardError; end
  # Allows to match message configuration against received data.
  #
  # Data is checked againts either allow or forbid rules. But not both at the
  # same time.
  class MessageMatcher
    def matches?(message_config, _data)
      check(message_config)

      true
    end

    private

    def check(message_config)
      return unless message_config.key?('allow') && message_config.key?('forbid')

      raise MessageMatchError, 'Both allow and forbid present in message config'
    end
  end
end
