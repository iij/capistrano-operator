
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano/operator/version'

Gem::Specification.new do |spec|
  spec.name          = 'capistrano-operator'
  spec.version       = Capistrano::Operator::VERSION
  spec.authors       = ['r-fujimoto','ukida']
  spec.email         = ['r-fujimoto@iij.ad.jp','ukida@iij.ad.jp']

  spec.summary       = %q{Capistrano semi-automate operation tool}
  spec.description   = %q{Providing semi-automate operation in maintenance while checking commands to be executed.}
  spec.homepage      = 'https://github.com/iij/capistrano-operator'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://github.com/iij/capistrano-operator'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f =~ /^docs|^Capfile$|^Gemfile.lock$|^config\/$|^Vagrantfile$/ }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'capistrano', '~> 3.10.0'
  spec.add_dependency 'awesome_print'
  spec.add_dependency 'sshkit-interactive'
  spec.add_dependency 'color_echo'
end
