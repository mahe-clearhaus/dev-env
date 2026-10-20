-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Escape terminal mode with Esc-Esc (built in)

-- === jump windows with cmd+1234 ===
-- closed -> open, open -> focus, focused -> close and focus the next of 4,3,1,2 (except the main window, which stays)
local function find(match)
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local b = vim.api.nvim_win_get_buf(w)
    local o = vim.bo[b]
    -- snacks picker windows are floats (relative="win"), so allow them explicitly
    local ok = vim.api.nvim_win_get_config(w).relative == "" or o.filetype:find("^snacks_picker")
    if ok and match(o, vim.api.nvim_buf_get_name(b)) then
      return w
    end
  end
end

local is_claude = function(o, n)
  return o.buftype == "terminal" and n:find("claude") ~= nil
end

-- the main window: files, dashboard, help etc. Not terminals or picker/layout windows
local is_buffer = function(o)
  return o.buftype ~= "terminal" and (o.filetype == "snacks_dashboard" or not o.filetype:find("^snacks_"))
end

local panes = {
  {
    key = "<D-1>",
    desc = "Explorer",
    match = function(o)
      return o.filetype == "snacks_picker_list"
    end,
    open = function()
      Snacks.explorer()
    end,
    close = function()
      Snacks.picker.get({ source = "explorer" })[1]:close()
    end,
  },
  {
    key = "<D-3>",
    desc = "Terminal",
    match = function(o, n)
      return o.buftype == "terminal" and not n:find("claude")
    end,
    open = function()
      Snacks.terminal(nil, { cwd = LazyVim.root() }) -- same opts as <c-/>, so it toggles this one
    end,
  },
  {
    key = "<D-4>",
    desc = "Buffer",
    keep = true,
    match = is_buffer,
    open = function()
      local w = find(function(o)
        return o.filetype ~= "snacks_picker_list"
      end)
      if w then
        vim.api.nvim_set_current_win(w)
      end
      vim.cmd("rightbelow vnew")
      local bufs = vim.tbl_filter(function(b)
        return vim.bo[b.bufnr].buftype == ""
      end, vim.fn.getbufinfo({ buflisted = 1 }))
      table.sort(bufs, function(x, y)
        return x.lastused > y.lastused
      end)
      if bufs[1] then
        vim.api.nvim_set_current_buf(bufs[1].bufnr)
      end
    end,
  },
  {
    key = "<D-2>",
    desc = "Claude",
    match = is_claude,
    open = function()
      require("claudecode") -- lazy-loads the plugin (it only has keys triggers)
      vim.cmd("ClaudeCode")
    end,
  },
}

for _, p in ipairs(panes) do
  vim.keymap.set({ "n", "t" }, p.key, function()
    local w = find(p.match)
    if not w then
      return p.open()
    end
    if w ~= vim.api.nvim_get_current_win() or p.keep then
      return vim.api.nvim_set_current_win(w)
    end
    if p.close then
      p.close()
    else
      pcall(vim.api.nvim_win_close, w, false) -- fails on the last window, which is fine
    end
    for _, i in ipairs({ 3, 2, 1, 4 }) do
      local next = find(panes[i].match)
      if next then
        return vim.api.nvim_set_current_win(next)
      end
    end
  end, { desc = "Toggle/focus " .. p.desc })
end
