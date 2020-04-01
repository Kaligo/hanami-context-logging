require 'hanami/logger'

require_relative 'formatter/with_context'
require_relative 'formatter/with_context_json'

module HanamiContextLogging
  class Logger < Hanami::Logger
    DEFAULT_APP_NAME ||= 'app'.freeze

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
    def initialize(app_name = default_application_name, *args, options) # rubocop:disable Style/OptionalArguments
      context_provider = options.delete(:context_provider)
      options[:formatter] = options[:formatter] || :with_context # default formatter
      super(app_name, *args, options)

      @formatter.context_provider = context_provider
      @formatter.ad_hoc_context = {}
    end

    # Adds ad hoc context to logger just before it does the logging
    # and removes the ad hoc context after that. This is meant for
    # transient contexts where we want to add context just for the few logs
    #
    # @param context [Hash] the extra context to be logged
    # @param block [Proc] whatever logging that is to be done with this ad hoc context
    # @example add an extra context to log
    # logger = HanamiContextLogging.new(...)
    # logger.with_context(new_context: 'value') do
    #   logger.info 'test log message' #=> will print '[new_context=value] test log message'
    # end
    #
    # logger.info 'test log message' #=> will print just 'test log message'
    def with_context(context)
      @formatter.ad_hoc_context = context
      yield if block_given?
      @formatter.ad_hoc_context = {}
    end

    private

    def default_application_name
      return DEFAULT_APP_NAME unless Hanami.respond_to? (:environment)

      Hanami.environment.project_name
    end
  end
end
