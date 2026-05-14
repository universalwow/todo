import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { TodoPage } from './TodoPage'

beforeEach(() => {
  localStorage.clear()
})

test('add, toggle, delete todo', async () => {
  const user = userEvent.setup()
  render(<TodoPage />)

  expect(screen.getByText('No todos yet')).toBeInTheDocument()

  await user.type(screen.getByLabelText('Add a todo'), 'Write tests')
  await user.click(screen.getByRole('button', { name: 'Add' }))

  const todoText = screen.getByText('Write tests')
  expect(todoText).toBeInTheDocument()

  await user.click(screen.getByRole('checkbox', { name: 'Mark as completed' }))
  expect(todoText).toHaveClass('completed')

  await user.click(screen.getByRole('button', { name: /Delete todo: Write tests/i }))
  expect(screen.getByText('No todos yet')).toBeInTheDocument()
})

test('persists todos across renders', async () => {
  const user = userEvent.setup()
  const { unmount } = render(<TodoPage />)

  await user.type(screen.getByLabelText('Add a todo'), 'Persistent item')
  await user.click(screen.getByRole('button', { name: 'Add' }))
  expect(screen.getByText('Persistent item')).toBeInTheDocument()

  unmount()
  render(<TodoPage />)

  expect(screen.getByText('Persistent item')).toBeInTheDocument()
})

