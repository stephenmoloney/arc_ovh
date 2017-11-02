defmodule ArcOvh.Mixfile do
  use Mix.Project
  @elixir_versions "~> 1.5"
  @version "0.2.0"

  def project do
    [
      app: :arc_ovh,
      version: @version,
      source_url: "https://github.com/stephenmoloney/arc_ovh",
      elixir:  @elixir_versions,
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      description: description(),
      elixirc_paths: elixirc_paths(Mix.env),
      package: package(),
      deps: deps(),
      docs: docs()
     ]
  end

  def application do
    [
      mod: {ArcOvh.Application, []},
      extra_applications: []
    ]
  end


  defp deps do
    [
      {:arc, "~> 0.8"},
      {:openstex_adapters_ovh, "~> 0.4"},
      {:mime, "~> 1.1"},

       # dev/test deps
      {:markdown, github: "devinus/markdown", only: :dev},
      {:ex_doc,  "~> 0.18", only: :dev},
      {:fastimage, "~> 0.0.7", only: :test}
    ]
  end


  defp description() do
    ~s"""
    An ovh storage adapter for arc.
    """
  end

  defp docs do
    [
     extras: ["README.md"]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]


  defp package() do
    %{
      licenses: ["MIT"],
      maintainers: ["Stephen Moloney"],
      links: %{ "GitHub" => "https://github.com/stephenmoloney/arc_ovh"},
      files: ~w(lib mix.exs README* LICENSE* CHANGELOG*)
     }
  end


end
