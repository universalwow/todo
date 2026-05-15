defmodule Uni7.Todos.Todo do
  use Ecto.Schema
  import Ecto.Changeset

  schema "todos" do
    field :title, :string
    field :completed, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(todo, attrs) do
    todo
    |> cast(attrs, [:title, :completed])
    |> update_change(:title, fn
      title when is_binary(title) -> String.trim(title)
      title -> title
    end)
    |> validate_required([:title])
    |> validate_length(:title, min: 1, max: 140)
  end
end
