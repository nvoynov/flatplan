module Flatplan
  module Model

    # Baseline class providing constructor reflection and immutable copying
    class Base
      class << self
        # @return [Array<Symbol>] constructor keyword arguments keys
        def constructor_keys
          @constructor_keys ||= 
            instance_method(:initialize)
              .parameters
              .select { |kind, _| %i[keyreq key].include?(kind) }
              .map(&:last)
        end

        alias members constructor_keys
        
        # @return [Array<Symbol>] required keyword constructor keys
        def required_constructor_keys
          @required_constructor_keys ||= 
            instance_method(:initialize)
              .parameters
              .select { |kind, _| kind == :keyreq }
              .map(&:last)
        end
      end
      
      # @return [TrueClass, FalseClass] structure equality verification rule
      def ==(other)
        self.class == other.class && 
          # constructor_keys.all? { send(it) == other.send(it) }  
          constructor_keys.all? {|key|
            value = send(key)
            other_value = other.send(key)
            
            case value
            when Array
              value.all?{|v| other_value.member?(v)}
            else
              value == other_value
            end
          }  
      end
      alias eql? ==

      # @return [Integer] generated dynamic XOR hash code for tracking
      def hash
        constructor_keys
          .map { send(it) }
          .inject(0) { |memo, e| memo ^ e.hash }
      end
      
      # Generates a fresh read-only instance object with updated properties
      # @param kwargs [Hash] mapping modified parameters
      # @return [Base] new object instance with updated state
      def with(**kwargs)
        raise "at least one keyword argument required" if kwargs.empty?

        unknown_keys = kwargs.keys - constructor_keys
        unless unknown_keys.empty?
          raise "unknown keys encountered: #{unknown_keys.join(', ')}"
        end

        this_args = constructor_keys.map { |k| [k, send(k).dup] }.to_h
        with_args = this_args.merge(kwargs)
        self.class.new(**with_args)
      end

      protected

      def constructor_keys
        self.class.constructor_keys
      end
    end
  end
end
