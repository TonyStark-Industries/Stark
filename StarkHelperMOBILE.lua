--[[
    STARK HELPER — MOBILE
    Auto Buy + Anchor + Anti Ragdoll + Optimizer + Block Events
    + FPS / Ping real
]]

local cloneref = cloneref or function(o) return o end
local function svc(name)
	local ok, s = pcall(function() return game:GetService(name) end)
	if not ok or not s then return nil end
	local ok2, r = pcall(cloneref, s)
	if ok2 and r then return r end
	return s
end

local Players = svc("Players")
local RunService = svc("RunService")
local UserInputService = svc("UserInputService")
local TweenService = svc("TweenService")
local CoreGui = svc("CoreGui")
local Lighting = svc("Lighting")
local Stats = svc("Stats")
local ReplicatedStorage = svc("ReplicatedStorage")

local player = Players.LocalPlayer
if not player then
	Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
	player = Players.LocalPlayer
end
local playerGui = player:WaitForChild("PlayerGui")

local env = (typeof(getgenv) == "function" and getgenv()) or _G
if env.StarkHelperStop then
	pcall(env.StarkHelperStop)
end

--------------------------------------------------------------------
-- STATE
--------------------------------------------------------------------
local helperAutoBuyActive = false
local helperAnchored = false
local helperAntiRagdollActive = false
local helperOptimizerActive = false
local helperBlockEventsActive = false
local helperAutoBuyElapsed = 0
local helperAntiRagdollCooldown = 0
local helperAntiRagdollConn

--------------------------------------------------------------------
-- AUTO BUY
--------------------------------------------------------------------
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

local function setHelperAutoBuy(state)
	helperAutoBuyActive = state == true
	helperAutoBuyElapsed = 0
	if helperAutoBuyActive then
		task.spawn(triggerWorkspacePrompts)
	end
end

--------------------------------------------------------------------
-- ANCHOR
--------------------------------------------------------------------
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

local function setHelperAnchor(state)
	helperAnchored = state == true
	setCharacterAnchored(helperAnchored)
end

--------------------------------------------------------------------
-- ANTI RAGDOLL
--------------------------------------------------------------------
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
		if workspace.CurrentCamera then
			workspace.CurrentCamera.CameraSubject = humanoid
		end
		humanoid.AutoRotate = true
		humanoid.PlatformStand = false
		humanoid.Sit = false
	end)

	pcall(function()
		local playerModule = player:FindFirstChild("PlayerScripts") and player.PlayerScripts:FindFirstChild("PlayerModule")
		local controlModule = playerModule and playerModule:FindFirstChild("ControlModule")
		if controlModule then
			local controls = require(controlModule)
			if controls and controls.Enable then
				controls:Enable()
			end
		end
	end)
end

local function setHelperAntiRagdoll(state)
	helperAntiRagdollActive = state == true
	if not helperAntiRagdollActive then
		if helperAntiRagdollConn then
			helperAntiRagdollConn:Disconnect()
		end
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
-- OPTIMIZER (suave)
--------------------------------------------------------------------
local function applyOptimizer(enabled)
	local Terrain = workspace:FindFirstChildOfClass("Terrain")
	if enabled then
		pcall(function()
			settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
		end)
		pcall(function()
			Lighting.GlobalShadows = false
			Lighting.FogEnd = 9e9
			Lighting.Brightness = 1
		end)
		pcall(function()
			for _, effect in ipairs(Lighting:GetChildren()) do
				if effect:IsA("BloomEffect")
				or effect:IsA("BlurEffect")
				or effect:IsA("SunRaysEffect")
				or effect:IsA("DepthOfFieldEffect") then
					pcall(function() effect.Enabled = false end)
				end
			end
		end)
		if Terrain then
			pcall(function()
				Terrain.WaterWaveSize = 0
				Terrain.WaterWaveSpeed = 0
				Terrain.WaterReflectance = 0
			end)
		end
	else
		pcall(function()
			settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
		end)
		pcall(function()
			Lighting.GlobalShadows = true
			Lighting.Brightness = 2
		end)
	end
end

local function setHelperOptimizer(state)
	helperOptimizerActive = state == true
	applyOptimizer(helperOptimizerActive)
end

--------------------------------------------------------------------
-- BLOCK EVENTS (estilo Traced, simplificado)
--------------------------------------------------------------------
local blockState = {
	ready = false,
	blocked = false,
	origGetActive = nil,
	EventController = nil,
}

local function resolveEventController()
	local controllers = ReplicatedStorage and ReplicatedStorage:FindFirstChild("Controllers")
	if not controllers then return nil end
	local mod = controllers:FindFirstChild("EventController", true)
	if not (mod and mod:IsA("ModuleScript")) then return nil end
	local ok, result = pcall(require, mod)
	if ok and type(result) == "table" then
		return result
	end
	return nil
