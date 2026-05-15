defmodule Uni7.TodosFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Uni7.Todos` context.
  """

  @doc """
  Generate a todo_item.
  """
  def todo_item_fixture(attrs \\ %{}) do
    {:ok, todo_item} =
      attrs
      |> Enum.into(%{
        completed: true,
        title: "some title"
      })
      |> Uni7.Todos.create_todo_item()

    todo_item
  end
end
