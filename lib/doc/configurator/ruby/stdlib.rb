require 'net/http'
require 'tempfile'
require 'yaml'

module Doc
  class Configurator
    class Ruby
      module Stdlib
        STDLIB_CONFIG_URL = 'http://stdlib-doc.rubyforge.org/svn/trunk/data/gendoc.yaml'

        def stdlib_config(update)
          if update || !read_stdlib_config
            download_stdlib_config
          end
          read_stdlib_config
        end

        def stdlib_config_path
          sources_dir / 'stdlib-config.yaml'
        end

        def read_stdlib_config
          YAML.load_file stdlib_config_path if stdlib_config_path.readable?
        end

        def download_stdlib_config
          stdlib_config_path.write(Net::HTTP.get(URI.parse(STDLIB_CONFIG_URL)))
        end
      end
    end
  end
end
