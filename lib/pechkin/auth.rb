module Pechkin
  module Auth
    class AuthError < StandardError; end

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
        @htpasswd = HTAuth::PasswdFile.open(auth_file) if File.exist?(auth_file)
        @app = app
      end

      def call(env)
        authorize(env)
        @app.call(env)
      rescue AuthError => e
        body = { status: 'error', reason: e.message }.to_json
        ['401', { 'Content-Type' => 'application/json' }, [body]]
      rescue StandardError => e
        body = { status: 'error', reason: e.message }.to_json
        ['503', { 'Content-Type' => 'application/json' }, [body]]
      end

      private

      def authorize(env)
        return unless htpasswd

        auth = env['HTTP_AUTHORIZATION']
        raise AuthError, 'Auth header is missing' unless auth

        match = auth.match(/^Basic (.*)$/)
        raise AuthError, 'Auth is not basic' unless match

        user, password = *Base64.decode64(match[1]).split(':')
        check_auth(user, password)
      end

      def check_auth(user, password)
        raise AuthError, 'User is missing' unless user

        raise AuthError, 'Password is missing' unless password

        e = htpasswd.fetch(user)

        raise AuthError, "User '#{user}' not found" unless e

        raise AuthError, "Can't authenticate" unless e.authenticated?(password)
      end
    end
  end
end
