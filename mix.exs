defmodule LoadFest.MixProject do
  use Mix.Project

  def project do
    [
      app: :loadfest,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {LoadFest.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.4"},
      {:jason, "~> 1.0"},
      {:credo, "~> 1.2.0", only: [:dev, :test], runtime: false}
    ]
  end
end
