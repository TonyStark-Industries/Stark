-- ============================================================
-- Code Sniper V4 | Full Version
-- Black + Pink/Violet | Smart Capture | More Features
-- ============================================================

repeat task.wait() until game:IsLoaded()

pcall(function()
	local old = getgenv().CodeSniperGui
	if old and old.Parent then old:Destroy() end
end)

getgenv().CodeSniperV4 = true

local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService       = game:GetService("HttpService")
local RunService        = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

-- ===================== THEME =====================
local C = {
	Bg       = Color3.fromRGB(8, 8, 10),
	Panel    = Color3.fromRGB(16, 14, 18),
	Card     = Color3.fromRGB(24, 20, 28),
	Accent   = Color3.fromRGB(255, 74, 177),
	Accent2  = Color3.fromRGB(255, 120, 190),
	Violet   = Color3.fromRGB(200, 100, 170),
	Text     = Color3.fromRGB(255, 245, 250),
	Dim      = Color3.fromRGB(175, 145, 165),
	Green    = Color3.fromRGB(110, 230, 180),
	Red      = Color3.fromRGB(255, 110, 120),
	Yellow   = Color3.fromRGB(255, 190, 100),
	Border   = Color3.fromRGB(160, 70, 120),
}

-- ===================== SETTINGS =====================
local CONFIG_FILE = "codesniper_v4.json"
local Settings = {
	AutoListen    = true,
	AutoRedeem    = true,
	AutoType      = true,
	WordMode      = false,
	WordCount     = 1,
	IgnoreSystem  = true,
	SpamMode      = false,
	SpamDelay     = 0.35,
	RetryCount    = 2,
	ListenKey     = "F",
	RedeemKey     = "G",
}

local function saveConfig()
	pcall(function()
		local wf = writefile or (syn and syn.writefile)
		if wf then wf(CONFIG_FILE, HttpService:JSONEncode(Settings)) end
	end)
end

local function loadConfig()
	pcall(function()
		local rf = readfile or (syn and syn.readfile)
		local isf = isfile or (syn and syn.isfile)
		if not rf or (isf and not isf(CONFIG_FILE)) then return end
		local data = HttpService:JSONDecode(rf(CONFIG_FILE))
		if type(data) == "table" then
			for k,v in pairs(data) do
				if Settings[k] ~= nil then Settings[k] = v end
			end
		end
	end)
end
pcall(loadConfig)

local function scheduleSave()
	task.delay(0.4, saveConfig)
end

-- ===================== HELPERS =====================
local function corner(p, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 10)
	c.Parent = p
	return c
end

local function stroke(p, col, thick, trans)
	local s = Instance.new("UIStroke")
	s.Color = col or C.Accent
	s.Thickness = thick or 1.4
	s.Transparency = trans or 0.3
	s.Parent = p
	return s
end

local function tween(obj, info, props)
	pcall(function()
		TweenService:Create(obj, info, props):Play()
	end)
end

local function getParent()
	local ok, h = pcall(gethui)
	if ok and h then return h end
	local ok2, core = pcall(function() return game:GetService("CoreGui") end)
	if ok2 and core then return core end
	return PlayerGui
end

-- ===================== SMART EXTRACTOR =====================
local SHORT_FILLER = {
	ok=true, the=true, a=true, an=true, is=true, to=true, of=true, in=true,
	on=true, for=true, and=true, or=true, my=true, your=true, this=true,
	new=true, use=true, code=true, type=true, just=true, now=true, try=true,
	lets=true, do_=true, please=true, here=true, heres=true
}

local function cleanText(str)
	return tostring(str or ""):gsub("<.->", ""):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
end

local function isStrongCode(word)
	if not word or #word < 4 or #word > 30 then return false end
	local hasLetter = word:match("%a") ~= nil
	local hasDigit  = word:match("%d") ~= nil
	local upper = 0
	local letters = 0
	for i = 1, #word do
		local c = word:sub(i,i)
		if c:match("%a") then
			letters += 1
			if c == c:upper() then upper += 1 end
		end
	end
	local upperRatio = letters > 0 and (upper / letters) or 0
	if hasDigit and hasLetter then return true end
	if upperRatio >= 0.65 and #word >= 5 then return true end
	if #word >= 8 then return true end
	return false
