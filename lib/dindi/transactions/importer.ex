defmodule Dindi.Transactions.Importer do
  
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://api-sandbox.gocardless.com"
  plug Tesla.Middleware.Headers, [{"authorization", "token xyz"}]
  plug Tesla.Middleware.JSON




end
