-- Insert Elixir Basics for Beginners into SQLite database
-- Run this with: sqlite3 skimsafe_blogg_dev.sqlite3 < insert_elixir_basics.sql

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
    'abcdef12-3456-7890-abcd-ef1234567890',
    'Elixir Basics for Beginners',
    'elixir-basics',
    'Elixir is a dynamic, functional programming language designed for building maintainable and scalable applications. This comprehensive guide covers all the fundamentals you need to get started with Elixir programming.',
    '# Elixir Basics for Beginners

Elixir is a dynamic, functional programming language designed for building maintainable and scalable applications. Built on the robust Erlang Virtual Machine (BEAM), Elixir brings modern language features while leveraging decades of battle-tested concurrency and fault-tolerance capabilities.

## Why Choose Elixir?

### Key Benefits

- **Fault Tolerance**: "Let it crash" philosophy ensures system resilience
- **Massive Concurrency**: Handle millions of lightweight processes
- **Immutability**: Data structures are immutable by default
- **Pattern Matching**: Powerful feature for control flow and data extraction
- **Actor Model**: Built-in support for distributed, concurrent systems
- **Hot Code Swapping**: Update running systems without downtime

## Setting Up Your Environment

Before diving into Elixir, make sure you have it installed. If you haven''t already, follow our [Phoenix Installation Guide](/posts/phoenix-installation) which covers Elixir installation as well.

### Verify Your Installation

```bash
elixir --version
```

You should see output similar to:
```
Erlang/OTP 26 [erts-14.0] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:1]

Elixir 1.15.4 (compiled with Erlang/OTP 26)
```

## Basic Syntax and Data Types

### Variables and Basic Types

```elixir
# Atoms - constants whose name is their value
:hello
:world
:ok
:error

# Numbers
42          # integer
3.14        # float
1_000_000   # you can use underscores for readability

# Strings
"Hello, World!"
"String interpolation: #{1 + 1}"

# Booleans
true
false

# Lists
[1, 2, 3, 4]
["hello", "world"]
[1, "mixed", :types, true]

# Tuples
{:ok, "success"}
{:error, "something went wrong"}
{1, 2, 3}
```

### Pattern Matching

Pattern matching is one of Elixir''s most powerful features:

```elixir
# Basic pattern matching
x = 1                    # assigns 1 to x
1 = x                    # matches! x is 1
# 2 = x                  # would raise MatchError

# Destructuring tuples
{a, b} = {1, 2}         # a = 1, b = 2
{:ok, message} = {:ok, "Success!"}

# Destructuring lists
[head | tail] = [1, 2, 3, 4]    # head = 1, tail = [2, 3, 4]
[first, second | rest] = [1, 2, 3, 4]  # first = 1, second = 2, rest = [3, 4]
```

## Functions

### Anonymous Functions

```elixir
# Basic anonymous function
add = fn a, b -> a + b end
add.(1, 2)  # returns 3

# Shorthand syntax
add = &(&1 + &2)
add.(1, 2)  # returns 3

# Pattern matching in functions
handle_result = fn
  {:ok, result} -> "Success: #{result}"
  {:error, reason} -> "Error: #{reason}"
end

handle_result.({:ok, "Data loaded"})    # "Success: Data loaded"
handle_result.({:error, "Not found"})   # "Error: Not found"
```

### Named Functions

```elixir
defmodule Math do
  # Public function
  def add(a, b) do
    a + b
  end

  # Private function
  defp multiply(a, b) do
    a * b
  end

  # Function with multiple clauses (pattern matching)
  def factorial(0), do: 1
  def factorial(n) when n > 0 do
    n * factorial(n - 1)
  end

  # Guard clauses
  def divide(a, b) when b != 0 do
    a / b
  end

  def divide(_, 0) do
    {:error, "Cannot divide by zero"}
  end
end

# Using the module
Math.add(1, 2)        # 3
Math.factorial(5)     # 120
Math.divide(10, 2)    # 5.0
Math.divide(10, 0)    # {:error, "Cannot divide by zero"}
```

## Working with Collections

### Lists

