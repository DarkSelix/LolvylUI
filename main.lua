local Lolvyl = {}

local tween = game:GetService("TweenService")
local tweeninfo = TweenInfo.new
local input = game:GetService("UserInputService")
local run = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")

local Utility = {}
local Objects = {}

-- Detect if device is mobile
local isMobile = userInputService.TouchEnabled and not userInputService.KeyboardEnabled and not userInputService.MouseEnabled

-- Modified dragging function for both mouse and touch
function Lolvyl:DraggingEnabled(frame, parent)
    parent = parent or frame
    
    local dragging = false
    local dragInput, mousePos, framePos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            mousePos = input.Position
            framePos = parent.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    userInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            parent.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)
end

function Utility:TweenObject(obj, properties, duration, ...)
    tween:Create(obj, tweeninfo(duration, ...), properties):Play()
end

-- LolvylUI purple theme
local themes = {
    SchemeColor = Color3.fromRGB(147, 112, 219), -- Light purple
    Background = Color3.fromRGB(30, 30, 45),     -- Dark purple-tinted background
    Header = Color3.fromRGB(25, 25, 40),         -- Darker header
    TextColor = Color3.fromRGB(255, 255, 255),   -- White text
    ElementColor = Color3.fromRGB(40, 40, 60)    -- Elements background
}

-- Original themes plus our new LolvylUI theme
local themeStyles = {
    DarkTheme = {
        SchemeColor = Color3.fromRGB(64, 64, 64),
        Background = Color3.fromRGB(0, 0, 0),
        Header = Color3.fromRGB(0, 0, 0),
        TextColor = Color3.fromRGB(255, 255, 255),
        ElementColor = Color3.fromRGB(20, 20, 20)
    },
    LightTheme = {
        SchemeColor = Color3.fromRGB(150, 150, 150),
        Background = Color3.fromRGB(255, 255, 255),
        Header = Color3.fromRGB(200, 200, 200),
        TextColor = Color3.fromRGB(0, 0, 0),
        ElementColor = Color3.fromRGB(224, 224, 224)
    },
    BloodTheme = {
        SchemeColor = Color3.fromRGB(227, 27, 27),
        Background = Color3.fromRGB(10, 10, 10),
        Header = Color3.fromRGB(5, 5, 5),
        TextColor = Color3.fromRGB(255, 255, 255),
        ElementColor = Color3.fromRGB(20, 20, 20)
    },
    GrapeTheme = {
        SchemeColor = Color3.fromRGB(166, 71, 214),
        Background = Color3.fromRGB(64, 50, 71),
        Header = Color3.fromRGB(36, 28, 41),
        TextColor = Color3.fromRGB(255, 255, 255),
        ElementColor = Color3.fromRGB(74, 58, 84)
    },
    Ocean = {
        SchemeColor = Color3.fromRGB(86, 76, 251),
        Background = Color3.fromRGB(26, 32, 58),
        Header = Color3.fromRGB(38, 45, 71),
        TextColor = Color3.fromRGB(200, 200, 200),
        ElementColor = Color3.fromRGB(38, 45, 71)
    },
    Midnight = {
        SchemeColor = Color3.fromRGB(26, 189, 158),
        Background = Color3.fromRGB(44, 62, 82),
        Header = Color3.fromRGB(57, 81, 105),
        TextColor = Color3.fromRGB(255, 255, 255),
        ElementColor = Color3.fromRGB(52, 74, 95)
    },
    Sentinel = {
        SchemeColor = Color3.fromRGB(230, 35, 69),
        Background = Color3.fromRGB(32, 32, 32),
        Header = Color3.fromRGB(24, 24, 24),
        TextColor = Color3.fromRGB(119, 209, 138),
        ElementColor = Color3.fromRGB(24, 24, 24)
    },
    Synapse = {
        SchemeColor = Color3.fromRGB(46, 48, 43),
        Background = Color3.fromRGB(13, 15, 12),
        Header = Color3.fromRGB(36, 38, 35),
        TextColor = Color3.fromRGB(152, 99, 53),
        ElementColor = Color3.fromRGB(24, 24, 24)
    },
    Serpent = {
        SchemeColor = Color3.fromRGB(0, 166, 58),
        Background = Color3.fromRGB(31, 41, 43),
        Header = Color3.fromRGB(22, 29, 31),
        TextColor = Color3.fromRGB(255, 255, 255),
        ElementColor = Color3.fromRGB(22, 29, 31)
    },
    -- New LolvylUI custom theme
    LolvylUI = {
        SchemeColor = Color3.fromRGB(147, 112, 219),   -- Medium purple
        Background = Color3.fromRGB(30, 30, 45),       -- Dark purple-blue
        Header = Color3.fromRGB(25, 25, 40),           -- Darker header
        TextColor = Color3.fromRGB(255, 255, 255),     -- White text
        ElementColor = Color3.fromRGB(40, 40, 60)      -- Elements background
    }
}

local oldTheme = ""
local SettingsT = {}
local Name = "LolvylConfig.JSON"

pcall(function()
    if not pcall(function() readfile(Name) end) then
        writefile(Name, game:service'HttpService':JSONEncode(SettingsT))
    end
    
    Settings = game:service'HttpService':JSONEncode(readfile(Name))
end)

local LibName = tostring(math.random(1, 100))..tostring(math.random(1,50))..tostring(math.random(1, 100))

