--[[
    STARK INSTANT
    Solo Instant Interact (sin spam)
    Tema: Blanco y Negro + Glow Rojo
]]

local cloneref = cloneref or function(o) return o end
local function svc(name)
    local ok, s = pcall(function() return game:GetService(name) end)
    if not ok or not s then return nil end
    local ok2, r = pcall(cloneref, s)
    if ok2 and r then return r end
    return s
end

local Players          = svc("Players")
local RunService       = svc("RunService")
local UserInputService = svc("UserInputService")
local TweenService     = svc("TweenService")
local CoreGui          = svc("CoreGui")

local player = Players.LocalPlayer
if not player then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    player = Players.LocalPlayer
end
local playerGui = player:WaitForChild("PlayerGui")

local env = (typeof(getgenv) == "function" and getgenv()) or _G

if env.StarkInstantStop then pcall(env.StarkInstantStop) end

--------------------------------------------------------------------
-- CONFIG
--------------------------------------------------------------------
local instantKey = Enum.KeyCode.V
local waitingForKey = false
local instantActive = false
local descConn

-- Guardamos los valores originales para poder restaurarlos
local originalHold = {}

--------------------------------------------------------------------
-- INSTANT INTERACT (con restore)
--------------------------------------------------------------------
local function makeInstant(prompt)
    if not prompt:IsA("ProximityPrompt") then return end
    if originalHold[prompt] == nil then
        originalHold[prompt] = prompt.HoldDuration
    end
    pcall(function()
        prompt.HoldDuration = 0
    end)
end

local function restorePrompt(prompt)
    if not prompt:IsA("ProximityPrompt") then return end
    local original = originalHold[prompt]
    if original ~= nil then
        pcall(function()
            prompt.HoldDuration = original
        end)
        originalHold[prompt] = nil
    end
end

local function applyToAll()
    for _, obj in ipairs(workspace:GetDescendants()) do
        makeInstant(obj)
    end
end

local function restoreAll()
    for prompt, _ in pairs(originalHold) do
        if prompt and prompt.Parent then
            restorePrompt(prompt)
        end
    end
    originalHold = {}
end

local function setInstant(state)
    instantActive = state == true

    if instantActive then
        applyToAll()
        if not descConn then
            descConn = workspace.DescendantAdded:Connect(function(obj)
                if instantActive then
                    task.defer(makeInstant, obj)
                end
            end)
        end
    else
        if descConn then
            descConn:Disconnect()
            descConn = nil
        end
        restoreAll()   -- ← aquí se desactiva de verdad
    end
end

--------------------------------------------------------------------
-- GUI
--------------------------------------------------------------------
local UI_NAME = "StarkInstantGUI"

pcall(function()
    local old = playerGui:FindFirstChild(UI_NAME)
    if old then old:Destroy() end
    if CoreGui then
        local oldCore = CoreGui:FindFirstChild(UI_NAME)
        if oldCore then oldCore:Destroy() end
    end
end)

local GUI = Instance.new("ScreenGui")
GUI.Name = UI_NAME
GUI.ResetOnSpawn = false
GUI.IgnoreGuiInset = true
GUI.DisplayOrder = 999999
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GUI.Parent = playerGui

local Theme = {
    Bg       = Color3.fromRGB(12, 12, 12),
    Panel    = Color3.fromRGB(22, 22, 22),
    Row      = Color3.fromRGB(35, 35, 35),
    Accent   = Color3.fromRGB(255, 255, 255),
    Text     = Color3.fromRGB(255, 255, 255),
    Dim      = Color3.fromRGB(160, 160, 160),
    Stroke   = Color3.fromRGB(60, 60, 60),
    White    = Color3.fromRGB(255, 255, 255),
    Black    = Color3.fromRGB(0, 0, 0),
    Red      = Color3.fromRGB(220, 40, 40),
}

local function corner(o, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r)
    c.Parent = o
    return c
end

local function stroke(o, col, th, tr)
    local s = Instance.new("UIStroke")
    s.Color = col or Theme.Stroke
    s.Thickness = th or 1
    s.Transparency = tr or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = o
    return s
end

