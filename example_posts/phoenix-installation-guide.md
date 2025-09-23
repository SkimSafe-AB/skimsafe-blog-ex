# Phoenix Installation Guide

Getting started with Phoenix Framework is straightforward, but there are a few prerequisites you'll need to have in place. This guide will walk you through installing Phoenix on your system step by step.

## Prerequisites

Before installing Phoenix, you'll need to have the following installed on your system:

### 1. Elixir and Erlang

Phoenix is built on Elixir, which runs on the Erlang Virtual Machine (BEAM). You'll need both installed.

**For macOS (using Homebrew):**
```bash
brew install elixir
```

**For Ubuntu/Debian:**
```bash
# Add Erlang Solutions repository
wget https://packages.erlang-solutions.com/erlang-solutions_2.0_all.deb
sudo dpkg -i erlang-solutions_2.0_all.deb
sudo apt-get update

# Install Elixir and Erlang
sudo apt-get install elixir erlang-dev erlang-parsetools
```

**For Windows:**
- Download and install Elixir from [elixir-lang.org](https://elixir-lang.org/install.html#windows)

### 2. Node.js (for asset compilation)

Phoenix uses Node.js for compiling assets like CSS and JavaScript.

**For macOS:**
```bash
brew install node
```

**For Ubuntu/Debian:**
```bash
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
```

**For Windows:**
- Download and install from [nodejs.org](https://nodejs.org/)

### 3. PostgreSQL (Database)

While Phoenix supports multiple databases, PostgreSQL is the default and most commonly used.

**For macOS:**
```bash
brew install postgresql
brew services start postgresql
```

**For Ubuntu/Debian:**
```bash
sudo apt-get install postgresql postgresql-contrib
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

## Installing Phoenix

Once you have the prerequisites installed, you can install Phoenix using Hex, Elixir's package manager.

### 1. Install Hex Package Manager

```bash
mix local.hex
```

### 2. Install Phoenix

```bash
mix archive.install hex phx_new
```

This installs the Phoenix application generator, which allows you to create new Phoenix projects.

## Creating Your First Phoenix Project

Now that Phoenix is installed, let's create a new project:

```bash
mix phx.new my_app
cd my_app
```

### Install Dependencies

```bash
mix deps.get
```

### Setup the Database

```bash
mix ecto.setup
```

### Start the Development Server

```bash
mix phx.server
```

Your Phoenix application will be available at `http://localhost:4000`.

## Verifying the Installation

To verify that everything is working correctly:

1. Open your browser and navigate to `http://localhost:4000`
2. You should see the Phoenix welcome page
3. The page should display "Welcome to Phoenix!" with the Phoenix logo

## Troubleshooting

### Common Issues

**Mix command not found:**
- Make sure Elixir is properly installed and in your PATH
- Restart your terminal after installation

**Database connection errors:**
- Ensure PostgreSQL is running
- Check your database configuration in `config/dev.exs`

**Asset compilation errors:**
- Verify Node.js is installed and accessible
- Try deleting `node_modules` and running `npm install` in the `assets` directory

**Port already in use:**
- Another process might be using port 4000
- Kill the process or change the port in `config/dev.exs`

## Next Steps

Now that you have Phoenix installed and running, you're ready to start building web applications! Here are some recommended next steps:

1. **Read the Phoenix Guides** - The official [Phoenix Guides](https://hexdocs.pm/phoenix/overview.html) are an excellent resource
2. **Learn Elixir** - If you're new to Elixir, check out the [Elixir Getting Started guide](https://elixir-lang.org/getting-started/introduction.html)
3. **Build a Simple App** - Try following the Phoenix [Up and Running guide](https://hexdocs.pm/phoenix/up_and_running.html)

## Additional Resources

- [Phoenix Framework Documentation](https://hexdocs.pm/phoenix/)
- [Elixir Documentation](https://hexdocs.pm/elixir/)
- [Phoenix GitHub Repository](https://github.com/phoenixframework/phoenix)
- [Elixir Forum](https://elixirforum.com/)

Happy coding with Phoenix! 🔥