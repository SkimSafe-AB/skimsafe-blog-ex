defmodule SkimsafeBloggWeb.AboutLive do
  use SkimsafeBloggWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "About")}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-white dark:bg-gray-900">
      <div class="max-w-4xl mx-auto px-4 py-8">
      <!-- Page Header -->
      <div class="text-center mb-12 pt-8">
        <h1 class="text-4xl font-bold text-gray-900 dark:text-white mb-4">About Us</h1>
        <div class="w-24 h-1 bg-purple-600 mx-auto rounded-full"></div>
      </div>

      <div class="space-y-16">
        <!-- About SkimSafe Section -->
        <section class="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-700 p-8">
          <div class="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
            <div>
              <h2 class="text-3xl font-bold text-gray-900 dark:text-white mb-6">About SkimSafe</h2>
              <div class="space-y-4 text-gray-600 dark:text-gray-300">
                <p class="text-lg font-medium text-gray-800 dark:text-gray-200">
                  In a perfect world, you wouldn't need us.
                </p>
                <p>
                  No one would hack your social media accounts, trick you out of money using your BankID,
                  skim your payment cards during a Sunday stroll, or cyberbully your children.
                </p>
                <p>
                  In a perfect world, we wouldn't need to warn you when someone has gotten hold of your
                  passwords or bank card details, or when fake SMS messages are sent from your "bank".
                </p>
                <p>
                  And you wouldn't need us to help you regain control of your digital life, recover
                  stolen money, or stop bullies from sharing harmful images of your children.
                </p>
                <p class="text-lg font-medium text-gray-800 dark:text-gray-200">
                  Unfortunately, we don't live in a perfect world.
                </p>
                <p>
                  But as a SkimSafe member, you can feel secure knowing you have the market's most
                  comprehensive protection against digital fraud, and that we always have your back.
                  With us, you get a knowledgeable security expert, a caring friend, and a lawyer –
                  all in one service. We're here for you, around the clock.
                </p>
                <p class="text-lg font-semibold text-purple-700 dark:text-purple-300">
                  Since our founding in 2017, we have protected over 400,000 people – something we're incredibly proud of.
                </p>
              </div>

              <!-- Key Services -->
              <div class="mt-8">
                <h3 class="text-xl font-semibold text-gray-900 dark:text-white mb-4">Our Expertise</h3>
                <div class="grid grid-cols-2 gap-4">
                  <div class="flex items-center space-x-3">
                    <div class="w-8 h-8 bg-purple-100 dark:bg-purple-900 rounded-lg flex items-center justify-center">
                      <.icon name="hero-shield-check" class="w-4 h-4 text-purple-600 dark:text-purple-400" />
                    </div>
                    <span class="text-sm font-medium text-gray-700 dark:text-gray-300">Fraud Prevention</span>
                  </div>
                  <div class="flex items-center space-x-3">
                    <div class="w-8 h-8 bg-purple-100 dark:bg-purple-900 rounded-lg flex items-center justify-center">
                      <.icon name="hero-identification" class="w-4 h-4 text-purple-600 dark:text-purple-400" />
                    </div>
                    <span class="text-sm font-medium text-gray-700 dark:text-gray-300">Identity Protection</span>
                  </div>
                  <div class="flex items-center space-x-3">
                    <div class="w-8 h-8 bg-purple-100 dark:bg-purple-900 rounded-lg flex items-center justify-center">
                      <.icon name="hero-credit-card" class="w-4 h-4 text-purple-600 dark:text-purple-400" />
                    </div>
                    <span class="text-sm font-medium text-gray-700 dark:text-gray-300">Payment Security</span>
                  </div>
                  <div class="flex items-center space-x-3">
                    <div class="w-8 h-8 bg-purple-100 dark:bg-purple-900 rounded-lg flex items-center justify-center">
                      <.icon name="hero-magnifying-glass" class="w-4 h-4 text-purple-600 dark:text-purple-400" />
                    </div>
                    <span class="text-sm font-medium text-gray-700 dark:text-gray-300">Fraud Detection</span>
                  </div>
                </div>
              </div>
            </div>

            <!-- Company Stats/Info -->
            <div class="space-y-6">
              <div class="bg-gray-50 dark:bg-gray-800 rounded-lg p-6">
                <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-4">Company Overview</h3>
                <div class="space-y-4">
                  <div class="flex justify-between items-center">
                    <span class="text-gray-600 dark:text-gray-400">Founded</span>
                    <span class="font-medium text-gray-900 dark:text-white">2017</span>
                  </div>
                  <div class="flex justify-between items-center">
                    <span class="text-gray-600 dark:text-gray-400">Location</span>
                    <span class="font-medium text-gray-900 dark:text-white">Stockholm, Sweden</span>
                  </div>
                  <div class="flex justify-between items-center">
                    <span class="text-gray-600 dark:text-gray-400">Team Size</span>
                    <span class="font-medium text-gray-900 dark:text-white">10+ Experts</span>
                  </div>
                  <div class="flex justify-between items-center">
                    <span class="text-gray-600 dark:text-gray-400">Tech Stack</span>
                    <span class="font-medium text-gray-900 dark:text-white">Elixir/Docker/K8s</span>
                  </div>
                </div>
              </div>

              <div class="bg-purple-50 dark:bg-purple-900/20 border border-purple-200 dark:border-purple-800 rounded-lg p-6">
                <h3 class="text-lg font-semibold text-purple-900 dark:text-purple-100 mb-2">Our Mission</h3>
                <p class="text-purple-800 dark:text-purple-200 text-sm">
                  To protect individuals and businesses from online fraud and identity theft,
                  creating a safer digital world for everyone.
                </p>
              </div>
            </div>
          </div>
        </section>

        <!-- About the Blog Section -->
        <section class="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-700 p-8">
          <h2 class="text-3xl font-bold text-gray-900 dark:text-white mb-8 text-center">About This Blog</h2>

          <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
            <!-- Blog Purpose -->
            <div class="lg:col-span-2 space-y-6">
              <div>
                <h3 class="text-xl font-semibold text-gray-900 dark:text-white mb-4">
                  A Developer Blog by Developers
                </h3>
                <div class="space-y-4 text-gray-600 dark:text-gray-300">
                  <p>
                    Welcome to the SkimSafe Developer Blog - a collaborative space where our engineering
                    team shares insights, tutorials, and lessons learned from building secure, scalable
                    web applications.
                  </p>
                  <p>
                    This blog is written and maintained by two passionate developers from our team who
                    believe in sharing knowledge and contributing to the developer community. Here, we
                    dive deep into the technologies we use daily, explore new frameworks, and share
                    practical solutions to real-world problems.
                  </p>
                  <p>
                    Whether you're just starting your journey with Elixir and Phoenix or you're a
                    seasoned developer looking for advanced techniques, you'll find valuable content
                    that combines practical experience with cutting-edge technology.
                  </p>
                </div>
              </div>

              <!-- What You'll Find -->
              <div>
                <h3 class="text-xl font-semibold text-gray-900 dark:text-white mb-4">
                  What You'll Find Here
                </h3>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div class="space-y-3">
                    <div class="flex items-start space-x-3">
                      <.icon name="hero-academic-cap" class="w-5 h-5 text-purple-600 dark:text-purple-400 mt-0.5 flex-shrink-0" />
                      <div>
                        <h4 class="font-medium text-gray-900 dark:text-white">Tutorials & Guides</h4>
                        <p class="text-sm text-gray-600 dark:text-gray-400">Step-by-step guides for Elixir, Phoenix, and LiveView</p>
                      </div>
                    </div>
                    <div class="flex items-start space-x-3">
                      <.icon name="hero-shield-check" class="w-5 h-5 text-purple-600 dark:text-purple-400 mt-0.5 flex-shrink-0" />
                      <div>
                        <h4 class="font-medium text-gray-900 dark:text-white">Security Best Practices</h4>
                        <p class="text-sm text-gray-600 dark:text-gray-400">Cybersecurity insights and secure coding practices</p>
                      </div>
                    </div>
                    <div class="flex items-start space-x-3">
                      <.icon name="hero-cog-6-tooth" class="w-5 h-5 text-purple-600 dark:text-purple-400 mt-0.5 flex-shrink-0" />
                      <div>
                        <h4 class="font-medium text-gray-900 dark:text-white">System Design</h4>
                        <p class="text-sm text-gray-600 dark:text-gray-400">Architecture patterns and scalability strategies</p>
                      </div>
                    </div>
                  </div>
                  <div class="space-y-3">
                    <div class="flex items-start space-x-3">
                      <.icon name="hero-light-bulb" class="w-5 h-5 text-purple-600 dark:text-purple-400 mt-0.5 flex-shrink-0" />
                      <div>
                        <h4 class="font-medium text-gray-900 dark:text-white">Tech Insights</h4>
                        <p class="text-sm text-gray-600 dark:text-gray-400">Deep dives into emerging technologies and frameworks</p>
                      </div>
                    </div>
                    <div class="flex items-start space-x-3">
                      <.icon name="hero-bug-ant" class="w-5 h-5 text-purple-600 dark:text-purple-400 mt-0.5 flex-shrink-0" />
                      <div>
                        <h4 class="font-medium text-gray-900 dark:text-white">Problem Solving</h4>
                        <p class="text-sm text-gray-600 dark:text-gray-400">Real-world debugging and optimization techniques</p>
                      </div>
                    </div>
                    <div class="flex items-start space-x-3">
                      <.icon name="hero-users" class="w-5 h-5 text-purple-600 dark:text-purple-400 mt-0.5 flex-shrink-0" />
                      <div>
                        <h4 class="font-medium text-gray-900 dark:text-white">Team Experiences</h4>
                        <p class="text-sm text-gray-600 dark:text-gray-400">Lessons from our development journey at SkimSafe</p>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <!-- Blog Stats -->
            <div class="space-y-6">
              <div class="bg-gray-50 dark:bg-gray-800 rounded-lg p-6">
                <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-4">Blog Focus Areas</h3>
                <div class="space-y-3">
                  <div class="flex items-center justify-between">
                    <span class="text-gray-600 dark:text-gray-400 text-sm">Elixir & Phoenix</span>
                    <div class="flex items-center">
                      <div class="w-16 h-2 bg-gray-200 dark:bg-gray-700 rounded-full overflow-hidden">
                        <div class="w-full h-full bg-purple-600"></div>
                      </div>
                      <span class="ml-2 text-xs text-gray-500 dark:text-gray-400">40%</span>
                    </div>
                  </div>
                  <div class="flex items-center justify-between">
                    <span class="text-gray-600 dark:text-gray-400 text-sm">Cybersecurity</span>
                    <div class="flex items-center">
                      <div class="w-16 h-2 bg-gray-200 dark:bg-gray-700 rounded-full overflow-hidden">
                        <div class="w-4/5 h-full bg-purple-600"></div>
                      </div>
                      <span class="ml-2 text-xs text-gray-500 dark:text-gray-400">30%</span>
                    </div>
                  </div>
                  <div class="flex items-center justify-between">
                    <span class="text-gray-600 dark:text-gray-400 text-sm">Web Development</span>
                    <div class="flex items-center">
                      <div class="w-16 h-2 bg-gray-200 dark:bg-gray-700 rounded-full overflow-hidden">
                        <div class="w-3/5 h-full bg-purple-600"></div>
                      </div>
                      <span class="ml-2 text-xs text-gray-500 dark:text-gray-400">20%</span>
                    </div>
                  </div>
                  <div class="flex items-center justify-between">
                    <span class="text-gray-600 dark:text-gray-400 text-sm">DevOps & Cloud</span>
                    <div class="flex items-center">
                      <div class="w-16 h-2 bg-gray-200 dark:bg-gray-700 rounded-full overflow-hidden">
                        <div class="w-2/5 h-full bg-purple-600"></div>
                      </div>
                      <span class="ml-2 text-xs text-gray-500 dark:text-gray-400">10%</span>
                    </div>
                  </div>
                </div>
              </div>

              <div class="text-center p-6 bg-gradient-to-br from-purple-50 to-blue-50 dark:from-purple-900/20 dark:to-blue-900/20 rounded-lg border border-purple-200 dark:border-purple-800">
                <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-2">Join Our Community</h3>
                <p class="text-sm text-gray-600 dark:text-gray-300 mb-4">
                  Connect with us and stay updated on our latest posts and insights.
                </p>
                <div class="flex justify-center space-x-4">
                  <a
                    href="https://github.com/skimsafe"
                    class="text-gray-600 hover:text-purple-600 dark:text-gray-400 dark:hover:text-purple-400 transition-colors"
                    aria-label="GitHub"
                  >
                    <.icon name="hero-code-bracket" class="w-5 h-5" />
                  </a>
                  <a
                    href="mailto:blog@skimsafe.com"
                    class="text-gray-600 hover:text-purple-600 dark:text-gray-400 dark:hover:text-purple-400 transition-colors"
                    aria-label="Email"
                  >
                    <.icon name="hero-envelope" class="w-5 h-5" />
                  </a>
                  <a
                    href="https://linkedin.com/company/skimsafe"
                    class="text-gray-600 hover:text-purple-600 dark:text-gray-400 dark:hover:text-purple-400 transition-colors"
                    aria-label="LinkedIn"
                  >
                    <.icon name="hero-building-office" class="w-5 h-5" />
                  </a>
                </div>
              </div>
            </div>
          </div>
        </section>

        <!-- Contact Section -->
        <section class="text-center py-12">
          <h2 class="text-2xl font-bold text-gray-900 dark:text-white mb-4">Get In Touch</h2>
          <p class="text-gray-600 dark:text-gray-300 mb-8 max-w-2xl mx-auto">
            Have questions about our content or want to collaborate? We'd love to hear from you.
          </p>
          <div class="flex flex-col sm:flex-row gap-4 justify-center">
            <a
              href="mailto:blog@skimsafe.com"
              class="inline-flex items-center justify-center px-6 py-3 bg-purple-600 text-white font-medium rounded-lg hover:bg-purple-700 transition-colors"
            >
              <.icon name="hero-envelope" class="w-4 h-4 mr-2" />
              Contact the Blog Team
            </a>
            <a
              href="https://skimsafe.se"
              class="inline-flex items-center justify-center px-6 py-3 border border-gray-300 dark:border-gray-600 text-gray-700 dark:text-gray-300 font-medium rounded-lg hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors"
            >
              <.icon name="hero-building-office" class="w-4 h-4 mr-2" />
              Visit SkimSafe.se
            </a>
          </div>
        </section>
      </div>

      <!-- Back to Blog -->
      <div class="text-center mt-12 pt-8 border-t border-gray-200 dark:border-gray-700">
        <.link
          navigate="/"
          class="inline-flex items-center text-purple-600 hover:text-purple-700 dark:text-purple-400 dark:hover:text-purple-300 font-medium transition-colors"
        >
          <.icon name="hero-arrow-left" class="w-4 h-4 mr-2" />
          Back to Blog
        </.link>
      </div>
      </div>
    </div>
    """
  end
end
