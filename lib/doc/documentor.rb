require 'fspath'
require 'progress'

module Doc
  class Documentor
    attr_reader :title, :min_update_interval, :clean_after, :configurators
    attr_reader :base_dir, :sources_dir, :docs_dir, :public_dir
    def initialize(*arguments, &block)
      config = RootConfig.new(self, *arguments, &block)
      @title = config[:title] || 'ruby documentation'
      @min_update_interval = config[:min_update_interval] || 1.hour
      @clean_after = config[:clean_after]
      @configurators = config.configurators

      @base_dir = FSPath('.').expand_path
      @sources_dir = base_dir / 'sources'
      @docs_dir = base_dir / 'docs'
      @public_dir = base_dir / 'public'
    end

    def build(update = false)
      started = Time.now

      last_updated_path = base_dir / '.last_updated'
      update ||= last_updated_path.exist? ? (Time.now > last_updated_path.mtime + min_update_interval) : true

      configurators.with_progress('config/update').each do |configurator|
        configurator.configure(update)
      end
      last_updated_path.touch if update

      root_task = RootMerger.new(self, {
        :title => title,
        :tasks => configurators.with_progress('tasks').map(&:tasks).flatten
      })

      root_task.run

      if clean_after
        (sources_dir.children + docs_dir.children).each do |dir|
          if started - dir.mtime > clean_after
            dir.rmtree_verbose
          end
        end
      end
    end
  end
end
