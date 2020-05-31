defmodule SumUpJobProcessor.Jobs do
  @moduledoc """
  The Jobs context
  - Responsible for processing jobs
  """

  alias SumUpJobProcessor.Jobs.{
    Job,
    Task
  }

  def process_job([]), do: {:error, :no_tasks}

  def process_job(job = %Job{}) do
    job
    |> determine_run_order()
  end

  defp determine_run_order(job = %Job{tasks: task_list}) do
    task_list
    |> Enum.flat_map(fn task ->
      check_requires(job, task, [])
    end)
    |> Enum.uniq
  end

  defp check_requires(%Job{}, %Task{name: name, requires: requires}, acc) when is_nil(requires) do
    [name | acc]
  end

  defp check_requires(job = %Job{tasks: task_list}, %Task{name: name, requires: requires}, acc) do
    requires
    |> Enum.flat_map(fn require_task_name ->
      required_task =
        Enum.find(task_list, fn item ->
          item.name == require_task_name
        end)

      check_requires(job, required_task, [name | acc])
    end)
  end
end
