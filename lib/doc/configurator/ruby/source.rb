require 'net/ftp'
require 'net/ftp/list'
require 'tempfile'
require 'tmpdir'
require 'timeout'

module Doc
  class Configurator
    class Ruby
      module Source
        def by_binary(binary, update)
          binary = (binary || 'ruby').to_s
          version = VersionSpecifier.new(`#{binary} -e 'print "\#{RUBY_VERSION}-p\#{RUBY_PATCHLEVEL}"'`)
          if $?.success?
            if version.valid?
              version = version.drop unless version < VersionSpecifier.new(2.1)
              by_version(version, update)
            else
              raise "invalid version from `#{binary}`: #{version.to_s.inspect}"
            end
          else
            raise "failed to get version from `#{binary}`"
          end
        end

        def by_version(version, update)
          version = VersionSpecifier.new(version)
          if version.valid?
            if (update && !version.full_version?) || !path_for_version(version)
              download_version(version)
            end
            if path = path_for_version(version)
              path.directory? ? from_dir(path) : from_archive(path)
            else
              raise "can't get ruby #{version}"
            end
          else
            raise "version should be in format X.Y, X.Y.Z or X.Y.Z-pPPP, download archive if you need release candidate or other version"
          end
        end

        def from_archive(path)
          path = FSPath(path)
          if path.file?
            if path.basename.to_s =~ /^(.*)(?i:\.(tar\.(?:gz|bz2)|tgz|tbz|zip))$/
              dir, extension = sources_dir / $1, $2.downcase
              unless dir.exist?
                FSPath.temp_dir 'ruby', sources_dir do |d|
                  begin
                    case extension
                    when 'tbz', 'tar.bz2'
                      Command.run('tar', '-xjf', path, '-C', d)
                    when 'tgz', 'tar.gz'
                      Command.run('tar', '-xzf', path, '-C', d)
                    when 'zip'
                      Command.run('unzip', '-q', path, '-d', d)
                    end

                    children = d.children
                    if children.length == 1
                      children.first.rename(dir)
                    else
                      dir.mkpath
                      FileUtils.mv children, dir
                    end
                  rescue SystemExit => e
                    raise "got #{e} trying to extract archive"
                  end
                end
              end
              from_dir(dir)
            else
              raise "#{path} doesn't seem to be archive of known type"
            end
          else
            raise "#{path} is not a file"
          end
        end

        def from_dir(path)
          path = FSPath(path)
          if path.directory?
            version_path = path / 'version.h'
            if version_path.file? && version_path.read['RUBY_VERSION']
              dot_document_path = path / '.document'
              if dot_document_path.size?
                path.expand_path
              else
                raise "#{path} doesn't contain .document file or it is empty"
              end
            else
              raise "#{path} doesn't contain version.h file or it has no RUBY_VERSION in it"
            end
          else
            raise "#{path} is not a directory"
          end
        end

      private

        def path_for_version(version)
          if path_info = PathInfo.latest_matching(version, sources_dir.children)
            path_info.path
          end
        end

        def tempfile_for(dst)
          FSPath.temp_file_path 'ruby', sources_dir do |path|
            yield path
            path.rename(dst)
          end
        end

        def latest_version_from_tag_list(command, regexp, version)
          IO.popen(command, &:readlines).map do |line|
            if line.strip =~ regexp
              VersionSpecifier.new($1)
            end
          end.compact.sort.grep(version).last
        end

        def tmpdir_for_latest_version_from_tag_list(command, regexp, version)
          if tag_version = latest_version_from_tag_list(command, regexp, version)
            unless path_for_version(tag_version)
              FSPath.temp_dir 'ruby', sources_dir do |d|
                tmp_dir = d / tag_version.dir_name
                if yield(tmp_dir, tag_version)
                  tmp_dir.rename(sources_dir / tag_version.dir_name)
                end
              end
            end
            path_for_version(tag_version)
          end
        end

        def download_version(version)
          download_version_via(:git_pull, version) || download_version_via(:git_tarball, version)
          # git doesn't always have latest version so fast download from there, but verify latest from ftp/svn
          download_version_via(:ftp, version) || download_version_via(:svn, version)
        end

        def download_version_via(type, version)
          $stderr.puts "Checking/downloading ruby #{version} via #{type}"
          Timeout.timeout(90) do
            send("download_version_via_#{type}", version)
          end
        end

        FTP_HOST = 'ftp.ruby-lang.org'
        SVN_TAGS_URL = 'http://svn.ruby-lang.org/repos/ruby/tags/'
        SVN_TAG_LIST_COMMAND = "svn list --non-interactive #{SVN_TAGS_URL}"
        SVN_TAG_REGEXP = /^(v\d+(?:_\d+){2,3})\/$/
        GIT_BARE_URL = 'github.com/ruby/ruby'
        GIT_URL = "git://#{GIT_BARE_URL}.git"
        GIT_TAG_LIST_COMMAND = "git ls-remote -t #{GIT_URL}"
        GIT_TAG_REGEXP = /^.*\t(refs\/tags\/v\d+(?:_\d+){2,3})$/

        def download_version_via_ftp(version)
          Net::FTP.open(FTP_HOST) do |ftp|
            ftp.passive = true
            ftp.login

            ftp_dir = FSPath('/pub/ruby') / version.parts[0, 2].join('.')
            entries = ftp.list(ftp_dir.to_s).map{ |e| Net::FTP::List.parse(e) }
            if archive_info = PathInfo.latest_matching(version, entries.select(&:file?))
              unless path_for_version(archive_info)
                entry = archive_info.path
                tempfile_for(sources_dir / entry.basename) do |f|
                  ftp.getbinaryfile(ftp_dir / entry.basename, f)
                end
              end
              path_for_version(archive_info)
            end
          end
        end

        def download_version_via_svn(version)
          tmpdir_for_latest_version_from_tag_list(SVN_TAG_LIST_COMMAND, SVN_TAG_REGEXP, version) do |tmp_dir, tag_version|
            Command.run *%W[svn export -q --non-interactive #{SVN_TAGS_URL}#{tag_version}/ #{tmp_dir}]
            $?.success?
          end
        rescue SystemExit
        end

        def download_version_via_git_pull(version)
          tmpdir_for_latest_version_from_tag_list(GIT_TAG_LIST_COMMAND, GIT_TAG_REGEXP, version) do |tmp_dir, tag_version|
            tmp_dir.mkpath
            Dir.chdir(tmp_dir) do
              Command.run 'git init -q'
              Command.run *%W[git pull -q --depth=1 #{GIT_URL} #{tag_version}]
              (tmp_dir / '.git').rmtree
            end
            $?.success?
          end
        rescue SystemExit
        end

        def download_version_via_git_tarball(version)
          if tag_version = latest_version_from_tag_list(GIT_TAG_LIST_COMMAND, GIT_TAG_REGEXP, version)
            unless path_for_version(tag_version)
              tempfile_for(sources_dir / "#{tag_version.dir_name}.tgz") do |f|
                Command.run *%W[
                  curl -L -s
                  http://#{GIT_BARE_URL}/tarball/#{tag_version.to_s.split('/').last}
                  -o #{f}
                ]
              end
            end
            path_for_version(tag_version)
          end
        rescue SystemExit
        end
      end
    end
  end
end
