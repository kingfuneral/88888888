--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local ESP = {}
local LocalPlayer = Players.LocalPlayer

local Config = {
    SkeletonColor = Color3.fromRGB(255, 255, 255),
    Thickness = 2.5,
    Transparency = 1,
    DistanceFade = true,
    MaxDistance = 500
}

local function IsAlive(player)
    if not player or not player.Character then return false end
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    return humanoid and humanoid.Health > 0
end

function ESP.CreateESP(player)
    if player == LocalPlayer then return end
    if not player or not player.Character then return end

    pcall(function()
        local character = player.Character
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end

        if ESP[player] then
            ESP.RemoveESP(player)
        end

        ESP[player] = {lines = {}}

        local head = character:FindFirstChild("Head")
        local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
        local lowerTorso = character:FindFirstChild("LowerTorso")
        local leftArm = character:FindFirstChild("Left Arm") or character:FindFirstChild("LeftUpperArm")
        local rightArm = character:FindFirstChild("Right Arm") or character:FindFirstChild("RightUpperArm")
        local leftLeg = character:FindFirstChild("Left Leg") or character:FindFirstChild("LeftUpperLeg")
        local rightLeg = character:FindFirstChild("Right Leg") or character:FindFirstChild("RightUpperLeg")
        local leftHand = character:FindFirstChild("LeftHand") or character:FindFirstChild("LeftLowerArm")
        local rightHand = character:FindFirstChild("RightHand") or character:FindFirstChild("RightLowerArm")
        local leftFoot = character:FindFirstChild("LeftFoot") or character:FindFirstChild("LeftLowerLeg")
        local rightFoot = character:FindFirstChild("RightFoot") or character:FindFirstChild("RightLowerLeg")

        local connections = {}
        
        if head and torso then table.insert(connections, {head, torso}) end
        if torso and lowerTorso then table.insert(connections, {torso, lowerTorso}) end
        if torso and leftArm then table.insert(connections, {torso, leftArm}) end
        if torso and rightArm then table.insert(connections, {torso, rightArm}) end
        if leftArm and leftHand then table.insert(connections, {leftArm, leftHand}) end
        if rightArm and rightHand then table.insert(connections, {rightArm, rightHand}) end
        if (lowerTorso or torso) and leftLeg then 
            table.insert(connections, {lowerTorso or torso, leftLeg}) 
        end
        if (lowerTorso or torso) and rightLeg then 
            table.insert(connections, {lowerTorso or torso, rightLeg}) 
        end
        if leftLeg and leftFoot then table.insert(connections, {leftLeg, leftFoot}) end
        if rightLeg and rightFoot then table.insert(connections, {rightLeg, rightFoot}) end

        for _, connection in ipairs(connections) do
            local part1 = connection[1]
            local part2 = connection[2]

            if part1 and part2 then
                pcall(function()
                    local line = Drawing.new("Line")
                    line.Color = Config.SkeletonColor
                    line.Thickness = Config.Thickness
                    line.Transparency = Config.Transparency
                    line.Visible = false
                    table.insert(ESP[player].lines, {line = line, part1 = part1, part2 = part2})
                end)
            end
        end
    end)
end

function ESP.UpdateESP(player)
    if not ESP[player] then return end
    if not IsAlive(player) then return end

    pcall(function()
        local character = player.Character
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local localCharacter = LocalPlayer.Character
        local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")

        if not humanoidRootPart or not localRoot then return end

        local distance = (humanoidRootPart.Position - localRoot.Position).Magnitude

        local transparency = Config.Transparency
        if Config.DistanceFade and distance > 0 then
            transparency = math.clamp(1 - (distance / Config.MaxDistance), 0.3, 1)
        end

        for _, data in ipairs(ESP[player].lines) do
            local part1 = data.part1
            local part2 = data.part2
            local line = data.line

            if part1 and part2 and part1.Parent and part2.Parent then
                local pos1, onScreen1 = Camera:WorldToViewportPoint(part1.Position)
                local pos2, onScreen2 = Camera:WorldToViewportPoint(part2.Position)

                if onScreen1 and onScreen2 and pos1.Z > 0 and pos2.Z > 0 then
                    line.From = Vector2.new(pos1.X, pos1.Y)
                    line.To = Vector2.new(pos2.X, pos2.Y)
                    line.Transparency = transparency
                    line.Visible = true
                else
                    line.Visible = false
                end
            else
                line.Visible = false
            end
        end
    end)
end

function ESP.RemoveESP(player)
    if ESP[player] then
        pcall(function()
            for _, data in ipairs(ESP[player].lines) do
                if data.line then
                    data.line:Remove()
                end
            end
        end)
        ESP[player] = nil
    end
end

local function SetupPlayer(player)
    if player == LocalPlayer then return end
    
    local charAddedConn
    local charRemovingConn
    
    charAddedConn = player.CharacterAdded:Connect(function(character)
        task.wait(0.5)
        ESP.CreateESP(player)
    end)
    
    charRemovingConn = player.CharacterRemoving:Connect(function(character)
        ESP.RemoveESP(player)
    end)
    
    if player.Character then
        task.spawn(function()
            task.wait(0.5)
            ESP.CreateESP(player)
        end)
    end
end

Players.PlayerAdded:Connect(SetupPlayer)

Players.PlayerRemoving:Connect(function(player)
    ESP.RemoveESP(player)
end)

for _, player in ipairs(Players:GetPlayers()) do
    SetupPlayer(player)
end

RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            ESP.UpdateESP(player)
        end
    end
end)

print("Made by ._changed_ on discord | guns.lol/xup")
