defmodule DindiWeb.TransactionLive.Index do
  use DindiWeb, :live_view

  alias Dindi.Transactions

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :transactions, Transactions.list_transactions())}
  end

end
