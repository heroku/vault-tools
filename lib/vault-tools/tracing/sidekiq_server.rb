module Vault
  module Tracing
    # Tracing info for sidekiq
    # This was lifted straight out of heroku/coal_car
    class SidekiqServer
      def initialize(config = nil)
        @config = ZipkinTracer::Config.new(nil, config).freeze
        @tracer = ZipkinTracer::TracerFactory.new.tracer(@config)
      end

      def call(worker, job, _queue)
        result = nil
        id = trace_id(job)
        klass = job["wrapped".freeze] || worker.class.to_s
        ::ZipkinTracer::TraceContainer.with_trace_id(id) do
          if id.sampled?
            @tracer.with_new_span(id, klass) do |span|
              span.record("sidekiq.start")
              result = yield
              span.record("sidekiq.end")
            end
          else
            yield
          end
        end
        ::Trace.tracer.flush! if ::Trace.tracer.respond_to?(:flush!)
        result
      end

      private

      def trace_id(job)
        info = job["zipkin_trace_information"]
        if info
          trace_id = info["trace_id"]
          span_id  = info["span_id"]
          parent_span_id = info["parent_id"]
          sampled = info["sampled"]
          flags = info["flags"].to_i
        else
          trace_id = span_id = ::Trace.generate_id
          parent_span_id = nil
          sampled = sample?
          flags = ::Trace::Flags::EMPTY
        end
        ::Trace::TraceId.new(trace_id, parent_span_id, span_id, sampled, flags)
      end

      def sample?
        rand < @config.sample_rate
      end
    end
  end
end
