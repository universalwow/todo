defmodule Uni7.Repo.Migrations.CreateTodos do
  use Ecto.Migration

  def change do
    create table(:todos) do
      add :title, :string, null: false
      add :completed, :boolean, null: false, default: false

      timestamps(type: :utc_datetime)
    end

    create index(:todos, [:completed])
  end
end
