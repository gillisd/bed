module Bed
  class Caster
    def self.cast(buildable)
      new(buildable).cast
    end

    def initialize(buildable)
      @buildable = buildable
    end

    def cast
      raise TypeError, "#{@buildable} does not respond to to_h" unless @buildable.respond_to?(:to_h)

      attributes = @buildable.to_h.transform_values do |value|
        case value
        in Hash
          self.class.cast(value)
        in Array
          value.map do |v|
            begin
              self.class.cast(v)
            rescue TypeError
              v
            end
          end
        else
          value
        end
      end

      Data.define(*attributes.keys, &method(:definition)).new(**attributes)
    end

    private

    def definition(instance)
      instance
    end
  end
end