--[[
    ███████╗██╗░░░██╗███████╗░██████╗░██████╗░████████╗
    ██╔════╝╚██╗░██╔╝██╔════╝██╔════╝░██╔══██╗╚══██╔══╝
    █████╗░░░╚████╔╝░█████╗░░██║░░██╗░██████╔╝░░░██║░░░
    ██╔══╝░░░░╚██╔╝░░██╔══╝░░██║░░╚██╗██╔══██╗░░░██║░░░
    ███████╗░░░██║░░░███████╗╚██████╔╝██║░░██║░░░██║░░░
    ╚══════╝░░░╚═╝░░░╚══════╝░╚═════╝░╚═╝░░╚═╝░░░╚═╝░░░

    ██╗██████╗░██╗░░██╗░█████╗░███╗░░██╗███████╗
    ██║██╔══██╗██║░░██║██╔══██╗████╗░██║██╔════╝
    ██║██████╔╝███████║██║░░██║██╔██╗██║█████╗░░
    ██║██╔═══╝░██╔══██║██║░░██║██║╚████║██╔══╝░░
    ██║██║░░░░░██║░░██║╚█████╔╝██║░╚███║███████╗
    ╚═╝╚═╝░░░░░╚═╝░░╚═╝░╚════╝░╚═╝░░╚══╝╚══════╝

    IPHONE-STYLE UI LIBRARY v1.0
    FITUR: Title center + Search bar + Scrollable tabs + Smooth animations
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
    Background = Color3.fromRGB(28, 28, 30),      -- iOS dark background
    Surface = Color3.fromRGB(44, 44, 46),         -- iOS secondary background
    Primary = Color3.fromRGB(58, 58, 60),         -- iOS tertiary background
    Accent = Color3.fromRGB(10, 132, 255),        -- iOS blue
    AccentLight = Color3.fromRGB(90, 200, 250),   -- Light blue
    Text = Color3.fromRGB(255, 255, 255),
    TextMuted = Color3.fromRGB(150, 150, 160),
    Shadow = Color3.fromRGB(0, 0, 0),
    SearchBg = Color3.fromRGB(58, 58, 60)
}

-- ========== UTILITY ==========
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

local function AddShadow(parent, intensity)
    intensity = intensity or 5
    for i = 1, intensity do
        local shadow = Create({
            Type = "Frame",
            BackgroundColor3 = Theme.Shadow,
            BackgroundTransparency = 0.7 - (i * 0.1),
            Size = parent.Size + UDim2.new(0, i*2, 0, i*2),
            Position = parent.Position - UDim2.new(0, i, 0, i),
            AnchorPoint = parent.AnchorPoint,
            BorderSizePixel = 0,
            ZIndex = parent.ZIndex - i,
            Parent = parent.Parent,
            Children = {
                Create({
                    Type = "UICorner",
                    CornerRadius = UDim.new(0, (parent:FindFirstChildOfClass("UICorner") and parent:FindFirstChildOfClass("UICorner").CornerRadius.Offset or 16) + i)
                })
            }
        })
    end
end

-- ========== WINDOW ==========
function Library:CreateWindow(title, options)
    options = options or {}
    local self = setmetatable({}, Library)

    self.Flags = {}
    self.Tabs = {}
    self.CurrentTab = nil

    -- Main GUI
    self.Gui = Create({
        Type = "ScreenGui",
        Name = "iPhoneUI_" .. math.random(1000, 9999),
        Parent = LocalPlayer:WaitForChild("PlayerGui"),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 1000
    })

    -- Main Window Frame (big rounded corners)
    self.Window = Create({
        Type = "Frame",
        BackgroundColor3 = Theme.Background,
        Size = options.Size or UDim2.new(0, 380, 0, 600), -- iPhone-like width
        Position = options.Position or UDim2.new(0.5, -190, 0.5, -300),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = self.Gui,
        ZIndex = 10,
        Children = {
            Create({ Type = "UICorner", CornerRadius = UDim.new(0, 24) }) -- large corner
        }
    })

    AddShadow(self.Window, 8)

    -- ===== TOP AREA (Title + Search) =====
    local TopArea = Create({
        Type = "Frame",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 80),
        Position = UDim2.new(0, 0, 0, 0),
        Parent = self.Window,
        ZIndex = 11
    })

    -- Title (centered)
    self.TitleLabel = Create({
        Type = "TextLabel",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, 10),
        Text = title or "EyeGPT",
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamBold,  -- closest to SF Pro
        TextSize = 20,
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = TopArea,
        ZIndex = 12
    })

    -- Search Bar
    self.SearchBar = Create({
        Type = "Frame",
        BackgroundColor3 = Theme.SearchBg,
        Size = UDim2.new(0, 340, 0, 36),
        Position = UDim2.new(0.5, -170, 0, 40),
        AnchorPoint = Vector2.new(0.5, 0),
        BorderSizePixel = 0,
        Parent = TopArea,
        ZIndex = 13,
        Children = {
            Create({ Type = "UICorner", CornerRadius = UDim.new(0, 10) }),
            Create({
                Type = "TextBox",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -30, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                PlaceholderText = "Search",
                PlaceholderColor3 = Theme.TextMuted,
                Text = "",
                TextColor3 = Theme.Text,
                Font = Enum.Font.Gotham,
                TextSize = 16,
                ClearTextOnFocus = false,
                ZIndex = 14
            }),
            Create({
                Type = "ImageLabel",
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(1, -30, 0.5, -10),
                Image = "rbxassetid://10747319789", -- search icon (placeholder)
                ImageColor3 = Theme.TextMuted,
                ZIndex = 14
            })
        }
    })

    -- ===== TAB BAR (Horizontal Scroll) =====
    self.TabContainer = Create({
        Type = "Frame",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 50),
        Position = UDim2.new(0, 0, 0, 90),
        Parent = self.Window,
        ZIndex = 11
    })

    -- ScrollingFrame for tabs
    self.TabScroller = Create({
        Type = "ScrollingFrame",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 0, -- hide scrollbar, but scrolling still works
        ScrollingDirection = Enum.ScrollingDirection.X,
        ScrollingEnabled = true,
        HorizontalScrollBarInset = Enum.ScrollBarInset.None,
        VerticalScrollBarInset = Enum.ScrollBarInset.None,
        Parent = self.TabContainer,
        ZIndex = 12,
        Children = {
            Create({
                Type = "UIListLayout",
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(0, 8)
            }),
            Create({
                Type = "UIPadding",
                PaddingLeft = UDim.new(0, 12),
                PaddingRight = UDim.new(0, 12)
            })
        }
    })

    -- ===== CONTENT AREA =====
    self.ContentContainer = Create({
        Type = "Frame",
        BackgroundColor3 = Theme.Surface,
        Size = UDim2.new(1, -20, 1, -160),
        Position = UDim2.new(0, 10, 0, 150),
        BorderSizePixel = 0,
        Parent = self.Window,
        ZIndex = 11,
        Children = {
            Create({ Type = "UICorner", CornerRadius = UDim.new(0, 16) })
        }
    })

    -- Page container inside content
    self.PageContainer = Create({
        Type = "Frame",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = self.ContentContainer,
        ZIndex = 12
    })

    -- ===== DRAGGABLE (by TopArea) =====
    local dragging = false
    local dragStart, windowPos

    TopArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            windowPos = self.Window.Position
        end
    end)

    TopArea.InputChanged:Connect(function(input)
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

    return self
end

-- ========== TAB ==========
function Library:CreateTab(name, icon)
    icon = icon or ""

    -- Tab Button
    local tabBtn = Create({
        Type = "TextButton",
        BackgroundColor3 = Theme.Primary,
        BackgroundTransparency = 0.3,
        Size = UDim2.new(0, 100, 0, 36),
        Text = "",
        AutoButtonColor = false,
        Parent = self.TabScroller,
        ZIndex = 13,
        Children = {
            Create({ Type = "UICorner", CornerRadius = UDim.new(0, 12) })
        }
    })

    -- Icon (optional)
    if icon ~= "" then
        Create({
            Type = "ImageLabel",
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(0, 8, 0.5, -10),
            Image = icon,
            ImageColor3 = Theme.TextMuted,
            Parent = tabBtn,
            ZIndex = 14
        })
    end

    -- Tab Text
    local tabText = Create({
        Type = "TextLabel",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, icon ~= "" and 30 or 10, 0, 0),
        Text = name,
        TextColor3 = Theme.TextMuted,
        Font = Enum.Font.Gotham,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = tabBtn,
        ZIndex = 14
    })

    -- Page
    local page = Create({
        Type = "ScrollingFrame",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Theme.Accent,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        Parent = self.PageContainer,
        ZIndex = 13,
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

    -- Update CanvasSize of TabScroller
    local function UpdateTabScrollerSize()
        local totalWidth = #self.Tabs * (100 + 8) + 24 -- 100 width + 8 padding + 12 left+right
        self.TabScroller.CanvasSize = UDim2.new(0, totalWidth, 0, 0)
    end
    UpdateTabScrollerSize()

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
    tab.Page.Visible = true
end

-- ========== SECTION ==========
function Library:CreateSection(parent, title)
    local section = Create({
        Type = "Frame",
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 0.2,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BorderSizePixel = 0,
        Parent = parent,
        ZIndex = 14,
        Children = {
            Create({ Type = "UICorner", CornerRadius = UDim.new(0, 12) })
        }
    })

    Create({
        Type = "TextLabel",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 12, 0, 8),
        Text = title,
        TextColor3 = Theme.Accent,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = section,
        ZIndex = 15
    })

    local content = Create({
        Type = "Frame",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 0),
        Position = UDim2.new(0, 10, 0, 40),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = section,
        ZIndex = 15,
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
        Size = UDim2.new(1, 0, 0, 45),
        Text = "",
        AutoButtonColor = false,
        Parent = parent,
        ZIndex = 16,
        Children = {
            Create({ Type = "UICorner", CornerRadius = UDim.new(0, 10) })
        }
    })

    local text = Create({
        Type = "TextLabel",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        Text = options.Name or "Button",
        TextColor3 = Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = btn,
        ZIndex = 17
    })

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {
            Size = UDim2.new(1, 0, 0, 48),
            BackgroundColor3 = Theme.AccentLight
        }):Play()
    end)

    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {
            Size = UDim2.new(1, 0, 0, 45),
            BackgroundColor3 = Theme.Accent
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
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 0.2,
        Size = UDim2.new(1, 0, 0, 45),
        BorderSizePixel = 0,
        Parent = parent,
        ZIndex = 16,
        Children = {
            Create({ Type = "UICorner", CornerRadius = UDim.new(0, 10) })
        }
    })

    local text = Create({
        Type = "TextLabel",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -70, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        Text = options.Name or "Toggle",
        TextColor3 = Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
        ZIndex = 17
    })

    local switch = Create({
        Type = "Frame",
        BackgroundColor3 = Theme.Primary,
        Size = UDim2.new(0, 50, 0, 24),
        Position = UDim2.new(1, -60, 0.5, -12),
        BorderSizePixel = 0,
        Parent = frame,
        ZIndex = 17,
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
        ZIndex = 18,
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
            TweenService:Create(switch, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Primary}):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {
                Position = UDim2.new(0, 2, 0.5, -10),
                BackgroundColor3 = Theme.TextMuted
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

    local frame = Create({
        Type = "Frame",
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 0.2,
        Size = UDim2.new(1, 0, 0, 70),
        BorderSizePixel = 0,
        Parent = parent,
        ZIndex = 16,
        Children = {
            Create({ Type = "UICorner", CornerRadius = UDim.new(0, 10) })
        }
    })

    Create({
        Type = "TextLabel",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 25),
        Position = UDim2.new(0, 12, 0, 8),
        Text = options.Name or "Slider",
        TextColor3 = Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
        ZIndex = 17
    })

    local valueText = Create({
        Type = "TextLabel",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 25),
        Position = UDim2.new(0, 12, 0, 30),
        Text = tostring(default) .. " " .. suffix,
        TextColor3 = Theme.Accent,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
        ZIndex = 17
    })

    local track = Create({
        Type = "Frame",
        BackgroundColor3 = Theme.Primary,
        Size = UDim2.new(1, -24, 0, 6),
        Position = UDim2.new(0, 12, 0, 55),
        BorderSizePixel = 0,
        Parent = frame,
        ZIndex = 17,
        Children = {
            Create({ Type = "UICorner", CornerRadius = UDim.new(1, 0) })
        }
    })

    local fill = Create({
        Type = "Frame",
        BackgroundColor3 = Theme.Accent,
        Size = UDim2.new(0, 0, 1, 0),
        BorderSizePixel = 0,
        Parent = track,
        ZIndex = 18,
        Children = {
            Create({ Type = "UICorner", CornerRadius = UDim.new(1, 0) })
        }
    })

    local knob = Create({
        Type = "Frame",
        BackgroundColor3 = Theme.Text,
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, -10, 0.5, -10),
        BorderSizePixel = 0,
        Parent = track,
        ZIndex = 19,
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
        value = math.clamp(value, min, max)

        local fillWidth = (value - min) / (max - min) * trackSize.X
        fill.Size = UDim2.new(0, fillWidth, 1, 0)
        knob.Position = UDim2.new(0, fillWidth - 10, 0.5, -10)
        valueText.Text = tostring(math.floor(value * 100) / 100) .. " " .. suffix

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
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 0.2,
        Size = UDim2.new(1, 0, 0, 45),
        BorderSizePixel = 0,
        Parent = parent,
        ZIndex = 16,
        Children = {
            Create({ Type = "UICorner", CornerRadius = UDim.new(0, 10) })
        }
    })

    Create({
        Type = "TextLabel",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        Text = options.Name or "Dropdown",
        TextColor3 = Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
        ZIndex = 17
    })

    local selectedText = Create({
        Type = "TextLabel",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 100, 1, 0),
        Position = UDim2.new(1, -120, 0, 0),
        Text = default,
        TextColor3 = Theme.Accent,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = frame,
        ZIndex = 17
    })

    local arrow = Create({
        Type = "ImageLabel",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -30, 0.5, -10),
        Image = "rbxassetid://10747302107", -- down arrow
        ImageColor3 = Theme.TextMuted,
        Parent = frame,
        ZIndex = 17
    })

    local menu = Create({
        Type = "Frame",
        BackgroundColor3 = Theme.Surface,
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
            BackgroundColor3 = Theme.Primary,
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
            if flag then self.Flags[flag] = item end
            if options.Callback then options.Callback(item) end
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
                arrow.Image = "rbxassetid://10747299867" -- up arrow
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
        Position = UDim2.new(1, -320, 1, -100),
        AnchorPoint = Vector2.new(0, 1),
        BorderSizePixel = 0,
        Parent = self.Gui,
        ZIndex = 200,
        Children = {
            Create({ Type = "UICorner", CornerRadius = UDim.new(0, 14) }),
            Create({
                Type = "UIStroke",
                Color = Theme.Accent,
                Thickness = 2,
                Transparency = 0.3
            })
        }
    })

    Create({
        Type = "TextLabel",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 25),
        Position = UDim2.new(0, 10, 0, 8),
        Text = options.Title or "Notification",
        TextColor3 = Theme.Accent,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notif,
        ZIndex = 201
    })

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
        Parent = notif,
        ZIndex = 201
    })

    TweenService:Create(notif, TweenInfo.new(0.4), {Position = UDim2.new(1, -320, 1, -100)}):Play()
    task.wait(options.Duration or 5)
    TweenService:Create(notif, TweenInfo.new(0.4), {Position = UDim2.new(1, 20, 1, -100)}):Play()
    task.wait(0.4)
    notif:Destroy()
end

-- ========== DESTROY ==========
function Library:Destroy()
    self.Gui:Destroy()
end

return Library