end

local function extractCode(raw)
	raw = cleanText(raw)
	if raw == "" then return nil end

	local patterns = {
		"[Cc]ode%s*[:=%-]?%s*([%w_]+)",
		"[Uu]se%s+[Cc]ode%s+([%w_]+)",
		"[Rr]edeem%s+([%w_]+)",
		"[Tt]ype%s+([%w_]+)",
		"[Ee]nter%s+([%w_]+)",
		"[Cc]laim%s+([%w_]+)",
	}
	for _, pat in ipairs(patterns) do
		local m = raw:match(pat)
		if m and #m >= 4 then return m end
	end

	local best, bestScore = nil, 0
	for word in raw:gmatch("[%w_]+") do
		local score = 0
		if isStrongCode(word) then
			score = #word * 2
			if word:match("%d") then score += 12 end
			if word == word:upper() then score += 10 end
		elseif #word >= 7 and not SHORT_FILLER[word:lower()] then
			score = #word
		end
		if score > bestScore then
			bestScore = score
			best = word
		end
	end
	if best then return best end

	-- Join consecutive short words (ok + lets + do)
	local words = {}
	for w in raw:gmatch("[%w_]+") do table.insert(words, w) end
	if #words >= 2 then
		for len = math.min(4, #words), 2, -1 do
			for i = 1, #words - len + 1 do
				local combined = table.concat(words, "", i, i + len - 1)
				if #combined >= 6 and #combined <= 30 and (isStrongCode(combined) or #combined >= 8) then
					return combined
				end
			end
		end
	end
	return nil
end

-- ===================== REDEEM =====================
local function findCodeUI()
	local codes = PlayerGui:FindFirstChild("Codes")
	if not codes then return nil, nil end
	local main = (codes:FindFirstChild("Codes") or codes):FindFirstChild("Main")
	local box = main and main:FindFirstChild("TextBox")
	if box and box:IsA("TextBox") then
		return box, main and main:FindFirstChild("Confirm")
	end
	for _, d in ipairs(codes:GetDescendants()) do
		if d:IsA("TextBox") then
			local conf = d.Parent and (d.Parent:FindFirstChild("Confirm") or d.Parent:FindFirstChildWhichIsA("ImageButton") or d.Parent:FindFirstChildWhichIsA("TextButton"))
			return d, conf
		end
	end
	return nil, nil
end

local function fireBtn(btn)
	if not btn or type(firesignal) ~= "function" then return false end
	return pcall(function()
		local b = btn:FindFirstChildWhichIsA("TextButton") or btn:FindFirstChildWhichIsA("ImageButton") or btn
		firesignal(b.Activated)
		firesignal(b.MouseButton1Click)
	end)
end

local function redeemCode(code)
	if not code or code == "" then return false, "empty" end
	local box, conf = findCodeUI()
	if not box then return false, "no box" end
	pcall(function()
		box.Text = code
		box:CaptureFocus()
	end)
	task.wait(0.04)
	local ok = conf and fireBtn(conf)
	if not ok then pcall(function() box:ReleaseFocus(true) end) ok = true end
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

-- Circular Open Button
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.fromOffset(58, 58)
openBtn.Position = UDim2.new(1, -18, 1, -18)
openBtn.AnchorPoint = Vector2.new(1, 1)
openBtn.BackgroundColor3 = C.Panel
openBtn.Text = ""
openBtn.AutoButtonColor = false
openBtn.Parent = gui
corner(openBtn, 29)
stroke(openBtn, C.Accent, 2.3)

local openImg = Instance.new("ImageLabel")
openImg.Size = UDim2.fromScale(0.7, 0.7)
openImg.Position = UDim2.fromScale(0.5, 0.5)
openImg.AnchorPoint = Vector2.new(0.5, 0.5)
openImg.BackgroundTransparency = 1
openImg.Image = "rbxassetid://72834593746265"
openImg.Parent = openBtn

-- Main Window
local window = Instance.new("Frame")
window.Size = UDim2.fromOffset(0, 0)
window.Position = UDim2.new(0.5, 0, 0.5, 0)
window.AnchorPoint = Vector2.new(0.5, 0.5)
window.BackgroundColor3 = C.Bg
window.BorderSizePixel = 0
window.ClipsDescendants = true
window.Visible = false
window.Parent = gui
corner(window, 16)
stroke(window, C.Accent, 1.8, 0.2)

local uiScale = Instance.new("UIScale", window)
uiScale.Scale = 0

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
title.Text = "Code Sniper V4"
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
scroll.Size = UDim2.new(1, -18, 1, -18)
scroll.Position = UDim2.fromOffset(9, 9)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = C.Accent
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.CanvasSize = UDim2.new()
scroll.Parent = content

local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 8)
list.SortOrder = Enum.SortOrder.LayoutOrder
list.Parent = scroll

