module Bed
  module Flex
    class Builder
      def initialize(*args, **kwargs, &blk)
        @whitelisted_attributes = []
        @attributes = {}
        @locked = false
        @converged = false
        result = if block_given?
                   block = blk
                   if block.arity.zero?
                     instance_eval(&block)
                   else
                     yield self
                   end
                 end

        converge(result) if should_converge?(result)
        @locked = true
      end

      def converge(value)
        @converged = true
        @attributes[:_converged] = value
      end

      def get(path)
        path.to_s.split('.').inject(self) { |obj_self, attr| obj_self.public_send(attr) }
      end

      def to_h
        return @attributes[:_converged] if @converged
        @attributes.transform_values { |v| v.is_a?(Builder) ? v.to_h : v }
      end

      # alias_method :inspect, :to_h
      alias_method :to_s, :to_h

      def deep_dup
        self.class.new.tap do |new_builder|
          @attributes.each do |key, value|
            new_builder.send(:"#{key}=", value.is_a?(Builder) ? value.deep_dup : value.dup)
          end
        end
      end

      def pretty_print(pp)
        pp.object_address_group(self) do
          pp.seplist(@attributes, -> { pp.text ',' }) do |k, v|
            pp.breakable
            pp.group(1) do
              pp.text k.to_s
              pp.text ':'
              pp.breakable
              pp.pp v
            end
          end
        end
      end

      private alias_method :old_inspect, :inspect

      def inspect
        case @attributes
        in {} then '{}'
        in { _converged: value } then value
        else
          old_inspect
        end
      end

      # def to_ary
      #   [to_h]
      # end
      def []=(name, value)
        set_attribute(name, value)
      end

      private

      def should_converge?(result)
        case [@attributes, result]
          # E.g.
          # b.foo do
          #   b.bar 'a string'
          # end
        in {}, Builder | nil then false
        # E.g.
        # b.foo do
        #   'a string'
        # end
        in {}, _ then true
        else false
        end
      end

      def respond_to_missing?(name, include_private = false)
        return false if name == :to_ary
        @whitelisted_attributes.empty? || @whitelisted_attributes.include?(name) || super
      end

      def method_missing(name, *args, &block)
        return super if !@whitelisted_attributes.empty? && !@whitelisted_attributes.include?(name)

        if name.end_with?('=')
          attribute_name = name.to_s.chomp('=').to_sym
          set_attribute(attribute_name, args.first)
        else
          get_or_set_attribute(name, *args, &block)
        end
      end

      def to_ary
        [inspect]
      end

      def get_or_set_attribute(name, *args, &block)
        if args.empty? && !block
          value = @attributes[name]

          if value.nil? && @locked
            raise NoMethodError, "#{name} is not defined"
          end
        else
          value = if block
                    if block.arity == 0
                      args.size > 0 ? [*args,->{Builder.new(&block)}] : Builder.new(&block)
                    else
                      Builder.new.tap { |b| block.call(b) }
                    end
                  else
                    args.size == 1 ? args.first : args
                  end
          set_attribute(name, value)
        end
      end

      def set_attribute(name, value)
        @attributes[name.to_sym] = value

        define_attribute_method(name)
        self
      end

      def define_attribute_method(name)
        singleton_class.define_method(name) do |*args, &block|
          if args.empty? && !block
            name.to_s
            @attributes[name]
          else
            get_or_set_attribute(name, *args, &block)
          end
        end
      end
    end
  end
end