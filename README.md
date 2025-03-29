# Work in progress dont use!

# LolvylUI

LolvylUI is a rebranded and enhanced version of the old Interface Suite. The goal is to provide a more user-friendly and aesthetically pleasing interface with additional features and improvements.
Our old interface was bad and buggy, sorry for the problems
## Features
- [ ] Improved User Interface
- [ ] Additional Customization Options
- [ ] Enhanced Performance
- [ ] Better Documentation
- [ ] More Examples and Use Cases

## Installation
Instructions on how to install and use LolvylUI.

## Usage
'''# LolvyUI

A modern, customizable UI library for Roblox with support for responsive design and mobile devices.

## Features

- 🎨 Customizable themes
- 📱 Mobile-responsive design
- 🔔 Built-in notification system
- 🎯 Easy-to-use API
- ⌨️ Customizable keybinds
- 🖼️ Background image support

## Installation

1. Copy the `LolvyUI.lua` file to your project
2. Require the module:

```lua
local LolvyUI = require(path.to.LolvyUI)
```

## Quick Start

```lua
-- Create a new UI instance
local ui = LolvyUI.new({
    Title = "My Cool UI",
    KeyBind = Enum.KeyCode.RightControl
})

-- Add a tab
local mainTab = ui:AddTab("Main")

-- Add elements
mainTab:AddButton("Click Me!", function()
    print("Button clicked!")
end)

mainTab:AddToggle("Toggle", false, function(value)
    print("Toggle:", value)
end)
```

## Documentation

### Configuration

```lua
local config = {
    Title = "My UI",
    Theme = {
        Background = Color3.fromRGB(30, 15, 30),
        Button = Color3.fromRGB(45, 25, 45),
        ButtonHover = Color3.fromRGB(55, 35, 55),
        ToggleOn = Color3.fromRGB(165, 25, 50),
        Text = Color3.fromRGB(230, 230, 230),
        TabSelected = Color3.fromRGB(60, 35, 60),
        TabUnselected = Color3.fromRGB(40, 20, 40)
    },
    KeyBind = Enum.KeyCode.C,
    Image = "rbxassetid://0", -- Background image
    MobileButtonImage = "rbxassetid://0" -- Mobile toggle button image
}
```

### Methods

#### UI Creation
- `LolvyUI.new(config)` - Create a new UI instance
- `ui:AddTab(name, icon?)` - Add a new tab
- `ui:ToggleVisibility()` - Toggle UI visibility
- `ui:Destroy()` - Clean up and remove the UI

#### Elements
- `ui:AddButton(tabName, text, callback)`
- `ui:AddToggle(tabName, text, default, callback)`
- `ui:AddNumberInput(tabName, text, default, min, max, callback)`
- `ui:AddTextInput(tabName, text, default, placeholder, callback)`
- `ui:AddLabel(tabName, text)`
- `ui:AddDivider(tabName, text?)`

#### Notifications
- `ui:Notify(title, message, duration?, type?)`
  - Types: "info", "success", "error", "warning"

## Examples

### Basic Setup
```lua
local LolvyUI = require(path.to.LolvyUI)

local ui = LolvyUI.new({
    Title = "Example UI",
    KeyBind = Enum.KeyCode.RightControl
})

-- Main tab
local mainTab = ui:AddTab("Main")

mainTab:AddButton("Hello", function()
    ui:Notify("Hello!", "Button clicked!", 3, "success")
end)

mainTab:AddToggle("Enable Feature", false, function(value)
    print("Feature enabled:", value)
end)

-- Settings tab
local settingsTab = ui:AddTab("Settings")

settingsTab:AddNumberInput("Speed", 50, 0, 100, function(value)
    print("Speed set to:", value)
end)

settingsTab:AddTextInput("Username", "", "Enter username...", function(text)
    print("Username:", text)
end)
```

### Theme Customization
```lua
local ui = LolvyUI.new({
    Title = "Custom Theme",
    Theme = {
        Background = Color3.fromRGB(20, 20, 30),
        Button = Color3.fromRGB(30, 30, 45),
        ButtonHover = Color3.fromRGB(40, 40, 60),
        ToggleOn = Color3.fromRGB(100, 150, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TabSelected = Color3.fromRGB(45, 45, 70),
        TabUnselected = Color3.fromRGB(25, 25, 40)
    }
})
```

## License

MIT License - Feel free to use in your own projects!'''
