# frozen_string_literal: true
require_relative "lib/bed/version"

Gem::Specification.new do |spec|
  spec.name = "bed"
  spec.version = Bed::VERSION
  spec.platform = Gem::Platform::RUBY  # Add this line
  spec.authors = ["David Gillis"]
  spec.email = ["david.gillis@hey.com"]
  spec.summary = "A simple, modern schema library built on top of Data class"
  spec.description = "Bed is a simple, modern schema library built on top of Data. It provides a simple, declarative way to define schemas for your data, and a way to validate that data against those schemas."
  spec.required_ruby_version = ">= 3.0.0"
  spec.homepage = "https://github.com/gillisd/bed"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.license = "MIT"

  spec.files = Dir.glob([
    "lib/**/*",
    "README.md",
    "LICENSE.txt",
    "*.gemspec"
  ]).reject { |f| File.directory?(f) }
  
  spec.bindir = "exe"
  spec.executables = Dir.glob("exe/*").map { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end