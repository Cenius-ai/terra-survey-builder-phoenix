const path = require("path");

module.exports = {
  content: [
    "../lib/terra_web/**/*.*ex",
    "../lib/terra_web/**/*.heex",
    "./js/**/*.js",
  ],
  darkMode: "class",
  theme: {
    extend: {
      colors: {
        card: "var(--card)",
        ring: "var(--ring)",
        muted: "var(--muted)",
        accent: "var(--accent)",
        border: "var(--border)",
        primary: "var(--primary)",
        "on-accent": "var(--on-accent)",
        secondary: "var(--secondary)",
        background: "var(--background)",
        foreground: "var(--foreground)",
        "on-primary": "var(--on-primary)",
        destructive: "var(--destructive)",
        "on-secondary": "var(--on-secondary)",
        "on-destructive": "var(--on-destructive)",
        "card-foreground": "var(--card-foreground)",
        "muted-foreground": "var(--muted-foreground)",
      },
      borderRadius: {
        xl: "var(--radius)",
      },
    },
  },
  plugins: [],
};
