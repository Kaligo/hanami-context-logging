class WithContextJson < Hanami::Logger::Formatter
  def self.eligible?(name)
    name == :with_context_json
  end

  def colorizer=(*)
    @colorizer = Hanami::Logger::NullColorizer.new
  end

  attr_writer :context_provider, :ad_hoc_context

  private

  def _format(hash)
    hash[:time] = hash[:time].utc.iso8601
    hash_with_context = hash.merge(contexts)
    Hanami::Utils::Json.generate(hash_with_context) + NEW_LINE
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
