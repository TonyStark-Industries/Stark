-- Code Sniper | White + Neon Blue (Improved)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Colores (blanco + azul neón)
local C = {
	Bg          = Color3.fromRGB(248, 250, 255),
	Panel       = Color3.fromRGB(255, 255, 255),
	Card        = Color3.fromRGB(240, 245, 255),
	Black       = Color3.fromRGB(15, 18, 28),
	Neon        = Color3.fromRGB(0, 170, 255),
	NeonSoft    = Color3.fromRGB(0, 140, 220),
	Text        = Color3.fromRGB(20, 25, 40),
	Dim         = Color3.fromRGB(110, 125, 150),
	Green       = Color3.fromRGB(30, 200, 120),
	Red         = Color3.fromRGB(240, 70, 90),
	Yellow      = Color3.fromRGB(255, 180, 40),
}

if getgenv then getgenv().__VECS_UI_TOKEN = (getgenv().__VECS_UI_TOKEN or 0) + 1 end
local token = getgenv and getgenv().__VECS_UI_TOKEN or 1
local function alive() return not getgenv or getgenv().__VECS_UI_TOKEN == token end

local function corner(p, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 10)
	c.Parent = p
	return c
end

local function stroke(p, color, thick, trans)
	local s = Instance.new("UIStroke")
	s.Color = color or C.Neon
	s.Thickness = thick or 1.5
	s.Transparency = trans or 0
	s.Parent = p
	return s
end

local function pad(p, t, b, l, r)
	local u = Instance.new("UIPadding")
	u.PaddingTop = UDim.new(0, t or 0)
	u.PaddingBottom = UDim.new(0, b or 0)
	u.PaddingLeft = UDim.new(0, l or 0)
	u.PaddingRight = UDim.new(0, r or 0)
	u.Parent = p
	return u
end

local function tween(obj, info, props)
	local ok, t = pcall(TweenService.Create, TweenService, obj, info, props)
	if ok and t then t:Play() end
end

local function getParent()
	local ok, h = pcall(function() return gethui() end)
	if ok and h then return h end
	local ok2, core = pcall(function() return game:GetService("CoreGui") end)
	if ok2 and core then return core end
	return playerGui
end

local parent = getParent()
if not parent then return end

pcall(function()
	for _, v in ipairs(parent:GetChildren()) do
		if v.Name == "CodeSniperMinimal" or v.Name == "CSMobileBtn" then
			v:Destroy()
		end
	end
end)

-- ===================== GUI =====================
local gui = Instance.new("ScreenGui")
gui.Name = "CodeSniperMinimal"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 9999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = parent

-- Botón circular
local mobile = Instance.new("TextButton")
mobile.Name = "CSMobileBtn"
mobile.Size = UDim2.fromOffset(58, 58)
mobile.Position = UDim2.new(1, -18, 1, -18)
mobile.AnchorPoint = Vector2.new(1, 1)
mobile.BackgroundColor3 = C.Panel
mobile.Text = ""
mobile.AutoButtonColor = false
mobile.Parent = gui
corner(mobile, 29)
stroke(mobile, C.Neon, 2.2)

local mobileImg = Instance.new("ImageLabel")
mobileImg.Size = UDim2.fromScale(0.7, 0.7)
mobileImg.Position = UDim2.fromScale(0.5, 0.5)
mobileImg.AnchorPoint = Vector2.new(0.5, 0.5)
mobileImg.BackgroundTransparency = 1
mobileImg.Image = "rbxassetid://72834593746265"
mobileImg.ScaleType = Enum.ScaleType.Fit
mobileImg.Parent = mobile

-- Ventana
local window = Instance.new("Frame")
window.Name = "Window"
window.Size = UDim2.fromOffset(0, 0)
window.Position = UDim2.new(0.5, 0, 0.5, 0)
window.AnchorPoint = Vector2.new(0.5, 0.5)
window.BackgroundColor3 = C.Bg
window.BorderSizePixel = 0
window.ClipsDescendants = true
window.Visible = false
window.Parent = gui
corner(window, 16)
stroke(window, C.Neon, 2, 0.1)

