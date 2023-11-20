defmodule Loadfest.MixProject do
  use Mix.Project

  def project do
    [
      app: :loadfest,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Loadfest.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 2.0"},
      {:hackney, "~>1.20.1"},
      {:finch, "~> 0.16"},
      {:tesla, "~> 1.4"},
      {:jason, "~> 1.0"},
      {:credo, "~> 1.0.0", only: [:dev, :test], runtime: false},
      {:benchee, "~> 1.0", only: [:dev, :test]},
      {:mix_test_watch, "~> 1.0", only: [:dev, :test], runtime: false},
      {:stream_data, "~> 0.5"},
      {:telemetry_poller, "~> 1.0"},
      {:telemetry, "~> 1.0"},
      {:telemetry_metrics, "~> 0.6.1"}
    ]
  end

  defp aliases do
    [
      "build.local": "cmd fly launch --local-only ",
      deploy: "cmd fly launch --now"
    ]
  end
end
