module Pechkin
  # Class to provide binding for ERB templating engine
  class MessageBinding < OpenStruct
    def render_template(template)
      template.result(binding)
    end
  end

  # Message template to render final message.
  class MessageTemplate
    def initialize(erb)
      @erb_template = ERB.new(erb)
    end

    def render(data)
      MessageBinding.new(data).render_template(@erb_template)
    end
  end
end
