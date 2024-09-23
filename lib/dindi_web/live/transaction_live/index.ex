defmodule DindiWeb.TransactionLive.Index do
  use DindiWeb, :live_view

  alias Dindi.Repo
  alias Dindi.Accounts
  alias Ecto.Adapter.Transaction
  alias Dindi.Transactions.Transaction
  alias Dindi.Transactions

  @impl true
  def render(assigns) do
    ~H"""
    <.modal id="form-modal">
      <div class="container mx-auto p-4">
        <div class="card">
          <.simple_form for={@form} phx-change="validate" phx-submit="save" class="card-body mx-auto">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <.input field={@form[:description]} label="Name" prompt="Amazon superman pants" />
              <.input field={@form[:date]} type="date" value={Date.utc_today()} label="Transaction" />
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <.input field={@form[:type]} label="Type" type="select" options={@types} />
              <.input
                field={@form[:category_id]}
                type="select"
                label="Category"
                options={@categories}
              />
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <.input field={@form[:account_id]} label="Account" type="select" options={@accounts} />
              <.input field={@form[:amount]} type="number" label="Amount" />
            </div>

            <.button class="btn-primary mt-5" phx-click={hide_modal("form-modal")}>Save</.button>
          </.simple_form>
        </div>
      </div>
    </.modal>

    <div class="container-md mx-auto mb-5">
      <.header class="mb-3">
        <div class="grid grid-cols-2 gap-2">
          <h1 class="text-3xl text-base-content font-semibold leading-normal">Transactions</h1>
        </div>
        <:actions>
          <.button class="btn-primary mb-1" phx-click={show_modal("form-modal")}>
            Create transaction
          </.button>
        </:actions>
      </.header>

      <div class="relative overflow-x-auto shadow-md sm:rounded-lg">
        <table class="w-full text-sm text-left text-base-content">
          <thead class="text-xs uppercase bg-base-200">
            <tr class="">
              <th scope="col" class="p-4 py-3">Name</th>
              <th scope="col" class="p-4 py-3">Account</th>
              <th scope="col" class="p-4 py-3">Category</th>
              <th scope="col" class="p-4 py-3">Date</th>
              <th scope="col" class="p-4 py-3">Amount</th>
              <th scope="col" class="p-4 py-3">Action</th>
            </tr>
          </thead>
          <tbody id="table-body" class="bg-base-300" phx-update="stream">
            <tr
              :for={{id, transaction} <- @streams.transactions}
              id={id}
              class="border-b border-base-100 "
            >
              <td class="px-4 py-4"><%= transaction.description %></td>
              <%= if transaction.account != nil do %>
                <td class="px-4 py-4"><%= transaction.account.name %></td>
              <% else %>
                <td class="px-4 py-4"></td>
              <% end %>
              <%= if transaction.account != nil do %>
                <td class="px-4 py-4"><%= transaction.category.name %></td>
              <% else %>
                <td class="px-4 py-4"></td>
              <% end %>
              <td class="px-4 py-4"><%= transaction.date %></td>
              <td class={[
                "px-4 py-4",
                if(Decimal.compare(transaction.amount, 0) == :gt,
                  do: "text-success",
                  else: "text-error"
                )
              ]}>
                €<%= transaction.amount %>
              </td>
              <td class="px-4 py-4">
                <.link
                  phx-value-id={transaction.id}
                  phx-click="delete-transaction"
                  data-confirm="Are you sure?"
                  class="font-medium text-red-600 dark:text-red-500 hover:underline"
                >
                  Delete
                </.link>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     stream(socket, :transactions, Transactions.list_transactions())
     |> assign(:form, Transactions.change_transaction(%Transaction{}) |> to_form())
     |> assign(
       :date_form,
       to_form(%{
         "start" => Date.beginning_of_month(Date.utc_today()),
         "end" => Date.end_of_month(Date.utc_today())
       })
     )
     |> assign(:types, [{"+", :gain}, {"-", :expense}])
     |> assign(:categories, Transactions.list_categories() |> to_options)
     |> assign(:accounts, Accounts.list_accounts() |> to_options)}
  end

  @impl true
  def handle_event("validate", %{"transaction" => transaction_params}, socket) do
    form =
      %Transaction{}
      |> Transactions.change_transaction(transaction_params)
      |> to_form(action: :validate)

    socket = socket |> assign(form: form)

    {:noreply, socket}
  end

  @impl true
  def handle_event("save", %{"transaction" => transaction_params}, socket) do
    transaction_params =
      case transaction_params do
        %{"type" => "gain"} ->
          transaction_params

        %{"type" => "expense", "amount" => amount} ->
          %{transaction_params | "amount" => Decimal.mult(amount, -1)}
      end
      |> trim()

    case Transactions.create_transaction(transaction_params) do
      {:ok, transaction} ->
        IO.inspect(transaction)

        {:noreply,
         socket
         |> stream_insert(:transactions, transaction |> Repo.preload([:category, :account]),
           at: 0
         )
         |> assign(:form, Transactions.change_transaction(%Transaction{}) |> to_form())
         |> put_flash(:info, "Transaction created successfully!")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: changeset)}
    end
  end

  @impl true
  def handle_event("delete-transaction", %{"id" => id}, socket) do
    to_be_deleted_transaction = Transactions.get_transaction!(id)

    case Transactions.delete_transaction(to_be_deleted_transaction) do
      {:ok, transaction} ->
        IO.inspect(transaction)

        {:noreply,
         socket
         |> stream_delete(:transactions, to_be_deleted_transaction)
         |> put_flash(:info, "Transaction deleted successfully!")}

      {:error, _} ->
        {:noreply, socket}
    end
  end

  defp to_options(list) do
    Enum.map(list, &{&1.name, &1.id})
  end

  defp trim(%{"description" => desc} = params) do
    %{params | "description" => desc |> String.trim()}
  end
end
