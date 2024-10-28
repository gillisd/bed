# frozen_string_literal: true

require 'test_helper'

class DefinitionTest < Minitest::Test
  def setup
    @definition = Bed.define(foo: String, bar: Integer)
    @object = @definition.new(foo: 'hello', bar: 42)
  end

  class NoNestingTest < DefinitionTest
    def test_attributes
      assert_equal 'hello', @object.foo
      assert_equal 42, @object.bar
    end

    def test_deconstruct
      assert_equal ['hello', 42], @object.deconstruct
    end

    def test_deconstruct_keys
      assert_equal({ foo: 'hello', bar: 42 }, @object.deconstruct_keys(%i[foo bar]))
    end

    def test_to_hash
      assert_equal({ foo: 'hello', bar: 42 }, @object.to_hash)
    end
  end

  class SchemaTest < Minitest::Test
    def setup
      @schema = Bed.schema do
        String :foo
        Float :jaskldjf
      end

      @object = @schema.new(foo: 'hello', bar: 42.0)
    end

    def test_schema
      assert_equal 'hello', @object.foo
      assert_equal 42.0, @object.bar
    end
  end

  class NestedTest < DefinitionTest
    def setup
      super
      @baz_definition = @definition
      @definition = Bed.define(foo: String, bar: Integer, baz: @baz_definition)
      @object = @definition[foo: 'hello', bar: 42, baz: @baz_definition[foo: 'world', bar: 24]]
    end

    def test_attributes
      assert_equal 'hello', @object.foo
      assert_equal 42, @object.bar
      assert_equal 'world', @object.baz.foo
      assert_equal 24, @object.baz.bar
    end

    def test_deconstruct
      assert_equal ['hello', 42, ['world', 24]], @object.deconstruct
    end

    def test_deconstruct_keys
      assert_equal({ foo: 'hello', bar: 42 }, @object.deconstruct_keys(%i[foo bar]))
    end

    def test_to_hash
      assert_equal({ foo: 'hello', bar: 42, baz: { foo: 'world', bar: 24 } }, @object.to_hash)
    end

    def test_nested_schema
      assert_equal 'hello', @object.foo
      assert_equal 42, @object.bar
      assert_equal 'world', @object.baz.foo
      assert_equal 24, @object.baz.bar
    end

    def test_nested_deconstruct
      assert_equal ['hello', 42, ['world', 24]], @object.deconstruct
    end

    def test_nested_deconstruct_keys
      assert_equal({ foo: 'hello', bar: 42 }, @object.deconstruct_keys(%i[foo bar]))
    end

    def test_nested_to_hash
      assert_equal({ foo: 'hello', bar: 42, baz: { foo: 'world', bar: 24 } }, @object.to_hash)
    end
  end

  class SchemaBuilderTest < Minitest::Test
    def setup
      @builder = Bed::SchemaBuilder.new
    end

    def test_constants_are_methods
      assert_respond_to @builder, :String
      assert_respond_to @builder, :Integer
      assert_respond_to @builder, :Float
    end

    def test_constants_are_not_methods_on_other_objects
      refute_respond_to Object.new, :String
      refute_respond_to Object.new, :Integer
      refute_respond_to Object.new, :Float
    end

    def test_define_field
      @builder.define_field(String, :foo)
      @builder.fields => { foo: Bed::Field[type: Class => type, name: :foo] }
      assert_equal(String, type)
    end

    def test_compile
      @builder.compile do
        String :foo
        Integer :bar
      end

      @builder.fields => { foo: Bed::Field[type: Class => type_foo, name: :foo], bar: Bed::Field[type: Class => type_bar, name: :bar] }
      assert_equal(String, type_foo)
      assert_equal(Integer, type_bar)
    end

    def test_to_schema
      @builder.define_field(String, :foo)
      @builder.define_field(Integer, :bar)

      assert_kind_of Bed::Schema, @builder.to_schema
    end

    def test_another_bed
      foo = Bed.flex do
        foo 'bar'
        car 'dar'
        nar do
          some do
            structure 'foo'
          end
        end

      end

      puts foo
    end
  end

  class TestInfer < Minitest::Test
    require 'json'

    def test_infer
    path = '/Users/davidgillis/Desktop/keepa2/0002156121.json'
      # result = Bed.infer_file(path)

      Bed.singleton_class.alias_method :new, :flex
      foo = JSON.load_file(path, {object_class: Bed::Flex::Builder})
      foo

    end

    def test_foo
      klass = Data.define(:foo, :bar)
      bar_klass = Data.define(:count)


    end

    def test_algo
      # I have a class that I put in JSON.load_file(path, {object_class: my_class})
      # to de-serialize json in ruby. The class is instantiated and the []=(name, value)
      # method is called to assign pairs from the json. However, I wish to produce a final product using nested instances of the
      # Data class, which are defined at runtime based on the schema. But setters like []= cannot be called on Data instances,
      # as the instances are immutable, so all data must be initialized up front. I am guessing that this means we must go bottom up from the json tree
      # rather than top down. How can we build an algorithm to do this?



    end
  end
end
