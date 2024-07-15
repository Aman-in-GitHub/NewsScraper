defmodule NewsScraper.Scraper do
  @moduledoc """
  Documentation for `Scraper`

  Scrapes the news and saves it in various file formats, such as [TXT | JSON | MD]
  """

  @urls %{
    world: "https://apnews.com/world-news",
    politics: "https://apnews.com/politics",
    sports: "https://apnews.com/sports",
    entertainment: "https://apnews.com/entertainment",
    business: "https://apnews.com/business"
  }
  @num_of_news 10
  @root "data"
  @wait_time [
    100,
    250,
    500,
    750,
    1000
  ]

  def run() do
    IO.puts("-----------------------")
    IO.puts("Initializing Scraper ⛏️")
    IO.puts("-----------------------")

    if !File.exists?(@root) do
      case File.mkdir(@root) do
        :ok ->
          IO.puts("\nSuccess: Scraper storage initialized")

        _ ->
          IO.puts("\nFATAL: Error initializing scraper storage")
          System.halt(1)
      end
    end

    scraper()

    IO.puts("\n----------------------")
    IO.puts("Terminating Scraper 📦")
    IO.puts("----------------------")
  end

  @spec save_to_txt(any(), String.t(), String.t()) :: :ok | :error
  defp save_to_txt(result, folder_path, file_path) do
    type = "txt"

    content =
      "#{result.title}\n#{result.author} - #{result.scraped_at}\n\n#{result.description}\n\nSource: #{result.source}"

    new_file_path = folder_path <> "/#{type}/" <> file_path <> ".#{type}"

    case File.write(new_file_path, content) do
      :ok ->
        IO.puts("Success: Created #{new_file_path}")
        :ok

      _ ->
        IO.puts("Error: File creation failed at #{new_file_path}")
        :error
    end
  end

  @spec save_to_json(any(), String.t(), String.t()) :: :ok | :error
  defp save_to_json(result, folder_path, file_path) do
    type = "json"

    {:ok, json} = Jason.encode(result, pretty: true)

    new_file_path = folder_path <> "/#{type}/" <> file_path <> ".#{type}"

    case File.write(new_file_path, json) do
      :ok ->
        IO.puts("Success: Created #{new_file_path}")
        :ok

      _ ->
        IO.puts("Error: File creation failed at #{new_file_path}")
        :error
    end
  end

  @spec save_to_md(any(), String.t(), String.t()) :: :ok | :error
  defp save_to_md(result, folder_path, file_path) do
    type = "md"

    content =
      "# #{result.title}\n_#{result.author} ~ #{result.scraped_at}_\n\n#{result.description}\n\n**Source**: [#{result.title}](#{result.source})"

    new_file_path = folder_path <> "/#{type}/" <> file_path <> ".#{type}"

    case File.write(new_file_path, content) do
      :ok ->
        IO.puts("Success: Created #{new_file_path}")
        :ok

      _ ->
        IO.puts("Error: File creation failed at #{new_file_path}")
        :error
    end
  end

  @spec handle_response(any(), String.t(), String.t()) :: :ok | :error
  defp handle_response(res, selected_url, category) do
    news_url = "h3 a.Link"

    IO.puts("\nStarted scraping #{category} news\n")

    case res do
      {:ok, %HTTPoison.Response{body: body}} ->
        {:ok, document} = Floki.parse_document(body)

        links =
          document
          |> Floki.attribute(news_url, "href")

        handle_detail_page(links, category)

      _ ->
        IO.puts("Error: Fetching #{selected_url} failed")
        :error
    end
  end

  @spec handle_detail_page([any()], String.t()) :: :ok | :error
  defp handle_detail_page(links, category) do
    links
    |> Enum.take(@num_of_news)
    |> Enum.each(fn link ->
      :timer.sleep(Enum.random(@wait_time))

      res =
        link
        |> HTTPoison.get()

      case res do
        {:ok, %HTTPoison.Response{body: body}} ->
          {:ok, document} = Floki.parse_document(body)

          elems = %{
            title: "h1.Page-headline",
            author: "div.Page-authors a",
            description: "div.RichTextStoryBody",
            source: "meta[property='og:url']"
          }

          result =
            Enum.reduce(elems, %{}, fn {key, selector}, acc ->
              if key == :source do
                text = document |> Floki.attribute(selector, "content") |> Enum.at(0)
                Map.put(acc, key, text)
              else
                text = document |> Floki.find(selector) |> Floki.text() |> String.trim()
                Map.put(acc, key, text)
              end
            end)

          today = Date.utc_today()
          current_time_in_seconds = System.os_time(:second)

          result = Map.put(result, :scraped_at, Date.to_string(today))
          folder_path = "#{@root}/#{category}"
          file_path = "#{category}_#{current_time_in_seconds}"

          if(!File.exists?(folder_path)) do
            case File.mkdir(folder_path) do
              :ok ->
                IO.puts("Success: #{category} category folder created")
                File.mkdir("#{folder_path}/txt")
                File.mkdir("#{folder_path}/json")
                File.mkdir("#{folder_path}/md")

                :ok

              _ ->
                IO.puts("Error: Folder creation failed at #{folder_path}")
                :error
            end
          end

          save_to_txt(result, folder_path, file_path)
          save_to_json(result, folder_path, file_path)
          save_to_md(result, folder_path, file_path)

        _ ->
          IO.puts("Error: Fetching #{link} failed")
          :error
      end
    end)
  end

  def scraper() do
    Enum.each(@urls, fn {category, url} ->
      url
      |> HTTPoison.get()
      |> handle_response(url, category)
    end)
  end
end
