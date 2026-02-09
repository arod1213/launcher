## Features

- Listens to global MacOS key events.
- Stops key events from propagating to other applications.
- Custom behaviors are defined using Lua scripts.
- Easy plugin system: drop Lua scripts into `~/Documents/Launcher/plugins/`.

## Installation

1. Clone the repository or download the latest release.
2. Place your Lua scripts in the `~/Documents/Launcher/plugins/` directory.
3. Launch SpecLauncher. It will automatically load all scripts in the plugins folder.

## Writing a Plugin

Each plugin is a Lua file that must define:

1. A `key` table specifying the key command to listen for.
2. A `main` function that will be executed when the key command is triggered.

### Key Table

The `key` table must have the following structure:

```lua
key = {
  keycode = 2,         --  The keycode for the key (e.g., 2 == d)
  modifiers = {        -- Optional list of modifier keys
        "control", 
        "option" 
    }, 
  retrigger = false,   -- Enables multiple triggers per hold
  trigger_per_ms = 0,  -- Speed of retrigger
  down = true,         -- If key press or key release
}
```

### Main Function

The `main` function contains the code that will be executed when the key command is pressed:
```lua
function  main()  
    os.execute("open -a 'Brave Browser'") 
end
```

### Example Plugin

```lua 
key = {
  keycode = 2, -- d        
  modifiers = { "control", "option" }, 
  retrigger = false,
  trigger_per_ms = 0,
  down = true,
}
function  main()  
	os.execute("open -a 'Brave Browser'") 
end
```