local function makeRow(h)
	local f = Instance.new("Frame")
	f.Size = UDim2.new(1, 0, 0, h or 44)
	f.BackgroundColor3 = C.Panel
	f.BorderSizePixel = 0
	f.Parent = scroll
	corner(f, 10)
	stroke(f, C.Border, 1, 0.55)
	return f
end

-- Status
local statusRow = makeRow(38)
local statusDot = Instance.new("Frame")
statusDot.Size = UDim2.fromOffset(9, 9)
statusDot.Position = UDim2.fromOffset(13, 14.5)
statusDot.BackgroundColor3 = C.Yellow
statusDot.BorderSizePixel = 0
statusDot.Parent = statusRow
corner(statusDot, 5)

local statusLbl = Instance.new("TextLabel")
statusLbl.Size = UDim2.new(1, -32, 1, 0)
statusLbl.Position = UDim2.fromOffset(28, 0)
statusLbl.BackgroundTransparency = 1
statusLbl.Text = "Starting..."
statusLbl.TextColor3 = C.Text
statusLbl.Font = Enum.Font.GothamBold
statusLbl.TextSize = 12
statusLbl.TextXAlignment = Enum.TextXAlignment.Left
statusLbl.Parent = statusRow

local function setStatus(txt, kind)
	statusLbl.Text = txt
	local col = (kind == "ok" and C.Green) or (kind == "err" and C.Red) or (kind == "wait" and C.Yellow) or C.Dim
	statusLbl.TextColor3 = col
	statusDot.BackgroundColor3 = col
end

