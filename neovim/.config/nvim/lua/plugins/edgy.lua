return {
  "folke/edgy.nvim",
  opts = function(_, opts)
    opts.options = { right = { size = 0.45 } } -- default 30 columns
    -- claudecode re-shows its terminal with a plain vsplit, which the extra's snacks_win filter misses
    table.insert(opts.right, 1, {
      title = "Claude",
      ft = "snacks_terminal",
      filter = function(buf)
        return vim.api.nvim_buf_get_name(buf):find("//%d+:.*claude") ~= nil -- term://{cwd}//{pid}:{cmd}, so match the cmd
      end,
    })
  end,
}
