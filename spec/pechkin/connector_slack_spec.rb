module Pechkin
  describe SlackConnector do
    SLACK_BOT_TOKEN = 'xoxb-123423-234234-omgomg'.freeze
    SLACK_REQ_URL = 'https://slack.com/api/chat.postMessage'.freeze

    let(:request_url) { SLACK_REQ_URL }
    let(:connector) { SlackConnector.new(SLACK_BOT_TOKEN) }
    let(:response) { double }
    before { allow(response).to receive(:code).and_return(200) }
    before { allow(response).to receive(:body).and_return('OK') }

    it 'Sends request to Slack API url' do
      expect(connector).to receive(:post_data)
        .with(request_url, anything, headers: anything).and_return(response)

      expect(connector.send_message('#general', 'Hello', {}))
        .to eq(['#general', 200, 'OK'])
    end

    it 'Adds Authorization header with requests' do
      headers = { 'Authorization' => "Bearer #{SLACK_BOT_TOKEN}" }
      expect(connector).to receive(:post_data)
        .with(anything, anything, headers: headers).and_return(response)

      expect(connector.send_message('#general', 'Hello', {}))
        .to eq(['#general', 200, 'OK'])
    end

    it 'Sends channel id and message text' do
      expect(connector).to receive(:post_data)
        .with(anything, { channel: '#general', text: 'Foo', attachments: {} },
              headers: anything)
        .and_return(response)

      expect(connector.send_message('#general', 'Foo', {}))
        .to eq(['#general', 200, 'OK'])
    end

    it 'Sends slack_attachments as attachments' do
      # Now we don't care about slack_attachments content. We just convert them
      # to json and send to Slack
      message_desc = { 'slack_attachments' => [{}] }

      expect(connector).to receive(:post_data)
        .with(anything, { channel: '#general', text: 'Foo', attachments: [{}] },
              headers: anything)
        .and_return(response)

      expect(connector.send_message('#general', 'Foo', message_desc))
        .to eq(['#general', 200, 'OK'])
    end

    context 'when text is empty and attachments is empty' do
      it do
        expect(connector.send_message('#general', '', {}))
          .to eq(['#general', 400, 'Internal error: message is empty'])
      end
    end
  end
end
