# frozen_string_literal: true

require 'json'
require 'active_support/all'
require_relative 'bed/data'
require_relative 'bed/definition'
require_relative 'bed/caster'
require_relative 'bed/flex/builder'
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
    infer(pathname)
  end

  def self.infer(inferrable)
    buildable = get_buildable(inferrable)

    Caster.cast(buildable)
  end

  def self.get_buildable(inferrable)
    if looks_like_json?(inferrable)
      return JSON.parse(inferrable, symbolize_names: true)
    end

    case inferrable
    in String
      JSON.load_file(inferrable, symbolize_names: true)
    in Hash
      inferrable
    else
      raise ArgumentError, "inferrable must be a String, Hash, JSON file path, or JSON string"
    end
  end

  def self.looks_like_json?(str)
    str.start_with?('{') || str.start_with?('[')
  end
end
