defmodule Commanded.EventStore.Adapters.EventStore.Mixfile do
  use Mix.Project

  @version "0.6.0"

  def project do
    [
      app: :commanded_eventstore_adapter,
      version: @version,
      elixir: "~> 1.6",
      elixirc_paths: elixirc_paths(Mix.env()),
      consolidate_protocols: Mix.env() != :test,
      description: description(),
      docs: docs(),
      package: package(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test) do
    [
      "deps/commanded/test/event_store",
      "deps/commanded/test/support",
      "lib",
      "test/support"
    ]
  end

  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      # {:commanded, ">= 0.19.0", runtime: Mix.env() == :test},
      {:commanded,
       github: "commanded/commanded", branch: "feature/multi-app", runtime: Mix.env() == :test},
      # {:eventstore, ">= 0.17.0"},
      {:eventstore, github: "commanded/eventstore"},

      # Optional dependencies
      {:jason, "~> 1.1", optional: true},

      # Build & test tools
      {:ex_doc, "~> 0.20", only: :dev},
      {:mix_test_watch, "~> 0.9", only: :dev},
      {:mox, "~> 0.5", only: :test}
    ]
  end

  defp description do
    """
    EventStore adapter for Commanded
    """
  end

  defp docs do
    [
      main: "Commanded.EventStore.Adapters.EventStore",
      canonical: "http://hexdocs.pm/commanded_eventstore_adapter",
      source_ref: "v#{@version}"
    ]
  end

  defp package do
    [
      files: [
        "lib",
        "mix.exs",
        "README*",
        "LICENSE*"
      ],
      maintainers: ["Ben Smith"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/commanded/commanded-eventstore-adapter"
      }
    ]
  end
end
