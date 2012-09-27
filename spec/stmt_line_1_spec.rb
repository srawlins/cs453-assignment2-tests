require_relative 'spec_helper'

def lines_in_each_expr_example(prefix, postfix)
  Dir.glob(File.join(File.dirname(__FILE__), "expr-examples", "*.txt")).each do |group|
    group_name = File.basename(group)
    examples = File.open(group)
    loop do
      begin
        input = examples.readline
        next if input == "\n"
        next if input[0] == '#'
        if THRESHOLD
          next unless PRNG.rand(0..99) < THRESHOLD
        end
        wrapped_input = "#{prefix}#{input}#{postfix}"
        yield(group_name, wrapped_input)
      rescue EOFError
        break
      end
    end
  end
end

describe "compile", "just assignments defined on line 1 (and the semicolon)" do
  wrappers = [
    ["if (",          ") ;"],
    ["if(",           ");"],
    ["if (",          "); else;"],
    ["if (",          ") if (1); else;"],
    ["if ( 1 ) if (", "); else;"]
  ]

  wrappers.each do |prefix, postfix|
    lines_in_each_expr_example(prefix, postfix) do |group_name, input|
      it "should parse toplevel #{group_name.gsub('_', ' ')} correctly: \"#{input}\"", :stmt_only => true do
        @pid, @stdin, @stdout, @stderr, @status = compile(input)
        @status.exitstatus.should be 0
        @stdout_lines = @stdout.readlines
        @stdout_lines.size.should be 0
        @stderr_lines = @stderr.readlines
        @stderr_lines.size.should be 0
      end
    end
  end
end

def compile(stdin)
  @pid, @stdin, @stdout, @stderr = Open4::popen4("compile")
  stdin.each_line { |line| @stdin.puts line }
  @stdin.close
  ignored, @status = Process::waitpid2(@pid)
  return @pid, @stdin, @stdout, @stderr, @status
end