local function tw(o, props, t)
    TweenService:Create(o, TweenInfo.new(t or 0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props):Play()
end

--------------------------------------------------------------------
-- LOGO
--------------------------------------------------------------------
local LOGO_ID = "rbxassetid://78843816849049"

local LogoContainer = Instance.new("Frame")
LogoContainer.Name = "LogoContainer"
LogoContainer.Size = UDim2.fromOffset(56, 56)
LogoContainer.Position = UDim2.new(0, 18, 0.5, -28)
LogoContainer.BackgroundTransparency = 1
LogoContainer.Parent = GUI

local logoGlow = Instance.new("Frame")
logoGlow.Size = UDim2.fromScale(1.45, 1.45)
logoGlow.Position = UDim2.fromScale(0.5, 0.5)
logoGlow.AnchorPoint = Vector2.new(0.5, 0.5)
logoGlow.BackgroundColor3 = Theme.Red
logoGlow.BackgroundTransparency = 0.65
logoGlow.BorderSizePixel = 0
logoGlow.ZIndex = 0
logoGlow.Parent = LogoContainer
corner(logoGlow, 99)

local LogoBtn = Instance.new("ImageButton")
LogoBtn.Size = UDim2.fromScale(1, 1)
LogoBtn.Position = UDim2.fromScale(0.5, 0.5)
LogoBtn.AnchorPoint = Vector2.new(0.5, 0.5)
LogoBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
LogoBtn.BorderSizePixel = 0
LogoBtn.AutoButtonColor = false
LogoBtn.Image = LOGO_ID
LogoBtn.ScaleType = Enum.ScaleType.Crop
LogoBtn.ZIndex = 2
LogoBtn.Parent = LogoContainer
corner(LogoBtn, 99)
stroke(LogoBtn, Theme.Red, 1.5, 0.25)

--------------------------------------------------------------------
-- MAIN WINDOW
--------------------------------------------------------------------
local Window = Instance.new("Frame")
Window.Name = "Main"
Window.Size = UDim2.fromOffset(290, 230)
Window.Position = UDim2.new(0, 90, 0.5, -115)
Window.BackgroundColor3 = Theme.Bg
Window.BorderSizePixel = 0
Window.Active = true
Window.Visible = false
Window.Parent = GUI
corner(Window, 16)
stroke(Window, Theme.White, 1.4, 0.25)

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundTransparency = 1
Header.Parent = Window

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, -90, 1, 0)
Title.Position = UDim2.fromOffset(18, 0)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 17
Title.TextColor3 = Theme.Text
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Text = "STARK INSTANT"
Title.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.fromOffset(28, 28)
CloseBtn.Position = UDim2.new(1, -70, 0.5, -14)
CloseBtn.BackgroundColor3 = Theme.Row
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "–"
CloseBtn.TextSize = 18
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextColor3 = Theme.Text
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = Header
corner(CloseBtn, 8)

local DestroyBtn = Instance.new("TextButton")
DestroyBtn.Size = UDim2.fromOffset(28, 28)
DestroyBtn.Position = UDim2.new(1, -36, 0.5, -14)
DestroyBtn.BackgroundColor3 = Theme.Black
DestroyBtn.BorderSizePixel = 0
DestroyBtn.Text = "×"
DestroyBtn.TextSize = 18
DestroyBtn.Font = Enum.Font.GothamBold
DestroyBtn.TextColor3 = Theme.White
DestroyBtn.AutoButtonColor = false
DestroyBtn.Parent = Header
corner(DestroyBtn, 8)
stroke(DestroyBtn, Theme.White, 1.2, 0.3)

local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(1, -36, 0, 1)
Divider.Position = UDim2.fromOffset(18, 50)
Divider.BackgroundColor3 = Theme.White
Divider.BackgroundTransparency = 0.6
Divider.BorderSizePixel = 0
Divider.Parent = Window

local Body = Instance.new("Frame")
Body.Size = UDim2.new(1, -36, 1, -74)
Body.Position = UDim2.fromOffset(18, 62)
Body.BackgroundTransparency = 1
Body.Parent = Window

