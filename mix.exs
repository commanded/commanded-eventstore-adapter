defmodule Commanded.EventStore.Adapters.EventStore.Mixfile do
  use Mix.Project

  def project do
    [
      app: :commanded_eventstore_adapter,
      version: "0.3.0",
      elixir: "~> 1.5",
      description: description(),
      package: package(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [
        :logger,
        :eventstore
      ]
    ]
  end

  defp deps do
    [
      {:commanded, github: "commanded/commanded", runtime: false},
      {:eventstore, github: "commanded/eventstore"},
      # {:commanded, ">= 0.15.0", runtime: false},
      # {:eventstore, ">= 0.13.0"},
      {:ex_doc, "~> 0.17", only: :dev},
      {:mix_test_watch, "~> 0.5", only: :dev}
    ]
  end

  defp description do
    """
    EventStore adapter for Commanded
    """
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
        "GitHub" => "https://github.com/commanded/commanded-eventstore-adapter",
        "Docs" => "https://hexdocs.pm/commanded_eventstore_adapter/"
      }
    ]
  end
end
