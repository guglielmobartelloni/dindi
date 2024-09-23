defmodule DindiWeb.ImportLive.FinishConnection do
  alias Dindi.Transactions
  use DindiWeb, :live_view

  alias Dindi.Transactions.Importer

  @impl true
  def render(assigns) do
    ~H"""
    <.async_result assign={@transactions}>
      <:loading>
        <div class="loading loading-spinner loading-lg mx-auto"></div>
      </:loading>
      <div class="container-md mx-auto mb-5">
        <.link
          phx-click="import-all"
          data-confirm="Are you sure?"
          class="font-medium text-primary hover:underline"
        >
          Import all
        </.link>
        <.table id="account-transactions" rows={@transactions.result}>
          <:col :let={trans} label="name">
            <%= trans["remittanceInformationUnstructured"] %>
          </:col>
          <:col :let={trans} label="amount">
            <%= trans["transactionAmount"]["amount"] %>
          </:col>
        </.table>
      </div>
    </.async_result>
    """
  end

  @impl true
  def mount(%{"ref" => ref}, _session, socket) do
    socket =
      socket
      |> assign_async(:transactions, fn ->
        client = Importer.new()
        %{"accounts" => accounts} = client |> Importer.list_accounts(ref) |> IO.inspect()

        %{"transactions" => %{"booked" => booked, "pending" => pending}} =
          Importer.list_transactions(client, accounts |> Enum.at(0)) |> IO.inspect()

        transactions = booked ++ pending
        {:ok, %{transactions: transactions}}
      end)

    {:ok, socket}
  end

  @impl true
  @spec handle_event(<<_::80>>, any(), any()) :: {:noreply, any()}
  def handle_event("import-all", _, socket) do
    socket.assigns.transactions.result
    |> Enum.map(fn %{
                     "bookingDate" => _,
                     "internalTransactionId" => _,
                     "remittanceInformationUnstructured" => desc,
                     "transactionAmount" => %{"amount" => amount, "currency" => _},
                     "transactionId" => _,
                     "valueDate" => value_date
                   } ->
      %{
        date: Date.from_iso8601!(value_date),
        description: desc,
        amount: Decimal.new(amount),
        inserted_at: DateTime.utc_now() |> DateTime.truncate(:second),
        updated_at: DateTime.utc_now() |> DateTime.truncate(:second)
      }
    end)
    |> Transactions.insert_transactions()

    {:noreply, socket}
  end
end
