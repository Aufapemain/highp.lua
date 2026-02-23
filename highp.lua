--// iOS Style UI Library untuk Roblox
--// Konsep: Tab kecil → membesar menggantikan base (smooth tween)
--// Professional 10/10 iPhone aesthetic

local iOSLib = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

--// iOS Design System
local iOSTheme = {
    -- Colors (iOS Style)
    Background = Color3.fromRGB(28, 28, 30),      -- iOS Dark Gray
    Card = Color3.fromRGB(44, 44, 46),            -- iOS Card Gray
    GroupedBackground = Color3.fromRGB(28, 28, 30),
    SecondarySystemFill = Color3.fromRGB(120, 120, 128),
    Label = Color3.fromRGB(255, 255, 255),        -- Primary Label
    SecondaryLabel = Color3.fromRGB(152, 152, 157),
    TertiaryLabel = Color3.fromRGB(122, 122, 126),
    Accent = Color3.fromRGB(10, 132, 255),        -- iOS Blue
    Green = Color3.fromRGB(48, 209, 88),          -- iOS Green
    Orange = Color3.fromRGB(255, 159, 10),        -- iOS Orange
    Red = Color3.fromRGB(255, 69, 58),            -- iOS Red
    Purple = Color3.fromRGB(175, 82, 222),        -- iOS Purple
    Pink = Color3.fromRGB(255, 55, 95),           -- iOS Pink
    
    -- Typography (San Francisco style)
    Font = Enum.Font.Gotham,                      -- Closest to SF Pro
    FontBold = Enum.Font.GothamBold,
    FontSemiBold = Enum.Font.GothamSemibold,
    FontMedium = Enum.Font.GothamMedium,
    
    -- Spacing (iOS 8pt grid)
    PaddingSmall = 8,
    PaddingMedium = 12,
    PaddingLarge = 16,
    PaddingXLarge = 20,
    
    -- Corner Radius (iOS style)
    RadiusSmall = UDim.new(0, 8),
    RadiusMedium = UDim.new(0, 12),
    RadiusLarge = UDim.new(0, 16),
    RadiusXLarge = UDim.new(0, 20),
    RadiusFull = UDim.new(1, 0),  -- For circles
    
    -- Animation
    AnimationFast = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    AnimationNormal = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    AnimationSlow = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    AnimationSpring = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
}

--// Utility Functions
local function Create(instanceType, properties)
    local instance = Instance.new(instanceType)
    for prop, value in pairs(properties or {}) do
        instance[prop] = value
    end
    return instance
end

local function Tween(instance, tweenInfo, properties)
    local tween = TweenService:Create(instance, tweenInfo, properties)
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

