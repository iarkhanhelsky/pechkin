module Pechkin
  describe MessageTemplate do
    it do
      expect(MessageTemplate.new('Hello <%= name %>!').render(name: 'John'))
        .to eq('Hello John!')
    end

    it 'Supports \'-\' trim mode' do
      template = "Hello\n<% if false %> not printed <% end -%>\n"
      expect(MessageTemplate.new(template).render({}))
        .to eq("Hello\n")
    end
  end
end
