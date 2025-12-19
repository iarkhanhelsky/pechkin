require 'rack/test'
require 'json'
require 'webmock/rspec'
require 'stringio'

module Pechkin
  module Integration
    # Helper module for integration tests
    # Manages Pechkin app lifecycle and provides WebMock stubs for external APIs
    module IntegrationHelper
      include Rack::Test::Methods

      attr_reader :app, :log_output

      # Initialize the Pechkin app with test configuration
      def start_pechkin_server(config_dir:)
        @config_dir = config_dir
        @log_output = StringIO.new

        # Load configuration
        config = Pechkin::Configuration.load_from_directory(config_dir)

        # Build handler from configuration
        handler = Pechkin::Handler.new(config.channels)

        # Create logger that writes to StringIO for testing
        logger = Logger.new(@log_output)
        logger.level = Logger::WARN

        # Build the Rack app
        @app = build_test_app(handler, logger)
      end

      # Clean up (no-op for in-process app, but keep for API compatibility)
      def stop_pechkin_server
        @app = nil
      end

      # Make a POST request to Pechkin using Rack::Test
      def post_to_pechkin(path, data, headers: {})
        post path, data.to_json, { 'CONTENT_TYPE' => 'application/json' }.merge(headers)
        # Wrap response to provide .code method for compatibility
        ResponseWrapper.new(last_response)
      end

      # Wrapper class to make Rack::MockResponse compatible with Net::HTTPResponse API
      class ResponseWrapper
        def initialize(rack_response)
          @response = rack_response
        end

        def code
          @response.status.to_s
        end

        def body
          @response.body
        end

        def [](header)
          @response.headers[header]
        end

        def method_missing(method, *args, &block)
          @response.send(method, *args, &block)
        end

        def respond_to_missing?(method, include_private = false)
          @response.respond_to?(method, include_private)
        end
      end

      # Setup default WebMock stubs for Slack and Telegram APIs
      def setup_default_stubs
        # Allow all Slack and Telegram requests by default with generic responses
        # Tests should override these with specific stubs
        stub_request(:post, %r{https://slack\.com/api/.*})
          .to_return(
            status: 200,
            body: { ok: true }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )

        stub_request(:get, %r{https://slack\.com/api/.*})
          .to_return(
            status: 200,
            body: { ok: true }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )

        stub_request(:post, %r{https://api\.telegram\.org/bot.*/.*})
          .to_return(
            status: 200,
            body: { ok: true }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      # Get the app logs for debugging
      def app_logs
        @log_output ? @log_output.string : ''
      end

      private

      def build_test_app(handler, logger)
        handler.logger = logger
        app = Pechkin::App.new(logger)
        app.handler = handler

        # Build minimal Rack app without prometheus and auth for testing
        Rack::Builder.app do
          use Rack::Deflater
          run app
        end
      end
    end
  end
end
