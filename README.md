# NewsScraper

An _Elixir_-based web scraper for extracting and organizing news articles from [AP News](https://apnews.com/)

## Installation

- Make sure you have Erlang and Elixir installed in your system.
- Clone this Git repository: `git clone https://github.com/Aman-in-GitHub/NewsScraper`
- Change into the project directory: `cd NewsScraper`
- Run `mix deps.get` to install dependencies
- Run `mix` to start your NewsScraper

## Features

- **Multi-Category Scraping:** Efficiently scrapes news articles from various categories, including World, Politics, Sports, Entertainment, and Business.

- **Multiple File Formats:** Saves scraped news articles in different file formats: TXT, JSON, and Markdown (MD).

- **Dynamic Folder Structure:** Organizes saved files into category-specific folders, ensuring easy access and management.

- **Rate Limiting:** Implements random wait times between requests to avoid overwhelming the target website and reduce the risk of being blocked.

- **Robust Error Handling:** Provides clear error messages for failed requests, ensuring reliable operation and easier debugging.

- **Timestamping:** Each saved article includes a timestamp of when it was scraped, allowing for better tracking of content freshness.
