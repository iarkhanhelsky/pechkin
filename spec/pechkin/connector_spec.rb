module Pechkin
  describe Connector do
    describe '#post_data' do
      let(:connector) { Connector.new }
      let(:http_url) { 'http://omg.com/api/v1/endpoint' }
      let(:https_url) { 'https://omg.com/api/v1/endpoint' }

      it 'sends data via post request over http' do
        stub_request(:post, http_url)
          .with(body: { 'key' => 'value' }.to_json)
          .to_return(status: 200)
        connector.post_data(http_url, 'key' => 'value')
      end

      it 'sends data via post request over https' do
        stub_request(:post, https_url)
          .with(body: { 'key' => 'value' }.to_json)
          .to_return(status: 200)
        connector.post_data(https_url, 'key' => 'value')
      end

      it 'sets Content-Type to application/json by default' do
        stub_request(:post, https_url)
          .with(body: { 'key' => 'value' }.to_json,
                headers: { 'Content-Type' => 'application/json' })
          .to_return(status: 200)
        connector.post_data(https_url, 'key' => 'value')
      end

      it 'sends provided headers' do
        stub_request(:post, https_url)
          .with(body: { 'key' => 'value' }.to_json,
                headers: { 'Content-Type' => 'text/plain' })
          .to_return(status: 200)
        connector.post_data(https_url, { 'key' => 'value' },
                            headers: { 'Content-Type' => 'text/plain' })

        stub_request(:post, https_url)
          .with(body: { 'key' => 'value' }.to_json,
                headers: { 'Authorization' => 'Bearer 123' })
          .to_return(status: 200)
        connector.post_data(https_url, { 'key' => 'value' },
                            headers: { 'Authorization' => 'Bearer 123' })
      end
    end
  end
end
