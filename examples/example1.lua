-- Example usage of LolvyUI

local LolvyUI = require(path.to.LolvyUI)

-- Create a new UI instance with custom theme
local ui = LolvyUI.new({
    Title = "Example UI",
    Theme = {
        Background = Color3.fromRGB(20, 20, 30),
        Button = Color3.fromRGB(30, 30, 45),
        ButtonHover = Color3.fromRGB(40, 40, 60),
        ToggleOn = Color3.fromRGB(100, 150, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TabSelected = Color3.fromRGB(45, 45, 70),
        TabUnselected = Color3.fromRGB(25, 25, 40)
    },
    KeyBind = Enum.KeyCode.RightControl
})

-- Create main tab
local mainTab = ui:AddTab("Main")

-- Add elements to main tab
mainTab:AddLabel("Welcome to the example!")

mainTab:AddButton("Click Me!", function()
    ui:Notify("Button Clicked", "You clicked the button!", 3, "success")
end)

mainTab:AddToggle("Enable Feature", false, function(value)
    print("Feature enabled:", value)
end)

mainTab:AddDivider("Settings")

mainTab:AddNumberInput("Speed", 50, 0, 100, function(value)
    print("Speed set to:", value)
end)

mainTab:AddTextInput("Username", "", "Enter username...", function(text)
    print("Username:", text)
end)

-- Create settings tab
local settingsTab = ui:AddTab("Settings")

settingsTab:AddLabel("UI Settings")

local themeToggle = settingsTab:AddToggle("Dark Theme", true, function(value)
    print("Theme changed:", value and "Dark" or "Light")
end)

settingsTab:AddButton("Reset Settings", function()
    themeToggle:SetValue(true)
    ui:Notify("Settings Reset", "All settings have been reset to default.", 3, "info")
end)

-- Create about tab
local aboutTab = ui:AddTab("About")

aboutTab:AddLabel("LolvyUI Example")
aboutTab:AddLabel("Version 1.0.0")
aboutTab:AddLabel("Created by Lolvy")

aboutTab:AddDivider()

aboutTab:AddButton("Check for Updates", function()
    ui:Notify("Update Check", "You are running the latest version!", 3, "success")
end)
