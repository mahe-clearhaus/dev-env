return {
  {
    "folke/snacks.nvim",
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
