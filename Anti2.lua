-- ═══════════════════════════════════════════════════════
-- 🛡️ ROBANIK ANTI-ANTICHEAT #1 - HARDCORE PROTECTION
-- ═══════════════════════════════════════════════════════

local AntiCheat1 = {}
AntiCheat1.Version = "1.0.0"

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local function log1(msg, lvl)
    print(string.format("[AC1] %s %s", lvl == "error" and "❌" or "✅", msg))
end

local function safeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        log1("Error: " .. tostring(result), "error")
    end
    return success
end

local function setupMetatableProtection()
    log1("Защита метатаблиц...", "info")
    safeCall(function()
        local mt = getrawmetatable(game)
        local oldNamecall = mt.__namecall
        local oldIndex = mt.__index
        local oldNewindex = mt.__newindex
        setreadonly(mt, false)
        local blockedMethods = {"Kick", "kick", "Ban", "ban", "RemovePlayer"}
        local blockedEvents = {
            "anticheat", "anti", "detect", "cheat", "exploit", 
            "hack", "ban", "kick", "flag", "report", "log",
            "check", "verify", "validate", "security"
        }
        mt.__namecall = newcclosure(function(self, ...)
            local args = {...}
            local method = getnamecallmethod()
            for _, blocked in ipairs(blockedMethods) do
                if method:lower() == blocked:lower() then
                    log1("Блок метод: " .. method, "warn")
                    return
                end
            end
            if method == "FireServer" or method == "InvokeServer" then
                local eventName = self.Name:lower()
                for _, blocked in ipairs(blockedEvents) do
                    if eventName:find(blocked) then
                        log1("Блок событие: " .. self.Name, "warn")
                        return
                    end
                end
            end
            return oldNamecall(self, ...)
        end)
        mt.__index = newcclosure(function(self, key)
            if typeof(self) == "Instance" and self:IsA("PlayerGui") then
                if key:find("Robanik") or key:find("Exploit") then
                    return nil
                end
            end
            return oldIndex(self, key)
        end)
        mt.__newindex = newcclosure(function(self, key, value)
            if typeof(self) == "Instance" and self:IsA("Humanoid") then
                if key == "WalkSpeed" or key == "JumpPower" or key == "Health" then
                    return
                end
            end
            return oldNewindex(self, key, value)
        end)
        setreadonly(mt, true)
    end)
end

local function setupAntiKick()
    log1("Защита от кика...", "info")
    safeCall(function()
        LocalPlayer.Kick = newcclosure(function(...)
            log1("Кик заблокирован!", "warn")
            return
        end)
        local mt = getrawmetatable(game)
        local oldNamecall = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if method == "Kick" or method == "kick" then
                return
            end
            if self == LocalPlayer and (method == "Destroy" or method == "Remove") then
                return
            end
            return oldNamecall(self, ...)
        end)
        setreadonly(mt, true)
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                local name = v.Name:lower()
                if name:find("kick") or name:find("ban") then
                    safeCall(function()
                        v.OnClientEvent:Connect(function() end)
                    end)
                end
            end
        end
    end)
end

local function setupAntiScriptDetection()
    log1("Отключение античит скриптов...", "info")
    safeCall(function()
        local keywords = {"anti", "detect", "cheat", "hack", "exploit", "security", "check"}
        for _, desc in pairs(game:GetDescendants()) do
            safeCall(function()
                if desc:IsA("LocalScript") or desc:IsA("ModuleScript") then
                    local name = desc.Name:lower()
                    for _, keyword in ipairs(keywords) do
                        if name:find(keyword) then
                            desc.Disabled = true
                            break
                        end
                    end
                end
            end)
        end
        game.DescendantAdded:Connect(function(desc)
            safeCall(function()
                if desc:IsA("LocalScript") or desc:IsA("ModuleScript") then
                    wait(0.1)
                    local name = desc.Name:lower()
                    for _, keyword in ipairs(keywords) do
                        if name:find(keyword) then
                            desc.Disabled = true
                            break
                        end
                    end
                end
            end)
        end)
    end)
end

