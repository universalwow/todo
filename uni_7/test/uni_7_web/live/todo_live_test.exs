defmodule Uni7Web.TodoLiveTest do
  use Uni7Web.ConnCase

  import Phoenix.LiveViewTest
  import Uni7.TodosFixtures

  defp create_todo(_) do
    todo = todo_fixture(%{title: "existing todo", completed: false})

    %{todo: todo}
  end

  describe "/todos" do
    setup [:create_todo]

    test "lists all todos", %{conn: conn, todo: todo} do
      {:ok, _index_live, html} = live(conn, ~p"/todos")

      assert html =~ "Todo 列表"
      assert html =~ todo.title
    end

    test "validates and saves a new todo", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/todos")

      assert view
             |> form("#todo-form", todo: %{title: ""})
             |> render_change() =~ "can&#39;t be blank"

      view
      |> form("#todo-form", todo: %{title: "buy milk"})
      |> render_submit()

      assert render(view) =~ "buy milk"
    end

    test "toggles completion", %{conn: conn, todo: todo} do
      {:ok, view, _html} = live(conn, ~p"/todos")

      refute has_element?(view, "#todos-#{todo.id} p.line-through")

      view
      |> element("#todo-toggle-#{todo.id}")
      |> render_click()

      assert has_element?(view, "#todos-#{todo.id} p.line-through")
    end

    test "deletes a todo", %{conn: conn, todo: todo} do
      {:ok, view, _html} = live(conn, ~p"/todos")

      assert has_element?(view, "#todos-#{todo.id}")

      view
      |> element("#todo-delete-#{todo.id}")
      |> render_click()

      refute has_element?(view, "#todos-#{todo.id}")
    end
  end
end
