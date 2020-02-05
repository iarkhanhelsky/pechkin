module Pechkin
  class MessageMatchError < StandardError; end
  # Allows to match message configuration against received data.
  #
  # Data is checked againts either allow or forbid rules. But not both at the
  # same time. Each field can contain list of rules to check. 'allow' list means
  # we need at least one matching rule to allow data processing. And 'forbid'
  # list respectievly means we need at least one matching rule to decline data
  # processing.
  class MessageMatcher
    # Checks data object against allow / forbid rule sets in message
    # configuration. If data object matches rules it means we can process this
    # data and send message.
    #
    # @param message_config [Hash] message description.
    # @param data [Hash] request object that need to be inspected whether we
    #   should process this data or not
    # @return [Boolean] is data object matches message_config rules or not
    def matches?(message_config, data)
      check(message_config)

      if message_config.key?('allow')
        rules = message_config['allow']
        rules.any? { |r| check_rule(r, data) }
      elsif message_config.key?('forbid')
        rules = message_config['forbid']
        rules.all? { |r| !check_rule(r, data) }
      else
        true
      end
    end

    private

    def check(msg)
      return unless msg.key?('allow') && msg.key?('forbid')

      raise MessageMatchError, 'Both allow and forbid present in message config'
    end

    # Check rule object against data. Rules are checked recursievly, i.e. we
    # can take one field in rule and check it separately as new rule. If all
    # fields are passed check then whole rule passed.
    def check_rule(rule, data)
      if rule.is_a?(Hash)
        check_hash_rule(rule, data)
      elsif rule.is_a?(Array)
        check_array_rule(rule, data)
      elsif rule.is_a?(String)
        check_string_rule(rule, data)
      else
        rule.eql?(data)
      end
    end

    def check_hash_rule(hash, data)
      return false unless data.is_a?(Hash)

      hash.all? do |key, value|
        data.key?(key) && check_rule(value, data[key])
      end
    end

    def check_array_rule(array, data)
      return false unless data.is_a?(Array)

      # Deep array check needs to be done against all elements so we zip arrays
      # to pair each rule with data element
      array.zip(data).all? { |r, d| check_rule(r, d) }
    end

    def check_string_rule(str, data)
      str.eql? data
    end
  end
end
