-- [[ NEBULA ENGINE v1.0 | BEYOND EVERYTHING ]] --
-- Pure source, no imitations. High-performance architecture.

local Nebula = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- UTILS (Sistem Animasi & Handling)
local function Create(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props) do inst[k] = v end
    return inst
end

function Nebula:CreateWindow(title)
    local NebulaGui = Create("ScreenGui", {Name = "Nebula_Core", Parent = CoreGui})
    
    -- Main Frame (The Monolith)
    local Main = Create("Frame", {
        Name = "Main",
        Parent = NebulaGui,
        Size = UDim2.new(0, 500, 0, 350),
        Position = UDim2.new(0.5, -250, 0.5, -175),
        BackgroundColor3 = Color3.fromRGB(5, 5, 7),
        BorderSizePixel = 0
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = Main})
    Create("UIStroke", {Color = Color3.fromRGB(40, 40, 50), Thickness = 1, Parent = Main})

    -- Sidebar (Navigation)
    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Parent = Main,
        Size = UDim2.new(0, 140, 1, 0),
        BackgroundColor3 = Color3.fromRGB(8, 8, 11),
        BorderSizePixel = 0
    })
    Create("UIStroke", {Color = Color3.fromRGB(25, 25, 30), Thickness = 1, Parent = Sidebar})

    local TitleLbl = Create("TextLabel", {
        Parent = Sidebar,
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 1,
        Text = title,
        Font = Enum.Font.Code, -- Kesan Professional Dev
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 18
    })

    local TabContainer = Create("ScrollingFrame", {
        Parent = Sidebar,
        Position = UDim2.new(0, 0, 0, 50),
        Size = UDim2.new(1, 0, 1, -50),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0,0,0,0)
    })
    local TabList = Create("UIListLayout", {Parent = TabContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)})

    -- Content Area
    local ContentHolder = Create("Frame", {
        Name = "Content",
        Parent = Main,
        Position = UDim2.new(0, 150, 0, 10),
        Size = UDim2.new(1, -160, 1, -20),
        BackgroundTransparency = 1
    })

    -- Dragging (Engineered for smoothness)
    local dragging, dragStart, startPos
    Main.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = i.Position; startPos = Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = i.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

    local TabLogic = {}
    function TabLogic:AddTab(tabName)
        local Page = Create("ScrollingFrame", {
            Parent = ContentHolder,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
            ScrollBarThickness = 1,
            ScrollBarImageColor3 = Color3.fromRGB(50, 50, 60),
            CanvasSize = UDim2.new(0,0,0,0)
        })
        Create("UIListLayout", {Parent = Page, Padding = UDim.new(0, 8)})

        local TabBtn = Create("TextButton", {
            Parent = TabContainer,
            Size = UDim2.new(1, -10, 0, 30),
            BackgroundColor3 = Color3.fromRGB(15, 15, 20),
            BackgroundTransparency = 1,
            Text = tabName,
            Font = Enum.Font.SourceSans,
            TextColor3 = Color3.fromRGB(150, 150, 160),
            TextSize = 14
        })

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(ContentHolder:GetChildren()) do v.Visible = false end
            for _, v in pairs(TabContainer:GetChildren()) do
                if v:IsA("TextButton") then
                    TweenService:Create(v, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(150, 150, 160), BackgroundTransparency = 1}):Play()
                end
            end
            Page.Visible = true
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0.8}):Play()
        end)

        local Elements = {}

        -- COMPONENT: Button (Action)
        function Elements:AddButton(text, callback)
            local Btn = Create("TextButton", {
                Parent = Page,
                Size = UDim2.new(1, -5, 0, 35),
                BackgroundColor3 = Color3.fromRGB(20, 20, 25),
                Text = text:upper(),
                Font = Enum.Font.Code,
                TextColor3 = Color3.fromRGB(220, 220, 220),
                TextSize = 13,
                AutoButtonColor = false
            })
            Create("UIStroke", {Color = Color3.fromRGB(40, 40, 50), Thickness = 1, Parent = Btn})
            
            Btn.MouseEnter:Connect(function() TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 40)}):Play() end)
            Btn.MouseLeave:Connect(function() TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(20, 20, 25)}):Play() end)
            Btn.MouseButton1Click:Connect(callback)
        end

        -- COMPONENT: Input (The Precision Box)
        function Elements:AddInput(text, placeholder, callback)
            local Container = Create("Frame", {
                Parent = Page,
                Size = UDim2.new(1, -5, 0, 45),
                BackgroundColor3 = Color3.fromRGB(12, 12, 15),
                BorderSizePixel = 0
            })
            Create("TextLabel", {
                Parent = Container,
                Size = UDim2.new(0.4, 0, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                Text = text,
                Font = Enum.Font.SourceSansBold,
                TextColor3 = Color3.fromRGB(180, 180, 180),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            local Input = Create("TextBox", {
                Parent = Container,
                Size = UDim2.new(0.5, 0, 0, 25),
                Position = UDim2.new(0.45, 0, 0.25, 0),
                BackgroundColor3 = Color3.fromRGB(20, 20, 25),
                Text = "",
                PlaceholderText = placeholder,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Font = Enum.Font.Code,
                TextSize = 13
            })
            Create("UIStroke", {Color = Color3.fromRGB(45, 45, 55), Thickness = 1, Parent = Input})
            Input.FocusLost:Connect(function() callback(Input.Text) end)
        end

        return Elements
    end
    return TabLogic
end

return Nebula
