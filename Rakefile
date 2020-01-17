# frozen_string_literal: true

require 'rubygems'
require 'rake'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require File.expand_path('lib/rrule', __dir__)

RSpec::Core::RakeTask.new(:spec)

require 'rubocop/rake_task'
RuboCop::RakeTask.new

namespace :spec do
  task all: ['spec']
end

task default: %w[spec:all rubocop]
