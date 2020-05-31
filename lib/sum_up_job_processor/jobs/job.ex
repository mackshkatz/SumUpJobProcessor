defmodule SumUpJobProcessor.Jobs.Job do
  defstruct halted: false,
            tasks: nil,
            bash_format: false
end
