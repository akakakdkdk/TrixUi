--[[
    ╔══════════════════════════════════════════╗
    ║         TRIX UI — Custom UI Library      ║
    ║       Glassmorphism · Particles · Glow   ║
    ╚══════════════════════════════════════════╝
]]

local TrixUI = {}
TrixUI.__index = TrixUI

-- ─── THEME ────────────────────────────────────
local Theme = {
    Background      = Color3.fromRGB(10, 10, 14),
    CardBG          = Color3.fromRGB(20, 20, 28),
    CardBorder      = Color3.fromRGB(45, 45, 60),
    AccentA         = Color3.fromRGB(99, 102, 241),   -- indigo
    AccentB         = Color3.fromRGB(168, 85, 247),   -- purple
    AccentC         = Color3.fromRGB(59, 130, 246),   -- blue
    Text            = Color3.fromRGB(240, 240, 245),
    TextDim         = Color3.fromRGB(140, 140, 155),
    ToggleOn        = Color3.fromRGB(99, 102, 241),
    ToggleOff       = Color3.fromRGB(50, 50, 65),
    SliderFill      = Color3.fromRGB(99, 102, 241),
    SliderTrack     = Color3.fromRGB(35, 35, 48),
    ButtonHover     = Color3.fromRGB(35, 35, 52),
    InputBG         = Color3.fromRGB(16, 16, 22),
    InputBorder     = Color3.fromRGB(55, 55, 75),
}

-- ─── UTILITIES ────────────────────────────────
local function lerp(a, b, t) return a + (b - a) * t end
local function clamp(v, mn, mx) return math.max(mn, math.min(mx, v)) end

local function shadow(parent, size, color, transparency)
    local s = Instance.new("ImageLabel")
    s.Name = "Shadow"
    s.BackgroundTransparency = 1
    s.Image = "rbxassetid://4483345875"
    s.ImageColor3 = color or Color3.new(0,0,0)
    s.ImageTransparency = transparency or 0.6
    s.Size = UDim2.new(1, size, 1, size)
    s.Position = UDim2.new(0, -size/2, 0, -size/2)
    s.ZIndex = -1
    s.Parent = parent
    return s
end

local function uiCorner(parent, rad)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, rad or 12)
    c.Parent = parent
    return c
end

local function uiPadding(parent, t, r, b, l)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, t or 8)
    p.PaddingRight  = UDim.new(0, r or 12)
    p.PaddingBottom = UDim.new(0, b or 8)
    p.PaddingLeft   = UDim.new(0, l or 12)
    p.Parent = parent
    return p
end

local function listLayout(parent, pad, dir)
    local l = Instance.new("UIListLayout")
    l.Padding = UDim.new(0, pad or 6)
    l.FillDirection = dir or Enum.FillDirection.Vertical
    l.HorizontalAlignment = Enum.HorizontalAlignment.Center
    l.VerticalAlignment = Enum.VerticalAlignment.Top
    l.Parent = parent
    return l
end

local function gridLayout(parent, colCount, cellSize, cellPad)
    local g = Instance.new("UIGridLayout")
    g.CellSize = cellSize or UDim2.new(1, 0, 0, 34)
    g.CellPadding = UDim2.new(0, cellPad or 6, 0, cellPad or 6)
    g.FillDirection = Enum.FillDirection.Horizontal
    g.HorizontalAlignment = Enum.HorizontalAlignment.Center
    g.VerticalAlignment = Enum.VerticalAlignment.Top
    g.Parent = parent
    return g
end

local function makeLabel(parent, text, size, color, font, weight)
    local l = Instance.new("TextLabel")
    l.Name = "Label"
    l.Text = text or ""
    l.TextSize = size or 13
    l.TextColor3 = color or Theme.Text
    l.Font = font or Enum.Font.GothamBold
    l.FontWeight = weight or Enum.FontWeight.Bold
    l.BackgroundTransparency = 1
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextYAlignment = Enum.TextYAlignment.Center
    l.Size = UDim2.new(1, 0, 0, size + 6)
    l.Parent = parent
    return l
end

-- ─── GLOW EFFECT ──────────────────────────────
local function addGlow(frame, color, size, transparency)
    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://4483345875"
    glow.ImageColor3 = color or Theme.AccentA
    glow.ImageTransparency = transparency or 0.65
    glow.Size = UDim2.new(1, size or 40, 1, size or 40)
    glow.Position = UDim2.new(0, -(size or 40)/2, 0, -(size or 40)/2)
    glow.ZIndex = -2
    glow.Parent = frame
    return glow
end

-- ─── ANIMATE HELPERS ──────────────────────────
local TweenService = game:GetService("TweenService")
local function tweenProp(obj, props, time, style, dir)
    local info = TweenInfo.new(time or 0.25, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
    TweenService:Create(obj, info, props):Play()
end

-- ─── PARTICLE CANVAS (ambient floating orbs) ─
local function createParticles(screenGui)
    local canvas = Instance.new("Frame")
    canvas.Name = "ParticleCanvas"
    canvas.Size = UDim2.new(1, 0, 1, 0)
    canvas.BackgroundTransparency = 1
    canvas.Parent = screenGui

    local particleCount = 12
    local particles = {}

    for i = 1, particleCount do
        local p = Instance.new("Frame")
        p.Name = "Particle_" .. i
        p.BackgroundColor3 = (i % 3 == 0) and Theme.AccentA or (i % 3 == 1) and Theme.AccentB or Theme.AccentC
        p.BorderSizePixel = 0
        local sz = math.random(3, 7)
        p.Size = UDim2.new(0, sz, 0, sz)
        p.Position = UDim2.new(math.random(), 0, math.random(), 0)
        p.Parent = canvas
        uiCorner(p, sz)

        -- UIGradient for glow feel on particle
        local grad = Instance.new("UIGradient")
        grad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, p.BackgroundColor3),
            ColorSequenceKeypoint.new(1, p.BackgroundColor3),
        })
        grad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.0),
            NumberSequenceKeypoint.new(0.5, 0.3),
            NumberSequenceKeypoint.new(1, 0.8),
        })
        grad.Parent = p

        particles[i] = {
            frame   = p,
            x       = math.random(),
            y       = math.random(),
            speedX  = (math.random() - 0.5) * 0.04,
            speedY  = (math.random() - 0.5) * 0.03,
            phase   = math.random() * math.pi * 2,
        }
    end

    local RunService = game:GetService("RunService")
    local conn
    conn = RunService.Heartbeat:Connect(function(dt)
        if not canvas or not canvas.Parent then
            conn:Disconnect()
            return
        end
        for _, pt in ipairs(particles) do
            pt.x = pt.x + pt.speedX * dt
            pt.y = pt.y + pt.speedY * dt
            if pt.x > 1.05 then pt.x = -0.05 end
            if pt.x < -0.05 then pt.x = 1.05 end
            if pt.y > 1.05 then pt.y = -0.05 end
            if pt.y < -0.05 then pt.y = 1.05 end

            local pulse = 0.85 + 0.15 * math.sin(tick() * 2 + pt.phase)
            pt.frame.Position = UDim2.new(pt.x, 0, pt.y, 0)
            pt.frame.BackgroundTransparency = 1 - pulse * 0.7
        end
    end)

    return canvas
