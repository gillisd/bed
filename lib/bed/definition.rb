module Bed
  class Schema
    attr_reader :fields

    def initialize(fields)
      @fields = fields
    end

    def pattern
      fields.map { |_, v| v.is_a?(Schema) ? v.pattern : '_' }.join(', ')
    end
  end

  class Type
    class << self
      attr_reader :schema

      def define(schema)
        @schema = schema
        Data.define(*schema.fields.keys) do

          def initialize(...)
            super
            validate
          end

          define_method(:deconstruct) do
            self.class.schema.fields.keys.map do |key|
              value = public_send(key)
              if value.is_a?(Data) && value.class.respond_to?(:schema)
                value.deconstruct
              else
                value
              end
            end
          end

          define_method(:deconstruct_keys) do |keys = nil|
            keys ||= self.class.schema.fields.keys
            keys.each_with_object({}) do |key, hash|
              if self.class.schema.fields.key?(key)
                value = public_send(key)
                hash[key] = if value.is_a?(Data) && value.class.respond_to?(:schema)
                              value.deconstruct_keys
                            else
                              value
                            end
              end
            end
          end

          define_method(:to_hash) do
            self.class.schema.fields.keys.each_with_object({}) do |key, hash|
              value = public_send(key)
              hash[key] = if value.is_a?(Data) && (value.class.respond_to?(:schema) || value.respond_to?(:to_hash))
                            value.to_hash
                          else
                            value
                          end
            end
          end

          define_method(:validate) do
            pattern = "case self\nin [#{self.class.schema.pattern}]\ntrue\nelse\nfalse\nend"
            eval(pattern)
          end

          # Class variable to store the schema
          class_variable_set(:@@schema, schema)

          # Class method to access the schema
          define_singleton_method(:schema) do
            class_variable_get(:@@schema)
          end
        end
      end
    end
  end

  Field = Data.define(:name, :type, :required, :enable_default, :default_value, :allow_nil) do
    def initialize(name:, type:, required: true, enable_default: false, default_value: nil, allow_nil: false)
      super
    end
  end

  class SchemaBuilder
    attr_reader :fields

    def initialize
      @fields = {}
    end

    Object.constants.each do |const|
      define_method(const) do |field_name, **args|
        define_field(Object.const_get(const), field_name, **args)
      end
    end

    def compile(&block)
      instance_eval(&block)
    end

    def to_schema
      Schema.new(@fields)
    end

    def define_field(type, field_name, required: true, enable_default: false, default_value: nil, allow_nil: false)
      @fields[field_name] = Field.new(name: field_name, type: type, required: required, enable_default: enable_default, default_value: default_value, allow_nil: allow_nil)
    end

    private

    def const_missing(type)
      Object.const_get(type)
    end

    def method_missing(type, *args)
      field_name = args.first
      @fields[field_name] = Object.const_get(type)
    end
  end
end