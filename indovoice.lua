-- Auto Fishing ULTIMATE - PC & MOBILE Support!
-- Kombinasi Mouse Simulation + Touch + Remote Event + Smart Detection
-- Space Theme UI by Astro

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- ========= SPACE THEME COLORS =========
local Theme = {
    -- Dark space background like deep space
    Background = Color3.fromRGB(16, 15, 28),      -- #100f1c
    -- Panel with dark purple-gray
    Surface = Color3.fromRGB(33, 31, 51),        -- #211f33
    -- Slightly brighter panel for hover effects
    SurfaceAlt = Color3.fromRGB(45, 43, 69),     -- #2d2b45
    -- Primary text with soft ivory white
    TextPrimary = Color3.fromRGB(234, 234, 234), -- #EAEAEA
    -- Secondary/muted text, purple-gray
    TextMuted = Color3.fromRGB(138, 136, 153),   -- #8a8899
    -- Main accent with bright lavender purple
    Accent = Color3.fromRGB(159, 93, 255),       -- #9f5dff
    -- Secondary accent with striking magenta
    AccentSecondary = Color3.fromRGB(190, 41, 236), -- #be29ec
    -- Softer/darker accent variant
    AccentSoft = Color3.fromRGB(108, 76, 158),   -- #6c4c9e
    -- Subtle stroke/border color
    Stroke = Color3.fromRGB(59, 56, 85)          -- #3b3855
}

-- Helper functions for space theme styling
local function AddCorner(target, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = target
end

local function AddStroke(target, color, thickness)
    local ok, s = pcall(function()
        return Instance.new("UIStroke")
    end)
    if ok and s then
        s.Color = color or Theme.Stroke
        s.Thickness = thickness or 1
        s.Transparency = 0.3
        s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        s.Parent = target
    end
end

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Backpack = LocalPlayer:WaitForChild("Backpack")
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Detect Platform
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local IsPC = UserInputService.KeyboardEnabled

-- Config
local Config = {
    Enabled = false,
    CastDelay = 1.5,
    MinigameDelay = 0.3,
    TapSpeed = IsMobile and 0.03 or 0.02, -- Mobile lebih lambat sedikit
    AutoEquip = true,
    SmartDetection = true,
}

-- Variables
local FishingRod = nil
local IsCasting = false
local InMinigame = false
local IsSpamming = false
local SpamConnection = nil
local Stats = {
    Catches = 0,
    StartTime = 0,
}

-- Create GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoFishingUltimateGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- Main Frame (Responsive untuk Mobile) - Space Theme
local MainFrame = Instance.new("Frame")
if IsMobile then
    MainFrame.Size = UDim2.new(0, 320, 0, 235) -- TitleBar (50) + ContentFrame (185) = 235
    MainFrame.Position = UDim2.new(0.5, -160, 0.05, 0) -- Lebih ke atas
else
    MainFrame.Size = UDim2.new(0, 300, 0, 220) -- TitleBar (45) + ContentFrame (175) = 220
    MainFrame.Position = UDim2.new(0.5, -150, 0.1, 0)
end
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = not IsMobile -- Mobile pakai touch, jangan draggable
MainFrame.Parent = ScreenGui

-- Space theme styling
AddCorner(MainFrame, 12)
AddStroke(MainFrame, Theme.Stroke, 2)

-- Title Bar - Space Theme
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, IsMobile and 50 or 45)
TitleBar.BackgroundColor3 = Theme.Surface
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

-- Space theme styling for title bar
AddCorner(TitleBar, 12)
AddStroke(TitleBar, Theme.Accent, 2)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -90, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = IsMobile and "🚀 INDO VOICE (📱)" or "🚀 INDO VOICE (💻)"
Title.TextColor3 = Theme.Accent
Title.TextSize = IsMobile and 16 or 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

