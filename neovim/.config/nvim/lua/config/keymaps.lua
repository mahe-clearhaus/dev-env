-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Escape terminal mode with Esc-Esc (built in)

-- === jump windows with alt+1234 ===
local function focus(match)
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local b = vim.api.nvim_win_get_buf(w)
    local o = vim.bo[b]
    -- snacks picker windows are floats (relative="win"), so allow them explicitly
    local ok = vim.api.nvim_win_get_config(w).relative == "" or o.filetype:find("^snacks_picker")
    if ok and match(o, vim.api.nvim_buf_get_name(b)) then
      return vim.api.nvim_set_current_win(w)
    end
  end
end

local function map(key, desc, match)
  vim.keymap.set({ "n", "t" }, key, function()
    focus(match)
  end, { desc = desc })
end

map("<A-1>", "Focus explorer", function(o)
  return o.filetype == "snacks_picker_list"
end)
map("<A-2>", "Focus terminal", function(o, n)
  return o.buftype == "terminal" and not n:find("claude")
end)
map("<A-3>", "Focus buffer", function(o)
  return o.buftype == ""
end)
map("<A-4>", "Focus agent", function(o, n)
  return o.buftype == "terminal" and n:find("claude") ~= nil
end)
