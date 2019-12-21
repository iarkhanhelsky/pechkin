module Pechkin
  module Auth
    describe Middleware do
      before(:all) do
        # admin:admin
        htpasswd_content = 'admin:$apr1$01Qu1Wqq$ODnwSVr.yfRH6zsJ1UFOb.'
        @htpasswd_file = Tempfile.new(['pechkin-', '.htpasswd'])
        @htpasswd_file.write(htpasswd_content + "\n")
        @htpasswd_file.close
      end

      let(:app) { double }
      let(:middleware) { Middleware.new(app, auth_file: @htpasswd_file.path) }

      it 'fails to authorize if Authorization header is missing' do
        env = {}
        expect(middleware.call(env).first).to eq('401')
      end

      it 'fails to authorize if Authorization is not Basic' do
        env = { 'HTTP_AUTHORIZATION' => 'Bearer aoch7Ref5aiku7aM' }
        expect(middleware.call(env).first).to eq('401')
      end

      it 'fails to authorize if user doesn\'t match' do
        auth = Base64.encode64('root:admin')
        env = { 'HTTP_AUTHORIZATION' => "Basic #{auth}" }
        expect(middleware.call(env).first).to eq('401')
      end

      it 'fails to authorize if password doesn\'t match' do
        auth = Base64.encode64('admin:admin123')
        env = { 'HTTP_AUTHORIZATION' => "Basic #{auth}" }
        expect(middleware.call(env).first).to eq('401')
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
  end
end