function Lolvyl:ToggleUI()
    if game.CoreGui[LibName].Enabled then
        game.CoreGui[LibName].Enabled = false
    else
        game.CoreGui[LibName].Enabled = true
    end
end

function Lolvyl.CreateLib(libName, themeList)
    if not themeList then
        themeList = themes  -- Default to our purple theme
    end
    
    -- Theme selection
    if themeList == "DarkTheme" then
        themeList = themeStyles.DarkTheme
    elseif themeList == "LightTheme" then
        themeList = themeStyles.LightTheme
    elseif themeList == "BloodTheme" then
        themeList = themeStyles.BloodTheme
    elseif themeList == "GrapeTheme" then
        themeList = themeStyles.GrapeTheme
    elseif themeList == "Ocean" then
        themeList = themeStyles.Ocean
    elseif themeList == "Midnight" then
        themeList = themeStyles.Midnight
    elseif themeList == "Sentinel" then
        themeList = themeStyles.Sentinel
    elseif themeList == "Synapse" then
        themeList = themeStyles.Synapse
    elseif themeList == "Serpent" then
        themeList = themeStyles.Serpent
    elseif themeList == "LolvylUI" then
        themeList = themeStyles.LolvylUI
    else
        -- Verify custom theme has all required properties
        if themeList.SchemeColor == nil then
            themeList.SchemeColor = Color3.fromRGB(147, 112, 219)
        elseif themeList.Background == nil then
            themeList.Background = Color3.fromRGB(30, 30, 45)
        elseif themeList.Header == nil then
            themeList.Header = Color3.fromRGB(25, 25, 40)
        elseif themeList.TextColor == nil then
            themeList.TextColor = Color3.fromRGB(255, 255, 255)
        elseif themeList.ElementColor == nil then
            themeList.ElementColor = Color3.fromRGB(40, 40, 60)
        end
    end

    themeList = themeList or {}
    local selectedTab 
    libName = libName or "LolvylUI"
    table.insert(Lolvyl, libName)
    
    for i,v in pairs(game.Players.LocalPlayer.PlayerGui:GetChildren()) do
        if v:IsA("ScreenGui") and v.Name == libName then
            v:Destroy()
        end
    end
    
    -- Create main UI components
    local ScreenGui = Instance.new("ScreenGui")
    local Main = Instance.new("Frame")
    local MainCorner = Instance.new("UICorner")
    local MainHeader = Instance.new("Frame")
    local headerCover = Instance.new("UICorner")
    local coverup = Instance.new("Frame")
    local title = Instance.new("TextLabel")
    local close = Instance.new("ImageButton")
    local minimize = Instance.new("ImageButton") -- New minimize button
    local MainSide = Instance.new("Frame")
    local sideCorner = Instance.new("UICorner")
    local coverup_2 = Instance.new("Frame")
    local tabFrames = Instance.new("Frame")
    local tabListing = Instance.new("UIListLayout")
    local pages = Instance.new("Frame")
    local Pages = Instance.new("Folder")
    local infoContainer = Instance.new("Frame")
    local blurFrame = Instance.new("Frame")
    
    -- Make main frame draggable
    Lolvyl:DraggingEnabled(MainHeader, Main)

    -- Set up blur frame
    blurFrame.Name = "blurFrame"
    blurFrame.Parent = pages
    blurFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    blurFrame.BackgroundTransparency = 1
    blurFrame.BorderSizePixel = 0
    blurFrame.Position = UDim2.new(-0.0222222228, 0, -0.0371747203, 0)
    blurFrame.Size = UDim2.new(0, 376, 0, 289)
    blurFrame.ZIndex = 999

    -- Screen GUI setup
    ScreenGui.Parent = game.CoreGui
    ScreenGui.Name = LibName
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    
    -- Adjust for mobile
    if isMobile then
        ScreenGui.IgnoreGuiInset = true
    end

    -- Main frame setup - adjusted for better visibility on mobile
    Main.Name = "Main"
    Main.Parent = ScreenGui
    Main.BackgroundColor3 = themeList.Background
    Main.ClipsDescendants = true
    
    -- Adjust position and size based on device
    if isMobile then
        -- For mobile, make it take more screen space
        Main.Position = UDim2.new(0.1, 0, 0.15, 0)
        Main.Size = UDim2.new(0, 525, 0, 350)
    else
        -- For desktop, keep original positioning
        Main.Position = UDim2.new(0.336503863, 0, 0.275485456, 0)
        Main.Size = UDim2.new(0, 525, 0, 318)
    end

    MainCorner.CornerRadius = UDim.new(0, 6) -- Rounder corners
    MainCorner.Name = "MainCorner"
    MainCorner.Parent = Main

    MainHeader.Name = "MainHeader"
    MainHeader.Parent = Main
    MainHeader.BackgroundColor3 = themeList.Header
    Objects[MainHeader] = "BackgroundColor3"
    MainHeader.Size = UDim2.new(0, 525, 0, 29)
    
    headerCover.CornerRadius = UDim.new(0, 6) -- Match main corner radius
    headerCover.Name = "headerCover"
    headerCover.Parent = MainHeader

    coverup.Name = "coverup"
    coverup.Parent = MainHeader
    coverup.BackgroundColor3 = themeList.Header
    Objects[coverup] = "BackgroundColor3"
    coverup.BorderSizePixel = 0
    coverup.Position = UDim2.new(0, 0, 0.758620679, 0)
    coverup.Size = UDim2.new(0, 525, 0, 7)

    title.Name = "title"
    title.Parent = MainHeader
    title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    title.BackgroundTransparency = 1.000
    title.BorderSizePixel = 0
    title.Position = UDim2.new(0.0171428565, 0, 0.344827592, 0)
    title.Size = UDim2.new(0, 204, 0, 8)
    title.Font = Enum.Font.GothamBold -- Changed to bold for better visibility
    title.Text = libName
    title.TextColor3 = Color3.fromRGB(245, 245, 245)
    title.TextSize = 16.000
    title.TextXAlignment = Enum.TextXAlignment.Left

    -- Close button
    close.Name = "close"
    close.Parent = MainHeader
    close.BackgroundTransparency = 1.000
    close.Position = UDim2.new(0.949999988, 0, 0.137999997, 0)
    close.Size = UDim2.new(0, 21, 0, 21)
    close.ZIndex = 2
    close.Image = "rbxassetid://3926305904"
    close.ImageRectOffset = Vector2.new(284, 4)
    close.ImageRectSize = Vector2.new(24, 24)
    close.ImageColor3 = Color3.fromRGB(255, 255, 255) -- White icon for visibility
    
    -- Minimize button
    minimize.Name = "minimize"
    minimize.Parent = MainHeader
    minimize.BackgroundTransparency = 1.000
    minimize.Position = UDim2.new(0.9, 0, 0.137999997, 0)
    minimize.Size = UDim2.new(0, 21, 0, 21)
    minimize.ZIndex = 2
    minimize.Image = "rbxassetid://3926307971"
    minimize.ImageRectOffset = Vector2.new(884, 284)
    minimize.ImageRectSize = Vector2.new(36, 36)
    minimize.ImageColor3 = Color3.fromRGB(255, 255, 255) -- White icon for visibility
    
    -- Set up sidebar
    MainSide.Name = "MainSide"
    MainSide.Parent = Main
    MainSide.BackgroundColor3 = themeList.Header
    Objects[MainSide] = "Header"
    MainSide.Position = UDim2.new(-7.4505806e-09, 0, 0.0911949649, 0)
    MainSide.Size = UDim2.new(0, 149, 0, 289)

    sideCorner.CornerRadius = UDim.new(0, 6) -- Match main corner radius
    sideCorner.Name = "sideCorner"
    sideCorner.Parent = MainSide

    coverup_2.Name = "coverup"
    coverup_2.Parent = MainSide
    coverup_2.BackgroundColor3 = themeList.Header
    Objects[coverup_2] = "Header"
    coverup_2.BorderSizePixel = 0
    coverup_2.Position = UDim2.new(0.949939311, 0, 0, 0)
    coverup_2.Size = UDim2.new(0, 7, 0, 289)

    tabFrames.Name = "tabFrames"
    tabFrames.Parent = MainSide
    tabFrames.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    tabFrames.BackgroundTransparency = 1.000
    tabFrames.Position = UDim2.new(0.0438990258, 0, -0.00066378375, 0)
    tabFrames.Size = UDim2.new(0, 135, 0, 283)

    -- Adjust tab listing for better spacing on mobile
    tabListing.Name = "tabListing"
    tabListing.Parent = tabFrames
    tabListing.SortOrder = Enum.SortOrder.LayoutOrder
    
    if isMobile then
        tabListing.Padding = UDim.new(0, 8) -- More padding for touch targets
    else
        tabListing.Padding = UDim.new(0, 5)
    end

    pages.Name = "pages"
    pages.Parent = Main
    pages.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    pages.BackgroundTransparency = 1.000
    pages.BorderSizePixel = 0
    pages.Position = UDim2.new(0.299047589, 0, 0.122641519, 0)
    pages.Size = UDim2.new(0, 360, 0, 269)

    Pages.Name = "Pages"
    Pages.Parent = pages

