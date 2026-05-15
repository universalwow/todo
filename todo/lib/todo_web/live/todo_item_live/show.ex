defmodule TodoWeb.TodoItemLive.Show do
  use TodoWeb, :live_view

  alias Todo.Todos

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        待办详情
        <:subtitle>查看并编辑你的待办</:subtitle>
        <:actions>
          <.button navigate={~p"/todos"} aria-label="返回列表">
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/todos/#{@todo_item}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> 编辑
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="内容">{@todo_item.title}</:item>
        <:item title="状态">{if @todo_item.completed, do: "已完成", else: "未完成"}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "待办详情")
     |> assign(:todo_item, Todos.get_todo_item!(id))}
  end
end
