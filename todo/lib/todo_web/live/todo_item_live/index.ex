defmodule TodoWeb.TodoItemLive.Index do
  use TodoWeb, :live_view

  alias Todo.Todos
  alias Todo.Todos.TodoItem

  @impl true
  def render(assigns) do
    assigns = assign(assigns, :title_errors, translate_errors(assigns.form.source.errors, :title))

    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Todo
        <:subtitle>简洁的待办列表：新增、完成、删除</:subtitle>
      </.header>

      <div class="card bg-base-100 border border-base-200 shadow-sm">
        <div class="card-body gap-4">
          <.form for={@form} id="new-todo" phx-change="validate" phx-submit="save">
            <div class="w-full">
              <div class="join w-full">
                <input
                  type="text"
                  name={@form[:title].name}
                  id={@form[:title].id}
                  value={Phoenix.HTML.Form.normalize_value("text", @form[:title].value)}
                  placeholder="添加一个待办…"
                  autocomplete="off"
                  class={[
                    "input input-bordered join-item w-full",
                    @title_errors != [] && "input-error"
                  ]}
                />
                <button type="submit" class="btn btn-primary join-item" phx-disable-with="Adding...">
                  添加
                </button>
              </div>

              <p :for={msg <- @title_errors} class="mt-1.5 text-sm text-error">
                {msg}
              </p>
            </div>
          </.form>

          <div class="tabs tabs-boxed w-fit">
            <.link patch={~p"/todos"} class={tab_class(@filter == :all)}>全部</.link>
            <.link patch={~p"/todos?filter=active"} class={tab_class(@filter == :active)}>未完成</.link>
            <.link patch={~p"/todos?filter=completed"} class={tab_class(@filter == :completed)}>
              已完成
            </.link>
          </div>

          <div :if={Enum.empty?(@streams.todo_items.inserts)} class="text-sm text-base-content/70">
            还没有待办，先添加一个吧。
          </div>

          <ul id="todo_items" phx-update="stream" class="divide-y divide-base-200">
            <li
              :for={{dom_id, todo_item} <- @streams.todo_items}
              id={dom_id}
              class="flex items-center gap-3 py-3"
            >
              <input
                type="checkbox"
                class="checkbox checkbox-sm"
                checked={todo_item.completed}
                phx-click="toggle"
                phx-value-id={todo_item.id}
              />

              <div class={["flex-1 text-sm", todo_item.completed && "line-through opacity-60"]}>
                {todo_item.title}
              </div>

              <button
                type="button"
                class="btn btn-ghost btn-sm text-error"
                phx-click={JS.push("delete", value: %{id: todo_item.id}) |> hide("##{dom_id}")}
                data-confirm="确认删除？"
                aria-label="删除"
              >
                <.icon name="hero-x-mark" class="size-4" />
              </button>
            </li>
          </ul>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    filter = parse_filter(params["filter"])

    {:ok,
     socket
     |> assign(:page_title, "Todo")
     |> assign(:filter, filter)
     |> assign(:form, to_form(Todos.change_todo_item(%TodoItem{})))
     |> stream(:todo_items, Todos.list_todo_items(filter: filter))}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    filter = parse_filter(params["filter"])

    {:noreply,
     socket
     |> assign(:filter, filter)
     |> stream(:todo_items, Todos.list_todo_items(filter: filter), reset: true)}
  end

  @impl true
  def handle_event("validate", %{"todo_item" => todo_item_params}, socket) do
    changeset = Todos.change_todo_item(%TodoItem{}, todo_item_params)
    {:noreply, assign(socket, :form, to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"todo_item" => todo_item_params}, socket) do
    case Todos.create_todo_item(todo_item_params) do
      {:ok, todo_item} ->
        {:noreply,
         socket
         |> assign(:form, to_form(Todos.change_todo_item(%TodoItem{})))
         |> stream_insert(:todo_items, todo_item, at: 0)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  def handle_event("toggle", %{"id" => id}, socket) do
    todo_item = Todos.get_todo_item!(id)
    {:ok, todo_item} = Todos.toggle_todo_item(todo_item)

    {:noreply, stream_insert(socket, :todo_items, todo_item)}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    todo_item = Todos.get_todo_item!(id)
    {:ok, _} = Todos.delete_todo_item(todo_item)

    {:noreply, stream_delete(socket, :todo_items, todo_item)}
  end

  defp parse_filter("active"), do: :active
  defp parse_filter("completed"), do: :completed
  defp parse_filter(_), do: :all

  defp tab_class(true), do: "tab tab-active"
  defp tab_class(false), do: "tab"
end
