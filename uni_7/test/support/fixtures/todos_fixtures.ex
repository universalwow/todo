defmodule Uni7.TodosFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Uni7.Todos` context.
  """

  @doc """
  Generate a todo.
  """
  def todo_fixture(attrs \\ %{}) do
    {:ok, todo} =
      attrs
      |> Enum.into(%{
        completed: true,
        title: "some title"
      })
      |> Uni7.Todos.create_todo()

    todo
  end
end
