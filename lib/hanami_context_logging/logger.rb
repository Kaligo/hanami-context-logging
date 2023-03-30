require 'hanami/logger'

require_relative 'formatter/with_context'
require_relative 'formatter/with_context_json'

module HanamiContextLogging
  class Logger < Hanami::Logger
    # A logger that has the same interface as Hanami::Logger, except
    # ContextLogger accepts one more option, called :context_provider
    # context_provider is just any object that responds to #context which returns a hash
    #
    # We first need to extract this option, otherwise Hanami::Logger cannot be initialized due to unrecognized option
    # and pad the formatter to be :with_context by default
    # with_context formatter is a custom formatter that accepts and logs context out.
    # @param app_name [String] app name (defaults to app name)
    # @param *args [any] any arbitrary Logger argument (will just be passed to Hanami::Logger)
    # @param options [Hash] Any Hanami::Logger options
    def initialize(application_name = nil, *args, **kwargs) # rubocop:disable Layout/LineLength
      # rubocop:disable Style/OptionalArguments
      @initializing_arguments = [application_name, args, kwargs]

      options_copy = kwargs.dup

      context_provider = options_copy.delete(:context_provider)
      options_copy[:formatter] ||= :with_context # default formatter
      super(application_name, *args, **options_copy)

      @formatter.context_provider = context_provider
      @formatter.ad_hoc_context = {}
    end

    # Adds ad hoc context to logger just before it does the logging
    # and removes the ad hoc context after that. This is meant for
    # transient contexts where we want to add context just for the few logs
    #
    # @overload with_context(context) { block }
    #   When block is provided, the context will be applied only into the block
    #   @param context [Hash] the extra context to be logged
    #   @param block [Proc] (optional) whatever logging that is to be done with this ad hoc context.
    #
    #   @example add an extra context to log
    #     logger = HanamiContextLogging.new(...)
    #     logger.with_context(new_context: 'value') do
    #       logger.info 'test log message' #=> will print '[new_context=value] test log message'
    #     end
    #
    #     logger.info 'test log message' #=> will print just 'test log message'
    #
    # @overload with_context(context)
    #   When block is not provided, it will return a new instance of logger with the context
    #   This can be used in method chaining to achieve better readability
    #   @param context [Hash] the extra context to be logged
    #
    #   @example add an extra context to log
    #     logger = HanamiContextLogging.new(...)
    #     logger.with_context(new_context: 'value').info 'test log message'
    #     #=> will print '[new_context=value] test log message'
    def with_context(context)
      if block_given?
        @formatter.ad_hoc_context = context
        yield
        @formatter.ad_hoc_context = {}
      else
        initialize_with_context(context)
      end
    end

    private

    def initialize_with_context(context)
      app_name, args, opts = @initializing_arguments

      temp_logger = self.class.new(app_name, *args, **opts)
      temp_logger.instance_eval do
        @formatter.ad_hoc_context = context
      end
      temp_logger
    end

    def default_application_name
      return unless Hanami.respond_to? (:environment)

      Hanami.environment.project_name
    end
  end
end
