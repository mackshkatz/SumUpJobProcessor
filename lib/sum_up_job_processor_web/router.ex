defmodule SumUpJobProcessorWeb.Router do
  use SumUpJobProcessorWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", SumUpJobProcessorWeb do
    pipe_through :api

    post("/jobs", JobController, :create)
  end
end
