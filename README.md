# StockTracker

StockTracker is a sample stock watchlist app built to practice Swift concurrency.

The app displays stock quote data from the [Twelve Data](https://twelvedata.com/) API or from local mock data, and includes watchlist persistence, stock search, sorting, and filtering-style controls for organizing the watchlist.

## Service Interface

App code depends on `StockServicing`, which exposes `fetchQuotes(symbols:)`, `searchStocks(query:)`, and `fetchTimeSeries(symbol:)`. `StockService` creates the Twelve Data requests internally and uses a private generic `fetch` helper for networking, mock data, and decoding. Controllers and service test doubles do not need provider-specific request types. An empty quote list returns immediately without a network request.

## Data Modes

Mock mode is enabled by default in `AppConfiguration.current` and needs no API key. Quotes, search, and price history use deterministic synthetic JSON matching Twelve Data's `/quote`, `/symbol_search`, and `/time_series` response shapes. Both modes run through the same decoders; missing mock data produces an error and never falls back to networking.

The mock catalog contains AAPL, AMZN, GOOGL, META, MSFT, NVDA, and TSLA. Search is limited to US common stocks quoted in USD and deduplicated by symbol. A failed or partial quote batch preserves the existing quotes.

## API Key Setup

The app reads the Twelve Data API key from a local `Config/Secrets.xcconfig` file. That file is ignored by git so real API keys do not get committed.

To use live Twelve Data responses, create `Config/Secrets.xcconfig` using `Config/Secrets.example.xcconfig` as a template:

```xcconfig
TWELVE_DATA_API_KEY = your_api_key_here
```

`Config/Debug.xcconfig` and `Config/Release.xcconfig` include this local secrets file when it exists. To enable live calls, set `usesMockData` to `false` in `AppConfiguration.current`. Use a Twelve Data key; an existing StockData key is not compatible. Live calls consume account credits, and the current 60-second polling and search debounce do not implement a provider-wide rate limiter. Verify your plan's access before enabling live mode.

Price history fetches the latest 78 regular-session five-minute bars for one symbol. Both modes return `StockPricePoint` values sorted oldest first, parsing timestamps using the response's exchange timezone (including daylight saving time). Invalid prices, dates, duplicate timestamps, or mismatched metadata fail the request; empty results remain empty. The service can return bars spanning trading sessions. The detail view model keeps only the newest available trading date in the exchange’s time zone, preserving chronological order. It uses the latest bar rather than today, so weekends, holidays, and pre-open hours retain the most recent session. This date-based filtering applies to the regular-session equities requested by the app; it does not model overnight trading sessions. Mock history uses a fixed synthetic session on October 15, 2026, ending at each stock's mock quote price. The detail screen displays this history below the price and daily change using Swift Charts: a smooth line, gradient fill, and latest-price dot. It loads on opening the screen, supports loading/empty/error states, and hides axis labels while retaining subtle horizontal grid lines. The line, fill, and latest-price dot are green for positive daily change and red otherwise. An accessibility summary includes exchange-local dates and the price range. There is no retry button, drag selection, or period selection yet.

As verified October 16, 2026, [Basic pricing](https://twelvedata.com/pricing) lists 8 API credits per minute and 800 per day. `/time_series` costs 1 credit per symbol. Seven watchlist quotes per minute leave only one credit for history or search; continuous polling can exhaust the daily quota. History is exposed as an on-demand service method and is not added to polling. Basic lists internal non-display usage; confirm display licensing with Twelve Data before distributing an app using live data. The [historical prices guide](https://support.twelvedata.com/en/articles/5656039-how-to-get-historical-prices) confirms five-minute bars and a maximum `outputsize` of 5,000 records per request. Historical availability depends on the instrument and account entitlements; no unlimited-history guarantee is assumed.

API reference: [Twelve Data documentation](https://twelvedata.com/docs).

## Screenshots

<img src="https://i.imgur.com/Dieraga.png" width="400"/>
