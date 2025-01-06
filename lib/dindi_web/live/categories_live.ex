defmodule DindiWeb.CategoriesLive do
  alias Dindi.Core.Category
  alias Dindi.Repo
  use DindiWeb, :live_view

  def mount(_, _, socket) do
    categories = Repo.all(Category)
    {:ok, socket |> assign(categories: categories)}
  end

  def render(assigns) do
    ~H"""
    <.h1>Categories</.h1>
    <.table
      id="posts"
      row_id={fn category -> "row_#{category.id}" end}
      rows={@categories}
    >
      <:col :let={category} label="Name">{category.name}</:col>
      <:col class="w-64">
        <div class="flex gap-2 items-center justify-end">
          <.button label="Delete" color="danger" />
        </div>
      </:col>
    </.table>
    """
  end
end

