# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

require 'gnfinder/version'

Gem::Specification.new do |gem|
  gem.name = 'gnfinder'
  gem.homepage = 'http://github.com/GlobalNamesArchitecture/gnfinder'
  gem.version = Gnfinder::VERSION
  gem.authors = ['Dmitry Mozzherin']
  gem.license = 'MIT'
  gem.summary = 'Scientific names finder'
  gem.description = %(The gem searches for scientific names in texts using
                     gRPC server running gnfinder app written in Go language)
  gem.email = 'dmozzherin@gmail.com'

  gem.files         = `git ls-files -z`
                      .split("\x0")
                      .reject { |f| f.match(%r{^(test|spec|features)/}) }

  gem.require_paths = ['lib']
  gem.required_ruby_version = '~> 2.6'
  gem.add_development_dependency 'bundler', '~> 2.0'
  gem.add_development_dependency 'byebug', '~> 10.0'
  gem.add_development_dependency 'grpc', '~> 1.15'
  gem.add_development_dependency 'grpc-tools', '~> 1.15'
  gem.add_development_dependency 'rake', '~> 12.3'
  gem.add_development_dependency 'rspec', '~> 3.8'
  gem.add_development_dependency 'rubocop', '~> 0.59'
end
