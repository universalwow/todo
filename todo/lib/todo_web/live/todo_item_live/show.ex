defmodule TodoWeb.TodoItemLive.Show do
  use TodoWeb, :live_view

  alias Todo.Todos

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Todo item {@todo_item.id}
        <:subtitle>This is a todo_item record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/todos"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/todos/#{@todo_item}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit todo_item
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Title">{@todo_item.title}</:item>
        <:item title="Completed">{@todo_item.completed}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Todo item")
     |> assign(:todo_item, Todos.get_todo_item!(id))}
  end
end
