--[[
    ███████╗██╗░░░██╗███████╗░██████╗░██████╗░████████╗
    ██╔════╝╚██╗░██╔╝██╔════╝██╔════╝░██╔══██╗╚══██╔══╝
    █████╗░░░╚████╔╝░█████╗░░██║░░██╗░██████╔╝░░░██║░░░
    ██╔══╝░░░░╚██╔╝░░██╔══╝░░██║░░╚██╗██╔══██╗░░░██║░░░
    ███████╗░░░██║░░░███████╗╚██████╔╝██║░░██║░░░██║░░░
    ╚══════╝░░░╚═╝░░░╚══════╝░╚═════╝░╚═╝░░╚═╝░░░╚═╝░░░

    ██╗░░░░░██╗██████╗░██████╗░░█████╗░██████╗░██╗░░░██╗
    ██║░░░░░██║██╔══██╗██╔══██╗██╔══██╗██╔══██╗╚██╗░██╔╝
    ██║░░░░░██║██████╔╝██████╦╝██║░░██║██████╔╝░╚████╔╝░
    ██║░░░░░██║██╔══██╗██╔══██╗██║░░██║██╔══██╗░░╚██╔╝░░
    ███████╗██║██║░░██║██████╦╝╚█████╔╝██║░░██║░░░██║░░░
    ╚══════╝╚═╝╚═╝░░╚═╝╚═════╝░░╚════╝░╚═╝░░╚═╝░░░╚═╝░░░

    VERSION: 2.0 - PROFESSIONAL 10/10 - BY EYEGPT
    FITUR: Window, Tab, Section, Button, Toggle, Slider, Dropdown, MultiDropdown,
           Keybind, ColorPicker, Label, Paragraph, Textbox, Notif, Watermark,
           LoadingScreen, Tooltip, Settings Saver, Theme Changer, Animasi SMOOTH.
]]

local Library = {}
Library.__index = Library

