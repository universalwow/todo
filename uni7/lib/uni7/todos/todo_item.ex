defmodule Uni7.Todos.TodoItem do
  use Ecto.Schema
  import Ecto.Changeset

  @title_max_length 200

  schema "todo_items" do
    field :title, :string
    field :completed, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(todo_item, attrs) do
    todo_item
    |> cast(attrs, [:title, :completed])
    |> validate_required([:title, :completed])
    |> update_change(:title, &String.trim/1)
    |> validate_length(:title, min: 1, max: @title_max_length)
  end
end
