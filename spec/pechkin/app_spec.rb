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
      .to receive(:handle).with('a', 'b', any_args, 'name' => 'John').and_return([])

    post '/a/b', data.to_json

    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq('[]')
  end

  context 'when data is not json' do
    it do
      expect(handler).to receive(:message?).with('a', 'b').and_return(true)
      expect(logger).to receive(:error).with(any_args)

      post '/a/b', 'Obviosly not a json string'
      expect(last_response.status).to eq(503)
    end
  end
end
