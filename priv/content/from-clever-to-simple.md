# From Clever to Simple: Building a Campaign Admin Interface

I recently built an admin interface for managing marketing campaigns in Trinity. What started as a “let’s do this the clever way” slowly turned into a reminder that simple solutions are often good enough—and that over-engineering is very easy.

My first instinct was to optimize early. Campaigns were going to be read by LiveView pages, so I thought: let’s build a GenServer backed by ETS. The idea was straightforward: load all active campaigns at application startup, keep them in memory, and make lookups extremely fast. The GenServer would live in the supervision tree, populate an ETS table from Postgres, expose helpers to fetch campaigns by market and type, and handle cache invalidation whenever something changed in the admin interface.

On paper, this felt very Elixir-ish. OTP gives you great tools for concurrent state and in-memory data, and ETS is ridiculously fast. It looked like a solid design.

Then I paused and actually looked at the problem I was solving.

We had a small number of campaigns, not thousands. Lookups happened once per page load, not at some extreme rate. The cache invalidation logic was already getting more complex than the actual business rules. And on top of that, Postgres is really good at what it does when you give it proper indexes.

At that point it became obvious: this was a textbook YAGNI moment.

So I retired my GenServer and went back to basics. Campaigns live in the database, and when the application needs one, it just queries for it.

The schema itself stayed fairly rich, since campaigns needed to support multiple markets (Sweden and Norway for now), different campaign types (B2C and B2B), custom branding, flexible content, and routing based on URL paths. Fields like `market`, `campaign_type`, `path`, and `active` handle selection, while a `custom_data` JSONB column gives room to grow without constant migrations. Logos are associated normally.

Fetching a campaign became a single, readable query. Given a market, path, and campaign type, normalize the input, filter on active campaigns, preload what’s needed, and return either a result or `:not_found`. No in-memory state, no synchronization concerns, and no “did the cache update correctly?” questions.

On the admin side, Alkemist did most of the heavy lifting. With a handful of lines, I had a full CRUD interface: list views with the right columns, edit forms, create/update/delete actions, and auditing baked in. There was no need to write custom controllers or worry about edge cases since the framework handled it cleanly.

Integrating this into LiveView was almost boring, which is exactly what you want. On mount, the view grabs the campaign based on the incoming path and market, maps it into rendering options, and assigns it to the socket. If nothing matches, redirect and move on. No indirection, no extra processes involved.

The end result is a system that supports multi-market campaigns, partner branding, image uploads, flexible content, and path-based routing without any complex state management. It’s easier to read, easier to debug, and far easier to modify later.

The GenServer + ETS approach wasn’t wrong. It just solved a problem that didn’t exist yet. In this case, trusting the database and keeping things simple turned out to be the better engineering decision.

//Louise Blanc