```elixir
# Creating lists
numbers = [1, 2, 3, 4, 5]

# Adding elements
new_list = [0 | numbers]  # [0, 1, 2, 3, 4, 5]

# List operations
length(numbers)           # 5
hd(numbers)              # 1 (head)
tl(numbers)              # [2, 3, 4, 5] (tail)

# List concatenation
[1, 2] ++ [3, 4]         # [1, 2, 3, 4]

# List subtraction
[1, 2, 3] -- [2]         # [1, 3]
```

### Maps

```elixir
# Creating maps
person = %{name: "Alice", age: 30, city: "Stockholm"}

# Accessing values
person[:name]            # "Alice"
person.name              # "Alice" (atom keys only)

# Adding/updating values
person = Map.put(person, :email, "alice@example.com")
person = %{person | age: 31}  # Update existing key

# Pattern matching with maps
%{name: name} = person   # extracts name
%{name: "Alice"} = person  # matches when name is "Alice"
```

### Keyword Lists

```elixir
# Keyword lists (lists of two-element tuples)
options = [host: "localhost", port: 4000, ssl: false]

# Alternative syntax
options = [{:host, "localhost"}, {:port, 4000}, {:ssl, false}]

# Accessing values
options[:host]           # "localhost"
Keyword.get(options, :port)  # 4000
Keyword.get(options, :timeout, 5000)  # 5000 (default)
```

## Control Flow

### Case Statements

```elixir
case File.read("config.txt") do
  {:ok, content} ->
    "File content: #{content}"
  {:error, :enoent} ->
    "File not found"
  {:error, reason} ->
    "Error reading file: #{reason}"
end
```

### Cond Statements

```elixir
age = 25

result = cond do
  age < 13 -> "child"
  age < 20 -> "teenager"
  age < 60 -> "adult"
  true -> "senior"  # default case
end
```

### If/Unless

```elixir
if age >= 18 do
  "Can vote"
else
  "Cannot vote"
end

unless age < 18 do
  "Can vote"
end
```

## Processes and Concurrency

### Spawning Processes

```elixir
# Spawn a simple process
pid = spawn(fn -> IO.puts("Hello from process!") end)

# Spawn and send messages
pid = spawn(fn ->
  receive do
    {:greet, name} -> IO.puts("Hello, #{name}!")
    :stop -> :ok
  end
end)

send(pid, {:greet, "Alice"})
send(pid, :stop)
```

### GenServer Example

```elixir
defmodule Counter do
  use GenServer

  # Client API
  def start_link(initial_value \\ 0) do
    GenServer.start_link(__MODULE__, initial_value, name: __MODULE__)
  end

  def get() do
    GenServer.call(__MODULE__, :get)
  end

  def increment() do
    GenServer.cast(__MODULE__, :increment)
  end

  # Server Callbacks
  def init(initial_value) do
    {:ok, initial_value}
  end

  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  def handle_cast(:increment, state) do
    {:noreply, state + 1}
  end
end

# Usage
{:ok, _pid} = Counter.start_link(0)
Counter.get()        # 0
Counter.increment()
Counter.get()        # 1
```

## Working with Enum

The `Enum` module provides many useful functions for working with collections:

```elixir
numbers = [1, 2, 3, 4, 5]

# Map over elements
Enum.map(numbers, fn x -> x * 2 end)        # [2, 4, 6, 8, 10]
Enum.map(numbers, &(&1 * 2))                # Same as above

# Filter elements
Enum.filter(numbers, fn x -> x > 3 end)     # [4, 5]
Enum.filter(numbers, &(&1 > 3))             # Same as above

# Reduce
Enum.reduce(numbers, 0, fn x, acc -> x + acc end)  # 15
Enum.reduce(numbers, &+/2)                   # 15

# Other useful functions
Enum.any?(numbers, &(&1 > 3))               # true
Enum.all?(numbers, &(&1 > 0))               # true
Enum.find(numbers, &(&1 > 3))               # 4
Enum.take(numbers, 3)                       # [1, 2, 3]
Enum.drop(numbers, 2)                       # [3, 4, 5]
```

## Pipe Operator

