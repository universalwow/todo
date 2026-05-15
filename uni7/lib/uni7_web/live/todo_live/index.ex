defmodule Uni7Web.TodoLive.Index do
  use Uni7Web, :live_view

  alias Uni7.Todos
  alias Uni7.Todos.Todo

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="mx-auto w-full max-w-2xl px-4 py-10">
        <div class="mb-6">
          <.header>
            Todos
            <:subtitle>简洁的待办清单，支持新增 / 勾选完成 / 删除，数据持久化。</:subtitle>
            <:actions>
              <.button navigate={~p"/home"}>About</.button>
            </:actions>
          </.header>
        </div>

        <.form for={@form} id="quick-todo-form" phx-change="validate" phx-submit="save">
          <div class="flex flex-col gap-3 sm:flex-row sm:items-end">
            <div class="flex-1">
              <.input
                field={@form[:title]}
                type="text"
                label="New todo"
                placeholder="例如：买牛奶"
              />
            </div>
            <.button variant="primary" phx-disable-with="Adding...">Add</.button>
          </div>
        </.form>

        <div class="mt-6 rounded-box bg-base-200 p-4 shadow-sm">
          <ul class="divide-y divide-base-300">
            <li
              :for={{dom_id, todo} <- @streams.todos}
              id={dom_id}
              class="flex items-start gap-3 py-3"
            >
              <input
                type="checkbox"
                class="checkbox checkbox-primary mt-1"
                checked={todo.completed}
                phx-click="toggle"
                phx-value-id={todo.id}
              />

              <div class="flex-1">
                <div class={["text-base", todo.completed && "line-through opacity-60"]}>
                  {todo.title}
                </div>
              </div>

              <div class="flex items-center gap-2">
                <.link navigate={~p"/todos/#{todo}/edit"} class="link link-hover text-sm">Edit</.link>
                <.link
                  phx-click={JS.push("delete", value: %{id: todo.id}) |> hide("##{dom_id}")}
                  data-confirm="Are you sure?"
                  class="link link-hover text-sm text-error"
                >
                  Delete
                </.link>
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
    {:ok,
     socket
     |> assign(:page_title, "Todos")
     |> assign(:form, to_form(Todos.change_todo(%Todo{})))
     |> stream(:todos, list_todos())}
  end

  @impl true
  def handle_event("validate", %{"todo" => todo_params}, socket) do
    changeset = Todos.change_todo(%Todo{}, todo_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"todo" => todo_params}, socket) do
    case Todos.create_todo(todo_params) do
      {:ok, _todo} ->
        {:noreply,
         socket
         |> assign(:form, to_form(Todos.change_todo(%Todo{})))
         |> stream(:todos, list_todos(), reset: true)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def handle_event("toggle", %{"id" => id}, socket) do
    todo = Todos.get_todo!(id)
    {:ok, _todo} = Todos.toggle_todo(todo)

    {:noreply, stream(socket, :todos, list_todos(), reset: true)}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    todo = Todos.get_todo!(id)
    {:ok, _} = Todos.delete_todo(todo)

    {:noreply, stream_delete(socket, :todos, todo)}
  end

  defp list_todos() do
    Todos.list_todos()
  end
end
