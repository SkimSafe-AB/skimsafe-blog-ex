defmodule SkimsafeBloggWeb.HomeLive do
  use SkimsafeBloggWeb, :live_view

  alias SkimsafeBlogg.Resources.Post

  def mount(_params, _session, socket) do
    # Get featured posts (published and featured)
    {:ok, featured_page} = Post.list_featured()
    featured_posts = featured_page.results

    # Get recent posts (published, ordered by date)
    {:ok, recent_page} = Post.list_recent()
    recent_posts = recent_page.results

    # Get all posts for the "View All" section (first 6)
    {:ok, all_posts_page} = Post.list_all_posts()
    all_posts = all_posts_page.results
    has_more_posts = all_posts_page.more?

    socket =
      socket
      |> assign(:featured_posts, featured_posts)
      |> assign(:recent_posts, recent_posts)
      |> assign(:all_posts, all_posts)
      |> assign(:has_more_posts, has_more_posts)
      |> assign(:page_offset, 0)
      |> assign(:loading_more, false)

    {:ok, socket}
  end

  def handle_event("load_more", _params, socket) do
    new_offset = socket.assigns.page_offset + 6

    # Get next batch of posts using Ash pagination
    {:ok, more_posts_page} = Post.list_all_posts(page: [offset: new_offset, limit: 6])
    new_posts = more_posts_page.results

    socket =
      socket
      |> assign(:all_posts, socket.assigns.all_posts ++ new_posts)
      |> assign(:has_more_posts, more_posts_page.more?)
      |> assign(:page_offset, new_offset)
      |> assign(:loading_more, false)

    {:noreply, socket}
  end

  def handle_event("loading_more", _params, socket) do
    {:noreply, assign(socket, :loading_more, true)}
  end

  def handle_event("show_less", _params, socket) do
    # Get the first 6 posts again
    {:ok, all_posts_page} = Post.list_all_posts()
    first_six_posts = all_posts_page.results

    socket =
      socket
      |> assign(:all_posts, first_six_posts)
      |> assign(:has_more_posts, all_posts_page.more?)
      |> assign(:page_offset, 0)

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-white dark:bg-gray-900">
      <Layouts.flash_group flash={@flash} />
      
    <!-- Hero Section -->
      <div class="bg-white dark:bg-gray-900 py-16">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div class="text-center">
            <h1 class="text-4xl font-bold text-gray-900 sm:text-5xl lg:text-6xl dark:text-white mb-6">
              Developer Blog
            </h1>
            <p class="text-xl text-gray-600 max-w-3xl mx-auto dark:text-gray-300">
              Exploring Elixir, Phoenix, and modern web development through practical insights and tutorials.
            </p>
          </div>
        </div>
      </div>
      
    <!-- Main Content -->
      <div class="max-w-7xl mx-auto px-4 py-12 sm:px-6 lg:px-8">
        <!-- Featured Post Section -->
        <div class="mb-12">
          <h2 class="text-2xl font-bold text-gray-900 mb-6 dark:text-white">Featured Post</h2>
          <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
            <.featured_blog_card
              :for={post <- @featured_posts}
              title={post.title}
              excerpt={post.excerpt}
              author={post.author}
              published_at={post.published_date_string}
              read_time={post.read_time}
              tags={post.tags}
              href={post.href}
            />
          </div>
        </div>
        
    <!-- Recent Posts Section -->
        <div class="mb-12">
          <h2 class="text-2xl font-bold text-gray-900 mb-6 dark:text-white">Recent Posts</h2>
          <.blog_grid posts={@recent_posts} />
        </div>
        
    <!-- All Posts Section -->
        <div class="mb-12">
          <h2 class="text-2xl font-bold text-gray-900 mb-6 dark:text-white">All Posts</h2>
          <.blog_grid posts={@all_posts} />
          
    <!-- Load More / Show Less Buttons -->
          <div class="text-center mt-8 space-y-4">
            <!-- Load More Button -->
            <div :if={@has_more_posts}>
              <button
                phx-click="load_more"
                phx-click-loading="loading_more"
                disabled={@loading_more}
                class={[
                  "inline-flex items-center px-6 py-3 border border-transparent text-base font-medium rounded-md",
                  "bg-purple-600 text-white hover:bg-purple-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-purple-500",
                  "disabled:opacity-50 disabled:cursor-not-allowed transition-colors duration-200",
                  "dark:focus:ring-offset-gray-900"
                ]}
              >
                <span :if={!@loading_more}>Load More Posts</span>
                <span :if={@loading_more} class="flex items-center">
                  <svg
                    class="animate-spin -ml-1 mr-2 h-4 w-4 text-white"
                    xmlns="http://www.w3.org/2000/svg"
                    fill="none"
                    viewBox="0 0 24 24"
                  >
                    <circle
                      class="opacity-25"
                      cx="12"
                      cy="12"
                      r="10"
                      stroke="currentColor"
                      stroke-width="4"
                    >
                    </circle>
                    <path
                      class="opacity-75"
                      fill="currentColor"
                      d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
                    >
                    </path>
                  </svg>
                  Loading...
                </span>
              </button>
            </div>
            
    <!-- Show Less Button -->
            <div :if={@page_offset > 0}>
              <button
                phx-click="show_less"
                class={[
                  "inline-flex items-center px-6 py-3 border border-gray-300 dark:border-gray-600 text-base font-medium rounded-md",
                  "bg-white dark:bg-gray-800 text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700",
                  "focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-purple-500 transition-colors duration-200",
                  "dark:focus:ring-offset-gray-900"
                ]}
              >
                <.icon name="hero-chevron-up" class="w-4 h-4 mr-2" /> Show Less
              </button>
            </div>
          </div>
        </div>
        
    <!-- Quick Links Section -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <div class="bg-white border border-gray-200 rounded-lg p-6 dark:bg-gray-900 dark:border-gray-700">
            <h3 class="text-lg font-semibold text-gray-900 mb-4 dark:text-white">Getting Started</h3>
            <div class="space-y-3">
              <.blog_list_item
                title="Phoenix Installation Guide"
                author="Tech Team"
                published_at="Sep 20, 2025"
                read_time="5 min read"
                href="/posts/phoenix-installation"
              />
              <.blog_list_item
                title="Elixir Basics for Beginners"
                author="Tech Team"
                published_at="Sep 18, 2025"
                read_time="7 min read"
                href="/posts/elixir-basics"
              />
              <.blog_list_item
                title="Your First Phoenix App"
                author="Tech Team"
                published_at="Sep 15, 2025"
                read_time="10 min read"
                href="/posts/first-phoenix-app"
              />
            </div>
          </div>

          <div class="bg-white border border-gray-200 rounded-lg p-6 dark:bg-gray-900 dark:border-gray-700">
            <h3 class="text-lg font-semibold text-gray-900 mb-4 dark:text-white">Community</h3>
            <div class="space-y-4">
              <a
                href="https://elixirforum.com"
                class="flex items-center space-x-3 text-gray-600 hover:text-purple-600 transition-colors dark:text-gray-400 dark:hover:text-purple-400"
              >
                <.icon name="hero-chat-bubble-left-right" class="w-5 h-5" />
                <span>Join the Discussion</span>
              </a>
              <a
                href="https://github.com/phoenixframework/phoenix"
                class="flex items-center space-x-3 text-gray-600 hover:text-purple-600 transition-colors dark:text-gray-400 dark:hover:text-purple-400"
              >
                <.icon name="hero-code-bracket" class="w-5 h-5" />
                <span>Contribute to Phoenix</span>
              </a>
              <a
                href="https://hexdocs.pm/phoenix"
                class="flex items-center space-x-3 text-gray-600 hover:text-purple-600 transition-colors dark:text-gray-400 dark:hover:text-purple-400"
              >
                <.icon name="hero-book-open" class="w-5 h-5" />
                <span>Read the Docs</span>
              </a>
            </div>
          </div>
        </div>
      </div>
      
    <!-- Footer Section -->
      <footer class="bg-gray-900 text-white dark:bg-black">
        <div class="max-w-7xl mx-auto px-4 py-12 sm:px-6 lg:px-8">
          <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
            <!-- Company Info -->
            <div>
              <div class="flex items-center space-x-3 mb-4">
                <div class="w-8 h-8 bg-purple-600 rounded-lg flex items-center justify-center">
                  <span class="text-white font-bold text-lg">S</span>
                </div>
                <h3 class="text-xl font-bold text-white">SkimSafe</h3>
              </div>
              <p class="text-gray-300 leading-relaxed mb-6">
                SkimSafe AB is a leading Swedish technology company specializing in online fraud prevention
                and identity protection. We help individuals and businesses protect themselves against
                digital fraud, identity theft, and online security threats.
              </p>
            </div>
            
    <!-- Contact Info -->
            <div>
              <h4 class="text-lg font-semibold text-white mb-4">Contact</h4>
              <div class="space-y-3">
                <div class="flex items-center space-x-3 text-gray-300">
                  <.icon name="hero-envelope" class="w-5 h-5 text-purple-400" />
                  <span>info@skimsafe.se</span>
                </div>
                <div class="flex items-center space-x-3 text-gray-300">
                  <.icon name="hero-map-pin" class="w-5 h-5 text-purple-400" />
                  <span>Surbrunnsgatan 32</span>
                </div>
                <div class="flex items-center space-x-3 text-gray-300">
                  <.icon name="hero-map-pin" class="w-5 h-5 text-purple-400" />
                  <span>Stockholm, Sweden</span>
                </div>
              </div>
            </div>
            
    <!-- Quick Links -->
            <div>
              <h4 class="text-lg font-semibold text-white mb-4">Quick Links</h4>
              <ul class="space-y-3">
                <li>
                  <a href="/about" class="text-gray-300 hover:text-purple-400 transition-colors">
                    About Us
                  </a>
                </li>
                <li>
                  <a href="/blog" class="text-gray-300 hover:text-purple-400 transition-colors">
                    Blog
                  </a>
                </li>
                <li>
                  <a href="/contact" class="text-gray-300 hover:text-purple-400 transition-colors">
                    Contact
                  </a>
                </li>
              </ul>
            </div>
          </div>
          
    <!-- Footer Bottom -->
          <div class="border-t border-gray-700 mt-12 pt-8">
            <div class="flex flex-col md:flex-row justify-between items-center space-y-4 md:space-y-0">
              <div class="flex items-center space-x-6">
                <p class="text-gray-400 text-sm">
                  © 2025 SkimSafe. All rights reserved.
                </p>
                <div class="flex items-center space-x-4">
                  <a
                    href="/privacy"
                    class="text-gray-400 hover:text-purple-400 text-sm transition-colors"
                  >
                    Privacy Policy
                  </a>
                  <a
                    href="/terms"
                    class="text-gray-400 hover:text-purple-400 text-sm transition-colors"
                  >
                    Terms of Service
                  </a>
                </div>
              </div>
              
    <!-- Social Links -->
              <div class="flex items-center space-x-4">
                <a
                  href="https://github.com/skimsafe"
                  class="text-gray-400 hover:text-purple-400 transition-colors"
                  aria-label="GitHub"
                >
                  <.icon name="hero-code-bracket" class="w-5 h-5" />
                </a>
                <a
                  href="https://www.linkedin.com/company/skimsafe"
                  class="text-gray-400 hover:text-purple-400 transition-colors"
                  aria-label="LinkedIn"
                >
                  <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 24 24" aria-hidden="true">
                    <path d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433c-1.144 0-2.063-.926-2.063-2.065 0-1.138.92-2.063 2.063-2.063 1.14 0 2.064.925 2.064 2.063 0 1.139-.925 2.065-2.064 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z" />
                  </svg>
                </a>
                <a
                  href="mailto:info@skimsafe.se"
                  class="text-gray-400 hover:text-purple-400 transition-colors"
                  aria-label="Email"
                >
                  <.icon name="hero-envelope" class="w-5 h-5" />
                </a>
              </div>
            </div>
            
    <!-- Additional Info -->
            <div class="mt-6 text-center">
              <p class="text-gray-500 text-xs">
                Built with ❤️ using Phoenix LiveView and Elixir.
                <a href="https://phoenixframework.org" class="text-purple-400 hover:text-purple-300">
                  Powered by Phoenix & Ash Framework
                </a>
              </p>
            </div>
          </div>
        </div>
      </footer>
    </div>
    """
  end
end