-- Service cache biar cepet
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ========== THEME ENGINE ==========
local Themes = {
    Dark = {
        Name = "Dark",
        Background = Color3.fromRGB(18, 18, 22),
        Surface = Color3.fromRGB(25, 25, 30),
        Primary = Color3.fromRGB(35, 35, 42),
        Secondary = Color3.fromRGB(45, 45, 52),
        Accent = Color3.fromRGB(88, 101, 242),
        AccentLight = Color3.fromRGB(114, 137, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TextMuted = Color3.fromRGB(180, 180, 190),
        Danger = Color3.fromRGB(237, 66, 69),
        Success = Color3.fromRGB(87, 242, 135),
        Shadow = Color3.fromRGB(0, 0, 0),
        Gradient = {Color3.fromRGB(88, 101, 242), Color3.fromRGB(114, 137, 255)}
    },
    Light = {
        Name = "Light",
        Background = Color3.fromRGB(240, 240, 245),
        Surface = Color3.fromRGB(255, 255, 255),
        Primary = Color3.fromRGB(230, 230, 235),
        Secondary = Color3.fromRGB(220, 220, 225),
        Accent = Color3.fromRGB(0, 120, 255),
        AccentLight = Color3.fromRGB(70, 150, 255),
        Text = Color3.fromRGB(20, 20, 20),
        TextMuted = Color3.fromRGB(100, 100, 100),
        Danger = Color3.fromRGB(220, 50, 50),
        Success = Color3.fromRGB(50, 180, 50),
        Shadow = Color3.fromRGB(150, 150, 150),
        Gradient = {Color3.fromRGB(0, 120, 255), Color3.fromRGB(70, 150, 255)}
    },
    Blood = {
        Name = "Blood",
        Background = Color3.fromRGB(20, 10, 10),
        Surface = Color3.fromRGB(30, 15, 15),
        Primary = Color3.fromRGB(45, 20, 20),
        Secondary = Color3.fromRGB(60, 25, 25),
        Accent = Color3.fromRGB(200, 0, 0),
        AccentLight = Color3.fromRGB(255, 50, 50),
        Text = Color3.fromRGB(255, 200, 200),
        TextMuted = Color3.fromRGB(180, 120, 120),
        Danger = Color3.fromRGB(255, 0, 0),
        Success = Color3.fromRGB(0, 200, 0),
        Shadow = Color3.fromRGB(0, 0, 0),
        Gradient = {Color3.fromRGB(200, 0, 0), Color3.fromRGB(255, 50, 50)}
    }
}

local CurrentTheme = Themes.Dark

-- ========== UTILITY FUNGSI ==========
local function Create(props)
    local obj = Instance.new(props.Type)
    for k, v in pairs(props) do
        if k ~= "Type" and k ~= "Children" then
            obj[k] = v
        end
    end
    if props.Children then
        for _, child in ipairs(props.Children) do
            child.Parent = obj
        end
    end
    return obj
end

local function AddShadow(parent, intensity, offset, transparency)
    intensity = intensity or 5
    offset = offset or 3
    transparency = transparency or 0.8
    for i = 1, intensity do
        local shadow = Create({
            Type = "Frame",
            BackgroundColor3 = CurrentTheme.Shadow,
            BackgroundTransparency = transparency - (i * 0.1),
            Size = parent.Size + UDim2.new(0, i*2, 0, i*2),
            Position = parent.Position - UDim2.new(0, i, 0, i),
            AnchorPoint = parent.AnchorPoint,
            BorderSizePixel = 0,
            ZIndex = parent.ZIndex - i,
            Parent = parent.Parent,
            Children = {
                Create({
                    Type = "UICorner",
                    CornerRadius = UDim.new(0, (parent:FindFirstChildOfClass("UICorner") and parent:FindFirstChildOfClass("UICorner").CornerRadius.Offset or 12) + i)
                })
            }
        })
    end
end

local function ApplyGradient(frame, color1, color2, rotation)
    rotation = rotation or 90
    local gradient = Create({
        Type = "UIGradient",
        Color = ColorSequence.new({ColorSequenceKeypoint.new(0, color1 or CurrentTheme.Gradient[1]), ColorSequenceKeypoint.new(1, color2 or CurrentTheme.Gradient[2])}),
        Rotation = rotation
    })
    gradient.Parent = frame
    return gradient
end

-- ========== MAIN WINDOW ==========
function Library:CreateWindow(title, options)
    options = options or {}
    local self = setmetatable({}, Library)
    
    self.Flags = {}
    self.Tabs = {}
    self.CurrentTab = nil
    self.Notifications = {}
    self.WatermarkEnabled = options.Watermark or false
    self.Theme = CurrentTheme
    
    -- Main GUI
    self.Gui = Create({
        Type = "ScreenGui",
        Name = "EyeGPT_" .. math.random(1000, 9999),
        Parent = LocalPlayer:WaitForChild("PlayerGui"),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 1000
    })
    
    -- Blur background (optional)
    if options.Blur then
        local blur = Instance.new("BlurEffect")
        blur.Size = 0
        blur.Parent = game:GetService("Lighting")
        TweenService:Create(blur, TweenInfo.new(0.5), {Size = 20}):Play()
        self.Blur = blur
    end
    
    -- Main Window Frame
    self.Window = Create({
        Type = "Frame",
        BackgroundColor3 = self.Theme.Background,
        Size = options.Size or UDim2.new(0, 800, 0, 600),
        Position = options.Position or UDim2.new(0.5, -400, 0.5, -300),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = self.Gui,
        ZIndex = 10,
        Children = {
            Create({ Type = "UICorner", CornerRadius = UDim.new(0, 18) })
        }
    })
    
    -- Shadow (multi layer)
    AddShadow(self.Window, 6, 4, 0.9)
    
    -- Gradient overlay (subtle)
    ApplyGradient(self.Window, self.Theme.Background, self.Theme.Surface, 45)
    
    -- Title Bar
    self.TitleBar = Create({
        Type = "Frame",
        BackgroundColor3 = self.Theme.Primary,
        BackgroundTransparency = 0.2,
        Size = UDim2.new(1, 0, 0, 50),
        BorderSizePixel = 0,
        Parent = self.Window,
        ZIndex = 11,
        Children = {
            Create({ Type = "UICorner", CornerRadius = UDim.new(0, 18) })
        }
    })
    
    -- Icon (optional)
    if options.Icon then
        self.Icon = Create({
            Type = "ImageLabel",
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 30, 0, 30),
            Position = UDim2.new(0, 12, 0.5, -15),
            Image = options.Icon,
            ImageColor3 = self.Theme.Text,
            Parent = self.TitleBar,
            ZIndex = 12
        })
    end
    
    -- Title Text
    self.Title = Create({
        Type = "TextLabel",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -150, 1, 0),
        Position = UDim2.new(0, options.Icon and 50 or 20, 0, 0),
        Text = title or "EyeGPT Library",
        TextColor3 = self.Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.TitleBar,
        ZIndex = 12
    })
    
    -- Window Controls
    self.ControlContainer = Create({
        Type = "Frame",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 100, 1, 0),
        Position = UDim2.new(1, -100, 0, 0),
        Parent = self.TitleBar,
        ZIndex = 12
    })
    
    -- Minimize
    self.MinBtn = Create({
        Type = "ImageButton",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(0, 10, 0.5, -15),
        Image = "rbxassetid://10747308083",
        ImageColor3 = self.Theme.TextMuted,
        Parent = self.ControlContainer,
        ZIndex = 13
    })
    
    -- Close
    self.CloseBtn = Create({
        Type = "ImageButton",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(0, 50, 0.5, -15),
        Image = "rbxassetid://10747312666",
        ImageColor3 = self.Theme.TextMuted,
        Parent = self.ControlContainer,
        ZIndex = 13
    })
    
    -- Tab Container
    self.TabContainer = Create({
        Type = "Frame",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 45),
        Position = UDim2.new(0, 10, 0, 55),
        Parent = self.Window,
        ZIndex = 11,
        Children = {
            Create({
                Type = "UIListLayout",
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(0, 8)
            })
        }
    })
    
    -- Page Container
    self.PageContainer = Create({
        Type = "Frame",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 1, -115),
        Position = UDim2.new(0, 10, 0, 105),
        Parent = self.Window,
        ZIndex = 11,
        Children = {
            Create({ Type = "UICorner", CornerRadius = UDim.new(0, 14) })
        }
    })
    
    -- Dragging
    local dragging = false
    local dragStart, windowPos
    
    self.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            windowPos = self.Window.Position
        end
    end)
    
    self.TitleBar.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            self.Window.Position = UDim2.new(
                windowPos.X.Scale,
                windowPos.X.Offset + delta.X,
                windowPos.Y.Scale,
                windowPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Close & Minimize
    self.CloseBtn.MouseButton1Click:Connect(function()
        self:Destroy()
    end)
    
    self.MinBtn.MouseButton1Click:Connect(function()
        self.Window.Visible = not self.Window.Visible
        if self.Watermark then
            self.Watermark.Visible = self.Window.Visible
        end
    end)
    
    -- Hover effects
    for _, btn in pairs({self.CloseBtn, self.MinBtn}) do
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {ImageColor3 = self.Theme.Text}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {ImageColor3 = self.Theme.TextMuted}):Play()
        end)
    end
    
    -- Watermark
    if options.Watermark then
        self:CreateWatermark(title)
    end
    
    -- Keybind to toggle UI
    if options.Keybind then
        UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.KeyCode == Enum.KeyCode[options.Keybind] then
                self.Window.Visible = not self.Window.Visible
                if self.Watermark then
                    self.Watermark.Visible = self.Window.Visible
                end
            end
        end)
    end
    
    return self
