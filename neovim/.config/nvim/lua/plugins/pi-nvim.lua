return {
  "carderne/pi-nvim",
  config = true,
  keys = {
    { "<leader>a", nil, desc = "AI/Pi" },
    { "<leader>ap", "<cmd>PiSend<cr>", desc = "Send to Pi" },
    { "<leader>as", "<cmd>PiSendSelection<cr>", mode = "v", desc = "Send selection to Pi" },
  },
}
