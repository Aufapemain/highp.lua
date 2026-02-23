-- [[ AURAlib v1.0 - PROFESSIONAL UI LIBRARY ]] --
-- Created by Gemini (Your AI Peer)

local AuraLib = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = game.Players.LocalPlayer

function AuraLib:CreateMain(title)
    local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
    ScreenGui.Name = "AuraLib_UI"
    ScreenGui.ResetOnSpawn = false

    -- Main Frame (Glassmorphism Effect)
    local Main = Instance.new("Frame", ScreenGui)
    Main.Name = "MainFrame"
    Main.Size = UDim2.new(0, 450, 0, 300)
    Main.Position = UDim2.new(0.5, -225, 0.5, -150)
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true

    local Corner = Instance.new("UICorner", Main)
    Corner.CornerRadius = UDim.new(0, 10)

    local Stroke = Instance.new("UIStroke", Main)
    Stroke.Thickness = 2
    Stroke.Color = Color3.fromRGB(45, 45, 60)
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    -- Sidebar
    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Size = UDim2.new(0, 140, 1, 0)
    Sidebar.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    Sidebar.BorderSizePixel = 0

    local SidebarList = Instance.new("UIListLayout", Sidebar)
    SidebarList.Padding = UDim.new(0, 5)
    SidebarList.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local TopPadding = Instance.new("UIPadding", Sidebar)
    TopPadding.PaddingTop = UDim.new(0, 15)

    -- Title
    local Title = Instance.new("TextLabel", Sidebar)
    Title.Text = title:upper()
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.TextColor3 = Color3.fromRGB(180, 160, 255)
    Title.TextSize = 16

    -- Container for Pages
    local PageHolder = Instance.new("Frame", Main)
    PageHolder.Position = UDim2.new(0, 150, 0, 10)
    PageHolder.Size = UDim2.new(1, -160, 1, -20)
    PageHolder.BackgroundTransparency = 1

    -- Dragging Logic
    local dragging, dragInput, dragStart, startPos
    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

    local tabs = {}
    function tabs:CreateTab(name)
        local Page = Instance.new("ScrollingFrame", PageHolder)
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 2
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        
        local PageList = Instance.new("UIListLayout", Page)
        PageList.Padding = UDim.new(0, 8)
        PageList.SortOrder = Enum.SortOrder.LayoutOrder
        PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y)
        end)

        local TabBtn = Instance.new("TextButton", Sidebar)
        TabBtn.Size = UDim2.new(0, 120, 0, 35)
        TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        TabBtn.Text = name
        TabBtn.Font = Enum.Font.GothamSemibold
        TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        TabBtn.TextSize = 13
        local BtnCorner = Instance.new("UICorner", TabBtn)
        BtnCorner.CornerRadius = UDim.new(0, 6)

        TabBtn.MouseButton1Click:Connect(function()
            for _, p in pairs(PageHolder:GetChildren()) do p.Visible = false end
            for _, b in pairs(Sidebar:GetChildren()) do 
                if b:IsA("TextButton") then TweenService:Create(b, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(30, 30, 40)}):Play() end
            end
            Page.Visible = true
            TweenService:Create(TabBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(80, 60, 180)}):Play()
        end)

        local elements = {}
        
        -- Modern Button
        function elements:CreateButton(text, callback)
            local Btn = Instance.new("TextButton", Page)
            Btn.Size = UDim2.new(1, -10, 0, 35)
            Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
            Btn.Text = text
            Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            Btn.Font = Enum.Font.Gotham
            Btn.TextSize = 14
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
            Btn.MouseButton1Click:Connect(callback)
        end

        -- Modern TextBox
        function elements:CreateTextBox(label, placeholder, callback)
            local BoxFrame = Instance.new("Frame", Page)
            BoxFrame.Size = UDim2.new(1, -10, 0, 50)
            BoxFrame.BackgroundTransparency = 1
            
            local Lbl = Instance.new("TextLabel", BoxFrame)
            Lbl.Text = label
            Lbl.Size = UDim2.new(1, 0, 0, 20)
            Lbl.TextColor3 = Color3.fromRGB(150, 150, 150)
            Lbl.Font = Enum.Font.Gotham
            Lbl.TextSize = 12
            Lbl.TextXAlignment = Enum.TextXAlignment.Left

            local Input = Instance.new("TextBox", BoxFrame)
            Input.Position = UDim2.new(0, 0, 0, 20)
            Input.Size = UDim2.new(1, 0, 0, 25)
            Input.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
            Input.Text = ""
            Input.PlaceholderText = placeholder
            Input.TextColor3 = Color3.fromRGB(255, 255, 255)
            Input.Font = Enum.Font.Gotham
            Input.TextSize = 14
            Instance.new("UICorner", Input).CornerRadius = UDim.new(0, 4)
            Input.FocusLost:Connect(function() callback(Input.Text) end)
        end

        return elements
    end
    return tabs
end

-- [[ IMPLEMENTASI SCRIPT ]] --

local UI = AuraLib:CreateMain("Aura V7")
local MainTab = UI:CreateTab("Garden")
local MoveTab = UI:CreateTab("Movement")

-- Garden Logic
MainTab:CreateButton("Plant At Feet (Efficiency 100%)", function()
    local Char = LocalPlayer.Character
    local Tool = Char and Char:FindFirstChildOfClass("Tool")
    if Tool and Char:FindFirstChild("HumanoidRootPart") then
        local args = {
            [1] = Tool.Name,
            [2] = Char.HumanoidRootPart.Position - Vector3.new(0, 3, 0)
        }
        game:GetService("ReplicatedStorage").RemoteEvents.PlantSeed:InvokeServer(unpack(args))
    end
end)

-- Movement Logic
local WS, JP = 16, 50
MoveTab:CreateTextBox("WalkSpeed", "Default 16", function(val) WS = tonumber(val) or 16 end)
MoveTab:CreateTextBox("JumpPower", "Default 50", function(val) JP = tonumber(val) or 50 end)

RunService.Heartbeat:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = WS
        LocalPlayer.Character.Humanoid.JumpPower = JP
    end
end)

print("AuraLib Professional Loaded.")