local function makeToggle(y, titleText, noteText, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 54)
    row.Position = UDim2.fromOffset(0, y)
    row.BackgroundColor3 = Theme.Panel
    row.BorderSizePixel = 0
    row.Parent = Body
    corner(row, 12)
    local rowStroke = stroke(row, Theme.Stroke, 1)

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, -90, 0, 22)
    title.Position = UDim2.fromOffset(14, 8)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 13
    title.TextColor3 = Theme.Text
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = titleText
    title.Parent = row

    local note = Instance.new("TextLabel")
    note.BackgroundTransparency = 1
    note.Size = UDim2.new(1, -90, 0, 16)
    note.Position = UDim2.fromOffset(14, 28)
    note.Font = Enum.Font.Gotham
    note.TextSize = 11
    note.TextColor3 = Theme.Dim
    note.TextXAlignment = Enum.TextXAlignment.Left
    note.Text = noteText
    note.Parent = row

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromOffset(64, 32)
    btn.Position = UDim2.new(1, -76, 0.5, -16)
    btn.BackgroundColor3 = Theme.Row
    btn.BorderSizePixel = 0
    btn.Text = "OFF"
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBlack
    btn.TextColor3 = Theme.Text
    btn.AutoButtonColor = false
    btn.Parent = row
    corner(btn, 10)

    local state = false

    local function setVisual(on)
        state = on
        if on then
            tw(btn, {BackgroundColor3 = Theme.White})
            tw(rowStroke, {Color = Theme.White})
            btn.Text = "ON"
            btn.TextColor3 = Theme.Black
        else
            tw(btn, {BackgroundColor3 = Theme.Row})
            tw(rowStroke, {Color = Theme.Stroke})
            btn.Text = "OFF"
            btn.TextColor3 = Theme.Text
        end
    end

    btn.MouseButton1Click:Connect(function()
        setVisual(not state)
        callback(state)
    end)

    _G.StarkUpdateInstantVisual = setVisual
    return setVisual
end

makeToggle(0, "INSTANT INTERACT", "HoldDuration = 0 (sin spam)", setInstant)

--------------------------------------------------------------------
-- KEYBIND ROW
--------------------------------------------------------------------
local KeyRow = Instance.new("Frame")
KeyRow.Size = UDim2.new(1, 0, 0, 54)
KeyRow.Position = UDim2.fromOffset(0, 64)
KeyRow.BackgroundColor3 = Theme.Panel
KeyRow.BorderSizePixel = 0
KeyRow.Parent = Body
corner(KeyRow, 12)
stroke(KeyRow, Theme.Stroke, 1)

local KeyTitle = Instance.new("TextLabel")
KeyTitle.BackgroundTransparency = 1
KeyTitle.Size = UDim2.new(1, -90, 0, 22)
KeyTitle.Position = UDim2.fromOffset(14, 8)
KeyTitle.Font = Enum.Font.GothamBold
KeyTitle.TextSize = 13
KeyTitle.TextColor3 = Theme.Text
KeyTitle.TextXAlignment = Enum.TextXAlignment.Left
KeyTitle.Text = "INSTANT KEY"
KeyTitle.Parent = KeyRow

local KeyNote = Instance.new("TextLabel")
KeyNote.BackgroundTransparency = 1
KeyNote.Size = UDim2.new(1, -90, 0, 16)
KeyNote.Position = UDim2.fromOffset(14, 28)
KeyNote.Font = Enum.Font.Gotham
KeyNote.TextSize = 11
KeyNote.TextColor3 = Theme.Dim
KeyNote.TextXAlignment = Enum.TextXAlignment.Left
KeyNote.Text = "Pica para cambiar tecla"
KeyNote.Parent = KeyRow

local KeyBtn = Instance.new("TextButton")
KeyBtn.Size = UDim2.fromOffset(64, 32)
KeyBtn.Position = UDim2.new(1, -76, 0.5, -16)
KeyBtn.BackgroundColor3 = Theme.Row
KeyBtn.BorderSizePixel = 0
KeyBtn.Text = instantKey.Name
KeyBtn.TextSize = 12
KeyBtn.Font = Enum.Font.GothamBlack
KeyBtn.TextColor3 = Theme.Text
KeyBtn.AutoButtonColor = false
KeyBtn.Parent = KeyRow
corner(KeyBtn, 10)

KeyBtn.MouseButton1Click:Connect(function()
    if waitingForKey then return end
    waitingForKey = true
    KeyBtn.Text = "..."
    KeyBtn.TextColor3 = Theme.White
end)

--------------------------------------------------------------------
-- FOOTER + CONFIRM
--------------------------------------------------------------------
local Footer = Instance.new("TextLabel")
Footer.BackgroundTransparency = 1
Footer.Size = UDim2.new(1, 0, 0, 20)
Footer.Position = UDim2.new(0, 0, 1, -24)
Footer.Font = Enum.Font.Gotham
Footer.TextSize = 11
Footer.TextColor3 = Theme.Dim
Footer.Text = "STARK INSTANT"
Footer.Parent = Window

local ConfirmFrame = Instance.new("Frame")
ConfirmFrame.Size = UDim2.fromOffset(260, 140)
ConfirmFrame.Position = UDim2.new(0.5, -130, 0.5, -70)
ConfirmFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
ConfirmFrame.BorderSizePixel = 0
ConfirmFrame.Visible = false
ConfirmFrame.ZIndex = 50
ConfirmFrame.Parent = GUI
corner(ConfirmFrame, 14)
stroke(ConfirmFrame, Theme.White, 1.5, 0.25)