-- Minimize Button - Space Theme
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, IsMobile and 40 or 35, 0, IsMobile and 40 or 35)
MinimizeButton.Position = UDim2.new(1, IsMobile and -85 or -80, 0, 5)
MinimizeButton.BackgroundColor3 = Theme.SurfaceAlt
MinimizeButton.BorderSizePixel = 0
MinimizeButton.Text = "−"
MinimizeButton.TextColor3 = Theme.TextPrimary
MinimizeButton.TextSize = IsMobile and 24 or 20
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.AutoButtonColor = false
MinimizeButton.Parent = TitleBar

-- Space theme styling for minimize button
AddCorner(MinimizeButton, 8)
AddStroke(MinimizeButton, Theme.Stroke, 1)

-- Close Button - Space Theme
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, IsMobile and 40 or 35, 0, IsMobile and 40 or 35)
CloseButton.Position = UDim2.new(1, IsMobile and -45 or -40, 0, 5)
CloseButton.BackgroundColor3 = Theme.SurfaceAlt
CloseButton.BorderSizePixel = 0
CloseButton.Text = "×"
CloseButton.TextColor3 = Theme.TextPrimary
CloseButton.TextSize = IsMobile and 24 or 20
CloseButton.Font = Enum.Font.GothamBold
CloseButton.AutoButtonColor = false
CloseButton.Parent = TitleBar

-- Space theme styling for close button
AddCorner(CloseButton, 8)
AddStroke(CloseButton, Theme.Stroke, 1)

-- Content Frame - Space Theme (for minimize functionality)
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, 0, 0, IsMobile and 185 or 175)
ContentFrame.Position = UDim2.new(0, 0, 0, TitleBar.Size.Y.Offset)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Status Container - Space Theme
local StatusContainer = Instance.new("Frame")
StatusContainer.Size = UDim2.new(1, -20, 0, IsMobile and 45 or 40)
StatusContainer.Position = UDim2.new(0, 10, 0, 10)
StatusContainer.BackgroundColor3 = Theme.Surface
StatusContainer.BorderSizePixel = 0
StatusContainer.Parent = ContentFrame

-- Space theme styling for status container
AddCorner(StatusContainer, 8)
AddStroke(StatusContainer, Theme.Stroke, 1)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -10, 1, 0)
StatusLabel.Position = UDim2.new(0, 8, 0, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "💤 Status: OFFLINE"
StatusLabel.TextColor3 = Theme.TextMuted
StatusLabel.TextSize = IsMobile and 13 or 14
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.TextWrapped = true
StatusLabel.Parent = StatusContainer

-- Method Label - Space Theme
local MethodLabel = Instance.new("TextLabel")
MethodLabel.Size = UDim2.new(1, -20, 0, IsMobile and 25 or 22)
MethodLabel.Position = UDim2.new(0, 15, 0, IsMobile and 65 or 60)
MethodLabel.BackgroundTransparency = 1
MethodLabel.Text = IsMobile and "⚙️ Touch Mode" or "⚙️ Method: Auto"
MethodLabel.TextColor3 = Theme.TextMuted
MethodLabel.TextSize = IsMobile and 11 or 12
MethodLabel.Font = Enum.Font.GothamBold
MethodLabel.TextXAlignment = Enum.TextXAlignment.Left
MethodLabel.Parent = ContentFrame

-- Info Label - Space Theme
local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, -20, 0, IsMobile and 25 or 22)
InfoLabel.Position = UDim2.new(0, 15, 0, IsMobile and 95 or 85)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "📊 Fish: 0 | Time: 0s"
InfoLabel.TextColor3 = Theme.TextMuted
InfoLabel.TextSize = IsMobile and 11 or 12
InfoLabel.Font = Enum.Font.GothamBold
InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
InfoLabel.Parent = ContentFrame

-- Toggle Button - Space Theme (Lebih besar untuk mobile)
local ToggleButton = Instance.new("TextButton")
if IsMobile then
    ToggleButton.Size = UDim2.new(0, 280, 0, 55)
    ToggleButton.Position = UDim2.new(0.5, -140, 0, IsMobile and 125 or 120)
