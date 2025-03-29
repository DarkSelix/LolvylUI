local LolvyUI = {}
LolvyUI.__index = LolvyUI

-- Configurações padrão
local DEFAULT_CONFIG = {
    Title = "Horizontal Hub",
    Theme = {
        Background = Color3.fromRGB(30, 15, 30), -- Roxo muito escuro quase carmesim/preto
        Button = Color3.fromRGB(45, 25, 45),     -- Botões um pouco mais forte
        ButtonHover = Color3.fromRGB(55, 35, 55),
        ToggleOn = Color3.fromRGB(165, 25, 50),  -- Carmesim forte para toggle ativado
        Text = Color3.fromRGB(230, 230, 230),
        TabSelected = Color3.fromRGB(60, 35, 60),
        TabUnselected = Color3.fromRGB(40, 20, 40)
    },
    KeyBind = Enum.KeyCode.C,
    Image = "rbxassetid://0", -- Imagem de fundo (substitua pelo ID)
    MobileButtonImage = "rbxassetid://0" -- Imagem do botão mobile (substitua pelo ID)
}

-- Criar uma nova instância do hub
function HorizontalHub.new(config)
    local self = setmetatable({}, HorizontalHub)
    
    -- Mesclar configurações fornecidas com padrões
    self.config = {}
    for key, value in pairs(DEFAULT_CONFIG) do
        if type(value) == "table" then
            self.config[key] = {}
            for subKey, subValue in pairs(value) do
                self.config[key][subKey] = (config and config[key] and config[key][subKey] ~= nil) and config[key][subKey] or subValue
            end
        else
            self.config[key] = (config and config[key] ~= nil) and config[key] or value
        end
    end
    
    -- Estado interno
    self.tabs = {}
    self.currentTab = nil
    self.visible = false
    self.notifications = {}
    
    -- Inicializar a GUI
    self:Initialize()
    
    return self
end

-- Inicializar a interface
function LolvyUI:Initialize()
    local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "HorizontalHubGui"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = playerGui
    
    -- Armazenar referência
    self.gui = screenGui
    
    -- Criar a UI principal
    self:CreateMainUI()
    
    -- Configurar sistema de redimensionamento
    self:SetupResizing()
    
    -- Configurar keybind
    self:SetupKeybind()
    
    -- Detectar se é dispositivo móvel
    self:SetupMobileSupport()
    
    -- Inicialmente ocultar o hub
    self.mainFrame.Visible = false
end

