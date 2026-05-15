defmodule Uni7Web.TodoItemLive.Form do
  use Uni7Web, :live_view

  alias Uni7.Todos
  alias Uni7.Todos.TodoItem

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Keep it short and actionable.</:subtitle>
      </.header>

      <.form for={@form} id="todo_item-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:completed]} type="checkbox" label="Completed" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save</.button>
          <.button navigate={return_path(@return_to, @todo_item)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    todo_item = Todos.get_todo_item!(id)

    socket
    |> assign(:page_title, "Edit Todo item")
    |> assign(:todo_item, todo_item)
    |> assign(:form, to_form(Todos.change_todo_item(todo_item)))
  end

  defp apply_action(socket, :new, _params) do
    todo_item = %TodoItem{}

    socket
    |> assign(:page_title, "New Todo item")
    |> assign(:todo_item, todo_item)
    |> assign(:form, to_form(Todos.change_todo_item(todo_item)))
  end

  @impl true
  def handle_event("validate", %{"todo_item" => todo_item_params}, socket) do
    changeset = Todos.change_todo_item(socket.assigns.todo_item, todo_item_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"todo_item" => todo_item_params}, socket) do
    save_todo_item(socket, socket.assigns.live_action, todo_item_params)
  end

  defp save_todo_item(socket, :edit, todo_item_params) do
    case Todos.update_todo_item(socket.assigns.todo_item, todo_item_params) do
      {:ok, todo_item} ->
        {:noreply,
         socket
         |> put_flash(:info, "Todo item updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, todo_item))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_todo_item(socket, :new, todo_item_params) do
    case Todos.create_todo_item(todo_item_params) do
      {:ok, todo_item} ->
        {:noreply,
         socket
         |> put_flash(:info, "Todo item created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, todo_item))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _todo_item), do: ~p"/todos"
  defp return_path("show", todo_item), do: ~p"/todos/#{todo_item}"
end
