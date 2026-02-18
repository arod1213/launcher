key = {
  keycode = 1, -- s
  modifiers = { "control" },
  retrigger = false,
  trigger_per_ms = 0,
  down = true,
}

function main()
  os.execute("open -a 'Tidal'")
end