local function setupRemoteProtection()
    log1("Защита Remote'ов...", "info")
    safeCall(function()
        local callCounts = {}
        local MAX_CALLS = 60
        local function isSpamming(remote)
            local name = tostring(remote)
            local time = tick()
            if not callCounts[name] then
                callCounts[name] = {count = 1, lastReset = time}
                return false
            end
            local data = callCounts[name]
            if time - data.lastReset >= 1 then
                data.count = 1
                data.lastReset = time
                return false
            end
            data.count = data.count + 1
            return data.count > MAX_CALLS
        end
        for _, remote in pairs(game:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                safeCall(function()
                    local oldFire = remote.FireServer
                    remote.FireServer = newcclosure(function(self, ...)
                        if isSpamming(self) then
                            return
                        end
                        return oldFire(self, ...)
                    end)
                end)
            end
        end
    end)
end

local function setupGUIProtection()
    log1("Защита GUI...", "info")
    safeCall(function()
        local protectedGuis = {}
        local function hideGui(gui)
            if gui and gui:IsA("ScreenGui") then
                table.insert(protectedGuis, gui)
                local mt = getrawmetatable(gui)
                setreadonly(mt, false)
                local oldIndex = mt.__index
                mt.__index = newcclosure(function(self, key)
                    if key == "Parent" and table.find(protectedGuis, self) then
                        return nil
                    end
                    return oldIndex(self, key)
                end)
                setreadonly(mt, true)
            end
        end
        for _, gui in pairs(CoreGui:GetChildren()) do
            if gui.Name:find("Robanik") then
                hideGui(gui)
            end
        end
        CoreGui.ChildAdded:Connect(function(gui)
            wait(0.1)
            if gui.Name:find("Robanik") then
                hideGui(gui)
            end
        end)
    end)
end

function AntiCheat1:Initialize()
    log1("🛡️ ANTI-ANTICHEAT #1 АКТИВАЦИЯ", "info")
    setupMetatableProtection()
    setupAntiKick()
    setupAntiScriptDetection()
    setupRemoteProtection()
    setupGUIProtection()
    log1("✅ AC#1 активен!", "info")
end

-- ═══════════════════════════════════════════════════════
-- 🎭 ROBANIK ANTI-ANTICHEAT #2 - LEGITIMACY EMULATOR
-- ═══════════════════════════════════════════════════════

local AntiCheat2 = {}
AntiCheat2.Version = "2.0.0"

local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

local function log2(msg, lvl)
    print(string.format("[AC2] %s %s", lvl == "error" and "🔥" or "🎭", msg))
end

local humanBehavior = {
    lastInputTime = tick(),
    inputPattern = {},
    movementPattern = {},
    reactionTimes = {}
}

local function recordHumanInput(inputType)
    local currentTime = tick()
    local timeSinceLastInput = currentTime - humanBehavior.lastInputTime
    table.insert(humanBehavior.inputPattern, {
        type = inputType,
        time = currentTime,
        delay = timeSinceLastInput
    })
    if #humanBehavior.inputPattern > 50 then
        table.remove(humanBehavior.inputPattern, 1)
    end
    humanBehavior.lastInputTime = currentTime
end

local function getAverageReactionTime()
    if #humanBehavior.reactionTimes == 0 then
        return math.random(150, 300) / 1000
    end
    local sum = 0
    for _, time in ipairs(humanBehavior.reactionTimes) do
        sum = sum + time
    end
    return sum / #humanBehavior.reactionTimes
end

local function addHumanDelay()
    local baseDelay = getAverageReactionTime()
    local variance = math.random(-50, 50) / 1000
    local finalDelay = math.max(0.05, baseDelay + variance)
    wait(finalDelay)
end

local function setupLegitimacyEmulator()
    log2("Эмулятор легитимности...", "info")
    safeCall(function()
        UserInputService.InputBegan:Connect(function(input)
            recordHumanInput(input.UserInputType.Name)
            local reactionTime = math.random(150, 350) / 1000
            table.insert(humanBehavior.reactionTimes, reactionTime)
            if #humanBehavior.reactionTimes > 20 then
                table.remove(humanBehavior.reactionTimes, 1)
            end
        end)
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")
        local lastPosition = character.HumanoidRootPart.Position
        RunService.Heartbeat:Connect(function()
            local currentPos = character.HumanoidRootPart.Position
            local movement = (currentPos - lastPosition).Magnitude
            table.insert(humanBehavior.movementPattern, movement)
            if #humanBehavior.movementPattern > 100 then
                table.remove(humanBehavior.movementPattern, 1)
            end
            lastPosition = currentPos
        end)
    end)
end

local fakeStats = {
    walkSpeed = 16,
    jumpPower = 50,
    health = 100,
    position = Vector3.new(0, 0, 0),
    velocity = Vector3.new(0, 0, 0)
}

local function setupDataSpoofer()
    log2("Подмена статистики...", "info")
    safeCall(function()
        local mt = getrawmetatable(game)
        setreadonly(mt, false)
        local oldNamecall = mt.__namecall
        mt.__namecall = newcclosure(function(self, ...)
            local args = {...}
            local method = getnamecallmethod()
            if method == "FireServer" or method == "InvokeServer" then
                local newArgs = {}
                for i, arg in ipairs(args) do
                    if type(arg) == "number" then
                        if arg > 100 and arg < 1000 then
                            local spoofed = math.random(10, 20)
                            table.insert(newArgs, spoofed)
                            log2("Подменено значение: " .. arg .. " -> " .. spoofed, "warn")
                        else
                            table.insert(newArgs, arg)
                        end
                    elseif typeof(arg) == "Vector3" then
                        local variance = Vector3.new(
                            math.random(-100, 100) / 100,
                            math.random(-100, 100) / 100,
                            math.random(-100, 100) / 100
                        )
                        table.insert(newArgs, arg + variance)
                    else
                        table.insert(newArgs, arg)
                    end
                end
                return oldNamecall(self, unpack(newArgs))
            end
            return oldNamecall(self, ...)
        end)
        setreadonly(mt, true)
    end)
end

local function setupDelaySimulator()
    log2("Симуляция задержек...", "info")
    safeCall(function()
        local mt = getrawmetatable(game)
        setreadonly(mt, false)
        local oldNamecall = mt.__namecall
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if method == "FireServer" then
                addHumanDelay()
            end
            return oldNamecall(self, ...)
        end)
        setreadonly(mt, true)
    end)
