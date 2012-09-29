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

    # This needed to be modified:
    # * to only accept intcons in a var decl...
    # * to not chain assignments
    # * moving the i declaration up top
    # * replacing i++
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

    # This needed to be modified, to not assign variables during declaration.
    inputs << <<-C
int fib(int n)
{
  int a, b, i, c;
  b = 1;
  a = 1;
  i = 1;
  for (i = 3; i <= n; i=i+1) {
    c = a + b;
    a = b;
    b = c;
  }
  return b;
}
    C

    inputs.each do |input|
      compile(input).should succeed
    end
  end

  it "should parse factorial algorithms from http://www.programmingsimplified.com/c-program-find-factorial" do
    inputs = []
    # This needed to be modified:
    # * assignments happen after declarations
    # * no &'s
    # * no ++
    # * no empty parm_types; use void
    inputs << <<-C
int main(void)
{
  int c, n, fact;
  fact = 1;
  printf("Enter a number to calculate it's factorial\\n");
  scanf("%d", n);
  for (c = 1; c <= n; c=c+1)
    fact = fact * c;

  printf("Factorial of %d = %d\\n", n, fact);
  return 0;
}
    C


    inputs.each do |input|
      compile(input).should succeed
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
