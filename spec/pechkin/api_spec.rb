module Pechkin
  describe Generator do
    include Rack::Test::Methods

    FIXTURE_CONFIG = <<-CONFIG.strip_indent.freeze
    bots:
      marvin:
        token: TEST123456789
        connector: tg
    views:
    chanels:
      test:
        chat_ids: 10000
        bot: marvin
        messages:
          test:
            template: spec/views/simple.erb
          options:
            parse_mode: html
          test-filters:
            template: spec/views/simple.erb
            filters:
              text: /^default$/
    CONFIG

    let(:send_message_url) do
      'https://api.telegram.org/botTEST123456789/sendMessage'
    end

    def app
      app = Pechkin.create(YAML.safe_load(FIXTURE_CONFIG))
      app.logger Logger.new(StringIO.new)
      app
    end

    context 'when template file does not exist' do
      it 'raises error' do
        post '/test/test-test'
        expect(last_response.status).to eq(404)
      end
    end

    context 'when bot does not exist' do
      it 'raises error'
    end

    context 'when chat does not exist' do
      it 'raises error' do
        post '/test2/test'
        expect(last_response.status).to eq(404)
      end
    end

    context 'POST request with valid content-type ("application/json")' do
      let(:request) { { 'hello' => 'world' } }

      it do
        stub_request(:post, send_message_url)
          .with(body: { 'parse_mode' => 'HTML',
                        'chat_id' => 10_000,
                        'text' => request.to_json }.to_json)
          .to_return(status: 200)

        header 'Content-Type', 'application/json'
        post '/test/test', request.to_json
      end
    end

    context 'POST request without content-type' do
      let(:request) { { 'hello' => 'world' } }
      it do
        stub_request(:post, send_message_url)
          .with(body: { 'parse_mode' => 'HTML',
                        'chat_id' => 10_000,
                        'text' => request.to_json }.to_json,
                headers: { 'Content-Type' => 'application/json' })
          .to_return(status: 200)
        post '/test/test', request.to_json
      end
    end

    context 'when chanel contains filters' do
      context 'when parameter matches filter' do
        let(:send_message_url) do
          'https://api.telegram.org/botTEST123456789/sendMessage'
        end

        let(:request) { { 'text' => 'default' } }

        it do
          stub_request(:post, send_message_url)
            .with(body: { 'chat_id' => '10000',
                          'parse_mode' => 'HTML',
                          'text' => request.to_json })
            .to_return(status: 200)
          post '/test/test-filters', request.to_json
        end
      end

      context 'when parameter does not match filter' do
        let(:request) { { 'text' => 'master' } }
        it do
          post '/test/test-filters', request.to_json
          # Did not pass validation
          expect(last_response.status).to eq(400)
        end
      end
    end
  end

  describe 'Generated application' do
    describe 'POST /:chanel/:message' do
      context 'when chanel does not exist' do
        it
      end

      context 'when message does not exist' do
        it
      end
    end
  end
end