end

local function setupDataValidator()
    log2("Валидатор данных...", "info")
    safeCall(function()
        local mt = getrawmetatable(game)
        setreadonly(mt, false)
        local oldNamecall = mt.__namecall
        mt.__namecall = newcclosure(function(self, ...)
            local args = {...}
            local method = getnamecallmethod()
            if method == "FireServer" or method == "InvokeServer" then
                for i, arg in ipairs(args) do
                    if type(arg) == "number" then
                        if arg ~= arg then
                            args[i] = 0
                        end
                        if arg == math.huge or arg == -math.huge then
                            args[i] = 0
                        end
                        if math.abs(arg) > 1e10 then
                            args[i] = math.random(1, 100)
                        end
                    end
                    if typeof(arg) == "Vector3" then
                        if arg.Magnitude > 10000 then
                            args[i] = Vector3.new(0, 0, 0)
                        end
                    end
                end
                return oldNamecall(self, unpack(args))
            end
            return oldNamecall(self, ...)
        end)
        setreadonly(mt, true)
    end)
end

local fakeResponses = {}

local function setupFakeValidation()
    log2("Фейковые проверки...", "info")
    safeCall(function()
        for _, remote in pairs(game:GetDescendants()) do
            if remote:IsA("RemoteFunction") then
                local name = remote.Name:lower()
                if name:find("check") or name:find("verify") or name:find("validate") then
                    fakeResponses[remote.Name] = true
                    safeCall(function()
                        local oldInvoke = remote.InvokeServer
                        remote.InvokeServer = newcclosure(function(self, ...)
                            addHumanDelay()
                            local result = oldInvoke(self, ...)
                            if type(result) == "boolean" then
                                log2("Фейковый ответ для: " .. self.Name, "warn")
                                return true
                            end
                            if type(result) == "number" then
                                return math.random(1, 100)
                            end
                            return result
                        end)
                    end)
                end
            end
        end
    end)
