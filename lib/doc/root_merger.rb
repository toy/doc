module Doc
  class RootMerger < Merger
    def doc_dir
      documentor.public_dir
    end

    def progress_message
      'building docs'
    end

    def run
      super
      if succeeded?
        public_doc_dir = doc_dir / documentor.docs_dir.basename
        public_doc_dir.mkpath
        symlink_children_to(public_doc_dir)
      end
    end
  end
end
