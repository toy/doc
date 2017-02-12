module Doc
  class Merger < BaseTask
    attr_reader :tasks
    def initialize(documentor, options)
      super
      @tasks = options[:tasks].uniq

      @config = {
        :title => title,
        :dir_name => dir_name,
        :tasks => tasks.map(&:config),
      }
    end

    state_methods :failed, <<-RUBY
      tasks.map(&:failed?)
    RUBY

    def progress_message
      title
    end

    def run
      tasks.with_progress(progress_message).each do |task|
        Progress.note = task.dir_name
        task.run
      end
      super(failed_state_changed? || tasks.any?(&:succeeded?))
      write_failed_state if succeeded?
    end

    def build
      $stderr.puts "Merging #{title}"

      succeded_tasks = tasks.reject(&:failed?)
      task_titles = succeded_tasks.map{ |task| task.title.gsub(',', '_') }
      task_urls = succeded_tasks.map{ |task| task_url(task) }

      cmd = Command.new('sdoc-merge', "_#{loaded_gem_version('sdoc')}_")
      cmd.add "--op=#{doc_dir}"
      cmd.add "--title=#{title}"
      cmd.add "--names=#{task_titles.join(',')}"
      cmd.add "--urls=#{task_urls.join(' ')}"
      cmd.add *succeded_tasks.map(&:doc_dir)

      cmd.run
    end

    def task_url(task)
      task.doc_dir.relative_path_from(doc_dir)
    end

    def symlink_children_to(path)
      tasks.reject(&:failed?).each do |task|
        task.symlink_to(path)
      end
    end

    def symlink_to(path)
      symlink_children_to(path)
      super
    end
  end
end
