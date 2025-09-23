-- Insert Your First Phoenix App into SQLite database
-- Run this with: sqlite3 skimsafe_blogg_dev.sqlite3 < insert_phoenix_app.sql

INSERT INTO posts (
    id,
    title,
    slug,
    excerpt,
    content,
    author,
    author_email,
    tags,
    featured,
    published,
    published_at,
    read_time_minutes,
    view_count,
    inserted_at,
    updated_at
) VALUES (
    'fedcba98-7654-3210-fedc-ba9876543210',
    'Your First Phoenix App',
    'first-phoenix-app',
    'Ready to build your first Phoenix application? This hands-on tutorial will guide you through creating a complete task management web application from scratch, demonstrating Phoenix''s core features including LiveView, database operations, and real-time updates.',
    '# Your First Phoenix App

Ready to build your first Phoenix application? This hands-on tutorial will guide you through creating a complete web application from scratch. We''ll build a simple task management app that demonstrates Phoenix''s core features including LiveView, database operations, and real-time updates.

## Prerequisites

Before we start, make sure you have:

1. **Elixir and Phoenix installed** - Follow our [Phoenix Installation Guide](/posts/phoenix-installation)
2. **Basic Elixir knowledge** - Check out [Elixir Basics for Beginners](/posts/elixir-basics)
3. **PostgreSQL running** (or SQLite for simpler setup)
4. **A text editor** with Elixir support

## Project Overview

We''ll build **TaskTracker**, a simple task management application with these features:

- ✅ Create, read, update, and delete tasks
- ✅ Mark tasks as complete/incomplete
- ✅ Real-time updates using LiveView
- ✅ Form validation and error handling
- ✅ Clean, responsive UI with Tailwind CSS

## Step 1: Create the Phoenix Project

Let''s start by generating a new Phoenix application:

```bash
mix phx.new task_tracker
cd task_tracker
```

When prompted, choose:
- **Fetch and install dependencies?** → Yes (Y)
- **Generate a .gitignore file?** → Yes (Y)

For this tutorial, we''ll use SQLite for simplicity, but you can use PostgreSQL by leaving the defaults.

## Step 2: Database Setup

If you''re using the default PostgreSQL setup, make sure PostgreSQL is running and create the database:

```bash
mix ecto.setup
```

For SQLite (simpler option), update your `config/dev.exs`:

```elixir
config :task_tracker, TaskTracker.Repo,
  adapter: Ecto.Adapters.SQLite3,
  database: "task_tracker_dev.sqlite3"
```

## Step 3: Generate the Task Schema

Let''s create our Task model with a migration:

```bash
mix phx.gen.schema Task tasks title:string description:text completed:boolean
```

This generates:
- Migration file in `priv/repo/migrations/`
- Schema module in `lib/task_tracker/task.ex`

Let''s examine the generated schema and enhance it:

```elixir
# lib/task_tracker/task.ex
defmodule TaskTracker.Task do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tasks" do
    field :title, :string
    field :description, :string
    field :completed, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:title, :description, :completed])
    |> validate_required([:title])
    |> validate_length(:title, min: 3, max: 100)
  end
end
```

Run the migration:

```bash
mix ecto.migrate
```

## Step 4: Create the Context

Phoenix uses contexts to organize related functionality. Let''s create a Tasks context:

```bash
mix phx.gen.context Tasks Task tasks title:string description:text completed:boolean
```

This generates the context module at `lib/task_tracker/tasks.ex`. Let''s enhance it:

```elixir
# lib/task_tracker/tasks.ex
defmodule TaskTracker.Tasks do
  @moduledoc """
  The Tasks context.
  """

  import Ecto.Query, warn: false
  alias TaskTracker.Repo
  alias TaskTracker.Task

  @doc """
  Returns the list of tasks.
  """
  def list_tasks do
    Repo.all(from t in Task, order_by: [desc: t.inserted_at])
  end

  @doc """
  Gets a single task.
  """
  def get_task!(id), do: Repo.get!(Task, id)

  @doc """
  Creates a task.
  """
  def create_task(attrs \\ %{}) do
    %Task{}
    |> Task.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a task.
  """
  def update_task(%Task{} = task, attrs) do
    task
    |> Task.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a task.
  """
  def delete_task(%Task{} = task) do
    Repo.delete(task)
  end

  @doc """
  Toggles task completion status.
  """
  def toggle_task_completion(%Task{} = task) do
    update_task(task, %{completed: !task.completed})
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking task changes.
  """
  def change_task(%Task{} = task, attrs \\ %{}) do
    Task.changeset(task, attrs)
  end
end
```

## Step 5: Create the LiveView

Now let''s create our main LiveView module:

```elixir
# lib/task_tracker_web/live/task_live.ex
defmodule TaskTrackerWeb.TaskLive do
  use TaskTrackerWeb, :live_view
  alias TaskTracker.Tasks
  alias TaskTracker.Task

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(TaskTracker.PubSub, "tasks")
    end

    socket =
      socket
      |> assign(:tasks, Tasks.list_tasks())
      |> assign(:form, to_form(Tasks.change_task(%Task{})))

    {:ok, socket}
  end

  def handle_event("create_task", %{"task" => task_params}, socket) do
    case Tasks.create_task(task_params) do
      {:ok, task} ->
        Phoenix.PubSub.broadcast(TaskTracker.PubSub, "tasks", {:task_created, task})

        socket =
          socket
          |> put_flash(:info, "Task created successfully!")
          |> assign(:form, to_form(Tasks.change_task(%Task{})))

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  def handle_event("toggle_task", %{"id" => id}, socket) do
    task = Tasks.get_task!(id)

    case Tasks.toggle_task_completion(task) do
      {:ok, updated_task} ->
        Phoenix.PubSub.broadcast(TaskTracker.PubSub, "tasks", {:task_updated, updated_task})
        {:noreply, socket}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Could not update task")}
    end
  end

  def handle_event("delete_task", %{"id" => id}, socket) do
    task = Tasks.get_task!(id)

    case Tasks.delete_task(task) do
      {:ok, _} ->
        Phoenix.PubSub.broadcast(TaskTracker.PubSub, "tasks", {:task_deleted, task})
        {:noreply, put_flash(socket, :info, "Task deleted successfully!")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Could not delete task")}
    end
  end

  # Handle real-time updates
  def handle_info({:task_created, _task}, socket) do
    {:noreply, assign(socket, :tasks, Tasks.list_tasks())}
  end

  def handle_info({:task_updated, _task}, socket) do
    {:noreply, assign(socket, :tasks, Tasks.list_tasks())}
  end

  def handle_info({:task_deleted, _task}, socket) do
    {:noreply, assign(socket, :tasks, Tasks.list_tasks())}
  end
end
```

## Step 6: Add Routing

Update your router to include the LiveView route:

```elixir
# lib/task_tracker_web/router.ex
defmodule TaskTrackerWeb.Router do
  use TaskTrackerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TaskTrackerWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", TaskTrackerWeb do
    pipe_through :browser

    live "/", TaskLive, :index  # Add this line
    get "/", PageController, :home  # Remove or comment this
  end
end
```

## Step 7: Test Your Application

Start your Phoenix server:

```bash
mix phx.server
```

Visit `http://localhost:4000` and you should see your TaskTracker application!

## Features We''ve Implemented

Let''s review what we''ve built:

### ✅ **CRUD Operations**
- Create new tasks with title and description
- Read/display all tasks in real-time
- Update task completion status
- Delete tasks with confirmation

### ✅ **Real-time Updates**
- Uses Phoenix PubSub for live updates
- Multiple users see changes instantly
- No page refreshes needed

### ✅ **Form Validation**
- Client and server-side validation
- Error messages display
- Required field handling

### ✅ **User Experience**
- Clean, responsive design
- Visual feedback for completed tasks
- Confirmation dialogs for destructive actions
- Empty state handling

## Testing Your App

Let''s add some basic tests. Create a test file:

```elixir
# test/task_tracker_web/live/task_live_test.exs
defmodule TaskTrackerWeb.TaskLiveTest do
  use TaskTrackerWeb.ConnCase
  import Phoenix.LiveViewTest
  alias TaskTracker.Tasks

  test "displays no tasks message when empty", %{conn: conn} do
    {:ok, view, html} = live(conn, "/")

    assert html =~ "No tasks yet"
    assert html =~ "TaskTracker"
  end

  test "creates a new task", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    assert view
           |> form("#task-form", task: %{title: "Test Task", description: "Test Description"})
           |> render_submit()

    assert render(view) =~ "Test Task"
    assert render(view) =~ "Test Description"
  end

  test "toggles task completion", %{conn: conn} do
    {:ok, task} = Tasks.create_task(%{title: "Test Task"})
    {:ok, view, _html} = live(conn, "/")

    assert view
           |> element("[phx-click=''toggle_task''][phx-value-id=''#{task.id}'']")
           |> render_click()

    # Verify task is marked as completed
    updated_task = Tasks.get_task!(task.id)
    assert updated_task.completed
  end
end
```

Run your tests:

```bash
mix test
```

## Next Steps

Congratulations! You''ve built your first Phoenix application. Here are some ideas to extend it:

### 🚀 **Enhancement Ideas**

1. **User Authentication** - Add user accounts with `phx.gen.auth`
2. **Categories/Tags** - Organize tasks by categories
3. **Due Dates** - Add task deadlines with reminders
4. **Task Priorities** - High, medium, low priority levels
5. **Search & Filtering** - Find tasks quickly
6. **Export/Import** - CSV or JSON backup functionality
7. **Mobile App** - Use Phoenix LiveView Native
8. **API** - Add JSON API for mobile/external integrations

### 📚 **Learn More**

- [Phoenix LiveView Documentation](https://hexdocs.pm/phoenix_live_view)
- [Ecto Query Guide](https://hexdocs.pm/ecto/Ecto.Query.html)
- [Phoenix PubSub](https://hexdocs.pm/phoenix_pubsub)
- [Phoenix Testing](https://hexdocs.pm/phoenix/testing.html)

## Troubleshooting

### Common Issues

**Database errors:**
```bash
mix ecto.reset  # Reset database
mix ecto.migrate  # Run migrations
```

**Asset compilation errors:**
```bash
cd assets && npm install  # Reinstall assets
```

**Port already in use:**
```bash
lsof -ti:4000 | xargs kill  # Kill process on port 4000
```

**LiveView not updating:**
- Check browser console for JavaScript errors
- Verify PubSub is working correctly
- Ensure `connected?/1` check in mount

## Summary

You''ve successfully built a complete Phoenix LiveView application! This tutorial covered:

- ✅ Project setup and configuration
- ✅ Database schema and migrations
- ✅ Context modules for business logic
- ✅ LiveView for real-time interactions
- ✅ Form handling and validation
- ✅ PubSub for real-time updates
- ✅ Styling with Tailwind CSS
- ✅ Basic testing strategies

Phoenix makes building interactive web applications incredibly productive. With LiveView, you get the benefits of a single-page application without the complexity of managing client-side state and JavaScript frameworks.

Keep building and exploring Phoenix - there''s so much more to discover! 🚀',
    'Tech Team',
    'tech@skimsafe.se',
    '["Phoenix", "Tutorial", "LiveView", "Getting Started", "Web Development"]',
    0,
    1,
    '2024-11-22 14:00:00',
    10,
    0,
    datetime('now'),
    datetime('now')
);