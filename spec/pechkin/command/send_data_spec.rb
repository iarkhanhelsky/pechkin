require 'tempfile'

module Pechkin
  module Command
    describe SendData do
      context 'when receives non existend channel and message' do
        it do
          opt = OpenStruct.new(send_data: 'channel/message')
          cmd = SendData.new(opt)

          expect(cmd).to receive_message_chain(:handler, :message?)
            .with('channel', 'message')
            .and_return(false)

          expect { cmd.execute }.to raise_error(StandardError)
        end
      end

      it do
        opt = OpenStruct.new(send_data: 'channel/message',
                             data: '{"hello":"world"}',
                             preview: true)
        cmd = SendData.new(opt)
        handler = double

        expect(cmd).to receive(:handler).at_least(:once).and_return(handler)
        expect(handler).to receive(:message?)
          .with('channel', 'message')
          .and_return(true)
        expect(handler).to receive(:'preview=').with(true)
        expect(cmd).to receive_message_chain(:handler, :handle)
          .with('channel', 'message', 'hello' => 'world')

        cmd.execute
      end

      it do
        data_file = Tempfile.new
        data_file.write({ hello: 'world' }.to_json)
        data_file.close

        opt = OpenStruct.new(send_data: 'channel/message',
                             data: "@#{data_file.path}",
                             preview: true)
        cmd = SendData.new(opt)
        handler = double

        expect(cmd).to receive(:handler).at_least(:once).and_return(handler)
        expect(handler).to receive(:message?)
          .with('channel', 'message')
          .and_return(true)
        expect(handler).to receive(:'preview=').with(true)
        expect(cmd).to receive_message_chain(:handler, :handle)
          .with('channel', 'message', 'hello' => 'world')

        cmd.execute

        data_file.unlink
      end
    end
  end
end
