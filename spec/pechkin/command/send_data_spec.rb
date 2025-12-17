require 'tempfile'

describe Pechkin::Command::SendData do
  context 'when receives non existend channel and message' do
    it do
      opt = OpenStruct.new(send_data: 'channel/message')
      cmd = Pechkin::Command::SendData.new(opt, stdout: StringIO.new, stderr: StringIO.new)

      expect(cmd).to receive_message_chain(:handler, :message?)
        .with('channel', 'message')
        .and_return(false)

      expect { cmd.execute }.to raise_error(StandardError)
    end
  end

  context 'when data is json string' do
    it do
      opt = OpenStruct.new(send_data: 'channel/message',
                           data: '{"hello":"world"}',
                           preview: false)
      cmd = Pechkin::Command::SendData.new(opt, stdout: StringIO.new, stderr: StringIO.new)
      handler = double

      expect(cmd).to receive(:handler).at_least(:once).and_return(handler)
      expect(handler).to receive(:message?)
        .with('channel', 'message')
        .and_return(true)

      expect(cmd).to receive_message_chain(:handler, :handle)
        .with('channel', 'message', 'hello' => 'world')
        .and_return([])

      cmd.execute
    end
  end

  context 'when preview mode' do
    it do
      opt = OpenStruct.new(send_data: 'channel/message',
                           data: '{"hello":"world"}',
                           preview: true)

      cmd = Pechkin::Command::SendData.new(opt, stdout: StringIO.new, stderr: StringIO.new)
      handler = double

      expect(cmd).to receive(:handler).at_least(:once).and_return(handler)
      expect(handler).to receive(:message?)
        .with('channel', 'message')
        .and_return(true)
      expect(cmd).to receive_message_chain(:handler, :preview)
        .with('channel', 'message', 'hello' => 'world')

      cmd.execute
    end
  end

  context 'when data is path to file' do
    it do
      data_file = Tempfile.new
      data_file.write({ hello: 'world' }.to_json)
      data_file.close

      opt = OpenStruct.new(send_data: 'channel/message',
                           data: "@#{data_file.path}",
                           preview: false)
      cmd = Pechkin::Command::SendData.new(opt, stdout: StringIO.new, stderr: StringIO.new)
      handler = double

      expect(cmd).to receive(:handler).at_least(:once).and_return(handler)
      expect(handler).to receive(:message?)
        .with('channel', 'message')
        .and_return(true)

      expect(cmd).to receive_message_chain(:handler, :handle)
        .with('channel', 'message', 'hello' => 'world')
        .and_return([])

      cmd.execute

      data_file.unlink
    end
  end
end