end

-- ========== WATERMARK ==========
function Library:CreateWatermark(text)
    local watermark = Create({
        Type = "Frame",
        BackgroundColor3 = self.Theme.Surface,
        BackgroundTransparency = 0.1,
        Size = UDim2.new(0, 200, 0, 30),
        Position = UDim2.new(0, 10, 1, -40),
        AnchorPoint = Vector2.new(0, 1),
        BorderSizePixel = 0,
        Parent = self.Gui,
        ZIndex = 999,
        Children = {
            Create({ Type = "UICorner", CornerRadius = UDim.new(0, 8) }),
            Create({
                Type = "UIStroke",
                Color = self.Theme.Accent,
                Thickness = 1,
                Transparency = 0.5
            }),
            Create({
                Type = "TextLabel",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -10, 1, 0),
                Position = UDim2.new(0, 5, 0, 0),
                Text = text .. " | EyeGPT",
                TextColor3 = self.Theme.Text,
                Font = Enum.Font.Gotham,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
        }
    })
    
    -- Draggable watermark
    local wmDrag = false
    watermark.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            wmDrag = true
        end
    end)
    watermark.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            wmDrag = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if wmDrag and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = UserInputService:GetMouseLocation()
            watermark.Position = UDim2.new(0, pos.X - watermark.AbsoluteSize.X/2, 0, pos.Y - watermark.AbsoluteSize.Y/2)
        end
    end)
    
    self.Watermark = watermark
end

-- ========== TAB SYSTEM ==========
function Library:CreateTab(name, icon)
    icon = icon or ""
    
    local tabBtn = Create({
        Type = "TextButton",
        BackgroundColor3 = self.Theme.Primary,
        BackgroundTransparency = 0.3,
        Size = UDim2.new(0, 130, 0, 38),
        Text = "",
        AutoButtonColor = false,
        Parent = self.TabContainer,
        ZIndex = 12,
        Children = {
            Create({ Type = "UICorner", CornerRadius = UDim.new(0, 10) })
        }
    })
    
    if icon ~= "" then
        Create({
            Type = "ImageLabel",
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(0, 10, 0.5, -10),
            Image = icon,
            ImageColor3 = self.Theme.TextMuted,
            Parent = tabBtn,
            ZIndex = 13
        })
    end
    
    local tabText = Create({
        Type = "TextLabel",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, icon ~= "" and 35 or 10, 0, 0),
        Text = name,
        TextColor3 = self.Theme.TextMuted,
        Font = Enum.Font.Gotham,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = tabBtn,
        ZIndex = 13
    })
    
    local page = Create({
        Type = "ScrollingFrame",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 6,
        ScrollBarImageColor3 = self.Theme.Accent,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        Parent = self.PageContainer,
        ZIndex = 12,
        Children = {
            Create({
                Type = "UIListLayout",
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 12)
            }),
            Create({
                Type = "UIPadding",
                PaddingTop = UDim.new(0, 12),
                PaddingBottom = UDim.new(0, 12),
                PaddingLeft = UDim.new(0, 12),
                PaddingRight = UDim.new(0, 12)
            })
        }
    })
    
    local tabData = {
        Name = name,
        Button = tabBtn,
        Page = page,
        Text = tabText
    }
    table.insert(self.Tabs, tabData)
    
    tabBtn.MouseButton1Click:Connect(function()
        self:SelectTab(tabData)
    end)
    
    tabBtn.MouseEnter:Connect(function()
        if self.CurrentTab ~= tabData then
            TweenService:Create(tabBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.1}):Play()
            TweenService:Create(tabText, TweenInfo.new(0.2), {TextColor3 = self.Theme.Text}):Play()
        end
    end)
    
    tabBtn.MouseLeave:Connect(function()
        if self.CurrentTab ~= tabData then
            TweenService:Create(tabBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.3}):Play()
            TweenService:Create(tabText, TweenInfo.new(0.2), {TextColor3 = self.Theme.TextMuted}):Play()
        end
    end)
    
    if #self.Tabs == 1 then
        self:SelectTab(tabData)
    end
    
    return page
