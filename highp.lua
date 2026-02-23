--// ModernUI Library for Roblox Executors
--// Tema: Rounded Box dengan Search Bar Center & Horizontal Tabs
--// Author: Custom UI Library

local ModernUI = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

--// Settings & Theme
local Theme = {
    Background = Color3.fromRGB(25, 25, 30),
    Secondary = Color3.fromRGB(35, 35, 40),
    Accent = Color3.fromRGB(88, 101, 242), -- Discord Blue
    AccentHover = Color3.fromRGB(71, 82, 196),
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(150, 150, 150),
    Border = Color3.fromRGB(50, 50, 55),
    Success = Color3.fromRGB(59, 165, 93),
    Error = Color3.fromRGB(237, 66, 69),
    Warning = Color3.fromRGB(250, 168, 26),
    CornerRadius = UDim.new(0, 12),
    TabCornerRadius = UDim.new(0, 8),
    ButtonCornerRadius = UDim.new(0, 8),
    Padding = 20
}

--// Utility Functions
local function Create(instanceType, properties)
    local instance = Instance.new(instanceType)
    for prop, value in pairs(properties or {}) do
        instance[prop] = value
    end
    return instance
end

local function Tween(instance, properties, duration, easingStyle, easingDirection)
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(duration or 0.3, easingStyle or Enum.EasingStyle.Quart, easingDirection or Enum.EasingDirection.Out),
        properties
    )
    tween:Play()
    return tween
end

local function MakeDraggable(frame, handle)
    local dragging = false
    local dragInput, dragStart, startPos
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

