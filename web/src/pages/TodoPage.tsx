import { useEffect, useMemo, useState } from 'react'

type Todo = {
  id: string
  text: string
  completed: boolean
  createdAt: number
}

const STORAGE_KEY = 'uni-7.todos.v1'

function loadTodos(): Todo[] {
  try {
    const raw = localStorage.getItem(STORAGE_KEY)
    if (!raw) return []
    const parsed: unknown = JSON.parse(raw)
    if (!Array.isArray(parsed)) return []
    return parsed
      .filter((t): t is Todo => {
        return (
          typeof t === 'object' &&
          t !== null &&
          typeof (t as Todo).id === 'string' &&
          typeof (t as Todo).text === 'string' &&
          typeof (t as Todo).completed === 'boolean' &&
          typeof (t as Todo).createdAt === 'number'
        )
      })
      .slice(0, 500)
  } catch {
    return []
  }
}

function newId() {
  if (typeof crypto !== 'undefined' && 'randomUUID' in crypto) {
    return crypto.randomUUID()
  }
  return `${Date.now()}-${Math.random().toString(16).slice(2)}`
}

export function TodoPage() {
  const [todos, setTodos] = useState<Todo[]>(() => loadTodos())
  const [draft, setDraft] = useState('')

  useEffect(() => {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(todos))
  }, [todos])

  const remainingCount = useMemo(() => todos.filter((t) => !t.completed).length, [todos])

  function addTodo() {
    const text = draft.trim()
    if (!text) return
    setTodos((prev) => [{ id: newId(), text, completed: false, createdAt: Date.now() }, ...prev])
    setDraft('')
  }

  function toggleTodo(id: string) {
    setTodos((prev) =>
      prev.map((t) => (t.id === id ? { ...t, completed: !t.completed } : t)),
    )
  }

  function deleteTodo(id: string) {
    setTodos((prev) => prev.filter((t) => t.id !== id))
  }

  function clearCompleted() {
    setTodos((prev) => prev.filter((t) => !t.completed))
  }

  return (
    <section className="card">
      <div className="cardHeader">
        <h1 className="h1">Todo</h1>
        <div className="muted" aria-label="Remaining todos">
          {remainingCount} remaining
        </div>
      </div>

      <div className="row">
        <label className="srOnly" htmlFor="todoInput">
          Add a todo
        </label>
        <input
          id="todoInput"
          className="input"
          value={draft}
          onChange={(e) => setDraft(e.target.value)}
          placeholder="What do you need to do?"
          onKeyDown={(e) => {
            if (e.key === 'Enter') addTodo()
          }}
          autoComplete="off"
        />
        <button type="button" className="btn primary" onClick={addTodo} disabled={!draft.trim()}>
          Add
        </button>
      </div>

      {todos.length === 0 ? (
        <div className="emptyState">
          <div className="emptyTitle">No todos yet</div>
          <div className="muted">Add your first task above.</div>
        </div>
      ) : (
        <>
          <ul className="list" aria-label="Todo list">
            {todos.map((t) => (
              <li key={t.id} className="listItem">
                <label className="todoLabel">
                  <input
                    type="checkbox"
                    checked={t.completed}
                    onChange={() => toggleTodo(t.id)}
                    aria-label={t.completed ? 'Mark as not completed' : 'Mark as completed'}
                  />
                  <span className={t.completed ? 'todoText completed' : 'todoText'}>{t.text}</span>
                </label>
                <button
                  type="button"
                  className="btn"
                  onClick={() => deleteTodo(t.id)}
                  aria-label={`Delete todo: ${t.text}`}
                >
                  Delete
                </button>
              </li>
            ))}
          </ul>

          <div className="actions">
            <button
              type="button"
              className="btn"
              onClick={clearCompleted}
              disabled={!todos.some((t) => t.completed)}
            >
              Clear completed
            </button>
          </div>
        </>
      )}
    </section>
  )
}

