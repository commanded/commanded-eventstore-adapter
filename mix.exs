defmodule Commanded.EventStore.Adapters.EventStore.Mixfile do
  use Mix.Project

  def project do
    [
      app: :commanded_eventstore_adapter,
      version: "0.1.0",
      elixir: "~> 1.4",
      description: description(),
      package: package(),
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
    ]
  end

  def application do
    [
      extra_applications: [
        :logger,
      ],
    ]
  end

  defp deps do
    [
      {:commanded, "~> 0.10", runtime: false},
      {:eventstore, "~> 0.9"},
      {:ex_doc, "~> 0.15", only: :dev},
      {:mix_test_watch, "~> 0.2", only: :dev},
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
        "lib", "mix.exs", "README*", "LICENSE*",
      ],
      maintainers: ["Ben Smith"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/slashdotdash/commanded-eventstore-adapter",
               "Docs" => "https://hexdocs.pm/commanded_eventstore_adapter/"}
    ]
  end
end
