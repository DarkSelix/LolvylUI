--[[
    LolvyUI - Modern UI Library for Roblox
    Author: Lolvy
    License: MIT
    Version: 1.0.0
]]

local LolvyUI = {}
LolvyUI.__index = LolvyUI

-- Default configurations
local DEFAULT_CONFIG = {
    Title = "LolvyUI",
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
    Image = "rbxassetid://0",
    MobileButtonImage = "rbxassetid://0"
}

-- Utility functions
local function deepCopy(original)
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then
            copy[k] = deepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

local function validateConfig(config)
    if not config then return deepCopy(DEFAULT_CONFIG) end
    
    local validatedConfig = deepCopy(DEFAULT_CONFIG)
    
    -- Validate and merge theme
    if config.Theme then
        for key, defaultValue in pairs(DEFAULT_CONFIG.Theme) do
            if config.Theme[key] and typeof(config.Theme[key]) == "Color3" then
                validatedConfig.Theme[key] = config.Theme[key]
            end
        end
    end
    
    -- Validate other fields
    if config.Title and type(config.Title) == "string" then
        validatedConfig.Title = config.Title
    end
    
    if config.KeyBind and typeof(config.KeyBind) == "EnumItem" and config.KeyBind.EnumType == Enum.KeyCode then
        validatedConfig.KeyBind = config.KeyBind
    end
    
    if config.Image and type(config.Image) == "string" then
        validatedConfig.Image = config.Image
    end
    
    if config.MobileButtonImage and type(config.MobileButtonImage) == "string" then
        validatedConfig.MobileButtonImage = config.MobileButtonImage
    end
    
    return validatedConfig
end

-- Create a new instance of the hub
function LolvyUI.new(config)
    local self = setmetatable({}, LolvyUI)
    
    -- Validate and set configuration
    self.config = validateConfig(config)
    
    -- Initialize state
    self.tabs = {}
    self.currentTab = nil
    self.visible = false
    self.notifications = {}
    self.destroyed = false
    
    -- Initialize GUI
    self:Initialize()
    
    -- Setup cleanup
    game:GetService("Players").LocalPlayer.CharacterRemoving:Connect(function()
        if not self.destroyed then
            self:Destroy()
        end
    end)
    
    return self
end

-- Initialize the interface
function LolvyUI:Initialize()
    if self.destroyed then return end
    
    local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LolvyUIGui"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = playerGui
    
    self.gui = screenGui
    
    -- Create main UI
    self:CreateMainUI()
    
    -- Setup systems
    self:SetupResizing()
    self:SetupKeybind()
    self:SetupMobileSupport()
    
    -- Initially hide
    self.mainFrame.Visible = false
end

