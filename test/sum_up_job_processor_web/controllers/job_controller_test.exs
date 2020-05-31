defmodule SumUpJobProcessorWeb.JobControllerTest do
  use SumUpJobProcessorWeb.ConnCase

  @valid_params %{
      tasks: [
        %{
          name: "task-1",
          command: "touch /tmp/file1"
        },
        %{
          name: "task-2",
          command: "cat /tmp/file1",
          requires: [
              "task-3"
          ]
        },
        %{
          name: "task-3",
          command: "echo 'Hello World!' > /tmp/file1",
          requires: [
              "task-1"
          ]
        },
        %{
          name: "task-4",
          command: "rm /tmp/file1",
          requires: [
              "task-2",
              "task-3"
          ]
        }
      ]
    }

  describe "POST /api/jobs/process" do
    test "valid request returns list of ordered tasks" do
      conn =
        build_conn()
        |> put_req_header("content-type", "application/json")
        |> post("/api/jobs/process", @valid_params)

      assert [
        %{"command" => "touch /tmp/file1", "name" => "task-1"},
        %{"command" => "echo 'Hello World!' > /tmp/file1", "name" => "task-3"},
        %{"command" => "cat /tmp/file1", "name" => "task-2"},
        %{"command" => "rm /tmp/file1", "name" => "task-4"}
      ] = json_response(conn, 200)
    end

    test "valid request with bash param flag returns commands in a pipeable format for bash" do
      conn =
        build_conn()
        |> put_req_header("content-type", "application/json")
        |> post("/api/jobs/process", @valid_params |> Map.put(:bash, true))

      assert """
      #!/usr/bin/env bash

      touch /tmp/file1
      echo 'Hello World!' > /tmp/file1
      cat /tmp/file1
      rm /tmp/file1\
      """ = json_response(conn, 200)
    end

    test "invalid request returns error without raising exception" do
      conn =
        build_conn()
        |> put_req_header("content-type", "application/json")
        |> post("/api/jobs/process",
          %{
            tasks: []
          }
        )

      assert %{"errors" => "invalid_job"} = json_response(conn, 422)
    end
  end
end