end

local function setHelperBlockEvents(state)
	helperBlockEventsActive = state == true

	if not blockState.EventController then
		blockState.EventController = resolveEventController()
	end

	local EC = blockState.EventController
	if not EC or type(EC.GetActiveEvents) ~= "function" then
		blockState.ready = false
		return
	end

	blockState.ready = true

	if not blockState.origGetActive then
		blockState.origGetActive = EC.GetActiveEvents
	end

	blockState.blocked = helperBlockEventsActive

	EC.GetActiveEvents = function(self, ...)
		if blockState.blocked then
			return {} -- no active events
		end
		local ok, result = pcall(blockState.origGetActive, self, ...)
		if ok and type(result) == "table" then
			return result
		end
		return {}
	end

	-- limpiar efectos activos si se puede
	if helperBlockEventsActive then
		pcall(function()
			local EffectController
			local controllers = ReplicatedStorage:FindFirstChild("Controllers")
			local mod = controllers and controllers:FindFirstChild("EffectController", true)
			if mod then
				local ok, res = pcall(require, mod)
				if ok then EffectController = res end
			end
			if EffectController and type(EffectController.ActiveEffects) == "table" then
				for k in pairs(EffectController.ActiveEffects) do
					EffectController.ActiveEffects[k] = nil
				end
			end
		end)
	end
end

--------------------------------------------------------------------
-- GUI
--------------------------------------------------------------------
local UI_NAME = "StarkHelperMobile"

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
	Bg = Color3.fromRGB(10, 12, 18),
	Row = Color3.fromRGB(24, 30, 40),
	Accent = Color3.fromRGB(0, 210, 255),
	Text = Color3.fromRGB(240, 245, 255),
	Stroke = Color3.fromRGB(40, 55, 75),
	On = Color3.fromRGB(0, 210, 255),
}

local GREEN  = Color3.fromRGB(80, 220, 120)
local YELLOW = Color3.fromRGB(230, 190, 50)
local RED    = Color3.fromRGB(230, 70, 80)

local function corner(o, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r)
	c.Parent = o
end

local function stroke(o, col, th, tr)
	local s = Instance.new("UIStroke")
	s.Color = col or Theme.Stroke
	s.Thickness = th or 1.5
	s.Transparency = tr or 0.15
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = o
	return s
end

local function tw(o, props, t)
	TweenService:Create(o, TweenInfo.new(t or 0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props):Play()
end

local CIRCLE = 48
local GAP = 8
local COUNT = 5
local stripW = CIRCLE * COUNT + GAP * (COUNT - 1) + 16
local stripH = CIRCLE + 46

local Strip = Instance.new("Frame")
Strip.Name = "MobileStrip"
Strip.Size = UDim2.fromOffset(stripW, stripH)
Strip.Position = UDim2.new(0.5, -math.floor(stripW / 2), 1, -stripH - 24)
Strip.BackgroundColor3 = Theme.Bg
Strip.BackgroundTransparency = 0.12
Strip.BorderSizePixel = 0
Strip.Active = true
Strip.Parent = GUI
corner(Strip, 16)
stroke(Strip, Theme.Accent, 1.2, 0.4)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 14)
title.Position = UDim2.fromOffset(0, 3)
title.BackgroundTransparency = 1
title.Text = "STARK"
title.TextSize = 11
title.Font = Enum.Font.GothamBlack
title.TextColor3 = Theme.Accent
title.Parent = Strip

local statsLabel = Instance.new("TextLabel")
statsLabel.Size = UDim2.new(1, -8, 0, 14)
statsLabel.Position = UDim2.fromOffset(4, 16)
statsLabel.BackgroundTransparency = 1
statsLabel.Text = "FPS --  |  --"
statsLabel.TextSize = 11
statsLabel.Font = Enum.Font.GothamBold
statsLabel.TextColor3 = Theme.Text
statsLabel.TextXAlignment = Enum.TextXAlignment.Center
statsLabel.Parent = Strip

-- Drag
do
	local dragging, dragStart, startPos = false, nil, nil
	Strip.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = Strip.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End or input.UserInputState == Enum.UserInputState.Cancel then
					dragging = false
				end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
			local delta = input.Position - dragStart
			Strip.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
end

