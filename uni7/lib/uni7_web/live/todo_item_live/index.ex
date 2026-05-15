defmodule Uni7Web.TodoItemLive.Index do
  use Uni7Web, :live_view

  alias Uni7.Todos
  alias Uni7.Todos.TodoItem

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Todos
        <:subtitle>Simple, fast, and persistent.</:subtitle>
      </.header>

      <div class="card bg-base-200 border border-base-300">
        <div class="card-body gap-4">
          <.form
            for={@new_form}
            id="new-todo-form"
            phx-submit="create"
            class="flex flex-col gap-3 sm:flex-row sm:items-end"
          >
            <.input
              field={@new_form[:title]}
              label="New todo"
              placeholder="What do you need to do?"
              autocomplete="off"
              class="grow"
            />
            <div class="sm:pb-1">
              <.input field={@new_form[:completed]} type="checkbox" label="Done" />
            </div>
            <.button variant="primary" class="sm:w-32">Add</.button>
          </.form>

          <div :if={@todo_count == 0} class="text-sm opacity-70">
            No todos yet. Add your first one above.
          </div>

          <ul id="todo_items" phx-update="stream" class="space-y-2">
            <li
              :for={{dom_id, todo_item} <- @streams.todo_items}
              id={dom_id}
              class={[
                "flex items-center gap-3 rounded-box border border-base-300 bg-base-100 px-3 py-2",
                todo_item.completed && "opacity-80"
              ]}
            >
              <input
                type="checkbox"
                class="checkbox checkbox-primary"
                checked={todo_item.completed}
                phx-click="toggle"
                phx-value-id={todo_item.id}
                aria-label="Toggle completion"
              />

              <span class={["text-sm sm:text-base", todo_item.completed && "line-through opacity-60"]}>
                {todo_item.title}
              </span>

              <div class="ml-auto flex items-center gap-2">
                <.link navigate={~p"/todos/#{todo_item}/edit"} class="btn btn-ghost btn-sm">
                  Edit
                </.link>
                <button
                  type="button"
                  class="btn btn-ghost btn-sm text-error"
                  phx-click={JS.push("delete", value: %{id: todo_item.id}) |> hide("##{dom_id}")}
                  data-confirm="Delete this todo?"
                >
                  Delete
                </button>
              </div>
            </li>
          </ul>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    todo_items = list_todo_items()

    {:ok,
     socket
     |> assign(:page_title, "Todos")
     |> assign(:todo_count, length(todo_items))
     |> assign(:new_form, to_form(Todos.change_todo_item(%TodoItem{}), as: :todo_item))
     |> stream(:todo_items, todo_items)}
  end

  @impl true
  def handle_event("create", %{"todo_item" => todo_item_params}, socket) do
    case Todos.create_todo_item(todo_item_params) do
      {:ok, todo_item} ->
        {:noreply,
         socket
         |> stream_insert(:todo_items, todo_item, at: 0)
         |> assign(:todo_count, socket.assigns.todo_count + 1)
         |> assign(:new_form, to_form(Todos.change_todo_item(%TodoItem{}), as: :todo_item))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :new_form, to_form(changeset, as: :todo_item))}
    end
  end

  def handle_event("toggle", %{"id" => id}, socket) do
    todo_item = Todos.get_todo_item!(id)

    case Todos.toggle_todo_item_completed(todo_item) do
      {:ok, todo_item} ->
        {:noreply, stream_insert(socket, :todo_items, todo_item)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Could not update todo. Please try again.")}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    todo_item = Todos.get_todo_item!(id)
    {:ok, _} = Todos.delete_todo_item(todo_item)

    {:noreply,
     socket
     |> stream_delete(:todo_items, todo_item)
     |> assign(:todo_count, max(socket.assigns.todo_count - 1, 0))}
  end

  defp list_todo_items() do
    Todos.list_todo_items()
  end
end
