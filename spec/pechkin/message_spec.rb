module Pechkin
  describe Message do
    it 'merges data values with variables field' do
      template = MessageTemplate.new("Hello!")
      variables = { 'issue_labels' => ['HH-\\d+', 'hh'] }
      message = Message.new({ 'template' => template, 'variables' => variables })

      expect(template).to receive(:render).with(variables)
      message.prepare({})
    end

    it 'applies substitutions to message parameters' do
      data = { reference: 1234 }
      message_config = Message.new({ 'url' => 'https://a.com/${reference}' })
      expect(message_config.prepare(data).first).to eq({ 'url' => 'https://a.com/1234' })
    end

    it 'renders data values with template object' do
      template = MessageTemplate.new('<%= foo %>, <%= bar %>')
      data = { foo: 42, bar: 38 }
      message_config = Message.new({ 'template' => template })

      expect(message_config.prepare(data).last).to eq('42, 38')
    end
  end
end