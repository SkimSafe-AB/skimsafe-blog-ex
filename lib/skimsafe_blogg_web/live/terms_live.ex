defmodule SkimsafeBloggWeb.TermsLive do
  use SkimsafeBloggWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-white dark:bg-gray-900">
      <Layouts.flash_group flash={@flash} />

      <!-- Main Content -->
      <div class="max-w-4xl mx-auto px-4 py-12 sm:px-6 lg:px-8">
        <div class="prose prose-lg dark:prose-invert max-w-none">
          <h1>Terms of Service</h1>
          <p class="text-gray-600 dark:text-gray-300">Last updated: <%= Date.utc_today() %></p>

          <h2>About This Service</h2>
          <p>
            This developer blog is owned and operated by SkimSafe AB, a Swedish company registered
            in Stockholm, Sweden. By accessing and using this website, you agree to be bound by
            these terms of service.
          </p>

          <h2>Acceptable Use</h2>
          <p>You may use this blog to:</p>
          <ul>
            <li>Read and share our technical articles and tutorials</li>
            <li>Learn about Elixir, Phoenix, and web development</li>
            <li>Reference our content with proper attribution</li>
          </ul>

          <p>You may not:</p>
          <ul>
            <li>Use automated tools to scrape or download content in bulk</li>
            <li>Republish our content without permission</li>
            <li>Use our content for commercial purposes without authorization</li>
            <li>Attempt to disrupt or interfere with the website's functionality</li>
          </ul>

          <h2>Content Ownership</h2>
          <p>
            All blog posts, articles, code examples, and other content on this website are owned
            by SkimSafe AB unless otherwise noted. We grant you a limited, non-exclusive license
            to view and reference this content for personal and educational purposes.
          </p>

          <h3>Code Examples</h3>
          <p>
            Code snippets and examples in our blog posts are provided for educational purposes.
            You may use these in your own projects, but we recommend understanding and adapting
            them rather than copying directly.
          </p>

          <h2>Disclaimer</h2>
          <p>
            The information on this blog is provided "as is" without warranties of any kind.
            While we strive for accuracy, we make no guarantees about the completeness,
            reliability, or suitability of the information for any particular purpose.
          </p>

          <h2>Limitation of Liability</h2>
          <p>
            SkimSafe AB shall not be liable for any direct, indirect, incidental, special,
            or consequential damages resulting from your use of this website or the information
            contained herein.
          </p>

          <h2>External Links</h2>
          <p>
            Our blog may contain links to third-party websites. We are not responsible for
            the content, privacy policies, or practices of external sites.
          </p>

          <h2>Privacy</h2>
          <p>
            Your privacy is important to us. Please review our
            <a href="/privacy" class="text-purple-600 hover:text-purple-700 dark:text-purple-400">
              Privacy Policy
            </a>
            to understand how we collect and use information.
          </p>

          <h2>Changes to Terms</h2>
          <p>
            We reserve the right to modify these terms at any time. Changes will be effective
            immediately upon posting. Your continued use of the website constitutes acceptance
            of any changes.
          </p>

          <h2>Governing Law</h2>
          <p>
            These terms are governed by Swedish law. Any disputes will be resolved in the
            courts of Stockholm, Sweden.
          </p>

          <h2>Contact Information</h2>
          <p>
            If you have questions about these terms of service, please contact us:
          </p>
          <div class="bg-gray-50 dark:bg-gray-800 p-6 rounded-lg">
            <p class="mb-0">
              <strong>SkimSafe AB</strong><br />
              Surbrunnsgatan 32<br />
              113 48 Stockholm, Sweden<br />
              Email: <a href="mailto:info@skimsafe.se">info@skimsafe.se</a>
            </p>
          </div>
        </div>
      </div>
    </div>
    """
  end
end