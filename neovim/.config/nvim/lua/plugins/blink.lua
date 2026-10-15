-- mbh 2026-10-07
-- <C-f> to accept blink autosuggestion.
--
-- Justification:
-- 1. If you want to line break and press enter, it autocompletes unless you
--    hit e.g. <esc> first. Thats annoying.
-- 2. The vim default key for accepting a suggesting is <C-y> which is not convenient.
-- 3. <C-f> is also how it is done in fish, so I can have 1 key. It is also
--    nicer than right arrow, which is what I use in fish now.
return {
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        preset = "default",
        ["<C-f>"] = { "select_and_accept", "fallback" },
      },
    },
  },
}