infoContainer.Name = "infoContainer"
infoContainer.Parent = Main
infoContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
infoContainer.BackgroundTransparency = 1.000
infoContainer.BorderColor3 = Color3.fromRGB(27, 42, 53)
infoContainer.ClipsDescendants = true
infoContainer.Position = UDim2.new(0.299047619, 0, 0.874213815, 0)
infoContainer.Size = UDim2.new(0, 368, 0, 33)

-- Add minimize functionality
local minimized = false
minimize.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        -- Tween the main container to minimize it
        Utility:TweenObject(MainHeader, {Size = UDim2.new(0, 525, 0, 29)}, 0.5)
        Utility:TweenObject(Main, {Size = UDim2.new(0, 525, 0, 29)}, 0.5)
        
        -- Hide everything except the header
        for _, child in pairs(Main:GetChildren()) do
            if child ~= MainHeader and child ~= MainCorner then
                child.Visible = false
            end
        end
        -- Change minimize icon to expand
        minimize.ImageRectOffset = Vector2.new(764, 244)
        minimize.ImageRectSize = Vector2.new(36, 36)
    else
        -- Restore to original size
        if isMobile then
            Utility:TweenObject(Main, {Size = UDim2.new(0, 525, 0, 350)}, 0.5)
        else
            Utility:TweenObject(Main, {Size = UDim2.new(0, 525, 0, 318)}, 0.5)
        end
        
        -- Make everything visible again
        wait(0.3) -- Wait for animation to progress before showing content
        for _, child in pairs(Main:GetChildren()) do
            child.Visible = true
        end
        -- Change icon back to minimize
        minimize.ImageRectOffset = Vector2.new(884, 284)
        minimize.ImageRectSize = Vector2.new(36, 36)
    end
