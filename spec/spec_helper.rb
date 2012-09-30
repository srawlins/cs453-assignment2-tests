require 'open4'
require_relative 'helpers'

if `which compile`.empty?
  $stderr.puts "compile not found in $PATH!!! Exiting."
  exit 1
end

PRNG = Random.new
puts "PRNG's seed: #{PRNG.seed}"
if ENV['RANDOM_THRESHOLD']
  # If $RANDOM_THRESHOLD is set, use it
  THRESHOLD = ENV['RANDOM_THRESHOLD'].to_i
else
  # Alternatively, if it dodesn't, in the interest of the poor scheduler on lectura, just run 5% of the tests.
  THRESHOLD = 5
  $stderr.puts "$RANDOM_THRESHOLD not set. Conservatively using $RANDOM_THRESHOLD=5"
end

module Matchers
  class Succeed
    def initialize

    end

    def matches?(ary)
      @input  = ary[0]
      @pid    = ary[1]
      @stdin  = ary[2]
      @stdout = ary[3].read
      if @stdout != ""
        @failure_reason = :stdout
        return false
      end
      @stderr = ary[4].read
      if @stderr != ""
        @failure_reason = :stderr
        return false
      end
      @status = ary[5].exitstatus
      if @status != 0
        @failure_reason = :status
        return false
      end

      return true
    end

    def failure_message
      "expected\n" +
        "\n" +
        "  compile <<EOF\n" +
        @input.each_line.map {|l| '  > '+l}.join +
        "  > EOF\n" +
        "\n" +
        case @failure_reason
        when :stdout
          "to print nothing on stdout, but it printed:\n" +
          "    #{@stdout.inspect}\n" +
          "\n"
        when :stderr
          "to print nothing on stderr, but it printed:\n" +
          @stderr.each_line.map {|l| '    '+l}.join +
          "\n"
        when :status
          "to exit 0, but it instead exited #{@status}"
        else
          "to... um... (@failure_reason not given)"
        end
    end

    def negative_failure_message
      "expected ... to not succeed"
    end
  end

  def succeed
    Succeed.new
  end

  class Fail
    def initialize(err_lines)
      @err_lines = err_lines
    end

    def matches?(ary)
      @input  = ary[0]
      @pid    = ary[1]
      @stdin  = ary[2]
      @stdout = ary[3].read
      #if @stdout != ""
      #  @failure_reason = :stdout
      #  return false
      #end

      @stderr = ary[4].read
      # If there are any error line numbers that don't show up in @stderr
      if @err_lines.any? {|l| not @stderr =~ /#{l}/}
        @failure_reason = :stderr
        @failure_specific = @err_lines.select {|l| not @stderr =~ /#{l}/}
        return false
      end

      @status = ary[5].exitstatus
      #if @status == 0
      #  @failure_reason = :status
      #  return false
      #end

      return true
    end

    def failure_message
      "expected\n" +
        "\n" +
        "  compile <<EOF\n" +
        @input.each_line.map {|l| '  > '+l}.join +
        "  > EOF\n" +
        "\n" +
        case @failure_reason
        #when :stdout
        #  "to print nothing on stdout, but it printed:\n" +
        #  "    #{@stdout.inspect}\n" +
        #  "\n"
        when :stderr
          "to print these erroneous line numbers on stderr:\n" +
            '    '+@err_lines.join(", ")+"\n" +
            "but stderr instead contained this:\n" +
            @stderr.each_line.map {|l| '    '+l}.join +
            "(#{@failure_specific.join(", ")} is missing)\n" +
            "\n"
        when :status
          "to exit not-so-0, but it instead exited #{@status}"
        else
          "to... um... (@failure_reason not given)"
        end
    end

    def negative_failure_message
      "expected ... to not fail"
    end
  end

  def fail_with_error_messages_about_lines(*lines)
    Fail.new(lines)
  end
end

RSpec.configure do |config|
  config.include Matchers
end
