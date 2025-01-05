defmodule Dindi.Account.Connection do
  use Ecto.Schema
  import Ecto.Changeset

  schema "connections" do
    field :api_ref_id, :string
    field :account_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(connection, attrs) do
    connection
    |> cast(attrs, [:api_ref_id])
    |> validate_required([:api_ref_id])
  end
end
