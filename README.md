# StockTracker

StockTracker is a sample stock watchlist app built to practice Swift concurrency.

The app displays stock quote data from the [StockData.org](https://www.stockdata.org/) API or from local mock data, and includes watchlist persistence, stock search, sorting, and filtering-style controls for organizing the watchlist.

## API Key Setup

The app reads the StockData.org API key from a local `Config/Secrets.xcconfig` file. That file is ignored by git so real API keys do not get committed.

To use live StockData.org data, create `Config/Secrets.xcconfig` using `Config/Secrets.example.xcconfig` as a template:

```xcconfig
STOCKDATA_API_KEY = your_api_key_here
```

`Config/Debug.xcconfig` and `Config/Release.xcconfig` include this local secrets file when it exists. When developing without live API calls, the app can use local mock data instead.
