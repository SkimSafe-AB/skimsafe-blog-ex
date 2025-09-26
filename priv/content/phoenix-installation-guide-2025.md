# Phoenix Installation Guide 2025

Getting Phoenix up and running is honestly pretty straightforward, but there are a few moving pieces you need to get in place first. I've done this setup more times than I can count now, so let me walk you through it step by step and save you from the gotchas I've run into.

## What You Need Before We Start

Before we can install Phoenix, we need to get a few things sorted. Think of this as setting up your development toolkit, you only have to do this once, and then you're golden for all your future Phoenix projects.

### 1. Elixir and Erlang - The Foundation

Phoenix runs on Elixir, which runs on the Erlang Virtual Machine (BEAM). You need both, but the good news is that installing Elixir usually brings Erlang along for the ride.

**For macOS (using Homebrew):**
```bash
brew install elixir
```

When you run brew install elixir on macOS, Homebrew automatically installs Erlang as a dependency. You don't need to explicitly install it separately.

**For Ubuntu/Debian:**
```bash
# First, add the Erlang Solutions repository
wget https://packages.erlang-solutions.com/erlang-solutions_2.0_all.deb
sudo dpkg -i erlang-solutions_2.0_all.deb
sudo apt-get update

# Now install to get the full package
sudo apt-get install elixir erlang-dev erlang-parsetools
```

The erlang-dev and erlang-parsetools packages are important, or you risk to run into weird compilation errors later. Don't be that person!

**erlang-dev:**
- Contains header files and development tools needed to compile Erlang/Elixir applications
- Essential for compiling NIFs (Native Implemented Functions) and ports
- Required when installing packages that have native dependencies (like some database drivers, crypto libraries, etc.)

**erlang-parsetools:**
- Contains tools like yecc (Yet Another Compiler Compiler) and leex (Lexical Analyzer Generator)
- Needed when compiling packages that generate parsers or lexers
- Some Phoenix dependencies or third-party packages require these tools

**Other systems:**
- **macOS (Homebrew):** brew install erlang includes these by default
- **Windows:** The Erlang installer is typically complete
- **asdf:** Builds from source, so includes everything

**For Windows:**
Head over to elixir-lang.org and grab the installer

Windows folks, I feel for you. The installer should handle everything, but if you run into issues, the Elixir community forum is super helpful.

### 2. PostgreSQL - Your Database

Phoenix supports multiple databases, but PostgreSQL is the default and probably the best choice for most projects. It's solid, well-supported, and plays nicely with Ecto (Phoenix's database wrapper).

**For macOS:**
```bash
brew install postgresql
brew services start postgresql
```

That brew services start postgresql command starts PostgreSQL as a background service. Super convenient, it'll start automatically when you boot your machine.