end

-- ─── SCANLINE OVERLAY ─────────────────────────
local function createScanlines(parent)
    local scan = Instance.new("Frame")
    scan.Name = "Scanlines"
    scan.Size = UDim2.new(1, 0, 1, 0)
    scan.BackgroundTransparency = 1
    scan.Parent = parent
    scan.ZIndex = 10

    -- Using a repeating image for scanline effect
    local img = Instance.new("ImageLabel")
    img.Name = "ScanlineImage"
    img.Size = UDim2.new(1, 0, 1, 0)
    img.BackgroundTransparency = 1
    img.Image = "rbxassetid://6373401893" -- repeating horizontal lines
    img.ImageColor3 = Color3.new(0, 0, 0)
    img.ImageTransparency = 0.88
    img.Parent = scan

    return scan
end

-- ─── NOISE TEXTURE BG ─────────────────────────
local function createNoiseBG(parent)
    local noise = Instance.new("ImageLabel")
    noise.Name = "NoiseBG"
    noise.Size = UDim2.new(1, 0, 1, 0)
    noise.BackgroundTransparency = 1
    noise.Image = "rbxassetid://6373401893"
    noise.ImageColor3 = Theme.AccentA
    noise.ImageTransparency = 0.92
    noise.Parent = parent
    noise.ZIndex = -1
    return noise
end

