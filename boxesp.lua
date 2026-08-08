--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local function createEsp(player)
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.new(1, 1, 1)
    box.Thickness = 1
    box.Transparency = 1
    box.Filled = false

    local connection
    connection = RunService.RenderStepped:Connect(function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = player.Character.HumanoidRootPart
            local position, onScreen = Camera:WorldToViewportPoint(rootPart.Position)

            if onScreen then
                local top = Camera:WorldToViewportPoint(rootPart.Position + Vector3.new(0, 3, 0))
                local bottom = Camera:WorldToViewportPoint(rootPart.Position + Vector3.new(0, -3.5, 0))
                local sizeY = math.abs(top.Y - bottom.Y)
                local sizeX = sizeY * 0.6
                
                box.Size = Vector2.new(sizeX, sizeY)
                box.Position = Vector2.new(position.X - sizeX / 2, position.Y - sizeY / 2)
                box.Visible = true
            else
                box.Visible = false
            end
        else
            box.Visible = false
        end
    end)

    player.AncestryChanged:Connect(function(_, parent)
        if not parent then
            box.Visible = false
            box:Remove()
            connection:Disconnect()
        end
    end)
end

for _, player in pairs(Players:GetPlayers()) do
    if player ~= Players.LocalPlayer then
        createEsp(player)
    end
end

Players.PlayerAdded:Connect(createEsp)
