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
  end
end
