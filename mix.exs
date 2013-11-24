defmodule HangGame.Mixfile do
  use Mix.Project

  def project do
    [ app: :hang_game,
      version: "0.0.1",
      build_per_environment: true,
      dynamos: [HangGame.Dynamo],
      compilers: [:elixir, :dynamo, :app],
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    [ applications: [:cowboy, :dynamo, :hackney],
      mod: { HangGame, [] } ]
  end

  defp deps do
    [ { :cowboy, github: "extend/cowboy" },
      { :mimetypes, github: "spawngrid/mimetypes", override: true },
      { :dynamo, "~> 0.1.0-dev", github: "elixir-lang/dynamo" },
      { :hackney, github: "benoitc/hackney" },
      { :hang_game_engine, github: "lucho-yankov/hang-game-engine" }
    ]
  end
end
