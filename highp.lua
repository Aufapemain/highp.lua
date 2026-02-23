--[[
    ________________________________________________________________
    ███████╗██╗███╗░░░███╗██████╗░██╗░░░░░███████╗
    ██╔════╝██║████╗░████║██╔══██╗██║░░░░░██╔════╝
    █████╗░░██║██╔████╔██║██████╔╝██║░░░░░█████╗░░
    ██╔══╝░░██║██║╚██╔╝██║██╔═══╝░██║░░░░░██╔══╝░░
    ██║░░░░░██║██║░╚═╝░██║██║░░░░░███████╗███████╗
    ╚═╝░░░░░╚═╝╚═╝░░░░░╚═╝╚═╝░░░░░╚══════╝╚══════╝

    SIMPLE UI LIBRARY v1.0
    Fitur: Drag dengan bayangan, Minimize, Rounded Corners
--]]

local Library = {}
Library.__index = Library

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ========== THEME ==========
local Theme = {
    Background = Color3.fromRGB(30, 30, 35),
    Surface = Color3.fromRGB(45, 45, 50),
    Accent = Color3.fromRGB(100, 100, 255),
    Text = Color3.fromRGB(255, 255, 255),
    Shadow = Color3.fromRGB(0, 0, 0)
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

-- Fungsi buat bikin bayangan (shadow)
local function CreateShadow(parent, intensity, offset)
    intensity = intensity or 4
    offset = offset or 2
    
    -- Hapus shadow lama kalo ada
    for _, v in pairs(parent.Parent:GetChildren()) do
        if v.Name == "Shadow" then
            v:Destroy()
        end
    end
    
    -- Buat shadow baru (multi layer)
    for i = 1, intensity do
        local shadow = Create({
            Type = "Frame",
            Name = "Shadow",
            BackgroundColor3 = Theme.Shadow,
            BackgroundTransparency = 0.6 - (i * 0.1),
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

-- ========== WINDOW ==========
function Library:CreateWindow(options)
    options = options or {}
    local self = setmetatable({}, Library)
    
    self.Minimized = false
    self.OriginalSize = options.Size or UDim2.new(0, 400, 0, 500)
    self.MinimizedSize = UDim2.new(0, 400, 0, 40)
    
    -- Main GUI
    self.Gui = Create({
        Type = "ScreenGui",
        Name = "SimpleUI_" .. math.random(1000, 9999),
        Parent = LocalPlayer:WaitForChild("PlayerGui"),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    -- Main Window Frame (kotak kubus dengan ujung rounded)
    self.Window = Create({
        Type = "Frame",
        BackgroundColor3 = Theme.Background,
        Size = self.OriginalSize,
        Position = options.Position or UDim2.new(0.5, -200, 0.5, -250),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = self.Gui,
        ZIndex = 10,
        Children = {
            Create({ Type = "UICorner", CornerRadius = UDim.new(0, 16) }) -- Rounded ujung
        }
    })
    
    -- Title Bar (buat drag dan minimize)
    self.TitleBar = Create({
        Type = "Frame",
        BackgroundColor3 = Theme.Surface,
        Size = UDim2.new(1, 0, 0, 40),
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
        Size = UDim2.new(1, -80, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        Text = options.Title or "Simple UI",
        TextColor3 = Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.TitleBar,
        ZIndex = 12
    })
    
    -- Minimize Button
    self.MinBtn = Create({
        Type = "ImageButton",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -70, 0.5, -15),
        Image = "rbxassetid://10747308083", -- minus icon
        ImageColor3 = Theme.Text,
        Parent = self.TitleBar,
        ZIndex = 12
    })
    
    -- Close Button
    self.CloseBtn = Create({
        Type = "ImageButton",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -35, 0.5, -15),
        Image = "rbxassetid://10747312666", -- X icon
        ImageColor3 = Theme.Text,
        Parent = self.TitleBar,
        ZIndex = 12
    })
    
    -- Content Container (tempat lo naro komponen nanti)
    self.Content = Create({
        Type = "Frame",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 1, -55),
        Position = UDim2.new(0, 10, 0, 45),
        Parent = self.Window,
        ZIndex = 11
    })
    
    -- ===== DRAG MECHANISM =====
    local dragging = false
    local dragStart, windowPos
    local shadowIntensity = 8
    
    self.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            windowPos = self.Window.Position
            
            -- Pas mulai drag, bayangan makin jelas
            CreateShadow(self.Window, shadowIntensity, 4)
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
            
            -- Update bayangan setiap kali posisi berubah
            CreateShadow(self.Window, shadowIntensity, 4)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            -- Bayangan tetap ada meskipun drag selesai
        end
    end)
    
    -- ===== MINIMIZE =====
    self.MinBtn.MouseButton1Click:Connect(function()
        self.Minimized = not self.Minimized
        
        if self.Minimized then
            -- Minimize: simpan ukuran asli, lalu kecilin
            self.OriginalSize = self.Window.Size
            TweenService:Create(self.Window, TweenInfo.new(0.3), {
                Size = self.MinimizedSize
            }):Play()
        else
            -- Restore: balikin ke ukuran asli
            TweenService:Create(self.Window, TweenInfo.new(0.3), {
                Size = self.OriginalSize
            }):Play()
        end
        
        -- Update bayangan
        CreateShadow(self.Window, shadowIntensity, 4)
    end)
    
    -- ===== CLOSE =====
    self.CloseBtn.MouseButton1Click:Connect(function()
        self:Destroy()
    end)
    
    -- Hover effects
    for _, btn in pairs({self.MinBtn, self.CloseBtn}) do
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {
                ImageColor3 = Theme.Accent
            }):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {
                ImageColor3 = Theme.Text
            }):Play()
        end)
    end
    
    -- Buat bayangan awal
    CreateShadow(self.Window, shadowIntensity, 4)
    
    return self
