--[[
    ██████╗ ██╗      █████╗  ██████╗██╗  ██╗
    ██╔══██╗██║     ██╔══██╗██╔════╝██║ ██╔╝
    ██████╔╝██║     ███████║██║     █████╔╝ 
    ██╔══██╗██║     ██╔══██║██║     ██╔═██╗ 
    ██████╔╝███████╗██║  ██║╚██████╗██║  ██╗
    ╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝

    SIMPLE BLACK UI v1.0
    Fitur: Drag, Minimize smooth, Shadow
]]

local Library = {}
Library.__index = Library

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ========== THEME (HITAM DOANG) ==========
local Theme = {
    Background = Color3.fromRGB(20, 20, 20),      -- Hitam pekat
    Surface = Color3.fromRGB(30, 30, 30),         -- Hitam sedikit lebih terang
    Text = Color3.fromRGB(255, 255, 255),         -- Putih
    Shadow = Color3.fromRGB(0, 0, 0)              -- Hitam buat bayangan
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

-- Fungsi buat bikin bayangan
local function CreateShadow(parent, intensity)
    intensity = intensity or 5
    
    -- Hapus shadow lama kalo ada
    for _, v in pairs(parent.Parent:GetChildren()) do
        if v.Name == "Shadow" then
            v:Destroy()
        end
    end
    
    -- Buat shadow multi-layer
    for i = 1, intensity do
        local shadow = Create({
            Type = "Frame",
            Name = "Shadow",
            BackgroundColor3 = Theme.Shadow,
            BackgroundTransparency = 0.7 - (i * 0.08),
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
    self.OriginalSize = options.Size or UDim2.new(0, 500, 0, 400)
    self.MinimizedSize = UDim2.new(0, 500, 0, 40) -- Tinggal title bar doang
    
    -- Main GUI
    self.Gui = Create({
        Type = "ScreenGui",
        Name = "BlackUI_" .. math.random(1000, 9999),
        Parent = LocalPlayer:WaitForChild("PlayerGui"),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    -- Main Window (persegi panjang hitam)
    self.Window = Create({
        Type = "Frame",
        BackgroundColor3 = Theme.Background,
        Size = self.OriginalSize,
        Position = options.Position or UDim2.new(0.5, -250, 0.5, -200),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = self.Gui,
        ZIndex = 10,
        Children = {
            Create({ Type = "UICorner", CornerRadius = UDim.new(0, 12) }) -- Rounded sedikit
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
            Create({ Type = "UICorner", CornerRadius = UDim.new(0, 12) })
        }
    })
    
    -- Title Text (optional, bisa diisi kalo mau)
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
    
    -- Minimize Button
    self.MinBtn = Create({
        Type = "ImageButton",
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -70, 0.5, -15),
        Image = "rbxassetid://10747308083", -- Icon minus
        ImageColor3 = Theme.Text,
        Parent = self.TitleBar,
        ZIndex = 12
    })
    
    -- ===== DRAG MECHANISM =====
    local dragging = false
    local dragStart, windowPos
    
    self.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            windowPos = self.Window.Position
            CreateShadow(self.Window, 6) -- Bayangan tebal pas di-drag
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
            -- Update bayangan setiap kali geser
            CreateShadow(self.Window, 6)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            -- Bayangan tetap ada
        end
    end)
    
    -- ===== MINIMIZE SMOOTH PAKE TWEEN =====
    self.MinBtn.MouseButton1Click:Connect(function()
        self.Minimized = not self.Minimized
        
        if self.Minimized then
            -- Minimize: simpan ukuran asli, lalu kecilin
            self.OriginalSize = self.Window.Size
            TweenService:Create(self.Window, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {
                Size = self.MinimizedSize
            }):Play()
        else
            -- Restore: balikin ke ukuran asli
            TweenService:Create(self.Window, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {
                Size = self.OriginalSize
            }):Play()
        end
        
        -- Update bayangan setelah resize
        wait(0.3)
        CreateShadow(self.Window, 5)
    end)
    
    -- Hover effect di tombol minimize
    self.MinBtn.MouseEnter:Connect(function()
        TweenService:Create(self.MinBtn, TweenInfo.new(0.2), {
            ImageColor3 = Color3.fromRGB(200, 200, 200)
        }):Play()
    end)
    
    self.MinBtn.MouseLeave:Connect(function()
        TweenService:Create(self.MinBtn, TweenInfo.new(0.2), {
            ImageColor3 = Theme.Text
        }):Play()
    end)
    
    -- Buat bayangan awal
    CreateShadow(self.Window, 5)
    
    -- Content container (kosong, buat lo isi nanti)
    self.Content = Create({
        Type = "Frame",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 1, -55),
        Position = UDim2.new(0, 10, 0, 45),
        Parent = self.Window,
        ZIndex = 11
    })
    
    return self
end

-- ========== DESTROY ==========
function Library:Destroy()
    self.Gui:Destroy()
end

return Library