-- Toggle helper
local function makeToggle(name, default, cb)
	local r = makeRow(44)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0.62, 0, 1, 0)
	lbl.Position = UDim2.fromOffset(12, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = name
	lbl.TextColor3 = C.Text
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 13
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = r

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.fromOffset(60, 26)
	btn.Position = UDim2.new(1, -72, 0.5, -13)
	btn.BackgroundColor3 = default and C.Green or C.Red
	btn.Text = default and "ON" or "OFF"
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 11
	btn.Parent = r
	corner(btn, 6)

	local state = default
	btn.MouseButton1Click:Connect(function()
		state = not state
		btn.Text = state and "ON" or "OFF"
		btn.BackgroundColor3 = state and C.Green or C.Red
		cb(state)
		scheduleSave()
	end)
	return btn
end

makeToggle("Auto Listen", Settings.AutoListen, function(v) Settings.AutoListen = v end)
makeToggle("Auto Redeem", Settings.AutoRedeem, function(v) Settings.AutoRedeem = v end)
makeToggle("Auto Type", Settings.AutoType, function(v) Settings.AutoType = v end)
makeToggle("Word Mode", Settings.WordMode, function(v) Settings.WordMode = v end)
makeToggle("Spam Mode", Settings.SpamMode, function(v) Settings.SpamMode = v end)
makeToggle("Ignore System", Settings.IgnoreSystem, function(v) Settings.IgnoreSystem = v end)

-- Code Box
local codeRow = makeRow(48)
local codeBox = Instance.new("TextBox")
codeBox.Size = UDim2.new(1, -20, 0, 32)
codeBox.Position = UDim2.fromOffset(10, 8)
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

-- Action Buttons
local actRow = makeRow(46)
local redeemBtn = Instance.new("TextButton")
redeemBtn.Size = UDim2.new(0.48, -6, 0, 32)
redeemBtn.Position = UDim2.fromOffset(10, 7)
redeemBtn.BackgroundColor3 = C.Accent
redeemBtn.Text = "REDEEM"
redeemBtn.TextColor3 = Color3.new(1,1,1)
redeemBtn.Font = Enum.Font.GothamBlack
redeemBtn.TextSize = 13
redeemBtn.Parent = actRow
corner(redeemBtn, 8)

local clearBtn = Instance.new("TextButton")
clearBtn.Size = UDim2.new(0.48, -6, 0, 32)
clearBtn.Position = UDim2.new(0.52, 0, 0, 7)
clearBtn.BackgroundColor3 = C.Card
clearBtn.Text = "CLEAR"
clearBtn.TextColor3 = C.Text
clearBtn.Font = Enum.Font.GothamBold
clearBtn.TextSize = 13
clearBtn.Parent = actRow
corner(clearBtn, 8)
stroke(clearBtn, C.Border, 1)

-- History
local histRow = makeRow(90)
local histTitle = Instance.new("TextLabel")
histTitle.Size = UDim2.new(1, -16, 0, 18)
histTitle.Position = UDim2.fromOffset(10, 6)
histTitle.BackgroundTransparency = 1
histTitle.Text = "ÚLTIMOS CÓDIGOS"
histTitle.TextColor3 = C.Accent2
histTitle.Font = Enum.Font.GothamBlack
histTitle.TextSize = 11
histTitle.TextXAlignment = Enum.TextXAlignment.Left
histTitle.Parent = histRow

local histLabel = Instance.new("TextLabel")
histLabel.Size = UDim2.new(1, -16, 0, 60)
histLabel.Position = UDim2.fromOffset(10, 24)
histLabel.BackgroundTransparency = 1
histLabel.Text = "Ninguno todavía"
histLabel.TextColor3 = C.Dim
histLabel.Font = Enum.Font.Code
histLabel.TextSize = 11
histLabel.TextXAlignment = Enum.TextXAlignment.Left
histLabel.TextYAlignment = Enum.TextYAlignment.Top
histLabel.TextWrapped = true
histLabel.Parent = histRow

local history = {}
local function addHistory(code)
	table.insert(history, 1, code)
	if #history > 6 then table.remove(history) end
	histLabel.Text = table.concat(history, "\n")
end

-- Info
local infoRow = makeRow(55)
local infoLbl = Instance.new("TextLabel")
infoLbl.Size = UDim2.new(1, -16, 1, -12)
infoLbl.Position = UDim2.fromOffset(10, 6)
infoLbl.BackgroundTransparency = 1
infoLbl.Text = "Esperando códigos..."
infoLbl.TextColor3 = C.Dim
infoLbl.Font = Enum.Font.Code
infoLbl.TextSize = 12
infoLbl.TextXAlignment = Enum.TextXAlignment.Left
infoLbl.TextYAlignment = Enum.TextYAlignment.Top
infoLbl.TextWrapped = true
infoLbl.Parent = infoRow

-- ===================== LOGIC =====================
local lastCode, lastTime = "", 0
local collected = {}
local spamToken = 0

local function doRedeem(code, source)
	if not code or code == "" then return end
	setStatus("Redeeming: " .. code, "wait")
	infoLbl.Text = (source or "") .. " → " .. code
	local ok = redeemCode(code)
	if ok then
		setStatus("Sent: " .. code, "ok")
		infoLbl.Text = "✓ " .. code
		addHistory(code)
	else
		setStatus("Failed: " .. code, "err")
		infoLbl.Text = "✗ " .. code
	end
	return ok
end

local function onCaptured(raw)
	local code = extractCode(raw)
	if not code then return end

	local now = os.clock()
	if code == lastCode and now - lastTime < 0.45 then return end
	lastCode, lastTime = code, now

	if Settings.WordMode then
		table.insert(collected, code)
		codeBox.Text = table.concat(collected, " ")
		if #collected >= (tonumber(Settings.WordCount) or 1) then
			local final = table.concat(collected)
			collected = {}
			if Settings.AutoType then codeBox.Text = final end
			if Settings.AutoRedeem then doRedeem(final, "WORD") end
		else
			setStatus(string.format("Collecting %d/%d", #collected, Settings.WordCount), "wait")
		end
	else
		collected = {}
		if Settings.AutoType then codeBox.Text = code end
		if Settings.AutoRedeem then
			doRedeem(code, "AUTO")
			if Settings.SpamMode then
				spamToken += 1
				local my = spamToken
				task.spawn(function()
					for i = 1, (Settings.RetryCount or 2) do
						task.wait(Settings.SpamDelay or 0.35)
						if my ~= spamToken then return end
						doRedeem(code, "RETRY "..i)
					end
				end)
			end
		else
			setStatus("Captured: " .. code, "ok")
			infoLbl.Text = "Captured → " .. code
			addHistory(code)
		end
	end
end

-- Remote Hook
task.spawn(function()
	setStatus("Finding remotes...", "wait")
	local packages = ReplicatedStorage:FindFirstChild("Packages")
	local net = packages and packages:FindFirstChild("Net")
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
				if Settings.IgnoreSystem and args[4] and args[4] ~= "Top" then return end
				onCaptured(text)
			end)
		end
	end

	for _, d in ipairs(net:GetDescendants()) do hook(d) end
	net.DescendantAdded:Connect(hook)
	setStatus("Listening for codes", "ok")
	infoLbl.Text = "Listo - esperando códigos Top"
end)

-- ===================== UI CONTROLS =====================
local isOpen = false
local function toggleOpen()
	isOpen = not isOpen
	if isOpen then
		window.Visible = true
		window.Size = UDim2.fromOffset(350, 520)
		tween(uiScale, TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1})
	else
		tween(uiScale, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = 0})
		task.delay(0.22, function() if not isOpen then window.Visible = false end end)
	end