else
    ToggleButton.Size = UDim2.new(0, 260, 0, 50)
    ToggleButton.Position = UDim2.new(0.5, -130, 0, IsMobile and 125 or 120)
end
ToggleButton.BackgroundColor3 = Theme.Accent
ToggleButton.BorderSizePixel = 0
ToggleButton.Text = "▶ START"
ToggleButton.TextColor3 = Theme.TextPrimary
ToggleButton.TextSize = IsMobile and 20 or 18
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.AutoButtonColor = false
ToggleButton.Parent = ContentFrame

-- Space theme styling for toggle button
AddCorner(ToggleButton, 12)
AddStroke(ToggleButton, Theme.AccentSecondary, 2)

-- Functions
local function findFishingRod()
    for _, item in pairs(Character:GetChildren()) do
        if item:IsA("Tool") and (item:FindFirstChild("Cast") or item.Name:lower():find("rod")) then
            return item
        end
    end
    
    for _, item in pairs(Backpack:GetChildren()) do
        if item:IsA("Tool") and (item:FindFirstChild("Cast") or item.Name:lower():find("rod")) then
            return item
        end
    end
    
    return nil
end

local function equipFishingRod()
    if not FishingRod then
        FishingRod = findFishingRod()
    end
    
    if not FishingRod then
        return false
    end
    
    if FishingRod.Parent == Backpack then
        LocalPlayer.Character.Humanoid:EquipTool(FishingRod)
        task.wait(0.3)
    end
    
    return FishingRod.Parent == Character
end

local function updateStatus(status, color)
    StatusLabel.Text = status
    StatusLabel.TextColor3 = color
end

local function updateStats()
    local elapsed = math.floor(tick() - Stats.StartTime)
    InfoLabel.Text = string.format("📊 Fish: %d | Time: %ds", Stats.Catches, elapsed)
end

local function stopSpamming()
    if SpamConnection then
        SpamConnection:Disconnect()
        SpamConnection = nil
    end
    IsSpamming = false
end

local function simulateInput()
    if IsMobile then
        -- Mobile: Simulate touch
        local screenCenter = workspace.CurrentCamera.ViewportSize / 2
        VirtualInputManager:SendTouchEvent(0, screenCenter.X, screenCenter.Y)
        task.wait(0.01)
        VirtualInputManager:SendTouchEvent(1, screenCenter.X, screenCenter.Y)
    else
        -- PC: Simulate mouse click
        local mousePos = UserInputService:GetMouseLocation()
        VirtualInputManager:SendMouseButtonEvent(mousePos.X, mousePos.Y, 0, true, game, 0)
        task.wait(0.01)
        VirtualInputManager:SendMouseButtonEvent(mousePos.X, mousePos.Y, 0, false, game, 0)
    end
end

local function simulateHoldInput()
    pcall(function()
        if IsMobile then
            -- Mobile: Simulate touch hold for 2 seconds
            local screenCenter = workspace.CurrentCamera.ViewportSize / 2
            VirtualInputManager:SendTouchEvent(0, screenCenter.X, screenCenter.Y) -- Touch down
            task.wait(2) -- Hold for 2 seconds
            VirtualInputManager:SendTouchEvent(1, screenCenter.X, screenCenter.Y) -- Touch up
        else
            -- PC: Simulate mouse hold for 2 seconds
            local mousePos = UserInputService:GetMouseLocation()
            VirtualInputManager:SendMouseButtonEvent(mousePos.X, mousePos.Y, 0, true, game, 0) -- Mouse down
            task.wait(2) -- Hold for 2 seconds
            VirtualInputManager:SendMouseButtonEvent(mousePos.X, mousePos.Y, 0, false, game, 0) -- Mouse up
        end
    end)
end

