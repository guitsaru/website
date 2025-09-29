const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    "../lib/website_web/templates/**/*.html.eex"
  ],
  safelist: ["prose-red"],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
      },
    },
  },
  variants: {},
  plugins: [
    require('@tailwindcss/typography'),
  ]
}
