defmodule Uni7Web.TodoLive do
  use Uni7Web, :live_view

  alias Uni7.Todos
  alias Uni7.Todos.Todo

  @impl true
  def mount(_params, _session, socket) do
    todos = Todos.list_todos(order: [desc: :inserted_at])

    {:ok,
     socket
     |> stream(:todos, todos)
     |> assign(:counts, counts(todos))
     |> assign_form(Todos.change_todo(%Todo{}))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="space-y-8">
        <div class="space-y-2">
          <h1 class="text-2xl font-semibold tracking-tight text-base-content">Todo 列表</h1>
          <p class="text-sm text-base-content/70">
            {@counts.remaining} remaining · {@counts.total} total
          </p>
        </div>

        <section class="rounded-2xl border border-base-300 bg-base-100/70 shadow-sm backdrop-blur">
          <div class="p-4 sm:p-5">
            <.form for={@form} id="todo-form" phx-change="validate" phx-submit="save">
              <div class="flex flex-col gap-3 sm:flex-row sm:items-end">
                <div class="flex-1">
                  <.input
                    field={@form[:title]}
                    id="todo-title"
                    type="text"
                    placeholder="新增一个待办事项…"
                    autocomplete="off"
                  />
                </div>

                <button
                  type="submit"
                  class="inline-flex items-center justify-center rounded-lg bg-primary px-4 py-2.5 text-sm font-semibold text-primary-content shadow-sm transition hover:brightness-110 active:brightness-95 disabled:opacity-60 phx-submit-loading:opacity-60"
                >
                  <.icon name="hero-plus-micro" class="mr-2 size-4" /> 新增
                </button>
              </div>
            </.form>
          </div>

          <div class="border-t border-base-300">
            <div id="todos" phx-update="stream" class="divide-y divide-base-300">
              <div
                id="todos-empty"
                class="hidden p-6 text-center text-sm text-base-content/60 only:block"
              >
                还没有待办事项。先新增一个吧。
              </div>

              <div
                :for={{dom_id, todo} <- @streams.todos}
                id={dom_id}
                class="group flex items-start gap-3 p-4 sm:p-5"
              >
                <button
                  id={"todo-toggle-#{todo.id}"}
                  type="button"
                  class={[
                    "mt-0.5 inline-flex size-5 items-center justify-center rounded border transition",
                    todo.completed && "border-success bg-success text-success-content",
                    not todo.completed && "border-base-300 bg-base-100 hover:border-base-content/30"
                  ]}
                  phx-click="toggle"
                  phx-value-id={todo.id}
                  aria-label={if(todo.completed, do: "Mark as incomplete", else: "Mark as complete")}
                >
                  <.icon
                    :if={todo.completed}
                    name="hero-check-micro"
                    class="size-4"
                  />
                </button>

                <div class="min-w-0 flex-1">
                  <p class={[
                    "break-words text-sm leading-6 text-base-content transition",
                    todo.completed && "line-through opacity-60"
                  ]}>
                    {todo.title}
                  </p>
                  <p class="mt-1 text-xs text-base-content/50">
                    {Calendar.strftime(todo.inserted_at, "%Y-%m-%d %H:%M")}
                  </p>
                </div>

                <button
                  id={"todo-delete-#{todo.id}"}
                  type="button"
                  class="inline-flex items-center justify-center rounded-lg p-2 text-base-content/60 transition hover:bg-base-200 hover:text-base-content focus:outline-none focus:ring-2 focus:ring-primary/40"
                  phx-click="delete"
                  phx-value-id={todo.id}
                  aria-label="Delete todo"
                >
                  <.icon name="hero-trash-micro" class="size-4" />
                </button>
              </div>
            </div>
          </div>
        </section>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("validate", %{"todo" => todo_params}, socket) do
    changeset =
      %Todo{}
      |> Todos.change_todo(todo_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"todo" => todo_params}, socket) do
    case Todos.create_todo(todo_params) do
      {:ok, todo} ->
        todos = Todos.list_todos(order: [desc: :inserted_at])

        {:noreply,
         socket
         |> stream_insert(:todos, todo, at: 0)
         |> assign(:counts, counts(todos))
         |> assign_form(Todos.change_todo(%Todo{}))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  def handle_event("toggle", %{"id" => id}, socket) do
    todo = Todos.get_todo!(id)

    case Todos.toggle_todo(todo) do
      {:ok, updated} ->
        todos = Todos.list_todos(order: [desc: :inserted_at])

        {:noreply,
         socket
         |> stream_insert(:todos, updated)
         |> assign(:counts, counts(todos))}

      {:error, _changeset} ->
        {:noreply, socket}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    todo = Todos.get_todo!(id)
    {:ok, _} = Todos.delete_todo(todo)

    todos = Todos.list_todos(order: [desc: :inserted_at])

    {:noreply,
     socket
     |> stream_delete(:todos, todo)
     |> assign(:counts, counts(todos))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset, as: "todo"))
  end

  defp counts(todos) do
    total = length(todos)
    remaining = Enum.count(todos, &(!&1.completed))
    %{total: total, remaining: remaining}
  end
end
