# frozen_string_literal: true

require_relative "lib/bed/version"

Gem::Specification.new do |spec|
  spec.name = "bed"
  spec.version = Bed::VERSION
  spec.authors = ["David Gillis"]
  spec.email = ["david.gillis@hey.com"]

  spec.summary = "A simple, modern schema library built on top of Data"
  spec.description = "Bed is a simple, modern schema library built on top of Data. It provides a simple, declarative way to define schemas for your data, and a way to validate that data against those schemas."
  spec.required_ruby_version = ">= 3.0.0"
  spec.homepage = "https://github.com/gillisd/bed"
  spec.metadata["homepage_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.license = "MIT"
end
