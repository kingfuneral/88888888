local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local MIN_SCALE = 0.55
local MAX_SCALE = 1.0

local CLOSE_DISTANCE = 15
local FAR_DISTANCE = 150

local function createHealthBar(player, character)
    local humanoid = character:WaitForChild("Humanoid", 10)
    local root = character:WaitForChild("HumanoidRootPart", 10)

    if not humanoid or not root then
        return
    end

    local old = character:FindFirstChild("SideHealthBar")
    if old then
        old:Destroy()
    end

    local gui = Instance.new("BillboardGui")
    gui.Name = "SideHealthBar"
    gui.Adornee = root
    gui.Size = UDim2.fromOffset(12, 90)
    gui.StudsOffset = Vector3.new(-3, 0, 0)
    gui.AlwaysOnTop = true
    gui.MaxDistance = 1000
    gui.Parent = character

    -- Black outline
    local outline = Instance.new("Frame")
    outline.Name = "Outline"
    outline.Size = UDim2.fromScale(1, 1)
    outline.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    outline.BorderSizePixel = 0
    outline.Parent = gui

    -- Inner background
    local background = Instance.new("Frame")
    background.Name = "Background"
    background.Position = UDim2.fromOffset(2, 2)
    background.Size = UDim2.new(1, -4, 1, -4)
    background.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    background.BorderSizePixel = 0
    background.ClipsDescendants = true
    background.Parent = outline

    -- Health
    local health = Instance.new("Frame")
    health.Name = "Health"
    health.AnchorPoint = Vector2.new(0, 1)
    health.Position = UDim2.fromScale(0, 1)
    health.Size = UDim2.fromScale(1, 1)
    health.BackgroundColor3 = Color3.fromRGB(80, 255, 80)
    health.BorderSizePixel = 0
    health.Parent = background

    -- Gradient
    local gradient = Instance.new("UIGradient")
    gradient.Rotation = 90
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 255, 80)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 220, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 60, 60))
    })
    gradient.Parent = health

    -- Health updating
    humanoid.HealthChanged:Connect(function()
        local percent = math.clamp(
            humanoid.Health / humanoid.MaxHealth,
            0,
            1
        )

        health.Size = UDim2.fromScale(1, percent)
    end)

    -- Initial health
    local percent = math.clamp(
        humanoid.Health / humanoid.MaxHealth,
        0,
        1
    )

    health.Size = UDim2.fromScale(1, percent)
end

local function setupPlayer(player)
    player.CharacterAdded:Connect(function(character)
        createHealthBar(player, character)
    end)

    if player.Character then
        task.spawn(function()
            createHealthBar(player, player.Character)
        end)
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    setupPlayer(player)
end

Players.PlayerAdded:Connect(setupPlayer)

-- Distance-based scaling
RunService.RenderStepped:Connect(function()
    if not Camera then
        Camera = workspace.CurrentCamera
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            local gui = character and character:FindFirstChild("SideHealthBar")

            if root and gui then
                local distance = (Camera.CFrame.Position - root.Position).Magnitude

                local alpha = math.clamp(
                    (distance - CLOSE_DISTANCE) /
                    (FAR_DISTANCE - CLOSE_DISTANCE),
                    0,
                    1
                )

                local scale = MAX_SCALE + (MIN_SCALE - MAX_SCALE) * alpha

                gui.Size = UDim2.fromOffset(
                    12 * scale,
                    90 * scale
                )
            end
        end
    end
end)