**For Ubuntu/Debian:**
```bash
sudo apt-get install postgresql postgresql-contrib
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

The postgresql-contrib package gives you some extra utilities:
- uuid-ossp - for generating UUIDs (very common in Phoenix apps)
- pgcrypto - cryptographic functions
- hstore - key-value pairs within PostgreSQL
- pg_trgm - trigram matching for fuzzy text search

The systemctl enable command makes sure PostgreSQL starts on boot.

## Phoenix 1.7 Changes - What's New in 2025

Before we dive into installation, it's important to understand what's changed in Phoenix 1.7+, as it affects how you'll work with assets and the overall development experience:

### New Asset Pipeline
Phoenix 1.7+ has completely revamped how it handles assets:
- **No Node.js required** for basic Phoenix applications
- Uses **esbuild** (via Elixir wrapper) for JavaScript compilation
- Uses **tailwindcss** (via Elixir wrapper) for CSS processing
- Asset compilation happens entirely through Elixir, making the setup much simpler

### LiveView is Now Central
- **LiveView** is no longer an add-on - it's a core part of new Phoenix applications
- New project templates include LiveView examples by default
- The directory structure reflects this LiveView-first approach
- You get real-time, interactive features without writing JavaScript

### What This Means for You
- Faster setup (no npm install steps)
- Fewer moving parts in your development environment
- More consistent tooling across the Phoenix ecosystem
- LiveView makes building interactive UIs much easier

## Installing Phoenix - The Main Event

Alright, now that we've got our prerequisites sorted, let's actually install Phoenix!

### 1. Install Hex Package Manager

First, we need Hex, which is Elixir's package manager:
```bash
mix local.hex
```

If you're coming from other ecosystems, think of Hex like npm for Node.js or pip for Python. It handles all the dependency management stuff.

### 2. Install Phoenix Generator

```bash
mix archive.install hex phx_new
```

This command installs the Phoenix application generator - basically a tool that creates new Phoenix projects with all the boilerplate set up for you. It's a huge time saver and ensures you start with all the right conventions.

You might see a prompt asking if you want to install the archive. Say yes! That's what we want.

## Creating Your First Phoenix Project

Time to create something! Let's make a new Phoenix app and see if everything is working:

```bash
mix phx.new my_new_app
cd my_new_app
```

The generator will ask you a few questions:
- Fetch and install dependencies? - Say yes (Y)
- Database config - The defaults are usually fine for local development

You'll see a bunch of output as it creates files and downloads dependencies. Don't worry if it looks like a lot, Phoenix is just setting up everything you need for a full-featured web application.

### Install Dependencies

```bash
mix deps.get
```

This downloads all the Elixir dependencies your project needs. Think of it like npm install but for Elixir packages.

### Setup the Database

**Best Practice 2025 - Step-by-step approach:**
```bash
mix ecto.create    # Create the database
mix ecto.migrate   # Run migrations
```

**Alternative (if you prefer one command):**
```bash
mix ecto.setup
```

The step-by-step approach is recommended because it gives you better error handling and control. When `mix ecto.setup` fails, you can't tell which step broke. Individual commands give you precise feedback, which is especially helpful in team environments and CI/CD pipelines.

### Fire It Up!

```bash
mix phx.server
```

If everything worked correctly, you should see something like:
```
[info] Running MyNewAppWeb.Endpoint with cowboy 2.9.0 at 127.0.0.1:4000 (http)
[info] Access MyNewAppWeb.Endpoint at http://localhost:4000
```

Now open your browser and go to http://localhost:4000. You should see the Phoenix welcome page with a phoenix logo and some LiveView examples.

If you see all that, you're golden. If not, let's troubleshoot!

## When Things Go Wrong (Troubleshooting)

I've been through most of these issues myself, so here are the common ones and how to fix them:

### "Mix command not found"
This usually means Elixir isn't installed properly or isn't in your system PATH.
- **Double-check the installation** - Run `elixir --version` to see if Elixir is actually installed
- **Restart your terminal** - Sometimes you need to restart for PATH changes to take effect
- **Check your shell configuration** - Make sure your .bashrc, .zshrc, or whatever shell config file has the right paths

### Database Connection Errors
Usually looks something like "connection refused" or "database does not exist".
- **Is PostgreSQL running?** - Run `brew services list | grep postgresql` on Mac or `sudo systemctl status postgresql` on Linux
- **Check your database config** - Look at `config/dev.exs` and make sure the username/password match your PostgreSQL setup

### Port 4000 Already in Use
This happens when you've got another Phoenix app running or some other process is using port 4000.
- **Kill the other process** - Find it with `lsof -i :4000` and kill it
- **Use a different port** - Change the port in `config/dev.exs` or start with `PORT=4001 mix phx.server`

### Asset Compilation Issues
With Phoenix 1.7+, these are rare since we don't rely on Node.js, but if you do encounter them:
- **Make sure your dependencies are up to date** - Run `mix deps.get`
- **Clear the build cache** - Run `mix clean` and rebuild

## What's Next?

Awesome! You've got Phoenix installed and running. Now the fun really begins. Here's what I'd recommend doing next:

### 1. Play Around with the Generated App

Before diving into building your own stuff, explore what Phoenix generated for you. Check out:

**Phoenix 1.7+ Directory Structure:**
- `lib/my_new_app_web/` - This is where your web-related code lives
- `lib/my_new_app_web/router.ex` - This defines your routes
- `lib/my_new_app_web/controllers/` - Your controller logic
- `lib/my_new_app_web/live/` - Your LiveView modules (the new hotness!)
- `lib/my_new_app_web/components/` - Reusable UI components

**Note:** Phoenix 1.7+ has moved away from traditional templates in favor of function components and LiveView. You'll see more `.heex` files (HEEx templates) and function components instead of the old template structure.

### 2. Learn Elixir If You Haven't Already

If you're new to Elixir, definitely check out our Elixir Basics for Beginners guide. Phoenix is built on Elixir, so understanding the language will make everything else click into place.

### 3. Dive into LiveView

LiveView is now a core part of Phoenix! The generated app includes LiveView examples that show you:
- Real-time updates without JavaScript
- Interactive forms and components  
- Live navigation
- Component-based architecture

Play around with the examples in `lib/my_new_app_web/live/` to see what's possible.

### 4. When You Need Node.js

Remember, while Phoenix 1.7+ doesn't require Node.js for basic functionality, you might still need it if you:
- Want to add specific npm packages
- Need complex JavaScript tooling
- Are working with React/Vue integration
- Are maintaining older Phoenix projects

You can always add Node.js later when you actually need it!

## Resources Worth Bookmarking

- [Phoenix Framework Documentation](https://hexdocs.pm/phoenix/) - Really well written and comprehensive
- [Elixir Documentation](https://elixir-lang.org/docs.html) - Essential if you're learning Elixir
- [Elixir Forum](https://elixirforum.com/) - Super helpful community, great for asking questions
- [Phoenix GitHub Repository](https://github.com/phoenixframework/phoenix) - Source code and issues
- [LiveView Documentation](https://hexdocs.pm/phoenix_live_view/) - Essential for understanding the new LiveView-centric approach

Once you have it running, you'll be amazed at how productive you can be.

Now go build something awesome! 🔥