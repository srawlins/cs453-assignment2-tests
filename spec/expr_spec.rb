require_relative 'spec_helper'

describe "compile just expressions", "negate" do
  Dir.glob(File.join(File.dirname(__FILE__), "expr-examples", "*.txt")).each do |group|
    group_name = File.basename(group)
    examples = File.open(group)
    loop do
      begin
        input = examples.readline
        next if input == "\n"
        next if input[0] == '#'
        it "should parse toplevel #{group_name.gsub('_', ' ')} correctly: \"#{input}\"", :expr_only => true do
          @pid, @stdin, @stdout, @stderr, @status = compile(input)
          @status.exitstatus.should be 0
          @stdout_lines = @stdout.readlines
          @stdout_lines.size.should be 0
          @stderr_lines = @stderr.readlines
          @stderr_lines.size.should be 0
        end
      rescue EOFError
        break
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
