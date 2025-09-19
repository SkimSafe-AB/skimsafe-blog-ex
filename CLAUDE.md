# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Phoenix 1.8 web application using Ash Framework for resource modeling and data management. The project uses SQLite as the database with Ecto.Adapters.SQLite3 and AshSqlite.DataLayer.

## Development Commands

### Setup and Installation
- `mix setup` - Install and setup all dependencies (includes deps.get, ecto.setup, assets.setup, assets.build)
- `mix deps.get` - Install Elixir dependencies

### Running the Application
- `mix phx.server` - Start Phoenix server (available at http://localhost:4000)
- `iex -S mix phx.server` - Start server in interactive Elixir shell

### Development Workflow
- `mix precommit` - Run complete pre-commit checks (compile with warnings as errors, deps.unlock --unused, format, test)
- `mix test` - Run tests (includes ecto.create --quiet, ecto.migrate --quiet)
- `mix test test/path/to/test.exs` - Run specific test file
- `mix test --failed` - Run only previously failed tests

### Database Management
- `mix ecto.setup` - Create database, run migrations, and seed data
- `mix ecto.reset` - Drop and recreate database
- `mix ecto.create` - Create database
- `mix ecto.migrate` - Run database migrations

### Asset Management
- `mix assets.setup` - Install Tailwind and ESBuild if missing
- `mix assets.build` - Build assets (compile + tailwind + esbuild)
- `mix assets.deploy` - Build and minify assets for production

## Architecture

### Tech Stack
- **Web Framework**: Phoenix 1.8 with LiveView
- **Data Layer**: Ash Framework with AshSqlite for SQLite integration
- **Database**: SQLite3 via Ecto.Adapters.SQLite3
- **Frontend**: Phoenix LiveView with HEEx templates, Tailwind CSS, ESBuild
- **HTTP Client**: Req library (preferred over httpoison/tesla)

### Key Directories
- `lib/skimsafe_blogg/` - Core application logic and Ash resources
- `lib/skimsafe_blogg_web/` - Web interface (controllers, views, templates, components)
- `lib/skimsafe_blogg_web/components/` - Reusable Phoenix Components
- `priv/repo/` - Database files and seeds
- `assets/` - Frontend assets (JS, CSS)
- `test/` - Test files

### Ash Framework Integration
- Resources are defined in `lib/skimsafe_blogg/resources/`
- Uses AshSqlite.DataLayer for SQLite integration
- Post resource exists but is currently empty - likely needs implementation

### Database Setup
- Uses SQLite3 database (`skimsafe_blogg_dev.sqlite3`)
- Ecto repo configured with Ecto.Adapters.SQLite3 and AshSqlite.DataLayer
- No migrations exist yet - database structure likely managed through Ash resources

## Important Project Guidelines

This project includes comprehensive development guidelines in AGENTS.md covering:
- Phoenix 1.8 specific patterns (LiveView, HEEx templates, components)
- Elixir language guidelines and best practices
- UI/UX guidelines emphasizing world-class design
- Use of Req library for HTTP requests
- Tailwind CSS and modern frontend practices

Key points:
- Always run `mix precommit` before finalizing changes
- Use the Ash Framework for data modeling and persistence
- Follow Phoenix 1.8 LiveView patterns
- Use HEEx templates with proper syntax
- Employ Tailwind CSS for styling
- Use the Req library for HTTP requests