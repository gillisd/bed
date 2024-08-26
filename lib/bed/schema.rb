class Bed::Schema < Data
  def self.define_with_types(**kwargs)
    puts 'defining...'
    old_kwdargs = kwargs
    kwargs = kwargs.transform_values do |v|
      v.superclass == Data ? v.new : v
    end

    keys = kwargs.keys

    puts kwargs

    init_block = Proc.new do
      define_method :initialize do |args = nil|
        case args
        in Hash
          super(**kwargs.merge(args))
        in Array
          super(kwargs.merge(args))
        else
          super(**kwargs)
        end

        unless args.nil?
          # raise ArgumentError, 'Invalid arguments' unless validate
        end
      end

      alias_method :_deconstruct, :deconstruct

      define_method :deconstruct do
        puts 'deconstructing...'
        val = _deconstruct
        case val
        in *beginning, Class => data, *ending
          [*beginning, *data.deconstruct, *ending]
        in [*rest, Data => data]
          [*rest, *data.deconstruct]
        in [Data => data, *rest]
          [*data.deconstruct, *rest]
        else
          _deconstruct
        end
      end

      alias_method :_deconstruct_keys, :deconstruct_keys

      define_method :deconstruct_keys do |keys = self.class.schema.keys|
        puts keys
        _deconstruct_keys(keys)
        # _deconstruct_keys(keys).transform_values do |v|
        #   v.respond_to?(:deconstruct_keys) ? v.deconstruct_keys(keys) : v
        # end
      end

      define_method :to_hash do
        to_h.transform_values do |v|
          v.respond_to?(:to_hash) ? v.to_hash : v
        end
      end

      define_method :validate do
        arr = self.class.new.deconstruct
        pattern = <<-RUBY
          case self
            in #{arr}
             true
            else
             false
           end
        RUBY
        eval(pattern)
      end

      define_singleton_method :schema do
        old_kwdargs
      end

      define_singleton_method :create_nested_objects do |grouped_data|
        grouped_data.to_a.reverse.reduce(nil) do |inner, (klass, values)|
          args = values.map(&:first)
          args << inner if inner
          klass.new(*args)
        end
      end

      define_singleton_method :go do
        schema.values.map { |v| v.respond_to?(:superclass) && v.superclass == Data ? v.go : self }.flatten
      end

      define_singleton_method :reconstruct do |*args|
        grouped = args.zip(go).group_by(&:last)

        create_nested_objects(grouped)
      end
    end
    Data.define(*keys, &init_block)
  end
end