end

openBtn.MouseButton1Click:Connect(toggleOpen)
UserInputService.InputBegan:Connect(function(inp, gp)
	if gp then return end
	if inp.KeyCode == Enum.KeyCode.RightControl then toggleOpen() end
	if inp.KeyCode.Name == Settings.ListenKey then
		-- can add manual listen toggle later
	end
	if inp.KeyCode.Name == Settings.RedeemKey then
		local t = codeBox.Text
		if t ~= "" then doRedeem(t, "KEY") end
	end
end)

minBtn.MouseButton1Click:Connect(function()
	content.Visible = not content.Visible
	window.Size = content.Visible and UDim2.fromOffset(350, 520) or UDim2.fromOffset(350, 48)
	minBtn.Text = content.Visible and "−" or "+"
end)

-- Drag
do
	local dragging, startPos, startInput
	top.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			startPos = window.Position
			startInput = i.Position
		end
	end)
	top.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local d = i.Position - startInput
			window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
end

redeemBtn.MouseButton1Click:Connect(function()
	local t = codeBox.Text
	if t and t ~= "" then doRedeem(t, "MANUAL") end
end)

clearBtn.MouseButton1Click:Connect(function()
	codeBox.Text = ""
	collected = {}
	setStatus("Cleared", "wait")
	infoLbl.Text = "Esperando códigos..."
end)

print("[Code Sniper V4] Full version loaded | Black + Pink")
