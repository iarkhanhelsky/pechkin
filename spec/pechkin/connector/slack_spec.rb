module Pechkin
  describe Connector::Slack do
    let(:slack_bot_token) { 'xoxb-123423-234234-omgomg' }
    let(:logger) { double('Logger') }
    let(:request_url) { 'https://slack.com/api/chat.postMessage' }
    let(:connector) { Connector::Slack.new(slack_bot_token, 'marvin') }
    let(:response) { double }
    before do
      allow(response).to receive(:code).and_return(200)
      allow(logger).to receive(:warn).with(any_args)
    end
    before { allow(response).to receive(:body).and_return('OK') }

    it 'Sends request to Slack API url' do
      expect(connector).to receive(:post_data)
        .with(request_url, anything, headers: anything).and_return(response)

      expect(connector.send_message('#general', nil, 'Hello', {}, logger))
        .to eq(channel: '#general', code: 200,  response: 'OK')
    end

    it 'Adds Authorization header with requests' do
      headers = { 'Authorization' => "Bearer #{slack_bot_token}" }
      expect(connector).to receive(:post_data)
        .with(anything, anything, headers: headers).and_return(response)

      expect(connector.send_message('#general', nil, 'Hello', {}, logger))
        .to eq(channel: '#general', code: 200, response: 'OK')
    end

    it 'Sends channel id and message text' do
      expect(connector).to receive(:post_data)
        .with(anything, { channel: '#general', text: 'Foo', attachments: {} },
              headers: anything)
        .and_return(response)

      expect(connector.send_message('#general', nil, 'Foo', {}, logger))
        .to eq(channel: '#general', code: 200, response: 'OK')
    end

    it 'Sends slack_attachments as attachments' do
      # Now we don't care about slack_attachments content. We just convert them
      # to json and send to Slack
      message_desc = { 'slack_attachments' => [{}] }

      expect(connector).to receive(:post_data)
        .with(anything, { channel: '#general', text: 'Foo', attachments: [{}] },
              headers: anything)
        .and_return(response)

      expect(connector.send_message('#general', nil, 'Foo', message_desc, logger))
        .to eq(channel: '#general', code: 200, response: 'OK')
    end

    context 'when text is empty and attachments is empty' do
      it do
        expect(connector.send_message('#general', nil, '', {}, logger))
          .to eq(channel: '#general', code: 400,
                 response: 'Internal error: message is empty')
      end
    end
  end
end