-- Create the main UI
function LolvyUI:CreateMainUI()
    if self.destroyed then return end
    
    -- Create title label
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(0, 300, 0, 30)
    titleLabel.Position = UDim2.new(0.5, -150, 0, -30)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = self.config.Title
    titleLabel.TextColor3 = self.config.Theme.Text
    titleLabel.TextSize = 24
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = self.gui
    self.titleLabel = titleLabel
    
    -- Create main frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0.9, 0, 0.6, 0)
    mainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
    mainFrame.BackgroundColor3 = self.config.Theme.Background
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = self.gui
    
    -- Add corner and shadow
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5028857084"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.6
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(24, 24, 276, 276)
    shadow.ZIndex = -1
    shadow.Parent = mainFrame
    
    -- Add background image if specified
    if self.config.Image ~= "rbxassetid://0" then
        local bgImage = Instance.new("ImageLabel")
        bgImage.Name = "BackgroundImage"
        bgImage.Size = UDim2.new(1, 0, 1, 0)
        bgImage.BackgroundTransparency = 1
        bgImage.Image = self.config.Image
        bgImage.ImageTransparency = 0.85
        bgImage.ScaleType = Enum.ScaleType.Crop
        bgImage.Parent = mainFrame
    end
    
    -- Create tabs container
    local tabsContainer = Instance.new("Frame")
    tabsContainer.Name = "TabsContainer"
    tabsContainer.Size = UDim2.new(0.2, 0, 1, 0)
    tabsContainer.BackgroundColor3 = Color3.fromRGB(20, 10, 20)
    tabsContainer.BorderSizePixel = 0
    tabsContainer.Parent = mainFrame
    
    local tabsCorner = Instance.new("UICorner")
    tabsCorner.CornerRadius = UDim.new(0, 8)
    tabsCorner.Parent = tabsContainer
    
    -- Create tabs list
    local tabsList = Instance.new("ScrollingFrame")
    tabsList.Name = "TabsList"
    tabsList.Size = UDim2.new(1, 0, 1, -10)
    tabsList.Position = UDim2.new(0, 0, 0, 5)
    tabsList.BackgroundTransparency = 1
    tabsList.ScrollBarThickness = 4
    tabsList.ScrollBarImageColor3 = self.config.Theme.ToggleOn
    tabsList.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabsList.Parent = tabsContainer
    
    local tabsListLayout = Instance.new("UIListLayout")
    tabsListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabsListLayout.Padding = UDim.new(0, 5)
    tabsListLayout.Parent = tabsList
    
    -- Create content container
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Size = UDim2.new(0.8, 0, 1, 0)
    contentContainer.Position = UDim2.new(0.2, 0, 0, 0)
    contentContainer.BackgroundTransparency = 1
    contentContainer.BorderSizePixel = 0
    contentContainer.Parent = mainFrame
    
    -- Store references
    self.mainFrame = mainFrame
    self.tabsContainer = tabsContainer
    self.tabsList = tabsList
    self.contentContainer = contentContainer
end

-- Setup responsive resizing
function LolvyUI:SetupResizing()
    if self.destroyed then return end
    
    local function updateSize()
        local viewportSize = workspace.CurrentCamera.ViewportSize
        local widthRatio = math.clamp(viewportSize.X / 1920, 0.6, 1)
        local heightRatio = math.clamp(viewportSize.Y / 1080, 0.6, 1)
        
        self.mainFrame.Size = UDim2.new(0.9 * widthRatio, 0, 0.6 * heightRatio, 0)
        self.mainFrame.Position = UDim2.new(0.05 + (0.05 * (1 - widthRatio)), 0, 0.2 + (0.05 * (1 - heightRatio)), 0)
        
        -- Update tabs list canvas size
        if #self.tabs > 0 then
            self.tabsList.CanvasSize = UDim2.new(0, 0, 0, (#self.tabs * 40) + (5 * (#self.tabs - 1)))
        end
    end
    
    -- Connect to RenderStepped with throttling
    local lastUpdate = 0
    game:GetService("RunService").RenderStepped:Connect(function()
        if self.destroyed then return end
        local now = tick()
        if now - lastUpdate >= 0.1 then -- Update every 0.1 seconds
            lastUpdate = now
            updateSize()
        end
    end)
end

-- Setup keybind
function LolvyUI:SetupKeybind()
    if self.destroyed then return end
    
    game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
        if self.destroyed or gameProcessed then return end
        
        if input.KeyCode == self.config.KeyBind then
            self:ToggleVisibility()
        end
    end)
end

-- Setup mobile support
function LolvyUI:SetupMobileSupport()
    if self.destroyed then return end
    
    local UserInputService = game:GetService("UserInputService")
    
    if UserInputService.TouchEnabled then
        -- Create mobile button
        local mobileButton = Instance.new("ImageButton")
        mobileButton.Name = "MobileButton"
        mobileButton.Size = UDim2.new(0, 40, 0, 40)
        mobileButton.Position = UDim2.new(0.1, 0, 0.8, 0)
        mobileButton.BackgroundColor3 = self.config.Theme.Button
        mobileButton.Image = self.config.MobileButtonImage ~= "rbxassetid://0" 
            and self.config.MobileButtonImage 
            or "rbxassetid://3926307971"
        mobileButton.ImageRectOffset = Vector2.new(764, 764)
        mobileButton.ImageRectSize = Vector2.new(36, 36)
        mobileButton.ImageColor3 = self.config.Theme.Text
        mobileButton.Parent = self.gui
        
        -- Add corner radius
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 20)
        buttonCorner.Parent = mobileButton
        
        -- Make draggable
        local dragging = false
        local dragInput
        local dragStart
        local startPos
        
        local function updateDrag(input)
            if dragging and dragInput and dragStart then
                local delta = input.Position - dragStart
                local newPosition = UDim2.new(
                    startPos.X.Scale,
                    math.clamp(startPos.X.Offset + delta.X, 0, workspace.CurrentCamera.ViewportSize.X - 40),
                    startPos.Y.Scale,
                    math.clamp(startPos.Y.Offset + delta.Y, 0, workspace.CurrentCamera.ViewportSize.Y - 40)
                )
                mobileButton.Position = newPosition
            end
        end
        
        mobileButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = mobileButton.Position
                
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        
        mobileButton.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
                dragInput = input
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                updateDrag(input)
            end
        end)
        
        -- Toggle visibility on click
        mobileButton.Activated:Connect(function()
            self:ToggleVisibility()
        end)
        
        self.mobileButton = mobileButton
    end
