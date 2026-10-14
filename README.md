# StockTracker

StockTracker is a sample stock watchlist app built to practice Swift concurrency.

The app displays stock quote data from the [Twelve Data](https://twelvedata.com/) API or from local mock data, and includes watchlist persistence, stock search, sorting, and filtering-style controls for organizing the watchlist.

## Service Interface

App code depends on `StockServicing`, which exposes `fetchQuotes(symbols:)` and `searchStocks(query:)`. `StockService` creates the Twelve Data requests internally and uses a private generic `fetch` helper for networking, mock data, and decoding. Controllers and service test doubles do not need provider-specific request types. An empty quote list returns immediately without a network request.

## Data Modes

Mock mode is enabled by default in `AppConfiguration.current` and needs no API key. Quotes and search use deterministic synthetic JSON matching Twelve Data's `/quote` and `/symbol_search` response shapes. Both modes run through the same decoders; missing mock data produces an error and never falls back to networking.

The mock catalog contains AAPL, AMZN, GOOGL, META, MSFT, NVDA, and TSLA. Search is limited to US common stocks quoted in USD and deduplicated by symbol. A failed or partial quote batch preserves the existing quotes.

## API Key Setup

The app reads the Twelve Data API key from a local `Config/Secrets.xcconfig` file. That file is ignored by git so real API keys do not get committed.

To use live Twelve Data responses, create `Config/Secrets.xcconfig` using `Config/Secrets.example.xcconfig` as a template:

```xcconfig
TWELVE_DATA_API_KEY = your_api_key_here
```

`Config/Debug.xcconfig` and `Config/Release.xcconfig` include this local secrets file when it exists. To enable live calls, set `usesMockData` to `false` in `AppConfiguration.current`. Use a Twelve Data key; an existing StockData key is not compatible. Live calls consume account credits, and the current 60-second polling and search debounce do not implement a provider-wide rate limiter. Verify your plan's access before enabling live mode.

This integration covers quotes and search only; historical time series and detail charts are not implemented.

API reference: [Twelve Data documentation](https://twelvedata.com/docs).

## Screenshots

<img src="https://i.imgur.com/Dieraga.png" width="400"/>
