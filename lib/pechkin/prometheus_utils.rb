module Pechkin
  module PrometheusUtils # :nodoc:
    class << self
      def registry
        registry = ::Prometheus::Client.registry
        registry.gauge(:pechkin_start_time_seconds,
                       docstring: 'Startup timestamp').set(Time.now.to_i)

        version_labels = { version: Pechkin::Version.version_string }
        registry.gauge(:pechkin_version,
                       docstring: 'Pechkin version', labels: [:version])
                .set(1, labels: version_labels)

        registry
      end
    end
  end
end
