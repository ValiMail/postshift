# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'postshift/version'

Gem::Specification.new do |spec|
  spec.platform      = Gem::Platform::RUBY
  spec.name          = 'postshift'
  spec.version       = Postshift::VERSION
  spec.authors       = ['Dave Krupinski']
  spec.email         = ['david.krupinski@valimail.com']

  spec.summary       = %q{Amazon Redshift adapter for ActiveRecord 5 and above.}
  spec.description   = %q{Thin ActiveRecord Redshift Adapter extension for existing PostgreSQL adapter.}
  spec.homepage      = 'http://github.com'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.2.2'

  spec.add_dependency 'pg', '~> 0.20.0'
  spec.add_dependency 'activerecord', '>= 5.0'
  spec.add_dependency 'activesupport', '>= 5.0'

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'factory_girl', '~> 4.8.0'
  spec.add_development_dependency 'database_cleaner', '~> 1.6.0'
  spec.add_development_dependency 'appraisal', '~> 2.2.0'
end
