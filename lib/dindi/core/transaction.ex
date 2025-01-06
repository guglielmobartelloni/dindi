defmodule Dindi.Core.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  schema "transactions" do
    field :title, :string
    field :amount, :decimal
    belongs_to :category, Dindi.Core.Category

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:title, :amount, :category_id])
    |> validate_required([:title, :amount, :category_id])
  end
end
