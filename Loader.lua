local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

local CORRECT_KEY = "ROBANIK2024"

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KeySystemGUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true
screenGui.Parent = player.PlayerGui

local blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Parent = game.Lighting

TweenService:Create(blur, TweenInfo.new(0.5), {Size = 15}):Play()

local overlay = Instance.new("Frame")
overlay.Size = UDim2.new(1, 0, 1, 0)
overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
overlay.BackgroundTransparency = 0.4
overlay.BorderSizePixel = 0
overlay.Parent = screenGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 0, 0, 0)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 20)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(100, 100, 255)
mainStroke.Thickness = 2
mainStroke.Transparency = 0.5
mainStroke.Parent = mainFrame

local glowEffect = Instance.new("ImageLabel")
glowEffect.Size = UDim2.new(1, 60, 1, 60)
glowEffect.Position = UDim2.new(0.5, 0, 0.5, 0)
glowEffect.AnchorPoint = Vector2.new(0.5, 0.5)
glowEffect.BackgroundTransparency = 1
glowEffect.Image = "rbxassetid://4996891970"
glowEffect.ImageColor3 = Color3.fromRGB(80, 80, 255)
glowEffect.ImageTransparency = 0.7
glowEffect.ScaleType = Enum.ScaleType.Slice
glowEffect.SliceCenter = Rect.new(128, 128, 128, 128)
glowEffect.ZIndex = 0
glowEffect.Parent = mainFrame

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 20))
}
gradient.Rotation = 45
gradient.Parent = mainFrame

local particlesFrame = Instance.new("Frame")
particlesFrame.Size = UDim2.new(1, 0, 1, 0)
particlesFrame.BackgroundTransparency = 1
particlesFrame.ClipsDescendants = true
particlesFrame.Parent = mainFrame

for i = 1, 15 do
    local particle = Instance.new("Frame")
    particle.Size = UDim2.new(0, math.random(2, 4), 0, math.random(2, 4))
    particle.Position = UDim2.new(math.random(0, 100) / 100, 0, math.random(0, 100) / 100, 0)
    particle.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
    particle.BackgroundTransparency = math.random(30, 70) / 100
    particle.BorderSizePixel = 0
    particle.Parent = particlesFrame
    
    local particleCorner = Instance.new("UICorner")
    particleCorner.CornerRadius = UDim.new(1, 0)
    particleCorner.Parent = particle
    
    spawn(function()
        while particle.Parent do
            local newPos = UDim2.new(math.random(0, 100) / 100, 0, math.random(0, 100) / 100, 0)
            local newTrans = math.random(30, 90) / 100
            TweenService:Create(particle, TweenInfo.new(math.random(3, 6), Enum.EasingStyle.Sine), {
                Position = newPos,
                BackgroundTransparency = newTrans
            }):Play()
            task.wait(math.random(3, 6))
        end
    end)
end

local logoFrame = Instance.new("Frame")
logoFrame.Size = UDim2.new(0, 100, 0, 100)
logoFrame.Position = UDim2.new(0.5, 0, 0, 50)
logoFrame.AnchorPoint = Vector2.new(0.5, 0)
logoFrame.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
logoFrame.BorderSizePixel = 0
logoFrame.Parent = mainFrame

local logoCorner = Instance.new("UICorner")
logoCorner.CornerRadius = UDim.new(0.5, 0)
logoCorner.Parent = logoFrame

local logoGradient = Instance.new("UIGradient")
logoGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 120, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 80, 200))
}
logoGradient.Rotation = 135
logoGradient.Parent = logoFrame

local logoStroke = Instance.new("UIStroke")
logoStroke.Color = Color3.fromRGB(150, 150, 255)
logoStroke.Thickness = 3
logoStroke.Parent = logoFrame

local logoIcon = Instance.new("TextLabel")
logoIcon.Size = UDim2.new(1, 0, 1, 0)
logoIcon.BackgroundTransparency = 1
logoIcon.Font = Enum.Font.GothamBold
logoIcon.Text = "🔐"
logoIcon.TextSize = 50
logoIcon.TextColor3 = Color3.new(1, 1, 1)
logoIcon.Parent = logoFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -40, 0, 40)
titleLabel.Position = UDim2.new(0, 20, 0, 170)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "KEY SYSTEM"
titleLabel.TextSize = 28
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Parent = mainFrame

