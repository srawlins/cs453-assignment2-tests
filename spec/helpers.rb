module Helpers
  def read_inputs_from(file)
    inputs = []
    input = ""
    error_lines = []
    inputs_file = "#{$1}.data"
    File.open(file) do |handle|
      while line=handle.gets
        if line =~ /^%%%+/  # If line starts with at least three %, its a data separator
          inputs << [input, error_lines]
          input = ""
        elsif line =~ /^%% ERROR LINES (.+)$/
          error_lines = $1.split(/\s+/)
        else
          input << line
        end
      end

      if input != ""
        inputs << [input, error_lines]
      end
    end

    return inputs
  end
end
