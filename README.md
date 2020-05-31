# SumUpJobProcessor

Feel free to clone the project locally, and to start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your favorite HTTP client.

Example request:

  * Requesting bash format output:
    ```
    {
      "bash": true,
      "tasks":[
          {
            "name":"task-1",
            "command":"touch /tmp/file1"
          },
          {
            "name":"task-2",
            "command":"cat /tmp/file1",
            "requires":[
                "task-3"
            ]
          },
          {
            "name":"task-3",
            "command":"echo 'Hello World!' > /tmp/file1",
            "requires":[
                "task-1"
            ]
          },
          {
            "name":"task-4",
            "command":"rm /tmp/file1",
            "requires":[
                "task-2",
                "task-3"
            ]
          }
      ]
    }
    ```
  * Don't send the bash param if you want it returned as a list of objects containing the name and command
