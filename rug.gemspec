# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
version = File.read(File.expand_path('../RUG_VERSION', __FILE__)).strip

Gem::Specification.new do |spec|
  spec.name          = "rug"
  spec.version       = version
  spec.authors       = ["Matej Outly (Clockstar s.r.o.)"]
  spec.email         = ["matej@clockstar.cz"]
  spec.summary       = %q{Rails framewirk extension}
  spec.description   = %q{This gem is only configurable wrapper for other gems which Rug framework consists of.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = Dir["README.md", "LICENSE.txt", "lib/**/*", "bin/**/*"]
  spec.executables   = []
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", "~> 4.2"

  spec.add_dependency "rug_support", version
  spec.add_dependency "rug_record", version
  spec.add_dependency "rug_builder", version

end
