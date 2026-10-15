-- mbh 2026-10-07
-- nvim-ts-autotag closes HTML/XML tags, so typing the nvim key
-- `<leader>` in my markdown notes became `<leader></leader>`.
-- Disable closing for markdown only and keep it on for html/xml,
-- since closing those tags is actually a pain in the ass.
--
return {
  {
    "windwp/nvim-ts-autotag",
    opts = {
      per_filetype = {
        markdown = { enable_close = false },
      },
    },
  },
}
