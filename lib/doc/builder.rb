require 'find'

module Doc
  class Builder < BaseTask
    attr_reader :index, :main, :source_dir, :paths
    def initialize(documentor, options)
      super
      @index = options[:index].to_s if options[:index]
      @main = options[:main].to_s if options[:main]
      @source_dir = FSPath(options[:source_dir]).expand_path if options[:source_dir]
      @paths = Array(options[:paths]) if options[:paths]

      unless @source_dir || @paths
        raise 'both source_dir and paths are not set'
      end

      if @paths
        if @source_dir && !options[:no_auto_add_paths]
          children = @source_dir.children.select(&:file?).map(&:basename).map(&:to_s)
          @paths = children.grep(/^((mit-)?license|change(?:s|log)|readme|history|todo|copying|faq|legal)($|\.)/i) | @paths
        end

        if @main
          unless @paths.include?(@main)
            @paths = [@main] | @paths
          end
        else
          %w[^ /].map do |prefix|
            [/#{prefix}readme(?:\.(?:txt|rdoc|markdown|md))?$/i, /#{prefix}readme\./i]
          end.flatten.each do |readme_r|
            break if @main = @paths.grep(readme_r).first
          end
        end

        @paths.select! do |path|
          source_dir ? (source_dir / path).readable? : File.readable?(path)
        end
        @paths.uniq!

        unless @source_dir
          if @source_dir = FSPath.common_dir(*@paths)
            @paths = @paths.map{ |path| FSPath(path).relative_path_from(@source_dir).to_s }
          end
        end
      end

      chdir_source_dir do
        paths_info = []
        if paths
          Find.find(*paths) do |path|
            paths_info << [path, File.size(path), File.mtime(path).to_i]
          end
        end

        @config = {
          :title => title,
          :dir_name => dir_name,
          :index => index,
          :main => main,
          :source_dir => source_dir.to_s,
          :paths => paths_info,
        }
      end
    end

    def build
      cmd = Command.new('sdoc')
      cmd.add '--format=shtml'
      cmd.add '--template=direct'
      cmd.add '--line-numbers'
      cmd.add '--all'
      cmd.add '--charset=utf-8'
      cmd.add '--tab-width=2'
      cmd.add "--title=#{title}"
      cmd.add "--output=#{doc_dir}"
      cmd.add "--main=#{main}" if main
      cmd.add *paths if paths

      chdir_source_dir do
        cmd.run
      end

      if control_files_exist? && index
        index_dir_name = 'custom_index'
        FileUtils.cp_r(index, doc_dir / index_dir_name)
        index_html = doc_dir / 'index.html'
        index_html.write(index_html.read.sub(/(<frame src=")[^"]+(" name="docwin" \/>)/, "\\1#{index_dir_name}/index.html\\2"))
      end
    end

  private

    def chdir_source_dir(&block)
      if source_dir
        Dir.chdir(source_dir, &block)
      else
        block.call
      end
    end
  end
end
