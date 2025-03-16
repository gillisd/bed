# frozen_string_literal: true

# require 'json'
# require 'active_support'
require_relative 'bed/data'
# require_relative 'bed/definition'
# require_relative 'bed/caster'
# require_relative 'bed/flex/builder'
# require_relative "bed/version"

$LOAD_PATH << File.expand_path(__dir__)
autoload :Pathname, 'pathname'
autoload :FileUtils, 'fileutils'
autoload :StringIO, 'stringio'
autoload :JSON, 'json'
autoload :SecureRandom, 'securerandom'

module Bed
  autoload :Schema, 'bed/definition'
  autoload :SchemaBuilder, 'bed/definition'
  autoload :Type, 'bed/definition'
  autoload :Caster, 'bed/caster'
  # autoload :Data, 'bed/data'
  autoload :VERSION, 'bed/version'

  module Flex
    autoload :Builder, 'bed/flex/builder'
  end

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
    return false unless String === str
    str.chars.first == '{' || str.chars.first == '['
  end
end