-- Criar a UI principal
function LolvyUI:CreateMainUI()
    -- Título acima da tela
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
    
    -- Frame principal
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0.9, 0, 0.6, 0)
    mainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
    mainFrame.BackgroundColor3 = self.config.Theme.Background
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = self.gui
    
    -- Cantos arredondados e sombra
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5028857084" -- Imagem de sombra
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.6
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(24, 24, 276, 276)
    shadow.ZIndex = -1
    shadow.Parent = mainFrame
    
    -- Imagem de fundo
    if self.config.Image and self.config.Image ~= "rbxassetid://0" then
        local bgImage = Instance.new("ImageLabel")
        bgImage.Name = "BackgroundImage"
        bgImage.Size = UDim2.new(1, 0, 1, 0)
        bgImage.BackgroundTransparency = 1
        bgImage.Image = self.config.Image
        bgImage.ImageTransparency = 0.85
        bgImage.ScaleType = Enum.ScaleType.Crop
        bgImage.Parent = mainFrame
    end
    
    -- Container para abas (lado esquerdo)
    local tabsContainer = Instance.new("Frame")
    tabsContainer.Name = "TabsContainer"
    tabsContainer.Size = UDim2.new(0.2, 0, 1, 0)
    tabsContainer.Position = UDim2.new(0, 0, 0, 0)
    tabsContainer.BackgroundColor3 = Color3.fromRGB(20, 10, 20) -- Um pouco mais escuro que o fundo
    tabsContainer.BorderSizePixel = 0
    tabsContainer.Parent = mainFrame
    
    local tabsCorner = Instance.new("UICorner")
    tabsCorner.CornerRadius = UDim.new(0, 8)
    tabsCorner.Parent = tabsContainer
    
    -- Garantir que apenas o lado esquerdo tenha cantos arredondados
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.5, 0, 1, 0)
    frame.Position = UDim2.new(0.5, 0, 0, 0)
    frame.BackgroundColor3 = Color3.fromRGB(20, 10, 20)
    frame.BorderSizePixel = 0
    frame.Parent = tabsContainer
    
    -- Contêiner de abas com rolagem
    local tabsList = Instance.new("ScrollingFrame")
    tabsList.Name = "TabsList"
    tabsList.Size = UDim2.new(1, 0, 1, -10)
    tabsList.Position = UDim2.new(0, 0, 0, 5)
    tabsList.BackgroundTransparency = 1
    tabsList.ScrollBarThickness = 4
    tabsList.ScrollBarImageColor3 = self.config.Theme.ToggleOn
    tabsList.CanvasSize = UDim2.new(0, 0, 0, 0) -- Será atualizado dinamicamente
    tabsList.Parent = tabsContainer
    
    local tabsListLayout = Instance.new("UIListLayout")
    tabsListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabsListLayout.Padding = UDim.new(0, 5)
    tabsListLayout.Parent = tabsList
    
    -- Container de conteúdo (lado direito)
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Size = UDim2.new(0.8, 0, 1, 0)
    contentContainer.Position = UDim2.new(0.2, 0, 0, 0)
    contentContainer.BackgroundTransparency = 1
    contentContainer.BorderSizePixel = 0
    contentContainer.Parent = mainFrame
    
    -- Armazenar referências
    self.mainFrame = mainFrame
    self.tabsContainer = tabsContainer
    self.tabsList = tabsList
    self.contentContainer = contentContainer
end

-- Configurar redimensionamento responsivo
function HorizontalHub:SetupResizing()
    game:GetService("RunService").RenderStepped:Connect(function()
        -- Atualizar a posição e tamanho com base no tamanho da tela
        self:UpdateSize()
    end)
end

-- Atualizar o tamanho do hub com base na tela
function LolvyUI:UpdateSize()
    local viewportSize = workspace.CurrentCamera.ViewportSize
    
    -- Ajustar tamanho baseado no tamanho da tela
    local widthRatio = math.clamp(viewportSize.X / 1920, 0.6, 1)
    local heightRatio = math.clamp(viewportSize.Y / 1080, 0.6, 1)
    
    self.mainFrame.Size = UDim2.new(0.9 * widthRatio, 0, 0.6 * heightRatio, 0)
    self.mainFrame.Position = UDim2.new(0.05 + (0.05 * (1 - widthRatio)), 0, 0.2 + (0.05 * (1 - heightRatio)), 0)
    
    -- Atualizar tamanho da lista de abas
    self.tabsList.CanvasSize = UDim2.new(0, 0, 0, (#self.tabs * 40) + (5 * (#self.tabs - 1)))
end

-- Configurar keybind para abrir/fechar o hub
function LolvyUI:SetupKeybind()
    game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == self.config.KeyBind then
            self:ToggleVisibility()
        end
    end)
end

-- Configurar suporte para dispositivos móveis
function LolvyUI:SetupMobileSupport()
    local UserInputService = game:GetService("UserInputService")
    
    if UserInputService.TouchEnabled then
        -- Criar botão móvel
        local mobileButton = Instance.new("ImageButton")
        mobileButton.Name = "MobileButton"
        mobileButton.Size = UDim2.new(0, 40, 0, 40)
        mobileButton.Position = UDim2.new(0.1, 0, 0.8, 0)
        mobileButton.BackgroundColor3 = self.config.Theme.Button
        mobileButton.Image = self.config.MobileButtonImage ~= "rbxassetid://0" and self.config.MobileButtonImage or "rbxassetid://3926307971"
        mobileButton.ImageRectOffset = Vector2.new(764, 764)
        mobileButton.ImageRectSize = Vector2.new(36, 36)
        mobileButton.ImageColor3 = self.config.Theme.Text
        mobileButton.Parent = self.gui
        
        -- Criar UI Corner para o botão
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 20)
        buttonCorner.Parent = mobileButton
        
        -- Tornar arrastável
        local dragging = false
        local dragInput
        local dragStart
        local startPos
        
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
                local delta = input.Position - dragStart
                mobileButton.Position = UDim2.new(
                    startPos.X.Scale, 
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end)
        
        -- Adicionar evento de clique para abrir/fechar o hub
        mobileButton.Activated:Connect(function()
            self:ToggleVisibility()
        end)
        
        self.mobileButton = mobileButton
    end
