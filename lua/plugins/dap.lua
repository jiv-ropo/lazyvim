return {
  "mfussenegger/nvim-dap",
  dependencies = {
    -- Debugger UI
    "rcarriga/nvim-dap-ui",
    -- UI dependencies
    "nvim-neotest/nvim-nio",
    "theHamsta/nvim-dap-virtual-text",
    -- Debuggers
    --   Nvim plugin debugger
    "jbyuki/one-small-step-for-vimkind",
  },
  lazy = false,
  config = function()
    local dap = require("dap")
    local dapvt = require("nvim-dap-virtual-text")
    dap.configurations.lua = {
      {
        type = "nlua",
        request = "attach",
        name = "Attach to running Neovim instance",
      },
    }
    local dapui = require("dapui")

    dapvt.setup({})

    dapui.setup({
      icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
      mappings = {
        expand = { "<CR>", "<2-LeftMouse>" },
        open = "o",
        remove = "d",
        edit = "e",
        repl = "r",
        toggle = "t",
      },
      element_mappings = {},
      expand_lines = vim.fn.has("nvim-0.7") == 1,
      force_buffers = true,
      layouts = {
        {
          elements = {
            { id = "scopes", size = 0.25 },
            { id = "breakpoints", size = 0.25 },
            { id = "stacks", size = 0.25 },
            { id = "watches", size = 0.25 },
          },
          size = 40,
          position = "left",
        },
        {
          elements = { "repl", "console" },
          size = 10,
          position = "bottom",
        },
      },
      floating = {
        max_height = nil,
        max_width = nil,
        border = "single",
        mappings = {
          close = { "q", "<Esc>" },
        },
      },
      controls = {
        enabled = vim.fn.exists("+winbar") == 1,
        element = "repl",
        icons = {
          pause = "⏸",
          play = "▶",
          step_into = "⏎",
          step_over = "⏭",
          step_out = "⏮",
          step_back = "b",
          run_last = "▶▶",
          terminate = "⏹",
          disconnect = "⏏",
        },
      },
      render = {
        indent = 1,
        max_type_length = nil,
        max_value_lines = 100,
      },
    })

    dap.adapters.nlua = function(callback, config)
      callback({ type = "server", host = config.host or "127.0.0.1", port = config.port or 8086 })
    end
    vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { noremap = true, desc = "Toggle breakpoint" })
    vim.keymap.set("n", "<leader>dr", dap.continue, { noremap = true, desc = "Run/Continue F1" })
    vim.keymap.set("n", "<leader>dc", dapui.close, { noremap = true, desc = "Close UI" })

    vim.keymap.set("n", "<leader>dl", function()
      require("osv").launch({ port = 8086 })
    end, { noremap = true, desc = "Launch server" })

    vim.keymap.set("n", "<leader>dw", function()
      local widgets = require("dap.ui.widgets")
      widgets.hover()
    end, { desc = "Hover variables" })

    vim.keymap.set("n", "<leader>df", function()
      local widgets = require("dap.ui.widgets")
      widgets.centered_float(widgets.frames)
    end, { desc = "Show frames" })

    vim.keymap.set("n", "<F1>", dap.continue)
    vim.keymap.set("n", "<F2>", dap.step_into)
    vim.keymap.set("n", "<F3>", dap.step_over)
    vim.keymap.set("n", "<F4>", dap.step_out)
    vim.keymap.set("n", "<F5>", dap.step_back)
    vim.keymap.set("n", "<F12>", dap.restart)

    dap.listeners.before.attach.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
      dapui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
      dapui.close()
    end
  end,
}
