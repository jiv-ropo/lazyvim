-- lua/blink-demo/init.lua
--
-- A minimal custom blink.cmp source that demonstrates the core source API:
--
--   • get_completions()  — return CompletionItem[] to blink
--   • resolve()          — enrich an item just before it is shown (docs, etc.)
--   • execute()          — called after an item is accepted
--
-- Each completion item shows a different blink feature:
--   "demofn"   → snippet with a tabstop  (demonstrates snippet insertion)
--   "demovar"  → plain text replacement  (demonstrates textEdit)
--   "demolog"  → labelDetails / detail   (demonstrates label annotations)
--   "demoapi"  → lazy-resolved docs      (demonstrates the resolve() callback)
--   "democmd"  → execute() side-effect   (demonstrates post-accept hooks)

local M = {}

-- ---------------------------------------------------------------------------
-- Static item catalogue
-- ---------------------------------------------------------------------------

---@type lsp.CompletionItem[]
local ITEMS = {
  {
    label = "demofn",
    kind = vim.lsp.protocol.CompletionItemKind.Function,
    -- labelDetails is shown in the blink menu as a right-aligned annotation.
    labelDetails = { detail = " (snippet)" },
    -- insertTextFormat 2 = Snippet; ${1:name} is a tabstop with placeholder.
    insertTextFormat = vim.lsp.protocol.InsertTextFormat.Snippet,
    insertText = "demofn(${1:arg})",
    documentation = {
      kind = "markdown",
      value = table.concat({
        "## `demofn(arg)`",
        "",
        "**Demo** — snippet insertion.",
        "",
        "After accepting, the cursor lands on `arg` so you can type the",
        "argument immediately. Press `<Tab>` to jump out of the snippet.",
        "",
        "```lua",
        "demofn(myArg)",
        "```",
      }, "\n"),
    },
  },

  {
    label = "demovar",
    kind = vim.lsp.protocol.CompletionItemKind.Variable,
    labelDetails = { detail = " string" },
    insertTextFormat = vim.lsp.protocol.InsertTextFormat.PlainText,
    insertText = 'demovar = "hello"',
    documentation = {
      kind = "markdown",
      value = table.concat({
        "## `demovar`",
        "",
        "**Demo** — plain-text replacement.",
        "",
        "Inserts the full assignment expression as-is, with no snippet",
        "tabstops.",
      }, "\n"),
    },
  },

  {
    label = "demolog",
    kind = vim.lsp.protocol.CompletionItemKind.Keyword,
    -- description appears in blink's secondary annotation column (if enabled).
    labelDetails = { description = "prints to :messages" },
    insertTextFormat = vim.lsp.protocol.InsertTextFormat.Snippet,
    insertText = 'vim.notify("${1:message}", vim.log.levels.INFO)',
    documentation = {
      kind = "markdown",
      value = table.concat({
        "## `demolog`",
        "",
        "**Demo** — `labelDetails.description` annotation.",
        "",
        "The right-hand column in the completion menu shows the text from",
        "`labelDetails.description`. Useful for type hints, module paths, etc.",
        "",
        "```lua",
        'vim.notify("hello", vim.log.levels.INFO)',
        "```",
      }, "\n"),
    },
  },

  {
    label = "demoapi",
    kind = vim.lsp.protocol.CompletionItemKind.Module,
    labelDetails = { detail = " (lazy docs)" },
    insertTextFormat = vim.lsp.protocol.InsertTextFormat.PlainText,
    insertText = "demoapi",
    -- No documentation here on purpose — resolve() will add it lazily.
    _lazy_doc = true,
  },

  {
    label = "democmd",
    kind = vim.lsp.protocol.CompletionItemKind.Event,
    labelDetails = { detail = " (side-effect)" },
    insertTextFormat = vim.lsp.protocol.InsertTextFormat.PlainText,
    insertText = "democmd",
    documentation = {
      kind = "markdown",
      value = table.concat({
        "## `democmd`",
        "",
        "**Demo** — `execute()` callback.",
        "",
        "After this item is accepted, the source's `execute()` method fires",
        "and prints a notification via `vim.notify`. Useful for triggering",
        "imports, bracket pairs, or any post-insert side-effect.",
      }, "\n"),
    },
    _has_execute = true,
  },
}

