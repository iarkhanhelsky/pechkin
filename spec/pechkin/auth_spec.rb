require_relative '../spec_helper'

describe Pechkin::Auth::Middleware do
  before(:all) do
    # admin:admin
    htpasswd_content = 'admin:$apr1$01Qu1Wqq$ODnwSVr.yfRH6zsJ1UFOb.'
    @htpasswd_file = Tempfile.new(['pechkin-', '.htpasswd'])
    @htpasswd_file.write("#{htpasswd_content}\n")
    @htpasswd_file.close
  end

  let(:app) { double }
  let(:middleware) { Pechkin::Auth::Middleware.new(app, auth_file: @htpasswd_file.path) }

  it 'fails to authorize if Authorization header is missing' do
    env = {}
    code, _header, body = middleware.call(env)
    expect(code).to eq('401')
    expect(body.first)
      .to eq({ status: 'error', reason: 'Auth header is missing' }.to_json)
  end

  it 'fails to authorize if Authorization is not Basic' do
    env = { 'HTTP_AUTHORIZATION' => 'Bearer aoch7Ref5aiku7aM' }
    code, _header, body = middleware.call(env)
    expect(code).to eq('401')
    expect(body.first)
      .to eq({ status: 'error', reason: 'Auth is not basic' }.to_json)
  end

  it 'fails to authorize if Auth header contains only user field' do
    auth = Base64.encode64('admin')
    env = { 'HTTP_AUTHORIZATION' => "Basic #{auth}" }
    code, _header, body = middleware.call(env)
    expect(code).to eq('401')
    expect(body.first)
      .to eq({ status: 'error', reason: 'Password is missing' }.to_json)
  end

  it 'fails to authorize if Auth header contains empty auth string' do
    auth = Base64.encode64('')
    env = { 'HTTP_AUTHORIZATION' => "Basic #{auth}" }
    code, _header, body = middleware.call(env)
    expect(code).to eq('401')
    expect(body.first)
      .to eq({ status: 'error', reason: 'User is missing' }.to_json)
  end

  it 'fails to authorize if user doesn\'t match' do
    auth = Base64.encode64('root:admin')
    env = { 'HTTP_AUTHORIZATION' => "Basic #{auth}" }
    code, _header, body = middleware.call(env)
    expect(code).to eq('401')

    error = "User \'root\' not found"
    expect(body.first)
      .to eq({ status: 'error', reason: error }.to_json)
  end

  it 'fails to authorize if password doesn\'t match' do
    auth = Base64.encode64('admin:admin123')
    env = { 'HTTP_AUTHORIZATION' => "Basic #{auth}" }
    code, _header, body = middleware.call(env)
    expect(code).to eq('401')
    expect(body.first)
      .to eq({ status: 'error', reason: "Can't authenticate" }.to_json)
  end

  it 'calls app if auth matching' do
    auth = Base64.encode64('admin:admin')
    env = { 'HTTP_AUTHORIZATION' => "Basic #{auth}" }
    response = ['200', {}, 'Hello!']
    expect(app).to receive(:call).with(env).and_return(response)

    expect(middleware.call(env)).to eq(response)
  end

  after(:all) do
    @htpasswd_file.unlink
  end
end
