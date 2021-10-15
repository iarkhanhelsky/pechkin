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
    KEY_ALLOW = 'allow'.freeze
    KEY_FORBID = 'forbid'.freeze

    attr_reader :logger

    def initialize(logger)
      @logger = logger
    end

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

      if message_config.key?(KEY_ALLOW)
        rules = message_config[KEY_ALLOW]
        rules.any? { |r| check_rule(r, r, data) }
      elsif message_config.key?(KEY_FORBID)
        rules = message_config[KEY_FORBID]
        rules.all? { |r| !check_rule(r, r, data) }
      else
        true
      end
    end

    private

    def check(msg)
      return unless msg.key?(KEY_ALLOW) && msg.key?(KEY_FORBID)

      raise MessageMatchError, 'Both allow and forbid present in message config'
    end

    # Check rule object against data. Rules are checked recursievly, i.e. we
    # can take one field in rule and check it separately as new rule. If all
    # fields are passed check then whole rule passed.
    def check_rule(top_rule, sub_rule, data)
      result = case sub_rule
               when Hash
                 check_hash_rule(top_rule, sub_rule, data)
               when Array
                 check_array_rule(top_rule, sub_rule, data)
               when String
                 check_string_rule(top_rule, sub_rule, data)
               else
                 sub_rule.eql?(data)
               end

      unless result
        logger.info "Expected #{sub_rule.to_json} got #{data.to_json} when" \
                    " checking #{top_rule.to_json}"
      end

      result
    end

    def check_hash_rule(top_rule, hash, data)
      return false unless data.is_a?(Hash)

      hash.all? do |key, value|
        data.key?(key) && check_rule(top_rule, value, data[key])
      end
    end

    def check_array_rule(top_rule, array, data)
      return false unless data.is_a?(Array)

      # Deep array check needs to be done against all elements so we zip arrays
      # to pair each rule with data element
      array.zip(data).all? { |r, d| check_rule(top_rule, r, d) }
    end

    def check_string_rule(_top_rule, str, data)
      str.eql? data
    end
  end
end
