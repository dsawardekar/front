# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'front/version'

Gem::Specification.new do |spec|
  spec.name          = "front"
  spec.version       = Front::VERSION
  spec.authors       = ["Darshan Sawardekar"]
  spec.email         = ["darshan@sawardekar.org"]
  spec.description   = %q{Speed up your Vagrant workflow}
  spec.summary       = %q{Booting up a fresh virtual machine takes time. `Front` speeds up VM boot time by preinitializing a pool of VMs. When you need a fresh instance, use `front next` and you are ready to work instantly. And while you work it rebuilds the old VM for your next refill!}
  spec.homepage      = "https://github.com/dsawardekar/front"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake", "~> 10.1.0"
end
