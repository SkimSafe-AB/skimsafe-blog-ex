# Elixir Basics for Beginners

So you want to learn Elixir? Smart choice! Elixir is this really cool dynamic, functional programming language that's designed for building apps that actually stay up and running. It's built on top of the Erlang Virtual Machine (BEAM), which has been battle-tested for decades. We're talking telecom systems that can't afford to go down, ever.

I've been playing around with Elixir for a while now, and honestly, once you get the hang of it, you'll wonder why other languages make concurrency so damn complicated.

## Why I Think Elixir Rocks

### The Good Stuff

- **Fault Tolerance**: The "let it crash" philosophy is genius. Instead of trying to prevent every possible error, you just let things fail and restart them.
- **Massive Concurrency**: We're talking millions of lightweight processes. Not threads, not OS processes but elixir processes that are super cheap to create and destroy
- **Immutability**: Your data can't be changed once it's created, which means fewer bugs and headaches
- **Pattern Matching**: This is probably my favorite feature. You can destructure and match data in really nice ways
- **Actor Model**: Built-in support for distributed systems that just makes sense
- **Hot Code Swapping**: You can literally update your running system without stopping it.

## Getting Your Environment Ready

Before we dive in, make sure you've got Elixir installed. If you haven't done this yet, check out our [Phoenix Installation Guide](/posts/phoenix-installation) - it covers Elixir installation too.

### Double-Check Everything Works

```bash
elixir --version
```

You should see something like this:
```
Erlang/OTP 26 [erts-14.0] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:1]

Elixir 1.15.4 (compiled with Erlang/OTP 26)
```

If you see that, you're golden!

## Basic Syntax and Data Types

### Variables and the Usual Suspects

```elixir
# Atoms - these are like constants but their name is their value
# Think of them as symbols if you're coming from Ruby
:hello
:world
:ok
:error

# Numbers - pretty standard stuff
42          # integer
3.14        # float
1_000_000   # you can use underscores for readability (neat!)

# Strings - with interpolation that actually works nicely
"Hello, World!"
"String interpolation: #{1 + 1}"  # outputs "String interpolation: 2"

# Booleans
true
false

# Lists - can hold anything
[1, 2, 3, 4]
["hello", "world"]
[1, "mixed", :types, true]  # yep, mixed types work fine

# Tuples - like lists but fixed size and faster access
{:ok, "success"}
{:error, "something went wrong"}
{1, 2, 3}
```

### Pattern Matching - The Game Changer

This is where Elixir starts getting really interesting. Pattern matching isn't just assignment - it's like destructuring on steroids:

```elixir
# Basic pattern matching
x = 1                    # assigns 1 to x
1 = x                    # this matches! x is indeed 1
# 2 = x                  # this would blow up with a MatchError

# Destructuring tuples - super handy for return values
{a, b} = {1, 2}         # now a = 1, b = 2
{:ok, message} = {:ok, "Success!"}  # extract the success message

# Destructuring lists - this is where it gets fun
[head | tail] = [1, 2, 3, 4]    # head = 1, tail = [2, 3, 4]
[first, second | rest] = [1, 2, 3, 4]  # first = 1, second = 2, rest = [3, 4]
```

The pattern matching thing took me a bit to wrap my head around at first, but now I use it everywhere. It's like having built-in destructuring that also validates your assumptions about the data structure.

## Functions - Anonymous and Named

### Anonymous Functions

```elixir
# Basic anonymous function - notice the dot when calling it
add = fn a, b -> a + b end
add.(1, 2)  # returns 3

# Shorthand syntax - once you get used to this, it's addictive
add = &(&1 + &2)
add.(1, 2)  # returns 3

# Pattern matching in functions - this is where it gets powerful
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
  # Public function - anyone can call this
  def add(a, b) do
    a + b
  end

  # Private function - only this module can use it
  defp multiply(a, b) do
    a * b
  end

  # Multiple function clauses - this is pure magic
  def factorial(0), do: 1  # base case
  def factorial(n) when n > 0 do  # recursive case with guard
    n * factorial(n - 1)
  end

  # Guard clauses help you handle edge cases elegantly  
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

The multiple function clauses thing is handy - instead of having one big function with a bunch of if/else statements, you just define multiple versions of the same function with different patterns. Elixir picks the right one automatically.

## Working with Collections

### Lists

```elixir
# Creating lists
numbers = [1, 2, 3, 4, 5]

# Adding elements to the front (this is fast!)
new_list = [0 | numbers]  # [0, 1, 2, 3, 4, 5]

# List operations - head and tail are super common patterns
length(numbers)           # 5
hd(numbers)              # 1 (head - first element)
tl(numbers)              # [2, 3, 4, 5] (tail - everything except first)

