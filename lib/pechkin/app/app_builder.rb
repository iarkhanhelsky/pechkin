module Pechkin
  # Application configurator and builder. This creates all needed middleware
  # and stuff
  class AppBuilder
    def build(handler, options)
      logger = create_logger(options.log_dir)
      handler.logger = logger
      app = App.new(logger)
      app.handler = handler
      prometheus = Pechkin::PrometheusUtils.registry

      Rack::Builder.app do
        use Rack::CommonLogger, logger
        use Rack::Deflater
        use Prometheus::Middleware::Collector, registry: prometheus
        # Add Auth check if found htpasswd file or it was excplicitly provided
        # See CLI class for configuration details
        if options.htpasswd
          use Pechkin::Auth::Middleware, auth_file: options.htpasswd
        end
        use Prometheus::Middleware::Exporter, registry: prometheus

        run app
      end
    end

    private

    def create_logger(log_dir)
      if log_dir
        raise "Directory #{log_dir} does not exist" unless File.exist?(log_dir)

        log_file = File.join(log_dir, 'pechkin.log')
        file = File.open(log_file, File::WRONLY | File::APPEND)
        Logger.new(file)
      else
        Logger.new(STDOUT)
      end
    end
  end
end
