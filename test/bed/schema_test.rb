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
        Float :bar
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
  end
end
