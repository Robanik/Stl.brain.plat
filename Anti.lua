local AntiCheat = {}
AntiCheat.Version = "3.0.0"
AntiCheat.Enabled = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local function log(msg, lvl)
    local prefix = lvl == "error" and "❌" or lvl == "warn" and "⚠️" or "✅"
    print(string.format("[ROBANIK AC] %s %s", prefix, msg))
end

local function safeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        log("Error: " .. tostring(result), "error")
    end
    return success, result
end

local function setupMetatableProtection()
    log("Инициализация защиты метатаблиц...", "info")
    local success = safeCall(function()
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
                    log("Заблокирован метод: " .. method, "warn")
                    return
                end
            end
            if method == "FireServer" or method == "InvokeServer" then
                local eventName = self.Name:lower()
                for _, blocked in ipairs(blockedEvents) do
                    if eventName:find(blocked) then
                        log("Заблокировано событие: " .. self.Name, "warn")
                        return
                    end
                end
            end
            return oldNamecall(self, ...)
        end)
        mt.__index = newcclosure(function(self, key)
            if typeof(self) == "Instance" and self:IsA("PlayerGui") then
                if key == "RobanikUltimateGUI" or key:find("Exploit") then
                    return nil
                end
            end
            return oldIndex(self, key)
        end)
        mt.__newindex = newcclosure(function(self, key, value)
            if typeof(self) == "Instance" and self:IsA("Humanoid") then
                if key == "WalkSpeed" or key == "JumpPower" or key == "Health" then
                    log("Блокировка изменения " .. key, "warn")
                    return
                end
            end
            return oldNewindex(self, key, value)
        end)
        setreadonly(mt, true)
    end)
    log(success and "Защита метатаблиц активна" or "Ошибка защиты метатаблиц", success and "info" or "error")
    return success
end

local function setupAntiKick()
    log("Инициализация защиты от кика...", "info")
    local success = safeCall(function()
        local oldKick = LocalPlayer.Kick
        LocalPlayer.Kick = newcclosure(function(...)
            log("Попытка кика заблокирована!", "warn")
            return
        end)
        local mt = getrawmetatable(game)
        local oldNamecall = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if method == "Kick" or method == "kick" then
                log("Кик заблокирован через __namecall", "warn")
                return
            end
            if self == LocalPlayer and (method == "Destroy" or method == "Remove") then
                log("Попытка удаления игрока заблокирована", "warn")
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
    log(success and "Защита от кика активна" or "Ошибка защиты от кика", success and "info" or "error")
    return success
end

local function setupAntiScriptDetection()
    log("Инициализация защиты от детектирования...", "info")
    local success = safeCall(function()
        local keywords = {
            "anti", "detect", "cheat", "hack", "exploit", 
            "security", "protection", "check", "verify", "monitor"
        }
        for _, desc in pairs(game:GetDescendants()) do
            safeCall(function()
                if desc:IsA("LocalScript") or desc:IsA("ModuleScript") then
                    local name = desc.Name:lower()
                    for _, keyword in ipairs(keywords) do
                        if name:find(keyword) then
                            log("Отключен скрипт: " .. desc.Name, "warn")
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
                            log("Блокирован новый скрипт: " .. desc.Name, "warn")
                            desc.Disabled = true
                            break
                        end
                    end
                end
            end)
        end)
    end)
    log(success and "Защита от детектирования активна" or "Ошибка", success and "info" or "error")
    return success
end

