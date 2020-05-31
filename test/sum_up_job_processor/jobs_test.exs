defmodule SumUpJobProcessor.JobsTest do
  use ExUnit.Case

  alias SumUpJobProcessor.Jobs

  alias SumUpJobProcessor.Jobs.{
    Job,
    Task
  }

  setup do
    task_list = [
      %Task{
        name: "task-1",
        command: "touch /tmp/file1"
      },
      %Task{
        name: "task-2",
        command: "cat /tmp/file1",
        requires: [
          "task-3"
        ]
      },
      %Task{
        name: "task-3",
        command: "echo 'Hello World!' > /tmp/file1",
        requires: [
          "task-1"
        ]
      },
      %Task{
        name: "task-4",
        command: "rm /tmp/file1",
        requires: [
          "task-2",
          "task-3"
        ]
      }
    ]

    %{
      job: %Job{tasks: task_list}
    }
  end

  describe "jobs" do
    test "process_job/1 returns error for a halted job" do
      assert {:error, :invalid_job} = Jobs.process_job(%Job{halted: true})
    end

    test "process_job/1 returns name and command for each task in the proper run order", %{
      job: job
    } do
      assert [
               %{
                 name: "task-1",
                 command: "touch /tmp/file1"
               },
               %{
                 name: "task-3",
                 command: "echo 'Hello World!' > /tmp/file1"
               },
               %{
                 name: "task-2",
                 command: "cat /tmp/file1"
               },
               %{
                 name: "task-4",
                 command: "rm /tmp/file1"
               }
             ] = Jobs.process_job(job)
    end
  end
end