end

local remoteProxy = {}

local function setupRemoteProxy()
    log2("Прокси Remote'ов...", "info")
    safeCall(function()
        local mt = getrawmetatable(game)
        setreadonly(mt, false)
        local oldNamecall = mt.__namecall
        mt.__namecall = newcclosure(function(self, ...)
            local args = {...}
            local method = getnamecallmethod()
            if method == "FireServer" then
                local proxyKey = self.Name .. "_" .. tostring(tick())
                remoteProxy[proxyKey] = {
                    remote = self,
                    args = args,
                    time = tick()
                }
                spawn(function()
                    wait(math.random(10, 50) / 1000)
                    if remoteProxy[proxyKey] then
                        local data = remoteProxy[proxyKey]
                        oldNamecall(data.remote, unpack(data.args))
                        remoteProxy[proxyKey] = nil
                    end
                end)
                return
            end
            return oldNamecall(self, ...)
        end)
        setreadonly(mt, true)
    end)
end

local behaviorRandomizer = {
    lastRandomAction = tick(),
    patterns = {}
}

local function setupAntiPatternDetection()
    log2("Анти-паттерн детекция...", "info")
    safeCall(function()
        spawn(function()
            while wait(math.random(5, 15)) do
                local character = LocalPlayer.Character
                if character and character:FindFirstChild("Humanoid") then
                    local randomActions = {
                        function()
                            local humanoid = character.Humanoid
                            if humanoid.WalkSpeed == 16 then
                                humanoid.WalkSpeed = math.random(15, 17)
                                wait(0.1)
                                humanoid.WalkSpeed = 16
                            end
                        end,
                        function()
                            if character:FindFirstChild("HumanoidRootPart") then
                                local root = character.HumanoidRootPart
                                local oldCFrame = root.CFrame
                                root.CFrame = oldCFrame * CFrame.Angles(0, math.rad(math.random(-5, 5)), 0)
                            end
                        end,
                        function()
                            wait(math.random(1, 3))
                        end
                    }
                    local randomAction = randomActions[math.random(1, #randomActions)]
                    safeCall(randomAction)
                    behaviorRandomizer.lastRandomAction = tick()
                end
            end
        end)
        local mt = getrawmetatable(game)
        setreadonly(mt, false)
        local oldNamecall = mt.__namecall
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if method == "FireServer" then
                local shouldDelay = math.random(1, 10) > 7
                if shouldDelay then
                    wait(math.random(5, 50) / 1000)
                end
            end
            return oldNamecall(self, ...)
        end)
        setreadonly(mt, true)
    end)
end

function AntiCheat2:Initialize()
    log2("🎭 ANTI-ANTICHEAT #2 АКТИВАЦИЯ", "info")
    setupLegitimacyEmulator()
    setupDataSpoofer()
    setupDelaySimulator()
    setupDataValidator()
    setupFakeValidation()
    setupRemoteProxy()
    setupAntiPatternDetection()
    log2("✅ AC#2 активен!", "info")
end

spawn(function()
    wait(1)
    AntiCheat1:Initialize()
    wait(0.5)
    AntiCheat2:Initialize()
    print("═══════════════════════════════════")
    print("🛡️ ROBANIK DUAL ANTI-ANTICHEAT")
    print("✅ AC#1: Hardcore Protection")
    print("✅ AC#2: Legitimacy Emulator")
    print("🔒 Двойная защита активна!")
    print("═══════════════════════════════════")
end)

LocalPlayer.CharacterAdded:Connect(function()
    wait(2)
    log1("Реинициализация AC#1...", "info")
    log2("Реинициализация AC#2...", "info")
    setupMetatableProtection()
    setupAntiKick()
    setupLegitimacyEmulator()
    setupDataSpoofer()
end)

return {AntiCheat1 = AntiCheat1, AntiCheat2 = AntiCheat2}