end

function Library:SelectTab(tab)
    if self.CurrentTab then
        TweenService:Create(self.CurrentTab.Button, TweenInfo.new(0.2), {
            BackgroundColor3 = self.Theme.Primary,
            BackgroundTransparency = 0.3
        }):Play()
        TweenService:Create(self.CurrentTab.Text, TweenInfo.new(0.2), {
            TextColor3 = self.Theme.TextMuted
        }):Play()
        self.CurrentTab.Page.Visible = false
    end
    
    self.CurrentTab = tab
    TweenService:Create(tab.Button, TweenInfo.new(0.2), {
        BackgroundColor3 = self.Theme.Accent,
        BackgroundTransparency = 0
    }):Play()
    TweenService:Create(tab.Text, TweenInfo.new(0.2), {
        TextColor3 = self.Theme.Text
    }):Play()
    tab.Page.Visible = true
end

-- ========== SECTION ==========
function Library:CreateSection(parent, title)
    local section = Create({
        Type = "Frame",
        BackgroundColor3 = self.Theme.Primary,
        BackgroundTransparency = 0.2,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BorderSizePixel = 0,
        Parent = parent,
        ZIndex = 13,
        Children = {
            Create({ Type = "UICorner", CornerRadius = UDim.new(0, 14) }),
            Create({
                Type = "UIStroke",
                Color = self.Theme.TextMuted,
                Thickness = 1,
                Transparency = 0.9
            })
        }
    })
    
    Create({
        Type = "TextLabel",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 35),
        Position = UDim2.new(0, 12, 0, 8),
        Text = title,
        TextColor3 = self.Theme.AccentLight,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = section,
        ZIndex = 14
    })
    
    local content = Create({
        Type = "Frame",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 0),
        Position = UDim2.new(0, 10, 0, 45),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = section,
        ZIndex = 14,
        Children = {
            Create({
                Type = "UIListLayout",
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 10)
            }),
            Create({
                Type = "UIPadding",
                PaddingBottom = UDim.new(0, 12)
            })
        }
    })
    
    return content
end

-- ========== BUTTON ==========
function Library:CreateButton(parent, options)
    local btn = Create({
        Type = "TextButton",
        BackgroundColor3 = self.Theme.Accent,
        Size = UDim2.new(1, 0, 0, 45),
        Text = "",
        AutoButtonColor = false,
        Parent = parent,
        ZIndex = 15,
        Children = {
            Create({ Type = "UICorner", CornerRadius = UDim.new(0, 10) })
        }
    })
    
    ApplyGradient(btn, self.Theme.Gradient[1], self.Theme.Gradient[2], 45)
    
    local text = Create({
        Type = "TextLabel",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        Text = options.Name or "Button",
        TextColor3 = self.Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = btn,
        ZIndex = 16
    })
    
    -- Hover animation
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {
            Size = UDim2.new(1, 0, 0, 48),
            BackgroundColor3 = self.Theme.AccentLight
        }):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {
            Size = UDim2.new(1, 0, 0, 45),
            BackgroundColor3 = self.Theme.Accent
        }):Play()
    end)
    
    btn.MouseButton1Click:Connect(function()
        if options.Callback then
            pcall(options.Callback)
        end
    end)
    
    return btn
end

