module Pechkin
  module Command
    describe Dispatcher do
      context 'when cli contains --add-auth' do
        let(:cli) { CLI.parse(%w[--add-auth admin:admin123]) }
        it { expect(Dispatcher.new(cli).dispatch).to be_a(AddAuth) }
      end

      context 'when cli contains --check' do
        let(:cli) { CLI.parse(%w[--check]) }
        it { expect(Dispatcher.new(cli).dispatch).to be_a(Check) }
      end

      context 'when cli contains -k' do
        let(:cli) { CLI.parse(%w[-k]) }
        it { expect(Dispatcher.new(cli).dispatch).to be_a(Check) }
      end

      context 'when cli contains --list' do
        let(:cli) { CLI.parse(%w[--list]) }
        it { expect(Dispatcher.new(cli).dispatch).to be_a(List) }
      end

      context 'when cli contains --send' do
        let(:cli) { CLI.parse(%w[--send /some/endpoint]) }
        it { expect(Dispatcher.new(cli).dispatch).to be_a(SendData) }
      end

      context 'when cli nothing' do
        let(:cli) { CLI.parse(%w[]) }
        it { expect(Dispatcher.new(cli).dispatch).to be_a(RunServer) }
      end
    end
  end
end