--// Main Window Creation
function ModernUI:CreateWindow(config)
    config = config or {}
    local Window = {
        Tabs = {},
        CurrentTab = nil,
        TabCount = 0,
        Opened = false
    }
    
    --// ScreenGui
    local ScreenGui = Create("ScreenGui", {
        Name = "ModernUI_" .. (config.Title or "Executor"),
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })
    
    --// Main Container (Rounded Box)
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 700, 0, 450),
        Position = UDim2.new(0.5, -350, 0.5, -225),
        ClipsDescendants = true
    })
    
    local MainCorner = Create("UICorner", {
        CornerRadius = Theme.CornerRadius,
        Parent = MainFrame
    })
    
    --// Shadow Effect
    local Shadow = Create("ImageLabel", {
        Name = "Shadow",
        Parent = ScreenGui,
        BackgroundTransparency = 1,
        Image = "rbxassetid://5554236805",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.6,
        Position = UDim2.new(0.5, -360, 0.5, -235),
        Size = UDim2.new(0, 720, 0, 470),
        ZIndex = -1
    })
    
    --// Top Bar (Draggable)
    local TopBar = Create("Frame", {
        Name = "TopBar",
        Parent = MainFrame,
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 50)
    })
    
    --// Search Bar (Centered Title/Search)
    local SearchContainer = Create("Frame", {
        Name = "SearchContainer",
        Parent = TopBar,
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 300, 0, 32),
        Position = UDim2.new(0.5, -150, 0.5, -16)
    })
    
    local SearchCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 16),
        Parent = SearchContainer
    })
    
    local SearchStroke = Create("UIStroke", {
        Color = Theme.Border,
        Thickness = 1,
        Parent = SearchContainer
    })
    
    local SearchIcon = Create("ImageLabel", {
        Name = "SearchIcon",
        Parent = SearchContainer,
        BackgroundTransparency = 1,
        Image = "rbxassetid://3605509925",
        ImageColor3 = Theme.TextDark,
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 12, 0.5, -8)
    })
    
    local SearchBox = Create("TextBox", {
        Name = "SearchBox",
        Parent = SearchContainer,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 32, 0, 0),
        Font = Enum.Font.Gotham,
        Text = config.Title or "Modern UI",
        TextColor3 = Theme.Text,
        TextSize = 14,
        ClearTextOnFocus = false,
        PlaceholderText = "Search...",
        PlaceholderColor3 = Theme.TextDark
    })
    
    --// Window Controls
    local CloseButton = Create("TextButton", {
        Name = "Close",
        Parent = TopBar,
        BackgroundColor3 = Theme.Error,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(1, -20, 0.5, -6),
        Text = ""
    })
    
    local CloseCorner = Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = CloseButton
    })
    
    local MinimizeButton = Create("TextButton", {
        Name = "Minimize",
        Parent = TopBar,
        BackgroundColor3 = Theme.Warning,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(1, -40, 0.5, -6),
        Text = ""
    })
    
    local MinimizeCorner = Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = MinimizeButton
    })
    
    --// Tab Container (Horizontal Scrollable)
    local TabContainer = Create("Frame", {
        Name = "TabContainer",
        Parent = MainFrame,
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 45),
        Position = UDim2.new(0, 0, 0, 50),
        ClipsDescendants = true
    })
    
    local TabLayout = Create("UIListLayout", {
        Parent = TabContainer,
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8)
    })
    
    local TabPadding = Create("UIPadding", {
        Parent = TabContainer,
        PaddingLeft = UDim.new(0, 15),
        PaddingRight = UDim.new(0, 15),
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8)
    })
    
    --// Content Container
    local ContentContainer = Create("Frame", {
        Name = "ContentContainer",
        Parent = MainFrame,
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, -95),
        Position = UDim2.new(0, 0, 0, 95),
        ClipsDescendants = true
    })
    
    --// Dragging
    MakeDraggable(MainFrame, TopBar)
    
    --// Animations
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    Shadow.ImageTransparency = 1
    
    -- Open Animation
    function Window:Open()
        Window.Opened = true
        Tween(MainFrame, {Size = UDim2.new(0, 700, 0, 450), Position = UDim2.new(0.5, -350, 0.5, -225)}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        Tween(Shadow, {ImageTransparency = 0.6}, 0.5)
    end
    
    -- Close Animation
    CloseButton.MouseButton1Click:Connect(function()
        Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        Tween(Shadow, {ImageTransparency = 1}, 0.4)
        wait(0.4)
        ScreenGui:Destroy()
    end)
    
    -- Hover Effects
    CloseButton.MouseEnter:Connect(function()
        Tween(CloseButton, {BackgroundColor3 = Color3.fromRGB(255, 80, 80)}, 0.2)
    end)
    CloseButton.MouseLeave:Connect(function()
        Tween(CloseButton, {BackgroundColor3 = Theme.Error}, 0.2)
    end)
    
    MinimizeButton.MouseEnter:Connect(function()
        Tween(MinimizeButton, {BackgroundColor3 = Color3.fromRGB(255, 200, 80)}, 0.2)
    end)
    MinimizeButton.MouseLeave:Connect(function()
        Tween(MinimizeButton, {BackgroundColor3 = Theme.Warning}, 0.2)
    end)
    
    --// Tab Creation
    function Window:CreateTab(tabConfig)
        tabConfig = tabConfig or {}
        local Tab = {
            Sections = {},
            Elements = {}
        }
        
        Window.TabCount = Window.TabCount + 1
        local tabIndex = Window.TabCount
        
        -- Tab Button (Rectangle Panjang)
        local TabButton = Create("TextButton", {
            Name = "Tab_" .. (tabConfig.Name or "Tab" .. tabIndex),
            Parent = TabContainer,
            BackgroundColor3 = (tabIndex == 1) and Theme.Accent or Theme.Background,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 120, 0, 29),
            Font = Enum.Font.GothamSemibold,
            Text = tabConfig.Name or "Tab " .. tabIndex,
            TextColor3 = (tabIndex == 1) and Theme.Text or Theme.TextDark,
            TextSize = 13,
            AutoButtonColor = false,
            LayoutOrder = tabIndex
        })
        
        local TabCorner = Create("UICorner", {
            CornerRadius = Theme.TabCornerRadius,
            Parent = TabButton
        })
        
        -- Tab Content
        local TabContent = Create("ScrollingFrame", {
            Name = "Content_" .. tabConfig.Name,
            Parent = ContentContainer,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Theme.Accent,
            Visible = (tabIndex == 1),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y
        })
        
        local ContentLayout = Create("UIListLayout", {
            Parent = TabContent,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10)
        })
        
        local ContentPadding = Create("UIPadding", {
            Parent = TabContent,
            PaddingLeft = UDim.new(0, 20),
            PaddingRight = UDim.new(0, 20),
            PaddingTop = UDim.new(0, 20),
            PaddingBottom = UDim.new(0, 20)
        })
        
        --// Tab Switching Logic
        TabButton.MouseButton1Click:Connect(function()
            if Window.CurrentTab == Tab then return end
            
            -- Deactivate current tab
            if Window.CurrentTab then
                Tween(Window.CurrentTab.Button, {BackgroundColor3 = Theme.Background}, 0.3)
                Tween(Window.CurrentTab.Button, {TextColor3 = Theme.TextDark}, 0.3)
                Window.CurrentTab.Content.Visible = false
            end
            
            -- Activate new tab
            Window.CurrentTab = Tab
            Tab.Content.Visible = true
            Tween(TabButton, {BackgroundColor3 = Theme.Accent}, 0.3)
            Tween(TabButton, {TextColor3 = Theme.Text}, 0.3)
            
            -- Smooth content fade
            TabContent.BackgroundTransparency = 1
            Tween(TabContent, {BackgroundTransparency = 1}, 0.1)
        end)
        
        -- Hover effect
        TabButton.MouseEnter:Connect(function()
            if Window.CurrentTab ~= Tab then
                Tween(TabButton, {BackgroundColor3 = Theme.Border}, 0.2)
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if Window.CurrentTab ~= Tab then
                Tween(TabButton, {BackgroundColor3 = Theme.Background}, 0.2)
            end
        end)
        
        Tab.Button = TabButton
        Tab.Content = TabContent
        
        if tabIndex == 1 then
            Window.CurrentTab = Tab
        end
        
        --// Section Creation
        function Tab:CreateSection(sectionConfig)
            sectionConfig = sectionConfig or {}
            
            local Section = Create("Frame", {
                Name = "Section_" .. (sectionConfig.Name or "Section"),
                Parent = TabContent,
                BackgroundColor3 = Theme.Secondary,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 50),
                AutomaticSize = Enum.AutomaticSize.Y
            })
            
            local SectionCorner = Create("UICorner", {
                CornerRadius = Theme.CornerRadius,
                Parent = Section
            })
            
            local SectionPadding = Create("UIPadding", {
                Parent = Section,
                PaddingLeft = UDim.new(0, 15),
                PaddingRight = UDim.new(0, 15),
                PaddingTop = UDim.new(0, 15),
                PaddingBottom = UDim.new(0, 15)
            })
            
            if sectionConfig.Name then
                local SectionTitle = Create("TextLabel", {
                    Name = "Title",
                    Parent = Section,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = Enum.Font.GothamBold,
                    Text = sectionConfig.Name,
                    TextColor3 = Theme.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local ElementsContainer = Create("Frame", {
                    Name = "Elements",
                    Parent = Section,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 0, 25),
                    AutomaticSize = Enum.AutomaticSize.Y
                })
                
                local ElementsLayout = Create("UIListLayout", {
                    Parent = ElementsContainer,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 8)
                })
                
                Section.Elements = ElementsContainer
            end
            
            --// Element Creation Functions
            function Section:AddButton(buttonConfig)
                buttonConfig = buttonConfig or {}
                
                local Button = Create("TextButton", {
                    Name = "Button",
                    Parent = Section.Elements or Section,
                    BackgroundColor3 = Theme.Accent,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 35),
                    Font = Enum.Font.GothamSemibold,
                    Text = buttonConfig.Name or "Button",
                    TextColor3 = Theme.Text,
                    TextSize = 13,
                    AutoButtonColor = false
                })
                
                local ButtonCorner = Create("UICorner", {
                    CornerRadius = Theme.ButtonCornerRadius,
                    Parent = Button
                })
                
                -- Hover & Click Effects
                Button.MouseEnter:Connect(function()
                    Tween(Button, {BackgroundColor3 = Theme.AccentHover}, 0.2)
                end)
                
                Button.MouseLeave:Connect(function()
                    Tween(Button, {BackgroundColor3 = Theme.Accent}, 0.2)
                end)
                
                Button.MouseButton1Down:Connect(function()
                    Tween(Button, {Size = UDim2.new(0.97, 0, 0, 35)}, 0.1)
                end)
                
                Button.MouseButton1Up:Connect(function()
                    Tween(Button, {Size = UDim2.new(1, 0, 0, 35)}, 0.1)
                end)
                
                Button.MouseButton1Click:Connect(function()
                    if buttonConfig.Callback then
                        buttonConfig.Callback()
                    end
                end)
                
                return Button
            end
            
            function Section:AddToggle(toggleConfig)
                toggleConfig = toggleConfig or {}
                local toggled = toggleConfig.Default or false
                
                local ToggleFrame = Create("Frame", {
                    Name = "Toggle",
                    Parent = Section.Elements or Section,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 30)
                })
                
                local ToggleLabel = Create("TextLabel", {
                    Name = "Label",
                    Parent = ToggleFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -50, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = toggleConfig.Name or "Toggle",
                    TextColor3 = Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local ToggleButton = Create("Frame", {
                    Name = "ToggleButton",
                    Parent = ToggleFrame,
                    BackgroundColor3 = toggled and Theme.Accent or Theme.Border,
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, 40, 0, 20),
                    Position = UDim2.new(1, -40, 0.5, -10)
                })
                
                local ToggleCorner = Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = ToggleButton
                })
                
                local ToggleCircle = Create("Frame", {
                    Name = "Circle",
                    Parent = ToggleButton,
                    BackgroundColor3 = Theme.Text,
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                })
                
                local CircleCorner = Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = ToggleCircle
                })
                
                local ClickArea = Create("TextButton", {
                    Name = "ClickArea",
                    Parent = ToggleFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = ""
                })
                
                local function UpdateToggle()
                    toggled = not toggled
                    Tween(ToggleButton, {BackgroundColor3 = toggled and Theme.Accent or Theme.Border}, 0.3)
                    Tween(ToggleCircle, {Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}, 0.3)
                    
                    if toggleConfig.Callback then
                        toggleConfig.Callback(toggled)
                    end
                end
                
                ClickArea.MouseButton1Click:Connect(UpdateToggle)
                
                return ToggleFrame
            end
            
            function Section:AddSlider(sliderConfig)
                sliderConfig = sliderConfig or {}
                local min = sliderConfig.Min or 0
                local max = sliderConfig.Max or 100
                local default = math.clamp(sliderConfig.Default or min, min, max)
                
                local SliderFrame = Create("Frame", {
                    Name = "Slider",
                    Parent = Section.Elements or Section,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 45)
                })
                
                local SliderLabel = Create("TextLabel", {
                    Name = "Label",
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.5, 0, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = sliderConfig.Name or "Slider",
                    TextColor3 = Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local ValueLabel = Create("TextLabel", {
                    Name = "Value",
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.5, 0, 0, 20),
                    Position = UDim2.new(0.5, 0, 0, 0),
                    Font = Enum.Font.GothamBold,
                    Text = tostring(default),
                    TextColor3 = Theme.Accent,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Right
                })
                
                local SliderBg = Create("Frame", {
                    Name = "Background",
                    Parent = SliderFrame,
                    BackgroundColor3 = Theme.Border,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 6),
                    Position = UDim2.new(0, 0, 0, 30)
                })
                
                local BgCorner = Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = SliderBg
                })
                
                local SliderFill = Create("Frame", {
                    Name = "Fill",
                    Parent = SliderBg,
                    BackgroundColor3 = Theme.Accent,
                    BorderSizePixel = 0,
                    Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
                })
                
                local FillCorner = Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = SliderFill
                })
                
                local SliderKnob = Create("Frame", {
                    Name = "Knob",
                    Parent = SliderFill,
                    BackgroundColor3 = Theme.Text,
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, 14, 0, 14),
                    Position = UDim2.new(1, -7, 0.5, -7)
                })
                
                local KnobCorner = Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = SliderKnob
                })
                
                -- Slider Logic
                local dragging = false
                
                local function UpdateSlider(input)
                    local pos = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
                    local value = math.floor(min + (max - min) * pos)
                    
                    SliderFill.Size = UDim2.new(pos, 0, 1, 0)
                    ValueLabel.Text = tostring(value)
                    
                    if sliderConfig.Callback then
                        sliderConfig.Callback(value)
                    end
                end
                
                SliderBg.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        UpdateSlider(input)
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        UpdateSlider(input)
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                return SliderFrame
            end
            
            function Section:AddDropdown(dropdownConfig)
                dropdownConfig = dropdownConfig or {}
                local options = dropdownConfig.Options or {}
                local selected = dropdownConfig.Default or (options[1] or "Select...")
                
                local DropdownFrame = Create("Frame", {
                    Name = "Dropdown",
                    Parent = Section.Elements or Section,
                    BackgroundColor3 = Theme.Background,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 35),
                    ClipsDescendants = true
                })
                
                local DropdownCorner = Create("UICorner", {
                    CornerRadius = Theme.ButtonCornerRadius,
                    Parent = DropdownFrame
                })
                
                local DropdownStroke = Create("UIStroke", {
                    Color = Theme.Border,
                    Thickness = 1,
                    Parent = DropdownFrame
                })
                
                local DropdownButton = Create("TextButton", {
                    Name = "Button",
                    Parent = DropdownFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 35),
                    Font = Enum.Font.Gotham,
                    Text = selected,
                    TextColor3 = Theme.Text,
                    TextSize = 13
                })
                
                local DropdownIcon = Create("ImageLabel", {
                    Name = "Icon",
                    Parent = DropdownButton,
                    BackgroundTransparency = 1,
                    Image = "rbxassetid://3926307971",
                    ImageRectOffset = Vector2.new(324, 364),
                    ImageRectSize = Vector2.new(36, 36),
                    ImageColor3 = Theme.TextDark,
                    Size = UDim2.new(0, 20, 0, 20),
                    Position = UDim2.new(1, -25, 0.5, -10)
                })
                
                local OptionsFrame = Create("Frame", {
                    Name = "Options",
                    Parent = DropdownFrame,
                    BackgroundColor3 = Theme.Secondary,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 0, 35),
                    Visible = false
                })
                
                local OptionsLayout = Create("UIListLayout", {
                    Parent = OptionsFrame,
                    SortOrder = Enum.SortOrder.LayoutOrder
                })
                
                local isOpen = false
                
                local function ToggleDropdown()
                    isOpen = not isOpen
                    OptionsFrame.Visible = true
                    
                    if isOpen then
                        Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 35 + (#options * 30))}, 0.3)
                        Tween(DropdownIcon, {Rotation = 180}, 0.3)
                    else
                        Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 35)}, 0.3)
                        Tween(DropdownIcon, {Rotation = 0}, 0.3)
                        wait(0.3)
                        OptionsFrame.Visible = false
                    end
                end
                
                for i, option in ipairs(options) do
                    local OptionBtn = Create("TextButton", {
                        Name = option,
                        Parent = OptionsFrame,
                        BackgroundColor3 = Theme.Secondary,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 0, 30),
                        Font = Enum.Font.Gotham,
                        Text = option,
                        TextColor3 = Theme.Text,
                        TextSize = 13,
                        LayoutOrder = i
                    })
                    
                    OptionBtn.MouseEnter:Connect(function()
                        Tween(OptionBtn, {BackgroundColor3 = Theme.Border}, 0.2)
                    end)
                    
                    OptionBtn.MouseLeave:Connect(function()
                        Tween(OptionBtn, {BackgroundColor3 = Theme.Secondary}, 0.2)
                    end)
                    
                    OptionBtn.MouseButton1Click:Connect(function()
                        DropdownButton.Text = option
                        ToggleDropdown()
                        if dropdownConfig.Callback then
                            dropdownConfig.Callback(option)
                        end
                    end)
                end
                
                DropdownButton.MouseButton1Click:Connect(ToggleDropdown)
                
                return DropdownFrame
            end
            
            return Section
        end
        
        table.insert(Window.Tabs, Tab)
        return Tab
    end
    
    --// Smooth Scroll for Tabs (jika lebih dari 5)
    local function UpdateTabScroll()
        if Window.TabCount > 5 then
            local totalWidth = 0
            for _, tab in ipairs(Window.Tabs) do
                totalWidth = totalWidth + 120 + 8 -- width + padding
            end
            
            -- Enable scrolling behavior
            TabContainer.ClipsDescendants = true
            
            -- Mouse wheel scroll
            TabContainer.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseWheel then
                    local currentPos = TabContainer.CanvasPosition.X
                    local newPos = math.clamp(currentPos - (input.Position.Z * 50), 0, totalWidth - TabContainer.AbsoluteSize.X)
                    
                    Tween(TabContainer, {CanvasPosition = Vector2.new(newPos, 0)}, 0.3, Enum.EasingStyle.Quart)
                end
            end)
        end
    end
    
    --// Keybind Toggle
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == (config.ToggleKey or Enum.KeyCode.RightShift) then
            MainFrame.Visible = not MainFrame.Visible
            Shadow.Visible = MainFrame.Visible
        end
    end)
    
    -- Initialize
    Window:Open()
    
    return Window
end

--// Return Library
return ModernUI
