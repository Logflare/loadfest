defmodule LoadFest do
  @moduledoc """
  Load tester for Logflare.
  """

  @doc """
  Posts a lot to a Logflare source.

  ## Examples

  """
  def post(count) do
    api_key = Application.get_env(:loadfest, :logflare_api_key)
    source = Application.get_env(:loadfest, :logflare_source)
    url = "https://logflare.app/api/logs"
    user_agent = "Loadfest"
    line = "Derp"

    headers = [
      {"Content-type", "application/json"},
      {"X-API-KEY", api_key},
      {"User-Agent", user_agent}
    ]

    for line <- 1..count do
      Task.Supervisor.start_child(LoadFest.TaskSupervisor, fn ->
        body = Jason.encode!(%{
          log_entry: line,
          source: source,
          })

        line = HTTPoison.post!(url, body, headers, hackney: [pool: :loadfest_pool])
        IO.puts(line.status_code)
      end)
    end
  end

  def sup_test() do
    Task.Supervisor.start_child(LoadFest.TaskSupervisor, fn ->
      IO.puts("derp")
    end)
  end

end
