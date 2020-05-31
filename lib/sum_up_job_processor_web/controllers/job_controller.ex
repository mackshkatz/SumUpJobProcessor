defmodule SumUpJobProcessorWeb.JobController do
  use SumUpJobProcessorWeb, :controller

  alias SumUpJobProcessor.Jobs
  alias SumUpJobProcessor.Jobs.{
    Job,
    Task
  }

  def process(conn, job_params) do
    job_params
    |> deserialize_job()
    |> Jobs.process_job()
    |> case do
      {:error, error} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: error})

      ordered_tasks ->
        conn
        |> put_status(:ok)
        |> json(ordered_tasks)
    end
  end

  # I would normally not concern the controller with deserializing
  # but for simplicity's sake for the code test, I handled it here
  defp deserialize_job(%{"tasks" => task_list}) when length(task_list) == 0 do
    %Job{halted: true}
  end

  defp deserialize_job(job_params = %{"tasks" => task_list}) do
    task_list
    |> Enum.map(fn task ->
      %Task{
        name: task["name"],
        command: task["command"],
        requires: task["requires"]
      }
    end)
    |> (fn task_list ->
      %Job{
        tasks: task_list,
        bash_format: job_params["bash"]
      } end).()
  end
end
