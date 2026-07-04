# lib/flatplan/callable.rb

module Flatplan
  # A mixin interface providing standard invocation sugar for service objects,
  # builders, and command pipelines using modern anonymous forwarding.
  module Callable
    # Instantiates the underlying object and immediately invokes its execution.
    #
    # @param ... [Object] arbitrary positional, keyword, or block arguments
    # @return [Object] the execution result of the instance implementation
    def call(...)
      new.call(...)
    end
  end
end
