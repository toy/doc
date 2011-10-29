require 'doc/core_ext'

module Doc
  smart_autoload :Tasks, :Documentor, :Configurator, :ConfigObject, :RootConfig, :ConfigError
  smart_autoload :BaseTask, :Builder, :Merger, :RootMerger
  smart_autoload :Command
end

%w[gems paths rails ruby].each do |name|
  require "doc/configurator/#{name}"
end