local function makeCircle(index, shortName)
	local x = 8 + (index - 1) * (CIRCLE + GAP)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.fromOffset(CIRCLE, CIRCLE)
	btn.Position = UDim2.fromOffset(x, 34)
	btn.BackgroundColor3 = Theme.Row
	btn.BorderSizePixel = 0
	btn.Text = shortName
	btn.TextSize = 10
	btn.Font = Enum.Font.GothamBlack
	btn.TextColor3 = Theme.Text
	btn.AutoButtonColor = false
	btn.Parent = Strip
	corner(btn, 99)
	local st = stroke(btn, Theme.Stroke, 1.6, 0.2)

	local function setVisual(state)
		if state then
			tw(btn, { BackgroundColor3 = Theme.On })
			tw(st, { Color = Theme.On, Transparency = 0 })
			btn.TextColor3 = Color3.fromRGB(8, 12, 18)
		else
			tw(btn, { BackgroundColor3 = Theme.Row })
			tw(st, { Color = Theme.Stroke, Transparency = 0.2 })
			btn.TextColor3 = Theme.Text
		end
	end

	return btn, setVisual
end

local buyBtn, setBuyVisual = makeCircle(1, "BUY")
local ancBtn, setAncVisual = makeCircle(2, "ANC")
local ragBtn, setRagVisual = makeCircle(3, "RAG")
local optBtn, setOptVisual = makeCircle(4, "OPT")
local blkBtn, setBlkVisual = makeCircle(5, "BLK")

buyBtn.MouseButton1Click:Connect(function()
	local nextState = not helperAutoBuyActive
	setHelperAutoBuy(nextState)
	setBuyVisual(nextState)
end)

ancBtn.MouseButton1Click:Connect(function()
	local nextState = not helperAnchored
	setHelperAnchor(nextState)
	setAncVisual(nextState)
end)

ragBtn.MouseButton1Click:Connect(function()
	local nextState = not helperAntiRagdollActive
	setHelperAntiRagdoll(nextState)
	setRagVisual(nextState)
end)

optBtn.MouseButton1Click:Connect(function()
	local nextState = not helperOptimizerActive
	setHelperOptimizer(nextState)
	setOptVisual(nextState)
end)

blkBtn.MouseButton1Click:Connect(function()
	local nextState = not helperBlockEventsActive
	setHelperBlockEvents(nextState)
	setBlkVisual(nextState)
end)

--------------------------------------------------------------------
-- FPS + PING real
--------------------------------------------------------------------
local currentFps, currentPing = 0, 0
local fpsBuf, fpsFlush, pingAccum = {}, 0, 0

local function updateStatsLabel()
	if not (statsLabel and statsLabel.Parent) then return end
	statsLabel.Text = string.format("FPS %d  |  %d", currentFps, currentPing)

	local badFps = currentFps > 0 and currentFps < 15
	local midFps = currentFps >= 16 and currentFps <= 39
	local badPing = currentPing >= 100
	local midPing = currentPing >= 41 and currentPing <= 99

	if badFps or badPing then
		statsLabel.TextColor3 = RED
	elseif midFps or midPing then
		statsLabel.TextColor3 = YELLOW
	else
		statsLabel.TextColor3 = GREEN
	end
end

RunService.RenderStepped:Connect(function(dt)
	if dt > 0 then
		fpsBuf[#fpsBuf + 1] = 1 / dt
	end
	fpsFlush += dt
	if fpsFlush >= 0.35 and #fpsBuf > 0 then
		fpsFlush = 0
		local sum = 0
		for i = 1, #fpsBuf do sum += fpsBuf[i] end
		currentFps = math.round(sum / #fpsBuf)
		fpsBuf = {}
		updateStatsLabel()
	end
end)

RunService.Heartbeat:Connect(function(dt)
	pingAccum += dt
	if pingAccum < 2 then return end
	pingAccum = 0

	local ok, val = pcall(function()
		return math.round(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
	end)
	if ok and type(val) == "number" then
		currentPing = val
		updateStatsLabel()
	end
end)

--------------------------------------------------------------------
-- STOP
--------------------------------------------------------------------
local function stopEverything()
	helperAutoBuyActive = false
	helperAntiRagdollActive = false
	helperOptimizerActive = false
	helperBlockEventsActive = false

	if helperAutoBuyConn then pcall(function() helperAutoBuyConn:Disconnect() end) end
	if helperCharacterConn then pcall(function() helperCharacterConn:Disconnect() end) end
	if helperAntiRagdollConn then pcall(function() helperAntiRagdollConn:Disconnect() end) end

	if helperAnchored then pcall(function() setCharacterAnchored(false) end) end
	helperAnchored = false

	applyOptimizer(false)
	setHelperBlockEvents(false)

	if GUI then pcall(function() GUI:Destroy() end) end
end

env.StarkHelperStop = stopEverything

print("[STARK HELPER MOBILE] BUY / ANC / RAG / OPT / BLK + FPS/Ping")
