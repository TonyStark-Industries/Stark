-- ============================================================
-- Code Sniper | Black + Pink/Violet (Fixed Capture)
-- Based on Traced + K2 improvements
-- ============================================================

repeat task.wait() until game:IsLoaded()

pcall(function()
	local old = getgenv().CodeSniperGui
	if old and old.Parent then old:Destroy() end
end)

getgenv().CodeSniperV3 = true

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ===================== THEME (Negro real + Rosa/Violeta) =====================
local C = {
	Bg          = Color3.fromRGB(8, 8, 10),
	Panel       = Color3.fromRGB(16, 14, 18),
	Card        = Color3.fromRGB(22, 18, 26),
	Accent      = Color3.fromRGB(255, 74, 177),
	Accent2     = Color3.fromRGB(255, 120, 190),
	Violet      = Color3.fromRGB(200, 100, 170),
	Text        = Color3.fromRGB(255, 245, 250),
	Dim         = Color3.fromRGB(180, 150, 170),
	Green       = Color3.fromRGB(110, 230, 180),
	Red         = Color3.fromRGB(255, 110, 120),
	Yellow      = Color3.fromRGB(255, 190, 100),
	Border      = Color3.fromRGB(160, 70, 120),
}

-- ===================== CONFIG =====================
local CONFIG_FILE = "codesniper_v3_config.json"
local saving = false

local Settings = {
	AutoListen     = true,
	AutoRedeem     = true,
	AutoType       = true,
	WordMode       = false,
	WordCount      = 1,
	IgnoreSystem   = true,
	SubmitDelay    = 0,
}

local function saveConfig()
	pcall(function()
		local wf = writefile or (syn and syn.writefile)
		if wf then
			wf(CONFIG_FILE, HttpService:JSONEncode(Settings))
		end
	end)
end

local function loadConfig()
	pcall(function()
		local rf = readfile or (syn and syn.readfile)
		local isf = isfile or (syn and syn.isfile)
		if not rf then return end
		if isf and not isf(CONFIG_FILE) then return end
		local data = HttpService:JSONDecode(rf(CONFIG_FILE))
		if type(data) == "table" then
			for k, v in pairs(data) do
				if Settings[k] ~= nil then Settings[k] = v end
			end
		end
	end)
end

local function scheduleSave()
	if saving then return end
	saving = true
	task.delay(0.4, function()
		saving = false
		saveConfig()
	end)
end

pcall(loadConfig)

-- ===================== HELPERS =====================
local function corner(p, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 10)
	c.Parent = p
	return c
end

local function stroke(p, color, thick, trans)
	local s = Instance.new("UIStroke")
	s.Color = color or C.Accent
	s.Thickness = thick or 1.4
	s.Transparency = trans or 0.25
	s.Parent = p
	return s
end

local function tween(obj, info, props)
	local ok, t = pcall(TweenService.Create, TweenService, obj, info, props)
	if ok and t then t:Play() end
end

local function getParent()
	local ok, h = pcall(gethui)
	if ok and h then return h end
	local ok2, core = pcall(function() return game:GetService("CoreGui") end)
	if ok2 and core then return core end
	return PlayerGui
end

-- ===================== SMART CODE EXTRACTOR (FIXED) =====================
local FILLER = {
	ok=true, lets=true, do_=true, the=true, a=true, an=true, is=true, code=true,
	use=true, using=true, redeem=true, type=true, enter=true, claim=true, here=true,
	heres=true, new=true, free=true, working=true, another=true, this=true, your=true,
	sammy=true, spydersammy=true, just=true, now=true, try=true, please=true
}

local function cleanText(str)
	return tostring(str or ""):gsub("<.->", ""):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
end

local function isCodeLike(word)
	if not word or #word < 4 or #word > 24 then return false end
	if FILLER[word:lower()] then return false end
	-- Prefer codes with letters + numbers or all caps
	local hasLetter = word:match("%a")
	local hasDigit  = word:match("%d")
	local mostlyUpper = word == word:upper()
	if hasLetter and (hasDigit or mostlyUpper) then return true end
	if #word >= 6 and mostlyUpper then return true end
	return false
end

