module Pechkin
  describe TelegramConnector do
    BOT_TOKEN = 'bot123456'.freeze
    TELEGRAM_REQ_URL = "https://api.telegram.org/bot#{BOT_TOKEN}" \
                       '/sendMessage'.freeze

    let(:connector) { TelegramConnector.new(BOT_TOKEN) }
    let(:response) { double }
    before { expect(response).to receive(:code).and_return(200) }
    before { expect(response).to receive(:body).and_return('OK') }

    describe '#send_message' do
      it do
        data = { chat_id: 1234, text: 'Hello', parse_mode: 'HTML' }
        expect(connector).to receive(:post_data)
          .with(TELEGRAM_REQ_URL, data).and_return(response)

        expect(connector.send_message(1234, 'Hello', {}))
          .to eq([1234, 200, 'OK'])
      end

      it 'telegram_parse_mode overrides parse_mode value' do
        data = { chat_id: 1234, text: 'Hello', parse_mode: 'markdown' }
        expect(connector).to receive(:post_data)
          .with(TELEGRAM_REQ_URL, data).and_return(response)

        message_desc = { 'telegram_parse_mode' => 'markdown' }
        expect(connector.send_message(1234, 'Hello', message_desc))
          .to eq([1234, 200, 'OK'])
      end
    end
  end
end
