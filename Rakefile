require 'rake'
require 'jeweler'
require 'rake/gem_ghost_task'

name = 'doc'

Jeweler::Tasks.new do |gem|
  gem.name = name
  gem.summary = %Q{Documentation for everything}
  gem.description = %Q{Command line tool to get searchable documentation for ruby, rails, gems, plugins and other ruby related code in one place}
  gem.homepage = "http://github.com/toy/#{name}"
  gem.license = 'MIT'
  gem.authors = ['Ivan Kuchin']
  gem.add_development_dependency 'jeweler', '~> 1.5.1'
  gem.add_development_dependency 'rake-gem-ghost'
end
Jeweler::RubygemsDotOrgTasks.new
Rake::GemGhostTask.new
