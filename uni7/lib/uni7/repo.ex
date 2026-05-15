defmodule Uni7.Repo do
  use Ecto.Repo,
    otp_app: :uni7,
    adapter: Ecto.Adapters.SQLite3
end
