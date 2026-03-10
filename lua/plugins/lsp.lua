return {
  "neovim/nvim-lspconfig",
  opts = {
    diagnostics = {
      virtual_text = false,
    },
    servers = {
      --      ["*"] = {
      --        keys = {
      --          -- Disable some hover thing. It's messing up with Undotree browsing.
      --          { "K", false },
      --        },
      --      },
      intelephense = {
        cmd = { "intelephense", "--stdio" },
        filetypes = { "php" },
        root_markers = { ".git", "composer.json" },
      },
      lua_ls = {
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
          },
        },
      },
    },
  },
}
