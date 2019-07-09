# -*- encoding: utf-8 -*-
# stub: danger-slather 0.0.6 ruby lib

Gem::Specification.new do |s|
  s.name = "danger-slather".freeze
  s.version = "0.0.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Bruno Mazzo".freeze]
  s.date = "2016-11-28"
  s.description = "Danger plugin to Slather code coverage framework".freeze
  s.email = ["mazzo.bruno@gmail.com".freeze]
  s.homepage = "https://github.com/BrunoMazzo/danger-slather".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.7.4".freeze
  s.summary = "A Danger plugin that show code coverage of the project and by file. Add warnings or fail the build if a minimum coverage are not achieved. It uses Slather Framework for calculate coverage, so it's required to configurate the slather object before using it.".freeze

  s.installed_by_version = "2.7.4" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<danger-plugin-api>.freeze, ["~> 1.0"])
      s.add_runtime_dependency(%q<slather>.freeze, ["~> 2.3"])
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.3"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 3.4"])
      s.add_development_dependency(%q<mocha>.freeze, ["~> 1.2"])
      s.add_development_dependency(%q<rubocop>.freeze, ["~> 0.41"])
      s.add_development_dependency(%q<yard>.freeze, ["~> 0.8"])
      s.add_development_dependency(%q<guard>.freeze, ["~> 2.14"])
      s.add_development_dependency(%q<guard-rspec>.freeze, ["~> 4.7"])
      s.add_development_dependency(%q<listen>.freeze, ["= 3.0.7"])
      s.add_development_dependency(%q<pry>.freeze, ["~> 0.9"])
    else
      s.add_dependency(%q<danger-plugin-api>.freeze, ["~> 1.0"])
      s.add_dependency(%q<slather>.freeze, ["~> 2.3"])
      s.add_dependency(%q<bundler>.freeze, ["~> 1.3"])
      s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_dependency(%q<rspec>.freeze, ["~> 3.4"])
      s.add_dependency(%q<mocha>.freeze, ["~> 1.2"])
      s.add_dependency(%q<rubocop>.freeze, ["~> 0.41"])
      s.add_dependency(%q<yard>.freeze, ["~> 0.8"])
      s.add_dependency(%q<guard>.freeze, ["~> 2.14"])
      s.add_dependency(%q<guard-rspec>.freeze, ["~> 4.7"])
      s.add_dependency(%q<listen>.freeze, ["= 3.0.7"])
      s.add_dependency(%q<pry>.freeze, ["~> 0.9"])
    end
  else
    s.add_dependency(%q<danger-plugin-api>.freeze, ["~> 1.0"])
    s.add_dependency(%q<slather>.freeze, ["~> 2.3"])
    s.add_dependency(%q<bundler>.freeze, ["~> 1.3"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.4"])
    s.add_dependency(%q<mocha>.freeze, ["~> 1.2"])
    s.add_dependency(%q<rubocop>.freeze, ["~> 0.41"])
    s.add_dependency(%q<yard>.freeze, ["~> 0.8"])
    s.add_dependency(%q<guard>.freeze, ["~> 2.14"])
    s.add_dependency(%q<guard-rspec>.freeze, ["~> 4.7"])
    s.add_dependency(%q<listen>.freeze, ["= 3.0.7"])
    s.add_dependency(%q<pry>.freeze, ["~> 0.9"])
  end
end
