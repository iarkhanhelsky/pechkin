module Pechkin
  describe Handler do
    describe '#handle' do
      let(:logger) { double('Logger') }
      before { allow(logger).to receive(:warn).with(any_args) }

      context 'when configuration has no channel with provided id' do
        it do
          expect { Handler.new({}).handle('foo', 'bar', logger, {}) }
            .to raise_error(ChannelNotFoundError)
        end
      end

      context 'when configuration has no message in channel' do
        it do
          channel_double = double
          expect(channel_double).to receive(:messages).and_return({})
          handler = Handler.new('foo' => channel_double)

          expect { handler.handle('foo', 'bar', logger, {}) }
            .to raise_error(MessageNotFoundError)
        end
      end

      let(:connector) { double }
      let(:channel) { double }
      let(:handler) { Handler.new('a' => channel) }

      before { allow(channel).to receive(:messages).and_return('a' => Message.new({})) }
      before { allow(channel).to receive(:chat_ids).and_return(['#general']) }
      before { allow(channel).to receive(:connector).and_return(connector) }

      it 'sends message for each channel id' do
        expect(connector).to receive(:send_message).with('#general', nil, '', {}, logger)
        expect(connector).to receive(:send_message).with('#random', nil, '', {}, logger)

        expect(channel)
          .to receive(:chat_ids).and_return(%w[#general #random])

        handler.handle('a', 'a', logger, {})
      end

      it 'renders data values with template object' do
        template = MessageTemplate.new('Hello!')
        data = { foo: 42, bar: 38 }
        message_config = Message.new({ 'template' => template })

        expect(channel).to receive(:messages).and_return('a' => message_config)
        expect(connector).to receive(:send_message).with('#general', nil, 'Hello!', {}, logger)

        handler.handle('a', 'a', logger, data)
      end

      context 'when message contains allow / forbid rules' do
        let(:connector) { double }
        let(:channel) { double }
        let(:handler) { Handler.new('a' => channel) }
        let(:msg) do
          v = YAML.safe_load <<~MESSAGE
            allow:
              - branch: 'master'
          MESSAGE

          Message.new(v)
        end

        before { allow(channel).to receive(:messages).and_return('a' => msg) }
        before { allow(channel).to receive(:chat_ids).and_return(['#general']) }
        before { allow(channel).to receive(:connector).and_return(connector) }

        it 'all chats will be skipped' do
          data = { 'branch' => 'default' }
          expect(channel)
            .to receive(:chat_ids).and_return(%w[#general #random])

          expect(handler.handle('a', 'a', logger, data)).to eq([])
        end

        it 'message will be send' do
          data = { 'branch' => 'master' }

          expect(channel)
            .to receive(:chat_ids).and_return(%w[#general #random])
          expect(connector).to receive(:send_message)
            .with('#general', nil, '', msg.to_h, logger)
            .and_return(:ok_general)
          expect(connector).to receive(:send_message)
            .with('#random', nil, '', msg.to_h, logger)
            .and_return(:ok_random)

          expect(handler.handle('a', 'a', logger, data))
            .to eq(%i[ok_general ok_random])
        end
      end
    end
  end
end
