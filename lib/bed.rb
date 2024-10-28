# frozen_string_literal: true

require 'json'
require 'bed/definition'
require 'bed/caster'
require 'bed/flex/builder'
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

  def self.flex(&block)
    buildable = Flex::Builder.new(&block)
    Caster.cast(buildable)
  end

  def self.infer_file(pathname)
    infer(File.read(pathname))
  end

  def self.infer(inferrable)
    buildable = JSON.parse(inferrable, symbolize_names: true)

    Caster.cast(buildable)
  end
end
