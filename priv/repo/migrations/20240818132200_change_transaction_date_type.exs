defmodule Dindi.Repo.Migrations.ChangeTransactionDateType do
  use Ecto.Migration

  def change do

    alter table(:transactions) do
      modify :date, :date
      
    end

  end
end
