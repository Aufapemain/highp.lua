--[[
    YourUI Library
    Single-file Roblox UI Library
    
    Author: [Your Name]
    Version: 1.0.0
    License: MIT
    
    Features:
    - Modern design system
    - Smooth animations
    - Theme support
    - Config saving
    - Mobile optimized
--]]

local YourUI = (function()
    --[[ Services ]]--
    local Services = setmetatable({}, {
        __index = function(t, k)
            t[k] = game:GetService(k)
            return t[k]
        end
    })
    
    local Players = Services.Players
    local TweenService = Services.TweenService
    local UserInputService = Services.UserInputService
    local RunService = Services.RunService
    local HttpService = Services.HttpService
    local CoreGui = Services.CoreGui
    local TextService = Services.TextService
    
    local LocalPlayer = Players.LocalPlayer
    local Mouse = LocalPlayer:GetMouse()
    
    --[[ Protection ]]--
    local ProtectGui = protectgui or (syn and syn.protect_gui) or function() end
    
    --[[ Utility Functions ]]--
    local Utility = {}
    
    function Utility:Tween(obj, info, properties, callback)
        local tween = TweenService:Create(obj, info, properties)
        if callback then
            tween.Completed:Connect(callback)
        end
        tween:Play()
        return tween
    end
    
    function Utility:Round(num, decimals)
        local mult = 10 ^ (decimals or 0)
        return math.floor(num * mult + 0.5) / mult
    end
    
    function Utility:Clamp(val, min, max)
        return math.max(min, math.min(max, val))
    end
    
    function Utility:GetTextBounds(text, font, size, width)
        return TextService:GetTextSize(text, size, font, Vector2.new(width or math.huge, math.huge))
    end
    
    function Utility:Create(class, properties)
        local obj = Instance.new(class)
        for prop, val in pairs(properties or {}) do
            if prop ~= "Parent" then
                if typeof(val) == "Instance" then
                    val.Parent = obj
                else
                    obj[prop] = val
                end
            end
        end
        if properties and properties.Parent then
            obj.Parent = properties.Parent
        end
        return obj
    end
    
    function Utility:Connect(signal, callback)
        local conn = signal:Connect(callback)
        return conn
    end
    
    --[[ Icons (Embedded) ]]--
    local Icons = {
        -- Lucide-style icons (gunakan rbxassetid yang valid)
        ["check"] = "rbxassetid://7733715400",
        ["x"] = "rbxassetid://7733715400",
        ["chevron-down"] = "rbxassetid://7733715400",
        ["chevron-up"] = "rbxassetid://7733715400",
        ["settings"] = "rbxassetid://7733715400",
        ["search"] = "rbxassetid://7733715400",
        ["bell"] = "rbxassetid://7733715400",
        ["menu"] = "rbxassetid://7733715400",
        ["home"] = "rbxassetid://7733715400",
        ["user"] = "rbxassetid://7733715400",
        ["moon"] = "rbxassetid://7733715400",
        ["sun"] = "rbxassetid://7733715400"
    }
    
    --[[ Themes ]]--
    local Themes = {
        Dark = {
            Name = "Dark",
            Background = Color3.fromRGB(30, 30, 30),
            BackgroundSecondary = Color3.fromRGB(40, 40, 40),
            BackgroundTertiary = Color3.fromRGB(50, 50, 50),
            TextPrimary = Color3.fromRGB(255, 255, 255),
            TextSecondary = Color3.fromRGB(180, 180, 180),
            TextDisabled = Color3.fromRGB(120, 120, 120),
            Accent = Color3.fromRGB(100, 150, 255),
            Success = Color3.fromRGB(80, 200, 120),
            Warning = Color3.fromRGB(255, 180, 60),
            Error = Color3.fromRGB(255, 80, 80),
            Border = Color3.fromRGB(60, 60, 60),
            Hover = Color3.fromRGB(70, 70, 70),
            Pressed = Color3.fromRGB(90, 90, 90)
        },
        Light = {
            Name = "Light",
            Background = Color3.fromRGB(245, 245, 245),
            BackgroundSecondary = Color3.fromRGB(255, 255, 255),
            BackgroundTertiary = Color3.fromRGB(230, 230, 230),
            TextPrimary = Color3.fromRGB(30, 30, 30),
            TextSecondary = Color3.fromRGB(100, 100, 100),
            TextDisabled = Color3.fromRGB(150, 150, 150),
            Accent = Color3.fromRGB(0, 120, 212),
            Success = Color3.fromRGB(60, 160, 90),
            Warning = Color3.fromRGB(220, 160, 40),
            Error = Color3.fromRGB(220, 60, 60),
            Border = Color3.fromRGB(200, 200, 200),
            Hover = Color3.fromRGB(220, 220, 220),
            Pressed = Color3.fromRGB(210, 210, 210)
        },
        Midnight = {
            Name = "Midnight",
            Background = Color3.fromRGB(15, 15, 25),
            BackgroundSecondary = Color3.fromRGB(25, 25, 40),
            BackgroundTertiary = Color3.fromRGB(35, 35, 55),
            TextPrimary = Color3.fromRGB(240, 240, 255),
            TextSecondary = Color3.fromRGB(160, 160, 200),
            TextDisabled = Color3.fromRGB(100, 100, 140),
            Accent = Color3.fromRGB(130, 100, 255),
            Success = Color3.fromRGB(100, 220, 150),
            Warning = Color3.fromRGB(255, 200, 80),
            Error = Color3.fromRGB(255, 100, 100),
            Border = Color3.fromRGB(40, 40, 60),
            Hover = Color3.fromRGB(50, 50, 80),
            Pressed = Color3.fromRGB(60, 60, 100)
        }
    }
    
    --[[ Main Library ]]--
    local Library = {
        Version = "1.0.0",
        Windows = {},
        Options = {},
        Theme = "Dark",
        CurrentTheme = Themes.Dark,
        MinimizeKey = Enum.KeyCode.LeftControl,
        Minimized = false,
        UseAcrylic = false,
        ConfigSaving = false,
        ConfigFolder = "YourUI",
        GUI = nil,
        Connections = {}
    }
    
    function Library:SetTheme(themeName)
        if Themes[themeName] then
            self.Theme = themeName
            self.CurrentTheme = Themes[themeName]
            -- Update all elements
            for _, window in pairs(self.Windows) do
                if window.UpdateTheme then
                    window:UpdateTheme()
                end
            end
        end
    end
    
    function Library:SaveConfig(name)
        if not self.ConfigSaving then return end
        if not isfolder then return end
        
        if not isfolder(self.ConfigFolder) then
            makefolder(self.ConfigFolder)
        end
        
        local config = {}
        for flag, option in pairs(self.Options) do
            if option.Save then
                config[flag] = option:Save()
            end
        end
        
        local success, err = pcall(function()
            writefile(self.ConfigFolder .. "/" .. name .. ".json", HttpService:JSONEncode(config))
        end)
        
        if not success then
            warn("Failed to save config: " .. tostring(err))
        end
    end
    
    function Library:LoadConfig(name)
        if not self.ConfigSaving then return end
        if not isfile then return end
        
        local path = self.ConfigFolder .. "/" .. name .. ".json"
        if not isfile(path) then return end
        
        local success, content = pcall(function()
            return readfile(path)
        end)
        
        if success then
            local config = HttpService:JSONDecode(content)
            for flag, value in pairs(config) do
                local option = self.Options[flag]
                if option and option.Load then
                    option:Load(value)
                end
            end
        end
    end
    
    function Library:Notify(config)
        config = config or {}
        local title = config.Title or "Notification"
        local content = config.Content or ""
        local subContent = config.SubContent or ""
        local duration = config.Duration or 5
        local type = config.Type or "Info" -- Info, Success, Warning, Error
        
        local colors = {
            Info = self.CurrentTheme.Accent,
            Success = self.CurrentTheme.Success,
            Warning = self.CurrentTheme.Warning,
            Error = self.CurrentTheme.Error
        }
        
        -- Create notification UI
        if not self.NotificationHolder then
            self.NotificationHolder = Utility:Create("Frame", {
                Name = "Notifications",
                Size = UDim2.new(0, 320, 1, -20),
                Position = UDim2.new(1, -340, 0, 10),
                BackgroundTransparency = 1,
                Parent = self.GUI
            })
            
            Utility:Create("UIListLayout", {
                Padding = UDim.new(0, 10),
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
                Parent = self.NotificationHolder
            })
        end
        
        local notifFrame = Utility:Create("Frame", {
            Name = "Notification",
            Size = UDim2.new(1, 0, 0, 80),
            BackgroundColor3 = self.CurrentTheme.Background,
            BackgroundTransparency = 0.1,
            BorderSizePixel = 0,
            ClipsDescendants = true,
            Parent = self.NotificationHolder
        })
        
        Utility:Create("UICorner", {
            CornerRadius = UDim.new(0, 8),
            Parent = notifFrame
        })
        
        -- Accent bar
        Utility:Create("Frame", {
            Name = "Accent",
            Size = UDim2.new(0, 4, 1, 0),
            BackgroundColor3 = colors[type],
            BorderSizePixel = 0,
            Parent = notifFrame
        })
        
        -- Title
        Utility:Create("TextLabel", {
            Name = "Title",
            Size = UDim2.new(1, -50, 0, 20),
            Position = UDim2.new(0, 15, 0, 10),
            BackgroundTransparency = 1,
            Text = title,
            TextColor3 = self.CurrentTheme.TextPrimary,
            TextSize = 14,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = notifFrame
        })
        
        -- Content
        if content ~= "" then
            Utility:Create("TextLabel", {
                Name = "Content",
                Size = UDim2.new(1, -30, 0, 16),
                Position = UDim2.new(0, 15, 0, 32),
                BackgroundTransparency = 1,
                Text = content,
                TextColor3 = self.CurrentTheme.TextSecondary,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = notifFrame
            })
        end
        
        -- SubContent
        if subContent ~= "" then
            Utility:Create("TextLabel", {
                Name = "SubContent",
                Size = UDim2.new(1, -30, 0, 14),
                Position = UDim2.new(0, 15, 0, 50),
                BackgroundTransparency = 1,
                Text = subContent,
                TextColor3 = self.CurrentTheme.TextDisabled,
                TextSize = 12,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = notifFrame
            })
        end
        
        -- Progress bar
        local progressBar = Utility:Create("Frame", {
            Name = "Progress",
            Size = UDim2.new(1, 0, 0, 3),
            Position = UDim2.new(0, 0, 1, -3),
            BackgroundColor3 = colors[type],
            BorderSizePixel = 0,
            Parent = notifFrame
        })
        
        -- Close button
        local closeBtn = Utility:Create("TextButton", {
            Name = "Close",
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(1, -25, 0, 10),
            BackgroundTransparency = 1,
            Text = "×",
            TextColor3 = self.CurrentTheme.TextSecondary,
            TextSize = 20,
            Font = Enum.Font.GothamBold,
            Parent = notifFrame
        })
        
        -- Animation in
        notifFrame.Position = UDim2.new(1, 0, 0, 0)
        Utility:Tween(notifFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {
            Position = UDim2.new(0, 0, 0, 0)
        })
        
        -- Progress animation
        Utility:Tween(progressBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
            Size = UDim2.new(0, 0, 0, 3)
        })
        
        -- Close function
        local closed = false
        local function close()
            if closed then return end
            closed = true
            
            Utility:Tween(notifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
                Position = UDim2.new(1, 20, 0, 0),
                BackgroundTransparency = 1
            }, function()
                notifFrame:Destroy()
            end)
        end
        
        closeBtn.MouseButton1Click:Connect(close)
        task.delay(duration, close)
    end
    
    --[[ Window Creation ]]--
    function Library:CreateWindow(config)
        config = config or {}
        local title = config.Title or "YourUI"
        local subTitle = config.SubTitle or ""
        local size = config.Size or UDim2.new(0, 600, 0, 400)
        local tabWidth = config.TabWidth or 160
        local configSaving = config.ConfigSaving or false
        local fileName = config.FileName or "Config"
        
        if #self.Windows > 0 then
            warn("YourUI: Only one window allowed!")
            return self.Windows[1]
        end
        
        self.ConfigSaving = configSaving
        
        -- Main GUI
        self.GUI = Utility:Create("ScreenGui", {
            Name = "YourUI_" .. HttpService:GenerateGUID(false),
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        })
        
        ProtectGui(self.GUI)
        
        if RunService:IsStudio() then
            self.GUI.Parent = LocalPlayer.PlayerGui
        else
            self.GUI.Parent = CoreGui
        end
        
        -- Main Frame
        local mainFrame = Utility:Create("Frame", {
            Name = "Main",
            Size = size,
            Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2),
            BackgroundColor3 = self.CurrentTheme.Background,
            BorderSizePixel = 0,
            ClipsDescendants = true,
            Parent = self.GUI
        })
        
        Utility:Create("UICorner", {
            CornerRadius = UDim.new(0, 8),
            Parent = mainFrame
        })
        
        -- Shadow
        Utility:Create("ImageLabel", {
            Name = "Shadow",
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(1, 40, 1, 40),
            BackgroundTransparency = 1,
            Image = "rbxassetid://5554236805",
            ImageColor3 = Color3.fromRGB(0, 0, 0),
            ImageTransparency = 0.6,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(23, 23, 277, 277),
            ZIndex = -1,
            Parent = mainFrame
        })
        
        -- Title Bar
        local titleBar = Utility:Create("Frame", {
            Name = "TitleBar",
            Size = UDim2.new(1, 0, 0, 45),
            BackgroundColor3 = self.CurrentTheme.BackgroundSecondary,
            BorderSizePixel = 0,
            Parent = mainFrame
        })
        
        -- Title Text
        Utility:Create("TextLabel", {
            Name = "Title",
            Size = UDim2.new(0, 200, 0, 20),
            Position = UDim2.new(0, 15, 0, 8),
            BackgroundTransparency = 1,
            Text = title,
            TextColor3 = self.CurrentTheme.TextPrimary,
            TextSize = 16,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = titleBar
        })
        
        -- SubTitle
        if subTitle ~= "" then
            Utility:Create("TextLabel", {
                Name = "SubTitle",
                Size = UDim2.new(0, 200, 0, 14),
                Position = UDim2.new(0, 15, 0, 28),
                BackgroundTransparency = 1,
                Text = subTitle,
                TextColor3 = self.CurrentTheme.TextSecondary,
                TextSize = 12,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = titleBar
            })
        end
        
        -- Controls
        local controls = Utility:Create("Frame", {
            Name = "Controls",
            Size = UDim2.new(0, 70, 1, 0),
            Position = UDim2.new(1, -75, 0, 0),
            BackgroundTransparency = 1,
            Parent = titleBar
        })
        
        -- Minimize Button
        local minBtn = Utility:Create("TextButton", {
            Name = "Minimize",
            Size = UDim2.new(0, 30, 0, 30),
            Position = UDim2.new(0, 0, 0.5, -15),
            BackgroundColor3 = self.CurrentTheme.BackgroundTertiary,
            Text = "-",
            TextColor3 = self.CurrentTheme.TextPrimary,
            TextSize = 18,
            Font = Enum.Font.GothamBold,
            Parent = controls
        })
        
        Utility:Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = minBtn
        })
        
        -- Close Button
        local closeBtn = Utility:Create("TextButton", {
            Name = "Close",
            Size = UDim2.new(0, 30, 0, 30),
            Position = UDim2.new(0, 35, 0.5, -15),
            BackgroundColor3 = self.CurrentTheme.Error,
            Text = "×",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 18,
            Font = Enum.Font.GothamBold,
            Parent = controls
        })
        
        Utility:Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = closeBtn
        })
        
        -- Tab Container (Sidebar)
        local tabContainer = Utility:Create("Frame", {
            Name = "TabContainer",
            Size = UDim2.new(0, tabWidth, 1, -45),
            Position = UDim2.new(0, 0, 0, 45),
            BackgroundColor3 = self.CurrentTheme.BackgroundSecondary,
            BorderSizePixel = 0,
            Parent = mainFrame
        })
        
        local tabList = Utility:Create("UIListLayout", {
            Padding = UDim.new(0, 5),
            Parent = tabContainer
        })
        
        Utility:Create("UIPadding", {
            PaddingTop = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
            Parent = tabContainer
        })
        
        -- Content Container
        local contentContainer = Utility:Create("Frame", {
            Name = "Content",
            Size = UDim2.new(1, -tabWidth, 1, -45),
            Position = UDim2.new(0, tabWidth, 0, 45),
            BackgroundTransparency = 1,
            ClipsDescendants = true,
            Parent = mainFrame
        })
        
        -- Dragging
        local dragging = false
        local dragStart, startPos
        
        titleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = mainFrame.Position
            end
        end)
        
        titleBar.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStart
                mainFrame.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end)
        
        -- Minimize functionality
        local minimized = false
        minBtn.MouseButton1Click:Connect(function()
            minimized = not minimized
            self.Minimized = minimized
            
            if minimized then
                Utility:Tween(mainFrame, TweenInfo.new(0.3), {
                    Size = UDim2.new(0, size.X.Offset, 0, 45)
                })
                minBtn.Text = "+"
            else
                Utility:Tween(mainFrame, TweenInfo.new(0.3), {
                    Size = size
                })
                minBtn.Text = "-"
            end
        end)
        
        -- Close functionality
        closeBtn.MouseButton1Click:Connect(function()
            self.GUI:Destroy()
            self.Windows = {}
        end)
        
        -- Window Object
        local Window = {
            Title = title,
            Tabs = {},
            ActiveTab = nil,
            MainFrame = mainFrame,
            TabContainer = tabContainer,
            ContentContainer = contentContainer
        }
        
        function Window:UpdateTheme()
            -- Update all colors based on new theme
            mainFrame.BackgroundColor3 = Library.CurrentTheme.Background
            titleBar.BackgroundColor3 = Library.CurrentTheme.BackgroundSecondary
            tabContainer.BackgroundColor3 = Library.CurrentTheme.BackgroundSecondary
            -- Update all child elements...
        end
        
        function Window:CreateTab(tabConfig)
            tabConfig = tabConfig or {}
            local tabName = tabConfig.Name or "Tab"
            local tabIcon = tabConfig.Icon
            
            local Tab = {
                Name = tabName,
                Sections = {},
                Elements = {}
            }
            
            -- Tab Button
            local tabBtn = Utility:Create("TextButton", {
                Name = tabName .. "Tab",
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundColor3 = Library.CurrentTheme.BackgroundTertiary,
                BackgroundTransparency = 0.5,
                Text = "",
                AutoButtonColor = false,
                Parent = tabContainer
            })
            
            Utility:Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = tabBtn
            })
            
            -- Icon
            if tabIcon then
                local iconImg = Utility:Create("ImageLabel", {
                    Name = "Icon",
                    Size = UDim2.new(0, 18, 0, 18),
                    Position = UDim2.new(0, 10, 0.5, -9),
                    BackgroundTransparency = 1,
                    Image = Icons[tabIcon] or tabIcon,
                    ImageColor3 = Library.CurrentTheme.TextSecondary,
                    Parent = tabBtn
                })
            end
            
            -- Label
            local label = Utility:Create("TextLabel", {
                Name = "Label",
                Size = UDim2.new(1, tabIcon and -35 or -20, 1, 0),
                Position = UDim2.new(0, tabIcon and 32 or 10, 0, 0),
                BackgroundTransparency = 1,
                Text = tabName,
                TextColor3 = Library.CurrentTheme.TextSecondary,
                TextSize = 13,
                Font = Enum.Font.GothamSemibold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = tabBtn
            })
            
            -- Content Page
            local contentPage = Utility:Create("ScrollingFrame", {
                Name = tabName .. "Content",
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ScrollBarThickness = 4,
                ScrollBarImageColor3 = Library.CurrentTheme.Accent,
                Visible = false,
                Parent = contentContainer
            })
            
            local contentList = Utility:Create("UIListLayout", {
                Padding = UDim.new(0, 10),
                Parent = contentPage
            })
            
            Utility:Create("UIPadding", {
                PaddingTop = UDim.new(0, 10),
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
                PaddingBottom = UDim.new(0, 10),
                Parent = contentPage
            })
            
            -- Auto canvas size
            contentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                contentPage.CanvasSize = UDim2.new(0, 0, 0, contentList.AbsoluteContentSize.Y + 20)
            end)
            
            Tab.Content = contentPage
            Tab.Button = tabBtn
            
            -- Tab switching
            tabBtn.MouseButton1Click:Connect(function()
                if Window.ActiveTab == Tab then return end
                
                -- Deactivate old tab
                if Window.ActiveTab then
                    Utility:Tween(Window.ActiveTab.Button, TweenInfo.new(0.2), {
                        BackgroundColor3 = Library.CurrentTheme.BackgroundTertiary,
                        BackgroundTransparency = 0.5
                    })
                    Window.ActiveTab.Button.Label.TextColor3 = Library.CurrentTheme.TextSecondary
                    Window.ActiveTab.Content.Visible = false
                end
                
                -- Activate new tab
                Window.ActiveTab = Tab
                Utility:Tween(tabBtn, TweenInfo.new(0.2), {
                    BackgroundColor3 = Library.CurrentTheme.Accent,
                    BackgroundTransparency = 0.1
                })
                label.TextColor3 = Library.CurrentTheme.TextPrimary
                contentPage.Visible = true
                
                -- Animation
                contentPage.Position = UDim2.new(0.02, 0, 0, 0)
                contentPage.GroupTransparency = 0.5
                Utility:Tween(contentPage, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
                    Position = UDim2.new(0, 0, 0, 0),
                    GroupTransparency = 0
                })
            end)
            
            -- Element Creators
            function Tab:CreateSection(sectionConfig)
                sectionConfig = sectionConfig or {}
                local sectionTitle = sectionConfig.Name or "Section"
                
                local sectionFrame = Utility:Create("Frame", {
                    Name = sectionTitle .. "Section",
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundColor3 = Library.CurrentTheme.BackgroundTertiary,
                    BackgroundTransparency = 0.8,
                    BorderSizePixel = 0,
                    Parent = contentPage
                })
                
                Utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = sectionFrame
                })
                
                Utility:Create("TextLabel", {
                    Size = UDim2.new(1, -20, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text = sectionTitle,
                    TextColor3 = Library.CurrentTheme.TextSecondary,
                    TextSize = 12,
                    Font = Enum.Font.GothamBold,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = sectionFrame
                })
                
                return sectionFrame
            end
            
            function Tab:AddButton(btnConfig)
                btnConfig = btnConfig or {}
                local btnTitle = btnConfig.Title or "Button"
                local btnDesc = btnConfig.Description
                local callback = btnConfig.Callback or function() end
                
                local btnFrame = Utility:Create("TextButton", {
                    Name = btnTitle .. "Button",
                    Size = UDim2.new(1, 0, 0, btnDesc and 60 or 40),
                    BackgroundColor3 = Library.CurrentTheme.BackgroundTertiary,
                    BackgroundTransparency = 0.5,
                    Text = "",
                    AutoButtonColor = false,
                    Parent = contentPage
                })
                
                Utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = btnFrame
                })
                
                Utility:Create("TextLabel", {
                    Size = UDim2.new(1, -20, 0, 20),
                    Position = UDim2.new(0, 10, 0, btnDesc and 8 or 10),
                    BackgroundTransparency = 1,
                    Text = btnTitle,
                    TextColor3 = Library.CurrentTheme.TextPrimary,
                    TextSize = 14,
                    Font = Enum.Font.GothamSemibold,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = btnFrame
                })
                
                if btnDesc then
                    Utility:Create("TextLabel", {
                        Size = UDim2.new(1, -20, 0, 16),
                        Position = UDim2.new(0, 10, 0, 32),
                        BackgroundTransparency = 1,
                        Text = btnDesc,
                        TextColor3 = Library.CurrentTheme.TextSecondary,
                        TextSize = 12,
                        Font = Enum.Font.Gotham,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = btnFrame
                    })
                end
                
                -- Hover effects
                btnFrame.MouseEnter:Connect(function()
                    Utility:Tween(btnFrame, TweenInfo.new(0.2), {
                        BackgroundTransparency = 0.3
                    })
                end)
                
                btnFrame.MouseLeave:Connect(function()
                    Utility:Tween(btnFrame, TweenInfo.new(0.2), {
                        BackgroundTransparency = 0.5
                    })
                end)
                
                btnFrame.MouseButton1Down:Connect(function()
                    Utility:Tween(btnFrame, TweenInfo.new(0.1), {
                        BackgroundColor3 = Library.CurrentTheme.Pressed
                    })
                end)
                
                btnFrame.MouseButton1Up:Connect(function()
                    Utility:Tween(btnFrame, TweenInfo.new(0.1), {
                        BackgroundColor3 = Library.CurrentTheme.BackgroundTertiary
                    })
                end)
                
                btnFrame.MouseButton1Click:Connect(function()
                    Library:SafeCallback(callback)
                end)
                
                return btnFrame
            end
            
            function Tab:AddToggle(toggleConfig)
                toggleConfig = toggleConfig or {}
                local toggleTitle = toggleConfig.Title or "Toggle"
                local toggleDesc = toggleConfig.Description
                local default = toggleConfig.Default or false
                local callback = toggleConfig.Callback or function() end
                local flag = toggleConfig.Flag
                
                local Toggle = {
                    Value = default,
                    Flag = flag
                }
                
                if flag then
                    Library.Options[flag] = Toggle
                end
                
                local toggleFrame = Utility:Create("Frame", {
                    Name = toggleTitle .. "Toggle",
                    Size = UDim2.new(1, 0, 0, toggleDesc and 65 or 45),
                    BackgroundColor3 = Library.CurrentTheme.BackgroundTertiary,
                    BackgroundTransparency = 0.5,
                    BorderSizePixel = 0,
                    Parent = contentPage
                })
                
                Utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = toggleFrame
                })
                
                -- Title
                Utility:Create("TextLabel", {
                    Size = UDim2.new(1, -70, 0, 20),
                    Position = UDim2.new(0, 10, 0, toggleDesc and 8 or 12),
                    BackgroundTransparency = 1,
                    Text = toggleTitle,
                    TextColor3 = Library.CurrentTheme.TextPrimary,
                    TextSize = 14,
                    Font = Enum.Font.GothamSemibold,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = toggleFrame
                })
                
                -- Description
                if toggleDesc then
                    Utility:Create("TextLabel", {
                        Size = UDim2.new(1, -70, 0, 16),
                        Position = UDim2.new(0, 10, 0, 32),
                        BackgroundTransparency = 1,
                        Text = toggleDesc,
                        TextColor3 = Library.CurrentTheme.TextSecondary,
                        TextSize = 12,
                        Font = Enum.Font.Gotham,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = toggleFrame
                    })
                end
                
                -- Switch
                local switch = Utility:Create("Frame", {
                    Name = "Switch",
                    Size = UDim2.new(0, 44, 0, 24),
                    Position = UDim2.new(1, -54, 0.5, -12),
                    BackgroundColor3 = default and Library.CurrentTheme.Accent or Library.CurrentTheme.BackgroundSecondary,
                    BorderSizePixel = 0,
                    Parent = toggleFrame
                })
                
                Utility:Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = switch
                })
                
                local knob = Utility:Create("Frame", {
                    Name = "Knob",
                    Size = UDim2.new(0, 18, 0, 18),
                    Position = UDim2.new(0, default and 23 or 3, 0.5, -9),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    Parent = switch
                })
                
                Utility:Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = knob
                })
                
                -- Click area
                local clickArea = Utility:Create("TextButton", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = toggleFrame
                })
                
                function Toggle:SetValue(value)
                    self.Value = value
                    
                    if value then
                        Utility:Tween(switch, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
                            BackgroundColor3 = Library.CurrentTheme.Accent
                        })
                        Utility:Tween(knob, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
                            Position = UDim2.new(0, 23, 0.5, -9)
                        })
                    else
                        Utility:Tween(switch, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
                            BackgroundColor3 = Library.CurrentTheme.BackgroundSecondary
                        })
                        Utility:Tween(knob, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
                            Position = UDim2.new(0, 3, 0.5, -9)
                        })
                    end
                    
                    Library:SafeCallback(callback, value)
                end
                
                function Toggle:Save()
                    return self.Value
                end
                
                function Toggle:Load(value)
                    self:SetValue(value)
                end
                
                clickArea.MouseButton1Click:Connect(function()
                    Toggle:SetValue(not Toggle.Value)
                end)
                
                -- Hover effects
                clickArea.MouseEnter:Connect(function()
                    Utility:Tween(toggleFrame, TweenInfo.new(0.2), {
                        BackgroundTransparency = 0.3
                    })
                end)
                
                clickArea.MouseLeave:Connect(function()
                    Utility:Tween(toggleFrame, TweenInfo.new(0.2), {
                        BackgroundTransparency = 0.5
                    })
                end)
                
                table.insert(Tab.Elements, Toggle)
                return Toggle
            end
            
            function Tab:AddSlider(sliderConfig)
                sliderConfig = sliderConfig or {}
                local sliderTitle = sliderConfig.Title or "Slider"
                local min = sliderConfig.Min or 0
                local max = sliderConfig.Max or 100
                local default = sliderConfig.Default or min
                local increment = sliderConfig.Increment or 1
                local callback = sliderConfig.Callback or function() end
                local flag = sliderConfig.Flag
                
                local Slider = {
                    Value = default,
                    Min = min,
                    Max = max,
                    Flag = flag
                }
                
                if flag then
                    Library.Options[flag] = Slider
                end
                
                local sliderFrame = Utility:Create("Frame", {
                    Name = sliderTitle .. "Slider",
                    Size = UDim2.new(1, 0, 0, 70),
                    BackgroundColor3 = Library.CurrentTheme.BackgroundTertiary,
                    BackgroundTransparency = 0.5,
                    BorderSizePixel = 0,
                    Parent = contentPage
                })
                
                Utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = sliderFrame
                })
                
                -- Title & Value
                Utility:Create("TextLabel", {
                    Size = UDim2.new(0.5, 0, 0, 20),
                    Position = UDim2.new(0, 10, 0, 8),
                    BackgroundTransparency = 1,
                    Text = sliderTitle,
                    TextColor3 = Library.CurrentTheme.TextPrimary,
                    TextSize = 14,
                    Font = Enum.Font.GothamSemibold,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = sliderFrame
                })
                
                local valueLabel = Utility:Create("TextLabel", {
                    Size = UDim2.new(0, 50, 0, 20),
                    Position = UDim2.new(1, -60, 0, 8),
                    BackgroundColor3 = Library.CurrentTheme.BackgroundSecondary,
                    Text = tostring(default),
                    TextColor3 = Library.CurrentTheme.TextPrimary,
                    TextSize = 12,
                    Font = Enum.Font.GothamBold,
                    Parent = sliderFrame
                })
                
                Utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = valueLabel
                })
                
                -- Slider bar
                local barBg = Utility:Create("Frame", {
                    Name = "BarBackground",
                    Size = UDim2.new(1, -20, 0, 6),
                    Position = UDim2.new(0, 10, 0, 45),
                    BackgroundColor3 = Library.CurrentTheme.BackgroundSecondary,
                    BorderSizePixel = 0,
                    Parent = sliderFrame
                })
                
                Utility:Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = barBg
                })
                
                local barFill = Utility:Create("Frame", {
                    Name = "BarFill",
                    Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                    BackgroundColor3 = Library.CurrentTheme.Accent,
                    BorderSizePixel = 0,
                    Parent = barBg
                })
                
                Utility:Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = barFill
                })
                
                local knob = Utility:Create("Frame", {
                    Name = "Knob",
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new(0, -8, 0.5, -8),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    Parent = barFill
                })
                
                Utility:Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = knob
                })
                
                -- Dragging
                local dragging = false
                
                local function UpdateValue(input)
                    local pos = math.clamp((input.Position.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
                    local value = min + (pos * (max - min))
                    
                    if increment > 0 then
                        value = math.floor(value / increment + 0.5) * increment
                    end
                    
                    value = math.clamp(value, min, max)
                    Slider.Value = value
                    
                    local fillScale = (value - min) / (max - min)
                    barFill.Size = UDim2.new(fillScale, 0, 1, 0)
                    valueLabel.Text = tostring(Utility:Round(value, 2))
                    
                    Library:SafeCallback(callback, value)
                end
                
                knob.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                    end
                end)
                
                barBg.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        UpdateValue(input)
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        UpdateValue(input)
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                function Slider:SetValue(value)
                    value = math.clamp(value, min, max)
                    self.Value = value
                    
                    local fillScale = (value - min) / (max - min)
                    barFill.Size = UDim2.new(fillScale, 0, 1, 0)
                    valueLabel.Text = tostring(Utility:Round(value, 2))
                    
                    Library:SafeCallback(callback, value)
                end
                
                function Slider:Save()
                    return self.Value
                end
                
                function Slider:Load(value)
                    self:SetValue(value)
                end
                
                return Slider
            end
            
            function Tab:AddDropdown(dropdownConfig)
                dropdownConfig = dropdownConfig or {}
                local dropdownTitle = dropdownConfig.Title or "Dropdown"
                local options = dropdownConfig.Options or {}
                local default = dropdownConfig.Default
                local callback = dropdownConfig.Callback or function() end
                local flag = dropdownConfig.Flag
                
                local Dropdown = {
                    Value = default,
                    Options = options,
                    Open = false,
                    Flag = flag
                }
                
                if flag then
                    Library.Options[flag] = Dropdown
                end
                
                local dropdownFrame = Utility:Create("Frame", {
                    Name = dropdownTitle .. "Dropdown",
                    Size = UDim2.new(1, 0, 0, 45),
                    BackgroundColor3 = Library.CurrentTheme.BackgroundTertiary,
                    BackgroundTransparency = 0.5,
                    BorderSizePixel = 0,
                    ClipsDescendants = true,
                    Parent = contentPage
                })
                
                Utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = dropdownFrame
                })
                
                -- Title
                Utility:Create("TextLabel", {
                    Size = UDim2.new(1, -50, 0, 20),
                    Position = UDim2.new(0, 10, 0, 12),
                    BackgroundTransparency = 1,
                    Text = dropdownTitle,
                    TextColor3 = Library.CurrentTheme.TextPrimary,
                    TextSize = 14,
                    Font = Enum.Font.GothamSemibold,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = dropdownFrame
                })
                
                -- Selected value display
                local selectedLabel = Utility:Create("TextLabel", {
                    Size = UDim2.new(0, 100, 0, 20),
                    Position = UDim2.new(1, -130, 0, 12),
                    BackgroundTransparency = 1,
                    Text = default or "Select...",
                    TextColor3 = Library.CurrentTheme.TextSecondary,
                    TextSize = 13,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = dropdownFrame
                })
                
                -- Arrow
                local arrow = Utility:Create("ImageLabel", {
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new(1, -26, 0, 14),
                    BackgroundTransparency = 1,
                    Image = Icons["chevron-down"],
                    ImageColor3 = Library.CurrentTheme.TextSecondary,
                    Parent = dropdownFrame
                })
                
                -- Options container
                local optionsFrame = Utility:Create("Frame", {
                    Name = "Options",
                    Size = UDim2.new(1, -20, 0, 0),
                    Position = UDim2.new(0, 10, 0, 45),
                    BackgroundColor3 = Library.CurrentTheme.BackgroundSecondary,
                    BorderSizePixel = 0,
                    ClipsDescendants = true,
                    Parent = dropdownFrame
                })
                
                Utility:Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = optionsFrame
                })
                
                local optionsList = Utility:Create("UIListLayout", {
                    Padding = UDim.new(0, 2),
                    Parent = optionsFrame
                })
                
                local optionButtons = {}
                
                local function CreateOptions()
                    for _, opt in pairs(options) do
                        local optBtn = Utility:Create("TextButton", {
                            Size = UDim2.new(1, 0, 0, 30),
                            BackgroundColor3 = Library.CurrentTheme.BackgroundTertiary,
                            BackgroundTransparency = 0.5,
                            Text = opt,
                            TextColor3 = Library.CurrentTheme.TextPrimary,
                            TextSize = 13,
                            Font = Enum.Font.Gotham,
                            Parent = optionsFrame
                        })
                        
                        optBtn.MouseButton1Click:Connect(function()
                            Dropdown.Value = opt
                            selectedLabel.Text = opt
                            Dropdown:Close()
                            Library:SafeCallback(callback, opt)
                        end)
                        
                        table.insert(optionButtons, optBtn)
                    end
                    
                    local totalHeight = #options * 32
                    optionsFrame.Size = UDim2.new(1, -20, 0, totalHeight)
                end
                
                CreateOptions()
                
                function Dropdown:Open()
                    self.Open = true
                    Utility:Tween(arrow, TweenInfo.new(0.2), {
                        Rotation = 180
                    })
                    Utility:Tween(dropdownFrame, TweenInfo.new(0.2), {
                        Size = UDim2.new(1, 0, 0, 50 + optionsFrame.Size.Y.Offset)
                    })
                end
                
                function Dropdown:Close()
                    self.Open = false
                    Utility:Tween(arrow, TweenInfo.new(0.2), {
                        Rotation = 0
                    })
                    Utility:Tween(dropdownFrame, TweenInfo.new(0.2), {
                        Size = UDim2.new(1, 0, 0, 45)
                    })
                end
                
                function Dropdown:SetOptions(newOptions)
                    options = newOptions
                    self.Options = newOptions
                    -- Clear and recreate
                    for _, btn in pairs(optionButtons) do
                        btn:Destroy()
                    end
                    optionButtons = {}
                    CreateOptions()
                end
                
                -- Click to toggle
                local clickArea = Utility:Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 45),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = dropdownFrame
                })
                
                clickArea.MouseButton1Click:Connect(function()
                    if Dropdown.Open then
                        Dropdown:Close()
                    else
                        Dropdown:Open()
                    end
                end)
                
                return Dropdown
            end
            
            -- Select first tab by default
            if #Window.Tabs == 0 then
                task.spawn(function()
                    task.wait(0.1)
                    tabBtn.MouseButton1Click:Fire()
                end)
            end
            
            table.insert(Window.Tabs, Tab)
            return Tab
        end
        
        table.insert(self.Windows, Window)
        
        -- Entrance animation
        mainFrame.Size = UDim2.new(0, 0, 0, 0)
        mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        
        Utility:Tween(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
            Size = size,
            Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2)
        })
        
        return Window
    end
    
    function Library:SafeCallback(callback, ...)
        if not callback then return end
        local success, err = pcall(callback, ...)
        if not success then
            self:Notify({
                Title = "Callback Error",
                Content = tostring(err),
                Type = "Error",
                Duration = 5
            })
        end
    end
    
    -- Minimize keybind
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == self.MinimizeKey then
            for _, window in pairs(self.Windows) do
                window.MainFrame.Visible = not window.MainFrame.Visible
            end
        end
    end)
    
    return Library
end)()

-- Global access
getgenv().YourUI = YourUI

return YourUI
