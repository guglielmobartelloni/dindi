defmodule DindiWeb.CategoriesLive.Index do
  use DindiWeb, :live_view

  alias Dindi.Transactions.Category
  alias Dindi.Transactions

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container-md mx-auto mb-5">
      <div class="card bg-base-300 shadow-xl p-6 mx-auto">
        <.simple_form
          for={@form}
          phx-change="validate"
          phx-submit="save"
          class="card text-base-content grid lg:grid-cols-6 grid-cols-2 gap-4"
        >
          <.input field={@form[:name]} label="Name" />
          <.button class="btn-primary">Save</.button>
        </.simple_form>
      </div>
    </div>

    <div class="container-md mx-auto">
      <.header class="mb-3">
        <h1 class="text-3xl font-semibold leading-normal">Categories</h1>
        <:actions>
          <.simple_form
            for={@date_form}
            phx-change="change-date"
            class="card grid grid-cols-2 gap-4 content-evenly"
          >
            <.input
              field={@date_form[:start]}
              type="date"
              value={Date.beginning_of_month(Date.utc_today())}
            />
            <.input field={@date_form[:end]} type="date" value={Date.end_of_month(Date.utc_today())} />
          </.simple_form>
        </:actions>
      </.header>

      <div class="relative overflow-x-auto shadow-md sm:rounded-lg">
        <table class="w-full text-sm text-left text-base-content">
          <thead class="text-xs uppercase bg-base-200">
            <tr class="">
              <th scope="col" class="p-4 py-3">Name</th>
              <th scope="col" class="p-4 py-3">Account</th>
              <th scope="col" class="p-4 py-3">Action</th>
            </tr>
          </thead>
          <tbody id="table-body" class="bg-base-300" phx-update="stream">
            <tr
              :for={{id, category} <- @streams.categories}
              id={id}
              class="border-b border-base-100 "
            >
              <td class="px-4 py-4"><%= category.name %></td>
              <td class="px-4 py-4">Dummy</td>
              <td class="px-4 py-4">
                <.link
                  phx-value-id={category.id}
                  phx-click="delete-category"
                  data-confirm="Are you sure?"
                  class="font-medium text-blue-600 dark:text-blue-500 hover:underline"
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
     stream(socket, :categories, Transactions.list_categories())
     |> assign(:form, Transactions.change_category(%Category{}) |> to_form())
     |> assign(:date_form, to_form(%{"start" => "", "end" => ""}))
     |> assign(:types, [{"+", :gain}, {"-", :expense}])
    }
  end

  @impl true
  def handle_event("validate", %{"category" => category_params}, socket) do
    form =
      %Category{}
      |> Transactions.change_category(category_params)
      |> to_form(action: :validate)

    socket = socket |> assign(form: form)

    {:noreply, socket}
  end

  @impl true
  def handle_event("save", %{"category" => category_params}, socket) do
    case Transactions.create_category(category_params) do
      {:ok, category} ->

        {:noreply,
         socket
         |> stream_insert(:categories, category,
           at: 0
         )
         |> assign(:form, Transactions.change_category(%Category{}) |> to_form())
         |> put_flash(:info, "Category created successfully!")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: changeset)}
    end
  end

  @impl true
  def handle_event("delete-category", %{"id" => id}, socket) do
    to_be_deleted_category = Transactions.get_category!(id)

    case Transactions.delete_category(to_be_deleted_category) do
      {:ok, _} ->

        {:noreply,
         socket
         |> stream_delete(:categories, to_be_deleted_category)
         |> put_flash(:info, "Category deleted successfully!")}

      {:error, _} ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("change-date", %{"start" => start_date, "end" => end_date}, socket) do
    filtered_trans = Transactions.list_transactions_by_date(start_date, end_date)

    socket =
      socket
      |> stream(:transactions, filtered_trans, reset: true)
      |> put_flash(:info, "Filtered transactions")

    {:noreply, socket}
  end

end