local titleGradient = Instance.new("UIGradient")
titleGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 150, 255))
}
titleGradient.Parent = titleLabel

local subtitleLabel = Instance.new("TextLabel")
subtitleLabel.Size = UDim2.new(1, -40, 0, 20)
subtitleLabel.Position = UDim2.new(0, 20, 0, 215)
subtitleLabel.BackgroundTransparency = 1
subtitleLabel.Font = Enum.Font.Gotham
subtitleLabel.Text = "BY ROBANIK"
subtitleLabel.TextSize = 12
subtitleLabel.TextColor3 = Color3.fromRGB(150, 150, 200)
subtitleLabel.Parent = mainFrame

local inputFrame = Instance.new("Frame")
inputFrame.Size = UDim2.new(1, -60, 0, 55)
inputFrame.Position = UDim2.new(0, 30, 0, 260)
inputFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
inputFrame.BorderSizePixel = 0
inputFrame.Parent = mainFrame

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 12)
inputCorner.Parent = inputFrame

local inputStroke = Instance.new("UIStroke")
inputStroke.Color = Color3.fromRGB(60, 60, 80)
inputStroke.Thickness = 2
inputStroke.Parent = inputFrame

local inputBox = Instance.new("TextBox")
inputBox.Size = UDim2.new(1, -30, 1, -10)
inputBox.Position = UDim2.new(0, 15, 0, 5)
inputBox.BackgroundTransparency = 1
inputBox.Font = Enum.Font.GothamBold
inputBox.PlaceholderText = "Введите ключ..."
inputBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 120)
inputBox.Text = ""
inputBox.TextSize = 16
inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
inputBox.TextXAlignment = Enum.TextXAlignment.Left
inputBox.ClearTextOnFocus = false
inputBox.Parent = inputFrame

local getKeyButton = Instance.new("TextButton")
getKeyButton.Size = UDim2.new(1, -60, 0, 50)
getKeyButton.Position = UDim2.new(0, 30, 0, 335)
getKeyButton.BackgroundColor3 = Color3.fromRGB(255, 180, 50)
getKeyButton.BorderSizePixel = 0
getKeyButton.Font = Enum.Font.GothamBold
getKeyButton.Text = "🔑 ПОЛУЧИТЬ КЛЮЧ"
getKeyButton.TextSize = 16
getKeyButton.TextColor3 = Color3.new(1, 1, 1)
getKeyButton.AutoButtonColor = false
getKeyButton.Parent = mainFrame

local getKeyCorner = Instance.new("UICorner")
getKeyCorner.CornerRadius = UDim.new(0, 12)
getKeyCorner.Parent = getKeyButton

local getKeyGradient = Instance.new("UIGradient")
getKeyGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 200, 100)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 150, 50))
}
getKeyGradient.Rotation = 90
getKeyGradient.Parent = getKeyButton

local submitButton = Instance.new("TextButton")
submitButton.Size = UDim2.new(1, -60, 0, 50)
submitButton.Position = UDim2.new(0, 30, 0, 400)
submitButton.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
submitButton.BorderSizePixel = 0
submitButton.Font = Enum.Font.GothamBold
submitButton.Text = "✓ ОТПРАВИТЬ"
submitButton.TextSize = 16
submitButton.TextColor3 = Color3.new(1, 1, 1)
submitButton.AutoButtonColor = false
submitButton.Parent = mainFrame

local submitCorner = Instance.new("UICorner")
submitCorner.CornerRadius = UDim.new(0, 12)
submitCorner.Parent = submitButton

local submitGradient = Instance.new("UIGradient")
submitGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 220, 120)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 180, 80))
}
submitGradient.Rotation = 90
submitGradient.Parent = submitButton

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -40, 0, 25)
statusLabel.Position = UDim2.new(0, 20, 0, 465)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.Gotham
statusLabel.Text = ""
statusLabel.TextSize = 12
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.Parent = mainFrame

TweenService:Create(mainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 400, 0, 510)
}):Play()

spawn(function()
    while mainFrame.Parent do
        TweenService:Create(logoFrame, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            Rotation = 360
        }):Play()
        task.wait(2)
        logoFrame.Rotation = 0
    end
end)

spawn(function()
    while mainFrame.Parent do
        TweenService:Create(gradient, TweenInfo.new(3, Enum.EasingStyle.Linear), {
            Rotation = gradient.Rotation + 360
        }):Play()
        task.wait(3)
    end
end)

