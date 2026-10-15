return {
  {
    "folke/snacks.nvim",
    init = function()
      -- open explorer, terminal, claude on startup; order decides how the splits share space
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        once = true,
        callback = function()
          if #vim.api.nvim_list_uis() == 0 then
            return
          end
          Snacks.explorer()
          Snacks.terminal(nil, { cwd = LazyVim.root() }) -- same opts as <c-/>, so it toggles this one
          require("claudecode") -- lazy-loads the plugin (it only has keys triggers)
          vim.cmd("ClaudeCode")
        end,
      })
    end,
    opts = {
      picker = {
        hidden = true,
        ignored = true,
        sources = {
          explorer = {
            -- show the P preview in the main editor window, not under the explorer
            layout = { preview = { enabled = false, main = true } },
          },
        },
      },
    },
    -- .bak incase this is fucked
  },
}
