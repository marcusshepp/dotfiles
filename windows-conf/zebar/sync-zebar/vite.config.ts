import { defineConfig } from "vite";

export default defineConfig({
  // Zebar loads the widget from a file:// path, so every asset reference has
  // to be relative rather than root-absolute.
  base: "./",
  build: {
    outDir: "build",
    emptyOutDir: true,
    assetsInlineLimit: 0,
  },
});
