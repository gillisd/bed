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

      attributes = @buildable.to_h
                             .deep_symbolize_keys
                             .transform_values do |value|
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

      cache_key = [attributes.keys]

      Thread.current[:__bed_cast_cache] ||= {}
      Thread.current[:__bed_cast_cache][cache_key] ||= (
        Data.define(*attributes.keys, &method(:definition))
      )
      Thread.current[:__bed_cast_cache][cache_key].new(**attributes)
    end

    private

    def definition(instance)
      if instance.respond_to? :to_hash
        instance.alias_method :original_to_hash, :to_hash
      else
        instance.alias_method :original_to_hash, :to_h
      end
      instance.define_method :to_hash do
        original_to_hash.deep_transform_values do |value|
          case value
          in Array
            value.map do |v|
              next(v.to_hash) if value.respond_to? :to_hash
              next(v.to_h) if value.respond_to? :to_h
              v
            end
          else
            next(value.to_hash) if value.respond_to? :to_hash
            next(value.to_h) if value.respond_to? :to_h
            value
          end
        end
      end
    end
  end
end