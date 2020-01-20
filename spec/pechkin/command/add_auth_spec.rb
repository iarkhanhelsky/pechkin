require 'tempfile'

module Pechkin
  module Command
    describe AddAuth do
      let!(:htpasswd) { Tempfile.new }
      let!(:stdout) { StringIO.new }
      let!(:stderr) { StringIO.new }
      let!(:cmd) do
        AddAuth.new(OpenStruct.new(add_auth: 'admin:admin123',
                                   htpasswd: htpasswd),
                    stdout: stdout, stderr: stderr)
      end

      it 'prints htpasswd file content on end' do
        cmd.execute
        expect(stdout.string).to match(/^admin:\$apr1\$.+\$.+$/)
        expect(stderr.string).to be_empty
      end

      after(:each) { htpasswd.unlink }
    end
  end
end
