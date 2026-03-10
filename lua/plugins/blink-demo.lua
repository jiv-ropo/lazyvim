-- Demo plugin: shows how to wire a custom blink.cmp source into LazyVim.
--
-- The source itself lives in lua/blink-demo/init.lua and provides:
--   • keyword completions with icons and labels
--   • per-item documentation shown in the blink.cmp detail window
--   • a textEdit that inserts a short snippet with a tabstop
--
-- Trigger: start typing in any buffer — completions appear automatically
-- for words that start with one of the registered prefixes.
return {
  "saghen/blink.cmp",
  opts = function(_, opts)
    -- Merge our demo source into whatever sources LazyVim already set up.
    opts.sources = opts.sources or {}
    opts.sources.providers = opts.sources.providers or {}

    opts.sources.providers["blink-demo"] = {
      name = "Demo",
      module = "blink-demo",
      -- Show after the built-in sources so it doesn't crowd them out.
      score_offset = -10,
    }

    -- Add to the default completion list (insert-mode).
    opts.sources.default = opts.sources.default or { "lsp", "path", "snippets", "buffer" }
    table.insert(opts.sources.default, "blink-demo")

    -- DEBUG: remove after inspecting
    -- vim.notify(vim.inspect(opts), vim.log.levels.INFO, { title = "blink-demo opts" })

    return opts
  end,
}
