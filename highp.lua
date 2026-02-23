--[[
    ██╗░░░██╗██╗██╗░░░░░██╗██████╗░██████╗░░█████╗░██████╗░██╗░░░██╗
    ██║░░░██║██║██║░░░░░██║██╔══██╗██╔══██╗██╔══██╗██╔══██╗╚██╗░██╔╝
    ██║░░░██║██║██║░░░░░██║██████╔╝██████╦╝██║░░██║██████╔╝░╚████╔╝░
    ██║░░░██║██║██║░░░░░██║██╔══██╗██╔══██╗██║░░██║██╔══██╗░░╚██╔╝░░
    ╚██████╔╝██║███████╗██║██║░░██║██████╦╝╚█████╔╝██║░░██║░░░██║░░░
    ░╚═════╝░╚═╝╚══════╝╚═╝╚═╝░░╚═╝╚═════╝░░╚════╝░╚═╝░░╚═╝░░░╚═╝░░░

    PROFESSIONAL UI LIBRARY v1.0 - FOR EXECUTORS
    SMOOTH • MODERN • COMPLETE
]]

local Library = {}
Library.__index = Library

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ========== THEME ==========
local Theme = {
    Background = Color3.fromRGB(18, 18, 22),      -- #121216
    Surface = Color3.fromRGB(25, 25, 30),         -- #19191E
    Primary = Color3.fromRGB(35, 35, 42),         -- #23232A
    Secondary = Color3.fromRGB(45, 45, 52),       -- #2D2D34
    Accent = Color3.fromRGB(88, 101, 242),        -- #5865F2 (biru gradient)
    AccentLight = Color3.fromRGB(114, 137, 255),  -- #7289FF
    Text = Color3.fromRGB(255, 255, 255),
    TextMuted = Color3.fromRGB(180, 180, 190),
    Danger = Color3.fromRGB(237, 66, 69),         -- #ED4245
    Success = Color3.fromRGB(87, 242, 135),       -- #57F287
    Shadow = Color3.fromRGB(0, 0, 0)
}

-- ========== UTILITY FUNCTIONS ==========
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
    intensity = intensity or 4
    offset = offset or 2
    transparency = transparency or 0.7
    for i = 1, intensity do
        local shadow = Create({
            Type = "Frame",
            BackgroundColor3 = Theme.Shadow,
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
                    CornerRadius = UDim.new(0, 12 + i)
                })
            }
        })
    end
end

