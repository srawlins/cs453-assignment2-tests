require_relative 'spec_helper'

describe "compile", "prog examples from the interwebs" do
  it "should parse fibonacci algorithms from http://www.ics.uci.edu/~eppstein/161/960109.html" do
    inputs = []
    # This needed to be modified. "return" must end in ";"
    inputs << <<-C
int fib(int n)
{
  if (n <= 2) return 1;
  else return fib(n-1) + fib(n-2);
}
    C
    # This needed to be modified to only accept intcons in a var decl...
    # This needed to be modified to not chain assignments
    # This needed to be modified, moving the i declaration up top
    # This needed to be modified, replacing i++
    inputs << <<-C
int fib(int n)
{
  int f[1000];
  int i;
  f[1] = 1;
  f[2] = 1;
  for (i = 3; i <= n; i=i+1)
    f[i] = f[i-1] + f[i-2];
  return f[n];
}
    C
    inputs.each do |input|
      @pid, @stdin, @stdout, @stderr, @status = compile(input)
      @stdout.readlines.should eq []
      @stderr.readlines.should eq []
      @status.exitstatus.should be 0
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
