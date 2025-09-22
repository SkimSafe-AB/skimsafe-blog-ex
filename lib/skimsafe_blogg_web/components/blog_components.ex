defmodule SkimsafeBloggWeb.BlogComponents do
  @moduledoc """
  Blog-specific UI components for the SkimSafe Blog application.
  """
  use Phoenix.Component
  import SkimsafeBloggWeb.CoreComponents, only: [icon: 1]

  @doc """
  Renders a blog post card with title, excerpt, author, and metadata.
  """
  attr :title, :string, required: true, doc: "The blog post title"
  attr :excerpt, :string, default: nil, doc: "Brief excerpt or description"
  attr :author, :string, required: true, doc: "Author name"
  attr :published_at, :string, required: true, doc: "Publication date"
  attr :read_time, :string, default: "5 min read", doc: "Estimated reading time"
  attr :tags, :list, default: [], doc: "List of tags"
  attr :href, :string, default: "#", doc: "Link to full post"
  attr :class, :string, default: "", doc: "Additional CSS classes"

  def blog_card(assigns) do
    ~H"""
    <article class={[
      "group relative bg-white border border-gray-200 rounded-lg p-6 transition-all duration-200",
      "hover:shadow-lg hover:border-purple-300 hover:-translate-y-1",
      "dark:bg-gray-900 dark:border-gray-700 dark:hover:border-purple-500",
      @class
    ]}>
      <div class="space-y-4">
        <!-- Header with title and metadata -->
        <div class="space-y-3">
          <h3 class="text-xl font-semibold text-gray-900 group-hover:text-purple-600 transition-colors dark:text-white dark:group-hover:text-purple-400">
            <a href={@href} class="stretched-link">
              {@title}
            </a>
          </h3>

          <div class="flex items-center justify-between text-sm text-gray-600 dark:text-gray-400">
            <div class="flex items-center space-x-3">
              <span class="font-medium text-purple-600 dark:text-purple-400">{@author}</span>
              <span>•</span>
              <time>{@published_at}</time>
              <span>•</span>
              <span>{@read_time}</span>
            </div>
          </div>
        </div>
        
    <!-- Excerpt -->
        <p :if={@excerpt} class="text-gray-600 leading-relaxed line-clamp-3 dark:text-gray-300">
          {@excerpt}
        </p>
        
    <!-- Tags -->
        <div :if={@tags != []} class="flex flex-wrap gap-2">
          <span
            :for={tag <- @tags}
            class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-purple-100 text-purple-800 dark:bg-purple-900 dark:text-purple-200"
          >
            {tag}
          </span>
        </div>
        
    <!-- Read more indicator -->
        <div class="flex items-center text-sm font-medium text-purple-600 group-hover:text-purple-700 transition-colors dark:text-purple-400 dark:group-hover:text-purple-300">
          <span>Read more</span>
          <.icon
            name="hero-arrow-right"
            class="ml-1 w-4 h-4 transition-transform group-hover:translate-x-1"
          />
        </div>
      </div>
    </article>
    """
  end

  @doc """
  Renders a grid of blog post cards.
  """
  attr :posts, :list, required: true, doc: "List of blog posts"
  attr :class, :string, default: "", doc: "Additional CSS classes"

  def blog_grid(assigns) do
    ~H"""
    <div class={[
      "grid gap-6",
      "grid-cols-1 md:grid-cols-2 lg:grid-cols-3",
      @class
    ]}>
      <.blog_card
        :for={post <- @posts}
        title={post.title}
        excerpt={post.excerpt}
        author={post.author}
        published_at={post.published_at}
        read_time={post.read_time}
        tags={post.tags}
        href={post.href}
      />
    </div>
    """
  end

  @doc """
  Renders a featured blog post card with larger styling.
  """
  attr :title, :string, required: true
  attr :excerpt, :string, default: nil
  attr :author, :string, required: true
  attr :published_at, :string, required: true
  attr :read_time, :string, default: "5 min read"
  attr :tags, :list, default: []
  attr :href, :string, default: "#"
  attr :class, :string, default: ""

  def featured_blog_card(assigns) do
    ~H"""
    <article class={[
      "group relative bg-white border border-gray-200 rounded-xl p-8 transition-all duration-200",
      "hover:shadow-xl hover:border-purple-300 hover:-translate-y-2",
      "dark:bg-gray-900 dark:border-gray-700 dark:hover:border-purple-500",
      "lg:col-span-2",
      @class
    ]}>
      <div class="space-y-6">
        <!-- Featured badge -->
        <div class="inline-flex items-center px-3 py-1 rounded-full text-xs font-semibold bg-purple-600 text-white">
          <.icon name="hero-star" class="w-3 h-3 mr-1" /> Featured Post
        </div>
        
    <!-- Header with title and metadata -->
        <div class="space-y-4">
          <h2 class="text-3xl font-bold text-gray-900 group-hover:text-purple-600 transition-colors leading-tight dark:text-white dark:group-hover:text-purple-400">
            <a href={@href} class="stretched-link">
              {@title}
            </a>
          </h2>

          <div class="flex items-center space-x-4 text-sm text-gray-600 dark:text-gray-400">
            <span class="font-medium text-purple-600 text-base dark:text-purple-400">{@author}</span>
            <span>•</span>
            <time>{@published_at}</time>
            <span>•</span>
            <span>{@read_time}</span>
          </div>
        </div>
        
    <!-- Excerpt -->
        <p
          :if={@excerpt}
          class="text-gray-600 leading-relaxed text-lg line-clamp-4 dark:text-gray-300"
        >
          {@excerpt}
        </p>
        
    <!-- Tags -->
        <div :if={@tags != []} class="flex flex-wrap gap-2">
          <span
            :for={tag <- @tags}
            class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-purple-100 text-purple-800 dark:bg-purple-900 dark:text-purple-200"
          >
            {tag}
          </span>
        </div>
        
    <!-- Read more indicator -->
        <div class="flex items-center text-base font-semibold text-purple-600 group-hover:text-purple-700 transition-colors dark:text-purple-400 dark:group-hover:text-purple-300">
          <span>Read full article</span>
          <.icon
            name="hero-arrow-right"
            class="ml-2 w-5 h-5 transition-transform group-hover:translate-x-1"
          />
        </div>
      </div>
    </article>
    """
  end

  @doc """
  Renders a blog post list item for compact layouts.
  """
  attr :title, :string, required: true
  attr :author, :string, required: true
  attr :published_at, :string, required: true
  attr :read_time, :string, default: "5 min read"
  attr :href, :string, default: "#"
  attr :class, :string, default: ""

  def blog_list_item(assigns) do
    ~H"""
    <article class={[
      "group flex items-center justify-between py-4 border-b border-gray-200 last:border-b-0",
      "hover:bg-gray-50 -mx-4 px-4 rounded-lg transition-colors",
      "dark:border-gray-700 dark:hover:bg-gray-800",
      @class
    ]}>
      <div class="flex-1 min-w-0">
        <h4 class="font-medium text-gray-900 group-hover:text-purple-600 transition-colors truncate dark:text-white dark:group-hover:text-purple-400">
          <a href={@href} class="hover:underline">
            {@title}
          </a>
        </h4>
        <div class="flex items-center space-x-2 text-sm text-gray-600 mt-1 dark:text-gray-400">
          <span class="font-medium text-purple-600 dark:text-purple-400">{@author}</span>
          <span>•</span>
          <time>{@published_at}</time>
          <span>•</span>
          <span>{@read_time}</span>
        </div>
      </div>

      <.icon
        name="hero-arrow-right"
        class="w-4 h-4 text-gray-600 group-hover:text-purple-600 group-hover:translate-x-1 transition-all flex-shrink-0 ml-4 dark:text-gray-400 dark:group-hover:text-purple-400"
      />
    </article>
    """
  end
end
