module Pechkin
  # Class to provide binding for ERB templating engine
  class MessageBinding < OpenStruct
    def render_template(template)
      template.result(binding)
    end
  end

  # Message template to render final message.
  class MessageTemplate

    ERB_INITIALIZE_KEYWORD_ARGUMENTS = ERB.instance_method(:initialize).parameters.assoc(:key)

    def initialize(erb)
      # ERB#initialize has different signature starting from Ruby 2.6.*
      # See link:
      # https://github.com/ruby/ruby/blob/2311087/NEWS#stdlib-updates-outstanding-ones-only
      if MessageTemplate::ERB_INITIALIZE_KEYWORD_ARGUMENTS # Ruby 2.6+
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
