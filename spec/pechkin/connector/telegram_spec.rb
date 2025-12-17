module Pechkin
  describe Connector::Telegram do
    let(:telegram_bot_token) { 'bot123456' }
    let(:request_url) do
      "https://api.telegram.org/bot#{telegram_bot_token}/sendMessage"
    end
    let(:logger) { double('Logger') }
    let(:connector) { Connector::Telegram.new(telegram_bot_token, 'marvin') }
    let(:response) { double }
    before { expect(response).to receive(:code).and_return(200) }
    before { expect(response).to receive(:body).and_return('OK') }
    before { allow(logger).to receive(:warn).with(any_args) }

    describe '#send_message' do
      it do
        data = { chat_id: 1234, text: 'Hello', parse_mode: 'HTML' }
        expect(connector).to receive(:post_data)
          .with(request_url, data).and_return(response)

        expect(connector.send_message(1234, nil, 'Hello', {}, logger))
          .to eq(chat_id: 1234, code: 200, response: 'OK')
      end

      it 'telegram_parse_mode overrides parse_mode value' do
        data = { chat_id: 1234, text: 'Hello', parse_mode: 'markdown' }
        expect(connector).to receive(:post_data)
          .with(request_url, data).and_return(response)

        message_desc = { 'telegram_parse_mode' => 'markdown' }
        expect(connector.send_message(1234, nil, 'Hello', message_desc, logger))
          .to eq(chat_id: 1234, code: 200, response: 'OK')
      end
    end
  end
end