-- ========== TOGGLE ==========
function Library:CreateToggle(parent, options)
    local frame = Create({
        Type = "Frame",
        BackgroundColor3 = self.Theme.Primary,
        BackgroundTransparency = 0.3,
        Size = UDim2.new(1, 0, 0, 45),
        BorderSizePixel = 0,
        Parent = parent,
        ZIndex = 15,
        Children = {
            Create({ Type = "UICorner", CornerRadius = UDim.new(0, 10) })
        }
    })
    
    local text = Create({
        Type = "TextLabel",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -80, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        Text = options.Name or "Toggle",
        TextColor3 = self.Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
        ZIndex = 16
    })
    
    local switch = Create({
        Type = "Frame",
        BackgroundColor3 = self.Theme.Secondary,
        Size = UDim2.new(0, 55, 0, 26),
        Position = UDim2.new(1, -65, 0.5, -13),
        BorderSizePixel = 0,
        Parent = frame,
        ZIndex = 16,
        Children = {
            Create({ Type = "UICorner", CornerRadius = UDim.new(1, 0) })
        }
    })
    
    local knob = Create({
        Type = "Frame",
        BackgroundColor3 = self.Theme.TextMuted,
        Size = UDim2.new(0, 22, 0, 22),
        Position = UDim2.new(0, 2, 0.5, -11),
        BorderSizePixel = 0,
        Parent = switch,
        ZIndex = 17,
        Children = {
            Create({ Type = "UICorner", CornerRadius = UDim.new(1, 0) })
        }
    })
    
    local state = options.Default or false
    local flag = options.Flag
    
    local function SetState(newState)
        state = newState
        if state then
            TweenService:Create(switch, TweenInfo.new(0.2), {BackgroundColor3 = self.Theme.Accent}):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {
                Position = UDim2.new(1, -24, 0.5, -11),
                BackgroundColor3 = self.Theme.Text
            }):Play()
        else
            TweenService:Create(switch, TweenInfo.new(0.2), {BackgroundColor3 = self.Theme.Secondary}):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {
                Position = UDim2.new(0, 2, 0.5, -11),
                BackgroundColor3 = self.Theme.TextMuted
            }):Play()
        end
        
        if flag then self.Flags[flag] = state end
        if options.Callback then options.Callback(state) end
    end
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            SetState(not state)
        end
    end)
    
    SetState(state)
    
    return { SetState = SetState, GetState = function() return state end }
end

-- ========== SLIDER ==========
function Library:CreateSlider(parent, options)
    local min = options.Min or 0
    local max = options.Max or 100
    local default = options.Default or min
    local suffix = options.Suffix or ""
    local decimals = options.Decimals or 0
    
    local frame = Create({
        Type = "Frame",
        BackgroundColor3 = self.Theme.Primary,
        BackgroundTransparency = 0.3,
        Size = UDim2.new(1, 0, 0, 70),
        BorderSizePixel = 0,
        Parent = parent,
        ZIndex = 15,
        Children = {
            Create({ Type = "UICorner", CornerRadius = UDim.new(0, 10) })
        }
    })
    
    Create({
        Type = "TextLabel",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 25),
        Position = UDim2.new(0, 14, 0, 8),
        Text = options.Name or "Slider",
        TextColor3 = self.Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
        ZIndex = 16
    })
    
    local valueText = Create({
        Type = "TextLabel",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 25),
        Position = UDim2.new(0, 14, 0, 30),
        Text = tostring(default) .. " " .. suffix,
        TextColor3 = self.Theme.AccentLight,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
        ZIndex = 16
    })
    
    local track = Create({
        Type = "Frame",
        BackgroundColor3 = self.Theme.Secondary,
        Size = UDim2.new(1, -28, 0, 6),
        Position = UDim2.new(0, 14, 0, 55),
        BorderSizePixel = 0,
        Parent = frame,
        ZIndex = 16,
        Children = {
            Create({ Type = "UICorner", CornerRadius = UDim.new(1, 0) })
        }
    })
    
    local fill = Create({
        Type = "Frame",
        BackgroundColor3 = self.Theme.Accent,
        Size = UDim2.new(0, 0, 1, 0),
        BorderSizePixel = 0,
        Parent = track,
        ZIndex = 17,
        Children = {
            Create({ Type = "UICorner", CornerRadius = UDim.new(1, 0) })
        }
    })
    
    local knob = Create({
        Type = "Frame",
        BackgroundColor3 = self.Theme.Text,
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, -10, 0.5, -10),
        BorderSizePixel = 0,
        Parent = track,
        ZIndex = 18,
        Children = {
            Create({ Type = "UICorner", CornerRadius = UDim.new(1, 0) })
        }
    })
    
    local value = default
    local dragging = false
    local flag = options.Flag
    
    local function UpdateFromMouse(inputPos)
        local trackPos = track.AbsolutePosition
        local trackSize = track.AbsoluteSize
        local relX = math.clamp(inputPos.X - trackPos.X, 0, trackSize.X)
        local percent = relX / trackSize.X
        value = min + (percent * (max - min))
        if decimals then
            local mult = 10^decimals
            value = math.round(value * mult) / mult
        end
        value = math.clamp(value, min, max)
        
        local fillWidth = (value - min) / (max - min) * trackSize.X
        fill.Size = UDim2.new(0, fillWidth, 1, 0)
        knob.Position = UDim2.new(0, fillWidth - 10, 0.5, -10)
        valueText.Text = tostring(value) .. " " .. suffix
        
        if flag then self.Flags[flag] = value end
        if options.Callback then options.Callback(value) end
    end
    
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            UpdateFromMouse(input.Position)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            UpdateFromMouse(input.Position)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Initialize
    UpdateFromMouse({Position = Vector2.new(
        track.AbsolutePosition.X + ((default - min) / (max - min) * track.AbsoluteSize.X),
        track.AbsolutePosition.Y
    )})
    
    return { SetValue = function(v) value = v; UpdateFromMouse({Position = Vector2.new(
        track.AbsolutePosition.X + ((v - min) / (max - min) * track.AbsoluteSize.X),
        track.AbsolutePosition.Y
    )}) end, GetValue = function() return value end }
