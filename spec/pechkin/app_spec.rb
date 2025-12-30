require 'rack/test'
require_relative '../spec_helper'

describe Pechkin::App do
  include Rack::Test::Methods

  let(:logger) { double }
  let(:app) { Pechkin::App.new(logger) }
  let(:handler) { double }

  before(:each) do
    app.handler = handler
    allow(handler).to receive(:message?).with(anything, anything)
  end

  context 'GET is not allowed' do
    it do
      expect(logger).to receive(:error).with(anything)

      get '/foo/bar'
      expect(last_response.status).to eq(405)
    end
  end

  context 'HEAD is not allowed' do
    it do
      expect(logger).to receive(:error).with(anything)

      head '/foo/bar'
      expect(last_response.status).to eq(405)
    end
  end

  context 'DELETE is not allowed' do
    it do
      expect(logger).to receive(:error).with(anything)

      delete '/foo/bar'
      expect(last_response.status).to eq(405)
    end
  end

  context 'OPTIONS is not allowed' do
    it do
      expect(logger).to receive(:error).with(anything)

      options '/foo/bar'
      expect(last_response.status).to eq(405)
    end
  end

  context 'PATCH is not allowed' do
    it do
      expect(logger).to receive(:error).with(anything)
      patch '/foo/bar'
      expect(last_response.status).to eq(405)
    end
  end

  context 'POST is allowed' do
    it do
      expect(logger).to receive(:error).with(anything)
      post '/foo/bar'
      expect(last_response.status).not_to eq(405)
    end
  end

  context 'when requested path is not /channel/message' do
    it do
      expect(logger).to receive(:error).with(anything)
      post '/b/c'

      expect(last_response.status).to eq(404)
    end

    it do
      expect(handler).not_to receive(:message?).with(anything, anything)
      expect(logger).to receive(:error).with(anything)

      post '/'
      expect(last_response.status).to eq(404)
    end

    it do
      expect(handler).not_to receive(:message?).with(anything, anything)
      expect(logger).to receive(:error).with(anything)

      post '/omg'
      expect(last_response.status).to eq(404)
    end
  end

  it do
    data = { name: 'John' }
    expect(handler)
      .to receive(:message?).with('a', 'b').and_return(true)
    expect(handler)
      .to receive(:handle).with('a', 'b', anything, hash_including('name' => 'John')).and_return([])

    post '/a/b', data.to_json

    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq('[]')
  end

  context 'when data is not json' do
    it do
      expect(handler).to receive(:message?).with('a', 'b').and_return(true)
      expect(logger).to receive(:error).with(any_args)

      post '/a/b', 'Obviosly not a json string'
      expect(last_response.status).to eq(400)
    end
  end

  context 'status codes are integers' do
    it 'returns integer status code for successful response' do
      data = { name: 'John' }
      expect(handler)
        .to receive(:message?).with('a', 'b').and_return(true)
      expect(handler)
        .to receive(:handle).with('a', 'b', anything, hash_including('name' => 'John')).and_return([])

      post '/a/b', data.to_json

      expect(last_response.status).to be_a(Integer)
      expect(last_response.status).to eq(200)
    end

    it 'returns integer status code for 404 error' do
      expect(logger).to receive(:error).with(anything)
      post '/b/c'

      expect(last_response.status).to be_a(Integer)
      expect(last_response.status).to eq(404)
    end

    it 'returns integer status code for 405 error' do
      expect(logger).to receive(:error).with(anything)
      get '/foo/bar'

      expect(last_response.status).to be_a(Integer)
      expect(last_response.status).to eq(405)
    end

    it 'returns integer status code for 400 error' do
      expect(handler).to receive(:message?).with('a', 'b').and_return(true)
      expect(logger).to receive(:error).with(any_args)

      post '/a/b', 'Invalid JSON'

      expect(last_response.status).to be_a(Integer)
      expect(last_response.status).to eq(400)
    end

    it 'returns integer status code for favicon.ico request' do
      post '/favicon.ico'

      expect(last_response.status).to be_a(Integer)
      expect(last_response.status).to eq(405)
    end

    it 'verifies raw Rack response array has integer status code' do
      data = { name: 'John' }
      expect(handler)
        .to receive(:message?).with('a', 'b').and_return(true)
      expect(handler)
        .to receive(:handle).with('a', 'b', anything, hash_including('name' => 'John')).and_return([])

      post '/a/b', data.to_json

      # Access the raw Rack response to verify the status is an integer
      rack_response = last_response
      status_code = rack_response.status
      expect(status_code).to be_a(Integer)
      expect(status_code).to eq(200)
    end

    it 'verifies raw Rack response array structure directly' do
      data = { name: 'John' }
      expect(handler)
        .to receive(:message?).with('a', 'b').and_return(true)
      expect(handler)
        .to receive(:handle).with('a', 'b', anything, hash_including('name' => 'John')).and_return([])

      env = Rack::MockRequest.env_for('/a/b', method: 'POST', input: data.to_json)
      status, _headers, _body = app.call(env)

      # Verify the first element of the Rack response array is an integer
      expect(status).to be_a(Integer)
      expect(status).to eq(200)
    end

    it 'verifies raw Rack response array structure for error responses' do
      expect(logger).to receive(:error).with(anything)

      env = Rack::MockRequest.env_for('/b/c', method: 'POST')
      status, _headers, _body = app.call(env)

      # Verify the first element of the Rack response array is an integer
      expect(status).to be_a(Integer)
      expect(status).to eq(404)
    end
  end
end
