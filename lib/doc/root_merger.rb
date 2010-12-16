module Doc
  class RootMerger < Merger
    def doc_dir
      documentor.public_dir
    end

    def run
      super
      if succeeded?
        (doc_dir / documentor.docs_dir.basename).make_symlink(documentor.docs_dir.relative_path_from(doc_dir))
      end
    end
  end
end