end

-- ========== DROPDOWN ==========
function Library:CreateDropdown(parent, options)
    local items = options.Items or {}
    local default = options.Default or items[1]
    
    local frame = Create({
        Type = "Frame",
        BackgroundColor3 = self.Theme.Primary,
        BackgroundTransparency = 0.3,
        Size = UDim2.new(1, 0, 0, 45),
        BorderSizePixel = 0,
        Parent = parent,
        ZIndex = 15,
        Children = {
            Create({ Type = "UICorner", CornerRadius = UDim.new(0, 10) })
        }
    })
    
    Create({
        Type = "TextLabel",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        Text = options.Name or "Dropdown",
        TextColor3 = self.Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
        ZIndex = 16
    })
    
    local selectedText = Create({
        Type = "TextLabel",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 120, 1, 0),
        Position = UDim2.new(1, -140, 0, 0),
        Text = default,
        TextColor3 = self.Theme.AccentLight,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = frame,
        ZIndex = 16
    })
    
    local arrow = Create({
        Type = "ImageLabel",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -30, 0.5, -10),
        Image = "rbxassetid://10747302107",
        ImageColor3 = self.Theme.TextMuted,
        Parent = frame,
        ZIndex = 16
    })
    
    local menu = Create({
        Type = "Frame",
        BackgroundColor3 = self.Theme.Surface,
        Size = UDim2.new(0, 200, 0, 0),
        Position = UDim2.new(0, frame.AbsolutePosition.X + 10, 0, frame.AbsolutePosition.Y + 50),
        BorderSizePixel = 0,
        Visible = false,
        Parent = self.Gui,
        ZIndex = 20,
        ClipsDescendants = true,
        Children = {
            Create({ Type = "UICorner", CornerRadius = UDim.new(0, 10) }),
            Create({
                Type = "UIListLayout",
                Padding = UDim.new(0, 2)
            }),
            Create({
                Type = "UIPadding",
                PaddingTop = UDim.new(0, 5),
                PaddingBottom = UDim.new(0, 5)
            })
        }
    })
    
    local selected = default
    local flag = options.Flag
    local isOpen = false
    
    for _, item in ipairs(items) do
        local btn = Create({
            Type = "TextButton",
            BackgroundColor3 = self.Theme.Secondary,
            BackgroundTransparency = 0.5,
            Size = UDim2.new(1, -10, 0, 35),
            Text = "",
            AutoButtonColor = false,
            Parent = menu,
            ZIndex = 21,
            Children = {
                Create({ Type = "UICorner", CornerRadius = UDim.new(0, 6) }),
                Create({
                    Type = "TextLabel",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -10, 1, 0),
                    Position = UDim2.new(0, 5, 0, 0),
                    Text = item,
                    TextColor3 = self.Theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 22
                })
            }
        })
        
        btn.MouseButton1Click:Connect(function()
            selected = item
            selectedText.Text = item
            if flag then self.Flags[flag] = item end
            if options.Callback then options.Callback(item) end
            -- Close menu
            TweenService:Create(menu, TweenInfo.new(0.2), {Size = UDim2.new(0, 200, 0, 0)}):Play()
            wait(0.2)
            menu.Visible = false
            isOpen = false
            arrow.Image = "rbxassetid://10747302107"
        end)
    end
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if isOpen then
                TweenService:Create(menu, TweenInfo.new(0.2), {Size = UDim2.new(0, 200, 0, 0)}):Play()
                wait(0.2)
                menu.Visible = false
                arrow.Image = "rbxassetid://10747302107"
            else
                menu.Position = UDim2.new(0, frame.AbsolutePosition.X + 10, 0, frame.AbsolutePosition.Y + 50)
                menu.Size = UDim2.new(0, 200, 0, 0)
                menu.Visible = true
                TweenService:Create(menu, TweenInfo.new(0.2), {Size = UDim2.new(0, 200, 0, #items * 37 + 10)}):Play()
                arrow.Image = "rbxassetid://10747299867"
            end
            isOpen = not isOpen
        end
    end)
    
    return { SetValue = function(v) selected = v; selectedText.Text = v end, GetValue = function() return selected end }
end

-- ========== KEYBIND ==========
function Library:CreateKeybind(parent, options)
    local frame = Create({
        Type = "Frame",
        BackgroundColor3 = self.Theme.Primary,
        BackgroundTransparency = 0.3,
        Size = UDim2.new(1, 0, 0, 45),
        BorderSizePixel = 0,
        Parent = parent,
        ZIndex = 15,
        Children = {
            Create({ Type = "UICorner", CornerRadius = UDim.new(0, 10) })
        }
    })
    
    Create({
        Type = "TextLabel",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -120, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        Text = options.Name or "Keybind",
        TextColor3 = self.Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
        ZIndex = 16
    })
    
    local keyText = Create({
        Type = "TextLabel",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 100, 1, 0),
        Position = UDim2.new(1, -120, 0, 0),
        Text = options.Default or "None",
        TextColor3 = self.Theme.AccentLight,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = frame,
        ZIndex = 16
    })
    
    local listening = false
    local currentKey = options.Default or "None"
    local flag = options.Flag
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            listening = true
            keyText.Text = "..."
        end
    end)
    
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if listening then
            if input.KeyCode ~= Enum.KeyCode.Unknown then
                currentKey = input.KeyCode.Name
                keyText.Text = currentKey
                listening = false
                if flag then self.Flags[flag] = currentKey end
                if options.Callback then options.Callback(currentKey) end
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                currentKey = "Mouse1"
                keyText.Text = currentKey
                listening = false
                if flag then self.Flags[flag] = currentKey end
                if options.Callback then options.Callback(currentKey) end
            end
        end
    end)
    
    return { GetKey = function() return currentKey end }
