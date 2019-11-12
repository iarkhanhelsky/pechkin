module Pechkin
  # Easy way to render erb template
  class Message < OpenStruct
    def render(template_file)
      ERB.new(IO.read(template_file)).result(binding)
    end
  end
end