end

-- Alternar a visibilidade do hub
function LolvyUI:ToggleVisibility()
    self.visible = not self.visible
    self.mainFrame.Visible = self.visible
    self.titleLabel.Visible = self.visible
end

-- Adicionar uma nova aba
function LolvyUI:AddTab(tabName, icon)
    -- Verificar se a aba já existe
    for _, tab in ipairs(self.tabs) do
        if tab.name == tabName then
            return tab
        end
    end
    
    -- Criar botão de aba
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
    
    -- Adicionar ícone se fornecido
    if icon then
        local iconImage = Instance.new("ImageLabel")
        iconImage.Size = UDim2.new(0, 16, 0, 16)
        iconImage.Position = UDim2.new(0, 10, 0.5, -8)
        iconImage.BackgroundTransparency = 1
        iconImage.Image = icon
        iconImage.Parent = tabButton
        
        -- Ajustar o texto para acomodar o ícone
        tabButton.TextXAlignment = Enum.TextXAlignment.Right
    end
    
    -- Arredondar cantos
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = tabButton
    
    -- Criar contêiner de conteúdo para esta aba
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Name = tabName .. "Content"
    contentFrame.Size = UDim2.new(1, -20, 1, -20)
    contentFrame.Position = UDim2.new(0, 10, 0, 10)
    contentFrame.BackgroundTransparency = 1
    contentFrame.ScrollBarThickness = 4
    contentFrame.ScrollBarImageColor3 = self.config.Theme.ToggleOn
    contentFrame.BorderSizePixel = 0
    contentFrame.Visible = false
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0) -- Será atualizado dinamicamente
    contentFrame.Parent = self.contentContainer
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 10)
    contentLayout.Parent = contentFrame
    
    -- Atualizar o layout automaticamente
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        contentFrame.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
    end)
    
    -- Criar nova aba
    local tab = {
        name = tabName,
        button = tabButton,
        contentFrame = contentFrame,
        elements = {},
        elementCount = 0
    }
    
    -- Adicionar a aba à lista
    table.insert(self.tabs, tab)
    
    -- Configurar evento de clique
    tabButton.Activated:Connect(function()
        self:SelectTab(tabName)
    end)
    
    -- Se for a primeira aba, selecioná-la automaticamente
    if #self.tabs == 1 then
        self:SelectTab(tabName)
    end
    
    -- Atualizar o tamanho
    self:UpdateSize()
    
    return tab
end

-- Selecionar uma aba
function LolvyUI:SelectTab(tabName)
    -- Esconder todas as abas
    for _, tab in ipairs(self.tabs) do
        tab.contentFrame.Visible = false
        tab.button.BackgroundColor3 = self.config.Theme.TabUnselected
    end
    
    -- Mostrar a aba selecionada
    for _, tab in ipairs(self.tabs) do
        if tab.name == tabName then
            tab.contentFrame.Visible = true
            tab.button.BackgroundColor3 = self.config.Theme.TabSelected
            self.currentTab = tab
            break
        end
    end
end

-- Adicionar separador ao conteúdo
function LolvyUI:AddDivider(tabName, text)
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

-- Adicionar botão
function LolvyUI:AddButton(tabName, buttonText, callback)
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
    
    -- Arredondar cantos
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = button
    
    -- Efeito de hover
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = self.config.Theme.ButtonHover
    end)
    
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = self.config.Theme.Button
    end)
    
    -- Conectar callback
    button.Activated:Connect(function()
        if typeof(callback) == "function" then
            callback()
        end
    end)
    
    tab.elementCount = tab.elementCount + 1
    return button