local uiScale = Instance.new("UIScale")
uiScale.Scale = 0
uiScale.Parent = window

-- Topbar
local top = Instance.new("Frame")
top.Size = UDim2.new(1, 0, 0, 46)
top.BackgroundColor3 = C.Panel
top.BorderSizePixel = 0
top.Parent = window
corner(top, 16)
stroke(top, C.Neon, 1.2, 0.35)

local topImg = Instance.new("ImageLabel")
topImg.Size = UDim2.fromOffset(28, 28)
topImg.Position = UDim2.fromOffset(14, 9)
topImg.BackgroundTransparency = 1
topImg.Image = "rbxassetid://72834593746265"
topImg.ScaleType = Enum.ScaleType.Fit
topImg.Parent = top

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -100, 1, 0)
title.Position = UDim2.fromOffset(52, 0)
title.BackgroundTransparency = 1
title.Text = "Code Sniper"
title.TextColor3 = C.Neon
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = top

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.fromOffset(32, 32)
minBtn.Position = UDim2.new(1, -42, 0.5, -16)
minBtn.BackgroundColor3 = C.Card
minBtn.Text = "−"
minBtn.TextColor3 = C.Neon
minBtn.Font = Enum.Font.GothamBlack
minBtn.TextSize = 18
minBtn.Parent = top
corner(minBtn, 8)
stroke(minBtn, C.NeonSoft, 1.2)

-- Contenido
local content = Instance.new("Frame")
content.Size = UDim2.new(1, 0, 1, -46)
content.Position = UDim2.fromOffset(0, 46)
content.BackgroundTransparency = 1
content.Parent = window

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -20, 1, -20)
scroll.Position = UDim2.fromOffset(10, 10)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.ScrollBarImageColor3 = C.Neon
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.CanvasSize = UDim2.new()
scroll.Parent = content
pad(scroll, 4, 14, 4, 4)

local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 9)
list.SortOrder = Enum.SortOrder.LayoutOrder
list.Parent = scroll

local function row(h)
	local f = Instance.new("Frame")
	f.Size = UDim2.new(1, 0, 0, h or 46)
	f.BackgroundColor3 = C.Panel
	f.BorderSizePixel = 0
	f.Parent = scroll
	corner(f, 11)
	stroke(f, C.NeonSoft, 1.1, 0.45)
	return f
end

