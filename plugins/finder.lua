key = {
  keycode = 3, -- f
  modifiers = { "control" },
  retrigger = false,
  trigger_per_ms = 0,
  down = true,
}

function main()
  os.execute("open -a 'Finder'")
end

--EXAMPLE FOR RETRIGGERS
-- key = {
--   keycode = 0, -- f
--   modifiers = { "control" },
--   retrigger = true,
--   trigger_per_ms = 300,
-- }
--
-- function main()
--   print("hello there")
-- end