end

-- Adicionar toggle
function LolvyUI:AddToggle(tabName, toggleText, default, callback)
    local tab = self:GetTab(tabName)
    if not tab then return nil end
    
    -- Estado inicial
    local toggled = default or false
    
    -- Container
    local container = Instance.new("Frame")
    container.Name = "Toggle" .. tab.elementCount
    container.Size = UDim2.new(1, 0, 0, 35)
    container.BackgroundTransparency = 1
    container.LayoutOrder = tab.elementCount
    container.Parent = tab.contentFrame
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(0.7, -10, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = toggleText
    label.TextColor3 = self.config.Theme.Text
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    -- Botão de toggle
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
    
    -- Arredondar cantos
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = toggleButton
    
    -- Função para atualizar o toggle
    local function updateToggle()
        toggled = not toggled
        toggleButton.BackgroundColor3 = toggled and self.config.Theme.ToggleOn or self.config.Theme.Button
        toggleButton.Text = toggled and "ON" or "OFF"
        
        if typeof(callback) == "function" then
            callback(toggled)
        end
    end
    
    -- Conectar callback
    toggleButton.Activated:Connect(updateToggle)
    
    -- API para o toggle
    local toggleAPI = {
        SetValue = function(value)
            if toggled ~= value then
                toggled = not toggled -- Inverter para que updateToggle funcione corretamente
                updateToggle()
            end
        },
        GetValue = function()
            return toggled
        }
    }
    
    tab.elementCount = tab.elementCount + 1
    return toggleAPI
end

-- Adicionar campo de entrada numérica
function LolvyUI:AddNumberInput(tabName, labelText, default, min, max, callback)
    local tab = self:GetTab(tabName)
    if not tab then return nil end
    
    -- Valores padrão
    default = default or 0
    min = min or -math.huge
    max = max or math.huge
    
    -- Container
    local container = Instance.new("Frame")
    container.Name = "NumberInput" .. tab.elementCount
    container.Size = UDim2.new(1, 0, 0, 35)
    container.BackgroundTransparency = 1
    container.LayoutOrder = tab.elementCount
    container.Parent = tab.contentFrame
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(0.5, -10, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = self.config.Theme.Text
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    -- Campo de entrada
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
    
    -- Arredondar cantos
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = inputBox
    
    -- Validar entrada
    inputBox.FocusLost:Connect(function(enterPressed)
        local inputValue = tonumber(inputBox.Text)
        
        if not inputValue then
            inputBox.Text = tostring(default)
            return
        end
        
        -- Limitar ao intervalo min/max
        inputValue = math.clamp(inputValue, min, max)
        inputBox.Text = tostring(inputValue)
        
        if typeof(callback) == "function" then
            callback(inputValue)
        end
    end)
    
    -- API para o campo numérico
    local numberInputAPI = {
        SetValue = function(value)
            if not tonumber(value) then return end
            value = math.clamp(tonumber(value), min, max)
            inputBox.Text = tostring(value)
            
            if typeof(callback) == "function" then
                callback(value)
            end
        },
        GetValue = function()
            return tonumber(inputBox.Text) or default
        }
    }
    
    tab.elementCount = tab.elementCount + 1
    return numberInputAPI
end

-- Adicionar campo de entrada de texto
function LolvyUI:AddTextInput(tabName, labelText, default, placeholder, callback)
    local tab = self:GetTab(tabName)
    if not tab then return nil end
    
    -- Valores padrão
    default = default or ""
    placeholder = placeholder or "Digite aqui..."
    
    -- Container
    local container = Instance.new("Frame")
    container.Name = "TextInput" .. tab.elementCount
    container.Size = UDim2.new(1, 0, 0, 35)
    container.BackgroundTransparency = 1
    container.LayoutOrder = tab.elementCount
    container.Parent = tab.contentFrame
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(0.4, -10, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = self.config.Theme.Text
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    -- Campo de entrada
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
    
-- Callback quando o foco é perdido
    inputBox.FocusLost:Connect(function(enterPressed)
        if typeof(callback) == "function" then
            callback(inputBox.Text)
        end
    end)
    
    -- API para o campo de texto
    local textInputAPI = {
        SetValue = function(value)
            inputBox.Text = tostring(value)
            
            if typeof(callback) == "function" then
                callback(inputBox.Text)
            end
        },
        GetValue = function()
            return inputBox.Text
        }
    }
    
    tab.elementCount = tab.elementCount + 1
    return textInputAPI
