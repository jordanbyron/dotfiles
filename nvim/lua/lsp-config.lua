-- LSP Configuration for ruby-lsp
local lspconfig = require('lspconfig')

-- Function to set up keybindings when LSP attaches
local on_attach = function(client, bufnr)
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  
  -- LSP keybindings that won't conflict with existing mappings
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
  
  -- Manual formatting keybinding
  vim.keymap.set('n', '<leader>f', vim.lsp.buf.format, bufopts)
  
  -- Optional: format on save (can coexist with rubocop)
  -- Uncomment the next section if you want automatic formatting on save
  --[[
  if client.supports_method("textDocument/formatting") then
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format()
      end,
    })
  end
  --]]
end

-- Configure ruby-lsp (Mason now uses global Ruby 3.4.4)
lspconfig.ruby_lsp.setup({
  on_attach = on_attach,
  capabilities = vim.lsp.protocol.make_client_capabilities(),
  root_dir = lspconfig.util.root_pattern("Gemfile", ".git", ".ruby-version", ".tool-versions"),
  init_options = {
    formatter = "rubocop", -- Use rubocop for formatting (matches your Neomake setup)
    linters = {}, -- Use empty to avoid conflicts with Neomake
  },
  settings = {
    ruby_lsp = {
      -- Enable features you want
      enabledFeatures = {
        "semanticHighlighting",
        "diagnostics", 
        "codeActions",
        "hover",
        "documentSymbols",
        "completion",
        "definition",        -- Enable go to definition (gd)
        "references",        -- Enable find references (gr)
        "rename",           -- Enable rename (leader+rn)
        "formatting",       -- Enable formatting
        "selectionRanges",  -- Enable selection ranges
      },
    },
  },
})

-- Configure diagnostic display to work nicely with your setup
vim.diagnostic.config({
  virtual_text = false, -- Don't show inline diagnostics (Neomake handles this)
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

-- Define diagnostic signs
local signs = { Error = "󰅚 ", Warn = "󰀪 ", Hint = "󰌶 ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Optional: Show diagnostics in floating window on cursor hold
vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    local opts = {
      focusable = false,
      close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
      border = 'rounded',
      source = 'always',
      prefix = ' ',
      scope = 'cursor',
    }
    vim.diagnostic.open_float(nil, opts)
  end
})

-- Configure TypeScript LSP for React development
require("typescript-tools").setup({
  on_attach = function(client, bufnr)
    -- Call the common on_attach function
    on_attach(client, bufnr)
    
    -- Disable TypeScript's built-in formatting in favor of Prettier
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end,
  capabilities = vim.lsp.protocol.make_client_capabilities(),
  settings = {
    -- TypeScript server settings
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints = 'all',
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
    javascript = {
      inlayHints = {
        includeInlayParameterNameHints = 'all',
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
    -- React/JSX support
    jsx_close_tag = {
      enable = true,
      filetypes = { "javascriptreact", "typescriptreact" },
    },
  },
})

-- Set up Prettier formatting for TypeScript/JavaScript files
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "typescript", "typescriptreact", "javascript", "javascriptreact", "json", "css", "scss", "html" },
  callback = function()
    vim.keymap.set('n', '<leader>f', function()
      vim.cmd("!prettier --write " .. vim.fn.expand("%"))
      vim.cmd("edit") -- Reload the file to see changes
    end, { buffer = true, desc = "Format with Prettier" })
  end,
})

-- Optional: Auto-format TypeScript/JavaScript files on save with Prettier
-- Uncomment the next block if you want automatic formatting on save
--[[
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.ts", "*.tsx", "*.js", "*.jsx", "*.json", "*.css", "*.scss", "*.html" },
  callback = function()
    vim.cmd("silent !prettier --write " .. vim.fn.expand("%"))
    vim.cmd("edit") -- Reload the file to see changes
  end,
})
--]]