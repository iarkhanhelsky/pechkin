module Pechkin
  describe Handler do
    describe '#handle' do
      context 'when configuration has no channel with provided id' do
        it do
          expect { Handler.new({}).handle('foo', 'bar', {}) }
            .to raise_error(ChannelNotFoundError)
        end
      end

      context 'when configuration has no message in channel' do
        it do
          channel_double = double
          expect(channel_double).to receive(:messages).and_return({})
          handler = Handler.new('foo' => channel_double)

          expect { handler.handle('foo', 'bar', {}) }
            .to raise_error(MessageNotFoundError)
        end
      end

      let(:connector) { double }
      let(:channel) { double }
      let(:handler) { Handler.new('a' => channel) }

      before { allow(channel).to receive(:messages).and_return('a' => {}) }
      before { allow(channel).to receive(:chat_ids).and_return(['#general']) }
      before { allow(channel).to receive(:connector).and_return(connector) }

      it 'applies substitutions to message parameters' do
        data = { reference: 1234 }
        message_config = { 'url' => 'https://a.com/${reference}' }
        substituted_config = { 'url' => 'https://a.com/1234' }

        expect(channel).to receive(:messages).and_return('a' => message_config)

        expect(connector)
          .to receive(:send_message).with('#general', '', substituted_config)

        handler.handle('a', 'a', data)
      end

      it 'merges data values with variables field' do
        template = double
        message = {
          'template' => template,
          'variables' => { 'issue_labels' => ['HH-\\d+', 'hh'] }
        }

        expect(channel)
          .to receive(:messages).and_return('a' => message)
        expect(template)
          .to receive(:render).with(message['variables']).and_return('')
        expect(connector)
          .to receive(:send_message).with('#general', '', message)

        handler.handle('a', 'a', {})
      end

      it 'sends message for each channel id' do
        expect(connector).to receive(:send_message).with('#general', '', {})
        expect(connector).to receive(:send_message).with('#random', '', {})

        expect(channel)
          .to receive(:chat_ids).and_return(['#general', '#random'])

        handler.handle('a', 'a', {})
      end

      it 'renders data values with template object' do
        template = double
        data = { foo: 42, bar: 38 }
        message_config = { 'template' => template }

        expect(channel).to receive(:messages).and_return('a' => message_config)
        expect(template).to receive(:render).with(data).and_return('Hello!')
        expect(connector)
          .to receive(:send_message).with('#general', 'Hello!', message_config)

        handler.handle('a', 'a', data)
      end

      context 'when message contains allow / forbid rules' do
        let(:connector) { double }
        let(:channel) { double }
        let(:handler) { Handler.new('a' => channel) }
        let(:message) do
          YAML.safe_load <<~MESSAGE
            allow:
              - branch: 'master'
          MESSAGE
        end

        before { allow(channel).to receive(:messages).and_return('a' => message) }
        before { allow(channel).to receive(:chat_ids).and_return(['#general']) }
        before { allow(channel).to receive(:connector).and_return(connector) }

        it 'all chats will be skipped' do
          data = { 'branch' => 'default' }
          expect(channel)
            .to receive(:chat_ids).and_return(['#general', '#random'])

          expect(handler.handle('a', 'a', data)).to eq([])
        end

        it 'message will be send' do
          data = { 'branch' => 'master' }

          expect(channel)
            .to receive(:chat_ids).and_return(['#general', '#random'])
          expect(connector).to receive(:send_message)
            .with('#general', '', message)
            .and_return(:ok_general)
          expect(connector).to receive(:send_message)
            .with('#random', '', message)
            .and_return(:ok_random)

          expect(handler.handle('a', 'a', data))
            .to eq(%i[ok_general ok_random])
        end
      end
    end
  end
end