local function setupRemoteProtection()
    log("Инициализация защиты Remote'ов...", "info")
    local success = safeCall(function()
        local blockedRemotes = {}
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
                        if isSpamming(self) or blockedRemotes[self.Name] then
                            log("Блокирован Remote: " .. self.Name, "warn")
                            return
                        end
                        return oldFire(self, ...)
                    end)
                end)
            end
            if remote:IsA("RemoteFunction") then
                safeCall(function()
                    local oldInvoke = remote.InvokeServer
                    remote.InvokeServer = newcclosure(function(self, ...)
                        if isSpamming(self) or blockedRemotes[self.Name] then
                            log("Блокирован RemoteFunction: " .. self.Name, "warn")
                            return
                        end
                        return oldInvoke(self, ...)
                    end)
                end)
            end
        end
        game.DescendantAdded:Connect(function(desc)
            wait(0.05)
            if desc:IsA("RemoteEvent") then
                safeCall(function()
                    local oldFire = desc.FireServer
                    desc.FireServer = newcclosure(function(self, ...)
                        if isSpamming(self) or blockedRemotes[self.Name] then
                            return
                        end
                        return oldFire(self, ...)
                    end)
                end)
            end
        end)
    end)
    log(success and "Защита Remote'ов активна" or "Ошибка", success and "info" or "error")
    return success
end

local function setupEnvironmentProtection()
    log("Инициализация защиты окружения...", "info")
    local success = safeCall(function()
        local exploitFuncs = {
            "readfile", "writefile", "isfile", "delfile",
            "loadfile", "dofile", "listfiles", "makefolder",
            "HttpGet", "HttpPost", "GetObjects", "saveinstance",
            "getgc", "getgenv", "getrenv", "getrawmetatable",
            "setreadonly", "hookfunction", "newcclosure",
            "islclosure", "decompile", "setclipboard"
        }
        local fakeEnv = {}
        for _, funcName in ipairs(exploitFuncs) do
            if getgenv()[funcName] then
                fakeEnv[funcName] = getgenv()[funcName]
                safeCall(function()
                    getgenv()[funcName] = nil
                end)
            end
        end
        if not getgenv()._G then
            getgenv()._G = {}
        end
        local oldG = {}
        for k, v in pairs(getgenv()._G) do
            oldG[k] = v
        end
        setmetatable(getgenv()._G, {
            __index = function(self, key)
                return oldG[key]
            end,
            __newindex = function(self, key, value)
                if key:lower():find("anti") or key:lower():find("detect") then
                    log("Блокирована запись в _G: " .. tostring(key), "warn")
                    return
                end
                oldG[key] = value
            end
        })
    end)
    log(success and "Защита окружения активна" or "Ошибка", success and "info" or "error")
    return success
end

local function setupSpeedProtection()
    log("Инициализация защиты скорости...", "info")
    local success = safeCall(function()
        local maxSpeed = 16
        local lastPos = nil
        local lastTime = tick()
        RunService.Heartbeat:Connect(function()
            safeCall(function()
                local char = LocalPlayer.Character
                if not char then return end
                local humanoid = char:FindFirstChild("Humanoid")
                local root = char:FindFirstChild("HumanoidRootPart")
                if humanoid and root then
                    local time = tick()
                    local pos = root.Position
                    if lastPos then
                        local dist = (pos - lastPos).Magnitude
                        local delta = time - lastTime
                        local speed = dist / delta
                        if speed > maxSpeed * 1.5 and delta < 0.5 then
                            log("Высокая скорость: " .. math.floor(speed), "warn")
                        end
                    end
                    lastPos = pos
                    lastTime = time
                end
            end)
        end)
    end)
    log(success and "Защита скорости активна" or "Ошибка", success and "info" or "error")
    return success
end

local function setupAntiLogging()
    log("Инициализация защиты от логирования...", "info")
    local success = safeCall(function()
        local oldWarn = warn
        warn = newcclosure(function(...)
            local args = {...}
            local msg = table.concat(args, " ")
            if msg:lower():find("detected") or 
               msg:lower():find("exploit") or
               msg:lower():find("cheat") then
                return
            end
            return oldWarn(...)
        end)
        if game:GetService("LogService") then
            safeCall(function()
                local logService = game:GetService("LogService")
                logService.MessageOut:Connect(function(message, messageType)
                    if message:lower():find("kick") or 
                       message:lower():find("ban") or
                       message:lower():find("exploit") then
                        return false
                    end
                end)
            end)
        end
    end)
    log(success and "Защита от логирования активна" or "Ошибка", success and "info" or "error")
    return success
