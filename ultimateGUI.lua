-- Universal Script: ESP + Aimbot + FOV + No Recoil + Hitbox + Team Check
-- Interface Aqua com botão abrir/fechar

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")

-- Settings
local Settings = {
    AimbotEnabled = false,
    ESPEnabled = false,
    TracersEnabled = false,
    TeamCheck = true,
    NoRecoil = true,
    HitboxSize = Vector3.new(15, 15, 15),
    FOV = 150,
    InterfaceVisible = true
}

-- GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 240, 0, 260)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
frame.Visible = Settings.InterfaceVisible
frame.BorderSizePixel = 0
Instance.new("UICorner", frame)

local title = Instance.new("TextLabel", frame)
title.Text = "💧 Ultimate GUI"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBlack
title.TextScaled = true
title.TextColor3 = Color3.new(1, 1, 1)

local toggleY = 40
local toggles = {}

local function createToggle(name, default)
    local button = Instance.new("TextButton", frame)
    button.Size = UDim2.new(1, -20, 0, 30)
    button.Position = UDim2.new(0, 10, 0, toggleY)
    button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    button.TextColor3 = Color3.new(1,1,1)
    button.TextScaled = true
    button.Text = name .. ": " .. (Settings[name] and "ON" or "OFF")
    button.Font = Enum.Font.Gotham
    button.BorderSizePixel = 0
    Instance.new("UICorner", button)

    button.MouseButton1Click:Connect(function()
        Settings[name] = not Settings[name]
        button.Text = name .. ": " .. (Settings[name] and "ON" or "OFF")
    end)

    toggleY += 35
end

createToggle("ESPEnabled")
createToggle("TracersEnabled")
createToggle("AimbotEnabled")
createToggle("TeamCheck")
createToggle("NoRecoil")

-- Atalho para esconder/mostrar interface
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightControl then
        frame.Visible = not frame.Visible
        Settings.InterfaceVisible = frame.Visible
    end
end)

-- ESP + Tracer
local drawings = {}
local function createESP(plr)
    if plr == LocalPlayer then return end
    local text = Drawing.new("Text")
    text.Size = 13
    text.Center = true
    text.Outline = true
    text.Font = 2
    text.Visible = false

    local line = Drawing.new("Line")
    line.Thickness = 1.5
    line.Visible = false

    drawings[plr] = {text = text, line = line}
end

local function updateESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            if not drawings[plr] then createESP(plr) end
            local pos, onscreen = Camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
            local name = plr.Name
            local color = (Settings.TeamCheck and plr.Team == LocalPlayer.Team) and Color3.new(0,1,0) or Color3.fromHSV(tick()%5/5,1,1)
            local esp = drawings[plr]

            if Settings.ESPEnabled and onscreen then
                esp.text.Text = name
                esp.text.Position = Vector2.new(pos.X, pos.Y - 25)
                esp.text.Color = color
                esp.text.Visible = true
            else
                esp.text.Visible = false
            end

            if Settings.TracersEnabled and onscreen then
                esp.line.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                esp.line.To = Vector2.new(pos.X, pos.Y)
                esp.line.Color = color
                esp.line.Visible = true
            else
                esp.line.Visible = false
            end
        end
    end
end

-- Hitbox Expander + No Recoil
RunService.RenderStepped:Connect(function()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            if Settings.HitboxSize then
                local root = plr.Character:FindFirstChild("HumanoidRootPart")
                if root then root.Size = Settings.HitboxSize end
            end
        end
    end

    if Settings.NoRecoil then
        local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool and tool:FindFirstChild("Recoil") then
            tool.Recoil:Destroy()
        end
    end

    updateESP()
end)

-- Aimbot
local function getClosest()
    local closest, dist = nil, Settings.FOV
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            if Settings.TeamCheck and plr.Team == LocalPlayer.Team then continue end
            local pos, visible = Camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
            local mousePos = UIS:GetMouseLocation()
            local mag = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
            if visible and mag < dist then
                dist = mag
                closest = plr
            end
        end
    end
    return closest
end

UIS.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 and Settings.AimbotEnabled then
        local target = getClosest()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local pos = target.Character.HumanoidRootPart.Position
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, pos)
        end
    end
end)
