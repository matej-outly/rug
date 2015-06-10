# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
version = File.read(File.expand_path('../../RUG_VERSION', __FILE__)).strip

Gem::Specification.new do |spec|
  spec.name          = "rug_record"
  spec.version       = version
  spec.authors       = ["Matej Outly (Clockstar s.r.o.)"]
  spec.email         = ["matej@clockstar.cz"]
  spec.summary       = %q{Databases on Rug}
  spec.description   = %q{Extensions of Rails Active Record.}
  spec.homepage      = "http://www.clockstar.cz"
  spec.license       = "MIT"

  spec.files         = Dir["README.md", "LICENSE.txt", "lib/**/*"]
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", "~> 4.2"
  spec.add_dependency "activerecord-tableless", "~> 1.3" # Full-featured models without database
  spec.add_dependency "ordered-active-record", "~> 0.9" # Linear ordering of models
  spec.add_dependency "awesome_nested_set", "~> 3.0" # Hierarchical ordering of models
  spec.add_dependency "paperclip", "~> 4.2" # File attachments
  spec.add_dependency "queue_classic", "~> 3.0" # Queue Classic
  
  spec.add_dependency "rug_support", version

end
