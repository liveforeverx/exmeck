defmodule Exmeck.Mixfile do
  use Mix.Project

  def project do
    [ app: :exmeck,
      version: "0.0.1",
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    [applications: [:meck]]
  end

  defp deps do
    [{ :meck, github: "eproxus/meck"}]
  end
end
