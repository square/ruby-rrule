Gem::Specification.new do |s|
  s.name = 'rrule'
  s.version = '0.4.1'
  s.date = '2018-04-24'
  s.summary = 'RRule expansion'
  s.description = 'A gem for expanding dates according to the RRule specification'
  s.authors = ['Ryan Mitchell']
  s.email = 'rmitchell@squareup.com'
  s.files = `git ls-files`.split($/)
  s.test_files = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']
  s.homepage = 'http://rubygems.org/gems/rrule'

  # Since Ruby 1.9.2, Time implementation uses a signed 63 bit integer, Bignum
  # or Rational. This enables Time to finally work with years after 2038 which
  # is critical for this library.
  s.required_ruby_version = '>= 1.9.2'
  s.add_runtime_dependency 'activesupport', '>= 4.1'
  s.add_development_dependency 'rspec', '~> 3.4'
end
