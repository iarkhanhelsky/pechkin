module Pechkin
  module PrometheusUtils # :nodoc:
    class << self
      def registry
        registry = ::Prometheus::Client.registry
        registry.gauge(:pechkin_start_time_seconds,
                       docstring: 'Startup timestamp').set(Time.now.to_i)
        registry
      end
    end
  end
end