local function showNotification(text, color, isError)
    statusLabel.Text = text
    statusLabel.TextColor3 = color
    
    TweenService:Create(statusLabel, TweenInfo.new(0.3), {
        TextTransparency = 0
    }):Play()
    
    if isError then
        TweenService:Create(inputFrame, TweenInfo.new(0.1), {Position = UDim2.new(0, 25, 0, 260)}):Play()
        task.wait(0.1)
        TweenService:Create(inputFrame, TweenInfo.new(0.1), {Position = UDim2.new(0, 35, 0, 260)}):Play()
        task.wait(0.1)
        TweenService:Create(inputFrame, TweenInfo.new(0.1), {Position = UDim2.new(0, 30, 0, 260)}):Play()
    end
    
    task.wait(3)
    TweenService:Create(statusLabel, TweenInfo.new(0.5), {
        TextTransparency = 1
    }):Play()
end

getKeyButton.MouseEnter:Connect(function()
    TweenService:Create(getKeyButton, TweenInfo.new(0.2), {
        Size = UDim2.new(1, -50, 0, 55),
        BackgroundColor3 = Color3.fromRGB(255, 200, 80)
    }):Play()
end)

getKeyButton.MouseLeave:Connect(function()
    TweenService:Create(getKeyButton, TweenInfo.new(0.2), {
        Size = UDim2.new(1, -60, 0, 50),
        BackgroundColor3 = Color3.fromRGB(255, 180, 50)
    }):Play()
end)

submitButton.MouseEnter:Connect(function()
    TweenService:Create(submitButton, TweenInfo.new(0.2), {
        Size = UDim2.new(1, -50, 0, 55),
        BackgroundColor3 = Color3.fromRGB(120, 220, 120)
    }):Play()
end)

submitButton.MouseLeave:Connect(function()
    TweenService:Create(submitButton, TweenInfo.new(0.2), {
        Size = UDim2.new(1, -60, 0, 50),
        BackgroundColor3 = Color3.fromRGB(100, 200, 100)
    }):Play()
end)

inputBox.Focused:Connect(function()
    TweenService:Create(inputStroke, TweenInfo.new(0.3), {
        Color = Color3.fromRGB(100, 100, 255),
        Thickness = 3
    }):Play()
end)

inputBox.FocusLost:Connect(function()
    TweenService:Create(inputStroke, TweenInfo.new(0.3), {
        Color = Color3.fromRGB(60, 60, 80),
        Thickness = 2
    }):Play()
end)

getKeyButton.MouseButton1Click:Connect(function()
    TweenService:Create(getKeyButton, TweenInfo.new(0.1), {Size = UDim2.new(1, -70, 0, 45)}):Play()
    task.wait(0.1)
    TweenService:Create(getKeyButton, TweenInfo.new(0.1), {Size = UDim2.new(1, -60, 0, 50)}):Play()
    
    showNotification("Ключ скопирован: " .. CORRECT_KEY, Color3.fromRGB(100, 200, 255), false)
    setclipboard(CORRECT_KEY)
end)

submitButton.MouseButton1Click:Connect(function()
    TweenService:Create(submitButton, TweenInfo.new(0.1), {Size = UDim2.new(1, -70, 0, 45)}):Play()
    task.wait(0.1)
    TweenService:Create(submitButton, TweenInfo.new(0.1), {Size = UDim2.new(1, -60, 0, 50)}):Play()
    
    local inputKey = inputBox.Text
    
    if inputKey == "" then
        showNotification("❌ Введите ключ!", Color3.fromRGB(255, 100, 100), true)
        return
    end
    
    if inputKey == CORRECT_KEY then
        showNotification("✓ Ключ верный! Загрузка...", Color3.fromRGB(100, 255, 150), false)
        
        task.wait(1)
        
        TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            Rotation = 180
        }):Play()
        
        TweenService:Create(blur, TweenInfo.new(0.5), {Size = 0}):Play()
        
        task.wait(0.5)
        screenGui:Destroy()
        blur:Destroy()
        
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Robanik/Stl.brain.plat/refs/heads/main/Plt.hgtr.lua"))()
        
    else
        showNotification("❌ Неверный ключ!", Color3.fromRGB(255, 100, 100), true)
    end
end)
