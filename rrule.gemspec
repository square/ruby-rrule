# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rrule/version'

Gem::Specification.new do |s|
  s.name = 'rrule'
  s.version = RRule::VERSION
  s.summary = 'RRule expansion'
  s.description = 'A gem for expanding dates according to the RRule specification'
  s.authors = ['Ryan Mitchell']
  s.email = 'rmitchell@squareup.com'
  s.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  s.require_paths = ['lib']
  s.homepage = 'http://rubygems.org/gems/rrule'

  s.required_ruby_version = '>= 2.3.0'
  s.add_runtime_dependency 'activesupport', '>= 4.1'
  s.add_development_dependency 'rspec', '~> 3.4'
end
