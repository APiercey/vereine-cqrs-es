defmodule Vereine.MixProject do
  use Mix.Project

  def project do
    [
      app: :vereine,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
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

  def compiler_paths(:test), do: ["test/fakes" | compiler_paths(:prod)]
  def compiler_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug_cowboy, "~> 2.0"},
      {:elixir_uuid, "~> 1.2"}
    ]
  end
end
