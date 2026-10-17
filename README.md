# StockTracker

StockTracker is a sample stock watchlist app built to practice Swift concurrency.

The app displays stock quote data from the [Twelve Data](https://twelvedata.com/) API or from local mock data, and includes watchlist persistence, stock search, sorting, and filtering-style controls for organizing the watchlist.

## Service Interface

App code depends on `StockServicing`, which exposes `fetchQuotes(symbols:)`, `searchStocks(query:)`, and `fetchTimeSeries(symbol:range:)`. `StockService` creates the Twelve Data requests internally and uses a private generic `fetch` helper for networking, mock data, and decoding. Controllers and service test doubles do not need provider-specific request types. An empty quote list returns immediately without a network request.

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

The detail chart offers **1D, 1W, 1M, and 1Y** below the plot. Requests use five-minute, thirty-minute, daily, and weekly bars respectively. The service requests 78, 104, 32, or 54 bars to cover each window; the view model trims by exchange-local calendar dates relative to the latest returned bar. 1D keeps only the latest trading session, while longer ranges retain the past week, calendar month, or calendar year. This supports weekends and holidays without a market-calendar lookup; overnight trading sessions are outside the app's scope.

Both modes return chronological `StockPricePoint` values. Intraday timestamps and date-only daily/weekly timestamps use the exchange time zone, including daylight saving time. Invalid prices, dates, duplicate timestamps, or mismatched metadata fail the request. Mock data is deterministic synthetic history ending on October 15, 2026 (the weekly bar starts October 12), with each final price matching its mock quote. It skips weekends, but is not a historical holiday-calendar simulation.

Changing ranges clears chart selection and cancels the prior loading task. Late responses cannot replace the active range. Successful results, including empty results, are cached by stock and range for the lifetime of the detail view model; reopening the screen creates a fresh cache. There is no automatic refresh or retry button. Each uncached live range costs another request.

The chart has a smooth line, gradient fill, highlighted point, and no axis labels. 1D compares the displayed price with the quote's previous close; longer ranges compare it with the first visible price. Percentage change is `(displayed price - baseline) / baseline * 100`; missing or invalid baselines display a dash. The line, fill, and dot are green for a positive displayed change and red otherwise. A dotted line marks the baseline, which is included in the vertical scale. Dragging snaps to a recorded point and displays its exchange-local date; release restores the latest point. VoiceOver provides adjustable selection and describes the range baseline and change.


As verified October 16, 2026, [Basic pricing](https://twelvedata.com/pricing) lists 8 API credits per minute and 800 per day. `/time_series` costs 1 credit per symbol. Seven watchlist quotes per minute leave only one credit for history or search; continuous polling can exhaust the daily quota. History is exposed as an on-demand service method and is not added to polling. Basic lists internal non-display usage; confirm display licensing with Twelve Data before distributing an app using live data. The [historical prices guide](https://support.twelvedata.com/en/articles/5656039-how-to-get-historical-prices) confirms five-minute bars and a maximum `outputsize` of 5,000 records per request. Historical availability depends on the instrument and account entitlements; no unlimited-history guarantee is assumed.

API reference: [Twelve Data documentation](https://twelvedata.com/docs).

## Screenshots

<img src="https://i.imgur.com/Dieraga.png" width="400"/>
