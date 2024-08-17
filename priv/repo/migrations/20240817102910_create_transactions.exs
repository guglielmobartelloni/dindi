defmodule Dindi.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :description, :text
      add :date, :naive_datetime
      add :amount, :decimal
      add :category, references(:categories, on_delete: :nothing)
      add :account, references(:accounts, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:transactions, [:category, :account])
  end
end
