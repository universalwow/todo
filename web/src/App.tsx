import './App.css'
import { NavLink, Route, Routes } from 'react-router-dom'
import { HomePage } from './pages/HomePage'
import { TodoPage } from './pages/TodoPage'

function App() {
  return (
    <div className="app">
      <header className="appHeader">
        <div className="brand">Uniwow</div>
        <nav className="nav" aria-label="Primary">
          <NavLink to="/" end className={({ isActive }) => (isActive ? 'active' : undefined)}>
            Home
          </NavLink>
          <NavLink to="/todo" className={({ isActive }) => (isActive ? 'active' : undefined)}>
            Todo
          </NavLink>
        </nav>
      </header>

      <main className="appMain">
        <Routes>
          <Route path="/" element={<HomePage />} />
          <Route path="/todo" element={<TodoPage />} />
        </Routes>
      </main>
    </div>
  )
}

export default App