end

-- Adicionar label
function LolvyUI:AddLabel(tabName, labelText)
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
    
    -- API para o label
    local labelAPI = {
        SetText = function(text)
            label.Text = text
        },
        GetText = function()
            return label.Text
        }
    }
    
    tab.elementCount = tab.elementCount + 1
    return labelAPI
end

-- Sistema de notificação
function HorizontalHub:Notify(title, message, duration, notifType)
    -- Configurações padrão
    title = title or "Notificação"
    message = message or ""
    duration = duration or 5
    notifType = notifType or "info" -- info, success, error, warning
    
    -- Definir cor com base no tipo
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
    
    -- Criar notificação
    local notificationFrame = Instance.new("Frame")
    notificationFrame.Name = "Notification"
    notificationFrame.Size = UDim2.new(0, 250, 0, 80)
    notificationFrame.Position = UDim2.new(1, 20, 0.5 + (#self.notifications * 0.1), 0)
    notificationFrame.BackgroundColor3 = self.config.Theme.Background
    notificationFrame.BorderSizePixel = 0
    notificationFrame.Parent = self.gui
    
    -- Arredondar cantos
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = notificationFrame
    
    -- Barra colorida
    local colorBar = Instance.new("Frame")
    colorBar.Name = "ColorBar"
    colorBar.Size = UDim2.new(0, 5, 1, 0)
    colorBar.Position = UDim2.new(0, 0, 0, 0)
    colorBar.BackgroundColor3 = notifColor
    colorBar.BorderSizePixel = 0
    colorBar.Parent = notificationFrame
    
    local colorBarCorner = Instance.new("UICorner")
    colorBarCorner.CornerRadius = UDim.new(0, 6)
    colorBarCorner.Parent = colorBar
    
    -- Título
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
    
    -- Mensagem
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
    
    -- Botão de fechar
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
    
    -- Adicionar à lista de notificações
    table.insert(self.notifications, notificationFrame)
    
    -- Ajustar posições
    self:UpdateNotificationPositions()
    
    -- Animação de entrada
    notificationFrame:TweenPosition(
        UDim2.new(1, -270, notificationFrame.Position.Y.Scale, 0),
        Enum.EasingDirection.Out,
        Enum.EasingStyle.Quart,
        0.5,
        true
    )
    
    -- Função para remover a notificação
    local function removeNotification()
        -- Remover da lista
        for i, notif in ipairs(self.notifications) do
            if notif == notificationFrame then
                table.remove(self.notifications, i)
                break
            end
        end
        
        -- Animação de saída
        notificationFrame:TweenPosition(
            UDim2.new(1, 20, notificationFrame.Position.Y.Scale, 0),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quart,
            0.5,
            true,
            function()
                notificationFrame:Destroy()
                self:UpdateNotificationPositions()
            end
        )
    end
    
    -- Configurar botão de fechar
    closeButton.Activated:Connect(removeNotification)
    
    -- Auto-fechar após a duração
    task.delay(duration, function()
        if notificationFrame and notificationFrame.Parent then
            removeNotification()
        end
    end)
    
    return notificationFrame
end

-- Atualizar posições das notificações
function LolvyUI:UpdateNotificationPositions()
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

-- Obter uma aba por nome
function LolvyUI:GetTab(tabName)
    for _, tab in ipairs(self.tabs) do
        if tab.name == tabName then
            return tab
        end
    end
    return nil
end

-- Destruir o hub
function LolvyUI:Destroy()
    if self.gui then
        self.gui:Destroy()
    end
end

return LolvyUI
