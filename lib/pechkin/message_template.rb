module Pechkin
  # Class to provide binding for ERB templating engine
  class MessageBinding < OpenStruct
    def render_template(template)
      template.result(binding)
    end
  end

  # Message template to render final message.
  class MessageTemplate
    class << self
      def ruby_v260_or_later?(ruby_version = RUBY_VERSION)
        # Need to compare two versions, one is 2.6.0 - which supports keyword
        # arguments in ERB#initialize. Everything below that should use legacy
        # arguments
        rb_v260 = [2, 6, 0]
        rb_current = ruby_version.split('.').map(&:to_i)

        rb_v260.zip(rb_current).each do |x, y|
          x ||= 0
          y ||= 0
          return false if y < x
        end

        true
      end
    end

    RUBY_V260 = MessageTemplate.ruby_v260_or_later?

    def initialize(erb)
      # ERB#initialize has different signature starting from Ruby 2.6.*
      # See link:
      # https://github.com/ruby/ruby/blob/2311087/NEWS#stdlib-updates-outstanding-ones-only
      if MessageTemplate::RUBY_V260
        @erb_template = ERB.new(erb, trim_mode: '-')
      else
        safe_level = nil
        trim_mode = '-'
        @erb_template = ERB.new(erb, safe_level, trim_mode)
      end
    end

    def render(data)
      MessageBinding.new(data).render_template(@erb_template)
    end
  end
end
