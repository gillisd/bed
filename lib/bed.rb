# frozen_string_literal: true

require 'bed/definition'
require_relative "bed/version"

module Bed
  class Error < StandardError; end

  def self.define(**kwargs)
    schema = Schema.new(kwargs)
    Type.define(schema)
  end

  def self.schema(&block)
    if block_given?
      builder = SchemaBuilder.new
      builder.compile(&block)
      schema = builder.to_schema
      define(**schema.fields)
    else
      self
    end
  end
end