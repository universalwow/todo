defmodule Uni7.Todos do
  @moduledoc """
  The Todos context.
  """

  import Ecto.Query, warn: false

  alias Uni7.Repo
  alias Uni7.Todos.Todo

  @doc """
  Returns the list of todos.
  """
  def list_todos(opts \\ []) do
    order = Keyword.get(opts, :order, desc: :inserted_at)

    Todo
    |> order_by(^order)
    |> Repo.all()
  end

  @doc """
  Gets a single todo.
  """
  def get_todo!(id), do: Repo.get!(Todo, id)

  @doc """
  Creates a todo.
  """
  def create_todo(attrs \\ %{}) do
    %Todo{}
    |> Todo.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a todo.
  """
  def update_todo(%Todo{} = todo, attrs) do
    todo
    |> Todo.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Toggles the completed state of a todo.
  """
  def toggle_todo(%Todo{} = todo) do
    update_todo(todo, %{completed: not todo.completed})
  end

  @doc """
  Deletes a todo.
  """
  def delete_todo(%Todo{} = todo), do: Repo.delete(todo)

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking todo changes.
  """
  def change_todo(%Todo{} = todo, attrs \\ %{}) do
    Todo.changeset(todo, attrs)
  end
end