end

-- ========== SECTION (buat grouping komponen) ==========
function Library:CreateSection(parent, title)
    local section = Create({
        Type = "Frame",
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 0.3,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BorderSizePixel = 0,
        Parent = parent,
        ZIndex = 12,
        Children = {
            Create({ Type = "UICorner", CornerRadius = UDim.new(0, 12) })
        }
    })
    
    -- Title section
    Create({
        Type = "TextLabel",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 10, 0, 5),
        Text = title,
        TextColor3 = Theme.Accent,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = section,
        ZIndex = 13
    })
    
    -- Container untuk komponen
    local container = Create({
        Type = "Frame",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 0),
        Position = UDim2.new(0, 10, 0, 35),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = section,
        ZIndex = 13,
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
    
    return container
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
        ZIndex = 14,
        Children = {
            Create({ Type = "UICorner", CornerRadius = UDim.new(0, 8) })
        }
    })
    
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
        ZIndex = 15
    })
    
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
        BackgroundTransparency = 0.3,
        Size = UDim2.new(1, 0, 0, 40),
        BorderSizePixel = 0,
        Parent = parent,
        ZIndex = 14,
        Children = {
            Create({ Type = "UICorner", CornerRadius = UDim.new(0, 8) })
        }
    })
    
    local text = Create({
        Type = "TextLabel",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -70, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        Text = options.Name or "Toggle",
        TextColor3 = Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
        ZIndex = 15
    })
    
    local switch = Create({
        Type = "Frame",
        BackgroundColor3 = Theme.Surface,
        Size = UDim2.new(0, 50, 0, 24),
        Position = UDim2.new(1, -60, 0.5, -12),
        BorderSizePixel = 0,
        Parent = frame,
        ZIndex = 15,
        Children = {
            Create({ Type = "UICorner", CornerRadius = UDim.new(1, 0) })
        }
    })
    
    local knob = Create({
        Type = "Frame",
        BackgroundColor3 = Theme.Text,
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, 2, 0.5, -10),
        BorderSizePixel = 0,
        Parent = switch,
        ZIndex = 16,
        Children = {
            Create({ Type = "UICorner", CornerRadius = UDim.new(1, 0) })
        }
    })
    
    local state = options.Default or false
    
    local function SetState(newState)
        state = newState
        if state then
            TweenService:Create(switch, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent}):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {
                Position = UDim2.new(1, -22, 0.5, -10),
                BackgroundColor3 = Theme.Text
            }):Play()
        else
            TweenService:Create(switch, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Surface}):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {
                Position = UDim2.new(0, 2, 0.5, -10),
                BackgroundColor3 = Theme.Text
            }):Play()
        end
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

-- ========== DESTROY ==========
function Library:Destroy()
    self.Gui:Destroy()
end

return Library
