require_relative 'spec_helper'

include Helpers

describe "compile", "bad func" do
  it "should correctly output error line numbers for bad func parms" do
    inputs = read_inputs_from(__FILE__.sub('_spec.rb', '_parms.data'))

    inputs.each do |input, error_lines|
      compile(input).should fail_with_error_messages_about_lines(*error_lines)
    end
  end

  it "should correctly output error line numbers for bad func var_decls" do
    inputs = read_inputs_from(__FILE__.sub('_spec.rb', '_var_decls.data'))

    inputs.each do |input, error_lines|
      compile(input).should fail_with_error_messages_about_lines(*error_lines)
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
