# Website

To start your Phoenix server:

- Install dependencies with `mix deps.get`
- Install Node.js dependencies with `yarn install` or `npm install` inside the `assets` directory
- Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Writing Articles

Articles are stored as markdown files in `priv/articles`. Each article must have
elixir map frontmatter containing the following information:

```markdown
---
%{
  title: "A sample article title",
  published_at: ~D[2020-07-27],
  categories: ["sample"],
  image: "/images/image.jpg"
}
---

This is where the body of the article goes. It is written in markdown.
```

## Learn more

- This Website: https://mattpruitt.com
