defmodule TodoWeb.TodoItemLiveTest do
  use TodoWeb.ConnCase

  import Phoenix.LiveViewTest
  import Todo.TodosFixtures

  @create_attrs %{title: "some title"}
  @update_attrs %{title: "some updated title", completed: true}
  @invalid_attrs %{title: ""}
  defp create_todo_item(_) do
    todo_item = todo_item_fixture()

    %{todo_item: todo_item}
  end

  describe "Index" do
    setup [:create_todo_item]

    test "lists all todo_items", %{conn: conn, todo_item: todo_item} do
      {:ok, _index_live, html} = live(conn, ~p"/todos")

      assert html =~ "Todo"
      assert html =~ todo_item.title
    end

    test "saves new todo_item", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/todos")

      assert index_live
             |> form("#new-todo", todo_item: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      html =
        index_live
        |> form("#new-todo", todo_item: @create_attrs)
        |> render_submit()

      assert html =~ "some title"
    end

    test "toggles completion", %{conn: conn, todo_item: todo_item} do
      {:ok, index_live, _html} = live(conn, ~p"/todos")

      html =
        index_live
        |> element("#todo_items-#{todo_item.id} input[type=checkbox]")
        |> render_click()

      assert html =~ todo_item.title
    end

    test "deletes todo_item in listing", %{conn: conn, todo_item: todo_item} do
      {:ok, index_live, _html} = live(conn, ~p"/todos")

      assert index_live
             |> element("#todo_items-#{todo_item.id} button[aria-label='删除']")
             |> render_click()

      refute has_element?(index_live, "#todo_items-#{todo_item.id}")
    end

    test "filters active vs completed", %{conn: conn} do
      active = todo_item_fixture(%{title: "active item", completed: false})
      completed = todo_item_fixture(%{title: "completed item", completed: true})

      {:ok, view, _html} = live(conn, ~p"/todos?filter=active")
      html = render(view)
      assert html =~ active.title
      refute html =~ completed.title

      {:ok, view, _html} = live(conn, ~p"/todos?filter=completed")
      html = render(view)
      assert html =~ completed.title
      refute html =~ active.title
    end
  end

  describe "Show" do
    setup [:create_todo_item]

    test "displays todo_item", %{conn: conn, todo_item: todo_item} do
      {:ok, _show_live, html} = live(conn, ~p"/todos/#{todo_item}")

      assert html =~ "Show Todo item"
      assert html =~ todo_item.title
    end

    test "updates todo_item and returns to show", %{conn: conn, todo_item: todo_item} do
      {:ok, show_live, _html} = live(conn, ~p"/todos/#{todo_item}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
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