# List concatenation and subtraction
[1, 2] ++ [3, 4]         # [1, 2, 3, 4]
[1, 2, 3] -- [2]         # [1, 3]
```

Pro tip: Lists in Elixir are linked lists, so adding to the front is O(1) but adding to the end is O(n). Keep that in mind when you're building them up.

### Maps

```elixir
# Creating maps - like hashes or dictionaries in other languages
person = %{name: "Alice", age: 30, city: "Stockholm"}

# Accessing values - two ways to do it
person[:name]            # "Alice" - works with any key type
person.name              # "Alice" - only works with atom keys

# Adding/updating values
person = Map.put(person, :email, "alice@example.com")
person = %{person | age: 31}  # Update existing key (this syntax is sweet!)

# Pattern matching with maps - extract what you need
%{name: name} = person   # extracts just the name
%{name: "Alice"} = person  # matches only when name is "Alice"
```

### Keyword Lists

```elixir
# Keyword lists - basically lists of tuples, great for options
options = [host: "localhost", port: 4000, ssl: false]

# Alternative syntax (same thing)
options = [{:host, "localhost"}, {:port, 4000}, {:ssl, false}]

# Accessing values
options[:host]           # "localhost"
Keyword.get(options, :port)  # 4000
Keyword.get(options, :timeout, 5000)  # 5000 (default value)
```

I use keyword lists a lot for function options. They're ordered (unlike maps) and can have duplicate keys, which makes them perfect for configuration stuff.

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

Case statements with pattern matching are cleaner than traditional switch statements. You're not just comparing values - you're destructuring and extracting data at the same time.

### Cond Statements

```elixir
age = 25

result = cond do
  age < 13 -> "child"
  age < 20 -> "teenager"  
  age < 60 -> "adult"
  true -> "senior"  # this is your default case
end
```

### If/Unless

```elixir
if age >= 18 do
  "Can vote"
else
  "Cannot vote"
end

# Unless is just syntactic sugar for if not
unless age < 18 do
  "Can vote"  
end
```

I don't use if statement that much in Elixir. Pattern matching and case statements usually handles most things.

## Processes and Concurrency - The Real Magic

This is where Elixir really shines. Processes are not OS threads - they're super lightweight and isolated.

### Spawning Processes

```elixir
# Spawn a simple process
pid = spawn(fn -> IO.puts("Hello from process!") end)

# Processes communicate through messages - no shared memory!
pid = spawn(fn ->
  receive do
    {:greet, name} -> IO.puts("Hello, #{name}!")
    :stop -> :ok
  after
    5000 -> IO.puts("No message received, timing out")
  end
end)

send(pid, {:greet, "Alice"})
send(pid, :stop)
```

### GenServer Example

It's a generic server process that handles state, get use to it:

```elixir
defmodule Counter do
  use GenServer

  # Client API - this is what other processes call
  def start_link(initial_value \\ 0) do
    GenServer.start_link(__MODULE__, initial_value, name: __MODULE__)
  end

  def get() do
    GenServer.call(__MODULE__, :get)  # synchronous call
  end

  def increment() do
    GenServer.cast(__MODULE__, :increment)  # asynchronous cast
  end

  # Server Callbacks - this is the actual implementation
  def init(initial_value) do
    {:ok, initial_value}  # initial state
  end

  def handle_call(:get, _from, state) do
    {:reply, state, state}  # reply with current state, don't change it
  end

  def handle_cast(:increment, state) do
    {:noreply, state + 1}  # don't reply, but increment the state
  end
end

# Usage
{:ok, _pid} = Counter.start_link(0)
Counter.get()        # 0
Counter.increment()
Counter.get()        # 1
```

The GenServer pattern is everywhere in Elixir. It handles all the messy process management stuff so you can focus on your business logic.

## Working with Enum - Your Best Friend

The `Enum` module is probably what you'll use most when working with collections. It's packed with useful functions:

```elixir
numbers = [1, 2, 3, 4, 5]

# Map over elements - transform each one
Enum.map(numbers, fn x -> x * 2 end)        # [2, 4, 6, 8, 10]
Enum.map(numbers, &(&1 * 2))                # Same thing, shorter syntax

# Filter elements - keep only the ones you want
Enum.filter(numbers, fn x -> x > 3 end)     # [4, 5]
Enum.filter(numbers, &(&1 > 3))             # Same thing, shorter

# Reduce - combine all elements into a single value
Enum.reduce(numbers, 0, fn x, acc -> x + acc end)  # 15 (sum)
Enum.reduce(numbers, &+/2)                   # 15 (even shorter!)

