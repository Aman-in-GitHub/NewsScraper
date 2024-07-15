defmodule NewsScraper do
  @moduledoc """
  Documentation for `NewsScraper`

  Runs the scraper to extract news of various categories from `https://apnews.com`
  """

  alias NewsScraper.Scraper

  use Application

  @impl true
  def start(_type, _args) do
    init()

    children = []

    opts = [strategy: :one_for_one, name: NewsScraper.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def init() do
    Scraper.run()
  end
end