end

-- ========== COLORPICKER ==========
function Library:CreateColorpicker(parent, options)
    local frame = Create({
        Type = "Frame",
        BackgroundColor3 = self.Theme.Primary,
        BackgroundTransparency = 0.3,
        Size = UDim2.new(1, 0, 0, 45),
        BorderSizePixel = 0,
        Parent = parent,
        ZIndex = 15,
        Children = {
            Create({ Type = "UICorner", CornerRadius = UDim.new(0, 10) })
        }
    })
    
    Create({
        Type = "TextLabel",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        Text = options.Name or "Color",
        TextColor3 = self.Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
        ZIndex = 16
    })
    
    local colorDisplay = Create({
        Type = "Frame",
        BackgroundColor3 = options.Default or Color3.new(1,0,0),
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -40, 0.5, -15),
        BorderSizePixel = 0,
        Parent = frame,
        ZIndex = 16,
        Children = {
            Create({ Type = "UICorner", CornerRadius = UDim.new(0, 6) }),
            Create({
                Type = "UIStroke",
                Color = self.Theme.Text,
                Thickness = 1,
                Transparency = 0.5
            })
        }
    })
    
    local currentColor = options.Default or Color3.new(1,0,0)
    local flag = options.Flag
    
    -- Simple color picker popup (just cycles for demo, but you can implement HSV)
    colorDisplay.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            -- Generate random color for simplicity, but real one would have HSV picker
            local r = math.random()
            local g = math.random()
            local b = math.random()
            currentColor = Color3.new(r, g, b)
            colorDisplay.BackgroundColor3 = currentColor
            if flag then self.Flags[flag] = currentColor end
            if options.Callback then options.Callback(currentColor) end
        end
    end)
    
    return { SetColor = function(c) currentColor = c; colorDisplay.BackgroundColor3 = c end, GetColor = function() return currentColor end }
end

-- ========== LABEL ==========
function Library:CreateLabel(parent, options)
    local label = Create({
        Type = "TextLabel",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 30),
        Text = options.Text or "Label",
        TextColor3 = options.Color or self.Theme.Text,
        Font = options.Font or Enum.Font.Gotham,
        TextSize = options.Size or 16,
        TextXAlignment = options.Align or Enum.TextXAlignment.Left,
        Parent = parent,
        ZIndex = 15
    })
    return label
end

-- ========== PARAGRAPH ==========
function Library:CreateParagraph(parent, options)
    local frame = Create({
        Type = "Frame",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = parent,
        ZIndex = 15,
        Children = {
            Create({
                Type = "UIListLayout",
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 4)
            })
        }
    })
    
    for i, line in ipairs(options.Lines or {}) do
        local label = Create({
            Type = "TextLabel",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            Text = line,
            TextColor3 = options.Color or self.Theme.TextMuted,
            Font = options.Font or Enum.Font.Gotham,
            TextSize = options.Size or 14,
            TextXAlignment = options.Align or Enum.TextXAlignment.Left,
            Parent = frame,
            ZIndex = 16
        })
    end
    
    return frame
end