-- Status
local statusRow = row(40)
local statusDot = Instance.new("Frame")
statusDot.Size = UDim2.fromOffset(11, 11)
statusDot.Position = UDim2.fromOffset(15, 14.5)
statusDot.BackgroundColor3 = C.Yellow
statusDot.BorderSizePixel = 0
statusDot.Parent = statusRow
corner(statusDot, 6)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -40, 1, 0)
statusLabel.Position = UDim2.fromOffset(34, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Starting..."
statusLabel.TextColor3 = C.Text
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 13
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = statusRow

-- Auto Redeem
local autoRow = row(48)
local autoLabel = Instance.new("TextLabel")
autoLabel.Size = UDim2.new(0.55, 0, 1, 0)
autoLabel.Position = UDim2.fromOffset(16, 0)
autoLabel.BackgroundTransparency = 1
autoLabel.Text = "Auto Redeem"
autoLabel.TextColor3 = C.Text
autoLabel.Font = Enum.Font.GothamBold
autoLabel.TextSize = 14
autoLabel.TextXAlignment = Enum.TextXAlignment.Left
autoLabel.Parent = autoRow

local autoBtn = Instance.new("TextButton")
autoBtn.Size = UDim2.fromOffset(68, 30)
autoBtn.Position = UDim2.new(1, -80, 0.5, -15)
autoBtn.BackgroundColor3 = C.Green
autoBtn.Text = "ON"
autoBtn.TextColor3 = Color3.new(1,1,1)
autoBtn.Font = Enum.Font.GothamBold
autoBtn.TextSize = 13
autoBtn.Parent = autoRow
corner(autoBtn, 8)

-- Delay
local delayRow = row(48)
local delayLabel = Instance.new("TextLabel")
delayLabel.Size = UDim2.new(0.36, 0, 1, 0)
delayLabel.Position = UDim2.fromOffset(16, 0)
delayLabel.BackgroundTransparency = 1
delayLabel.Text = "Submit Delay"
delayLabel.TextColor3 = C.Text
delayLabel.Font = Enum.Font.GothamBold
delayLabel.TextSize = 14
delayLabel.TextXAlignment = Enum.TextXAlignment.Left
delayLabel.Parent = delayRow

local delayToggle = Instance.new("TextButton")
delayToggle.Size = UDim2.fromOffset(48, 28)
delayToggle.Position = UDim2.new(1, -186, 0.5, -14)
delayToggle.BackgroundColor3 = C.Red
delayToggle.Text = "OFF"
delayToggle.TextColor3 = Color3.new(1,1,1)
delayToggle.Font = Enum.Font.GothamBold
delayToggle.TextSize = 12
delayToggle.Parent = delayRow
corner(delayToggle, 7)

local delayMinus = Instance.new("TextButton")
delayMinus.Size = UDim2.fromOffset(30, 28)
delayMinus.Position = UDim2.new(1, -132, 0.5, -14)
delayMinus.BackgroundColor3 = C.Card
delayMinus.Text = "−"
delayMinus.TextColor3 = C.Neon
delayMinus.Font = Enum.Font.GothamBold
delayMinus.TextSize = 17
delayMinus.Parent = delayRow
corner(delayMinus, 7)
stroke(delayMinus, C.NeonSoft, 1.1)

local delayValue = Instance.new("TextLabel")
delayValue.Size = UDim2.fromOffset(50, 28)
delayValue.Position = UDim2.new(1, -98, 0.5, -14)
delayValue.BackgroundColor3 = C.Card
delayValue.Text = "0.2s"
delayValue.TextColor3 = C.Neon
delayValue.Font = Enum.Font.GothamBold
delayValue.TextSize = 13
delayValue.Parent = delayRow
corner(delayValue, 7)

local delayPlus = Instance.new("TextButton")
delayPlus.Size = UDim2.fromOffset(30, 28)
delayPlus.Position = UDim2.new(1, -42, 0.5, -14)
delayPlus.BackgroundColor3 = C.Card
delayPlus.Text = "+"
delayPlus.TextColor3 = C.Neon
delayPlus.Font = Enum.Font.GothamBold
delayPlus.TextSize = 17
delayPlus.Parent = delayRow
corner(delayPlus, 7)
stroke(delayPlus, C.NeonSoft, 1.1)

-- Format
local formatRow = row(44)
local formatLabel = Instance.new("TextLabel")
formatLabel.Size = UDim2.new(0.3, 0, 1, 0)
formatLabel.Position = UDim2.fromOffset(16, 0)
formatLabel.BackgroundTransparency = 1
formatLabel.Text = "Format"
formatLabel.TextColor3 = C.Text
formatLabel.Font = Enum.Font.GothamBold
formatLabel.TextSize = 14
formatLabel.TextXAlignment = Enum.TextXAlignment.Left
formatLabel.Parent = formatRow

local function makeFmt(txt, x)
	local b = Instance.new("TextButton")
	b.Size = UDim2.fromOffset(62, 28)
	b.Position = UDim2.new(1, x, 0.5, -14)
	b.BackgroundColor3 = C.Card
	b.Text = txt
	b.TextColor3 = C.Dim
	b.Font = Enum.Font.GothamBold
	b.TextSize = 12
	b.Parent = formatRow
	corner(b, 7)
	stroke(b, C.NeonSoft, 1, 0.4)
	return b
end

local fmtNormal = makeFmt("Normal", -198)
local fmtUpper  = makeFmt("UPPER",  -130)
local fmtLower  = makeFmt("lower",  -62)

-- Word Submit
local wordRow = row(48)
local wordLabel = Instance.new("TextLabel")
wordLabel.Size = UDim2.new(0.36, 0, 1, 0)
wordLabel.Position = UDim2.fromOffset(16, 0)
wordLabel.BackgroundTransparency = 1
wordLabel.Text = "Word Submit"
wordLabel.TextColor3 = C.Text
wordLabel.Font = Enum.Font.GothamBold
wordLabel.TextSize = 14
wordLabel.TextXAlignment = Enum.TextXAlignment.Left
wordLabel.Parent = wordRow

local wordToggle = Instance.new("TextButton")
wordToggle.Size = UDim2.fromOffset(48, 28)
wordToggle.Position = UDim2.new(1, -166, 0.5, -14)
wordToggle.BackgroundColor3 = C.Red
wordToggle.Text = "OFF"
wordToggle.TextColor3 = Color3.new(1,1,1)
wordToggle.Font = Enum.Font.GothamBold
wordToggle.TextSize = 12
wordToggle.Parent = wordRow
corner(wordToggle, 7)

local wordMinus = Instance.new("TextButton")
wordMinus.Size = UDim2.fromOffset(30, 28)
wordMinus.Position = UDim2.new(1, -112, 0.5, -14)
wordMinus.BackgroundColor3 = C.Card
wordMinus.Text = "−"
wordMinus.TextColor3 = C.Neon
wordMinus.Font = Enum.Font.GothamBold
wordMinus.TextSize = 17
wordMinus.Parent = wordRow
corner(wordMinus, 7)
stroke(wordMinus, C.NeonSoft, 1.1)

local wordValue = Instance.new("TextLabel")
wordValue.Size = UDim2.fromOffset(38, 28)
wordValue.Position = UDim2.new(1, -78, 0.5, -14)
wordValue.BackgroundColor3 = C.Card
wordValue.Text = "1"
wordValue.TextColor3 = C.Neon
wordValue.Font = Enum.Font.GothamBold
wordValue.TextSize = 13
wordValue.Parent = wordRow
corner(wordValue, 7)

local wordPlus = Instance.new("TextButton")
wordPlus.Size = UDim2.fromOffset(30, 28)
wordPlus.Position = UDim2.new(1, -36, 0.5, -14)
wordPlus.BackgroundColor3 = C.Card
wordPlus.Text = "+"
wordPlus.TextColor3 = C.Neon
wordPlus.Font = Enum.Font.GothamBold
wordPlus.TextSize = 17
wordPlus.Parent = wordRow
corner(wordPlus, 7)
stroke(wordPlus, C.NeonSoft, 1.1)

-- Submit Now
local submitBtn = Instance.new("TextButton")
submitBtn.Size = UDim2.new(1, 0, 0, 42)
submitBtn.BackgroundColor3 = C.Neon
submitBtn.Text = "SUBMIT NOW"
submitBtn.TextColor3 = Color3.new(1,1,1)
submitBtn.Font = Enum.Font.GothamBlack
submitBtn.TextSize = 15
submitBtn.Parent = scroll
corner(submitBtn, 11)

-- Info
local infoBox = Instance.new("Frame")
infoBox.Size = UDim2.new(1, 0, 0, 78)
infoBox.BackgroundColor3 = C.Panel
infoBox.BorderSizePixel = 0
infoBox.Parent = scroll
corner(infoBox, 11)
stroke(infoBox, C.NeonSoft, 1.1, 0.4)
pad(infoBox, 12, 12, 14, 14)

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, 0, 0, 0)
infoLabel.AutomaticSize = Enum.AutomaticSize.Y
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "idle"
infoLabel.TextColor3 = C.Dim
infoLabel.Font = Enum.Font.Code
infoLabel.TextSize = 13
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.TextWrapped = true
infoLabel.Parent = infoBox

