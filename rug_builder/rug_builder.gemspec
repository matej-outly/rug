# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
version = File.read(File.expand_path('../../RUG_VERSION', __FILE__)).strip

Gem::Specification.new do |spec|
  spec.name          = "rug_builder"
  spec.version       = version
  spec.authors       = ["Matej Outly (Clockstar s.r.o.)"]
  spec.email         = ["matej@clockstar.cz"]
  spec.summary       = %q{A collection of view builders for Rug}
  spec.description   = %q{Form, table and menu builders.}
  spec.homepage      = "http://www.clockstar.cz"
  spec.license       = "MIT"

  spec.files         = Dir["README.md", "LICENSE.txt", "lib/**/*"]
  spec.require_paths = ["lib"]

  spec.add_dependency "actionview", "~> 4.2"
  spec.add_dependency "truncate_html", "~> 0.9"
end
