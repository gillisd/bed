# frozen_string_literal: true

require 'test_helper'

class SchemaTest < Minitest::Test
  def setup
    @schema = Bed::Schema.define_with_types(foo: String, bar: Integer)
  end

  def teardown
    # Do nothing
  end

  def test_foo
    subject = @schema.new(foo: 'hello', bar: 42)
    assert_kind_of Data, subject
  end
end