local stopwatch = Instance.new("TextLabel")
stopwatch.Size = UDim2.new(1, 0, 0, 0)
stopwatch.Position = UDim2.fromOffset(0, 26)
stopwatch.AutomaticSize = Enum.AutomaticSize.Y
stopwatch.BackgroundTransparency = 1
stopwatch.Text = "STOPWATCH: --"
stopwatch.TextColor3 = C.Dim
stopwatch.Font = Enum.Font.Code
stopwatch.TextSize = 12
stopwatch.TextXAlignment = Enum.TextXAlignment.Left
stopwatch.Parent = infoBox

-- ===================== LÓGICA =====================
local flag = true
local useDelay = false
local delayTime = 0.2
local formatMode = "Normal"
local useWord = false
local wordCount = 1
local mode = "AUTO"

local building = ""
local lastCode = ""
local lastTime = 0
local wordCollected = 0
local waiting = false
local gen = 0

local keybinds = getgenv and getgenv().__VECS_keybinds or {
	toggleAutoRedeem = Enum.KeyCode.P,
	resetWords = Enum.KeyCode.R
}
if getgenv then getgenv().__VECS_keybinds = keybinds end

local session = {}
if getgenv then getgenv().__RW_session = session end

local function resolveNet()
	local packages = ReplicatedStorage:WaitForChild("Packages", 15)
	if not packages then return nil end
	return packages:WaitForChild("Net", 15)
