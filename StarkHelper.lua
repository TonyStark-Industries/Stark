--[[
    STARK HELPER
    Auto Buy + Anchor + Anti Ragdoll
    Todas con tecla personalizable
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
if env.StarkHelperStop then pcall(env.StarkHelperStop) end

--------------------------------------------------------------------
-- KEYBINDS
--------------------------------------------------------------------
local keys = {
    AutoBuy     = Enum.KeyCode.V,
    Anchor      = Enum.KeyCode.B,
    AntiRagdoll = Enum.KeyCode.N,
}

local waitingFor = nil   -- "AutoBuy" / "Anchor" / "AntiRagdoll" / nil

--------------------------------------------------------------------
-- HELPER LOGIC
--------------------------------------------------------------------
local helperAutoBuyActive = false
local helperAnchored = false
local helperAntiRagdollActive = false
local helperAutoBuyElapsed = 0
local helperAntiRagdollCooldown = 0
local helperAntiRagdollConn

local function triggerWorkspacePrompts()
    for _, prompt in ipairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            pcall(function()
                prompt.HoldDuration = 0
                prompt:InputHoldBegin()
                prompt:InputHoldEnd()
            end)
        end
    end
end

local helperAutoBuyConn = RunService.Stepped:Connect(function(_, deltaTime)
    if not helperAutoBuyActive then return end
    helperAutoBuyElapsed += tonumber(deltaTime) or 0
    if helperAutoBuyElapsed < 0.12 then return end
    helperAutoBuyElapsed = 0
    triggerWorkspacePrompts()
end)

local function setCharacterAnchored(state, character)
    local char = character or player.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            pcall(function() part.Anchored = state end)
        end
    end
end

local helperCharacterConn = player.CharacterAdded:Connect(function(character)
    if helperAnchored then
        task.defer(function()
            character:WaitForChild("HumanoidRootPart", 5)
            setCharacterAnchored(true, character)
        end)
    end
end)

local function forceAntiRagdollReset()
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root or humanoid.Health <= 0 then return end

    pcall(function()
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        root.Velocity = Vector3.zero
        root.RotVelocity = Vector3.zero
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        for _, object in ipairs(character:GetDescendants()) do
            if object:IsA("Motor6D") then object.Enabled = true end
            if object:IsA("Constraint") then object.Enabled = true end
        end
        if workspace.CurrentCamera then workspace.CurrentCamera.CameraSubject = humanoid end
        humanoid.AutoRotate = true
        humanoid.PlatformStand = false
        humanoid.Sit = false
    end)

    pcall(function()
        local playerModule = player:FindFirstChild("PlayerScripts")
            and player.PlayerScripts:FindFirstChild("PlayerModule")
        local controlModule = playerModule and playerModule:FindFirstChild("ControlModule")
        if controlModule then
            local controls = require(controlModule)
            if controls and controls.Enable then controls:Enable() end
        end
    end)
end

local function setHelperAutoBuy(state)
    helperAutoBuyActive = state == true
    helperAutoBuyElapsed = 0
    if helperAutoBuyActive then task.spawn(triggerWorkspacePrompts) end
end

local function setHelperAnchor(state)
    helperAnchored = state == true
    setCharacterAnchored(helperAnchored)
end

local function setHelperAntiRagdoll(state)
    helperAntiRagdollActive = state == true
    if not helperAntiRagdollActive then
        if helperAntiRagdollConn then helperAntiRagdollConn:Disconnect() end
        helperAntiRagdollConn = nil
        return
    end
    if helperAntiRagdollConn then return end
    helperAntiRagdollConn = RunService.Heartbeat:Connect(function()
        if not helperAntiRagdollActive then return end
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then return end
        local stateNow = humanoid:GetState()
        local ragdolled = stateNow == Enum.HumanoidStateType.Physics
            or stateNow == Enum.HumanoidStateType.Ragdoll
            or stateNow == Enum.HumanoidStateType.FallingDown
        if ragdolled and tick() - helperAntiRagdollCooldown > 0.15 then
            helperAntiRagdollCooldown = tick()
            forceAntiRagdollReset()
        end
    end)
end

--------------------------------------------------------------------
-- GUI
--------------------------------------------------------------------
local UI_NAME = "StarkHelperGUI"

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
    Bg       = Color3.fromRGB(10, 12, 18),
    Panel    = Color3.fromRGB(16, 20, 28),
    Row      = Color3.fromRGB(24, 30, 40),
    Accent   = Color3.fromRGB(0, 210, 255),
    Text     = Color3.fromRGB(240, 245, 255),
    Dim      = Color3.fromRGB(130, 145, 165),
    Stroke   = Color3.fromRGB(40, 55, 75),
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
local ARC_REACTOR_ID = "rbxassetid://78843816849049"

local LogoContainer = Instance.new("Frame")
LogoContainer.Name = "LogoContainer"
LogoContainer.Size = UDim2.fromOffset(74, 74)
LogoContainer.Position = UDim2.new(0, 18, 0.5, -37)
LogoContainer.BackgroundTransparency = 1
LogoContainer.Parent = GUI

local logoGlow = Instance.new("Frame")
logoGlow.Size = UDim2.fromScale(1.55, 1.55)
logoGlow.Position = UDim2.fromScale(0.5, 0.5)
logoGlow.AnchorPoint = Vector2.new(0.5, 0.5)
logoGlow.BackgroundColor3 = Color3.fromRGB(0, 190, 255)
logoGlow.BackgroundTransparency = 0.72
logoGlow.BorderSizePixel = 0
logoGlow.ZIndex = 0
logoGlow.Parent = LogoContainer
corner(logoGlow, 99)

local ring = Instance.new("Frame")
ring.Size = UDim2.fromScale(1.12, 1.12)
ring.Position = UDim2.fromScale(0.5, 0.5)
ring.AnchorPoint = Vector2.new(0.5, 0.5)
ring.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
ring.BackgroundTransparency = 0.35
ring.BorderSizePixel = 0
ring.ZIndex = 1
ring.Parent = LogoContainer
corner(ring, 99)
stroke(ring, Color3.fromRGB(0, 220, 255), 2.5, 0.15)

local LogoBtn = Instance.new("ImageButton")
LogoBtn.Size = UDim2.fromScale(1, 1)
LogoBtn.Position = UDim2.fromScale(0.5, 0.5)
LogoBtn.AnchorPoint = Vector2.new(0.5, 0.5)
LogoBtn.BackgroundColor3 = Color3.fromRGB(5, 10, 18)
LogoBtn.BorderSizePixel = 0
LogoBtn.AutoButtonColor = false
LogoBtn.Image = ARC_REACTOR_ID
LogoBtn.ScaleType = Enum.ScaleType.Crop
LogoBtn.ZIndex = 2
LogoBtn.Parent = LogoContainer
corner(LogoBtn, 99)
stroke(LogoBtn, Color3.fromRGB(0, 210, 255), 1.8, 0.2)

task.spawn(function()
    while LogoContainer and LogoContainer.Parent do
        tw(logoGlow, {Size = UDim2.fromScale(1.75, 1.75), BackgroundTransparency = 0.55}, 1.1)
        tw(ring, {BackgroundTransparency = 0.15, Size = UDim2.fromScale(1.18, 1.18)}, 1.1)
        task.wait(1.1)
        tw(logoGlow, {Size = UDim2.fromScale(1.45, 1.45), BackgroundTransparency = 0.78}, 1.1)
        tw(ring, {BackgroundTransparency = 0.4, Size = UDim2.fromScale(1.1, 1.1)}, 1.1)
        task.wait(1.1)
    end
end)

--------------------------------------------------------------------
-- MAIN WINDOW
--------------------------------------------------------------------
local Window = Instance.new("Frame")
Window.Name = "Main"
Window.Size = UDim2.fromOffset(290, 420)
Window.Position = UDim2.new(0, 110, 0.5, -210)
Window.BackgroundColor3 = Theme.Bg
Window.BorderSizePixel = 0
Window.Active = true
Window.Visible = false
Window.Parent = GUI
corner(Window, 16)
stroke(Window, Theme.Accent, 1.4, 0.15)

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
Title.Text = "STARK HELPER"
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
DestroyBtn.BackgroundColor3 = Color3.fromRGB(8, 10, 14)
DestroyBtn.BorderSizePixel = 0
DestroyBtn.Text = "×"
DestroyBtn.TextSize = 18
DestroyBtn.Font = Enum.Font.GothamBold
DestroyBtn.TextColor3 = Theme.Accent
DestroyBtn.AutoButtonColor = false
DestroyBtn.Parent = Header
corner(DestroyBtn, 8)
stroke(DestroyBtn, Theme.Accent, 1.2, 0.3)

local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(1, -36, 0, 1)
Divider.Position = UDim2.fromOffset(18, 50)
Divider.BackgroundColor3 = Theme.Accent
Divider.BackgroundTransparency = 0.55
Divider.BorderSizePixel = 0
Divider.Parent = Window

local Body = Instance.new("Frame")
Body.Size = UDim2.new(1, -36, 1, -74)
Body.Position = UDim2.fromOffset(18, 62)
Body.BackgroundTransparency = 1
Body.Parent = Window

-- Visual updaters
local updateVisuals = {}

local function makeToggle(y, titleText, noteText, callback, id)
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
            tw(btn, {BackgroundColor3 = Theme.Accent})
            tw(rowStroke, {Color = Theme.Accent})
            btn.Text = "ON"
            btn.TextColor3 = Color3.fromRGB(10, 15, 25)
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

    updateVisuals[id] = setVisual
    return setVisual
end

makeToggle(0,   "AUTO BUY",     "Activa prompts cercanos",     setHelperAutoBuy,     "AutoBuy")
makeToggle(64,  "ANCHOR",       "Ancla tu personaje",          setHelperAnchor,      "Anchor")
makeToggle(128, "ANTI RAGDOLL", "Te levanta automáticamente",  setHelperAntiRagdoll, "AntiRagdoll")

--------------------------------------------------------------------
-- KEYBIND ROWS
--------------------------------------------------------------------
local keyButtons = {}

local function makeKeyRow(y, label, id)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 40)
    row.Position = UDim2.fromOffset(0, y)
    row.BackgroundColor3 = Theme.Panel
    row.BorderSizePixel = 0
    row.Parent = Body
    corner(row, 10)
    stroke(row, Theme.Stroke, 1)

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, -80, 1, 0)
    title.Position = UDim2.fromOffset(14, 0)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 12
    title.TextColor3 = Theme.Text
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = label
    title.Parent = row

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromOffset(60, 28)
    btn.Position = UDim2.new(1, -70, 0.5, -14)
    btn.BackgroundColor3 = Theme.Row
    btn.BorderSizePixel = 0
    btn.Text = keys[id].Name
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBlack
    btn.TextColor3 = Theme.Text
    btn.AutoButtonColor = false
    btn.Parent = row
    corner(btn, 8)

    btn.MouseButton1Click:Connect(function()
        if waitingFor then return end
        waitingFor = id
        btn.Text = "..."
        btn.TextColor3 = Theme.Accent
    end)

    keyButtons[id] = btn