end)
    
-- Close button functionality
close.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)
    
-- Update theme colors continuously
coroutine.wrap(function()
    while wait() do
        Main.BackgroundColor3 = themeList.Background
        MainHeader.BackgroundColor3 = themeList.Header
        MainSide.BackgroundColor3 = themeList.Header
        coverup_2.BackgroundColor3 = themeList.Header
        coverup.BackgroundColor3 = themeList.Header
    end
end)()

-- Function to change theme colors
function Lolvyl:ChangeColor(prope, color)
    if prope == "Background" then
        themeList.Background = color
    elseif prope == "SchemeColor" then
        themeList.SchemeColor = color
    elseif prope == "Header" then
        themeList.Header = color
    elseif prope == "TextColor" then
        themeList.TextColor = color
    elseif prope == "ElementColor" then
        themeList.ElementColor = color
    end
end
    
local Tabs = {}
local first = true

-- Function to create new tabs
function Tabs:NewTab(tabName)
    tabName = tabName or "Tab"
    local tabButton = Instance.new("TextButton")
    local UICorner = Instance.new("UICorner")
    local page = Instance.new("ScrollingFrame")
    local pageListing = Instance.new("UIListLayout")

    local function UpdateSize()
        local cS = pageListing.AbsoluteContentSize

        game.TweenService:Create(page, TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
            CanvasSize = UDim2.new(0,cS.X,0,cS.Y)
        }):Play()
    end

    page.Name = "Page"
    page.Parent = Pages
    page.Active = true
    page.BackgroundColor3 = themeList.Background
    page.BorderSizePixel = 0
    page.Position = UDim2.new(0, 0, -0.00371747208, 0)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.ScrollBarThickness = 5
    page.Visible = false
    page.ScrollBarImageColor3 = Color3.fromRGB(themeList.SchemeColor.r * 255 - 16, themeList.SchemeColor.g * 255 - 15, themeList.SchemeColor.b * 255 - 28)

    pageListing.Name = "pageListing"
    pageListing.Parent = page
    pageListing.SortOrder = Enum.SortOrder.LayoutOrder
    pageListing.Padding = UDim.new(0, 5)

    tabButton.Name = tabName.."TabButton"
    tabButton.Parent = tabFrames
    tabButton.BackgroundColor3 = themeList.SchemeColor
    Objects[tabButton] = "SchemeColor"
    tabButton.Size = UDim2.new(0, 135, 0, 28)
    tabButton.AutoButtonColor = false
    tabButton.Font = Enum.Font.Gotham
    tabButton.Text = tabName
    tabButton.TextColor3 = themeList.TextColor
    Objects[tabButton] = "TextColor3"
    tabButton.TextSize = 14.000
    tabButton.BackgroundTransparency = 1

    if first then
        page.Visible = true
        tabButton.BackgroundTransparency = 0
        first = false
        UpdateSize()
    else
        page.Visible = false
        tabButton.BackgroundTransparency = 1
    end

    UICorner.CornerRadius = UDim.new(0, 5)
    UICorner.Parent = tabButton
    table.insert(Tabs, tabName)

    UpdateSize()
    page.ChildAdded:Connect(UpdateSize)
    page.ChildRemoved:Connect(UpdateSize)

    tabButton.MouseButton1Click:Connect(function()
        UpdateSize()
        for i,v in next, Pages:GetChildren() do
            v.Visible = false
        end
        page.Visible = true
        for i,v in next, tabFrames:GetChildren() do
            if v:IsA("TextButton") then
                if themeList.SchemeColor == Color3.fromRGB(255,255,255) then
                    Utility:TweenObject(v, {TextColor3 = Color3.fromRGB(255,255,255)}, 0.2)
                end 
                if themeList.SchemeColor == Color3.fromRGB(0,0,0) then
                    Utility:TweenObject(v, {TextColor3 = Color3.fromRGB(0,0,0)}, 0.2)
                end 
                Utility:TweenObject(v, {BackgroundTransparency = 1}, 0.2)
            end
        end
        if themeList.SchemeColor == Color3.fromRGB(255,255,255) then
            Utility:TweenObject(tabButton, {TextColor3 = Color3.fromRGB(0,0,0)}, 0.2)
        end 
        if themeList.SchemeColor == Color3.fromRGB(0,0,0) then
            Utility:TweenObject(tabButton, {TextColor3 = Color3.fromRGB(255,255,255)}, 0.2)
        end 
        Utility:TweenObject(tabButton, {BackgroundTransparency = 0}, 0.2)
    end)
    local Sections = {}
    local focusing = false
    local viewDe = false

    coroutine.wrap(function()
        while wait() do
            page.BackgroundColor3 = themeList.Background
            page.ScrollBarImageColor3 = Color3.fromRGB(themeList.SchemeColor.r * 255 - 16, themeList.SchemeColor.g * 255 - 15, themeList.SchemeColor.b * 255 - 28)
            tabButton.TextColor3 = themeList.TextColor
            tabButton.BackgroundColor3 = themeList.SchemeColor
        end
    end)()

    -- Function to create new sections
    function Sections:NewSection(secName)
        secName = secName or "Section"
        local modules = {}

        local sectionFrame = Instance.new("Frame")
        local sectionlistoknvm = Instance.new("UIListLayout")
        local sectionHead = Instance.new("Frame")
        local sHeadCorner = Instance.new("UICorner")
        local sectionName = Instance.new("TextLabel")
        local sectionInners = Instance.new("Frame")
        local sectionElListing = Instance.new("UIListLayout")

        sectionFrame.Name = "sectionFrame"
        sectionFrame.Parent = page
        sectionFrame.BackgroundColor3 = themeList.Background--36, 37, 43
        Objects[sectionFrame] = "BackgroundColor3"
        sectionFrame.BorderSizePixel = 0
        
        sectionlistoknvm.Name = "sectionlistoknvm"
        sectionlistoknvm.Parent = sectionFrame
        sectionlistoknvm.SortOrder = Enum.SortOrder.LayoutOrder
        sectionlistoknvm.Padding = UDim.new(0, 5)

        for i,v in pairs(sectionInners:GetChildren()) do
            while wait() do
                if v:IsA("Frame") or v:IsA("TextButton") then
                    function size(pro)
                        if pro == "Size" then
                            UpdateSize()
                            updateSectionFrame()
                        end
                    end
                    v.Changed:Connect(size)
                end
            end
        end
        sectionHead.Name = "sectionHead"
        sectionHead.Parent = sectionFrame
        sectionHead.BackgroundColor3 = themeList.SchemeColor
        Objects[sectionHead] = "BackgroundColor3"
        sectionHead.Size = UDim2.new(0, 352, 0, 33)

        sHeadCorner.CornerRadius = UDim.new(0, 4)
        sHeadCorner.Name = "sHeadCorner"
        sHeadCorner.Parent = sectionHead

        sectionName.Name = "sectionName"
        sectionName.Parent = sectionHead
        sectionName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        sectionName.BackgroundTransparency = 1.000
        sectionName.BorderColor3 = Color3.fromRGB(27, 42, 53)
        sectionName.Position = UDim2.new(0.0198863633, 0, 0, 0)
        sectionName.Size = UDim2.new(0.980113626, 0, 1, 0)
        sectionName.Font = Enum.Font.Gotham
        sectionName.Text = secName
        sectionName.TextColor3 = themeList.TextColor
        Objects[sectionName] = "TextColor3"
        sectionName.TextSize = 14.000
        sectionName.TextXAlignment = Enum.TextXAlignment.Left

        if themeList.SchemeColor == Color3.fromRGB(255,255,255) then
            Utility:TweenObject(sectionName, {TextColor3 = Color3.fromRGB(0,0,0)}, 0.2)
        end 
        if themeList.SchemeColor == Color3.fromRGB(0,0,0) then
            Utility:TweenObject(sectionName, {TextColor3 = Color3.fromRGB(255,255,255)}, 0.2)
        end 

        sectionInners.Name = "sectionInners"
        sectionInners.Parent = sectionFrame
        sectionInners.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        sectionInners.BackgroundTransparency = 1.000
        sectionInners.Position = UDim2.new(0, 0, 0.190751448, 0)

        sectionElListing.Name = "sectionElListing"
        sectionElListing.Parent = sectionInners
        sectionElListing.SortOrder = Enum.SortOrder.LayoutOrder
        sectionElListing.Padding = UDim.new(0, 3)

        coroutine.wrap(function()
            while wait() do
                sectionFrame.BackgroundColor3 = themeList.Background
                sectionHead.BackgroundColor3 = themeList.SchemeColor
                tabButton.TextColor3 = themeList.TextColor
                tabButton.BackgroundColor3 = themeList.SchemeColor
                sectionName.TextColor3 = themeList.TextColor
            end
        end)()

        local function updateSectionFrame()
            local innerSc = sectionElListing.AbsoluteContentSize
            sectionInners.Size = UDim2.new(1, 0, 0, innerSc.Y)
            local frameSc = sectionlistoknvm.AbsoluteContentSize
            sectionFrame.Size = UDim2.new(0, 352, 0, frameSc.Y)
        end
        updateSectionFrame()

        local Elements = {}

        -- Function to create new buttons
        function Elements:NewButton(bname, tipINf, callback)
            showLogo = showLogo or true
            local ButtonFunction = {}
            tipINf = tipINf or "Tip: Clicking this nothing will happen!"
            bname = bname or "Click Me!"
            callback = callback or function() end

            local buttonElement = Instance.new("TextButton")
            local UICorner = Instance.new("UICorner")
            local btnInfo = Instance.new("TextLabel")
            local viewInfo = Instance.new("ImageButton")
            local touch = Instance.new("ImageLabel")
            local Sample = Instance.new("ImageLabel")

            table.insert(modules, bname)

            buttonElement.Name = bname
            buttonElement.Parent = sectionInners
            buttonElement.BackgroundColor3 = themeList.ElementColor
            buttonElement.ClipsDescendants = true
            buttonElement.Size = UDim2.new(0, 352, 0, 33)
            buttonElement.AutoButtonColor = false
            buttonElement.Font = Enum.Font.SourceSans
            buttonElement.Text = ""
            buttonElement.TextColor3 = Color3.fromRGB(0, 0, 0)
            buttonElement.TextSize = 14.000
            Objects[buttonElement] = "BackgroundColor3"

            UICorner.CornerRadius = UDim.new(0, 4)
            UICorner.Parent = buttonElement

            viewInfo.Name = "viewInfo"
            viewInfo.Parent = buttonElement
            viewInfo.BackgroundTransparency = 1.000
            viewInfo.LayoutOrder = 9
            viewInfo.Position = UDim2.new(0.930000007, 0, 0.151999995, 0)
            viewInfo.Size = UDim2.new(0, 23, 0, 23)
            viewInfo.ZIndex = 2
            viewInfo.Image = "rbxassetid://3926305904"
            viewInfo.ImageColor3 = themeList.SchemeColor
            Objects[viewInfo] = "ImageColor3"
            viewInfo.ImageRectOffset = Vector2.new(764, 764)
            viewInfo.ImageRectSize = Vector2.new(36, 36)

            Sample.Name = "Sample"
            Sample.Parent = buttonElement
            Sample.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Sample.BackgroundTransparency = 1.000
            Sample.Image = "http://www.roblox.com/asset/?id=4560909609"
            Sample.ImageColor3 = themeList.SchemeColor
            Objects[Sample] = "ImageColor3"
            Sample.ImageTransparency = 0.600

            local moreInfo = Instance.new("TextLabel")
            local UICorner = Instance.new("UICorner")

            moreInfo.Name = "TipMore"
            moreInfo.Parent = infoContainer
            moreInfo.BackgroundColor3 = Color3.fromRGB(themeList.SchemeColor.r * 255 - 14, themeList.SchemeColor.g * 255 - 17, themeList.SchemeColor.b * 255 - 13)
            moreInfo.Position = UDim2.new(0, 0, 2, 0)
            moreInfo.Size = UDim2.new(0, 353, 0, 33)
            moreInfo.ZIndex = 9
            moreInfo.Font = Enum.Font.GothamSemibold
            moreInfo.Text = "  "..tipINf
            moreInfo.TextColor3 = themeList.TextColor
            Objects[moreInfo] = "TextColor3"
            moreInfo.TextSize = 14.000
            moreInfo.TextXAlignment = Enum.TextXAlignment.Left
            Objects[moreInfo] = "BackgroundColor3"

            UICorner.CornerRadius = UDim.new(0, 4)
            UICorner.Parent = moreInfo

            touch.Name = "touch"
            touch.Parent = buttonElement
            touch.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            touch.BackgroundTransparency = 1.000
            touch.BorderColor3 = Color3.fromRGB(27, 42, 53)
            touch.Position = UDim2.new(0.0199999996, 0, 0.180000007, 0)
            touch.Size = UDim2.new(0, 21, 0, 21)
            touch.Image = "rbxassetid://3926305904"
            touch.ImageColor3 = themeList.SchemeColor
            Objects[touch] = "SchemeColor"
            touch.ImageRectOffset = Vector2.new(84, 204)
            touch.ImageRectSize = Vector2.new(36, 36)
            touch.ImageTransparency = 0

            btnInfo.Name = "btnInfo"
            btnInfo.Parent = buttonElement
            btnInfo.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            btnInfo.BackgroundTransparency = 1.000
            btnInfo.Position = UDim2.new(0.096704483, 0, 0.272727281, 0)
            btnInfo.Size = UDim2.new(0, 314, 0, 14)
            btnInfo.Font = Enum.Font.GothamSemibold
            btnInfo.Text = bname
            btnInfo.TextColor3 = themeList.TextColor
            Objects[btnInfo] = "TextColor3"
            btnInfo.TextSize = 14.000
            btnInfo.TextXAlignment = Enum.TextXAlignment.Left

            if themeList.SchemeColor == Color3.fromRGB(255,255,255) then
                Utility:TweenObject(moreInfo, {TextColor3 = Color3.fromRGB(0,0,0)}, 0.2)
            end 
            if themeList.SchemeColor == Color3.fromRGB(0,0,0) then
                Utility:TweenObject(moreInfo, {TextColor3 = Color3.fromRGB(255,255,255)}, 0.2)
            end 

            updateSectionFrame()