-- ---------------------------------------------------------------------------
-- Source constructor (called once by blink when the source is first needed)
-- ---------------------------------------------------------------------------

function M.new()
  return setmetatable({}, { __index = M })
end

-- ---------------------------------------------------------------------------
-- get_completions  (required)
--
-- blink calls this on every keystroke while the completion menu is open (or
-- when triggered manually). Return a response table synchronously or call
-- callback() asynchronously.
-- ---------------------------------------------------------------------------

---@param ctx blink.cmp.Context
---@param callback fun(response: blink.cmp.CompletionResponse)
function M:get_completions(ctx, callback)
  -- Only provide completions when the text before the cursor starts with "demo".
  local word_before = ctx.line:sub(1, ctx.cursor[2]):match("[%w_]+$") or ""

  -- Check if "demo" starts with the current prefix — i.e. the user is still
  -- typing their way towards "demo" ("d", "de", "dem").  In that case we
  -- return no items but mark the response as incomplete so blink will call
  -- get_completions again on the next keystroke instead of caching the empty
  -- result.
  local is_partial_prefix = #word_before < 4 and vim.startswith("demo", word_before) and word_before ~= ""

  if not vim.startswith(word_before, "demo") then
    callback({
      is_incomplete_forward = is_partial_prefix,
      is_incomplete_backward = is_partial_prefix,
      items = {},
    })
    return
  end

  callback({
    is_incomplete_forward = false,
    is_incomplete_backward = false,
    items = ITEMS,
  })
end

-- ---------------------------------------------------------------------------
-- resolve  (optional)
--
-- blink calls this just before displaying the documentation for an item,
-- giving us a chance to fill in expensive/lazy data (e.g. fetched from a
-- server). Here we add documentation to `demoapi` lazily.
-- ---------------------------------------------------------------------------

---@param item lsp.CompletionItem
---@param callback fun(item: lsp.CompletionItem)
function M:resolve(item, callback)
  if item._lazy_doc then
    -- Simulate async work (e.g. an HTTP call or LSP request).
    vim.defer_fn(function()
      local resolved = vim.deepcopy(item)
      resolved.documentation = {
        kind = "markdown",
        value = table.concat({
          "## `demoapi`",
          "",
          "**Demo** — lazy `resolve()` documentation.",
          "",
          "This documentation was **not** present in the initial completion list.",
          "blink called `resolve()` only when you moved the cursor onto this item,",
          "so expensive lookups don't slow down the initial menu render.",
        }, "\n"),
      }
      callback(resolved)
    end, 50) -- 50 ms artificial delay to make the async nature visible
  else
    callback(item)
  end
end

-- ---------------------------------------------------------------------------
-- execute  (optional)
--
-- blink calls this after a completion item has been inserted into the buffer.
-- Use it for post-insert side-effects: auto-imports, bracket insertion, etc.
-- ---------------------------------------------------------------------------

---@param ctx blink.cmp.Context
---@param item lsp.CompletionItem
---@param resolve fun()  must be called to signal blink that execute is done
---@param default_implementation fun()
function M:execute(ctx, item, resolve, default_implementation)
  default_implementation()
  if item._has_execute then
    vim.notify(
      "[blink-demo] execute() fired for '" .. item.label .. "' — hook your import/side-effect here.",
      vim.log.levels.INFO,
      { title = "blink-demo" }
    )
  end
  resolve()
end

-- ---------------------------------------------------------------------------
-- enabled  (optional)
--
-- Return false to disable the source for specific buffers/filetypes.
-- Here we skip it in Telescope prompts and Oil buffers as an example.
-- ---------------------------------------------------------------------------

function M:enabled()
  local ft = vim.bo.filetype
  return ft ~= "TelescopePrompt" and ft ~= "oil"
end

return M
