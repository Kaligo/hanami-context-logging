module ContextLogger
  class WithContext < Hanami::Logger::Formatter
    def self.eligible?(name)
      name == :with_context
    end

    attr_writer :context_provider, :ad_hoc_context

    private

    def _format(hash)
      "#{_line_front_matter(hash.delete(:app), hash.delete(:severity), hash.delete(:time), *formatted_contexts)}#{SEPARATOR}#{_format_message(hash)}" # rubocop:disable Layout/LineLength
    end

    def formatted_contexts
      contexts.map { |k, v| "#{k}=#{v}" }
    end

    def contexts
      provider_context = if @context_provider.context.is_a?(Hash)
                           @context_provider.context
                         else
                           @context_provider.context.to_h
                         end
      {}.merge(
        provider_context,
        @ad_hoc_context
      )
    end
  end
end
