require 'shellwords'

module Doc
  class Command
    def self.run(*command)
      new(*command).run
    end

    attr_reader :command, :status
    def initialize(*command)
      @command = command
    end

    def add(*arguments)
      @command.concat(arguments)
    end

    def run
      command_string = command.length == 1 ? command.first : command.map(&:to_s).shelljoin
      puts "cd #{Dir.pwd.shellescape}; #{command_string}"
      output = IO.popen("#{command_string} 2>&1", &:read)
      @status = $?
      status.success? || begin
        print output
        case
        when status.signaled?
          if status.termsig == 2
            raise Interrupt.new
          else
            raise SignalException.new(status.termsig)
          end
        when status.exited?
          raise SystemExit.new(status.exitstatus)
        else
          raise status.inspect
        end
      end
    end
  end
end