-- ═══════════════════════════════════════════════
-- MAIN: CREATE WINDOW
-- ═══════════════════════════════════════════════
function TrixUI:CreateWindow(config)
    config = config or {}
    local windowName = config.Name or "TrixUI"

    -- ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TrixUI_ScreenGui"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Relative
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    -- Dark backdrop
    local backdrop = Instance.new("Frame")
    backdrop.Name = "Backdrop"
    backdrop.Size = UDim2.new(1, 0, 1, 0)
    backdrop.BackgroundColor3 = Theme.Background
    backdrop.BorderSizePixel = 0
    backdrop.Parent = screenGui

    -- Gradient on backdrop
    local bgGrad = Instance.new("UIGradient")
    bgGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,   Color3.fromRGB(8,  6,  18)),
        ColorSequenceKeypoint.new(0.4, Color3.fromRGB(12, 10, 24)),
        ColorSequenceKeypoint.new(1,   Color3.fromRGB(6,  8,  16)),
    })
    bgGrad.Rotation = 135
    bgGrad.Parent = backdrop

    -- Particles
    createParticles(screenGui)

    -- Scanlines
    createScanlines(screenGui)

    -- ── Main Panel ──
    local panel = Instance.new("Frame")
    panel.Name = "MainPanel"
    panel.Size = UDim2.new(0, 380, 0, 560)
    panel.Position = UDim2.new(0.5, -190, 0.5, -280)
    panel.BackgroundColor3 = Theme.CardBG
    panel.BorderSizePixel = 0
    panel.Parent = screenGui
    panel.ClipsDescendants = true
    uiCorner(panel, 18)

    -- Glass border
    local borderFrame = Instance.new("Frame")
    borderFrame.Name = "GlassBorder"
    borderFrame.Size = UDim2.new(1, 0, 1, 0)
    borderFrame.BackgroundTransparency = 1
    borderFrame.BorderSizePixel = 0
    borderFrame.Parent = panel
    do
        local stroke = Instance.new("UIStroke")
        stroke.Color = Theme.CardBorder
        stroke.Thickness = 1
        stroke.Transparency = 0.3
        stroke.Parent = borderFrame
        uiCorner(borderFrame, 18)
    end

    -- Panel bg gradient (subtle)
    local panelGrad = Instance.new("UIGradient")
    panelGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,   Color3.fromRGB(22, 21, 32)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(18, 17, 28)),
        ColorSequenceKeypoint.new(1,   Color3.fromRGB(24, 22, 34)),
    })
    panelGrad.Rotation = 180
    panelGrad.Parent = panel

    -- Glow behind panel
    addGlow(panel, Theme.AccentA, 60, 0.7)

    -- Shadow
    shadow(panel, 30, Color3.new(0,0,0), 0.5)

    -- ── Header ──
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 72)
    header.BackgroundColor3 = Color3.fromRGB(16, 15, 24)
    header.BorderSizePixel = 0
    header.Parent = panel

    -- Header bottom line (accent)
    local headerLine = Instance.new("Frame")
    headerLine.Name = "HeaderLine"
    headerLine.Size = UDim2.new(1, 0, 0, 2)
    headerLine.Position = UDim2.new(0, 0, 1, -2)
    headerLine.BackgroundColor3 = Theme.AccentA
    headerLine.BorderSizePixel = 0
    headerLine.Parent = header
    do
        local g = Instance.new("UIGradient")
        g.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0,    Theme.AccentC),
            ColorSequenceKeypoint.new(0.5,  Theme.AccentA),
            ColorSequenceKeypoint.new(1,    Theme.AccentB),
        })
        g.Parent = headerLine
    end

    -- Header content
    local headerContent = Instance.new("Frame")
    headerContent.Name = "HeaderContent"
    headerContent.Size = UDim2.new(1, 0, 1, 0)
    headerContent.BackgroundTransparency = 1
    headerContent.Parent = header
    do
        local flex = Instance.new("UIListLayout")
        flex.FillDirection = Enum.FillDirection.Horizontal
        flex.VerticalAlignment = Enum.VerticalAlignment.Center
        flex.Padding = UDim.new(0, 12)
        flex.Parent = headerContent
        uiPadding(headerContent, 0, 16, 0, 16)
    end

    -- Logo circle
    local logoBg = Instance.new("Frame")
    logoBg.Name = "LogoBG"
    logoBg.Size = UDim2.new(0, 36, 0, 36)
    logoBg.BackgroundColor3 = Theme.AccentA
    logoBg.BorderSizePixel = 0
    logoBg.Parent = headerContent
    uiCorner(logoBg, 10)
    do
        local g = Instance.new("UIGradient")
        g.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.AccentC),
            ColorSequenceKeypoint.new(1, Theme.AccentB),
        })
        g.Parent = logoBg
    end
    do
        local logoText = Instance.new("TextLabel")
        logoText.Size = UDim2.new(1, 0, 1, 0)
        logoText.Text = "✦"
        logoText.TextSize = 18
        logoText.Font = Enum.Font.GothamBold
        logoText.TextColor3 = Color3.new(1,1,1)
        logoText.BackgroundTransparency = 1
        logoText.Parent = logoBg
    end

    -- Title block
    local titleBlock = Instance.new("Frame")
    titleBlock.Name = "TitleBlock"
    titleBlock.Size = UDim2.new(1, -64, 1, 0)
    titleBlock.BackgroundTransparency = 1
    titleBlock.Parent = headerContent
    listLayout(titleBlock, 2)

    makeLabel(titleBlock, windowName, 16, Theme.Text, Enum.Font.GothamBold)
    makeLabel(titleBlock, config.Subtitle or "Custom Interface", 11, Theme.TextDim, Enum.Font.Gotham)

    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Text = "✕"
    closeBtn.TextSize = 14
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextColor3 = Theme.TextDim
    closeBtn.BackgroundColor3 = Color3.fromRGB(40, 38, 52)
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = headerContent
    uiCorner(closeBtn, 8)
    closeBtn.MouseEnter:Connect(function()
        tweenProp(closeBtn, {BackgroundColor3 = Color3.fromRGB(180, 60, 60)}, 0.2)
        tweenProp(closeBtn, {TextColor3 = Color3.new(1,1,1)}, 0.2)
    end)
    closeBtn.MouseLeave:Connect(function()
        tweenProp(closeBtn, {BackgroundColor3 = Color3.fromRGB(40, 38, 52)}, 0.2)
        tweenProp(closeBtn, {TextColor3 = Theme.TextDim}, 0.2)
    end)
    closeBtn.Activated:Connect(function()
        screenGui:Destroy()
    end)

    -- Minimize button (next to close)
    local minBtn = Instance.new("TextButton")
    minBtn.Name = "MinBtn"
    minBtn.Size = UDim2.new(0, 28, 0, 28)
    minBtn.Text = "─"
    minBtn.TextSize = 16
    minBtn.Font = Enum.Font.GothamBold
    minBtn.TextColor3 = Theme.TextDim
    minBtn.BackgroundColor3 = Color3.fromRGB(40, 38, 52)
    minBtn.BorderSizePixel = 0
    minBtn.Parent = headerContent
    uiCorner(minBtn, 8)
    local minimized = false
    local bodyRef -- will be set below
    minBtn.MouseEnter:Connect(function()
        tweenProp(minBtn, {BackgroundColor3 = Color3.fromRGB(40, 55, 75)}, 0.2)
    end)
    minBtn.MouseLeave:Connect(function()
        tweenProp(minBtn, {BackgroundColor3 = Color3.fromRGB(40, 38, 52)}, 0.2)
    end)
    minBtn.Activated:Connect(function()
        minimized = not minimized
        if bodyRef then
            if minimized then
                tweenProp(panel, {Size = UDim2.new(0, 380, 0, 72)}, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                bodyRef.Visible = false
                minBtn.Text = "▲"
            else
                bodyRef.Visible = true
                tweenProp(panel, {Size = UDim2.new(0, 380, 0, 560)}, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                minBtn.Text = "─"
            end
        end
    end)

    -- ── Tab Bar ──
    local tabBar = Instance.new("Frame")
    tabBar.Name = "TabBar"
    tabBar.Size = UDim2.new(1, 0, 0, 38)
    tabBar.BackgroundColor3 = Color3.fromRGB(14, 13, 20)
    tabBar.BorderSizePixel = 0
    tabBar.Parent = panel
    do
        local l = Instance.new("UIListLayout")
        l.FillDirection = Enum.FillDirection.Horizontal
        l.VerticalAlignment = Enum.VerticalAlignment.Center
        l.HorizontalAlignment = Enum.HorizontalAlignment.Center
        l.Padding = UDim.new(0, 4)
        l.Parent = tabBar
        uiPadding(tabBar, 0, 8, 0, 8)
    end

    -- ── Body (scrollable) ──
    local body = Instance.new("ScrollingFrame")
    body.Name = "Body"
    body.Size = UDim2.new(1, 0, 1, -110)
    body.Position = UDim2.new(0, 0, 0, 110)
    body.BackgroundTransparency = 1
    body.BorderSizePixel = 0
    body.TopImage = ""
    body.BottomImage = ""
    body.MidImage = ""
    body.ScrollBarThickness = 4
    body.Parent = panel
    bodyRef = body

    local bodyList = Instance.new("UIListLayout")
    bodyList.Padding = UDim.new(0, 8)
    bodyList.Parent = body
    uiPadding(body, 10, 12, 10, 12)

    -- ═══ WINDOW OBJECT ═══
    local window = {
        _screenGui = screenGui,
        _panel     = panel,
        _tabBar    = tabBar,
        _body      = body,
        _tabs      = {},
        _activeTab = nil,
    }

    -- ── Create Tab ──
    function window:CreateTab(name, icon)
        local tabContent = Instance.new("Frame")
        tabContent.Name = name .. "_Content"
        tabContent.Size = UDim2.new(1, 0, 0, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.Parent = body
        tabContent.Visible = false
        listLayout(tabContent, 8)
        Instance.new("UISizeConstraint", {
            MinimumSize = Vector2.new(0, 0),
            Parent = tabContent,
        })

        -- Tab button
        local tabBtn = Instance.new("TextButton")
        tabBtn.Name = name .. "_TabBtn"
        tabBtn.Size = UDim2.new(0, 0, 1, -12)
        tabBtn.Text = (icon or "") .. " " .. name
        tabBtn.TextSize = 12
        tabBtn.Font = Enum.Font.GothamBold
        tabBtn.TextColor3 = Theme.TextDim
        tabBtn.BackgroundColor3 = Color3.fromRGB(24, 23, 34)
        tabBtn.BorderSizePixel = 0
        tabBtn.AutomaticSize = Enum.AutomaticSize.X
        tabBtn.Parent = tabBar
        uiCorner(tabBtn, 8)
        uiPadding(tabBtn, 0, 14, 0, 14)

        local tabData = {
            btn     = tabBtn,
            content = tabContent,
            name    = name,
        }
        table.insert(window._tabs, tabData)

        -- Activate / deactivate visuals
        local function activateTab(data)
            data.content.Visible = true
            tweenProp(data.btn, {BackgroundColor3 = Theme.AccentA}, 0.2)
            tweenProp(data.btn, {TextColor3 = Color3.new(1,1,1)}, 0.2)
        end
        local function deactivateTab(data)
            data.content.Visible = false
            tweenProp(data.btn, {BackgroundColor3 = Color3.fromRGB(24, 23, 34)}, 0.2)
            tweenProp(data.btn, {TextColor3 = Theme.TextDim}, 0.2)
        end

        tabBtn.Activated:Connect(function()
            for _, t in ipairs(window._tabs) do
                deactivateTab(t)
            end
            activateTab(tabData)
            window._activeTab = tabData
        end)

        -- Auto-select first tab
        if #window._tabs == 1 then
            task.defer(function()
                activateTab(tabData)
                window._activeTab = tabData
            end)
        end

        -- ── Tab object ──
        local tab = { _content = tabContent }

        -- ─── SECTION HEADER ──
        function tab:CreateSection(title)
            local sec = Instance.new("Frame")
            sec.Name = "Section"
            sec.Size = UDim2.new(1, 0, 0, 24)
            sec.BackgroundTransparency = 1
            sec.Parent = tabContent

            local line = Instance.new("Frame")
            line.Name = "SectionLine"
            line.Size = UDim2.new(0, 20, 0, 2)
            line.Position = UDim2.new(0, 0, 0.5, -1)
            line.BackgroundColor3 = Theme.AccentA
            line.BorderSizePixel = 0
            line.Parent = sec

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -28, 1, 0)
            lbl.Position = UDim2.new(0, 26, 0, 0)
            lbl.Text = title or "Section"
            lbl.TextSize = 11
            lbl.Font = Enum.Font.GothamBold
            lbl.TextColor3 = Theme.AccentA
            lbl.BackgroundTransparency = 1
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = sec
            return sec
        end

        -- ─── TOGGLE ──
        function tab:CreateToggle(config)
            config = config or {}
            local value = config.CurrentValue or false

            local card = Instance.new("Frame")
            card.Name = "Toggle_" .. (config.Name or "")
            card.Size = UDim2.new(1, 0, 0, 42)
            card.BackgroundColor3 = Theme.CardBG
            card.BorderSizePixel = 0
            card.Parent = tabContent
            uiCorner(card, 10)
            do
                local s = Instance.new("UIStroke")
                s.Color = Theme.CardBorder
                s.Thickness = 1
                s.Transparency = 0.5
                s.Parent = card
            end

            -- Label
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -60, 1, 0)
            lbl.Text = config.Name or "Toggle"
            lbl.TextSize = 13
            lbl.Font = Enum.Font.GothamBold
            lbl.TextColor3 = Theme.Text
            lbl.BackgroundTransparency = 1
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = card
            uiPadding(lbl, 0, 0, 0, 14)

            -- Track
            local track = Instance.new("Frame")
            track.Name = "Track"
            track.Size = UDim2.new(0, 44, 0, 24)
            track.Position = UDim2.new(1, -56, 0.5, -12)
            track.BackgroundColor3 = value and Theme.ToggleOn or Theme.ToggleOff
            track.BorderSizePixel = 0
            track.Parent = card
            uiCorner(track, 12)

            -- Knob
            local knob = Instance.new("Frame")
            knob.Name = "Knob"
            knob.Size = UDim2.new(0, 20, 0, 20)
            knob.Position = value and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
            knob.BackgroundColor3 = Color3.new(1,1,1)
            knob.BorderSizePixel = 0
            knob.Parent = track
            uiCorner(knob, 10)
            shadow(knob, 6, Color3.new(0,0,0), 0.4)

            -- Glow on knob when on
            local knobGlow = addGlow(knob, Theme.AccentA, 12, value and 0.6 or 1.0)

            -- Click area
            local clickArea = Instance.new("TextButton")
            clickArea.Size = UDim2.new(1, 0, 1, 0)
            clickArea.BackgroundTransparency = 1
            clickArea.Text = ""
            clickArea.Parent = card

            clickArea.Activated:Connect(function()
                value = not value
                tweenProp(track, {BackgroundColor3 = value and Theme.ToggleOn or Theme.ToggleOff}, 0.25)
                tweenProp(knob, {Position = value and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)}, 0.25)
                tweenProp(knobGlow, {ImageTransparency = value and 0.6 or 1.0}, 0.25)
                if config.Callback then config.Callback(value) end
            end)

            -- Hover
            card.MouseEnter:Connect(function()
                tweenProp(card, {BackgroundColor3 = Theme.ButtonHover}, 0.15)
            end)
            card.MouseLeave:Connect(function()
                tweenProp(card, {BackgroundColor3 = Theme.CardBG}, 0.15)
            end)

            return {
                Set = function(self, val)
                    value = val
                    tweenProp(track, {BackgroundColor3 = value and Theme.ToggleOn or Theme.ToggleOff}, 0.25)
                    tweenProp(knob, {Position = value and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)}, 0.25)
                    tweenProp(knobGlow, {ImageTransparency = value and 0.6 or 1.0}, 0.25)
                    if config.Callback then config.Callback(value) end
                end,
                Get = function() return value end,
            }
        end

        -- ─── BUTTON ──
        function tab:CreateButton(config)
            config = config or {}

            local card = Instance.new("TextButton")
            card.Name = "Button_" .. (config.Name or "")
            card.Size = UDim2.new(1, 0, 0, 40)
            card.Text = config.Name or "Button"
            card.TextSize = 13
            card.Font = Enum.Font.GothamBold
            card.TextColor3 = Color3.new(1,1,1)
            card.BackgroundColor3 = Theme.AccentA
            card.BorderSizePixel = 0
            card.Parent = tabContent
            uiCorner(card, 10)

            -- Gradient on button
            do
                local g = Instance.new("UIGradient")
                g.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Theme.AccentC),
                    ColorSequenceKeypoint.new(1, Theme.AccentB),
                })
                g.Rotation = 90
                g.Parent = card
            end

            shadow(card, 8, Theme.AccentA, 0.55)

            -- Press animation
            card.Activated:Connect(function()
                tweenProp(card, {Size = UDim2.new(1, -6, 0, 38)}, 0.08)
                tweenProp(card, {Position = UDim2.new(0, 3, 0, 1)}, 0.08)
                task.wait(0.1)
                tweenProp(card, {Size = UDim2.new(1, 0, 0, 40)}, 0.12)
                tweenProp(card, {Position = UDim2.new(0, 0, 0, 0)}, 0.12)
                if config.Callback then config.Callback() end
            end)

            card.MouseEnter:Connect(function()
                tweenProp(card, {BackgroundColor3 = Color3.fromRGB(115, 118, 255)}, 0.15)
            end)
            card.MouseLeave:Connect(function()
                tweenProp(card, {BackgroundColor3 = Theme.AccentA}, 0.15)
            end)

            return card
        end

        -- ─── SLIDER ──
        function tab:CreateSlider(config)
            config = config or {}
            local min   = config.Min or 0
            local max   = config.Max or 100
            local value = config.CurrentValue or min
            local step  = config.Step or 1

            local card = Instance.new("Frame")
            card.Name = "Slider_" .. (config.Name or "")
            card.Size = UDim2.new(1, 0, 0, 56)
            card.BackgroundColor3 = Theme.CardBG
            card.BorderSizePixel = 0
            card.Parent = tabContent
            uiCorner(card, 10)
            do
                local s = Instance.new("UIStroke")
                s.Color = Theme.CardBorder
                s.Thickness = 1
                s.Transparency = 0.5
                s.Parent = card
            end

            -- Label row
            local labelRow = Instance.new("Frame")
            labelRow.Size = UDim2.new(1, 0, 0, 24)
            labelRow.BackgroundTransparency = 1
            labelRow.Parent = card
            uiPadding(labelRow, 8, 14, 0, 14)

            local nameLbl = Instance.new("TextLabel")
            nameLbl.Size = UDim2.new(1, -50, 1, 0)
            nameLbl.Text = config.Name or "Slider"
            nameLbl.TextSize = 13
            nameLbl.Font = Enum.Font.GothamBold
            nameLbl.TextColor3 = Theme.Text
            nameLbl.BackgroundTransparency = 1
            nameLbl.TextXAlignment = Enum.TextXAlignment.Left
            nameLbl.Parent = labelRow

            local valLbl = Instance.new("TextLabel")
            valLbl.Size = UDim2.new(0, 44, 1, 0)
            valLbl.Position = UDim2.new(1, -44, 0, 0)
            valLbl.Text = tostring(value)
            valLbl.TextSize = 12
            valLbl.Font = Enum.Font.GothamBold
            valLbl.TextColor3 = Theme.AccentA
            valLbl.BackgroundTransparency = 1
            valLbl.TextXAlignment = Enum.TextXAlignment.Right
            valLbl.Parent = labelRow

            -- Track
            local track = Instance.new("Frame")
            track.Name = "SliderTrack"
            track.Size = UDim2.new(1, -28, 0, 4)
            track.Position = UDim2.new(0, 14, 1, -18)
            track.BackgroundColor3 = Theme.SliderTrack
            track.BorderSizePixel = 0
            track.Parent = card
            uiCorner(track, 2)

            -- Fill
            local pct = (value - min) / (max - min)
            local fill = Instance.new("Frame")
            fill.Name = "SliderFill"
            fill.Size = UDim2.new(pct, 0, 1, 0)
            fill.BackgroundColor3 = Theme.SliderFill
            fill.BorderSizePixel = 0
            fill.Parent = track
            uiCorner(fill, 2)
            do
                local g = Instance.new("UIGradient")
                g.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Theme.AccentC),
                    ColorSequenceKeypoint.new(1, Theme.AccentB),
                })
                g.Parent = fill
            end

            -- Knob
            local knob = Instance.new("Frame")
            knob.Name = "SliderKnob"
            knob.Size = UDim2.new(0, 18, 0, 18)
            knob.Position = UDim2.new(pct, -9, 0.5, -9)
            knob.BackgroundColor3 = Color3.new(1,1,1)
            knob.BorderSizePixel = 0
            knob.Parent = track
            uiCorner(knob, 9)
            shadow(knob, 4, Color3.new(0,0,0), 0.3)
            addGlow(knob, Theme.AccentA, 8, 0.6)

            -- Drag logic
            local dragging = false
            local UIS = game:GetService("UserInputService")

            local function updateSlider(mousePos)
                local trackPos = track.AbsolutePosition
                local trackSize = track.AbsoluteSize
                local relX = clamp((mousePos.X - trackPos.X) / trackSize.X, 0, 1)
                local raw = min + relX * (max - min)
                value = math.round(raw / step) * step
                value = clamp(value, min, max)
                local p = (value - min) / (max - min)
                fill.Size = UDim2.new(p, 0, 1, 0)
                knob.Position = UDim2.new(p, -9, 0.5, -9)
                valLbl.Text = tostring(value)
                if config.Callback then config.Callback(value) end
            end

            knob.InputBegan:Connect(function(inp, consumed)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                end
            end)
            UIS.InputChanged:Connect(function(inp)
                if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
                    updateSlider(inp.Position)
                end
            end)
            UIS.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)

            card.MouseEnter:Connect(function()
                tweenProp(card, {BackgroundColor3 = Theme.ButtonHover}, 0.15)
            end)
            card.MouseLeave:Connect(function()
                tweenProp(card, {BackgroundColor3 = Theme.CardBG}, 0.15)
            end)

            return {
                Set = function(self, v)
                    value = clamp(v, min, max)
                    local p = (value - min) / (max - min)
                    fill.Size = UDim2.new(p, 0, 1, 0)
                    knob.Position = UDim2.new(p, -9, 0.5, -9)
                    valLbl.Text = tostring(value)
                    if config.Callback then config.Callback(value) end
                end,
                Get = function() return value end,
            }
        end

        -- ─── INPUT ──
        function tab:CreateInput(config)
            config = config or {}

            local card = Instance.new("Frame")
            card.Name = "Input_" .. (config.Name or "")
            card.Size = UDim2.new(1, 0, 0, 42)
            card.BackgroundColor3 = Theme.CardBG
            card.BorderSizePixel = 0
            card.Parent = tabContent
            uiCorner(card, 10)
            do
                local s = Instance.new("UIStroke")
                s.Color = Theme.CardBorder
                s.Thickness = 1
                s.Transparency = 0.5
                s.Parent = card
            end

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(0.4, -6, 1, 0)
            lbl.Text = config.Name or "Input"
            lbl.TextSize = 13
            lbl.Font = Enum.Font.GothamBold
            lbl.TextColor3 = Theme.Text
            lbl.BackgroundTransparency = 1
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = card
            uiPadding(lbl, 0, 0, 0, 14)

            local inputBox = Instance.new("TextBox")
            inputBox.Size = UDim2.new(0.6, -14, 0.7, 0)
            inputBox.Position = UDim2.new(0.4, 0, 0.15, 0)
            inputBox.Text = config.DefaultValue or ""
            inputBox.PlaceholderText = config.PlaceholderText or "..."
            inputBox.TextSize = 13
            inputBox.Font = Enum.Font.Gotham
            inputBox.TextColor3 = Theme.Text
            inputBox.PlaceholderColor3 = Theme.TextDim
            inputBox.BackgroundColor3 = Theme.InputBG
            inputBox.BorderSizePixel = 0
            inputBox.ClearTextOnFocus = false
            inputBox.TextXAlignment = Enum.TextXAlignment.Left
            inputBox.Parent = card
            uiCorner(inputBox, 8)
            do
                local s = Instance.new("UIStroke")
                s.Color = Theme.InputBorder
                s.Thickness = 1
                s.Parent = inputBox
            end
            uiPadding(inputBox, 0, 8, 0, 10)

            -- Focus glow
            inputBox.FocusedEvent:Connect(function()
                tweenProp(inputBox, {BackgroundColor3 = Color3.fromRGB(22, 22, 34)}, 0.2)
            end)
            inputBox.FocusLostEvent:Connect(function(submitted)
                tweenProp(inputBox, {BackgroundColor3 = Theme.InputBG}, 0.2)
                if config.Callback then config.Callback(inputBox.Text, submitted) end
            end)

            return {
                Get = function() return inputBox.Text end,
                Set = function(self, v) inputBox.Text = v end,
            }
        end

        -- ─── KEYBIND ──
        function tab:CreateKeybind(config)
            config = config or {}
            local currentKey = config.CurrentKeybind or "None"

            local card = Instance.new("Frame")
            card.Name = "Keybind_" .. (config.Name or "")
            card.Size = UDim2.new(1, 0, 0, 42)
            card.BackgroundColor3 = Theme.CardBG
            card.BorderSizePixel = 0
            card.Parent = tabContent
            uiCorner(card, 10)
            do
                local s = Instance.new("UIStroke")
                s.Color = Theme.CardBorder
                s.Thickness = 1
                s.Transparency = 0.5
                s.Parent = card
            end

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -100, 1, 0)
            lbl.Text = config.Name or "Keybind"
            lbl.TextSize = 13
            lbl.Font = Enum.Font.GothamBold
            lbl.TextColor3 = Theme.Text
            lbl.BackgroundTransparency = 1
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = card
            uiPadding(lbl, 0, 0, 0, 14)

            local keyBtn = Instance.new("TextButton")
            keyBtn.Size = UDim2.new(0, 80, 0.6, 0)
            keyBtn.Position = UDim2.new(1, -92, 0.2, 0)
            keyBtn.Text = currentKey
            keyBtn.TextSize = 12
            keyBtn.Font = Enum.Font.GothamBold
            keyBtn.TextColor3 = Theme.AccentA
            keyBtn.BackgroundColor3 = Color3.fromRGB(30, 29, 42)
            keyBtn.BorderSizePixel = 0
            keyBtn.Parent = card
            uiCorner(keyBtn, 6)
            do
                local s = Instance.new("UIStroke")
                s.Color = Theme.AccentA
                s.Thickness = 1
                s.Transparency = 0.4
                s.Parent = keyBtn
            end

            local listening = false

            keyBtn.Activated:Connect(function()
                if listening then return end
                listening = true
                keyBtn.Text = "..."
                tweenProp(keyBtn, {BackgroundColor3 = Color3.fromRGB(50, 40, 70)}, 0.15)

                local conn
                conn = game:GetService("UserInputService").InputBegan:Connect(function(inp, gameProcessed)
                    if inp.KeyCode ~= Enum.KeyCode.Unknown then
                        currentKey = inp.KeyCode.Name
                        keyBtn.Text = currentKey
                        tweenProp(keyBtn, {BackgroundColor3 = Color3.fromRGB(30, 29, 42)}, 0.15)
                        conn:Disconnect()
                        listening = false
                        if config.Callback then config.Callback(inp.KeyCode) end
                    end
                end)
            end)

            card.MouseEnter:Connect(function()
                tweenProp(card, {BackgroundColor3 = Theme.ButtonHover}, 0.15)
            end)
            card.MouseLeave:Connect(function()
                tweenProp(card, {BackgroundColor3 = Theme.CardBG}, 0.15)
            end)

            return {
                Set = function(self, v)
                    currentKey = v
                    keyBtn.Text = v
                end,
                Get = function() return currentKey end,
            }
        end

        -- ─── COLOR PICKER (simplified) ──
        function tab:CreateColorPicker(config)
            config = config or {}
            local currentColor = config.Color or Color3.fromRGB(255, 0, 0)

            local card = Instance.new("Frame")
            card.Name = "ColorPicker_" .. (config.Name or "")
            card.Size = UDim2.new(1, 0, 0, 42)
            card.BackgroundColor3 = Theme.CardBG
            card.BorderSizePixel = 0
            card.Parent = tabContent
            uiCorner(card, 10)
            do
                local s = Instance.new("UIStroke")
                s.Color = Theme.CardBorder
                s.Thickness = 1
                s.Transparency = 0.5
                s.Parent = card
            end

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -60, 1, 0)
            lbl.Text = config.Name or "Color"
            lbl.TextSize = 13
            lbl.Font = Enum.Font.GothamBold
            lbl.TextColor3 = Theme.Text
            lbl.BackgroundTransparency = 1
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = card
            uiPadding(lbl, 0, 0, 0, 14)

            local swatch = Instance.new("TextButton")
            swatch.Size = UDim2.new(0, 34, 0, 24)
            swatch.Position = UDim2.new(1, -46, 0.5, -12)
            swatch.BackgroundColor3 = currentColor
            swatch.Text = ""
            swatch.BorderSizePixel = 0
            swatch.Parent = card
            uiCorner(swatch, 6)
            do
                local s = Instance.new("UIStroke")
                s.Color = Color3.new(1,1,1)
                s.Thickness = 2
                s.Transparency = 0.3
                s.Parent = swatch
            end

            -- Simple preset colors popup
            local presets = {
                Color3.fromRGB(255, 0, 0),
                Color3.fromRGB(255, 100, 0),
                Color3.fromRGB(255, 255, 0),
                Color3.fromRGB(0, 255, 0),
                Color3.fromRGB(0, 200, 255),
                Color3.fromRGB(0, 0, 255),
                Color3.fromRGB(180, 0, 255),
                Color3.fromRGB(255, 0, 180),
                Color3.fromRGB(255, 255, 255),
                Color3.fromRGB(150, 150, 150),
            }

            local popup = Instance.new("Frame")
            popup.Name = "ColorPopup"
            popup.Size = UDim2.new(0, 160, 0, 80)
            popup.Position = UDim2.new(0.5, -80, 1, 6)
            popup.BackgroundColor3 = Color3.fromRGB(18, 17, 26)
            popup.BorderSizePixel = 0
            popup.Visible = false
            popup.Parent = card
            uiCorner(popup, 10)
            do
                local s = Instance.new("UIStroke")
                s.Color = Theme.CardBorder
                s.Thickness = 1
                s.Parent = popup
            end
            shadow(popup, 12, Color3.new(0,0,0), 0.5)
            uiPadding(popup, 10, 10, 10, 10)

            local grid = Instance.new("UIGridLayout")
            grid.CellSize = UDim2.new(0, 26, 0, 26)
            grid.CellPadding = UDim2.new(0, 4, 0, 4)
            grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
            grid.Parent = popup

            for _, col in ipairs(presets) do
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(0, 26, 0, 26)
                btn.BackgroundColor3 = col
                btn.Text = ""
                btn.BorderSizePixel = 0
                btn.Parent = popup
                uiCorner(btn, 6)

                btn.Activated:Connect(function()
                    currentColor = col
                    swatch.BackgroundColor3 = col
                    popup.Visible = false
                    if config.Callback then config.Callback(col) end
                end)

                btn.MouseEnter:Connect(function()
                    tweenProp(btn, {Size = UDim2.new(0, 28, 0, 28)}, 0.1)
                end)
                btn.MouseLeave:Connect(function()
                    tweenProp(btn, {Size = UDim2.new(0, 26, 0, 26)}, 0.1)
                end)
            end

            swatch.Activated:Connect(function()
                popup.Visible = not popup.Visible
            end)

            -- Close popup on outside click
            game:GetService("UserInputService").InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    task.defer(function()
                        if popup.Visible then
                            popup.Visible = false
                        end
                    end)
                end
            end)

            return {
                Set = function(self, c)
                    currentColor = c
                    swatch.BackgroundColor3 = c
                end,
                Get = function() return currentColor end,
            }
        end

        -- ─── NOTIFY ──
        function window:Notify(config)
            config = config or {}
            local dur = config.Duration or 3

            local notif = Instance.new("Frame")
            notif.Name = "Notification"
            notif.Size = UDim2.new(0, 280, 0, 0)
            notif.Position = UDim2.new(0.5, -140, 0, -80)
            notif.BackgroundColor3 = Color3.fromRGB(20, 19, 30)
            notif.BorderSizePixel = 0
            notif.AutomaticSize = Enum.AutomaticSize.Y
            notif.Parent = screenGui
            uiCorner(notif, 12)
            do
                local s = Instance.new("UIStroke")
                s.Color = Theme.AccentA
                s.Thickness = 1
                s.Transparency = 0.3
                s.Parent = notif
            end
            shadow(notif, 16, Color3.new(0,0,0), 0.5)
            addGlow(notif, Theme.AccentA, 30, 0.75)
            uiPadding(notif, 14, 18, 14, 18)

            local titleLbl = Instance.new("TextLabel")
            titleLbl.Size = UDim2.new(1, 0, 0, 18)
            titleLbl.Text = config.Title or "Notice"
            titleLbl.TextSize = 14
            titleLbl.Font = Enum.Font.GothamBold
            titleLbl.TextColor3 = Theme.AccentA
            titleLbl.BackgroundTransparency = 1
            titleLbl.TextXAlignment = Enum.TextXAlignment.Left
            titleLbl.Parent = notif

            local contentLbl = Instance.new("TextLabel")
            contentLbl.Size = UDim2.new(1, 0, 0, 40)
            contentLbl.Text = config.Content or ""
            contentLbl.TextSize = 12
            contentLbl.Font = Enum.Font.Gotham
            contentLbl.TextColor3 = Theme.TextDim
            contentLbl.BackgroundTransparency = 1
            contentLbl.TextXAlignment = Enum.TextXAlignment.Left
            contentLbl.TextWrapped = true
            contentLbl.Parent = notif

            -- Slide in
            notif.Position = UDim2.new(0.5, -140, 0, -80)
            task.defer(function()
                tweenProp(notif, {Position = UDim2.new(0.5, -140, 0, 20)}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            end)

            -- Auto dismiss
            task.delay(dur, function()
                tweenProp(notif, {Position = UDim2.new(0.5, -140, 0, -80)}, 0.3)
                tweenProp(notif, {BackgroundTransparency = 1}, 0.3)
                task.wait(0.35)
                if notif and notif.Parent then notif:Destroy() end
            end)
        end

        return tab
    end

    -- Notify on window object
    function window:Notify(config)
        config = config or {}
        local dur = config.Duration or 3

        local notif = Instance.new("Frame")
        notif.Name = "Notification"
        notif.Size = UDim2.new(0, 280, 0, 0)
        notif.Position = UDim2.new(0.5, -140, 0, -80)
        notif.BackgroundColor3 = Color3.fromRGB(20, 19, 30)
        notif.BorderSizePixel = 0
        notif.AutomaticSize = Enum.AutomaticSize.Y
        notif.Parent = screenGui
        uiCorner(notif, 12)
        do
            local s = Instance.new("UIStroke")
            s.Color = Theme.AccentA
            s.Thickness = 1
            s.Transparency = 0.3
            s.Parent = notif
        end
        shadow(notif, 16, Color3.new(0,0,0), 0.5)
        addGlow(notif, Theme.AccentA, 30, 0.75)
        uiPadding(notif, 14, 18, 14, 18)

        local titleLbl = Instance.new("TextLabel")
        titleLbl.Size = UDim2.new(1, 0, 0, 18)
        titleLbl.Text = config.Title or "Notice"
        titleLbl.TextSize = 14
        titleLbl.Font = Enum.Font.GothamBold
        titleLbl.TextColor3 = Theme.AccentA
        titleLbl.BackgroundTransparency = 1
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left
        titleLbl.Parent = notif

        local contentLbl = Instance.new("TextLabel")
        contentLbl.Size = UDim2.new(1, 0, 0, 40)
        contentLbl.Text = config.Content or ""
        contentLbl.TextSize = 12
        contentLbl.Font = Enum.Font.Gotham
        contentLbl.TextColor3 = Theme.TextDim
        contentLbl.BackgroundTransparency = 1
        contentLbl.TextXAlignment = Enum.TextXAlignment.Left
        contentLbl.TextWrapped = true
        contentLbl.Parent = notif

        notif.Position = UDim2.new(0.5, -140, 0, -80)
        task.defer(function()
            tweenProp(notif, {Position = UDim2.new(0.5, -140, 0, 20)}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        end)

        task.delay(dur, function()
            tweenProp(notif, {Position = UDim2.new(0.5, -140, 0, -80)}, 0.3)
            task.wait(0.35)
            if notif and notif.Parent then notif:Destroy() end
        end)
    end

    -- ── Entrance animation ──
    panel.Size = UDim2.new(0, 380, 0, 0)
    panel.BackgroundTransparency = 1
    task.defer(function()
        tweenProp(panel, {Size = UDim2.new(0, 380, 0, 560), BackgroundTransparency = 0}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end)

    -- ── Draggable ──
    local dragging2, dragOffset2
    local UIS2 = game:GetService("UserInputService")
    header.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging2 = true
            dragOffset2 = inp.Position - panel.AbsolutePosition
        end
    end)
    UIS2.InputChanged:Connect(function(inp)
        if dragging2 then
            panel.Position = UDim2.new(0, inp.Position.X - dragOffset2.X, 0, inp.Position.Y - dragOffset2.Y)
        end
    end)
    UIS2.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging2 = false
        end
    end)

    return window
end

return TrixUI
