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

    describe '::ruby_v260_or_later?' do
      it { expect(MessageTemplate.ruby_v260_or_later?('2.7')).to be(true) }
      it { expect(MessageTemplate.ruby_v260_or_later?('2.6.1')).to be(true) }
      it { expect(MessageTemplate.ruby_v260_or_later?('2.6.0')).to be(true) }
      it { expect(MessageTemplate.ruby_v260_or_later?('2.5.1')).to be(false) }
      it { expect(MessageTemplate.ruby_v260_or_later?('1.9')).to be(false) }
    end
  end

  describe MessageBinding do
    it do
      msg = MessageBinding.new(name: 'John', 'variables' => ['foo', 'bar'])
      expect(msg.name).to eq('John')
      expect(msg.variables).to eq(['foo', 'bar'])
    end
  end
end
