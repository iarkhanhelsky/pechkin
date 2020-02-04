module Pechkin
  # Allows to match message configuration against received data.
  #
  # Data is checked againts either allow or forbid rules. But not both at the
  # same time.
  class MessageMatcher
    def matches?(_message_config, _data)
      true
    end
  end
end
