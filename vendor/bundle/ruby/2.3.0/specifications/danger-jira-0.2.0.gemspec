# -*- encoding: utf-8 -*-
# stub: danger-jira 0.2.0 ruby lib

Gem::Specification.new do |s|
  s.name = "danger-jira".freeze
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["RestlessThinker".freeze]
  s.date = "2017-11-22"
  s.description = "A Danger plugin to link JIRA issues to a pull request.".freeze
  s.email = ["penaflor@gmail.com".freeze]
  s.homepage = "https://github.com/RestlessThinker/danger-jira".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.7.4".freeze
  s.summary = "A Danger plugin to link JIRA issues to a pull request.".freeze

  s.installed_by_version = "2.7.4" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<danger-plugin-api>.freeze, ["~> 1.0"])
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.3"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 3.4"])
      s.add_development_dependency(%q<rubocop>.freeze, ["~> 0.48.1"])
      s.add_development_dependency(%q<yard>.freeze, ["~> 0.8"])
      s.add_development_dependency(%q<guard>.freeze, ["~> 2.14"])
      s.add_development_dependency(%q<guard-rspec>.freeze, ["~> 4.7"])
      s.add_development_dependency(%q<listen>.freeze, ["= 3.0.7"])
      s.add_development_dependency(%q<pry>.freeze, [">= 0"])
    else
      s.add_dependency(%q<danger-plugin-api>.freeze, ["~> 1.0"])
      s.add_dependency(%q<bundler>.freeze, ["~> 1.3"])
      s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_dependency(%q<rspec>.freeze, ["~> 3.4"])
      s.add_dependency(%q<rubocop>.freeze, ["~> 0.48.1"])
      s.add_dependency(%q<yard>.freeze, ["~> 0.8"])
      s.add_dependency(%q<guard>.freeze, ["~> 2.14"])
      s.add_dependency(%q<guard-rspec>.freeze, ["~> 4.7"])
      s.add_dependency(%q<listen>.freeze, ["= 3.0.7"])
      s.add_dependency(%q<pry>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<danger-plugin-api>.freeze, ["~> 1.0"])
    s.add_dependency(%q<bundler>.freeze, ["~> 1.3"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.4"])
    s.add_dependency(%q<rubocop>.freeze, ["~> 0.48.1"])
    s.add_dependency(%q<yard>.freeze, ["~> 0.8"])
    s.add_dependency(%q<guard>.freeze, ["~> 2.14"])
    s.add_dependency(%q<guard-rspec>.freeze, ["~> 4.7"])
    s.add_dependency(%q<listen>.freeze, ["= 3.0.7"])
    s.add_dependency(%q<pry>.freeze, [">= 0"])
  end
end
