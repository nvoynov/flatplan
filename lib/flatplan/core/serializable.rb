require 'date'
require 'time'

module Flatplan
  module Core

    # NOTE: not used but could be helpful in future
    # Model hash paresenter/builder
    module Serializable
      def self.included(base)
        base.extend(ClassMethods)
      end

      def to_h
        explicit_args = self.class.initialize_args

        data_hash = explicit_args.each_with_object({}) do |arg, hash|
          hash[arg] = send(arg) if respond_to?(arg)
        end

        deep_h = ->(arg) do
          case arg
          in Flatplan::Core::Serializable if arg != self
            arg.to_h
          in DateTime
            { type: :DateTime, value: arg.iso8601 }
          in Time
            { type: :Time, value: arg.iso8601 }
          in Date
            { type: :Date, value: arg.iso8601 }
          # Обработка коллекций
          in Array
            arg.map(&deep_h)
          in Hash
            arg.transform_values(&deep_h)
          else
            arg
          end
        end

        serialized_data = data_hash.transform_values(&deep_h)

        relative_class_name = self.class.name.sub(/^Flatplan::/, '')

        {
          type: relative_class_name.to_sym,
          data: serialized_data
        }
      end

      module ClassMethods
        def initialize_args
          instance_method(:initialize).parameters.map { |_type, name| name }.compact
        end

        def from_h(hash)
          return nil if hash.nil?

          symbolize = ->(obj) do
            case obj
            when Hash
              obj.each_with_object({}) { |(k, v), h| h[k.to_sym] = symbolize.call(v) }
            when Array
              obj.map { |el| symbolize.call(el) }
            else
              obj
            end
          end

          symbolized_hash = symbolize.call(hash)

          find_class = ->(class_name) do
            full_name = class_name.start_with?('Flatplan::') ? class_name : "Flatplan::#{class_name}"
            Object.const_get(full_name) rescue nil
          end

          from_deep_h = ->(arg) do
            case arg
            # 1. Восстановление системных типов
            in { type: :DateTime, value: String => val }
              DateTime.parse(val)
            in { type: :Time, value: String => val }
              Time.parse(val)
            in { type: :Date, value: String => val }
              Date.parse(val)

            in { type: type, data: Hash => data }
              target_klass = find_class.call(type.to_s)
              return arg unless target_klass

              positional_values = []
              keyword_values = {}

              target_klass.instance_method(:initialize).parameters.each do |p_type, p_name|
                next unless p_name
                val = all_sources[p_name] || all_sources[p_name.to_s]
                val = from_deep_h.call(val)

                if [:req, :opt, :rest].include?(p_type)
                  positional_values << val
                else
                  keyword_values[p_name] = val
                end
              end

              if keyword_values.empty?
                target_klass.new(*positional_values)
              else
                target_klass.new(*positional_values, **keyword_values)
              end

            # 3. Стандартные коллекции
            in Hash
              arg.transform_values(&from_deep_h)
            in Array
              arg.map(&from_deep_h)
            else
              arg
            end
          end

          from_deep_h.call(symbolized_hash)
        end
      end
    end
  end
end
