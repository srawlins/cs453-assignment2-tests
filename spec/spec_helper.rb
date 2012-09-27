require 'open4'

if `which compile`.empty?
  $stderr.puts "compile not found in $PATH!!! Exiting."
  exit 1
end

PRNG = Random.new
puts "PRNG's seed: #{PRNG.seed}"
THRESHOLD = ENV['RANDOM_THRESHOLD'] ? ENV['RANDOM_THRESHOLD'].to_i : nil

module Matchers
  class Succeed
    def initialize

    end

    def matches?(ary)
      pid    = ary[0]
      stdin  = ary[1]
      stdout = ary[2]
      stderr = ary[3]
      status = ary[4]
      status == 0
    end

    def failure_message
      "expected ... to succeed"
    end

    def negative_failure_message
      "expected ... to not succeed"
    end
  end

  def succeed
    Succeed.new
  end
end

RSpec.configure do |config|
  config.include Matchers
end