local function startSpamming()
    if IsSpamming or not InMinigame then return end
    IsSpamming = true
    
    updateStatus(IsMobile and "⚡ TAPPING!" or "⚡ SPAM TAPPING!", Color3.fromRGB(255, 200, 0))
    
    SpamConnection = RunService.Heartbeat:Connect(function()
        if not Config.Enabled or not InMinigame then
            stopSpamming()
            return
        end
        
        simulateInput()
        task.wait(Config.TapSpeed)
    end)
end

local function castRodMouse()
    simulateHoldInput() -- Use hold instead of click
    MethodLabel.Text = IsMobile and "⚙️ Touch Hold (2s)" or "⚙️ Mouse Hold (2s)"
    return true
end

local function castRodRemote()
    if not FishingRod then return false end
    
    local castRemote = FishingRod:FindFirstChild("Cast")
    if castRemote and castRemote:IsA("RemoteEvent") then
        castRemote:FireServer()
        MethodLabel.Text = "⚙️ Remote Event"
        return true
    end
    
    return false
end

local function castRod()
    if IsCasting or InMinigame or not Config.Enabled then return end
    
    if Config.AutoEquip then
        if not equipFishingRod() then
            updateStatus("❌ NO ROD!", Color3.fromRGB(255, 100, 100))
            return
        end
    end
    
    IsCasting = true
    updateStatus(IsMobile and "🎣 HOLDING (2s)..." or "🎣 HOLDING (2s)...", Color3.fromRGB(100, 200, 255))
    
    local success = false
    
    if Config.SmartDetection then
        success = castRodRemote()
        if not success then
            success = castRodMouse()
        end
    else
        success = castRodMouse()
    end
    
    if success then
        print("[Auto Fishing] Cast successful!")
    end
    
    task.wait(Config.CastDelay) -- Additional delay after hold
    IsCasting = false
    
    if not InMinigame then
        updateStatus("🔄 WAITING...", Color3.fromRGB(150, 150, 255))
    end
end

local function monitorProgressBar()
    local fishingUI = PlayerGui:FindFirstChild("FishingUI")
    if not fishingUI then return end
    
    local bar = fishingUI:FindFirstChild("Bar", true)
    if not bar then 
        task.wait(Config.MinigameDelay)
        startSpamming()
        return
    end
    
    local lastWasGreen = false
    SpamConnection = RunService.Heartbeat:Connect(function()
        if not Config.Enabled or not InMinigame then
            stopSpamming()
            return
        end
        
        local barColor = bar.BackgroundColor3
        local isGreen = barColor.G > 0.7 and barColor.R < 0.6
        
        if isGreen and not lastWasGreen then
            IsSpamming = true
            simulateInput()
        elseif not isGreen and lastWasGreen then
            IsSpamming = false
        end
        
        if IsSpamming then
            simulateInput()
            task.wait(Config.TapSpeed)
        end
        
        lastWasGreen = isGreen
    end)
end

local function setupRemoteHooks()
    if not FishingRod then return end
    
    local startMinigame = FishingRod:FindFirstChild("StartMinigame")
    if startMinigame and startMinigame:IsA("RemoteEvent") then
        startMinigame.OnClientEvent:Connect(function(lure)
            InMinigame = true
            updateStatus("🎮 MINIGAME", Color3.fromRGB(255, 200, 100))
            
            task.wait(Config.MinigameDelay)
            monitorProgressBar()
        end)
    end
    
    local fishingCanceled = FishingRod:FindFirstChild("FishingCanceled")
    if fishingCanceled and fishingCanceled:IsA("RemoteEvent") then
        fishingCanceled.OnClientEvent:Connect(function()
            InMinigame = false
            stopSpamming()
            Stats.Catches = Stats.Catches + 1
            updateStats()
            
            updateStatus("✅ CAUGHT!", Color3.fromRGB(100, 255, 100))
            print("[Auto Fishing] Fish caught! Total: " .. Stats.Catches)
            
            if Config.Enabled then
                task.wait(0.8)
                castRod()
            end
        end)
    end
    
    local lureLanded = FishingRod:FindFirstChild("LureLanded")
    if lureLanded and lureLanded:IsA("RemoteEvent") then
        lureLanded.OnClientEvent:Connect(function(lure)
            updateStatus("🎯 LANDED", Color3.fromRGB(150, 255, 150))
        end)
    end