local ms = game.Players.LocalPlayer:GetMouse()

local btn = buttonElement
local sample = Sample

btn.MouseButton1Click:Connect(function()
    if not focusing then
        callback()
        local c = sample:Clone()
        c.Parent = btn
        local x, y = (ms.X - c.AbsolutePosition.X), (ms.Y - c.AbsolutePosition.Y)
        c.Position = UDim2.new(0, x, 0, y)
        local len, size = 0.35, nil
        if btn.AbsoluteSize.X >= btn.AbsoluteSize.Y then
            size = (btn.AbsoluteSize.X * 1.5)
        else
            size = (btn.AbsoluteSize.Y * 1.5)
        end
        c:TweenSizeAndPosition(UDim2.new(0, size, 0, size), UDim2.new(0.5, (-size / 2), 0.5, (-size / 2)), 'Out', 'Quad', len, true, nil)
        for i = 1, 10 do
            c.ImageTransparency = c.ImageTransparency + 0.05
            wait(len / 12)
        end
        c:Destroy()
    else
        for i,v in next, infoContainer:GetChildren() do
            Utility:TweenObject(v, {Position = UDim2.new(0,0,2,0)}, 0.2)
            focusing = false
        end
        Utility:TweenObject(blurFrame, {BackgroundTransparency = 1}, 0.2)
    end
end)
local hovering = false
btn.MouseEnter:Connect(function()
    if not focusing then
        game.TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
            BackgroundColor3 = Color3.fromRGB(themeList.ElementColor.r * 255 + 8, themeList.ElementColor.g * 255 + 9, themeList.ElementColor.b * 255 + 10)
        }):Play()
        hovering = true
    end