end

makeKeyRow(192, "AUTO BUY KEY",     "AutoBuy")
makeKeyRow(238, "ANCHOR KEY",       "Anchor")
makeKeyRow(284, "ANTI RAGDOLL KEY", "AntiRagdoll")

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
Footer.Text = "STARK HELPER"
Footer.Parent = Window

local ConfirmFrame = Instance.new("Frame")
ConfirmFrame.Size = UDim2.fromOffset(260, 140)
ConfirmFrame.Position = UDim2.new(0.5, -130, 0.5, -70)
ConfirmFrame.BackgroundColor3 = Color3.fromRGB(12, 14, 20)
ConfirmFrame.BorderSizePixel = 0
ConfirmFrame.Visible = false
ConfirmFrame.ZIndex = 50
ConfirmFrame.Parent = GUI
corner(ConfirmFrame, 14)
stroke(ConfirmFrame, Theme.Accent, 1.5, 0.2)

local ConfirmTitle = Instance.new("TextLabel")
ConfirmTitle.BackgroundTransparency = 1
ConfirmTitle.Size = UDim2.new(1, -20, 0, 50)
ConfirmTitle.Position = UDim2.fromOffset(10, 12)
ConfirmTitle.Font = Enum.Font.GothamBold
ConfirmTitle.TextSize = 14
ConfirmTitle.TextColor3 = Theme.Text
ConfirmTitle.TextWrapped = true
ConfirmTitle.Text = "¿Estás seguro que quieres\ncerrar Stark Helper?"
ConfirmTitle.ZIndex = 51
ConfirmTitle.Parent = ConfirmFrame

