defmodule SkimsafeBloggWeb.PrivacyLive do
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
          <h1>Privacy Policy</h1>
          <p class="text-gray-600 dark:text-gray-300">Last updated: <%= Date.utc_today() %></p>

          <h2>About This Blog</h2>
          <p>
            This developer blog is operated by SkimSafe AB, a Swedish technology company specializing
            in online fraud prevention and identity protection. We are committed to protecting your
            privacy and handling your personal data in accordance with Swedish and European Union
            data protection laws.
          </p>

          <h2>Information We Collect</h2>

          <h3>Blog Content Processing</h3>
          <p>
            When we create and update blog posts, we may use AI services (OpenAI and Anthropic Claude)
            to estimate reading times. This processing happens automatically and does not involve any
            personal data from visitors.
          </p>

          <h3>Website Analytics</h3>
          <p>
            We may collect basic website analytics to understand how our content is used, including:
          </p>
          <ul>
            <li>Page views and time spent reading</li>
            <li>General location information (country/region)</li>
            <li>Device and browser information</li>
            <li>Referring websites</li>
          </ul>

          <h3>Contact Information</h3>
          <p>
            If you contact us directly via email (info@skimsafe.se), we will store your email
            address and message content to respond to your inquiry.
          </p>

          <h2>How We Use Information</h2>
          <p>We use collected information to:</p>
          <ul>
            <li>Improve our blog content and user experience</li>
            <li>Respond to questions and feedback</li>
            <li>Ensure website security and functionality</li>
            <li>Comply with legal obligations</li>
          </ul>

          <h2>Data Storage and Security</h2>
          <p>
            Your data is stored securely and we implement appropriate technical and organizational
            measures to protect it. We retain personal data only as long as necessary for the
            purposes outlined in this policy.
          </p>

          <h2>Your Rights (GDPR)</h2>
          <p>Under GDPR, you have the right to:</p>
          <ul>
            <li>Access your personal data</li>
            <li>Correct inaccurate data</li>
            <li>Request deletion of your data</li>
            <li>Object to data processing</li>
            <li>Data portability</li>
          </ul>

          <h2>Third-Party Services</h2>
          <p>
            We may use third-party services for website functionality and analytics. These services
            have their own privacy policies and may collect data independently.
          </p>

          <h2>Changes to This Policy</h2>
          <p>
            We may update this privacy policy from time to time. The date of the last update is
            shown at the top of this page.
          </p>

          <h2>Contact Us</h2>
          <p>
            If you have questions about this privacy policy or want to exercise your data rights,
            please contact us:
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