end

local function setupGUIProtection()
    log("Инициализация защиты GUI...", "info")
    local success = safeCall(function()
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
        safeCall(function()
            for _, gui in pairs(CoreGui:GetChildren()) do
                if gui.Name:find("Robanik") or gui.Name:find("Exploit") then
                    hideGui(gui)
                end
            end
            CoreGui.ChildAdded:Connect(function(gui)
                wait(0.1)
                if gui.Name:find("Robanik") or gui.Name:find("Exploit") then
                    hideGui(gui)
                end
            end)
        end)
    end)
    log(success and "Защита GUI активна" or "Ошибка", success and "info" or "error")
    return success
end

local function setupServerCheckProtection()
    log("Инициализация защиты от серверных проверок...", "info")
    local success = safeCall(function()
        for _, remote in pairs(game:GetDescendants()) do
            if remote:IsA("RemoteFunction") then
                local name = remote.Name:lower()
                if name:find("check") or name:find("verify") or 
                   name:find("validate") or name:find("confirm") then
                    safeCall(function()
                        local oldInvoke = remote.InvokeServer
                        remote.InvokeServer = newcclosure(function(self, ...)
                            log("Серверная проверка: " .. self.Name, "warn")
                            local result = oldInvoke(self, ...)
                            if type(result) == "boolean" then
                                return true
                            end
                            return result
                        end)
                    end)
                end
            end
        end
    end)
    log(success and "Защита от серверных проверок активна" or "Ошибка", success and "info" or "error")
    return success
end

local function setupFEProtection()
    log("Инициализация FE защиты...", "info")
    local success = safeCall(function()
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local originalCFrames = {}
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                originalCFrames[part] = part.CFrame
            end
        end
        RunService.Heartbeat:Connect(function()
            safeCall(function()
                local root = char:FindFirstChild("HumanoidRootPart")
                if not root then return end
                if originalCFrames[root] then
                    local dist = (root.Position - originalCFrames[root].Position).Magnitude
                    if dist > 50 then
                        log("Обнаружена телепортация", "warn")
                    end
                end
                originalCFrames[root] = root.CFrame
            end)
        end)
    end)
    log(success and "FE защита активна" or "Ошибка", success and "info" or "error")
    return success
end

function AntiCheat:Initialize()
    log("🛡️ ROBANIK ANTI-ANTICHEAT SYSTEM", "info")
    log("Версия: " .. self.Version, "info")
    local protections = {
        {name = "Метатаблицы", func = setupMetatableProtection},
        {name = "Анти-кик", func = setupAntiKick},
        {name = "Анти-детект скриптов", func = setupAntiScriptDetection},
        {name = "Remote защита", func = setupRemoteProtection},
        {name = "Окружение", func = setupEnvironmentProtection},
        {name = "Скорость", func = setupSpeedProtection},
        {name = "Анти-логирование", func = setupAntiLogging},
        {name = "GUI защита", func = setupGUIProtection},
        {name = "Серверные проверки", func = setupServerCheckProtection},
        {name = "FE защита", func = setupFEProtection}
    }
    local successCount = 0
    local failCount = 0
    for _, prot in ipairs(protections) do
        log("Загрузка: " .. prot.name, "info")
        local success = prot.func()
        if success then
            successCount = successCount + 1
        else
            failCount = failCount + 1
        end
        wait(0.1)
    end
    log(string.format("✅ Успешно: %d | ❌ Ошибок: %d", successCount, failCount), "info")
    log("🔒 Система защиты активна!", "info")
    return successCount, failCount
end

spawn(function()
    wait(1)
    AntiCheat:Initialize()
end)

LocalPlayer.CharacterAdded:Connect(function()
    wait(2)
    log("Переинициализация после респавна...", "info")
    setupMetatableProtection()
    setupAntiKick()
    setupRemoteProtection()
end)

return AntiCheat
