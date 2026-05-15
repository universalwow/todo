defmodule Todo.Repo.Migrations.CreateTodoItems do
  use Ecto.Migration

  def change do
    create table(:todo_items) do
      add :title, :string
      add :completed, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