# Other super useful functions
Enum.any?(numbers, &(&1 > 3))               # true - any element > 3?
Enum.all?(numbers, &(&1 > 0))               # true - all elements > 0?
Enum.find(numbers, &(&1 > 3))               # 4 - first element > 3
Enum.take(numbers, 3)                       # [1, 2, 3] - first 3 elements
Enum.drop(numbers, 2)                       # [3, 4, 5] - drop first 2
```

That `&(&1 > 3)` syntax might look weird at first. It's just shorthand for `fn x -> x > 3 end`. Once you get used to it, it's really convenient for simple functions.

## Pipe Operator - Making Code Readable

The pipe operator `|>` is one of my favorite features. It lets you chain operations in a way that actually makes sense when you read it:

```elixir
# Without pipe operator - nested and hard to read
result = Enum.reduce(
  Enum.filter(
    Enum.map([1, 2, 3, 4, 5], &(&1 * 2)),
    &(&1 > 5)
  ),
  0,
  &+/2
)

# With pipe operator - reads like a recipe
result = [1, 2, 3, 4, 5]
|> Enum.map(&(&1 * 2))      # double each number: [2, 4, 6, 8, 10]
|> Enum.filter(&(&1 > 5))   # keep only > 5: [6, 8, 10]
|> Enum.reduce(0, &+/2)     # sum them up: 24
```

The pipe operator takes the result of the left side and passes it as the first argument to the function on the right. It's like Unix pipes but for function calls!

## Error Handling

### Try/Rescue

```elixir
try do
  1 / 0
rescue
  ArithmeticError -> "Cannot divide by zero"
end
```

Though honestly, try/rescue isn't used that much in Elixir. The preference is to return `{:ok, result}` or `{:error, reason}` tuples and pattern match on them.

### With Statement - The Clean Way

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

The `with` statement is smart for chaining operations that might fail. If any step returns something that doesn't match the pattern, it goes to the `else` clause. 

## Common Patterns You'll See Everywhere

### Supervisor Trees

```elixir
defmodule MyApp.Application do
  use Application

  def start(_type, _args) do
    children = [
      {Counter, 0},                # start Counter with initial value 0
      {MyApp.Worker, []}           # start Worker with empty args
    ]

    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
```

Supervisors are like babysitters for your processes. If a child process crashes, the supervisor restarts it according to the strategy you specify. It's all part of that "let it crash" philosophy.

### Task and Async Operations

```elixir
# Running expensive operations concurrently - this is so cool!
task1 = Task.async(fn -> expensive_operation_1() end)
task2 = Task.async(fn -> expensive_operation_2() end)

# Both operations are running at the same time now
result1 = Task.await(task1)  # wait for first to finish
result2 = Task.await(task2)  # wait for second to finish

# Fire-and-forget task
Task.start(fn -> background_cleanup() end)
```

## Best Practices I've Learned

### 1. Use Pattern Matching Like Crazy
```elixir
# This is the Elixir way
def handle_response({:ok, data}), do: process_data(data)
def handle_response({:error, reason}), do: log_error(reason)

# This works but feels wrong in Elixir
def handle_response(response) do
  if elem(response, 0) == :ok do
    process_data(elem(response, 1))
  else
    log_error(elem(response, 1))
  end
end
```

### 2. Pipe Everything
```elixir
# Beautiful and readable
"hello world"
|> String.upcase()
|> String.split()
|> Enum.join("-")
# Result: "HELLO-WORLD"

# Works but hurts my brain
Enum.join(String.split(String.upcase("hello world")), "-")
```

### 3. Keep Functions Small
```elixir
def process_user_data(data) do
  data
  |> validate_data()
  |> transform_data()
  |> save_data()
end

defp validate_data(data), do: # validation logic here
defp transform_data(data), do: # transformation logic here  
defp save_data(data), do
````

3. Keep Functions Small
```
elixirdef process_user_data(data) do
  data
  |> validate_data()
  |> transform_data()
  |> save_data()
end

defp validate_data(data), do: # validation logic here
defp transform_data(data), do: # transformation logic here  
defp save_data(data), do: # saving logic here
````

Each function does one thing and does it well. Easy to test, easy to understand, easy to debug.

#### What's Next?
So you've got the basics down. Here's what I'd recommend doing next:

- Play around in IEx, fire up the interactive shell and experiment. It's the best way to learn!
- Build something small, maybe a CLI tool or a simple library. Nothing fancy, just get your hands dirty.
- Dive into OTP and learn more about GenServer, Supervisor, and Application. This is where the real power is.
- Try Phoenix and build a web app! Phoenix is fantastic and will teach you a lot about Elixir patterns.
- Read other people's code and check out some open-source Elixir projects on GitHub

#### Resources Worth Checking Out

- Official Elixir Documentation - Actually really well written
- Elixir School - Great tutorials
- Programming Elixir by Dave Thomas - Solid book
- Elixir in Action by Saša Jurić - Goes deeper into OTP
- Elixir Forum - Super helpful community

Welcome to Elixir! It's a bit of a mind shift if you're coming from imperative languages, but once it clicks, you'll love it I hope. The combination of functional programming with the actor model for concurrency is perfect for building robust, scalable systems.
Now go build something cool! 

Stay weird!🧪

Louise Blanc
