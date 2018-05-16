module Pechkin
  describe CLI do
    context 'when config file is provided' do
      it do
        expect(CLI.parse(%w[-c test.yml]).config_file).to eq('test.yml')
      end
    end

    context 'when config file option is missing' do
      it do
        expect(CLI.parse(%w[]).config_file).to eq('/etc/pechkin/config.yml')
      end
    end

    context 'when log-dir option is missing' do
      it do
        expect(CLI.parse(%w[]).log_dir).to be_nil
      end
    end

    context 'when log-dir option is provided' do
      it do
        expect(CLI.parse(%w[--log-dir /var/log])).to_eq('/var/log')
      end
    end
  end
end
