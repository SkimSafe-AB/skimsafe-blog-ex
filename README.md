# SkimSafe Blog

A modern Phoenix 1.8 blog application built with Elixir, featuring automated content management, AI-powered features, and seamless deployment capabilities.

## ✨ Features

### 🤖 AI-Powered Content Management
- **Automated Content Loading** - GenServer that loads blog posts on application startup
- **AI-Generated Excerpts** - Smart summaries using Claude/OpenAI APIs for compelling blog cards
- **Intelligent Tagging** - Automatic tag generation for improved content discovery
- **Smart Read Time Estimation** - AI-powered reading time calculation with word count fallback

### 🎨 Modern UI/UX
- **Phoenix LiveView** - Interactive, real-time user interface
- **Tailwind CSS** - Beautiful, responsive design
- **Syntax Highlighting** - Code blocks with Makeup highlighting for Elixir/Erlang
- **Responsive Blog Cards** - Clean, mobile-first design with limited tag display (max 5)

### 🚀 Deployment Ready
- **Zero-Downtime Deployments** - Automated content loading ensures posts appear after deployment
- **SQLite Database** - Lightweight, file-based database perfect for blogs
- **Release Packaging** - Production-ready releases with `mix release`
- **Environment Configuration** - Flexible config for dev/staging/production

## 🏗️ Architecture

### Tech Stack
- **Web Framework**: Phoenix 1.8 with LiveView
- **Data Layer**: Ash Framework with AshSqlite for SQLite integration
- **Database**: SQLite3 via Ecto.Adapters.SQLite3
- **Frontend**: Phoenix LiveView, HEEx templates, Tailwind CSS, ESBuild
- **HTTP Client**: Req library for API calls
- **Markdown Processing**: Earmark + NimblePublisher with Makeup syntax highlighting

### Core Components
- **ContentLoader GenServer** - Automated post loading and processing on startup
- **MarkdownParser** - Extracts frontmatter, generates excerpts, handles featured posts
- **PostRenderer** - Dynamic markdown to HTML conversion with syntax highlighting
- **AI Integration** - Claude (Anthropic) and OpenAI API integration for content enhancement

## 🚀 Getting Started

### Prerequisites
- Elixir 1.15+
- Erlang/OTP 26+
- Node.js (for asset compilation)

### Installation

```bash
# Clone the repository
git clone <your-repo-url>
cd skimsafe_blogg

# Install dependencies and setup database
mix setup

# Start the development server
mix phx.server
```

Visit [`localhost:4000`](http://localhost:4000) to see your blog!

### Development Commands

```bash
# Run all pre-commit checks (recommended before commits)
mix precommit

# Run tests
mix test

# Reset database and reload content
mix ecto.reset

# Generate AI excerpts for posts
mix generate_excerpts

# Auto-tag posts using AI
mix auto_tag_posts

# Estimate read times for posts
mix estimate_read_times
```

## 📝 Content Management

### Adding Blog Posts

1. Create markdown files in `priv/content/`
2. Use frontmatter for metadata:

```markdown
---
title: "Your Post Title"
author: "Your Name"
author_email: "your@email.com"
published: true
featured: false
tags: ["Elixir", "Phoenix", "Tutorial"]
published_at: "2024-01-01"
excerpt: "Optional custom excerpt"
---

# Your Post Title

Your markdown content here...
```

3. Restart the server or run `SkimsafeBlogg.ContentLoader.load_content()` in IEx

### Automated Processing

The ContentLoader automatically:
- ✅ Generates excerpts from content if not provided
- ✅ Sets featured status based on keywords (phoenix-installation, elixir-basics, etc.)
- ✅ Creates AI-generated tags using content analysis
- ✅ Calculates realistic read times
- ✅ Handles updates to existing posts

## 🤖 AI Configuration

### Environment Variables

```bash
# For AI-powered excerpts and tagging
export ANTHROPIC_API_KEY="your-claude-key"
export OPENAI_API_KEY="your-openai-key"
```

### Features Using AI
- **Excerpt Generation** - Creates compelling 150-180 character summaries
- **Auto-Tagging** - Analyzes content to suggest relevant tags
- **Read Time Estimation** - Smart estimation based on content complexity

## 🚀 Deployment

### Production Release

```bash
# Build production assets
mix assets.deploy

# Create production release
MIX_ENV=prod mix release

# Set environment variables
export PHX_SERVER=true
export DATABASE_NAME="skimsafe_blogg_prod.sqlite3"
export SECRET_KEY_BASE="$(mix phx.gen.secret)"

# Start the release
_build/prod/rel/skimsafe_blogg/bin/skimsafe_blogg start
```

### Environment Configuration

The ContentLoader is configured differently per environment:

- **Development**: Disabled by default
- **Production**: Enabled (`load_content_on_startup: true`)
- **Override**: Set `SKIMSAFE_LOAD_CONTENT=true` to force loading

### First Deployment

On fresh deployments with empty databases:
1. Database migrations run automatically
2. ContentLoader detects empty posts table
3. Loads all content from `priv/content/`
4. Generates excerpts, tags, and read times
5. Blog is ready with full content!

## 🧪 Testing

```bash
# Run all tests
mix test

# Run specific test file
mix test test/skimsafe_blogg/content_loader_test.exs

# Run tests with coverage
mix test --cover
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run `mix precommit` to ensure code quality
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request


## 🆘 Support

If you encounter any issues:

1. Run `mix precommit` to catch common problems
2. Check logs for ContentLoader messages during startup
3. Verify environment variables are set correctly for AI features

---

**Built with ❤️ using Elixir and Phoenix+Ash**
