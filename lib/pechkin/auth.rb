module Pechkin
  module Auth
    # Utility class for altering htpasswd files
    class Manager
      attr_reader :htpasswd
      def initialize(htpasswd)
        @htpasswd = htpasswd
      end

      def add(user, password)
        m = File.exist?(htpasswd) ? HTAuth::File::ALTER : HTAuth::File::CREATE
        HTAuth::PasswdFile.open(htpasswd, m) do |f|
          f.add_or_update(user, password, 'md5')
        end
      end
    end

    # Auth middleware to check if provided auth can be found in .htpasswd file
    class Middleware
      attr_reader :htpasswd

      def initialize(app, auth_file:)
        @htpasswd = HTAuth::PasswdFile.open(auth_file)
        @app = app
      end

      def call(env)
        if authorized?(env)
          @app.call(env)
        else
          body = { status: 'error', reason: 'unathorized' }.to_json
          ['401', { 'Content-Type' => 'application/json' }, [body]]
        end
      rescue StandardError => e
        puts e.backtrace.reverse.join('\n\t')
        body = { status: 'error', reason: e.message }.to_json
        ['503', { 'Content-Type' => 'application/json' }, [body]]
      end

      private

      def authorized?(env)
        return true unless htpasswd

        auth = env['HTTP_AUTHORIZATION'] || ''
        auth.match(/^Basic (.+)$/) do |m|
          check_auth(*Base64.decode64(m[1]).split(':'))
        end
      end

      def check_auth(user, password)
        e = htpasswd.fetch(user)
        e && e.authenticated?(password)
      end
    end
  end
end
