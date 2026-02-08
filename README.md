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
  keycode = 11,       -- The keycode for the key (e.g., 11 = Enter)
  modifiers = {       -- Optional list of modifier keys
    "control",
    "option",
    "command",
    "fn"
  },
}
```

### Main Function

The `main` function contains the code that will be executed when the key command is pressed:
```lua
function  main()  os.execute("open -a 'Brave Browser'") end` 
```

### Example Plugin

```lua 
key = {
  keycode = 11, -- Enter key 
  modifiers = { "control" },
} 
function  main()  
	os.execute("open -a 'Brave Browser'") 
end
```
