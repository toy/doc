require 'doc/core_ext'

module Doc
  smart_autoload :Tasks, :Documentor, :Configurator, :ConfigObject, :RootConfig, :ConfigError
  smart_autoload :BaseTask, :Builder, :Merger, :RootMerger
  smart_autoload :Command
end

glob_require 'doc/configurator/*.rb'

# TODO: readme!!!
# TODO: kill sdoc_all hehe >:->