local YesBtn = Instance.new("TextButton")
YesBtn.Size = UDim2.fromOffset(100, 36)
YesBtn.Position = UDim2.new(0.5, -110, 1, -52)
YesBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 220)
YesBtn.BorderSizePixel = 0
YesBtn.Text = "Sí"
YesBtn.TextSize = 14
YesBtn.Font = Enum.Font.GothamBlack
YesBtn.TextColor3 = Color3.fromRGB(10, 15, 25)
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
        tw(Window, {Size = UDim2.fromOffset(290, 420)}, 0.2)
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

    -- Cambiar tecla
    if waitingFor and input.UserInputType == Enum.UserInputType.Keyboard then
        keys[waitingFor] = input.KeyCode
        if keyButtons[waitingFor] then
            keyButtons[waitingFor].Text = input.KeyCode.Name
            keyButtons[waitingFor].TextColor3 = Theme.Text
        end
        waitingFor = nil
        return
    end

    if waitingFor then return end

    -- Toggle por tecla
    if input.KeyCode == keys.AutoBuy then
        local newState = not helperAutoBuyActive
        setHelperAutoBuy(newState)
        if updateVisuals.AutoBuy then updateVisuals.AutoBuy(newState) end
    elseif input.KeyCode == keys.Anchor then
        local newState = not helperAnchored
        setHelperAnchor(newState)
        if updateVisuals.Anchor then updateVisuals.Anchor(newState) end
    elseif input.KeyCode == keys.AntiRagdoll then
        local newState = not helperAntiRagdollActive
        setHelperAntiRagdoll(newState)
        if updateVisuals.AntiRagdoll then updateVisuals.AntiRagdoll(newState) end
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
    helperAutoBuyActive = false
    helperAntiRagdollActive = false
    if helperAutoBuyConn then pcall(function() helperAutoBuyConn:Disconnect() end) end
    if helperCharacterConn then pcall(function() helperCharacterConn:Disconnect() end) end
    if helperAntiRagdollConn then pcall(function() helperAntiRagdollConn:Disconnect() end) end
    if helperAnchored then pcall(function() setCharacterAnchored(false) end) end
    helperAnchored = false
    if GUI then pcall(function() GUI:Destroy() end) end
end

env.StarkHelperStop = stopEverything

DestroyBtn.MouseButton1Click:Connect(function()
    ConfirmFrame.Visible = true
end)

YesBtn.MouseButton1Click:Connect(function()
    stopEverything()
end)

NoBtn.MouseButton1Click:Connect(function()
    ConfirmFrame.Visible = false
end)

print("[STARK HELPER] loaded - All keybinds")
