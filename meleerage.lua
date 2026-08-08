local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local DISTANCE = 1

local function getFarthestPlayer()
	local character = LocalPlayer.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then return nil end

	local farthest = nil
	local farthestDistance = -math.huge

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local targetCharacter = player.Character
			local targetRoot = targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart")

			if targetRoot then
				local distance = (targetRoot.Position - root.Position).Magnitude

				if distance > farthestDistance then
					farthestDistance = distance
					farthest = player
				end
			end
		end
	end

	return farthest
end

RunService.RenderStepped:Connect(function()
	local character = LocalPlayer.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local target = getFarthestPlayer()
	if not target then return end

	local targetRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
	if not targetRoot then return end

	-- directly behind the target
	local position = targetRoot.Position - targetRoot.CFrame.LookVector * DISTANCE

	root.CFrame = CFrame.lookAt(
		position,
		targetRoot.Position
	)
end)
