-- Variables
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:FindFirstChildOfClass("Humanoid")
local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")

local flying = true
local ctrl = {f = 0, b = 0, l = 0, r = 0}
local maxspeed = 50
local speed = 0
local glideDecay = 0.98 -- Decay factor for smooth stop
local rotationSpeed = 15 -- Increased rotation speed for faster alignment

-- Create BodyGyro and BodyVelocity for flight
local bg = Instance.new("BodyGyro", torso)
bg.P = 9e4
bg.maxTorque = Vector3.new(9e9, 9e9, 9e9) -- Allow full rotation
bg.cframe = torso.CFrame

local bv = Instance.new("BodyVelocity", torso)
bv.velocity = Vector3.new(0, 0.1, 0)
bv.maxForce = Vector3.new(9e9, 9e9, 9e9)

-- Function to handle flight
local function startFlying()
    humanoid.PlatformStand = true
    while flying do
        game:GetService("RunService").RenderStepped:Wait()

        if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
            speed = speed + 0.5 + (speed / maxspeed)
            if speed > maxspeed then
                speed = maxspeed
            end
        elseif speed ~= 0 then
            speed = speed * glideDecay
            if speed < 0.1 then
                speed = 0
            end
        end

        if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
            bv.velocity = ((game.Workspace.CurrentCamera.CFrame.LookVector * (ctrl.f + ctrl.b)) + ((game.Workspace.CurrentCamera.CFrame * CFrame.new(ctrl.l + ctrl.r, (ctrl.f + ctrl.b) * 0.2, 0).p) - game.Workspace.CurrentCamera.CFrame.p)) * speed
        else
            bv.velocity = bv.velocity * glideDecay
        end

        -- Smoothly and quickly rotate the character towards the camera's direction
        local currentCFrame = torso.CFrame
        local targetCFrame = game.Workspace.CurrentCamera.CFrame
        bg.cframe = currentCFrame:Lerp(targetCFrame, rotationSpeed * game:GetService("RunService").RenderStepped:Wait())
    end
end

-- Control binding to move the character while flying
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then
        ctrl.f = 1
    elseif input.KeyCode == Enum.KeyCode.S then
        ctrl.b = -1
    elseif input.KeyCode == Enum.KeyCode.A then
        ctrl.l = -1
    elseif input.KeyCode == Enum.KeyCode.D then
        ctrl.r = 1
    end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then
        ctrl.f = 0
    elseif input.KeyCode == Enum.KeyCode.S then
        ctrl.b = 0
    elseif input.KeyCode == Enum.KeyCode.A then
        ctrl.l = 0
    elseif input.KeyCode == Enum.KeyCode.D then
        ctrl.r = 0
    end
end)

-- Automatically start flying
startFlying()
