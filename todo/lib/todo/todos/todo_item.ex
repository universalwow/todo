defmodule Todo.Todos.TodoItem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "todo_items" do
    field :title, :string
    field :completed, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(todo_item, attrs) do
    todo_item
    |> cast(attrs, [:title, :completed])
    |> update_change(:title, fn
      nil -> nil
      title -> String.trim(title)
    end)
    |> validate_required([:title])
    |> validate_length(:title, min: 1, max: 200)
  end
end
