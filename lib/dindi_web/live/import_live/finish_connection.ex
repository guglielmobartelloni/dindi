defmodule DindiWeb.ImportLive.FinishConnection do
  use DindiWeb, :live_view

  alias Dindi.Transactions.Importer

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container-md mx-auto mb-5">
      <.table id="account-transactions" rows={@transactions}>
        <:col :let={trans} label="name"><%= Map.get(trans, "transactionAmount") |> Map.get("amount") %></:col>
        <:action>
          <.link
            phx-click="delete-transaction"
            data-confirm="Are you sure?"
            class="font-medium text-red-600 dark:text-red-500 hover:underline"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </div>
    """
  end

  @impl true
  def mount(%{"ref" => ref}, _session, socket) do
    if connected?(socket) do
      client = Importer.new()
      %{"accounts" => accounts} = client |> Importer.list_accounts(ref) |> IO.inspect()

      %{"transactions" => %{"booked" => booked, "pending" => pending}} =
        Importer.list_transactions(client, accounts |> Enum.at(0)) |> IO.inspect()

        transactions = booked ++ pending

      socket = socket |> assign(transactions: transactions)
      {:ok, socket}
    else
      {:ok, socket |> assign(transactions: [])}
    end
  end
end