local function extractCode(raw)
	raw = cleanText(raw)
	if raw == "" then return nil end

	-- 1. Try patterns like "code is XXX", "use code XXX"
	local patterns = {
		"[Cc]ode%s*[:=%-]?%s*([%w_]+)",
		"[Uu]se%s+[Cc]ode%s+([%w_]+)",
		"[Rr]edeem%s+([%w_]+)",
		"[Tt]ype%s+([%w_]+)",
		"[Ee]nter%s+([%w_]+)",
	}
	for _, pat in ipairs(patterns) do
		local m = raw:match(pat)
		if m and isCodeLike(m) then return m end
	end

	-- 2. Split words and pick the best code-like token
	local best = nil
	for word in raw:gmatch("[%w_]+") do
		if isCodeLike(word) then
			if not best or #word > #best then
				best = word
			end
		end
	end
	return best
end

-- ===================== REDEEM LOGIC =====================
local function findCodeBox()
	local codes = PlayerGui:FindFirstChild("Codes")
	if not codes then return nil, nil end

	local main = (codes:FindFirstChild("Codes") or codes):FindFirstChild("Main")
	local box = main and main:FindFirstChild("TextBox")
	if box and box:IsA("TextBox") then
		local confirm = main and main:FindFirstChild("Confirm")
		return box, confirm
	end

	for _, d in ipairs(codes:GetDescendants()) do
		if d:IsA("TextBox") then
			local confirm = d.Parent and (d.Parent:FindFirstChild("Confirm") or d.Parent:FindFirstChildWhichIsA("ImageButton") or d.Parent:FindFirstChildWhichIsA("TextButton"))
			return d, confirm
		end
	end
	return nil, nil
end

local function fireConfirm(btn)
	if not btn or type(firesignal) ~= "function" then return false end
	local ok = pcall(function()
		local b = btn:FindFirstChildWhichIsA("TextButton") or btn:FindFirstChildWhichIsA("ImageButton") or btn
		firesignal(b.Activated)
		firesignal(b.MouseButton1Click)
	end)
	return ok
end

local function redeemCode(code)
	if not code or code == "" then return false, "empty" end
	local box, confirm = findCodeBox()
	if not box then return false, "no code box" end

	pcall(function()
		box.Text = code
		box:CaptureFocus()
	end)

	task.wait(0.05)
	local ok = false
	if confirm then
		ok = fireConfirm(confirm)
	end
	if not ok then
		pcall(function() box:ReleaseFocus(true) end)
		ok = true
	end
	return ok, ok and "sent" or "failed"
end

-- ===================== GUI =====================
local parent = getParent()

local gui = Instance.new("ScreenGui")
gui.Name = "CodeSniperGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 9999
gui.Parent = parent
getgenv().CodeSniperGui = gui

-- Circular button
local mobile = Instance.new("TextButton")
mobile.Name = "OpenBtn"
mobile.Size = UDim2.fromOffset(58, 58)
mobile.Position = UDim2.new(1, -18, 1, -18)
mobile.AnchorPoint = Vector2.new(1, 1)
mobile.BackgroundColor3 = C.Panel
mobile.Text = ""
mobile.AutoButtonColor = false
mobile.Parent = gui
corner(mobile, 29)
stroke(mobile, C.Accent, 2.2)

local mobileImg = Instance.new("ImageLabel")
mobileImg.Size = UDim2.fromScale(0.7, 0.7)
mobileImg.Position = UDim2.fromScale(0.5, 0.5)
mobileImg.AnchorPoint = Vector2.new(0.5, 0.5)
mobileImg.BackgroundTransparency = 1
mobileImg.Image = "rbxassetid://72834593746265"
mobileImg.ScaleType = Enum.ScaleType.Fit
mobileImg.Parent = mobile

-- Main Window
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
stroke(window, C.Accent, 1.8, 0.15)

local uiScale = Instance.new("UIScale")
uiScale.Scale = 0
uiScale.Parent = window

-- Topbar
local top = Instance.new("Frame")
top.Size = UDim2.new(1, 0, 0, 48)
top.BackgroundColor3 = C.Panel
top.BorderSizePixel = 0
top.Parent = window
corner(top, 16)

local topImg = Instance.new("ImageLabel")
topImg.Size = UDim2.fromOffset(28, 28)
topImg.Position = UDim2.fromOffset(14, 10)
topImg.BackgroundTransparency = 1
topImg.Image = "rbxassetid://72834593746265"
topImg.Parent = top

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -100, 1, 0)
title.Position = UDim2.fromOffset(52, 0)
title.BackgroundTransparency = 1
title.Text = "Code Sniper"
title.TextColor3 = C.Accent
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = top

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.fromOffset(32, 32)
minBtn.Position = UDim2.new(1, -42, 0.5, -16)
minBtn.BackgroundColor3 = C.Card
minBtn.Text = "−"
minBtn.TextColor3 = C.Accent
minBtn.Font = Enum.Font.GothamBlack
minBtn.TextSize = 18
minBtn.Parent = top
corner(minBtn, 8)
stroke(minBtn, C.Accent2, 1)

