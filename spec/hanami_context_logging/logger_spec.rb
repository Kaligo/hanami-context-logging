RSpec.describe HanamiContextLogging::Logger do
  let(:mock_context_provider) { double(context: mock_context) }
  let(:mock_context) do
    {
      any_key_1: 'any_value_1',
      any_key_2: 'any_value_2'
    }
  end
  let(:stream) { StringIO.new }

  describe 'with with_context formatter' do
    let(:logger) { described_class.new(stream: stream, formatter: :with_context, context_provider: mock_context_provider) }
    it 'logs message including the context given from provider' do
      logger.info 'random message'

      stream.rewind
      expect(stream.read).to include('any_key_1=any_value_1', 'any_key_2=any_value_2', 'random message')
    end
  end

  describe 'with with_context_json formatter' do
    let(:logger) { described_class.new(stream: stream, formatter: :with_context_json, context_provider: mock_context_provider) }
    it 'logs message including the context given from provider' do
      logger.info 'random message'

      stream.rewind
      expect(JSON.parse(stream.read)).to include('any_key_1' => 'any_value_1', 'any_key_2' => 'any_value_2', 'message' => 'random message')
    end
  end

  describe '#with_context' do
    context 'when block is given' do
      let(:logger) { described_class.new(stream: stream, context_provider: mock_context_provider) }
      it 'logs message including the context given from provider AND the ad hoc context' do
        logger.info 'random message before'

        logger.with_context(additional_context: 'new_value') do
          logger.info 'random message with ad hoc context'
        end

        logger.info 'random message after'

        stream.rewind
        log_lines = stream.read.split("\n")
        expect(log_lines[0]).to include('any_key_1=any_value_1', 'any_key_2=any_value_2', 'random message before')
        expect(log_lines[0]).not_to include('additional_context=new_value', 'random message with ad hoc context')
        expect(log_lines[1]).to include('any_key_1=any_value_1', 'any_key_2=any_value_2', 'additional_context=new_value', 'random message with ad hoc context')
        expect(log_lines[2]).to include('any_key_1=any_value_1', 'any_key_2=any_value_2', 'random message after')
        expect(log_lines[2]).not_to include('additional_context=new_value', 'random message with ad hoc context')
      end
    end

    context 'when block is not given (method chained)' do
      let(:logger) { described_class.new(stream: stream, context_provider: mock_context_provider) }
      it 'logs message including the context given from provider AND the ad hoc context' do
        logger.info 'random message before'

        logger.with_context(additional_context: 'new_value').info 'random message with ad hoc context'

        logger.info 'random message after'

        stream.rewind
        log_lines = stream.read.split("\n")
        expect(log_lines[0]).to include('any_key_1=any_value_1', 'any_key_2=any_value_2', 'random message before')
        expect(log_lines[0]).not_to include('additional_context=new_value', 'random message with ad hoc context')
        expect(log_lines[1]).to include('any_key_1=any_value_1', 'any_key_2=any_value_2', 'additional_context=new_value', 'random message with ad hoc context')
        expect(log_lines[2]).to include('any_key_1=any_value_1', 'any_key_2=any_value_2', 'random message after')
        expect(log_lines[2]).not_to include('additional_context=new_value', 'random message with ad hoc context')
      end
    end
  end
end
