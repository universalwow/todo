defmodule Uni7Web.TodoItemLiveTest do
  use Uni7Web.ConnCase

  import Phoenix.LiveViewTest
  import Uni7.TodosFixtures

  @create_attrs %{title: "some title", completed: true}
  @update_attrs %{title: "some updated title", completed: false}
  @invalid_attrs %{title: nil, completed: false}
  defp create_todo_item(_) do
    todo_item = todo_item_fixture()

    %{todo_item: todo_item}
  end

  describe "Index" do
    setup [:create_todo_item]

    test "lists all todo_items", %{conn: conn, todo_item: todo_item} do
      {:ok, _index_live, html} = live(conn, ~p"/todos")

      assert html =~ "Todos"
      assert html =~ todo_item.title
    end

    test "saves new todo_item", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/todos")

      assert index_live
             |> form("#new-todo-form", todo_item: @invalid_attrs)
             |> render_submit() =~ "can&#39;t be blank"

      html =
        index_live
        |> form("#new-todo-form", todo_item: @create_attrs)
        |> render_submit()

      assert html =~ "some title"
    end

    test "updates todo_item in listing", %{conn: conn, todo_item: todo_item} do
      {:ok, index_live, _html} = live(conn, ~p"/todos")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#todo_items-#{todo_item.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/todos/#{todo_item}/edit")

      assert render(form_live) =~ "Edit Todo item"

      assert form_live
             |> form("#todo_item-form", todo_item: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#todo_item-form", todo_item: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/todos")

      html = render(index_live)
      assert html =~ "Todo item updated successfully"
      assert html =~ "some updated title"
    end

    test "deletes todo_item in listing", %{conn: conn, todo_item: todo_item} do
      {:ok, index_live, _html} = live(conn, ~p"/todos")

      assert index_live
             |> element("#todo_items-#{todo_item.id} button", "Delete")
             |> render_click()

      refute has_element?(index_live, "#todo_items-#{todo_item.id}")
    end
  end

  describe "Show" do
    setup [:create_todo_item]

    test "displays todo_item", %{conn: conn, todo_item: todo_item} do
      {:ok, _show_live, html} = live(conn, ~p"/todos/#{todo_item}")

      assert html =~ todo_item.title
    end

    test "updates todo_item and returns to show", %{conn: conn, todo_item: todo_item} do
      {:ok, show_live, _html} = live(conn, ~p"/todos/#{todo_item}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit todo")
               |> render_click()
               |> follow_redirect(conn, ~p"/todos/#{todo_item}/edit?return_to=show")

      assert render(form_live) =~ "Edit Todo item"

      assert form_live
             |> form("#todo_item-form", todo_item: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#todo_item-form", todo_item: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/todos/#{todo_item}")

      html = render(show_live)
      assert html =~ "Todo item updated successfully"
      assert html =~ "some updated title"
    end
  end
end
