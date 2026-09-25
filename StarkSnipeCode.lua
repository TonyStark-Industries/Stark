--[[
    CURSED HUB - Tony Stark Edition
    GUI estilo Arc Reactor (negro + azul neón)
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Limpiar GUI anterior si existe
if playerGui:FindFirstChild("CursedStarkGUI") then
    playerGui.CursedStarkGUI:Destroy()
end

-- ======================
-- COLORES TONY STARK
-- ======================
local Theme = {
    Background     = Color3.fromRGB(8, 10, 16),      -- Negro casi puro
    Background2    = Color3.fromRGB(12, 16, 26),     -- Azul muy oscuro
    Card           = Color3.fromRGB(16, 20, 32),
    Accent         = Color3.fromRGB(0, 180, 255),    -- Azul neón
    AccentDark     = Color3.fromRGB(0, 110, 180),
    Text           = Color3.fromRGB(230, 240, 255),
    Dim            = Color3.fromRGB(120, 140, 170),
    Success        = Color3.fromRGB(0, 220, 160),
    Error          = Color3.fromRGB(255, 70, 90),
    Glow           = Color3.fromRGB(0, 200, 255),
}

-- ======================
-- UTILIDADES
-- ======================
local function tween(obj, props, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props):Play()
end

local function corner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 12)
    c.Parent = obj
    return c
end

local function stroke(obj, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Accent
    s.Thickness = thickness or 1.5
    s.Transparency = transparency or 0.3
    s.Parent = obj
    return s
end

local function create(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        obj[k] = v
    end
    if parent then obj.Parent = parent end
    return obj
end

-- ======================
-- GUI PRINCIPAL
-- ======================
local GUI = create("ScreenGui", {
    Name = "CursedStarkGUI",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, playerGui)

-- Escala global
local Scale = create("UIScale", {Scale = 1}, GUI)

-- ======================
-- LAUNCHER (botón flotante estilo Arc Reactor)
-- ======================
local Launcher = create("Frame", {
    Name = "Launcher",
    Size = UDim2.fromOffset(64, 64),
    Position = UDim2.new(0, 30, 0.5, -32),
    BackgroundColor3 = Theme.Background,
    BorderSizePixel = 0,
}, GUI)
corner(Launcher, 32)
stroke(Launcher, Theme.Accent, 2, 0.2)

-- Círculo interior (Arc Reactor)
local ReactorCore = create("Frame", {
    Size = UDim2.fromOffset(36, 36),
    Position = UDim2.new(0.5, -18, 0.5, -18),
    BackgroundColor3 = Theme.Accent,
    BorderSizePixel = 0,
}, Launcher)
corner(ReactorCore, 18)

local ReactorInner = create("Frame", {
    Size = UDim2.fromOffset(18, 18),
    Position = UDim2.new(0.5, -9, 0.5, -9),
    BackgroundColor3 = Theme.Background,
    BorderSizePixel = 0,
}, ReactorCore)
corner(ReactorInner, 9)

-- Brillo del reactor
local ReactorGlow = create("ImageLabel", {
    Size = UDim2.fromOffset(80, 80),
    Position = UDim2.new(0.5, -40, 0.5, -40),
    BackgroundTransparency = 1,
    Image = "rbxassetid://5028857084", -- glow circular
    ImageColor3 = Theme.Accent,
    ImageTransparency = 0.6,
    ZIndex = 0,
}, Launcher)

-- Animación del reactor
task.spawn(function()
    while Launcher and Launcher.Parent do
        tween(ReactorCore, {BackgroundColor3 = Color3.fromRGB(0, 220, 255)}, 0.8)
        task.wait(0.8)
        tween(ReactorCore, {BackgroundColor3 = Theme.Accent}, 0.8)
        task.wait(0.8)
    end
end)

-- ======================
-- VENTANA PRINCIPAL
-- ======================
local Window = create("Frame", {
    Name = "MainWindow",
    Size = UDim2.fromOffset(420, 520),
    Position = UDim2.new(0.5, -210, 0.5, -260),
    BackgroundColor3 = Theme.Background,
    BorderSizePixel = 0,
    Visible = false,
}, GUI)
corner(Window, 18)
stroke(Window, Theme.Accent, 1.8, 0.25)

-- Gradiente sutil de fondo
local bgGradient = create("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 14, 24)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(6, 8, 14))
    }),
    Rotation = 90,
}, Window)

-- ======================
-- HEADER
-- ======================
local Header = create("Frame", {
    Size = UDim2.new(1, 0, 0, 58),
    BackgroundColor3 = Theme.Background2,
    BorderSizePixel = 0,
}, Window)
corner(Header, 18)

-- Arreglar esquinas inferiores del header
create("Frame", {
    Size = UDim2.new(1, 0, 0, 20),
    Position = UDim2.new(0, 0, 1, -20),
    BackgroundColor3 = Theme.Background2,
    BorderSizePixel = 0,
}, Header)

-- Logo Arc Reactor pequeño en el header
local HeaderReactor = create("Frame", {
    Size = UDim2.fromOffset(28, 28),
    Position = UDim2.fromOffset(16, 15),
    BackgroundColor3 = Theme.Accent,
    BorderSizePixel = 0,
}, Header)
corner(HeaderReactor, 14)

create("Frame", {
    Size = UDim2.fromOffset(12, 12),
    Position = UDim2.new(0.5, -6, 0.5, -6),
    BackgroundColor3 = Theme.Background2,
    BorderSizePixel = 0,
}, HeaderReactor).UICorner = Instance.new("UICorner", HeaderReactor:FindFirstChildOfClass("Frame") or HeaderReactor)
-- (simplificado)

local Title = create("TextLabel", {
    Size = UDim2.fromOffset(200, 28),
    Position = UDim2.fromOffset(54, 8),
    BackgroundTransparency = 1,
    Text = "CURSED  //  STARK",
    TextColor3 = Theme.Text,
    TextSize = 16,
    Font = Enum.Font.GothamBlack,
    TextXAlignment = Enum.TextXAlignment.Left,
}, Header)

local SubTitle = create("TextLabel", {
    Size = UDim2.fromOffset(200, 16),
    Position = UDim2.fromOffset(54, 32),
    BackgroundTransparency = 1,
    Text = "ARC REACTOR PROTOCOL",
    TextColor3 = Theme.Accent,
    TextSize = 10,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
}, Header)

-- Botón cerrar
local CloseBtn = create("TextButton", {
    Size = UDim2.fromOffset(32, 32),
    Position = UDim2.new(1, -44, 0.5, -16),
    BackgroundColor3 = Color3.fromRGB(30, 20, 25),
    Text = "✕",
    TextColor3 = Theme.Error,
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
}, Header)
corner(CloseBtn, 8)
stroke(CloseBtn, Theme.Error, 1, 0.5)

-- ======================
-- CONTENIDO (ejemplo)
-- ======================
local Body = create("Frame", {
    Size = UDim2.new(1, -24, 1, -80),
    Position = UDim2.fromOffset(12, 68),
    BackgroundTransparency = 1,
}, Window)

-- Ejemplo de tarjeta
local function createCard(title, desc, y)
    local card = create("Frame", {
        Size = UDim2.new(1, 0, 0, 70),
        Position = UDim2.fromOffset(0, y),
        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0,
    }, Body)
    corner(card, 14)
    stroke(card, Theme.Accent, 1, 0.7)

    create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 24),
        Position = UDim2.fromOffset(16, 12),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.Text,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, card)

    create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.fromOffset(16, 36),
        BackgroundTransparency = 1,
        Text = desc,
        TextColor3 = Theme.Dim,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, card)

    return card
end

createCard("CODE SNIPER", "Captura automática de códigos", 0)
createCard("RIDDLE SOLVER", "Base de datos offline + IA", 82)
createCard("AUTO SUBMIT", "Canjea al completar fragmentos", 164)

-- ======================
-- INTERACCIONES
-- ======================
local menuOpen = false

local function toggleMenu()
    menuOpen = not menuOpen
    if menuOpen then
        Window.Visible = true
        Window.Size = UDim2.fromOffset(420, 40)
        tween(Window, {Size = UDim2.fromOffset(420, 520)}, 0.35)
    else
        tween(Window, {Size = UDim2.fromOffset(420, 40)}, 0.25)
        task.delay(0.25, function()
            if not menuOpen then Window.Visible = false end
        end)
    end
end

Launcher.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        toggleMenu()
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    toggleMenu()
end)

-- Arrastrar la ventana
local dragging, dragStart, startPos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Window.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

print("[CURSED STARK] GUI estilo Tony Stark cargada")
