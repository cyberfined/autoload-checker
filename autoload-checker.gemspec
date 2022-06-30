# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "autoload-checker"
  spec.version       = '0.1.0'
  spec.authors       = %w[cyberfined]
  spec.email         = %w[cyberfined@protonmail.com]

  spec.summary       = "Checks for conflicts in class/module definitions and corrects them."
  spec.description   = "Checks for conflicts in class/module definitions and corrects them."
  spec.homepage      = "https://github.com/cyberfined/autoload-checker"
  spec.license       = "WTFPL"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match %r{^(spec)/}
  end

  spec.bindir        = "bin"
  spec.executables   = %w[autoload_checker.rb]

  spec.required_ruby_version = ">= 2.5"

  spec.add_development_dependency "bundler", "~> 2.0"
end
