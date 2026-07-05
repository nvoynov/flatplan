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
      # def ==(other)
      #   self.class == other.class && 
      #     constructor_keys.all? { send(it) == other.send(it) }  
      # end

      # Evaluates deep value-based equality between two model objects.
      # Automatically processes nested structures, arrays, and sub-entities.
      #
      # @param other [Object] the objective entity to compare against
      # @return [Boolean] true if classes match and all attribute values are equal
      def ==(other)
        return false unless other.is_a?(self.class)

        # Get all instance variables defined in the current object scope
        self_vars = instance_variables
        other_vars = other.instance_variables

        # Fail-Fast: if the set of internal attributes differs, they are not equal
        return false unless self_vars.sort == other_vars.sort

        # Deeply check each attribute value one by one
        self_vars.all? do |var|
          self_val = instance_variable_get(var)
          other_val = other.instance_variable_get(var)

          deep_equal?(self_val, other_val)
        end
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

      private
      
      # Recursively compares values, handling deep structures like arrays.
      def deep_equal?(val1, val2)
        if val1.is_a?(Array) && val2.is_a?(Array)
          return false unless val1.size == val2.size

          # Zip elements together and evaluate each pair recursively
          val1.zip(val2).all? { |v1, v2| deep_equal?(v1, v2) }
        else
          # Fallback to standard object equality (which invokes our overridden ==
          # if the objects inherit from Model::Base)
          val1 == val2
        end
      end
    end
  end
end
