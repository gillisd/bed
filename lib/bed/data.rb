module Bed
  if defined?(::Data)
    Data = ::Data
  else
    Data = ::Struct
    Data.class_eval do
      def self.define(*args, &block)
        new(*args, &block)
      end

      def []=(key, value)
        self[key] = value
      end

      def to_data
        self
      end
    end
  end
end

