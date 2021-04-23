# frozen_string_literal: true

require_relative 'lib/renamespace/version'

Gem::Specification.new do |spec|
  spec.name          = 'renamespace'
  spec.version       = Renamespace::VERSION
  spec.authors       = ['Brendan Weibrecht']
  spec.email         = ['brendan@weibrecht.net.au']

  spec.summary       = 'A command-line tool to help Ruby developers refactor class/module namespacing'
  spec.homepage      = 'https://github.com/greensync/renamespace'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.5.0')

  spec.metadata['allowed_push_host'] = 'https://rubygems.pkg.github.com/greensync'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/releases"

  spec.license = 'Nonstandard'

  spec.files = Dir.glob(
    %w[
      exe/**/*
      lib/**/*
      README.md
    ]
  )
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'clamp', '~> 1.3.2'
  spec.add_dependency 'facets', '~> 3.1.0'
  spec.add_dependency 'rainbow', '~> 3.0.0'

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
