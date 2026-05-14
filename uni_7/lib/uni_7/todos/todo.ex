defmodule Uni7.Todos.Todo do
  use Ecto.Schema
  import Ecto.Changeset

  schema "todos" do
    field :title, :string
    field :completed, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  def changeset(todo, attrs) do
    todo
    |> cast(attrs, [:title, :completed])
    |> update_change(:title, fn
      nil -> nil
      title -> String.trim(title)
    end)
    |> validate_required([:title, :completed])
    |> validate_length(:title, min: 1, max: 200)
  end
end
