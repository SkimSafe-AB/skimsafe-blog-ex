# Getting Started with Phoenix LiveView: Building Interactive Web Applications

Phoenix LiveView revolutionizes web development by enabling real-time, interactive applications without writing JavaScript. In this comprehensive guide, we'll explore the core concepts and build a practical example.

## What is Phoenix LiveView?

Phoenix LiveView is a library that enables rich, real-time user experiences with server-rendered HTML. It allows you to build interactive applications with minimal JavaScript, leveraging the power of the BEAM virtual machine for scalability and fault tolerance.

### Key Benefits

- **Real-time interactivity** without complex JavaScript frameworks
- **Server-side rendering** for better SEO and initial load times
- **Built-in WebSocket management** for seamless real-time updates
- **Fault-tolerant** architecture inherited from Elixir/OTP

## Core Concepts

### LiveView Lifecycle

LiveView follows a simple lifecycle:

1. **Mount** - Initialize the socket state
2. **Handle Events** - Process user interactions
3. **Render** - Update the UI based on state changes
4. **Terminate** - Clean up resources when the view closes

### Socket State

The socket holds your application's state and is the central piece of LiveView:

```elixir
defmodule MyAppWeb.CounterLive do
  use MyAppWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, count: 0)}
  end

  def handle_event("increment", _params, socket) do
    {:noreply, assign(socket, count: socket.assigns.count + 1)}
  end

  def handle_event("decrement", _params, socket) do
    {:noreply, assign(socket, count: socket.assigns.count - 1)}
  end
end
```

### Templates and HEEx

LiveView uses HEEx (HTML+EEx) templates for rendering:

```heex
<div class="counter">
  <h1>Count: <%= @count %></h1>
  <button phx-click="increment">+</button>
  <button phx-click="decrement">-</button>
</div>
```

## Building Your First LiveView

Let's build a simple real-time chat application to demonstrate LiveView's capabilities.

### Step 1: Create the LiveView Module

```elixir
defmodule MyAppWeb.ChatLive do
  use MyAppWeb, :live_view

  def mount(_params, _session, socket) do
    if connected?(socket) do
      MyApp.PubSub.subscribe("chat:general")
    end

    {:ok, assign(socket, messages: [], message: "")}
  end

  def handle_event("send_message", %{"message" => message}, socket) do
    MyApp.PubSub.broadcast("chat:general", {:new_message, message})
    {:noreply, assign(socket, message: "")}
  end

  def handle_event("typing", %{"message" => message}, socket) do
    {:noreply, assign(socket, message: message)}
  end

  def handle_info({:new_message, message}, socket) do
    messages = [message | socket.assigns.messages]
    {:noreply, assign(socket, messages: messages)}
  end
end
```

### Step 2: Create the Template

```heex
<div class="chat-container">
  <div class="messages" id="messages">
    <div :for={message <- @messages} class="message">
      <%= message %>
    </div>
  </div>

  <form phx-submit="send_message" class="message-form">
    <input
      type="text"
      name="message"
      value={@message}
      phx-change="typing"
      placeholder="Type your message..."
      autocomplete="off"
    />
    <button type="submit">Send</button>
  </form>
</div>
```

### Step 3: Add Routing

```elixir
# In your router.ex
live "/chat", ChatLive, :index
```

## Advanced Features

### LiveComponents

For reusable UI components, use LiveComponents:

```elixir
defmodule MyAppWeb.MessageComponent do
  use MyAppWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="message-component" id={@id}>
      <span class="author"><%= @message.author %></span>
      <span class="content"><%= @message.content %></span>
      <span class="timestamp"><%= @message.inserted_at %></span>
    </div>
    """
  end
end
```

### File Uploads

LiveView provides built-in file upload capabilities:

```elixir
def mount(_params, _session, socket) do
  socket =
    socket
    |> assign(:uploaded_files, [])
    |> allow_upload(:avatar, accept: ~w(.jpg .jpeg .png), max_entries: 1)

  {:ok, socket}
end

def handle_event("validate", _params, socket) do
  {:noreply, socket}
end

def handle_event("save", _params, socket) do
  uploaded_files =
    consume_uploaded_entries(socket, :avatar, fn %{path: path}, _entry ->
      dest = Path.join("priv/static/uploads", Path.basename(path))
      File.cp!(path, dest)
      {:ok, "/uploads/" <> Path.basename(dest)}
    end)

  {:noreply, assign(socket, uploaded_files: uploaded_files)}
end
```

## Testing LiveView

Testing LiveView applications is straightforward with Phoenix's built-in test helpers:

```elixir
defmodule MyAppWeb.ChatLiveTest do
  use MyAppWeb.ConnCase
  import Phoenix.LiveViewTest

  test "sends and displays messages", %{conn: conn} do
    {:ok, view, html} = live(conn, "/chat")

    assert html =~ "Type your message"

    html =
      view
      |> form("#message-form", message: "Hello, World!")
      |> render_submit()

    assert html =~ "Hello, World!"
  end
end
```

## Performance Considerations

### Optimizing LiveView Performance

1. **Use streams for large datasets** to avoid memory bloat
2. **Implement proper indexing** in your database queries
3. **Cache expensive calculations** in assigns
4. **Use temporary assigns** for data that doesn't need to persist

### Example with Streams

```elixir
def mount(_params, _session, socket) do
  socket =
    socket
    |> assign(:page_title, "Messages")
    |> stream(:messages, [])

  {:ok, socket}
end

def handle_info({:new_message, message}, socket) do
  {:noreply, stream_insert(socket, :messages, message)}
end
```

## Best Practices

### 1. Keep State Minimal
Only store what you need in the socket assigns. Compute derived values in the template or using calculations.

### 2. Use PubSub for Real-time Updates
Leverage Phoenix PubSub to broadcast changes to multiple users efficiently.

### 3. Handle Disconnections Gracefully
Always check if the socket is connected before subscribing to channels:

```elixir
def mount(_params, _session, socket) do
  if connected?(socket) do
    # Subscribe to channels
  end

  {:ok, socket}
end
```

### 4. Validate User Input
Always validate and sanitize user input on the server side.

## Conclusion

Phoenix LiveView provides a powerful way to build interactive web applications with minimal complexity. By leveraging server-side rendering and WebSocket connections, you can create rich user experiences while maintaining the simplicity of server-side development.

The key to mastering LiveView is understanding the socket lifecycle, proper state management, and effective use of PubSub for real-time features. Start with simple interactions and gradually build up to more complex real-time applications.

## Further Reading

- [Phoenix LiveView Documentation](https://hexdocs.pm/phoenix_live_view)
- [LiveView Examples](https://github.com/phoenixframework/phoenix_live_view/tree/main/examples)
- [Phoenix PubSub Guide](https://hexdocs.pm/phoenix_pubsub)

---

*Ready to start building with LiveView? Check out our [Phoenix installation guide](/posts/phoenix-installation) to get started.*