# encoding: UTF-8

Gem::Specification.new do |s|
  s.name        = 'doc'
  s.version     = '0.5.0'
  s.summary     = %q{Get all ruby documentation in one place}
  s.description = %Q{Generate `Rakefile` with `docr` and get searchable documentation for ruby, rails, gems, plugins and all other ruby code in one place}
  s.homepage    = "http://github.com/toy/#{s.name}"
  s.authors     = ['Ivan Kuchin']
  s.license     = 'MIT'

  s.rubyforge_project = s.name

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = %w[lib]

  s.add_runtime_dependency 'sdoc', '~> 0.2'
  s.add_runtime_dependency 'fspath', '~> 3.0'
  s.add_runtime_dependency 'progress', '~> 3.0'
  s.add_runtime_dependency 'net-ftp-list'
  s.add_runtime_dependency 'rake'
end
