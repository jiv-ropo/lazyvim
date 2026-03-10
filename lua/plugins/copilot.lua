return {
  {
    "zbirenbaum/copilot.lua",
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        hide_during_completion = false,
        keymap = {
          accept = "<M-l>",
          accept_word = "<M-k>",
          accept_line = "<M-j>",
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<M-h>",
          refresh = "<S-ä>",
        },
      },
      filetypes = {
        markdown = true,
        help = true,
        bash = true,
        sh = true,
        ["."] = true,
        ["*"] = true,
      },
    },
  },
}
