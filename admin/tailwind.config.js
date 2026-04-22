/** @type {import('tailwindcss').Config} */
export default {
  content: ["./index.html", "./src/**/*.{js,ts,jsx,tsx}"],
  theme: {
    extend: {
      // Pink's palette — direction A "Pink on Ivory", carried over from the
      // mobile app exactly so design tokens are a single source of truth.
      colors: {
        bg: "#FAF6F3",
        surface: "#FFFFFF",
        "surface-alt": "#F2EBE6",
        ink: "#140A0F",
        "ink-2": "#4A3E44",
        "ink-3": "#8F8289",
        hair: "#ECE3DE",
        "hair-2": "#D9CEC7",
        accent: "#D81B84",
        "accent-ink": "#FFFFFF",
        "accent-soft": "#FBE0EE",
        success: "#2F7A4D",
        "success-soft": "#E3EFE7",
        warn: "#B5811E",
        "warn-soft": "#F6ECD4",
        danger: "#9A2F2F",
        "danger-soft": "#F4DEDE",
        dark: "#140A0F",
      },
      fontFamily: {
        sans: [
          "Inter Tight",
          "Inter",
          "-apple-system",
          "BlinkMacSystemFont",
          "system-ui",
          "sans-serif",
        ],
        display: ["Instrument Serif", "Georgia", "serif"],
        mono: ["JetBrains Mono", "ui-monospace", "monospace"],
      },
      borderRadius: {
        sm: "8px",
        md: "12px",
        lg: "16px",
        xl: "20px",
      },
      fontSize: {
        eyebrow: ["11px", { letterSpacing: "0.15em", fontWeight: "700" }],
      },
    },
  },
  plugins: [],
};
