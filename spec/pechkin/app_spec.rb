module Pechkin
  describe App do
    include Rack::Test::Methods

    let(:app) { App.new }
    let(:handler) { double }

    before(:each) do
      app.handler = handler
      allow(handler).to receive(:message?).with(anything, anything)
    end

    context 'GET is not allowed' do
      it do
        get '/foo/bar'
        expect(last_response.status).to eq(405)
      end
    end

    context 'HEAD is not allowed' do
      it do
        head '/foo/bar'
        expect(last_response.status).to eq(405)
      end
    end

    context 'DELETE is not allowed' do
      it do
        delete '/foo/bar'
        expect(last_response.status).to eq(405)
      end
    end

    context 'OPTIONS is not allowed' do
      it do
        options '/foo/bar'
        expect(last_response.status).to eq(405)
      end
    end

    context 'PATCH is not allowed' do
      it do
        patch '/foo/bar'
        expect(last_response.status).to eq(405)
      end
    end

    context 'POST is allowed' do
      it do
        post '/foo/bar'
        expect(last_response.status).not_to eq(405)
      end
    end

    context 'when requested path is not /channel/message' do
      it do
        post '/b/c'
        expect(last_response.status).to eq(404)
      end

      it do
        expect(handler).not_to receive(:message?).with(anything, anything)

        post '/'
        expect(last_response.status).to eq(404)
      end

      it do
        expect(handler).not_to receive(:message?).with(anything, anything)

        post '/omg'
        expect(last_response.status).to eq(404)
      end
    end

    it do
      data = { name: 'John' }
      expect(handler)
        .to receive(:message?).with('a', 'b').and_return(true)
      expect(handler)
        .to receive(:handle).with('a', 'b', { 'name' => 'John' }).and_return([])

      post '/a/b', data.to_json

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq('[]')
    end

    context 'when data is not json' do
      it do
        expect(handler).to receive(:message?).with('a', 'b').and_return(true)

        post '/a/b', 'Obviosly not a json string'
        expect(last_response.status).to eq(503)
      end
    end
  end
end
