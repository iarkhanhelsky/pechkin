module Pechkin
  describe CLI do
    context 'when config file is provided' do
      it do
        expect(CLI.parse(%w[-c test.yml]).config_file).to eq('test.yml')
      end
    end

    context 'when log-dir option is missing' do
      it do
        expect(CLI.parse(%w[-c test.yml]).log_dir).to be_nil
      end
    end

    context 'when log-dir option is provided' do
      it do
        expect(CLI.parse(%w[--log-dir /var/log]).log_dir).to eq('/var/log')
      end
    end

    context 'when port number is not provided' do
      it { expect(CLI.parse(%w[-c test.yml]).port).to eq(9292) }
    end

    context 'when port number is provided' do
      it { expect(CLI.parse(%w[-c test.yml --port 8080]).port).to eq(8080) }
    end

    context 'when pid file is requested (short)' do
      it do
        expect(CLI.parse(%w[-c test.yml -p app.pid]).pid_file).to eq('app.pid')
      end
    end

    context 'when pid file is requested (long)' do
      it do
        expect(CLI.parse(%w[-c test.yml --pid-file app.pid]).pid_file)
          .to eq('app.pid')
      end
    end
  end
end
