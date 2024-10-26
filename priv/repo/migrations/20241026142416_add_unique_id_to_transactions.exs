defmodule Dindi.Repo.Migrations.AddUniqueIdToTransactions do
  use Ecto.Migration

  def change do
   # Method 2: Alter existing table to add unique column
    alter table(:transactions) do
      add :unique_id, :string
    end
    create unique_index(:transactions, [:unique_id])

  end

end
