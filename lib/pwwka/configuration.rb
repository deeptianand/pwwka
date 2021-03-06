require 'bunny'
require 'mono_logger'
module Pwwka
  class ConfigurationError < StandardError; end
  class Configuration

    attr_accessor :rabbit_mq_host
    attr_accessor :topic_exchange_name
    attr_accessor :delayed_exchange_name
    attr_accessor :logger
    attr_accessor :options
    attr_accessor :async_job_klass
    attr_accessor :send_message_resque_backoff_strategy
    attr_accessor :requeue_on_error
    attr_writer   :app_id
    attr_writer   :keep_alive_on_handler_klass_exceptions

    def initialize
      @rabbit_mq_host        = nil
      @topic_exchange_name   = "pwwka.topics.#{Pwwka.environment}"
      @delayed_exchange_name = "pwwka.delayed.#{Pwwka.environment}"
      @logger                = MonoLogger.new(STDOUT)
      @options               = {}
      @send_message_resque_backoff_strategy = [5,                  #intermittent glitch?
                                               60,                 # quick interruption
                                               600, 600, 600] # longer-term outage?
      @requeue_on_error = false
      @keep_alive_on_handler_klass_exceptions = false
      @async_job_klass = Pwwka::SendMessageAsyncJob
    end

    def keep_alive_on_handler_klass_exceptions?
      @keep_alive_on_handler_klass_exceptions
    end

    def app_id
      if @app_id.to_s.strip == ""
        if defined?(Rails)
          if Rails.respond_to?(:application)
            Rails.application.class.parent.name
          else
            raise "'Rails' is defined, but it doesn't respond to #application, so could not derive the app_id; you must explicitly set it"
          end
        else
          raise "Could not derive the app_id; you must explicitly set it"
        end
      else
        @app_id
      end
    end

    def payload_logging
      @payload_logging || :info
    end

    def payload_logging=(new_payload_logging_level)
      @payload_logging = new_payload_logging_level
    end

    def allow_delayed?
      options[:allow_delayed]
    end

  end
end
