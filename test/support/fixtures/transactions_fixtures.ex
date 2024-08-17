defmodule Dindi.TransactionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Dindi.Transactions` context.
  """

  @doc """
  Generate a category.
  """
  def category_fixture(attrs \\ %{}) do
    {:ok, category} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Dindi.Transactions.create_category()

    category
  end

  @doc """
  Generate a transaction.
  """
  def transaction_fixture(attrs \\ %{}) do
    {:ok, transaction} =
      attrs
      |> Enum.into(%{
        amount: 42,
        date: ~N[2024-08-16 10:28:00],
        description: "some description"
      })
      |> Dindi.Transactions.create_transaction()

    transaction
  end
end
