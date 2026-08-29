import js from "@eslint/js"
import globals from "globals"

export default [
  { ignores: ["vendor/**", "node_modules/**", "coverage/**", "gemfiles/**", "tmp/**"] },
  {
    files: ["app/assets/javascripts/**/*.js", "test/javascript/**/*.mjs", "eslint.config.js"],
    languageOptions: {
      ecmaVersion: 2024,
      sourceType: "module",
      globals: { ...globals.browser, ...globals.node }
    },
    rules: {
      ...js.configs.recommended.rules,
      "no-unused-vars": ["error", { varsIgnorePattern: "^_", argsIgnorePattern: "^_" }]
    }
  }
]
