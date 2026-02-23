--[[
    SIMPLE BLACK UI v2 - FIXED
    - Muncul di tengah
    - Dragable mulus
    - Minimize smooth
]]

local Library = {}
Library.__index = Library

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ========== THEME ==========
local Theme = {
    Background = Color3.fromRGB(20, 20, 20),
    Surface = Color3.fromRGB(30, 30, 30),
    Text = Color3.fromRGB(255, 255, 255),
    Shadow = Color3.fromRGB(0, 0, 0)
}

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

local function AddShadow(parent)
    for _, v in pairs(parent.Parent:GetChildren()) do
        if v.Name == "Shadow" then v:Destroy() end
    end
    for i = 1, 5 do
        local shadow = Create({
            Type = "Frame",
            Name = "Shadow",
            BackgroundColor3 = Theme.Shadow,
            BackgroundTransparency = 0.7 - (i * 0.1),
            Size = parent.Size + UDim2.new(0, i*2, 0, i*2),
            Position = parent.Position - UDim2.new(0, i, 0, i),
            AnchorPoint = parent.AnchorPoint,
            BorderSizePixel = 0,
            ZIndex = parent.ZIndex - i,
            Parent = parent.Parent,
            Children = { Create({ Type = "UICorner", CornerRadius = UDim.new(0, 12 + i) }) }
        })
    end
end

function Library:CreateWindow(options)
    options = options or {}
    local self = setmetatable({}, Library)
    
    self.Minimized = false
    self.OriginalSize = options.Size or UDim2.new(0, 500, 0, 400)
    self.MinimizedSize = UDim2.new(0, 500, 0, 40)
    
    self.Gui = Create({
        Type = "ScreenGui",
        Name = "BlackUI_" .. math.random(1000, 9999),
        Parent = LocalPlayer:WaitForChild("PlayerGui"),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    -- Window (posisi tengah)
    self.Window = Create({
        Type = "Frame",
        BackgroundColor3 = Theme.Background,
        Size = self.OriginalSize,
        Position = UDim2.new(0.5, -self.OriginalSize.X.Offset/2, 0.5, -self.OriginalSize.Y.Offset/2),
        AnchorPoint = Vector2.new(0, 0), -- Biar gampang, kita set posisi manual
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = self.Gui,
        ZIndex = 10,
        Children = { Create({ Type = "UICorner", CornerRadius = UDim.new(0, 12) }) }
    })
    
    AddShadow(self.Window)
    
    -- Title Bar
    self.TitleBar = Create({
        Type = "Frame",
        BackgroundColor3 = Theme.Surface,
        Size = UDim2.new(1, 0, 0, 40),
        BorderSizePixel = 0,
        Parent = self.Window,
        ZIndex = 11,
        Children = { Create({ Type = "UICorner", CornerRadius = UDim.new(0, 12) }) }
    })
    
    self.Title = Create({
        Type = "TextLabel",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -80, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        Text = options.Title or "Black UI",
        TextColor3 = Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.TitleBar,
        ZIndex = 12
    })
    
    self.MinBtn = Create({
        Type = "ImageButton",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -40, 0.5, -15),
        Image = "rbxassetid://10747308083",
        ImageColor3 = Theme.Text,
        Parent = self.TitleBar,
        ZIndex = 12
    })
    
    -- Content
    self.Content = Create({
        Type = "Frame",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 1, -55),
        Position = UDim2.new(0, 10, 0, 45),
        Parent = self.Window,
        ZIndex = 11
    })
    
    -- ===== DRAG (FIXED) =====
    local dragging = false
    local dragInput, dragStart, startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        self.Window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        AddShadow(self.Window)
    end
    
    self.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.Window.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    self.TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- ===== MINIMIZE =====
    self.MinBtn.MouseButton1Click:Connect(function()
        self.Minimized = not self.Minimized
        if self.Minimized then
            self.OriginalSize = self.Window.Size
            TweenService:Create(self.Window, TweenInfo.new(0.3), { Size = self.MinimizedSize }):Play()
        else
            TweenService:Create(self.Window, TweenInfo.new(0.3), { Size = self.OriginalSize }):Play()
        end
        wait(0.3)
        AddShadow(self.Window)
    end)
    
    return self
end

return Library