The pipe operator `|>` allows you to chain function calls elegantly:

```elixir
# Without pipe operator
result = Enum.reduce(
  Enum.filter(
    Enum.map([1, 2, 3, 4, 5], &(&1 * 2)),
    &(&1 > 5)
  ),
  0,
  &+/2
)

# With pipe operator
result = [1, 2, 3, 4, 5]
|> Enum.map(&(&1 * 2))
|> Enum.filter(&(&1 > 5))
|> Enum.reduce(0, &+/2)
# Result: 18 (6 + 8 + 10)
```

## Error Handling

### Try/Rescue

```elixir
try do
  1 / 0
rescue
  ArithmeticError -> "Cannot divide by zero"
end
```

### With Statement

```elixir
defmodule UserLoader do
  def load_user(id) do
    with {:ok, user_data} <- fetch_user(id),
         {:ok, preferences} <- fetch_preferences(user_data.id),
         {:ok, profile} <- build_profile(user_data, preferences) do
      {:ok, profile}
    else
      {:error, reason} -> {:error, reason}
      _ -> {:error, "Unknown error"}
    end
  end

  defp fetch_user(id), do: {:ok, %{id: id, name: "Alice"}}
  defp fetch_preferences(_id), do: {:ok, %{theme: "dark"}}
  defp build_profile(user, prefs), do: {:ok, Map.merge(user, prefs)}
end
```

## Common Patterns

### Supervisor Trees

```elixir
defmodule MyApp.Application do
  use Application

  def start(_type, _args) do
    children = [
      {Counter, 0},
      {MyApp.Worker, []}
    ]

    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
```

### Task and Async Operations

```elixir
# Running tasks concurrently
task1 = Task.async(fn -> expensive_operation_1() end)
task2 = Task.async(fn -> expensive_operation_2() end)

result1 = Task.await(task1)
result2 = Task.await(task2)

# Simple task
Task.start(fn -> background_work() end)
```

## Best Practices

### 1. Use Pattern Matching
```elixir
# Good
def handle_response({:ok, data}), do: process_data(data)
def handle_response({:error, reason}), do: log_error(reason)

# Less idiomatic
def handle_response(response) do
  if elem(response, 0) == :ok do
    process_data(elem(response, 1))
  else
    log_error(elem(response, 1))
  end
end
```

### 2. Use the Pipe Operator
```elixir
# Good
"hello world"
|> String.upcase()
|> String.split()
|> Enum.join("-")

# Less readable
Enum.join(String.split(String.upcase("hello world")), "-")
```

### 3. Prefer Small Functions
```elixir
def process_user_data(data) do
  data
  |> validate_data()
  |> transform_data()
  |> save_data()
end

defp validate_data(data), do: # validation logic
defp transform_data(data), do: # transformation logic
defp save_data(data), do: # saving logic
```

## Next Steps

Now that you understand Elixir basics, here are recommended next steps:

1. **Practice with IEx** - Use the interactive Elixir shell to experiment
2. **Build a Small Project** - Create a simple CLI application or library
3. **Learn OTP** - Dive deeper into GenServer, Supervisor, and Application
4. **Explore Phoenix** - Build web applications with the Phoenix framework
5. **Study Real Projects** - Look at open-source Elixir projects on GitHub

## Additional Resources

- [Official Elixir Documentation](https://hexdocs.pm/elixir/)
- [Elixir School](https://elixirschool.com/)
- [Programming Elixir](https://pragprog.com/titles/elixir16/programming-elixir-1-6/) by Dave Thomas
- [Elixir in Action](https://www.manning.com/books/elixir-in-action-second-edition) by Saša Jurić
- [Elixir Forum](https://elixirforum.com/)

Welcome to the world of Elixir! With its unique combination of functional programming and the actor model, you''re well-equipped to build concurrent, fault-tolerant applications. 🧪',
    'Tech Team',
    'tech@skimsafe.se',
    '["Elixir", "Functional Programming", "Beginners", "Tutorial", "BEAM"]',
    0,
    1,
    '2024-11-25 10:00:00',
    7,
    0,
    datetime('now'),
    datetime('now')
);