-- Content
local content = Instance.new("Frame")
content.Size = UDim2.new(1, 0, 1, -48)
content.Position = UDim2.fromOffset(0, 48)
content.BackgroundTransparency = 1
content.Parent = window

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -20, 1, -20)
scroll.Position = UDim2.fromOffset(10, 10)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = C.Accent
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.CanvasSize = UDim2.new()
scroll.Parent = content

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
	stroke(f, C.Border, 1, 0.5)
	return f
end

-- Status
local statusRow = row(40)
local statusDot = Instance.new("Frame")
statusDot.Size = UDim2.fromOffset(10, 10)
statusDot.Position = UDim2.fromOffset(14, 15)
statusDot.BackgroundColor3 = C.Yellow
statusDot.BorderSizePixel = 0
statusDot.Parent = statusRow
corner(statusDot, 5)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -36, 1, 0)
statusLabel.Position = UDim2.fromOffset(32, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Ready"
statusLabel.TextColor3 = C.Text
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 13
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = statusRow

local function setStatus(text, kind)
	statusLabel.Text = text
	local col = kind == "ok" and C.Green or kind == "err" and C.Red or kind == "wait" and C.Yellow or C.Dim
	statusLabel.TextColor3 = col
	statusDot.BackgroundColor3 = col
end

-- Toggles helper
local function makeToggle(parent, text, default, callback)
	local r = row(46)
	r.Parent = parent

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0.6, 0, 1, 0)
	lbl.Position = UDim2.fromOffset(14, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.TextColor3 = C.Text
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 13
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = r

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.fromOffset(64, 28)
	btn.Position = UDim2.new(1, -76, 0.5, -14)
	btn.BackgroundColor3 = default and C.Green or C.Red
	btn.Text = default and "ON" or "OFF"
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 12
	btn.Parent = r
	corner(btn, 7)

	local state = default
	btn.MouseButton1Click:Connect(function()
		state = not state
		btn.Text = state and "ON" or "OFF"
		btn.BackgroundColor3 = state and C.Green or C.Red
		callback(state)
		scheduleSave()
	end)
	return function(v)
		state = v
		btn.Text = v and "ON" or "OFF"
		btn.BackgroundColor3 = v and C.Green or C.Red
	end
end

local setAutoListen = makeToggle(scroll, "Auto Listen", Settings.AutoListen, function(v) Settings.AutoListen = v end)
local setAutoRedeem = makeToggle(scroll, "Auto Redeem", Settings.AutoRedeem, function(v) Settings.AutoRedeem = v end)
local setWordMode   = makeToggle(scroll, "Word Mode", Settings.WordMode, function(v) Settings.WordMode = v end)

-- Code box
local codeRow = row(50)
local codeBox = Instance.new("TextBox")
codeBox.Size = UDim2.new(1, -24, 0, 34)
codeBox.Position = UDim2.fromOffset(12, 8)
codeBox.BackgroundColor3 = C.Card
codeBox.Text = ""
codeBox.PlaceholderText = "Código capturado..."
codeBox.PlaceholderColor3 = C.Dim
codeBox.TextColor3 = C.Text
codeBox.Font = Enum.Font.GothamBold
codeBox.TextSize = 14
codeBox.ClearTextOnFocus = false
codeBox.Parent = codeRow
corner(codeBox, 8)
stroke(codeBox, C.Border, 1, 0.4)

-- Buttons
local btnRow = row(48)
local redeemBtn = Instance.new("TextButton")
redeemBtn.Size = UDim2.new(0.48, -6, 0, 34)
redeemBtn.Position = UDim2.fromOffset(10, 7)
redeemBtn.BackgroundColor3 = C.Accent
redeemBtn.Text = "REDEEM"
redeemBtn.TextColor3 = Color3.new(1,1,1)
redeemBtn.Font = Enum.Font.GothamBlack
redeemBtn.TextSize = 14
redeemBtn.Parent = btnRow
corner(redeemBtn, 8)

local clearBtn = Instance.new("TextButton")
clearBtn.Size = UDim2.new(0.48, -6, 0, 34)
clearBtn.Position = UDim2.new(0.52, 0, 0, 7)
clearBtn.BackgroundColor3 = C.Card
clearBtn.Text = "CLEAR"
clearBtn.TextColor3 = C.Text
clearBtn.Font = Enum.Font.GothamBold
clearBtn.TextSize = 14
clearBtn.Parent = btnRow
corner(clearBtn, 8)
stroke(clearBtn, C.Border, 1)

-- Info
local infoBox = row(70)
local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, -20, 1, -16)
infoLabel.Position = UDim2.fromOffset(10, 8)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "Esperando códigos..."
infoLabel.TextColor3 = C.Dim
infoLabel.Font = Enum.Font.Code
infoLabel.TextSize = 12
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.TextYAlignment = Enum.TextYAlignment.Top
infoLabel.TextWrapped = true
infoLabel.Parent = infoBox

