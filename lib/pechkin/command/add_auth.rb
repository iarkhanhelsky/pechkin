module Pechkin
  module Command
    # Read user:password combination and write it to htpasswd file. If file
    # already contains user then record will be replaced
    class AddAuth < BaseCommand
      def matches?
        options.add_auth
      end

      def execute
        user, password = options.add_auth.split(':')
        Pechkin::Auth::Manager.new(options.htpasswd).add(user, password)
        puts IO.read(options.htpasswd)
      end
    end
  end
end
