require 'date'
require 'time'

module Flatplan
  module Core
    module Serializable
      def self.included(base)
        base.extend(ClassMethods)
      end

      # Сериализация с использованием паттерн-матчинга
      def to_h
        explicit_args = self.class.initialize_args

        # Собираем плоский хэш по аргументам конструктора
        data_hash = explicit_args.each_with_object({}) do |arg, hash|
          hash[arg] = send(arg) if respond_to?(arg)
        end

        # Лямбда для глубокой рекурсивной сериализации
        deep_h = ->(arg) do
          case arg
          # Проверяем, что это объект нашей сериализуемой модели, а не стандартный Array/Hash
          in Flatplan::Core::Serializable if arg != self
            arg.to_h
          # Сериализация временных типов в ISO 8601 с маркерами
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

        # Глубоко сериализуем собранные данные
        serialized_data = data_hash.transform_values(&deep_h)

        # Вычищаем явные аргументы из метаданных
        clean_metadata = if respond_to?(:metadata) && metadata.is_a?(Hash)
                           metadata.reject { |k, _| explicit_args.include?(k.to_sym) }
                         else
                           {}
                         end

        # Вычисляем относительное имя класса от корня Flatplan
        relative_class_name = self.class.name.sub(/^Flatplan::/, '')

        {
          type: relative_class_name.to_sym,
          data: serialized_data
        }.merge(clean_metadata)
      end

      module ClassMethods
        def initialize_args
          instance_method(:initialize).parameters.map { |_type, name| name }.compact
        end

        # Десериализация полиморфных неймспейсов
        def from_h(hash)
          return nil if hash.nil?

          # Утилита для глубокой рекурсивной символизации ключей (убирает строки навсегда)
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

          # Принудительно превращаем все ключи хэша в символы
          symbolized_hash = symbolize.call(hash)

          # Поиск класса строго внутри корневого модуля Flatplan
          find_class = ->(class_name) do
            full_name = class_name.start_with?('Flatplan::') ? class_name : "Flatplan::#{class_name}"
            Object.const_get(full_name) rescue nil
          end

          # Рекурсивный гидратор (работает только с символами!)
          from_deep_h = ->(arg) do
            case arg
            # 1. Восстановление системных типов
            in { type: :DateTime, value: String => val }
              DateTime.parse(val)
            in { type: :Time, value: String => val }
              Time.parse(val)
            in { type: :Date, value: String => val }
              Date.parse(val)

            # 2. Структура сериализованной модели Flatplan
            in { type: type, data: Hash => data }
              target_klass = find_class.call(type.to_s)
              return arg unless target_klass

              hydrated_data = data.transform_values(&from_deep_h)
              
              metadata_source = arg.reject { |k, _| [:type, :data].include?(k) }
              all_sources = metadata_source.merge(hydrated_data)

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