local function ApplyGradient(frame, color1, color2, rotation)
    rotation = rotation or 90
    local gradient = Create({
        Type = "UIGradient",
        Color = ColorSequence.new({ColorSequenceKeypoint.new(0, color1), ColorSequenceKeypoint.new(1, color2)}),
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
    
    -- Main GUI
    self.Gui = Create({
        Type = "ScreenGui",
        Name = "UILibrary_" .. math.random(1000, 9999),
        Parent = LocalPlayer:WaitForChild("PlayerGui"),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    -- Main Window Frame
    self.Window = Create({
        Type = "Frame",
        BackgroundColor3 = Theme.Background,
        Size = options.Size or UDim2.new(0, 700, 0, 500),
        Position = options.Position or UDim2.new(0.5, -350, 0.5, -250),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = self.Gui,
        ZIndex = 10,
        Children = {
            Create({ Type = "UICorner", CornerRadius = UDim.new(0, 16) })
        }
    })
    
    -- Shadow
    AddShadow(self.Window, 5, 3, 0.8)
    
    -- Gradient overlay (subtle)
    ApplyGradient(self.Window, Theme.Background, Theme.Surface, 45)
    
    -- Title Bar
    self.TitleBar = Create({
        Type = "Frame",
        BackgroundColor3 = Theme.Primary,
        BackgroundTransparency = 0.3,
        Size = UDim2.new(1, 0, 0, 45),
        BorderSizePixel = 0,
        Parent = self.Window,
        ZIndex = 11,
        Children = {
            Create({ Type = "UICorner", CornerRadius = UDim.new(0, 16) })
        }
    })
    
    -- Title Text
    self.Title = Create({
        Type = "TextLabel",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 20, 0, 0),
        Text = title or "UI Library",
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.TitleBar,
        ZIndex = 12
    })
    
    -- Close Button
    self.CloseBtn = Create({
        Type = "ImageButton",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -40, 0.5, -15),
        Image = "rbxassetid://10747312666",  -- X icon
        ImageColor3 = Theme.TextMuted,
        Parent = self.TitleBar,
        ZIndex = 12
    })
    
    -- Minimize Button
    self.MinBtn = Create({
        Type = "ImageButton",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -80, 0.5, -15),
        Image = "rbxassetid://10747308083",  -- Minimize icon
        ImageColor3 = Theme.TextMuted,
        Parent = self.TitleBar,
        ZIndex = 12
    })
    
    -- Tab Container
    self.TabContainer = Create({
        Type = "Frame",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 40),
        Position = UDim2.new(0, 10, 0, 50),
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
        Size = UDim2.new(1, -20, 1, -100),
        Position = UDim2.new(0, 10, 0, 95),
        Parent = self.Window,
        ZIndex = 11,
        Children = {
            Create({ Type = "UICorner", CornerRadius = UDim.new(0, 12) })
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
    
    -- Close functionality
    self.CloseBtn.MouseButton1Click:Connect(function()
        self:Destroy()
    end)
    
    -- Minimize
    self.MinBtn.MouseButton1Click:Connect(function()
        self.Window.Visible = not self.Window.Visible
    end)
    
    -- Hover effects
    for _, btn in pairs({self.CloseBtn, self.MinBtn}) do
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {ImageColor3 = Theme.Text}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {ImageColor3 = Theme.TextMuted}):Play()
        end)
    end
    
    return self
end

-- ========== TAB SYSTEM ==========
function Library:CreateTab(name, icon)
    icon = icon or ""
    
    -- Tab Button
    local tabBtn = Create({
        Type = "TextButton",
        BackgroundColor3 = Theme.Primary,
        BackgroundTransparency = 0.3,
        Size = UDim2.new(0, 120, 0, 35),
        Text = "",
        AutoButtonColor = false,
        Parent = self.TabContainer,
        ZIndex = 12,
        Children = {
            Create({ Type = "UICorner", CornerRadius = UDim.new(0, 8) })
        }
    })
    
    -- Icon (if provided)
    if icon ~= "" then
        Create({
            Type = "ImageLabel",
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(0, 10, 0.5, -10),
            Image = icon,
            ImageColor3 = Theme.TextMuted,
            Parent = tabBtn,
            ZIndex = 13
        })
    end
    
    -- Tab Text
    local tabText = Create({
        Type = "TextLabel",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, icon ~= "" and 35 or 10, 0, 0),
        Text = name,
        TextColor3 = Theme.TextMuted,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = tabBtn,
        ZIndex = 13
    })
    
    -- Page
    local page = Create({
        Type = "ScrollingFrame",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Theme.Accent,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        Parent = self.PageContainer,
        ZIndex = 12,
        Children = {
            Create({
                Type = "UIListLayout",
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 10)
            }),
            Create({
                Type = "UIPadding",
                PaddingTop = UDim.new(0, 10),
                PaddingBottom = UDim.new(0, 10),
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10)
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
    
    -- Tab selection
    tabBtn.MouseButton1Click:Connect(function()
        self:SelectTab(tabData)
    end)
    
    -- Hover effect
    tabBtn.MouseEnter:Connect(function()
        if self.CurrentTab ~= tabData then
            TweenService:Create(tabBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.1}):Play()
            TweenService:Create(tabText, TweenInfo.new(0.2), {TextColor3 = Theme.Text}):Play()
        end
    end)
    
    tabBtn.MouseLeave:Connect(function()
        if self.CurrentTab ~= tabData then
            TweenService:Create(tabBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.3}):Play()
            TweenService:Create(tabText, TweenInfo.new(0.2), {TextColor3 = Theme.TextMuted}):Play()
        end
    end)
    
    -- Select first tab automatically
    if #self.Tabs == 1 then
        self:SelectTab(tabData)
    end
    
    return page
end

function Library:SelectTab(tab)
    if self.CurrentTab then
        -- Deselect old
        TweenService:Create(self.CurrentTab.Button, TweenInfo.new(0.2), {
            BackgroundColor3 = Theme.Primary,
            BackgroundTransparency = 0.3
        }):Play()
        TweenService:Create(self.CurrentTab.Text, TweenInfo.new(0.2), {
            TextColor3 = Theme.TextMuted
        }):Play()
        self.CurrentTab.Page.Visible = false
    end
    
    -- Select new
    self.CurrentTab = tab
    TweenService:Create(tab.Button, TweenInfo.new(0.2), {
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 0
    }):Play()
    TweenService:Create(tab.Text, TweenInfo.new(0.2), {
        TextColor3 = Theme.Text
    }):Play()
    
    -- Fade in page
    tab.Page.BackgroundTransparency = 1
    tab.Page.Visible = true
    TweenService:Create(tab.Page, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
end

-- ========== SECTION ==========
function Library:CreateSection(parent, title)
    local section = Create({
        Type = "Frame",
        BackgroundColor3 = Theme.Primary,
        BackgroundTransparency = 0.2,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BorderSizePixel = 0,
        Parent = parent,
        ZIndex = 13,
        Children = {
            Create({ Type = "UICorner", CornerRadius = UDim.new(0, 12) }),
            Create({
                Type = "UIStroke",
                Color = Theme.TextMuted,
                Thickness = 0.5,
                Transparency = 0.9
            })
        }
    })
    
    -- Title
    Create({
        Type = "TextLabel",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 10, 0, 8),
        Text = title,
        TextColor3 = Theme.AccentLight,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = section,
        ZIndex = 14
    })
    
    -- Content Container
    local content = Create({
        Type = "Frame",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 0),
        Position = UDim2.new(0, 10, 0, 40),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = section,
        ZIndex = 14,
        Children = {
            Create({
                Type = "UIListLayout",
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 8)
            }),
            Create({
                Type = "UIPadding",
                PaddingBottom = UDim.new(0, 10)
            })
        }
    })
    
    return content
