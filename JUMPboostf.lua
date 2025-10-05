local SuperJump = {}
SuperJump.Active = false
SuperJump.JumpPower = 2.2

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local connections = {}
local platformCache = {}
local lastJumpTime = 0
local jumpCooldown = 0.5

local function safeCall(func)
    local success = pcall(func)
    return success
end

local function setupAntiDetect()
    safeCall(function()
        local mt = getrawmetatable(game)
        setreadonly(mt, false)
        local oldNamecall = mt.__namecall
        
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            if method == "Kick" or method == "Ban" then
                return wait(9e9)
            end
            
            if method == "FireServer" or method == "InvokeServer" then
                local name = self.Name:lower()
                if name:find("detect") or name:find("anti") or name:find("cheat") or
                   name:find("jump") or name:find("velocity") then
                    return
                end
            end
            
            return oldNamecall(self, ...)
        end)
        
        setreadonly(mt, true)
    end)
end

local function blockAntiCheat()
    safeCall(function()
        for _, obj in pairs(game:GetDescendants()) do
            if obj:IsA("LocalScript") then
                local name = obj.Name:lower()
                if name:find("anti") or name:find("detect") or name:find("jump") then
                    obj.Disabled = true
                end
            end
        end
    end)
end

local function cleanupBodyMovers(character)
    safeCall(function()
        for _, obj in pairs(character:GetDescendants()) do
            if obj:IsA("BodyVelocity") or obj:IsA("BodyPosition") or obj:IsA("BodyGyro") then
                obj:Destroy()
            end
        end
    end)
end

local function createBoostPlatform(position)
    local platform = Instance.new("Part")
    platform.Name = "BP"
    platform.Size = Vector3.new(3, 0.2, 3)
    platform.Position = position
    platform.Anchored = true
    platform.CanCollide = true
    platform.Transparency = 1
    platform.Material = Enum.Material.ForceField
    platform.Parent = workspace
    
    table.insert(platformCache, platform)
    
    spawn(function()
        wait(0.1)
        if platform and platform.Parent then
            platform:Destroy()
        end
    end)
    
    return platform
end

local function applyJumpBoost(character)
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    cleanupBodyMovers(character)
    
    local currentVelocity = rootPart.AssemblyLinearVelocity
    
    if currentVelocity.Y > 5 then
        local platformPos = rootPart.Position - Vector3.new(0, 3, 0)
        createBoostPlatform(platformPos)
        
        wait(0.03)
        
        local newVelocity = Vector3.new(
            currentVelocity.X,
            currentVelocity.Y * SuperJump.JumpPower,
            currentVelocity.Z
        )
        
        rootPart.AssemblyLinearVelocity = newVelocity
    end
end

local function createGUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "SuperJumpGUI"
    gui.ResetOnSpawn = false
    gui.Parent = CoreGui
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 70, 0, 70)
    btn.Position = UDim2.new(0, 20, 0.5, 60)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.Active = true
    btn.Draggable = true
    btn.Parent = gui
    
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Color3.fromRGB(255, 140, 0)
    stroke.Thickness = 3
    
    local icon = Instance.new("TextLabel", btn)
    icon.Size = UDim2.new(1, 0, 0.7, 0)
    icon.BackgroundTransparency = 1
    icon.Text = "🦘"
    icon.TextSize = 32
    icon.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    local status = Instance.new("TextLabel", btn)
    status.Size = UDim2.new(1, 0, 0.3, 0)
    status.Position = UDim2.new(0, 0, 0.7, 0)
    status.BackgroundTransparency = 1
    status.Text = "OFF"
    status.TextSize = 11
    status.Font = Enum.Font.GothamBold
    status.TextColor3 = Color3.fromRGB(255, 100, 100)
    
    local powerLabel = Instance.new("TextLabel", btn)
    powerLabel.Size = UDim2.new(0, 45, 0, 22)
    powerLabel.Position = UDim2.new(1, 5, 0, 0)
    powerLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    powerLabel.BorderSizePixel = 0
    powerLabel.Text = "2.2x"
    powerLabel.TextSize = 11
    powerLabel.Font = Enum.Font.GothamBold
    powerLabel.TextColor3 = Color3.fromRGB(255, 140, 0)
    Instance.new("UICorner", powerLabel).CornerRadius = UDim.new(0, 6)
    
    btn.MouseButton1Click:Connect(function()
        SuperJump:Toggle()
        
        if SuperJump.Active then
            status.Text = "ON"
            status.TextColor3 = Color3.fromRGB(100, 255, 100)
            btn.BackgroundColor3 = Color3.fromRGB(40, 50, 30)
            icon.Text = "✅"
            stroke.Color = Color3.fromRGB(100, 255, 100)
        else
            status.Text = "OFF"
            status.TextColor3 = Color3.fromRGB(255, 100, 100)
            btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            icon.Text = "🦘"
            stroke.Color = Color3.fromRGB(255, 140, 0)
        end
    end)
end

function SuperJump:Enable()
    if self.Active then return end
    self.Active = true
    
    local character = LocalPlayer.Character
    if not character then
        self.Active = false
        return
    end
    
    connections.JumpDetect = RunService.Heartbeat:Connect(function()
        if not self.Active then return end
        
        local char = LocalPlayer.Character
        if not char then return end
        
        local hum = char:FindFirstChild("Humanoid")
        if not hum then return end
        
        if hum:GetState() == Enum.HumanoidStateType.Jumping then
            local currentTime = tick()
            
            if currentTime - lastJumpTime >= jumpCooldown then
                lastJumpTime = currentTime
                applyJumpBoost(char)
            end
        end
    end)
    
    connections.Cleanup = RunService.Heartbeat:Connect(function()
        if not self.Active then return end
        
        local char = LocalPlayer.Character
        if char then
            cleanupBodyMovers(char)
        end
    end)
end

function SuperJump:Disable()
    if not self.Active then return end
    self.Active = false
    
    for _, conn in pairs(connections) do
        if conn then
            conn:Disconnect()
        end
    end
    connections = {}
    
    for _, platform in pairs(platformCache) do
        if platform and platform.Parent then
            platform:Destroy()
        end
    end
    platformCache = {}
    
    local char = LocalPlayer.Character
    if char then
        cleanupBodyMovers(char)
    end
end

function SuperJump:Toggle()
    if self.Active then
        self:Disable()
    else
        self:Enable()
    end
end

setupAntiDetect()
blockAntiCheat()
createGUI()

LocalPlayer.CharacterAdded:Connect(function()
    wait(1.5)
    
    if SuperJump.Active then
        SuperJump:Disable()
        wait(0.5)
        SuperJump:Enable()
    end
    
    blockAntiCheat()
end)

return SuperJump