end

-- Toggle UI visibility
function LolvyUI:ToggleVisibility()
    if self.destroyed then return end
    
    self.visible = not self.visible
    self.mainFrame.Visible = self.visible
    self.titleLabel.Visible = self.visible
end

-- Add a new tab
function LolvyUI:AddTab(tabName, icon)
    if self.destroyed then return end
    
    -- Check for existing tab
    for _, tab in ipairs(self.tabs) do
        if tab.name == tabName then
            return tab
        end
    end
    
    -- Create tab button
    local tabButton = Instance.new("TextButton")
    tabButton.Name = tabName .. "Tab"
    tabButton.Size = UDim2.new(1, -10, 0, 40)
    tabButton.Position = UDim2.new(0, 5, 0, (#self.tabs * 45))
    tabButton.BackgroundColor3 = self.config.Theme.TabUnselected
    tabButton.Text = tabName
    tabButton.TextColor3 = self.config.Theme.Text
    tabButton.Font = Enum.Font.GothamSemibold
    tabButton.TextSize = 14
    tabButton.BorderSizePixel = 0
    tabButton.Parent = self.tabsList
    
    -- Add icon if provided
    if icon then
        local iconImage = Instance.new("ImageLabel")
        iconImage.Size = UDim2.new(0, 16, 0, 16)
        iconImage.Position = UDim2.new(0, 10, 0.5, -8)
        iconImage.BackgroundTransparency = 1
        iconImage.Image = icon
        iconImage.Parent = tabButton
        tabButton.TextXAlignment = Enum.TextXAlignment.Right
    end
    
    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = tabButton
    
    -- Create content frame
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Name = tabName .. "Content"
    contentFrame.Size = UDim2.new(1, -20, 1, -20)
    contentFrame.Position = UDim2.new(0, 10, 0, 10)
    contentFrame.BackgroundTransparency = 1
    contentFrame.ScrollBarThickness = 4
    contentFrame.ScrollBarImageColor3 = self.config.Theme.ToggleOn
    contentFrame.BorderSizePixel = 0
    contentFrame.Visible = false
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentFrame.Parent = self.contentContainer
    
    -- Add layout
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 10)
    contentLayout.Parent = contentFrame
    
    -- Auto-update canvas size
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if not self.destroyed then
            contentFrame.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
        end
    end)
    
    -- Create tab object
    local tab = {
        name = tabName,
        button = tabButton,
        contentFrame = contentFrame,
        elements = {},
        elementCount = 0
    }
    
    -- Add to tabs list
    table.insert(self.tabs, tab)
    
    -- Setup click handler
    tabButton.Activated:Connect(function()
        if not self.destroyed then
            self:SelectTab(tabName)
        end
    end)
    
    -- Select if first tab
    if #self.tabs == 1 then
        self:SelectTab(tabName)
    end
    
    return tab
