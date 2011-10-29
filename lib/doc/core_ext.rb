require 'fspath'

class Integer
  def minutes
    60 * self
  end
  alias_method :minute, :minutes

  def hours
    60 * minutes
  end
  alias_method :hour, :hours

  def days
    24 * hours
  end
  alias_method :day, :days

  def weeks
    7 * days
  end
  alias_method :week, :weeks
end

class String
  def underscore
    split(/::/).map{ |part| part.split(/(?=[A-Z])/).join('_') }.join('/').downcase
  end
end

class Module
  def smart_autoload(*names)
    names.each do |name|
      autoload name, "#{self}::#{name}".underscore
    end
  end

  def abstract_method(*names)
    names.each do |name|
      class_eval <<-RUBY, __FILE__, __LINE__
        def #{name}(*_)
          raise NotImplementedError.new("\#{self.class.name} has no implementation for method `#{name}`")
        end
      RUBY
    end
  end
end

class Array
  def select!(&block)
    replace(select(&block))
  end
end

class FSPath
  def touch(atime = nil, mtime = nil)
    open('w'){} unless exist?
    utime(atime ||= Time.now, mtime || atime)
  end

  def rmtree_verbose
    require 'fileutils'
    FileUtils.rm_r(@path, :verbose => true)
  end
end
