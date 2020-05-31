defmodule SumUpJobProcessor.Jobs do
  @moduledoc """
  The Jobs context
  - Responsible for processing jobs
  """

  alias SumUpJobProcessor.Jobs.{
    Job,
    Task
  }

  def process_job(%Job{halted: true}), do: {:error, :invalid_job}

  def process_job(job = %Job{}) do
    job
    |> determine_task_order()
    |> associate_command_with_task(job)
  end

  defp determine_task_order(job = %Job{tasks: task_list}) do
    task_list
    |> Enum.flat_map(fn task -> resolve_dependencies(job, task, []) end)
    |> Enum.uniq()
  end

  defp associate_command_with_task(ordered_task_list, %Job{bash_format: true, tasks: task_list}) do
    ordered_task_list
    |> Enum.map(fn task_name ->
      find_task(task_list, task_name)
      |> (fn matching_task -> matching_task.command end).()
    end)
    |> (fn commands -> ["#!/usr/bin/env bash\n" | commands] end).()
    |> Enum.join("\n")
  end

  defp associate_command_with_task(ordered_task_list, %Job{tasks: task_list}) do
    ordered_task_list
    |> Enum.map(fn task_name ->
      find_task(task_list, task_name)
      |> (fn matching_task ->
            %{
              name: matching_task.name,
              command: matching_task.command
            }
          end).()
    end)
  end

  defp resolve_dependencies(%Job{}, %Task{name: name, requires: requires}, acc)
       when is_nil(requires) do
    [name | acc]
  end

  defp resolve_dependencies(
         job = %Job{tasks: task_list},
         %Task{name: name, requires: requires},
         acc
       ) do
    requires
    |> Enum.flat_map(fn require_task_name ->
      required_task = find_task(task_list, require_task_name)

      resolve_dependencies(job, required_task, [name | acc])
    end)
  end

  defp find_task(task_list, task_name) do
    Enum.find(task_list, fn item ->
      item.name == task_name
    end)
  end
end
