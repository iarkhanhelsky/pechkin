module Pechkin
  # Message object
  #
  # TBD
  class Message
    def initialize(message)
      @message = message
    end

    def prepare(data)
      data = (@message['variables'] || {}).merge(data)
      # Find message and try substitute values to message parameters.
      message_config = render(data, substitute(data, @message))
      text = ''
      text = message_config.delete('template') if message_config.key?('template')

      [message_config, text]
    end

    def to_h
      Marshal.load(Marshal.dump(@message))
    end

    private

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

    def render(data, message_desc)
      render_recursive(data, message_desc)
    end

    def render_recursive(data, object)
      case object
      when MessageTemplate
        object.render(data)
      when Array
        object.map { |o| render_recursive(data, o) }
      when Hash
        r = {}
        object.each { |k, v| r[k] = render_recursive(data, v) }
        r
      else
        object
      end
    end
  end
end
