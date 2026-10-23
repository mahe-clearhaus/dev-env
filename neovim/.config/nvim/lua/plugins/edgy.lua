return {
  "folke/edgy.nvim",
  opts = function(_, opts)
    opts.options = { right = { size = 0.45 } } -- default 30 columns
    table.insert(opts.right, 1, {
      title = "Pi",
      ft = "snacks_terminal",
      filter = function(buf)
        return vim.api.nvim_buf_get_name(buf):find("//%d+:pi") ~= nil -- term://{cwd}//{pid}:{cmd}, so match the cmd
      end,
    })
  end,
}
