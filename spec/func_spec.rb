require_relative 'spec_helper'

def lines_in_each_stmt_example
  Dir.glob(File.join(File.dirname(__FILE__), "stmt-examples", "*.txt")).each do |group|
    group_name = File.basename(group)
    examples = File.open(group)
    loop do
      begin
        input = examples.readline
        next if input == "\n"
        next if input[0] == '#'
        yield(group_name, input)
      rescue EOFError
        break
      end
    end
  end
end

describe "compile", "just assignments defined on line 1 (and the semicolon)" do
  wrappers = [
    ["void x ( void ) { ",               " }"],
    ["void x ( int y ) { ",              " }"],
    ["void x ( int y, char z ) { ",      " }"],
    ["void x ( int y[], char z[], ) { ", " }"],
    ["void x(void){int y; ",             " }"],
    ["void x(void){int y,z; ",           " }"],
    ["void x(void){int y; char z; ",     " }"],

    ["int  x ( void ) { ",               " }"],
    ["int  x ( int y ) { ",              " }"],
    ["int  x ( int y, char z ) { ",      " }"],
    ["int  x ( int y[], char z[], ) { ", " }"],
    ["int  x(void){int y; ",             " }"],
    ["int  x(void){int y,z; ",           " }"],
    ["int  x(void){int y; char z; ",     " }"],

    ["char x ( void ) { ",               " }"],
    ["char x ( int y ) { ",              " }"],
    ["char x ( int y, char z ) { ",      " }"],
    ["char x ( int y[], char z[], ) { ", " }"],
    ["char x(void){int y; ",             " }"],
    ["char x(void){int y,z; ",           " }"],
    ["char x(void){int y; char z; ",     " }"]
  ]
  wrappers.each do |prefix,postfix|
    lines_in_each_stmt_example do |group_name, input|
      wrapped_input = "#{prefix}#{input}#{postfix}"
      it "should parse toplevel #{group_name.gsub('_', ' ')} correctly: \"#{wrapped_input}\"", :func_only => true do
        @pid, @stdin, @stdout, @stderr, @status = compile(input)
        @stdout_lines = @stdout.readlines
        @stdout_lines.should eq []
        @stderr_lines = @stderr.readlines
        @stderr_lines.should eq []
        @status.exitstatus.should be 0
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
