require_relative 'spec_helper'

describe "compile", "bad inputs" do
  it "should correctly write error line numbers" do
    inputs = []
    # This needed to be modified. "return" must end in ";"
    inputs << <<-C
void g(int d, imt e, char f) {}
int func(int a, char b, ing c) {}
    C

    inputs.each do |input|
      compile(input).should fail_with_error_messages_about_lines(1, 2)
    end
  end
end

def compile(input)
  @pid, @stdin, @stdout, @stderr = Open4::popen4("compile")
  input.each_line { |line| @stdin.puts line }
  @stdin.close
  ignored, @status = Process::waitpid2(@pid)
  return input, @pid, @stdin, @stdout, @stderr, @status
end
