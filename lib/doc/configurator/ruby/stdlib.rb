require 'net/http'
require 'tempfile'
require 'yaml'

module Doc
  class Configurator
    class Ruby
      module Stdlib
        STDLIB_CONFIG_URL = 'http://stdlib-doc.rubyforge.org/svn/trunk/data/gendoc.yaml'
        STDLIB_CONFIG_NAME = 'stdlib-config.yaml'
        STDLIB_CONFIG_VENDOR_PATH = FSPath(__FILE__).dirname / '../../../../vendor' / STDLIB_CONFIG_NAME

        def stdlib_config(update)
          if update || !read_stdlib_config
            download_stdlib_config
          end
          read_stdlib_config || YAML.load_file(STDLIB_CONFIG_VENDOR_PATH)
        end

        def stdlib_config_path
          sources_dir / STDLIB_CONFIG_NAME
        end

        def read_stdlib_config
          YAML.load_file stdlib_config_path if stdlib_config_path.size?
        end

        def download_stdlib_config
          url = URI.parse(STDLIB_CONFIG_URL)
          response = Net::HTTP.start(url.host, url.port){ |http| http.get(url.path) }
          if response.kind_of?(Net::HTTPSuccess)
            stdlib_config_path.write(response.body)
          end
        end
      end
    end
  end
end
