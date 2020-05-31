defmodule SumUpJobProcessorWeb.JobController do
  use SumUpJobProcessorWeb, :controller

  alias SumUpJobProcessor.Jobs
  alias SumUpJobProcessor.Jobs.{
    Job,
    Task
  }

  def process(conn, %{"tasks" => job_params}) do
    job_params
    |> deserialize_job()
    |> Jobs.process_job()
    # |> case do
      # {:ok, job} ->
      # {:error, error} ->
  end

  # I would normally not concern the controller with deserializing
  # but for simplicity's sake for the code test, I handled it here
  defp deserialize_job(job_params) do
    job_params
    |> Enum.map(fn task ->
      %Task{
        name: task["name"],
        command: task["command"],
        requires: task["requires"]
      }
    end)
    |> (fn task_list -> %Job{tasks: task_list} end).()
  end
end
