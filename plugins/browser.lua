key = {
  keycode = 36,              -- Enter key
  modifiers = { "control" }, -- Array of modifiers
  down = true,               -- Optional, defaults to true
  retrigger = false,         -- Optional, defaults to false
  trigger_per_ms = 60,       -- Optional, defaults to 60
  description = "Open Browser"
}

function main()
  print("opening browser")
end
