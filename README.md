# Hanami::Context::Logging

### What is this?
This is a modification on top of Hanami::Logger to allow context logging.

### What is context logging?
It's simply, logging the context or state of the application/processes without having to define it every time. Below is an example:
Without context logging:
```
logger.info "[controller=#{self.class}] [user_id#{user.id}] Error during user update"
# => "[controller=UserUpdate] [user_id=user123] Error during user update"
```

With context logging
```
MyContextProvider.context # => { controller: self.class, user_id: user.id }
logger = HanamiContextLogging::Logger.new(context_provider: MyContextProvider)

...

logger.info "Error during user update"
# => "[controller=UserUpdate] [user_id=user123] Error during user update"
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hanami-context-logging'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install hanami-context-logging

## Usage

### About context_provider
context_provider is simply any object that responds to `#context` which returns a hash. The below are all valid context providers

**Struct**
```
ContextProviderStruct = Struct.new(:context)
provider = ContextProviderStruct.new(a_context: 'a_value')
provider.context # returns context, all good
```

**Class**
```
class ContextProviderClass
  def self.context
    { a_context: 'a_value' }
  end
end
provider = ContextProviderClass
provider.context # returns context, all good
```

**Object**
```
class ContextProviderClass
  def context
    { a_context: 'a_value' }
  end
end
provider = ContextProviderClass.new
provider.context # returns context, all good
```

The logger allows you to define your own context provider. A use case for context provider is when the context is not yet known during initialization, but will be known during logging. For example
```
# request_context_provider.rb
class RequestContextProvider
  def self.context
    { request_id: request.env['HTTP_X_REQUEST_ID'] } # read some request environment headers
  end
end

# environment.rb
logger HanamiContextLogging::Logger.new(context_provider: RequestContextProvider) # during initialization, we are not receiving any http requests, so there is no context yet

# request_controller.rb
Hanami.logger.info "Request accepted"
# => "[request_id=id123] Request accepted"
```

### Transient contexts

This context logger also provides a method `with_context` to add transient contexts. You can use a block, where the context will be applied to only in the block
```
logger = HanamiContextLogging::Logger.new

logger.with_context(controller: self.class, user_id: user.id) do
  logger.info "Error during user update"
end
# => "[controller=UserUpdate] [user_id=user123] Error during user update"

logger.info "Should have no context here"
# => "Should have no context here"
```

or the syntatic-sugar method chain, where you can method-chain with your usual logger methods (info, error, etc)
```
logger = HanamiContextLogging::Logger.new

logger.with_context(controller: self.class, user_id: user.id).info "Error during user update"
# => "[controller=UserUpdate] [user_id=user123] Error during user update"

logger.info "Should have no context here"
# => "Should have no context here"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sswander/hanami-context-logging. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/sswander/hanami-context-logging/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Hanami::Context::Logging project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/sswander/hanami-context-logging/blob/master/CODE_OF_CONDUCT.md).