end

local function monitorFishingUI()
    PlayerGui.ChildAdded:Connect(function(child)
        if child.Name == "FishingUI" then
            InMinigame = true
            updateStatus("🎮 MINIGAME", Color3.fromRGB(255, 200, 100))
            
            task.wait(Config.MinigameDelay)
            monitorProgressBar()
            
            child.Destroying:Connect(function()
                InMinigame = false
                stopSpamming()
                Stats.Catches = Stats.Catches + 1
                updateStats()
                
                updateStatus("✅ CAUGHT!", Color3.fromRGB(100, 255, 100))
                
                if Config.Enabled then
                    task.wait(0.8)
                    castRod()
                end
            end)
        end
    end)
end

-- Button Events - Space Theme
ToggleButton.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    
    if Config.Enabled then
        ToggleButton.Text = IsMobile and "⏸ STOP" or "⏸ STOP FISHING"
        
        Stats.StartTime = tick()
        Stats.Catches = 0
        updateStats()
        
        updateStatus("🚀 STARTING...", Theme.Accent)
        
        -- Space theme animation for start
        TweenService:Create(ToggleButton, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = Theme.AccentSecondary
        }):Play()
        
        if ToggleButton:FindFirstChildOfClass("UIStroke") then
            TweenService:Create(ToggleButton:FindFirstChildOfClass("UIStroke"), TweenInfo.new(0.3), {
                Color = Theme.Accent,
                Thickness = 3
            }):Play()
        end
        
        task.wait(0.5)
        castRod()
    else
        ToggleButton.Text = IsMobile and "▶ START" or "▶ START FISHING"
        
        stopSpamming()
        updateStatus("💤 STOPPED", Theme.TextMuted)
        
        -- Space theme animation for stop
        TweenService:Create(ToggleButton, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = Theme.Accent
        }):Play()
        
        if ToggleButton:FindFirstChildOfClass("UIStroke") then
            TweenService:Create(ToggleButton:FindFirstChildOfClass("UIStroke"), TweenInfo.new(0.3), {
                Color = Theme.AccentSecondary,
                Thickness = 2
            }):Play()
        end
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    Config.Enabled = false
    stopSpamming()
    ScreenGui:Destroy()
end)

-- Minimize button functionality with space theme
local minimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    ContentFrame.Visible = not minimized
    
    if minimized then
        MinimizeButton.Text = "+"
        TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, IsMobile and 320 or 300, 0, IsMobile and 50 or 45)
        }):Play()
    else
        MinimizeButton.Text = "−"
        TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, IsMobile and 320 or 300, 0, IsMobile and 235 or 220)
        }):Play()
    end
end)

