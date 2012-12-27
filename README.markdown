# doc

Get searchable documentation for ruby, rails, gems, plugins and all other ruby code in one place.

Successor of [sdoc_all](https://github.com/toy/sdoc_all).

## Usage

    sudo gem install doc
    docr <place for your documentation>; cd <place for your documentation>
    <your favorite editor> Rakefile
    rake build
    open public/index.html # that's true for mac

## Config

    doc.title 'ruby, rails, gems'
    doc.min_update_interval 1.week
    doc.clean_after 1.day
    doc.public_dir 'pub'

    doc.ruby 'ruby', 'ruby1.9', :except => %w[win32ole tk], :index => 'ruby_quick_ref'
    doc.rails 2, 3, :prerelease => true
    doc.gems :except => %w[
      mysql
      rails railties actionmailer actionpack activemodel activerecord activeresource activesupport
      yard keychain_services msgpack doc
    ], :prerelease => true
    doc.paths '~/.plugins/*', :main => 'README*', :file_list => %w[+lib +README* +CHANGELOG*], :title => proc{ |path| "plugin #{path.basename}" }
    doc.paths '~/var/ruby', :file_list => %w[+**/*.rb -_arc]

### Global options

- `title` for documentation title, default is 'ruby documentation'
- `min_update_interval` — time between code updates, now used only for ruby source, default is 1 hour
- `clean_after` — delete old generated documentation after this period of time, by default it is not set and no cleaning is made
- `public_dir` — specify custom dir for final documentation, 'public' by default

`ruby`, `rails`, `gems`, `paths` — documentation configurators, below their options are explained, all configurators have default option which can be specified without key syntax

`gem` and `path` are just aliases to `gems` and `paths`

### ruby

Specify what to document using:

- `source` — path to ruby source
- `archive` — path to archive with ruby source (bzipped tar, gzipped tar or zip)
- `version` — ruby version in form X.Y, X.Y.Z or X.Y.Z-pPPP. Source will be downloaded from github.com/ruby/ruby or ruby-lang.org
- `binary` — command which is asked to run code to automatically determine ruby version. Source will be downloaded as for version specifier

All those specifiers accepts multiple entries. Default option is `binary`, 'ruby' binary is used if version is not specified.

Other options:

- `format` — can be `:all` to simply document all code, `:separate` to build core documentation and stdlib documentation separately and `:integrate` to integrate all stdlib to core
- `except` — skip documenting certain parts (like `win32ole` and `tk`)
- `index` — specify folder containing index.html to replace front page. Good place for cheat sheet or quick ref like one downloaded from [zenspider](http://www.zenspider.com/Languages/Ruby/QuickRef.html).

### rails

Specify version(s) of rails to document using `:version`. Can be any part of version: 3, '3.0', '3.0.1'. That is default option so you can skip key. If version is not specified, latest found in installed gems will be used.

Use `:prerelease => true` to document prerelease versions.

### gems

Use `:only` to document only certain gems or use `:except` to skip them from being documented. `:only` is the default option.

Use `:versions => :all` if you want to document all installed versions.

Use `:prerelease => true` to document prerelease versions.

### paths

Default option is `:glob`. Specify list of globs (or paths), documentation will be created for every path matched by glob.

Use `:main` to specify main file. It is a list of file names, first one found at path will be used.

Use `:file_list` to filter what to document. It can be an Array of glob string prefixed with + and - to exclude or include or a proc receiving instance of Rake::FileList.

Use `:title` to specify title, it must be a proc receiving path and returning title.

## Copyright

Copyright (c) 2010-2011 Ivan Kuchin. See LICENSE.txt for details.
