# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "doc"
  s.version = "0.2.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ivan Kuchin"]
  s.date = "2011-10-29"
  s.description = "Generate `Rakefile` with `docr` and get searchable documentation for ruby, rails, gems, plugins and all other ruby code in one place"
  s.executables = ["docr"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.markdown",
    "TODO"
  ]
  s.files = [
    ".tmignore",
    "LICENSE.txt",
    "README.markdown",
    "Rakefile",
    "TODO",
    "VERSION",
    "bin/docr",
    "doc.gemspec",
    "lib/doc.rb",
    "lib/doc/base_task.rb",
    "lib/doc/builder.rb",
    "lib/doc/command.rb",
    "lib/doc/config_error.rb",
    "lib/doc/config_object.rb",
    "lib/doc/configurator.rb",
    "lib/doc/configurator/gems.rb",
    "lib/doc/configurator/paths.rb",
    "lib/doc/configurator/rails.rb",
    "lib/doc/configurator/ruby.rb",
    "lib/doc/configurator/ruby/path_info.rb",
    "lib/doc/configurator/ruby/source.rb",
    "lib/doc/configurator/ruby/stdlib.rb",
    "lib/doc/configurator/ruby/version_specifier.rb",
    "lib/doc/core_ext.rb",
    "lib/doc/documentor.rb",
    "lib/doc/merger.rb",
    "lib/doc/root_config.rb",
    "lib/doc/root_merger.rb",
    "lib/doc/tasks.rb"
  ]
  s.homepage = "http://github.com/toy/doc"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.11"
  s.summary = "Get all ruby documentation in one place"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<sdoc>, ["~> 0.2.0"])
      s.add_runtime_dependency(%q<fspath>, [">= 0"])
      s.add_runtime_dependency(%q<progress>, [">= 0"])
      s.add_runtime_dependency(%q<net-ftp-list>, [">= 0"])
      s.add_runtime_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.5.1"])
      s.add_development_dependency(%q<rake-gem-ghost>, [">= 0"])
    else
      s.add_dependency(%q<sdoc>, ["~> 0.2.0"])
      s.add_dependency(%q<fspath>, [">= 0"])
      s.add_dependency(%q<progress>, [">= 0"])
      s.add_dependency(%q<net-ftp-list>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<jeweler>, ["~> 1.5.1"])
      s.add_dependency(%q<rake-gem-ghost>, [">= 0"])
    end
  else
    s.add_dependency(%q<sdoc>, ["~> 0.2.0"])
    s.add_dependency(%q<fspath>, [">= 0"])
    s.add_dependency(%q<progress>, [">= 0"])
    s.add_dependency(%q<net-ftp-list>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<jeweler>, ["~> 1.5.1"])
    s.add_dependency(%q<rake-gem-ghost>, [">= 0"])
  end
end

