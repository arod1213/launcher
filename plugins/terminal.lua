key = {
  keycode = 36, -- enter
  modifiers = { "control" },
  retrigger = false,
  trigger_per_ms = 0,
  down = true,
}

function main()
  os.execute("open -a 'Ghostty'")
end