end

local function findCodesUI()
	local codes = playerGui:FindFirstChild("Codes")
	if not codes then return nil, nil end
	local codes2 = codes:FindFirstChild("Codes")
	local textBox, confirm
	if codes2 then
		local redeem = codes2:FindFirstChild("CodeRedeem")
		if redeem then textBox = redeem:FindFirstChild("TextBox") end
		confirm = codes2:FindFirstChild("Confirm")
	end
	if not textBox then
		local redeem = codes:FindFirstChild("CodeRedeem", true)
		if redeem then textBox = redeem:FindFirstChildWhichIsA("TextBox", true) end
		textBox = textBox or codes:FindFirstChildWhichIsA("TextBox", true)
	end
	return textBox, confirm or codes:FindFirstChild("Confirm", true)
end

local cachedBox, cachedConfirm
local function getUI()
	if cachedBox and cachedBox.Parent and cachedConfirm and cachedConfirm.Parent then
		return cachedBox, cachedConfirm
	end
	cachedBox, cachedConfirm = findCodesUI()
	return cachedBox, cachedConfirm
end

local function fireConfirm(btn)
	if not btn or not btn.Parent or type(firesignal) ~= "function" then return false end
	local ok = pcall(function()
		local tb = btn:FindFirstChildWhichIsA("TextButton") or btn
		firesignal(tb.Activated)
	end)
	return ok
end

local function doRedeem(code, startTime)
	startTime = startTime or os.clock()
	if mode == "MANUAL" then
		infoLabel.Text = "manual: abre Codes y clickea el textbox"
		infoLabel.TextColor3 = C.Yellow
		return
	end
	local box, confirm = getUI()
	if not box or not confirm then
		infoLabel.Text = "esperando Codes UI..."
		infoLabel.TextColor3 = C.Yellow
		task.spawn(function()
			for i = 1, 40 do
				if not alive() then return end
				box, confirm = getUI()
				if box and confirm then
					doRedeem(code, startTime)
					return
				end
				task.wait(0.05)
			end
			infoLabel.Text = "Codes UI no encontrada"
			infoLabel.TextColor3 = C.Red
		end)
		return
	end
	box.Text = code
	local t = os.clock()
	local ok = fireConfirm(confirm)
	local ms = (t - startTime) * 1000
	stopwatch.Text = string.format("STOPWATCH: %.2fms", ms)
	stopwatch.TextColor3 = ms <= 20 and C.Green or (ms <= 60 and C.Yellow or C.Red)
	infoLabel.Text = (ok and "Dispatched: " or "Falló: ") .. code
	infoLabel.TextColor3 = ok and C.Green or C.Red
end

local function cleanCode(raw)
	local pattern = formatMode == "UPPER" and "[^A-Z0-9]" or formatMode == "lower" and "[^a-z0-9]" or "[^A-Za-z0-9]"
	local parts = {}
	for word in raw:gmatch("%S+") do
		local clean = word:gsub(pattern, "")
		if #clean >= 1 then table.insert(parts, clean) end
	end
	if #parts ~= 1 then return "" end
	local code = parts[1]
	if #code > 24 then return "" end
	return code
