# -*- encoding: utf-8 -*-
# stub: xcpretty-json-formatter 0.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "xcpretty-json-formatter".freeze
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Marcelo Fabri".freeze]
  s.date = "2016-08-27"
  s.description = "Custom formatter for xcpretty that saves on a JSON file all the errors, warnings and test failures, so you can process them easily later.".freeze
  s.email = ["me@marcelofabri.com".freeze]
  s.executables = ["xcpretty-json-formatter".freeze]
  s.files = ["bin/xcpretty-json-formatter".freeze]
  s.homepage = "https://github.com/marcelofabri/xcpretty-json-formatter".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.7.4".freeze
  s.summary = "xcpretty custom formatter for JSON output".freeze

  s.installed_by_version = "2.7.4" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<xcpretty>.freeze, [">= 0.0.7", "~> 0.2"])
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.11"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0"])
      s.add_development_dependency(%q<rubocop>.freeze, ["~> 0.38"])
    else
      s.add_dependency(%q<xcpretty>.freeze, [">= 0.0.7", "~> 0.2"])
      s.add_dependency(%q<bundler>.freeze, ["~> 1.11"])
      s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_dependency(%q<rspec>.freeze, ["~> 3.0"])
      s.add_dependency(%q<rubocop>.freeze, ["~> 0.38"])
    end
  else
    s.add_dependency(%q<xcpretty>.freeze, [">= 0.0.7", "~> 0.2"])
    s.add_dependency(%q<bundler>.freeze, ["~> 1.11"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.0"])
    s.add_dependency(%q<rubocop>.freeze, ["~> 0.38"])
  end
end
