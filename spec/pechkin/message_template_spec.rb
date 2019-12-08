module Pechkin
  describe MessageTemplate do
    it do
      expect(MessageTemplate.new('Hello <%= name %>!').render(name: 'John'))
        .to eq('Hello John!')
    end
  end
end