-- Hover effects - Space Theme (PC only)
if IsPC then
    ToggleButton.MouseEnter:Connect(function()
        TweenService:Create(ToggleButton, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 270, 0, 52)
        }):Play()
        
        if ToggleButton:FindFirstChildOfClass("UIStroke") then
            TweenService:Create(ToggleButton:FindFirstChildOfClass("UIStroke"), TweenInfo.new(0.15), {
                Color = Theme.Accent,
                Thickness = 3
            }):Play()
        end
    end)

    ToggleButton.MouseLeave:Connect(function()
        TweenService:Create(ToggleButton, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 260, 0, 50)
        }):Play()
        
        if ToggleButton:FindFirstChildOfClass("UIStroke") then
            TweenService:Create(ToggleButton:FindFirstChildOfClass("UIStroke"), TweenInfo.new(0.15), {
                Color = Theme.AccentSecondary,
                Thickness = 2
            }):Play()
        end
    end)
    
    -- Minimize button hover effects
    MinimizeButton.MouseEnter:Connect(function()
        TweenService:Create(MinimizeButton, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = Theme.Accent
        }):Play()
        
        if MinimizeButton:FindFirstChildOfClass("UIStroke") then
            TweenService:Create(MinimizeButton:FindFirstChildOfClass("UIStroke"), TweenInfo.new(0.15), {
                Color = Theme.AccentSecondary,
                Thickness = 2
            }):Play()
        end
    end)
    
    MinimizeButton.MouseLeave:Connect(function()
        TweenService:Create(MinimizeButton, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = Theme.SurfaceAlt
        }):Play()
        
        if MinimizeButton:FindFirstChildOfClass("UIStroke") then
            TweenService:Create(MinimizeButton:FindFirstChildOfClass("UIStroke"), TweenInfo.new(0.15), {
                Color = Theme.Stroke,
                Thickness = 1
            }):Play()
        end
    end)
    
    -- Close button hover effects
    CloseButton.MouseEnter:Connect(function()
        TweenService:Create(CloseButton, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        }):Play()
        
        if CloseButton:FindFirstChildOfClass("UIStroke") then
            TweenService:Create(CloseButton:FindFirstChildOfClass("UIStroke"), TweenInfo.new(0.15), {
                Color = Color3.fromRGB(255, 80, 80),
                Thickness = 2
            }):Play()
        end
    end)
    
    CloseButton.MouseLeave:Connect(function()
        TweenService:Create(CloseButton, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = Theme.SurfaceAlt
        }):Play()
        
        if CloseButton:FindFirstChildOfClass("UIStroke") then
            TweenService:Create(CloseButton:FindFirstChildOfClass("UIStroke"), TweenInfo.new(0.15), {
                Color = Theme.Stroke,
                Thickness = 1
            }):Play()
        end
    end)
end

-- Monitor character changes
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    FishingRod = nil
    IsCasting = false
    InMinigame = false
    stopSpamming()
    
    task.wait(1)
    FishingRod = findFishingRod()
    if FishingRod then
        setupRemoteHooks()
    end
end)

-- Monitor tool changes
Backpack.ChildAdded:Connect(function(child)
    if child:IsA("Tool") and (child:FindFirstChild("Cast") or child.Name:lower():find("rod")) then
        FishingRod = child
        setupRemoteHooks()
    end
end)

Character.ChildAdded:Connect(function(child)
    if child:IsA("Tool") and (child:FindFirstChild("Cast") or child.Name:lower():find("rod")) then
        FishingRod = child
        setupRemoteHooks()
    end
end)

-- Auto cast loop
task.spawn(function()
    while task.wait(3) do
        if Config.Enabled and not InMinigame and not IsCasting then
            castRod()
        end
        if Config.Enabled then
            updateStats()
        end
    end
end)

-- Setup
FishingRod = findFishingRod()
if FishingRod then
    setupRemoteHooks()
end
monitorFishingUI()

-- Startup animation - Space Theme
if IsMobile then
    MainFrame.Position = UDim2.new(0.5, -160, -0.4, 0)
    MainFrame.BackgroundTransparency = 1
    TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -160, 0.05, 0),
        BackgroundTransparency = 0
    }):Play()
else
    MainFrame.Position = UDim2.new(0.5, -150, -0.4, 0)
    MainFrame.BackgroundTransparency = 1
    TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -150, 0.1, 0),
        BackgroundTransparency = 0
    }):Play()
end

print("=================================")
print("🚀 AUTO FISHING ULTIMATE LOADED!")
print("Platform: " .. (IsMobile and "📱 MOBILE" or "💻 PC"))
print("✓ Optimized for " .. (IsMobile and "Mobile" or "PC"))
print("=================================")
print("Ready to fish! Click START! 🚀")
print("=================================")