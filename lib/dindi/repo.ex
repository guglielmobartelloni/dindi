defmodule Dindi.Repo do
  use Ecto.Repo,
    otp_app: :dindi,
    adapter: Ecto.Adapters.Postgres
end
