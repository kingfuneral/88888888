local Players = game:GetService("Players")

local function createUsernameTag(player, character)
    local head = character:WaitForChild("Head", 10)

    if not head then
        return
    end

    local old = head:FindFirstChild("UsernameTag")
    if old then
        old:Destroy()
    end

    local gui = Instance.new("BillboardGui")
    gui.Name = "UsernameTag"
    gui.Adornee = head
    gui.Size = UDim2.fromOffset(120, 22)
    gui.StudsOffset = Vector3.new(0, 2.3, 0)
    gui.AlwaysOnTop = true
    gui.MaxDistance = 1000
    gui.Parent = head

    local username = Instance.new("TextLabel")
    username.Name = "Username"
    username.Size = UDim2.fromScale(1, 1)
    username.BackgroundTransparency = 1
    username.Text = player.Name
    username.TextColor3 = Color3.fromRGB(255, 255, 255)
    username.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    username.TextStrokeTransparency = 0
    username.TextScaled = true
    username.Font = Enum.Font.Gotham
    username.Parent = gui
end

local function setupPlayer(player)
    player.CharacterAdded:Connect(function(character)
        createUsernameTag(player, character)
    end)

    if player.Character then
        task.spawn(function()
            createUsernameTag(player, player.Character)
        end)
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    setupPlayer(player)
end

Players.PlayerAdded:Connect(setupPlayer)