end)
btn.MouseLeave:Connect(function()
    if not focusing then 
        game.TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
            BackgroundColor3 = themeList.ElementColor
        }):Play()
        hovering = false
    end
end)
viewInfo.MouseButton1Click:Connect(function()
    if not viewDe then
        viewDe = true
        focusing = true
        for i,v in next, infoContainer:GetChildren() do
            if v ~= moreInfo then
                Utility:TweenObject(v, {Position = UDim2.new(0,0,2,0)}, 0.2)
            end
        end
        Utility:TweenObject(moreInfo, {Position = UDim2.new(0,0,0,0)}, 0.2)
        Utility:TweenObject(blurFrame, {BackgroundTransparency = 0.5}, 0.2)
        Utility:TweenObject(btn, {BackgroundColor3 = themeList.ElementColor}, 0.2)
        wait(1.5)
        focusing = false
        Utility:TweenObject(moreInfo, {Position = UDim2.new(0,0,2,0)}, 0.2)
        Utility:TweenObject(blurFrame, {BackgroundTransparency = 1}, 0.2)
        wait(0)
        viewDe = false
    end
end)
coroutine.wrap(function()
    while wait() do
        if not hovering then
            buttonElement.BackgroundColor3 = themeList.ElementColor
        end
        viewInfo.ImageColor3 = themeList.SchemeColor
        Sample.ImageColor3 = themeList.SchemeColor
        moreInfo.BackgroundColor3 = Color3.fromRGB(themeList.SchemeColor.r * 255 - 14, themeList.SchemeColor.g * 255 - 17, themeList.SchemeColor.b * 255 - 13)
        moreInfo.TextColor3 = themeList.TextColor
        touch.ImageColor3 = themeList.SchemeColor
        btnInfo.TextColor3 = themeList.TextColor
    end
end)()

