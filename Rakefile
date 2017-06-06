require 'rubygems'
require 'rake'
require 'rspec/core/rake_task'
require File.expand_path('../lib/rrule', __FILE__)

RSpec::Core::RakeTask.new(:spec)

namespace :spec do
  task :all => ['spec']
end

task :default => 'spec:all'