end

local function submitBuilt(startTime)
	local code = building
	building = ""
	wordCollected = 0
	waiting = false
	gen += 1
	if code == "" or not flag then return end
	doRedeem(code, startTime)
end

local function onCode(raw, startTime)
	if not flag then return end
	local code = cleanCode(raw)
	if code == "" then return end
	local now = os.clock()
	if code == lastCode and now - lastTime < 0.25 then return end
	lastCode = code
	lastTime = now
	building ..= code
	wordCollected += 1

	if useWord and wordCollected >= wordCount then
		submitBuilt(startTime or now)
		infoLabel.Text = "SUBMIT REQUESTED"
		infoLabel.TextColor3 = C.Green
		return
	end

	if not useDelay then
		if useWord then
			infoLabel.Text = string.format("Collecting %d/%d: %s", wordCollected, wordCount, building)
			infoLabel.TextColor3 = C.Yellow
		else
			local temp = building
			submitBuilt(startTime or now)
			infoLabel.Text = "instant → " .. temp
			infoLabel.TextColor3 = C.Green
		end
		return
	end

	waiting = true
	local myGen = gen
	task.delay(delayTime, function()
		if not alive() or myGen ~= gen or not waiting or not flag or not useDelay then return end
		submitBuilt(startTime or now)
	end)
	infoLabel.Text = "Building: " .. building
	infoLabel.TextColor3 = C.Yellow
end

local fired = 0
local function onRemote(arg, _, _, tag)
	if not alive() then return end
	if tag ~= "Top" then return end
	if type(arg) ~= "string" or #arg == 0 then return end
	if not flag then return end

	local t = os.clock()
	local match = arg:match("^([A-Za-z0-9]+)$") or arg:gsub("<.->", ""):match("^%s*([A-Za-z0-9]+)%s*$")
	if match and #match >= 1 and #match <= 24 and not useDelay and not useWord and formatMode == "Normal" then
		doRedeem(match, t)
	else
		if arg:find("<", 1, true) then arg = arg:gsub("<.->", "") end
		onCode(arg, t)
	end
	fired += 1
	statusLabel.Text = string.format("FIRED  (x%d)", fired)
	statusLabel.TextColor3 = C.Green
	statusDot.BackgroundColor3 = C.Green
end

-- ===================== CONTROLES =====================
local open = false
local minimized = false

local function setOpen(state)
	open = state
	if state then
		window.Visible = true
		window.Size = UDim2.fromOffset(355, 510)
		tween(uiScale, TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1})
	else
		tween(uiScale, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = 0})
		task.delay(0.24, function()
			if not open then window.Visible = false end
		end)
	end
end

mobile.MouseButton1Click:Connect(function()
	setOpen(not open)
end)

UserInputService.InputBegan:Connect(function(input, gp)
	if not alive() or gp then return end
	if input.KeyCode == Enum.KeyCode.RightControl then
		setOpen(not open)
	end
end)

minBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	content.Visible = not minimized
	window.Size = minimized and UDim2.fromOffset(355, 46) or UDim2.fromOffset(355, 510)
	minBtn.Text = minimized and "+" or "−"
end)

-- Drag
do
	local dragging, startPos, startInput
	top.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			startPos = window.Position
			startInput = input.Position
		end
	end)
	top.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - startInput
			window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

-- Auto
local function toggleAuto()
	flag = not flag
	if flag then
		autoBtn.Text = "ON"
		autoBtn.BackgroundColor3 = C.Green
		infoLabel.Text = "idle"
		infoLabel.TextColor3 = C.Dim
	else
		autoBtn.Text = "OFF"
		autoBtn.BackgroundColor3 = C.Red
		building = ""
		wordCollected = 0
		waiting = false
		gen += 1
		infoLabel.Text = "paused"
		infoLabel.TextColor3 = C.Dim
	end
end
autoBtn.MouseButton1Click:Connect(toggleAuto)

-- Delay
local function updateDelay()
	delayValue.Text = string.format("%.1fs", delayTime)