function ButtonFunction:UpdateButton(newTitle)
    btnInfo.Text = newTitle
end
return ButtonFunction
end

-- Function to create new textboxes
function Elements:NewTextBox(tname, tTip, callback)
    tname = tname or "Textbox"
    tTip = tTip or "Gets a value of Textbox"
    callback = callback or function() end
    local textboxElement = Instance.new("TextButton")
    local UICorner = Instance.new("UICorner")
    local viewInfo = Instance.new("ImageButton")
    local write = Instance.new("ImageLabel")
    local TextBox = Instance.new("TextBox")
    local UICorner_2 = Instance.new("UICorner")
    local togName = Instance.new("TextLabel")

    textboxElement.Name = "textboxElement"
    textboxElement.Parent = sectionInners
    textboxElement.BackgroundColor3 = themeList.ElementColor
    textboxElement.ClipsDescendants = true
    textboxElement.Size = UDim2.new(0, 352, 0, 33)
    textboxElement.AutoButtonColor = false
    textboxElement.Font = Enum.Font.SourceSans
    textboxElement.Text = ""
    textboxElement.TextColor3 = Color3.fromRGB(0, 0, 0)
    textboxElement.TextSize = 14.000

    UICorner.CornerRadius = UDim.new(0, 4)
    UICorner.Parent = textboxElement

    viewInfo.Name = "viewInfo"
    viewInfo.Parent = textboxElement
    viewInfo.BackgroundTransparency = 1.000
    viewInfo.LayoutOrder = 9
    viewInfo.Position = UDim2.new(0.930000007, 0, 0.151999995, 0)
    viewInfo.Size = UDim2.new(0, 23, 0, 23)
    viewInfo.ZIndex = 2
    viewInfo.Image = "rbxassetid://3926305904"
    viewInfo.ImageColor3 = themeList.SchemeColor
    viewInfo.ImageRectOffset = Vector2.new(764, 764)
    viewInfo.ImageRectSize = Vector2.new(36, 36)

    write.Name = "write"
    write.Parent = textboxElement
    write.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    write.BackgroundTransparency = 1.000
    write.BorderColor3 = Color3.fromRGB(27, 42, 53)
    write.Position = UDim2.new(0.0199999996, 0, 0.180000007, 0)
    write.Size = UDim2.new(0, 21, 0, 21)
    write.Image = "rbxassetid://3926305904"
    write.ImageColor3 = themeList.SchemeColor
    write.ImageRectOffset = Vector2.new(324, 604)
    write.ImageRectSize = Vector2.new(36, 36)

    TextBox.Parent = textboxElement
    TextBox.BackgroundColor3 = Color3.fromRGB(themeList.ElementColor.r * 255 - 6, themeList.ElementColor.g * 255 - 6, themeList.ElementColor.b * 255 - 7)
    TextBox.BorderSizePixel = 0
    TextBox.ClipsDescendants = true
    TextBox.Position = UDim2.new(0.488749921, 0, 0.212121218, 0)
    TextBox.Size = UDim2.new(0, 150, 0, 18)
    TextBox.ZIndex = 99
    TextBox.ClearTextOnFocus = false
    TextBox.Font = Enum.Font.Gotham
    TextBox.PlaceholderColor3 = Color3.fromRGB(themeList.SchemeColor.r * 255 - 19, themeList.SchemeColor.g * 255 - 26, themeList.SchemeColor.b * 255 - 35)
    TextBox.PlaceholderText = "Type here!"
    TextBox.Text = ""
    TextBox.TextColor3 = themeList.SchemeColor
    TextBox.TextSize = 12.000

    UICorner_2.CornerRadius = UDim.new(0, 4)
    UICorner_2.Parent = TextBox

    togName.Name = "togName"
    togName.Parent = textboxElement
    togName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    togName.BackgroundTransparency = 1.000
    togName.Position = UDim2.new(0.096704483, 0, 0.272727281, 0)
    togName.Size = UDim2.new(0, 138, 0, 14)
    togName.Font = Enum.Font.GothamSemibold
    togName.Text = tname
    togName.TextColor3 = themeList.TextColor
    togName.TextSize = 14.000
    togName.TextXAlignment = Enum.TextXAlignment.Left

    local moreInfo = Instance.new("TextLabel")
    local UICorner = Instance.new("UICorner")

    moreInfo.Name = "TipMore"
    moreInfo.Parent = infoContainer
    moreInfo.BackgroundColor3 = Color3.fromRGB(themeList.SchemeColor.r * 255 - 14, themeList.SchemeColor.g * 255 - 17, themeList.SchemeColor.b * 255 - 13)
    moreInfo.Position = UDim2.new(0, 0, 2, 0)
    moreInfo.Size = UDim2.new(0, 353, 0, 33)
    moreInfo.ZIndex = 9
    moreInfo.Font = Enum.Font.GothamSemibold
    moreInfo.Text = "  "..tTip
    moreInfo.TextColor3 = Color3.fromRGB(255, 255, 255)
    moreInfo.TextSize = 14.000
    moreInfo.TextXAlignment = Enum.TextXAlignment.Left

    if themeList.SchemeColor == Color3.fromRGB(255,255,255) then
        Utility:TweenObject(moreInfo, {TextColor3 = Color3.fromRGB(0,0,0)}, 0.2)
    end 
    if themeList.SchemeColor == Color3.fromRGB(0,0,0) then
        Utility:TweenObject(moreInfo, {TextColor3 = Color3.fromRGB(255,255,255)}, 0.2)
    end 

    UICorner.CornerRadius = UDim.new(0, 4)
    UICorner.Parent = moreInfo


    updateSectionFrame()
    
    local btn = textboxElement
    local infBtn = viewInfo

    btn.MouseButton1Click:Connect(function()
        if focusing then
            for i,v in next, infoContainer:GetChildren() do
                Utility:TweenObject(v, {Position = UDim2.new(0,0,2,0)}, 0.2)
                focusing = false
            end
            Utility:TweenObject(blurFrame, {BackgroundTransparency = 1}, 0.2)
        end
    end)
    local hovering = false
    btn.MouseEnter:Connect(function()
        if not focusing then
            game.TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
                BackgroundColor3 = Color3.fromRGB(themeList.ElementColor.r * 255 + 8, themeList.ElementColor.g * 255 + 9, themeList.ElementColor.b * 255 + 10)
            }):Play()
            hovering = true
        end 
    end)

    btn.MouseLeave:Connect(function()
        if not focusing then
            game.TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
                BackgroundColor3 = themeList.ElementColor
            }):Play()
            hovering = false
        end
    end)

    TextBox.FocusLost:Connect(function(EnterPressed)
        if focusing then
            for i,v in next, infoContainer:GetChildren() do
                Utility:TweenObject(v, {Position = UDim2.new(0,0,2,0)}, 0.2)
                focusing = false
            end
            Utility:TweenObject(blurFrame, {BackgroundTransparency = 1}, 0.2)
        end
        if not EnterPressed then 
            return
        else
            callback(TextBox.Text)
            wait(0.18)
            TextBox.Text = ""  
        end
    end)

    viewInfo.MouseButton1Click:Connect(function()
        if not viewDe then
            viewDe = true
            focusing = true
            for i,v in next, infoContainer:GetChildren() do
                if v ~= moreInfo then
                    Utility:TweenObject(v, {Position = UDim2.new(0,0,2,0)}, 0.2)
                end
            end
            Utility:TweenObject(moreInfo, {Position = UDim2.new(0,0,0,0)}, 0.2)
            Utility:TweenObject(blurFrame, {BackgroundTransparency = 0.5}, 0.2)
            Utility:TweenObject(btn, {BackgroundColor3 = themeList.ElementColor}, 0.2)
            wait(1.5)
            focusing = false
            Utility:TweenObject(moreInfo, {Position = UDim2.new(0,0,2,0)}, 0.2)
            Utility:TweenObject(blurFrame, {BackgroundTransparency = 1}, 0.2)
            wait(0)
            viewDe = false
        end
    end)
    coroutine.wrap(function()
        while wait() do
            if not hovering then
                textboxElement.BackgroundColor3 = themeList.ElementColor
            end
            viewInfo.ImageColor3 = themeList.SchemeColor
            TextBox.PlaceholderColor3 = Color3.fromRGB(themeList.SchemeColor.r * 255 - 19, themeList.SchemeColor.g * 255 - 26, themeList.SchemeColor.b * 255 - 35)
            TextBox.TextColor3 = themeList.SchemeColor
            moreInfo.BackgroundColor3 = Color3.fromRGB(themeList.SchemeColor.r * 255 - 14, themeList.SchemeColor.g * 255 - 17, themeList.SchemeColor.b * 255 - 13)
            moreInfo.TextColor3 = themeList.TextColor
            write.ImageColor3 = themeList.SchemeColor
            togName.TextColor3 = themeList.TextColor
        end
    end)()
end

return Sections
end

return Tabs
end

return Lolvyl