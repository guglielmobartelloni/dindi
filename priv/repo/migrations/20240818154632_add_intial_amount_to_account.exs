defmodule Dindi.Repo.Migrations.AddIntialAmountToAccount do
  use Ecto.Migration

  def change do
    alter table(:accounts) do
      add :initial_amount, :decimal
    end
  end
end