-- ===================== STATE =====================
local listening = false
local lastCode = ""
local lastTime = 0
local collected = {}

local function doRedeem(code)
	if not code or code == "" then return end
	setStatus("Redeeming: " .. code, "wait")
	infoLabel.Text = "Redeeming → " .. code
	local ok, msg = redeemCode(code)
	if ok then
		setStatus("Sent: " .. code, "ok")
		infoLabel.Text = "✓ " .. code
	else
		setStatus("Failed: " .. tostring(msg), "err")
		infoLabel.Text = "✗ " .. code .. " (" .. tostring(msg) .. ")"
	end
end

local function onCaptured(raw)
	local code = extractCode(raw)
	if not code then return end

	local now = os.clock()
	if code == lastCode and now - lastTime < 0.4 then return end
	lastCode = code
	lastTime = now

	if Settings.WordMode then
		table.insert(collected, code)
		if #collected >= (Settings.WordCount or 1) then
			local final = table.concat(collected)
			collected = {}
			codeBox.Text = final
			if Settings.AutoType then codeBox.Text = final end
			if Settings.AutoRedeem then doRedeem(final) end
		else
			codeBox.Text = table.concat(collected, " ")
			setStatus(string.format("Collecting %d/%d", #collected, Settings.WordCount), "wait")
		end
	else
		collected = {}
		codeBox.Text = code
		if Settings.AutoRedeem then
			doRedeem(code)
		else
			setStatus("Captured: " .. code, "ok")
			infoLabel.Text = "Captured → " .. code
		end
	end
end

-- ===================== REMOTE HOOK =====================
task.spawn(function()
	setStatus("Finding remotes...", "wait")
	local net = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("Net")
	if not net then
		setStatus("Net not found", "err")
		return
	end

	local function hook(rem)
		if rem:IsA("RemoteEvent") or rem:IsA("UnreliableRemoteEvent") then
			rem.OnClientEvent:Connect(function(...)
				local args = {...}
				local text = args[1]
				if type(text) ~= "string" then return end
				-- Solo Top banner normalmente
				if Settings.IgnoreSystem and args[4] and args[4] ~= "Top" then return end
				onCaptured(text)
			end)
		end
	end

	for _, c in ipairs(net:GetDescendants()) do hook(c) end
	net.DescendantAdded:Connect(hook)
	setStatus("Listening for codes", "ok")
end)

-- ===================== CONTROLS =====================
local open = false
local function setOpen(state)
	open = state
	if state then
		window.Visible = true
		window.Size = UDim2.fromOffset(340, 460)
		tween(uiScale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1})
	else
		tween(uiScale, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = 0})
		task.delay(0.22, function()
			if not open then window.Visible = false end
		end)
	end
end

mobile.MouseButton1Click:Connect(function() setOpen(not open) end)

UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.RightControl then
		setOpen(not open)
	end
end)

minBtn.MouseButton1Click:Connect(function()
	content.Visible = not content.Visible
	window.Size = content.Visible and UDim2.fromOffset(340, 460) or UDim2.fromOffset(340, 48)
	minBtn.Text = content.Visible and "−" or "+"
end)

-- Drag
do
	local drag, startPos, startInput
	top.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			drag = true
			startPos = window.Position
			startInput = i.Position
		end
	end)
	top.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			drag = false
		end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local d = i.Position - startInput
			window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
end

redeemBtn.MouseButton1Click:Connect(function()
	local t = codeBox.Text
	if t and t ~= "" then doRedeem(t) end
end)

clearBtn.MouseButton1Click:Connect(function()
	codeBox.Text = ""
	collected = {}
	setStatus("Cleared", "wait")
	infoLabel.Text = "Esperando códigos..."
end)

print("[Code Sniper V3] Black + Pink loaded | Smart capture active")
