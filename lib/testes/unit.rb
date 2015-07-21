module Testes
  class Unit
    attr_reader :file_path, :stdout, :stderr, :rvm_context

    def initialize(file_path, options = {})
      @rvm_context = options[:rvm_context]
      @file_path = file_path
      reset
    end

    def reset
      @stdout = []
      @stderr = []
      @complete = false
      @passing = false
    end

    def run
      color_print :cyan, file_path
      color_print :blue, " => "

      command = ['ruby', file_path]
      command.unshift(*['rvm', 'in', rvm_context, 'do']) if rvm_context

      Open3.popen3(*command) do |_in, out, err, _thread|
        # "rvm in #{rvm_context} do ruby -v"
        threads = []
        threads << Thread.new do
          while line=out.gets do
            stdout << line
            # color_print :cyan, "STDOUT: "
            # color_print :yellow, line
            process_line(line)
          end
        end
        threads << Thread.new do 
          while line=err.gets do
            stderr << line     
            # puts "STDERR: #{line}"   
            # color_print :red, "STDERR: "
            # color_print :yellow, line
          end
        end
        threads.each(&:join)
      end
    end

    def process_line(line)
      case line
      when /^[0-9]+\stests.*assertions.*failures.*notifications$/
        @complete = true
        if line =~ /^.*0\sfailures,\s0\serrors.*$/
          @passing = true
          color = :green
        else
          @passing = false
          color = :red
        end
        color_print color, line
      end
    end

    def passing?
      !!@passing
    end

    def complete?
      !!@complete
    end

    def color_print(color, *args)
      print *args.map { |arg| colorize color, arg }
    end

    def colorize(color, str)
      "\033[#{color(color.to_sym)}m#{str}\033[0m"
    end

    def color(code)
      colors[code]
    end

    def colors
      @colors ||= {
        black: 30,
        red: 31,
        green: 32,
        brown: 33,
        blue: 34,
        magenta: 35,
        cyan: 36,
        gray: 37,
        bg_black: 40,
        bg_red: 41,
        bg_green: 42,
        bg_brown: 43,
        bg_blue: 44,
        bg_magenta: 45,
        bg_cyan: 46,
        bg_gray: 47,
        bold: 1,
        reverse_color: 7
      }
    end
  end
end