--// iOS Library Main
function iOSLib:CreateWindow(config)
    config = config or {}
    local Window = {
        Tabs = {},
        CurrentTab = nil,
        TabCount = 0,
        IsTabOpen = false,
        BaseFrame = nil,
        ActiveTabFrame = nil
    }
    
    --// ScreenGui
    local ScreenGui = Create("ScreenGui", {
        Name = "iOSLib_" .. (config.Title or "App"),
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })
    
    --// Main Container (iPhone style rounded rectangle)
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        BackgroundColor3 = iOSTheme.Background,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 380, 0, 680),
        Position = UDim2.new(0.5, -190, 0.5, -340),
        ClipsDescendants = true
    })
    
    -- iOS style large corner radius
    local MainCorner = Create("UICorner", {
        CornerRadius = iOSTheme.RadiusXLarge,
        Parent = MainFrame
    })
    
    --// iOS Status Bar (Time, Battery)
    local StatusBar = Create("Frame", {
        Name = "StatusBar",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 44),
        Position = UDim2.new(0, 0, 0, 0)
    })
    
    local TimeLabel = Create("TextLabel", {
        Name = "Time",
        Parent = StatusBar,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 100, 0, 44),
        Position = UDim2.new(0.5, -50, 0, 0),
        Font = iOSTheme.FontBold,
        Text = os.date("%H:%M"),
        TextColor3 = iOSTheme.Label,
        TextSize = 15
    })
    
    -- Update time
    spawn(function()
        while wait(60) do
            TimeLabel.Text = os.date("%H:%M")
        end
    end)
    
    --// Navigation Bar (Title + Buttons)
    local NavBar = Create("Frame", {
        Name = "NavBar",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 52),
        Position = UDim2.new(0, 0, 0, 44)
    })
    
    local NavTitle = Create("TextLabel", {
        Name = "Title",
        Parent = NavBar,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 20, 0, 0),
        Font = iOSTheme.FontBold,
        Text = config.Title or "Settings",
        TextColor3 = iOSTheme.Label,
        TextSize = 28,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    --// Base Container (Horizontal Scroll untuk Tab Icons)
    local BaseContainer = Create("Frame", {
        Name = "BaseContainer",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 140),
        Position = UDim2.new(0, 0, 0, 110)
    })
    
    -- Base background (kotak rounded horizontal)
    local BaseFrame = Create("Frame", {
        Name = "BaseFrame",
        Parent = BaseContainer,
        BackgroundColor3 = iOSTheme.Card,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 20, 0, 0)
    })
    
    local BaseCorner = Create("UICorner", {
        CornerRadius = iOSTheme.RadiusLarge,
        Parent = BaseFrame
    })
    
    Window.BaseFrame = BaseFrame
    
    --// Tab Grid Layout (2x3 grid untuk 6 tab maksimal)
    local TabGrid = Create("UIGridLayout", {
        Parent = BaseFrame,
        SortOrder = Enum.SortOrder.LayoutOrder,
        CellSize = UDim2.new(0, 90, 0, 90),
        CellPadding = UDim2.new(0, 10, 0, 10),
        StartCorner = Enum.StartCorner.TopLeft,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center
    })
    
    local GridPadding = Create("UIPadding", {
        Parent = BaseFrame,
        PaddingTop = UDim.new(0, 15),
        PaddingBottom = UDim.new(0, 15),
        PaddingLeft = UDim.new(0, 15),
        PaddingRight = UDim.new(0, 15)
    })
    
    --// Active Tab Container (Full screen overlay)
    local ActiveTabContainer = Create("Frame", {
        Name = "ActiveTabContainer",
        Parent = MainFrame,
        BackgroundColor3 = iOSTheme.Background,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        Visible = false,
        ZIndex = 100
    })
    
    local ActiveTabCorner = Create("UICorner", {
        CornerRadius = iOSTheme.RadiusXLarge,
        Parent = ActiveTabContainer
    })
    
    -- Close button (X) di kanan atas
    local CloseButton = Create("TextButton", {
        Name = "CloseButton",
        Parent = ActiveTabContainer,
        BackgroundColor3 = iOSTheme.Card,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(1, -48, 0, 50),
        ZIndex = 101,
        Text = "✕",
        Font = iOSTheme.FontBold,
        TextColor3 = iOSTheme.Accent,
        TextSize = 18
    })
    
    local CloseCorner = Create("UICorner", {
        CornerRadius = iOSTheme.RadiusFull,
        Parent = CloseButton
    })
    
    -- Active Tab Title (Large iOS style)
    local ActiveTitle = Create("TextLabel", {
        Name = "ActiveTitle",
        Parent = ActiveTabContainer,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -80, 0, 40),
        Position = UDim2.new(0, 20, 0, 50),
        Font = iOSTheme.FontBold,
        Text = "",
        TextColor3 = iOSTheme.Label,
        TextSize = 32,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 101
    })
    
    -- Content area untuk tab yang aktif
    local TabContentArea = Create("ScrollingFrame", {
        Name = "TabContentArea",
        Parent = ActiveTabContainer,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -40, 1, -140),
        Position = UDim2.new(0, 20, 0, 100),
        ScrollBarThickness = 0,  -- iOS style hidden scrollbar
        ZIndex = 101,
        ClipsDescendants = true,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    })
    
    local ContentLayout = Create("UIListLayout", {
        Parent = TabContentArea,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 12)
    })
    
    Window.ActiveTabFrame = ActiveTabContainer
    
    --// Drag Support
    MakeDraggable(MainFrame, StatusBar)
    
    --// Animations - Entrance
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    
    function Window:Open()
        Tween(MainFrame, iOSTheme.AnimationSpring, {
            Size = UDim2.new(0, 380, 0, 680),
            Position = UDim2.new(0.5, -190, 0.5, -340)
        })
    end
    
    -- Close active tab animation
    local function CloseActiveTab()
        if not Window.IsTabOpen or not Window.CurrentTab then return end
        
        local tab = Window.CurrentTab
        local originalPos = tab.OriginalPosition
        
        -- Animate title out
        Tween(ActiveTitle, iOSTheme.AnimationFast, {TextTransparency = 1})
        
        -- Animate content out
        for _, child in pairs(TabContentArea:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextLabel") then
                Tween(child, iOSTheme.AnimationFast, {Position = UDim2.new(0, 0, 0, 50), Transparency = 1})
            end
        end
        
        wait(0.1)
        
        -- Shrink back to icon position
        Tween(ActiveTabContainer, iOSTheme.AnimationSlow, {
            Size = UDim2.new(0, 90, 0, 90),
            Position = UDim2.new(0, originalPos.X, 0, originalPos.Y)
        })
        
        -- Fade out corner radius untuk jadi rounded square lagi
        Tween(ActiveTabCorner, iOSTheme.AnimationSlow, {CornerRadius = iOSTheme.RadiusMedium})
        
        wait(0.3)
        
        ActiveTabContainer.Visible = false
        Window.IsTabOpen = false
        Window.CurrentTab = nil
        NavTitle.Text = config.Title or "Settings"
        
        -- Clear content
        for _, child in pairs(TabContentArea:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextLabel") then
                child:Destroy()
            end
        end
    end
    
    CloseButton.MouseButton1Click:Connect(CloseActiveTab)
    
    --// Tab Creation
    function Window:CreateTab(tabConfig)
        tabConfig = tabConfig or {}
        Window.TabCount = Window.TabCount + 1
        local tabIndex = Window.TabCount
        
        -- Icon colors (iOS app colors)
        local iconColors = {
            iOSTheme.Accent,    -- Blue
            iOSTheme.Green,     -- Green
            iOSTheme.Orange,    -- Orange
            iOSTheme.Red,       -- Red
            iOSTheme.Purple,    -- Purple
            iOSTheme.Pink       -- Pink
        }
        local iconColor = tabConfig.Color or iconColors[((tabIndex - 1) % 6) + 1]
        
        -- Tab Icon Button (kotak rounded seperti app iOS)
        local TabButton = Create("TextButton", {
            Name = "Tab_" .. (tabConfig.Name or "Tab" .. tabIndex),
            Parent = BaseFrame,
            BackgroundColor3 = iconColor,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 90, 0, 90),
            LayoutOrder = tabIndex,
            Text = "",
            AutoButtonColor = false,
            ClipsDescendants = true
        })
        
        local TabCorner = Create("UICorner", {
            CornerRadius = iOSTheme.RadiusMedium,
            Parent = TabButton
        })
        
        -- App Icon (Symbol)
        local IconLabel = Create("TextLabel", {
            Name = "Icon",
            Parent = TabButton,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0.6, 0),
            Position = UDim2.new(0, 0, 0.1, 0),
            Font = iOSTheme.FontBold,
            Text = tabConfig.Icon or "◆",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 32,
            TextTransparency = 0.9  -- Subtle icon
        })
        
        -- App Name
        local NameLabel = Create("TextLabel", {
            Name = "Name",
            Parent = TabButton,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -10, 0.3, 0),
            Position = UDim2.new(0, 5, 0.65, 0),
            Font = iOSTheme.FontSemiBold,
            Text = tabConfig.Name or "Tab",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 13,
            TextWrapped = true
        })
        
        -- Store original position untuk animation
        local function GetAbsolutePosition()
            return TabButton.AbsolutePosition - MainFrame.AbsolutePosition
        end
        
        -- Tab Click Handler - MAGIC HAPPENS HERE
        TabButton.MouseButton1Click:Connect(function()
            if Window.IsTabOpen then return end
            
            Window.IsTabOpen = true
            Window.CurrentTab = {
                Name = tabConfig.Name or "Tab",
                OriginalPosition = GetAbsolutePosition(),
                Color = iconColor
            }
            
            -- Update Nav Title
            NavTitle.Text = tabConfig.Name or "Tab"
            
            -- Setup Active Tab Container
            ActiveTabContainer.BackgroundColor3 = iconColor
            ActiveTitle.Text = tabConfig.Name or "Tab"
            ActiveTitle.TextTransparency = 0
            
            -- Position container exactly over the tab button
            local absPos = GetAbsolutePosition()
            ActiveTabContainer.Size = UDim2.new(0, 90, 0, 90)
            ActiveTabContainer.Position = UDim2.new(0, absPos.X, 0, absPos.Y)
            ActiveTabContainer.Visible = true
            
            -- Animate: Expand to full screen (iOS app open animation)
            Tween(ActiveTabContainer, iOSTheme.AnimationSlow, {
                Size = UDim2.new(1, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 0)
            })
            
            -- Corner radius animate to match main frame
            Tween(ActiveTabCorner, iOSTheme.AnimationSlow, {CornerRadius = iOSTheme.RadiusXLarge})
            
            -- Fade icon color to background color
            Tween(ActiveTabContainer, iOSTheme.AnimationSlow, {BackgroundColor3 = iOSTheme.Background})
            
            wait(0.3)
            
            -- Build content
            if tabConfig.Content then
                tabConfig.Content(TabContentArea)
            end
            
            -- Animate content in (staggered)
            local delay = 0
            for _, child in pairs(TabContentArea:GetChildren()) do
                if child:IsA("Frame") then
                    child.Position = UDim2.new(0, 0, 0, 20)
                    child.BackgroundTransparency = 1
                    
                    spawn(function()
                        wait(delay)
                        Tween(child, iOSTheme.AnimationNormal, {
                            Position = UDim2.new(0, 0, 0, 0),
                            BackgroundTransparency = 0
                        })
                    end)
                    
                    delay = delay + 0.05
                end
            end
        end)
        
        -- Hover effect (scale)
        TabButton.MouseEnter:Connect(function()
            Tween(TabButton, iOSTheme.AnimationFast, {Size = UDim2.new(0, 95, 0, 95)})
        end)
        
        TabButton.MouseLeave:Connect(function()
            Tween(TabButton, iOSTheme.AnimationFast, {Size = UDim2.new(0, 90, 0, 90)})
        end)
        
        return TabButton
    end
    
    --// UI Components Factory
    function iOSLib:CreateSlider(parent, config)
        config = config or {}
        
        local Container = Create("Frame", {
            Name = "SliderContainer",
            Parent = parent,
            BackgroundColor3 = iOSTheme.Card,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 80)
        })
        
        local Corner = Create("UICorner", {
            CornerRadius = iOSTheme.RadiusMedium,
            Parent = Container
        })
        
        -- Label
        local Label = Create("TextLabel", {
            Name = "Label",
            Parent = Container,
            BackgroundTransparency = 1,
            Size = UDim2.new(0.5, 0, 0, 30),
            Position = UDim2.new(0, 16, 0, 10),
            Font = iOSTheme.FontSemiBold,
            Text = config.Name or "Slider",
            TextColor3 = iOSTheme.Label,
            TextSize = 17,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        -- Value
        local ValueLabel = Create("TextLabel", {
            Name = "Value",
            Parent = Container,
            BackgroundTransparency = 1,
            Size = UDim2.new(0.5, -16, 0, 30),
            Position = UDim2.new(0.5, 0, 0, 10),
            Font = iOSTheme.FontMedium,
            Text = tostring(config.Default or config.Min or 0),
            TextColor3 = iOSTheme.Accent,
            TextSize = 17,
            TextXAlignment = Enum.TextXAlignment.Right
        })
        
        -- Track Background
        local TrackBg = Create("Frame", {
            Name = "TrackBg",
            Parent = Container,
            BackgroundColor3 = iOSTheme.SecondarySystemFill,
            BorderSizePixel = 0,
            Size = UDim2.new(1, -32, 0, 4),
            Position = UDim2.new(0, 16, 0, 50)
        })
        
        local TrackCorner = Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = TrackBg
        })
        
        -- Fill
        local min = config.Min or 0
        local max = config.Max or 100
        local default = math.clamp(config.Default or min, min, max)
        local fillScale = (default - min) / (max - min)
        
        local Fill = Create("Frame", {
            Name = "Fill",
            Parent = TrackBg,
            BackgroundColor3 = iOSTheme.Accent,
            BorderSizePixel = 0,
            Size = UDim2.new(fillScale, 0, 1, 0)
        })
        
        local FillCorner = Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = Fill
        })
        
        -- Thumb (iOS style circle)
        local Thumb = Create("Frame", {
            Name = "Thumb",
            Parent = Fill,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0,
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(1, -10, 0.5, -10),
            ZIndex = 2
        })
        
        local ThumbCorner = Create("UICorner", {
            CornerRadius = iOSTheme.RadiusFull,
            Parent = Thumb
        })
        
        -- Shadow untuk thumb
        local ThumbShadow = Create("ImageLabel", {
            Name = "Shadow",
            Parent = Thumb,
            BackgroundTransparency = 1,
            Image = "rbxassetid://5554236805",
            ImageColor3 = Color3.fromRGB(0, 0, 0),
            ImageTransparency = 0.7,
            Size = UDim2.new(1.5, 0, 1.5, 0),
            Position = UDim2.new(-0.25, 0, -0.25, 0),
            ZIndex = 1
        })
        
        -- Interaction
        local dragging = false
        
        local function UpdateSlider(input)
            local trackAbs = TrackBg.AbsolutePosition.X
            local trackSize = TrackBg.AbsoluteSize.X
            local pos = math.clamp((input.Position.X - trackAbs) / trackSize, 0, 1)
            local value = math.floor(min + (max - min) * pos)
            
            Fill.Size = UDim2.new(pos, 0, 1, 0)
            ValueLabel.Text = tostring(value)
            
            if config.Callback then
                config.Callback(value)
            end
        end
        
        TrackBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                UpdateSlider(input)
                
                -- Scale thumb up (iOS feedback)
                Tween(Thumb, iOSTheme.AnimationFast, {Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(1, -12, 0.5, -12)})
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                UpdateSlider(input)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
                
                -- Scale thumb down
                Tween(Thumb, iOSTheme.AnimationFast, {Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(1, -10, 0.5, -10)})
            end
        end)
        
        return Container
    end
    
    function iOSLib:CreateToggle(parent, config)
        config = config or {}
        
        local Container = Create("Frame", {
            Name = "ToggleContainer",
            Parent = parent,
            BackgroundColor3 = iOSTheme.Card,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 55)
        })
        
        local Corner = Create("UICorner", {
            CornerRadius = iOSTheme.RadiusMedium,
            Parent = Container
        })
        
        -- Label
        local Label = Create("TextLabel", {
            Name = "Label",
            Parent = Container,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -80, 1, 0),
            Position = UDim2.new(0, 16, 0, 0),
            Font = iOSTheme.FontSemiBold,
            Text = config.Name or "Toggle",
            TextColor3 = iOSTheme.Label,
            TextSize = 17,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        -- iOS Style Switch
        local SwitchBg = Create("Frame", {
            Name = "Switch",
            Parent = Container,
            BackgroundColor3 = config.Default and iOSTheme.Green or iOSTheme.SecondarySystemFill,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 51, 0, 31),
            Position = UDim2.new(1, -67, 0.5, -15.5)
        })
        
        local SwitchCorner = Create("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = SwitchBg
        })
        
        -- Circle
        local Circle = Create("Frame", {
            Name = "Circle",
            Parent = SwitchBg,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0,
            Size = UDim2.new(0, 27, 0, 27),
            Position = config.Default and UDim2.new(1, -29, 0.5, -13.5) or UDim2.new(0, 2, 0.5, -13.5)
        })
        
        local CircleCorner = Create("UICorner", {
            CornerRadius = iOSTheme.RadiusFull,
            Parent = Circle
        })
        
        -- Shadow
        local CircleShadow = Create("ImageLabel", {
            Name = "Shadow",
            Parent = Circle,
            BackgroundTransparency = 1,
            Image = "rbxassetid://5554236805",
            ImageColor3 = Color3.fromRGB(0, 0, 0),
            ImageTransparency = 0.6,
            Size = UDim2.new(1.2, 0, 1.2, 0),
            Position = UDim2.new(-0.1, 0, -0.1, 0),
            ZIndex = -1
        })
        
        local toggled = config.Default or false
        
        local ClickArea = Create("TextButton", {
            Name = "ClickArea",
            Parent = Container,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Text = ""
        })
        
        ClickArea.MouseButton1Click:Connect(function()
            toggled = not toggled
            
            -- Animate switch (iOS style spring)
            Tween(SwitchBg, iOSTheme.AnimationNormal, {BackgroundColor3 = toggled and iOSTheme.Green or iOSTheme.SecondarySystemFill})
            Tween(Circle, iOSTheme.AnimationSpring, {
                Position = toggled and UDim2.new(1, -29, 0.5, -13.5) or UDim2.new(0, 2, 0.5, -13.5)
            })
            
            if config.Callback then
                config.Callback(toggled)
            end
        end)
        
        return Container
    end
    
    function iOSLib:CreateButton(parent, config)
        config = config or {}
        
        local Button = Create("TextButton", {
            Name = "Button",
            Parent = parent,
            BackgroundColor3 = iOSTheme.Accent,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 50),
            Font = iOSTheme.FontSemiBold,
            Text = config.Name or "Button",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 17,
            AutoButtonColor = false
        })
        
        local Corner = Create("UICorner", {
            CornerRadius = iOSTheme.RadiusMedium,
            Parent = Button
        })
        
        -- iOS tap feedback
        Button.MouseButton1Down:Connect(function()
            Tween(Button, iOSTheme.AnimationFast, {BackgroundColor3 = iOSTheme.AccentHover or Color3.fromRGB(0, 100, 200)})
        end)
        
        Button.MouseButton1Up:Connect(function()
            Tween(Button, iOSTheme.AnimationFast, {BackgroundColor3 = iOSTheme.Accent})
        end)
        
        Button.MouseLeave:Connect(function()
            Tween(Button, iOSTheme.AnimationFast, {BackgroundColor3 = iOSTheme.Accent})
        end)
        
        Button.MouseButton1Click:Connect(function()
            if config.Callback then
                config.Callback()
            end
        end)
        
        return Button
    end
    
    --// Keybind Toggle
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == (config.ToggleKey or Enum.KeyCode.RightShift) then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)
    
    Window:Open()
    return Window
end

--// Return Library
return iOSLib
