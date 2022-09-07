defmodule Commanded.EventStore.Adapters.EventStore.Mixfile do
  use Mix.Project

  @version "1.4.0"

  def project do
    [
      app: :commanded_eventstore_adapter,
      version: @version,
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      consolidate_protocols: Mix.env() != :test,
      description: description(),
      docs: docs(),
      package: package(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
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

  defp elixirc_paths(_env), do: ["lib"]

  defp deps do
    [
      {:commanded, "~> 1.4"},
      {:eventstore, "~> 1.3"},

      # Optional dependencies
      {:jason, "~> 1.3", optional: true},

      # Build & test tools
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:mox, "~> 1.0", only: :test}
    ]
  end

  defp aliases do
    [
      reset: ["event_store.drop", "setup"],
      setup: ["event_store.create", "event_store.init"]
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
      source_ref: "v#{@version}",
      extra_section: "GUIDES",
      extras: [
        "CHANGELOG.md",
        "guides/Getting Started.md": [filename: "getting-started", title: "EventStore adapter"],
        "guides/Dynamic Event Store.md": [
          filename: "dynamic-event-store",
          title: "Dynamic EventStore"
        ]
      ]
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
