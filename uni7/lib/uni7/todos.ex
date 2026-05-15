defmodule Uni7.Todos do
  @moduledoc """
  The Todos context.
  """

  import Ecto.Query, warn: false
  alias Uni7.Repo

  alias Uni7.Todos.TodoItem

  @doc """
  Returns the list of todo_items.

  ## Examples

      iex> list_todo_items()
      [%TodoItem{}, ...]

  """
  def list_todo_items do
    Repo.all(from t in TodoItem, order_by: [asc: t.completed, desc: t.inserted_at])
  end

  @doc """
  Toggles completion status of a todo_item.
  """
  def toggle_todo_item_completed(%TodoItem{} = todo_item) do
    update_todo_item(todo_item, %{completed: !todo_item.completed})
  end

  @doc """
  Gets a single todo_item.

  Raises `Ecto.NoResultsError` if the Todo item does not exist.

  ## Examples

      iex> get_todo_item!(123)
      %TodoItem{}

      iex> get_todo_item!(456)
      ** (Ecto.NoResultsError)

  """
  def get_todo_item!(id), do: Repo.get!(TodoItem, id)

  @doc """
  Creates a todo_item.

  ## Examples

      iex> create_todo_item(%{field: value})
      {:ok, %TodoItem{}}

      iex> create_todo_item(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_todo_item(attrs) do
    %TodoItem{}
    |> TodoItem.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a todo_item.

  ## Examples

      iex> update_todo_item(todo_item, %{field: new_value})
      {:ok, %TodoItem{}}

      iex> update_todo_item(todo_item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_todo_item(%TodoItem{} = todo_item, attrs) do
    todo_item
    |> TodoItem.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a todo_item.

  ## Examples

      iex> delete_todo_item(todo_item)
      {:ok, %TodoItem{}}

      iex> delete_todo_item(todo_item)
      {:error, %Ecto.Changeset{}}

  """
  def delete_todo_item(%TodoItem{} = todo_item) do
    Repo.delete(todo_item)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking todo_item changes.

  ## Examples

      iex> change_todo_item(todo_item)
      %Ecto.Changeset{data: %TodoItem{}}

  """
  def change_todo_item(%TodoItem{} = todo_item, attrs \\ %{}) do
    TodoItem.changeset(todo_item, attrs)
  end
end
