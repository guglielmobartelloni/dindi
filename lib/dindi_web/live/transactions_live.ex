defmodule DindiWeb.TransactionsLive do
  alias Dindi.Core
  alias Dindi.Core.Category
  alias Dindi.Repo
  use DindiWeb, :live_view

  @impl true
  def mount(_, _, socket) do
    transactions = Core.get_transactions()
    categories = Repo.all(Category) |> Enum.map(fn e -> {e.name, e.id} end)

    total_transaction = Core.get_total_transaction(transactions)

    {:ok,
     socket
     |> assign(transactions: transactions)
     |> assign(total_transaction: total_transaction)
     |> assign(categories: categories)
     |> assign(form: %{} |> to_form)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex items-center justify-between">
      <.h2 class="text-black">Transactions</.h2>
      <.link patch={~p"/new-trans"}>
        <.button>
          New
        </.button>
      </.link>
    </div>
    <.table
      class="mt-5"
      id="posts"
      row_id={fn transaction -> "row_#{transaction.id}" end}
      rows={@transactions}
    >
      <:col :let={transaction} label="Title">{transaction.title}</:col>
      <:col :let={transaction} label="Amount">{transaction.amount}</:col>
      <:col :let={transaction} label="Category">{transaction.category.name}</:col>
      <:col class="w-64">
        <div class="flex gap-2 items-center justify-end">
          <.button label="Delete" color="danger" />
        </div>
      </:col>
    </.table>

    <.card class="mt-5">
      <.card_content category="" class="max-w-sm" heading="Total">
        {@total_transaction.amount}
      </.card_content>
    </.card>

    <%= if @live_action == :modal do %>
      <.modal max_width="md" title="Add transaction">
        <.container max_width="md" class="mx-auto">
          <.form for={@form} phx-submit="submit">
            <.field
              required
              field={@form[:title]}
              placeholder="Transaction title"
              phx-debounce="blur"
              label="Title"
            />
            <.field
              required
              type="number"
              field={@form[:amount]}
              placeholder="The transaction amount"
              phx-debounce="blur"
              label="Amount"
            />

            <.field type="select" field={@form[:category_id]} options={@categories} />
            <div class="flex justify-end">
              <.button label="Save" />
            </div>
          </.form>
        </.container>
      </.modal>
    <% end %>
    """
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("close_modal", _, socket) do
    # Go back to the :index live action
    {:noreply, push_patch(socket, to: ~p"/")}
  end

  @impl true
  def handle_event(
        "submit",
        params,
        socket
      ) do
    case Core.insert_fake_transaction(params) do
      {:ok, _} ->
        transactions = Core.get_transactions()

        {:noreply,
         socket
         |> assign(transactions: transactions)
         |> push_patch(to: ~p"/")}

      {:error, _} ->
        {:noreply,
         socket
         |> put_flash(:error, "Can't insert the transaction")
         |> push_patch(to: ~p"/")}
    end
  end
end
