# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Context

This is a Phoenix web application serving a personal website/blog at https://mattpruitt.com. It's a content-focused site that renders articles from markdown files stored in the repository.

## Development Commands

**Initial Setup:**
```bash
mix deps.get                     # Install Elixir dependencies
cd assets && npm install         # Install Node.js dependencies for frontend assets
mix setup                        # Run both commands above (alias defined in mix.exs)
```

**Development Server:**
```bash
mix phx.server                   # Start Phoenix server at localhost:4000
```

**Asset Management:**
```bash
cd assets && npm run watch       # Watch and rebuild frontend assets during development
cd assets && npm run deploy      # Build optimized production assets
```

**Code Quality and Testing:**
```bash
mix test                         # Run test suite
mix credo                        # Run static code analysis (configured in .credo.exs)
mix dialyzer                     # Run static type analysis
mix format                       # Format Elixir code according to .formatter.exs
```

**Coverage:**
```bash
mix coveralls                    # Generate test coverage report
mix coveralls.html              # Generate HTML coverage report
mix coveralls.github            # Generate coverage for GitHub integration
```

## Architecture and Structure

### Core Application Structure
- **Website**: Main application module that ensures required dependencies are started
- **WebsiteWeb**: Phoenix web interface module defining controllers, views, channels
- **Website.Article**: Core domain model representing blog articles with parsing capabilities
- **Website.ArticleRepository**: Repository pattern for loading and managing articles
- **Website.ContentLoader**: GenServer that loads articles from filesystem at startup

### Article System
Articles are stored as markdown files in `priv/articles/` with Elixir map frontmatter:
```markdown
---
%{
  title: "Article Title",
  published_at: ~D[2020-07-27],
  categories: ["category"],
  image: "/images/image.jpg",
  show_title: true  # optional, defaults based on file type
}
---

Article content in markdown...
```

The system supports two file types:
- `.md` files: Standard markdown parsed by `Website.Markdown`
- `.livemd` files: Livebook notebooks parsed by `Website.Fakebook`

### Key Components
- **Website.Highlighter**: Syntax highlighting for code blocks using Makeup
- **Website.Markdown**: Markdown to HTML conversion using Earmark
- **Website.Fakebook**: Livebook notebook parsing and formatting
- **WebsiteWeb.Router**: Defines routes for home page, articles listing, individual articles, tags, and RSS feed

### Frontend
- **Framework**: Phoenix with traditional server-rendered HTML
- **CSS**: Tailwind CSS with typography plugin
- **JS**: Alpine.js for lightweight client-side interactions
- **Build**: Webpack 4 with Babel for asset compilation

### Web Routes
- `/` - Homepage
- `/articles` - Articles listing
- `/articles/:slug` - Individual article
- `/articles/tags/:tag` - Articles filtered by tag
- `/feed` - RSS/Atom feed

## Content Management

Articles are loaded at application startup by the ContentLoader GenServer and cached in memory. To add new articles:

1. Create a new `.md` file in `priv/articles/`
2. Include proper frontmatter with title, published_at, categories, and image
3. Restart the application to reload the article cache

The application automatically handles:
- Slug generation from filename
- Published/draft status based on published_at date
- Category normalization (lowercased)
- Syntax highlighting in code blocks
- RSS feed generation

## Development Notes

- Uses Phoenix 1.5.x (older version)
- Configured for Elixir ~> 1.7
- Frontend assets are in `assets/` directory with traditional Webpack setup
- Test coverage is tracked with ExCoveralls
- Code quality enforced with Credo (max line length: 120 chars)
- Static typing checked with Dialyzer