end

-- Select a tab
function LolvyUI:SelectTab(tabName)
    if self.destroyed then return end
    
    -- Update all tabs
    for _, tab in ipairs(self.tabs) do
        tab.contentFrame.Visible = (tab.name == tabName)
        tab.button.BackgroundColor3 = (tab.name == tabName) 
            and self.config.Theme.TabSelected 
            or self.config.Theme.TabUnselected
        
        if tab.name == tabName then
            self.currentTab = tab
        end
    end
end

-- Add a divider
function LolvyUI:AddDivider(tabName, text)
    if self.destroyed then return end
    
    local tab = self:GetTab(tabName)
    if not tab then return nil end
    
    local divider = Instance.new("Frame")
    divider.Name = "Divider" .. tab.elementCount
    divider.Size = UDim2.new(1, 0, 0, 20)
    divider.BackgroundTransparency = 1
    divider.LayoutOrder = tab.elementCount
    divider.Parent = tab.contentFrame
    
    local line1 = Instance.new("Frame")
    line1.Name = "Line1"
    line1.Size = UDim2.new(0.3, 0, 0, 1)
    line1.Position = UDim2.new(0, 0, 0.5, 0)
    line1.BackgroundColor3 = self.config.Theme.Text
    line1.BackgroundTransparency = 0.7
    line1.BorderSizePixel = 0
    line1.Parent = divider
    
    local line2 = Instance.new("Frame")
    line2.Name = "Line2"
    line2.Size = UDim2.new(0.3, 0, 0, 1)
    line2.Position = UDim2.new(0.7, 0, 0.5, 0)
    line2.BackgroundColor3 = self.config.Theme.Text
    line2.BackgroundTransparency = 0.7
    line2.BorderSizePixel = 0
    line2.Parent = divider
    
    if text then
        local textLabel = Instance.new("TextLabel")
        textLabel.Name = "Text"
        textLabel.Size = UDim2.new(0.4, -10, 1, 0)
        textLabel.Position = UDim2.new(0.3, 5, 0, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = text
        textLabel.TextColor3 = self.config.Theme.Text
        textLabel.TextTransparency = 0.3
        textLabel.Font = Enum.Font.GothamMedium
        textLabel.TextSize = 12
        textLabel.Parent = divider
    end
    
    tab.elementCount = tab.elementCount + 1
    return divider
end

-- Add a button
function LolvyUI:AddButton(tabName, buttonText, callback)
    if self.destroyed then return end
    
    local tab = self:GetTab(tabName)
    if not tab then return nil end
    
    local button = Instance.new("TextButton")
    button.Name = "Button" .. tab.elementCount
    button.Size = UDim2.new(1, 0, 0, 35)
    button.BackgroundColor3 = self.config.Theme.Button
    button.Text = buttonText
    button.TextColor3 = self.config.Theme.Text
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 14
    button.BorderSizePixel = 0
    button.LayoutOrder = tab.elementCount
    button.Parent = tab.contentFrame
    
    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = button
    
    -- Hover effect
    button.MouseEnter:Connect(function()
        if not self.destroyed then
            button.BackgroundColor3 = self.config.Theme.ButtonHover
        end
    end)
    
    button.MouseLeave:Connect(function()
        if not self.destroyed then
            button.BackgroundColor3 = self.config.Theme.Button
        end
    end)
    
    -- Click handler
    button.Activated:Connect(function()
        if not self.destroyed and typeof(callback) == "function" then
            callback()
        end
    end)
    
    tab.elementCount = tab.elementCount + 1
    return button
end

-- Add a toggle
function LolvyUI:AddToggle(tabName, toggleText, default, callback)
    if self.destroyed then return end
    
    local tab = self:GetTab(tabName)
    if not tab then return nil end
    
    local toggled = default or false
    
    -- Create container
    local container = Instance.new("Frame")
    container.Name = "Toggle" .. tab.elementCount
    container.Size = UDim2.new(1, 0, 0, 35)
    container.BackgroundTransparency = 1
    container.LayoutOrder = tab.elementCount
    container.Parent = tab.contentFrame
    
    -- Add label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(0.7, -10, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = toggleText
    label.TextColor3 = self.config.Theme.Text
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    -- Add toggle button
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = UDim2.new(0.3, 0, 1, 0)
    toggleButton.Position = UDim2.new(0.7, 0, 0, 0)
    toggleButton.BackgroundColor3 = toggled and self.config.Theme.ToggleOn or self.config.Theme.Button
    toggleButton.Text = toggled and "ON" or "OFF"
    toggleButton.TextColor3 = self.config.Theme.Text
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.TextSize = 14
    toggleButton.BorderSizePixel = 0
    toggleButton.Parent = container
    
    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = toggleButton
    
    -- Toggle function
    local function updateToggle()
        if self.destroyed then return end
        
        toggled = not toggled
        toggleButton.BackgroundColor3 = toggled and self.config.Theme.ToggleOn or self.config.Theme.Button
        toggleButton.Text = toggled and "ON" or "OFF"
        
        if typeof(callback) == "function" then
            callback(toggled)
        end
    end
    
    -- Click handler
    toggleButton.Activated:Connect(updateToggle)
    
    -- Toggle API
    local toggleAPI = {
        SetValue = function(value)
            if self.destroyed then return end
            if toggled ~= value then
                toggled = not value -- Invert for updateToggle
                updateToggle()
            end
        end,
        GetValue = function()
            return toggled
        end
    }
    
    tab.elementCount = tab.elementCount + 1
    return toggleAPI
end

-- Add a number input
function LolvyUI:AddNumberInput(tabName, labelText, default, min, max, callback)
    if self.destroyed then return end
    
    local tab = self:GetTab(tabName)
    if not tab then return nil end
    
    -- Default values
    default = default or 0
    min = min or -math.huge
    max = max or math.huge
    
    -- Create container
    local container = Instance.new("Frame")
    container.Name = "NumberInput" .. tab.elementCount
    container.Size = UDim2.new(1, 0, 0, 35)
    container.BackgroundTransparency = 1
    container.LayoutOrder = tab.elementCount
    container.Parent = tab.contentFrame
    
    -- Add label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(0.5, -10, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = self.config.Theme.Text
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    -- Add input box
    local inputBox = Instance.new("TextBox")
    inputBox.Name = "InputBox"
    inputBox.Size = UDim2.new(0.5, 0, 1, 0)
    inputBox.Position = UDim2.new(0.5, 0, 0, 0)
    inputBox.BackgroundColor3 = self.config.Theme.Button
    inputBox.Text = tostring(default)
    inputBox.TextColor3 = self.config.Theme.Text
    inputBox.Font = Enum.Font.GothamSemibold
    inputBox.TextSize = 14
    inputBox.BorderSizePixel = 0
    inputBox.Parent = container
    
    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = inputBox
    
    -- Input validation
    inputBox.FocusLost:Connect(function(enterPressed)
        if self.destroyed then return end
        
        local inputValue = tonumber(inputBox.Text)
        
        if not inputValue then
            inputBox.Text = tostring(default)
            return
        end
        
        -- Clamp to range
        inputValue = math.clamp(inputValue, min, max)
        inputBox.Text = tostring(inputValue)
        
        if typeof(callback) == "function" then
            callback(inputValue)
        end
    end)
    
    -- Number input API
    local numberInputAPI = {
        SetValue = function(value)
            if self.destroyed then return end
            
            if not tonumber(value) then return end
            value = math.clamp(tonumber(value), min, max)
            inputBox.Text = tostring(value)
            
            if typeof(callback) == "function" then
                callback(value)
            end
        end,
        GetValue = function()
            return tonumber(inputBox.Text) or default
        end
    }
    
    tab.elementCount = tab.elementCount + 1
    return numberInputAPI
end

-- Add a text input
function LolvyUI:AddTextInput(tabName, labelText, default, placeholder, callback)
    if self.destroyed then return end
    
    local tab = self:GetTab(tabName)
    if not tab then return nil end
    
    -- Default values
    default = default or ""
    placeholder = placeholder or "Type here..."
    
    -- Create container
    local container = Instance.new("Frame")
    container.Name = "TextInput" .. tab.elementCount
    container.Size = UDim2.new(1, 0, 0, 35)
    container.BackgroundTransparency = 1
    container.LayoutOrder = tab.elementCount
    container.Parent = tab.contentFrame
    
    -- Add label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(0.4, -10, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = self.config.Theme.Text
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    -- Add input box
    local inputBox = Instance.new("TextBox")
    inputBox.Name = "InputBox"
    inputBox.Size = UDim2.new(0.6, 0, 1, 0)
    inputBox.Position = UDim2.new(0.4, 0, 0, 0)
    inputBox.BackgroundColor3 = self.config.Theme.Button
    inputBox.Text = default
    inputBox.PlaceholderText = placeholder
    inputBox.TextColor3 = self.config.Theme.Text
    inputBox.Font = Enum.Font.GothamSemibold
    inputBox.TextSize = 14
    inputBox.BorderSizePixel = 0
    inputBox.ClearTextOnFocus = false
    inputBox.Parent = container
    
    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = inputBox
    
    -- Input handler
    inputBox.FocusLost:Connect(function(enterPressed)
        if not self.destroyed and typeof(callback) == "function" then
            callback(inputBox.Text)
        end
    end)
    
    -- Text input API
    local textInputAPI = {
        SetValue = function(value)
            if self.destroyed then return end
            
            inputBox.Text = tostring(value)
            
            if typeof(callback) == "function" then
                callback(inputBox.Text)
            end
        end,
        GetValue = function()
            return inputBox.Text
        end
    }
    
    tab.elementCount = tab.elementCount + 1
    return textInputAPI
end

-- Add a label
function LolvyUI:AddLabel(tabName, labelText)
    if self.destroyed then return end
    
    local tab = self:GetTab(tabName)
    if not tab then return nil end
    
    local label = Instance.new("TextLabel")
    label.Name = "Label" .. tab.elementCount
    label.Size = UDim2.new(1, 0, 0, 30)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = self.config.Theme.Text
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.LayoutOrder = tab.elementCount
    label.Parent = tab.contentFrame
    
    -- Label API
    local labelAPI = {
        SetText = function(text)
            if not self.destroyed then
                label.Text = text
            end
        end,
        GetText = function()
            return label.Text
        end
    }
    
    tab.elementCount = tab.elementCount + 1
    return labelAPI
end

-- Show notification
function LolvyUI:Notify(title, message, duration, notifType)
    if self.destroyed then return end
    
    -- Default values
    title = title or "Notification"
    message = message or ""
    duration = duration or 5
    notifType = notifType or "info"
    
    -- Get notification color
    local notifColor
    if notifType == "info" then
        notifColor = Color3.fromRGB(50, 100, 255)
    elseif notifType == "success" then
        notifColor = Color3.fromRGB(50, 200, 100)
    elseif notifType == "error" then
        notifColor = Color3.fromRGB(200, 50, 50)
    elseif notifType == "warning" then
        notifColor = Color3.fromRGB(255, 150, 50)
    else
        notifColor = self.config.Theme.Button
    end
    
    -- Create notification frame
    local notificationFrame = Instance.new("Frame")
    notificationFrame.Name = "Notification"
    notificationFrame.Size = UDim2.new(0, 250, 0, 80)
    notificationFrame.Position = UDim2.new(1, 20, 0.5 + (#self.notifications * 0.1), 0)
    notificationFrame.BackgroundColor3 = self.config.Theme.Background
    notificationFrame.BorderSizePixel = 0
    notificationFrame.Parent = self.gui
    
    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = notificationFrame
    
    -- Add color bar
    local colorBar = Instance.new("Frame")
    colorBar.Name = "ColorBar"
    colorBar.Size = UDim2.new(0, 5, 1, 0)
    colorBar.BackgroundColor3 = notifColor
    colorBar.BorderSizePixel = 0
    colorBar.Parent = notificationFrame
    
    local colorBarCorner = Instance.new("UICorner")
    colorBarCorner.CornerRadius = UDim.new(0, 6)
    colorBarCorner.Parent = colorBar
    
    -- Add title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -15, 0, 25)
    titleLabel.Position = UDim2.new(0, 15, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = self.config.Theme.Text
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notificationFrame
    
    -- Add message
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Size = UDim2.new(1, -15, 0, 40)
    messageLabel.Position = UDim2.new(0, 15, 0, 30)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = self.config.Theme.Text
    messageLabel.TextTransparency = 0.2
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextSize = 14
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.TextWrapped = true
    messageLabel.Parent = notificationFrame
    
    -- Add close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 20, 0, 20)
    closeButton.Position = UDim2.new(1, -25, 0, 5)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "×"
    closeButton.TextColor3 = self.config.Theme.Text
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 18
    closeButton.Parent = notificationFrame
    
    -- Add to notifications list
    table.insert(self.notifications, notificationFrame)
    
    -- Update positions
    self:UpdateNotificationPositions()
    
    -- Slide in animation
    notificationFrame:TweenPosition(
        UDim2.new(1, -270, notificationFrame.Position.Y.Scale, 0),
        Enum.EasingDirection.Out,
        Enum.EasingStyle.Quart,
        0.5,
        true
    )
    
    -- Remove notification function
    local function removeNotification()
        if self.destroyed then return end
        
        -- Remove from list
        for i, notif in ipairs(self.notifications) do
            if notif == notificationFrame then
                table.remove(self.notifications, i)
                break
            end
        end
        
        -- Slide out animation
        notificationFrame:TweenPosition(
            UDim2.new(1, 20, notificationFrame.Position.Y.Scale, 0),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quart,
            0.5,
            true,
            function()
                if notificationFrame and notificationFrame.Parent then
                    notificationFrame:Destroy()
                    if not self.destroyed then
                        self:UpdateNotificationPositions()
                    end
                end
            end
        )
    end
    
    -- Setup close button
    closeButton.Activated:Connect(removeNotification)
    
    -- Auto close
    task.delay(duration, function()
        if notificationFrame and notificationFrame.Parent and not self.destroyed then
            removeNotification()
        end
    end)
    
    return notificationFrame
end

-- Update notification positions
function LolvyUI:UpdateNotificationPositions()
    if self.destroyed then return end
    
    for i, notif in ipairs(self.notifications) do
        notif:TweenPosition(
            UDim2.new(1, notif.Position.X.Offset, 0.1 + ((i - 1) * 0.12), 0),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quart,
            0.3,
            true
        )
    end
end

-- Get tab by name
function LolvyUI:GetTab(tabName)
    if self.destroyed then return nil end
    
    for _, tab in ipairs(self.tabs) do
        if tab.name == tabName then
            return tab
        end
    end
    return nil
end

-- Destroy the UI
function LolvyUI:Destroy()
    if self.destroyed then return end
    
    self.destroyed = true
    
    if self.gui then
        self.gui:Destroy()
    end
    
    -- Clear references
    self.tabs = nil
    self.currentTab = nil
    self.notifications = nil
    self.config = nil
end

return LolvyUI
