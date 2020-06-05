defmodule Vereine.MixProject do
  use Mix.Project

  def project do
    [
      app: :vereine,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      elixirc_paths: compiler_paths(Mix.env())
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :mnesia],
      mod: {Vereine.Application, []}
    ]
  end

  defp aliases do
    [
      test: "test --no-start"
    ]
  end

  def compiler_paths(:test), do: ["test/fakes", "test/support"] ++ compiler_paths(:prod)
  def compiler_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug_cowboy, "~> 2.0"},
      {:jason, "~> 1.2"},
      {:vex, "~> 0.8.0"},
      {:httpoison, "~> 1.6", env: :test},
      {:elixir_uuid, "~> 1.2"},
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false}
    ]
  end
end