end
delayPlus.MouseButton1Click:Connect(function()
	delayTime = math.clamp(delayTime + 0.1, 0.1, 10)
	updateDelay()
end)
delayMinus.MouseButton1Click:Connect(function()
	delayTime = math.clamp(delayTime - 0.1, 0.1, 10)
	updateDelay()
end)
delayToggle.MouseButton1Click:Connect(function()
	useDelay = not useDelay
	delayToggle.Text = useDelay and "ON" or "OFF"
	delayToggle.BackgroundColor3 = useDelay and C.Green or C.Red
end)

-- Format
local function setFormat(m)
	formatMode = m
	for _, btn in ipairs({fmtNormal, fmtUpper, fmtLower}) do
		local active = btn.Text == m
		btn.BackgroundColor3 = active and C.Neon or C.Card
		btn.TextColor3 = active and Color3.new(1,1,1) or C.Dim
	end
end
fmtNormal.MouseButton1Click:Connect(function() setFormat("Normal") end)
fmtUpper.MouseButton1Click:Connect(function() setFormat("UPPER") end)
fmtLower.MouseButton1Click:Connect(function() setFormat("lower") end)
setFormat("Normal")

-- Word
local function updateWord()
	wordValue.Text = tostring(wordCount)
end
wordPlus.MouseButton1Click:Connect(function()
	wordCount = math.clamp(wordCount + 1, 1, 20)
	updateWord()
end)
wordMinus.MouseButton1Click:Connect(function()
	wordCount = math.clamp(wordCount - 1, 1, 20)
	updateWord()
end)
wordToggle.MouseButton1Click:Connect(function()
	useWord = not useWord
	wordToggle.Text = useWord and "ON" or "OFF"
	wordToggle.BackgroundColor3 = useWord and C.Green or C.Red
end)

submitBtn.MouseButton1Click:Connect(function()
	if building ~= "" then
		submitBuilt()
	else
		infoLabel.Text = "nada que enviar"
		infoLabel.TextColor3 = C.Dim
	end
end)

-- Keybinds
UserInputService.InputBegan:Connect(function(input, gp)
	if not alive() or UserInputService:GetFocusedTextBox() then return end
	if gp then return end
	if input.KeyCode == keybinds.toggleAutoRedeem then
		toggleAuto()
	elseif input.KeyCode == keybinds.resetWords then
		building = ""
		wordCollected = 0
		waiting = false
		gen += 1
		infoLabel.Text = "resetted"
		infoLabel.TextColor3 = C.Yellow
	end
end)

-- Remote hook
task.spawn(function()
	statusLabel.Text = "Finding remotes..."
	local net = resolveNet()
	if not net then
		statusLabel.Text = "Net folder not found"
		statusLabel.TextColor3 = C.Red
		statusDot.BackgroundColor3 = C.Red
		return
	end

	if getgenv and getgenv().__RW_conns then
		for _, c in ipairs(getgenv().__RW_conns) do pcall(function() c:Disconnect() end) end
	end
	local conns = {}

	local function hook(desc)
		if not (desc:IsA("RemoteEvent") or desc:IsA("UnreliableRemoteEvent")) then return end
		local ok, conn = pcall(function()
			return desc.OnClientEvent:Connect(onRemote)
		end)
		if ok and conn then table.insert(conns, conn) end
	end

	for _, d in ipairs(net:GetDescendants()) do hook(d) end
	table.insert(conns, net.DescendantAdded:Connect(hook))
	if getgenv then getgenv().__RW_conns = conns end

	statusLabel.Text = "Waiting for fire"
	statusLabel.TextColor3 = C.Yellow
end)

task.spawn(function()
	while alive() do
		if flag and useDelay and waiting and building ~= "" then
			local left = math.max(0, (lastTime + delayTime) - os.clock())
			infoLabel.Text = string.format("Building: %s   %.2fs", building, left)
			infoLabel.TextColor3 = C.Yellow
			task.wait()
		else
			task.wait(0.1)
		end
	end
end)

print("[Code Sniper] White + Neon Blue loaded")
