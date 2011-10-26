require 'rake'
require 'jeweler'
require 'rake/gem_ghost_task'

name = 'doc'

Jeweler::Tasks.new do |gem|
  gem.name = name
  gem.summary = %Q{Get all ruby documentation in one place}
  gem.description = %Q{Generate `Rakefile` with `docr` and get searchable documentation for ruby, rails, gems, plugins and all other ruby code in one place}
  gem.homepage = "http://github.com/toy/#{name}"
  gem.license = 'MIT'
  gem.authors = ['Ivan Kuchin']

  gem.add_runtime_dependency 'sdoc', '~> 0.2.0'
  gem.add_runtime_dependency 'fspath'
  gem.add_runtime_dependency 'progress'
  gem.add_runtime_dependency 'net-ftp-list'
  gem.add_runtime_dependency 'rake'

  gem.add_development_dependency 'jeweler', '~> 1.5.1'
  gem.add_development_dependency 'rake-gem-ghost'
end
Jeweler::RubygemsDotOrgTasks.new
Rake::GemGhostTask.new