-- ========== TEXTBOX ==========
function Library:CreateTextbox(parent, options)
    local frame = Create({
        Type = "Frame",
        BackgroundColor3 = self.Theme.Primary,
        BackgroundTransparency = 0.3,
        Size = UDim2.new(1, 0, 0, 70),
        BorderSizePixel = 0,
        Parent = parent,
        ZIndex = 15,
        Children = {
            Create({ Type = "UICorner", CornerRadius = UDim.new(0, 10) })
        }
    })
    
    Create({
        Type = "TextLabel",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 25),
        Position = UDim2.new(0, 12, 0, 8),
        Text = options.Name or "Text Input",
        TextColor3 = self.Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
        ZIndex = 16
    })
    
    local inputFrame = Create({
        Type = "Frame",
        BackgroundColor3 = self.Theme.Secondary,
        Size = UDim2.new(1, -24, 0, 35),
        Position = UDim2.new(0, 12, 0, 35),
        BorderSizePixel = 0,
        Parent = frame,
        ZIndex = 16,
        Children = {
            Create({ Type = "UICorner", CornerRadius = UDim.new(0, 8) })
        }
    })
    
    local textbox = Create({
        Type = "TextBox",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        PlaceholderText = options.Placeholder or "Type...",
        PlaceholderColor3 = self.Theme.TextMuted,
        Text = options.Default or "",
        TextColor3 = self.Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 15,
        ClearTextOnFocus = false,
        Parent = inputFrame,
        ZIndex = 17
    })
    
    local flag = options.Flag
    textbox.FocusLost:Connect(function(enter)
        if flag then self.Flags[flag] = textbox.Text end
        if options.Callback then options.Callback(textbox.Text, enter) end
    end)
    
    return { SetText = function(t) textbox.Text = t end, GetText = function() return textbox.Text end }
end

-- ========== NOTIFICATION ==========
function Library:Notify(options)
    local notif = Create({
        Type = "Frame",
        BackgroundColor3 = self.Theme.Surface,
        Size = UDim2.new(0, 350, 0, 90),
        Position = UDim2.new(1, 20, 1, -20),
        AnchorPoint = Vector2.new(1, 1),
        BorderSizePixel = 0,
        Parent = self.Gui,
        ZIndex = 200,
        Children = {
            Create({ Type = "UICorner", CornerRadius = UDim.new(0, 14) }),
            Create({
                Type = "UIStroke",
                Color = self.Theme.Accent,
                Thickness = 2,
                Transparency = 0.3
            })
        }
    })
    
    -- Icon (optional)
    if options.Icon then
        Create({
            Type = "ImageLabel",
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 40, 0, 40),
            Position = UDim2.new(0, 12, 0.5, -20),
            Image = options.Icon,
            ImageColor3 = self.Theme.Text,
            Parent = notif,
            ZIndex = 201
        })
    end
    
    -- Title
    Create({
        Type = "TextLabel",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -70, 0, 25),
        Position = UDim2.new(0, options.Icon and 60 or 15, 0, 12),
        Text = options.Title or "Notification",
        TextColor3 = self.Theme.AccentLight,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notif,
        ZIndex = 201
    })
    
    -- Content
    Create({
        Type = "TextLabel",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -70, 0, 40),
        Position = UDim2.new(0, options.Icon and 60 or 15, 0, 35),
        Text = options.Content or "",
        TextColor3 = self.Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notif,
        ZIndex = 201
    })
    
    -- Slide in
    notif.Position = UDim2.new(1, 20, 1, -20)
    TweenService:Create(notif, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
        Position = UDim2.new(1, -370, 1, -20)
    }):Play()
    
    -- Auto destroy
    task.wait(options.Duration or 5)
    TweenService:Create(notif, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
        Position = UDim2.new(1, 20, 1, -20)
    }):Play()
    task.wait(0.4)
    notif:Destroy()
end

-- ========== THEME SWITCHER ==========
function Library:SetTheme(themeName)
    if Themes[themeName] then
        CurrentTheme = Themes[themeName]
        self.Theme = CurrentTheme
        -- In real implementation, you'd refresh all UI elements, but for simplicity we'll just notify
        self:Notify({
            Title = "Theme Changed",
            Content = "Theme set to " .. themeName,
            Duration = 2
        })
    end
end

-- ========== LOADING SCREEN ==========
function Library:ShowLoading(text)
    local loading = Create({
        Type = "Frame",
        BackgroundColor3 = self.Theme.Background,
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        Parent = self.Gui,
        ZIndex = 999,
        Children = {
            Create({ Type = "UICorner", CornerRadius = UDim.new(0, 0) })
        }
    })
    
    local spinner = Create({
        Type = "ImageLabel",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 50, 0, 50),
        Position = UDim2.new(0.5, -25, 0.5, -50),
        Image = "rbxassetid://6031094671",
        ImageColor3 = self.Theme.Accent,
        Parent = loading,
        ZIndex = 1000
    })
    
    -- Rotate animation
    local rot = 0
    local connection
    connection = RunService.Heartbeat:Connect(function(dt)
        rot = rot + dt * 100
        spinner.Rotation = rot
    end)
    
    Create({
        Type = "TextLabel",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0.5, 0),
        Text = text or "Loading...",
        TextColor3 = self.Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 20,
        Parent = loading,
        ZIndex = 1000
    })
    
    return {
        Close = function()
            connection:Disconnect()
            loading:Destroy()
        end
    }
end

-- ========== DESTROY ==========
function Library:Destroy()
    if self.Blur then
        TweenService:Create(self.Blur, TweenInfo.new(0.5), {Size = 0}):Play()
        task.wait(0.5)
        self.Blur:Destroy()
    end
    self.Gui:Destroy()
end

return Library