end

-- ========== BUTTON ==========
function Library:CreateButton(parent, options)
    local btn = Create({
        Type = "TextButton",
        BackgroundColor3 = Theme.Accent,
        Size = UDim2.new(1, 0, 0, 40),
        Text = "",
        AutoButtonColor = false,
        Parent = parent,
        ZIndex = 15,
        Children = {
            Create({ Type = "UICorner", CornerRadius = UDim.new(0, 8) })
        }
    })
    
    -- Gradient
    ApplyGradient(btn, Theme.Accent, Theme.AccentLight, 45)
    
    -- Text
    local text = Create({
        Type = "TextLabel",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        Text = options.Name or "Button",
        TextColor3 = Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = btn,
        ZIndex = 16
    })
    
    -- Hover
    local originalSize = btn.Size
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {
            Size = UDim2.new(1, 0, 0, 44),
            BackgroundColor3 = Theme.AccentLight
        }):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundColor3 = Theme.Accent
        }):Play()
    end)
    
    -- Click
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
        BackgroundColor3 = Theme.Primary,
        BackgroundTransparency = 0.3,
        Size = UDim2.new(1, 0, 0, 40),
        BorderSizePixel = 0,
        Parent = parent,
        ZIndex = 15,
        Children = {
            Create({ Type = "UICorner", CornerRadius = UDim.new(0, 8) })
        }
    })
    
    -- Text
    local text = Create({
        Type = "TextLabel",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -70, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        Text = options.Name or "Toggle",
        TextColor3 = Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
        ZIndex = 16
    })
    
    -- Toggle switch
    local switch = Create({
        Type = "Frame",
        BackgroundColor3 = Theme.Secondary,
        Size = UDim2.new(0, 50, 0, 24),
        Position = UDim2.new(1, -60, 0.5, -12),
        BorderSizePixel = 0,
        Parent = frame,
        ZIndex = 16,
        Children = {
            Create({ Type = "UICorner", CornerRadius = UDim.new(1, 0) })
        }
    })
    
    local knob = Create({
        Type = "Frame",
        BackgroundColor3 = Theme.TextMuted,
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, 2, 0.5, -10),
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
            TweenService:Create(switch, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent}):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {
                Position = UDim2.new(1, -22, 0.5, -10),
                BackgroundColor3 = Theme.Text
            }):Play()
        else
            TweenService:Create(switch, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Secondary}):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {
                Position = UDim2.new(0, 2, 0.5, -10),
                BackgroundColor3 = Theme.TextMuted
            }):Play()
        end
        
        if flag then
            self.Flags[flag] = state
        end
        
        if options.Callback then
            options.Callback(state)
        end
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
    
    local frame = Create({
        Type = "Frame",
        BackgroundColor3 = Theme.Primary,
        BackgroundTransparency = 0.3,
        Size = UDim2.new(1, 0, 0, 60),
        BorderSizePixel = 0,
        Parent = parent,
        ZIndex = 15,
        Children = {
            Create({ Type = "UICorner", CornerRadius = UDim.new(0, 8) })
        }
    })
    
    -- Title
    Create({
        Type = "TextLabel",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 12, 0, 8),
        Text = options.Name or "Slider",
        TextColor3 = Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
        ZIndex = 16
    })
    
    -- Value display
    local valueText = Create({
        Type = "TextLabel",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 12, 0, 28),
        Text = tostring(default) .. " " .. suffix,
        TextColor3 = Theme.AccentLight,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
        ZIndex = 16
    })
    
    -- Track
    local track = Create({
        Type = "Frame",
        BackgroundColor3 = Theme.Secondary,
        Size = UDim2.new(1, -24, 0, 4),
        Position = UDim2.new(0, 12, 0, 48),
        BorderSizePixel = 0,
        Parent = frame,
        ZIndex = 16,
        Children = {
            Create({ Type = "UICorner", CornerRadius = UDim.new(1, 0) })
        }
    })
    
    -- Fill
    local fill = Create({
        Type = "Frame",
        BackgroundColor3 = Theme.Accent,
        Size = UDim2.new(0, 0, 1, 0),
        BorderSizePixel = 0,
        Parent = track,
        ZIndex = 17,
        Children = {
            Create({ Type = "UICorner", CornerRadius = UDim.new(1, 0) })
        }
    })
    
    -- Knob
    local knob = Create({
        Type = "Frame",
        BackgroundColor3 = Theme.Text,
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, -8, 0.5, -8),
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
        if options.Round then
            value = math.round(value / options.Round) * options.Round
        end
        value = math.clamp(value, min, max)
        
        local fillWidth = (value - min) / (max - min) * trackSize.X
        fill.Size = UDim2.new(0, fillWidth, 1, 0)
        knob.Position = UDim2.new(0, fillWidth - 8, 0.5, -8)
        valueText.Text = tostring(math.floor(value * 100) / 100) .. " " .. suffix
        
        if flag then
            self.Flags[flag] = value
        end
        
        if options.Callback then
            options.Callback(value)
        end
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
        BackgroundColor3 = Theme.Primary,
        BackgroundTransparency = 0.3,
        Size = UDim2.new(1, 0, 0, 40),
        BorderSizePixel = 0,
        Parent = parent,
        ZIndex = 15,
        Children = {
            Create({ Type = "UICorner", CornerRadius = UDim.new(0, 8) })
        }
    })
    
    -- Text
    Create({
        Type = "TextLabel",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -70, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        Text = options.Name or "Dropdown",
        TextColor3 = Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
        ZIndex = 16
    })
    
    -- Selected value
    local selectedText = Create({
        Type = "TextLabel",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 100, 1, 0),
        Position = UDim2.new(1, -110, 0, 0),
        Text = default,
        TextColor3 = Theme.AccentLight,
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = frame,
        ZIndex = 16
    })
    
    -- Arrow
    local arrow = Create({
        Type = "ImageLabel",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -30, 0.5, -10),
        Image = "rbxassetid://10747302107",  -- Down arrow
        ImageColor3 = Theme.TextMuted,
        Parent = frame,
        ZIndex = 16
    })
    
    -- Dropdown menu
    local menu = Create({
        Type = "Frame",
        BackgroundColor3 = Theme.Surface,
        Size = UDim2.new(0, 200, 0, 0),
        Position = UDim2.new(0, frame.AbsolutePosition.X + 10, 0, frame.AbsolutePosition.Y + 45),
        BorderSizePixel = 0,
        Visible = false,
        Parent = self.Gui,
        ZIndex = 20,
        ClipsDescendants = true,
        Children = {
            Create({ Type = "UICorner", CornerRadius = UDim.new(0, 8) }),
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
    
    -- Create items
    for _, item in ipairs(items) do
        local btn = Create({
            Type = "TextButton",
            BackgroundColor3 = Theme.Secondary,
            BackgroundTransparency = 0.5,
            Size = UDim2.new(1, -10, 0, 30),
            Text = "",
            AutoButtonColor = false,
            Parent = menu,
            ZIndex = 21,
            Children = {
                Create({ Type = "UICorner", CornerRadius = UDim.new(0, 4) }),
                Create({
                    Type = "TextLabel",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -10, 1, 0),
                    Position = UDim2.new(0, 5, 0, 0),
                    Text = item,
                    TextColor3 = Theme.Text,
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
            
            if flag then
                self.Flags[flag] = item
            end
            
            if options.Callback then
                options.Callback(item)
            end
            
            -- Close menu
            TweenService:Create(menu, TweenInfo.new(0.2), {Size = UDim2.new(0, 200, 0, 0)}):Play()
            wait(0.2)
            menu.Visible = false
            isOpen = false
            arrow.Image = "rbxassetid://10747302107"
        end)
    end
    
    -- Toggle dropdown
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if isOpen then
                TweenService:Create(menu, TweenInfo.new(0.2), {Size = UDim2.new(0, 200, 0, 0)}):Play()
                wait(0.2)
                menu.Visible = false
                arrow.Image = "rbxassetid://10747302107"
            else
                menu.Position = UDim2.new(0, frame.AbsolutePosition.X + 10, 0, frame.AbsolutePosition.Y + 45)
                menu.Size = UDim2.new(0, 200, 0, 0)
                menu.Visible = true
                TweenService:Create(menu, TweenInfo.new(0.2), {Size = UDim2.new(0, 200, 0, #items * 32 + 10)}):Play()
                arrow.Image = "rbxassetid://10747299867"  -- Up arrow
            end
            isOpen = not isOpen
        end
    end)
    
    return { SetValue = function(v) selected = v; selectedText.Text = v end, GetValue = function() return selected end }
end

-- ========== NOTIFICATION ==========
function Library:Notify(options)
    local notif = Create({
        Type = "Frame",
        BackgroundColor3 = Theme.Surface,
        Size = UDim2.new(0, 300, 0, 80),
        Position = UDim2.new(1, -320, 0, 20),
        BorderSizePixel = 0,
        Parent = self.Gui,
        ZIndex = 100,
        Children = {
            Create({ Type = "UICorner", CornerRadius = UDim.new(0, 12) }),
            Create({
                Type = "UIStroke",
                Color = Theme.Accent,
                Thickness = 1,
                Transparency = 0.5
            }),
            Create({
                Type = "TextLabel",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -20, 0, 25),
                Position = UDim2.new(0, 10, 0, 8),
                Text = options.Title or "Notification",
                TextColor3 = Theme.AccentLight,
                Font = Enum.Font.GothamBold,
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 101
            }),
            Create({
                Type = "TextLabel",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -20, 0, 40),
                Position = UDim2.new(0, 10, 0, 35),
                Text = options.Content or "",
                TextColor3 = Theme.Text,
                Font = Enum.Font.Gotham,
                TextSize = 14,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 101
            })
        }
    })
    
    -- Slide in
    notif.Position = UDim2.new(1, 0, 0, 20)
    TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {
        Position = UDim2.new(1, -320, 0, 20)
    }):Play()
    
    -- Auto destroy
    task.wait(options.Duration or 5)
    TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {
        Position = UDim2.new(1, 0, 0, 20)
    }):Play()
    task.wait(0.3)
    notif:Destroy()
end

-- ========== DESTROY ==========
function Library:Destroy()
    self.Gui:Destroy()
end

-- ========== EXPORT ==========
return Library
