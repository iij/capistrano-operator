
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano/operator/version'

Gem::Specification.new do |spec|
  spec.name          = 'capistrano-operator'
  spec.version       = Capistrano::Operator::VERSION
  spec.authors       = ['r-fujimoto','ukida']
  spec.email         = ['r-fujimoto@iij.ad.jp','ukida@iij.ad.jp']

  spec.summary       = %q{semi-automating shell work in maintenance}
  spec.description   = %q{It is a tool for semi-automating shell work in maintenance. Capistrano-operator executes shell commands described by yaml operation files to the host.}
  spec.homepage      = 'https://github.com/iij/capistrano-operator'
  spec.license       = 'MIT'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/iij/capistrano-operator'
  spec.metadata['changelog_uri'] = 'https://github.com/iij/capistrano-operator/blob/master/CHANGELOG.md'
  spec.metadata['documentation_uri'] = 'https://github.com/iij/capistrano-operator/blob/master/README.md'
  spec.metadata['bug_tracker_uri'] = 'https://github.com/iij/capistrano-operator/issues'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f =~ /^docs|^Capfile$|^Gemfile.lock$|^config\/$|^Vagrantfile$/ }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'capistrano', '~> 3.10.0'
  spec.add_dependency 'awesome_print'
  spec.add_dependency 'sshkit-interactive'
  spec.add_dependency 'color_echo'
end
