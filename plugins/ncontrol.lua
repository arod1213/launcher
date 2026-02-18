key = {
  keycode = 45, -- n
  modifiers = { "control" },
  retrigger = false,
  trigger_per_ms = 0,
  down = true,
}

function main()
  os.execute("open -a 'NControl'")
end
