# -*- encoding: utf-8 -*-
# stub: jekyll-theme-hydeout 5.0.2 ruby lib

Gem::Specification.new do |s|
  s.name = "jekyll-theme-hydeout".freeze
  s.version = "5.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "plugin_type" => "theme" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Andrew Fong".freeze]
  s.bindir = "exe".freeze
  s.date = "2025-04-14"
  s.email = ["id@andrewfong.com".freeze]
  s.homepage = "https://github.com/fongandrew/hydeout".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new("~> 3.0".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "The Hyde theme for Jekyll, refreshed.".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<jekyll>.freeze, [">= 4.0", "< 5.0"])
  s.add_runtime_dependency(%q<jekyll-gist>.freeze, ["~> 1.5"])
  s.add_runtime_dependency(%q<jekyll-paginate>.freeze, ["~> 1.1"])
  s.add_runtime_dependency(%q<jekyll-feed>.freeze, ["~> 0.17"])
  s.add_runtime_dependency(%q<jekyll-include-cache>.freeze, ["~> 0.2"])
  s.add_runtime_dependency(%q<jemoji>.freeze, ["~> 0.13"])
  s.add_development_dependency(%q<bundler>.freeze, ["~> 2.6"])
end
