key = {
  keycode = 2, -- d
  modifiers = { "control", "option" },
  retrigger = false,
  trigger_per_ms = 0,
  down = true,
}

function main()
  os.execute("open -a 'Ableton Live 12 Suite'")
end