local ConfirmTitle = Instance.new("TextLabel")
ConfirmTitle.BackgroundTransparency = 1
ConfirmTitle.Size = UDim2.new(1, -20, 0, 50)
ConfirmTitle.Position = UDim2.fromOffset(10, 12)
ConfirmTitle.Font = Enum.Font.GothamBold
ConfirmTitle.TextSize = 14
ConfirmTitle.TextColor3 = Theme.Text
ConfirmTitle.TextWrapped = true
ConfirmTitle.Text = "¿Estás seguro que quieres\ncerrar Stark Instant?"
ConfirmTitle.ZIndex = 51
ConfirmTitle.Parent = ConfirmFrame

local YesBtn = Instance.new("TextButton")
YesBtn.Size = UDim2.fromOffset(100, 36)
YesBtn.Position = UDim2.new(0.5, -110, 1, -52)
YesBtn.BackgroundColor3 = Theme.White
YesBtn.BorderSizePixel = 0
YesBtn.Text = "Sí"
YesBtn.TextSize = 14
YesBtn.Font = Enum.Font.GothamBlack
YesBtn.TextColor3 = Theme.Black
YesBtn.AutoButtonColor = false
YesBtn.ZIndex = 51
YesBtn.Parent = ConfirmFrame
corner(YesBtn, 10)

local NoBtn = Instance.new("TextButton")
NoBtn.Size = UDim2.fromOffset(100, 36)
NoBtn.Position = UDim2.new(0.5, 10, 1, -52)
NoBtn.BackgroundColor3 = Theme.Row
NoBtn.BorderSizePixel = 0
NoBtn.Text = "No"
NoBtn.TextSize = 14
NoBtn.Font = Enum.Font.GothamBlack
NoBtn.TextColor3 = Theme.Text
NoBtn.AutoButtonColor = false
NoBtn.ZIndex = 51
NoBtn.Parent = ConfirmFrame
corner(NoBtn, 10)

--------------------------------------------------------------------
-- Toggle menú
--------------------------------------------------------------------
local menuOpen = false

local function setMenuOpen(open)
    menuOpen = open
    if open then
        Window.Visible = true
        Window.Size = UDim2.fromOffset(290, 40)
        tw(Window, {Size = UDim2.fromOffset(290, 230)}, 0.2)
    else
        tw(Window, {Size = UDim2.fromOffset(290, 40)}, 0.15)
        task.delay(0.16, function()
            if not menuOpen then Window.Visible = false end
        end)
    end
end

LogoBtn.MouseButton1Click:Connect(function()
    setMenuOpen(not menuOpen)
end)

CloseBtn.MouseButton1Click:Connect(function()
    setMenuOpen(false)
end)

--------------------------------------------------------------------
-- KEYBIND LOGIC
--------------------------------------------------------------------
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end

    if waitingForKey and input.UserInputType == Enum.UserInputType.Keyboard then
        instantKey = input.KeyCode
        KeyBtn.Text = instantKey.Name
        KeyBtn.TextColor3 = Theme.Text
        waitingForKey = false
        return
    end

    if input.KeyCode == instantKey and not waitingForKey then
        local newState = not instantActive
        setInstant(newState)
        if _G.StarkUpdateInstantVisual then
            _G.StarkUpdateInstantVisual(newState)
        end
    end

    if input.KeyCode == Enum.KeyCode.RightControl then
        GUI.Enabled = not GUI.Enabled
    end
end)

--------------------------------------------------------------------
-- Drag
--------------------------------------------------------------------
do
    local dragging, dragStart, startPos = false, nil, nil
    LogoBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = LogoContainer.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            LogoContainer.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

do
    local dragging, dragStart, startPos = false, nil, nil
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Window.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

--------------------------------------------------------------------
-- Stop
--------------------------------------------------------------------
local function stopEverything()
    setInstant(false)
    if GUI then pcall(function() GUI:Destroy() end) end
end

env.StarkInstantStop = stopEverything

DestroyBtn.MouseButton1Click:Connect(function()
    ConfirmFrame.Visible = true
end)

YesBtn.MouseButton1Click:Connect(function()
    stopEverything()
end)

NoBtn.MouseButton1Click:Connect(function()
    ConfirmFrame.Visible = false
end)

print("[STARK INSTANT] loaded")
