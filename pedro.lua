local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local CATALOG_URL = "https://raw.githubusercontent.com/NonyH/universalh3xa/refs/heads/main/loaders.lua"

local function new(class, props)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do
        o[k] = v
    end
    return o
end

local function round(obj, px)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, px or 12)
    c.Parent = obj
    return c
end

local function stroke(obj, transparency)
    local s = Instance.new("UIStroke")
    s.Color = Color3.new(1, 1, 1)
    s.Transparency = transparency or 0.9
    s.Thickness = 1
    s.Parent = obj
    return s
end

local function clampDescription(text)
    text = tostring(text or "")
    if #text <= 100 then
        return text
    end
    return string.sub(text, 1, 97) .. "..."
end

local function fallbackDescription(data)
    local title = tostring(data.Title or "Script")
    local lower = string.lower(title)

    if string.find(lower, "boat", 1, true) then
        return "Script diseñado para Build A Boat For Treasure."
    elseif string.find(lower, "h3x4", 1, true) then
        return "Script universal con herramientas y funciones para múltiples juegos."
    end

    return "Script disponible en el cargador universal H3X4."
end

local parent = Player:WaitForChild("PlayerGui")
if typeof(gethui) == "function" then
    local ok, p = pcall(gethui)
    if ok and p then
        parent = p
    end
end

local old = parent:FindFirstChild("H3X4UniversalLoader")
if old then
    old:Destroy()
end

local gui = new("ScreenGui", {
    Name = "H3X4UniversalLoader",
    IgnoreGuiInset = true,
    ResetOnSpawn = false,
    DisplayOrder = 999999,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = parent,
})

local overlay = new("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.new(0, 0, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 1,
    Parent = gui,
})

local main = new("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(420, 330),
    BackgroundColor3 = Color3.new(0, 0, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    ZIndex = 2,
    Parent = gui,
})
round(main, 16)

local scale = new("UIScale", {
    Scale = 0.82,
    Parent = main,
})

-- Fondo galaxia: negro puro + muchas estrellas blancas con movimiento lento y aleatorio.
local galaxy = new("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.new(0, 0, 0),
    BorderSizePixel = 0,
    ClipsDescendants = true,
    ZIndex = 2,
    Parent = main,
})
round(galaxy, 16)

local function animateStar(star)
    if not star or not star.Parent or not gui.Parent then
        return
    end

    local target = UDim2.fromScale(
        math.random(0, 1000) / 1000,
        math.random(0, 1000) / 1000
    )
    local duration = math.random(85, 170) / 10

    local tween = TweenService:Create(
        star,
        TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
        {Position = target}
    )

    tween.Completed:Connect(function()
        if star and star.Parent and gui.Parent then
            animateStar(star)
        end
    end)

    tween:Play()
end

for i = 1, 105 do
    local size = math.random(1, 3)
    local star = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(math.random(), math.random()),
        Size = UDim2.fromOffset(size, size),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = math.random(8, 48) / 100,
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = galaxy,
    })
    round(star, 999)
    animateStar(star)
end

-- Algunas estrellas ligeramente más grandes para dar profundidad sin cambiar el fondo negro.
for i = 1, 12 do
    local star = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(math.random(), math.random()),
        Size = UDim2.fromOffset(4, 4),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 0.62,
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = galaxy,
    })
    round(star, 999)
    animateStar(star)
end

local content = new("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    ZIndex = 5,
    Parent = main,
})
new("UIPadding", {
    PaddingTop = UDim.new(0, 8),
    PaddingBottom = UDim.new(0, 7),
    PaddingLeft = UDim.new(0, 8),
    PaddingRight = UDim.new(0, 8),
    Parent = content,
})

TweenService:Create(overlay, TweenInfo.new(0.25), {BackgroundTransparency = 0.36}):Play()
TweenService:Create(scale, TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()

local header = new("Frame", {
    Size = UDim2.new(1, 0, 0, 30),
    BackgroundTransparency = 1,
    ZIndex = 6,
    Parent = content,
})

new("TextLabel", {
    Size = UDim2.new(1, -118, 0, 18),
    BackgroundTransparency = 1,
    Text = "H3X4",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 15,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 7,
    Parent = header,
})

new("TextLabel", {
    Position = UDim2.fromOffset(0, 16),
    Size = UDim2.new(1, -118, 0, 12),
    BackgroundTransparency = 1,
    Text = "Universal Loader",
    TextColor3 = Color3.fromRGB(145, 145, 145),
    TextSize = 8,
    Font = Enum.Font.GothamMedium,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 7,
    Parent = header,
})

local countBadge = new("TextLabel", {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -31, 0, 1),
    Size = UDim2.fromOffset(74, 22),
    BackgroundColor3 = Color3.new(1, 1, 1),
    BackgroundTransparency = 0.9,
    BorderSizePixel = 0,
    Text = "0 SCRIPTS",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 8,
    Font = Enum.Font.GothamBold,
    ZIndex = 7,
    Parent = header,
})
round(countBadge, 8)
stroke(countBadge, 0.86)

local close = new("TextButton", {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, 0, 0, 0),
    Size = UDim2.fromOffset(24, 24),
    BackgroundColor3 = Color3.new(1, 1, 1),
    BackgroundTransparency = 0.92,
    BorderSizePixel = 0,
    Text = "×",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 15,
    Font = Enum.Font.GothamMedium,
    AutoButtonColor = false,
    ZIndex = 7,
    Parent = header,
})
round(close, 9)

local closing = false
local function closeLoader(callback)
    if closing then
        return
    end
    closing = true

    TweenService:Create(scale, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = 0.88}):Play()
    TweenService:Create(main, TweenInfo.new(0.18), {BackgroundTransparency = 1}):Play()
    TweenService:Create(overlay, TweenInfo.new(0.18), {BackgroundTransparency = 1}):Play()

    task.delay(0.19, function()
        if gui and gui.Parent then
            gui:Destroy()
        end
        if callback then
            callback()
        end
    end)
end

close.MouseButton1Click:Connect(function()
    closeLoader()
end)

local searchFrame = new("Frame", {
    Position = UDim2.fromOffset(0, 34),
    Size = UDim2.new(1, 0, 0, 28),
    BackgroundColor3 = Color3.fromRGB(10, 10, 10),
    BackgroundTransparency = 0.18,
    BorderSizePixel = 0,
    ZIndex = 6,
    Parent = content,
})
round(searchFrame, 10)
stroke(searchFrame, 0.86)

local search = new("TextBox", {
    Position = UDim2.fromOffset(8, 0),
    Size = UDim2.new(1, -16, 1, 0),
    BackgroundTransparency = 1,
    PlaceholderText = "Buscar script...",
    PlaceholderColor3 = Color3.fromRGB(120, 120, 120),
    Text = "",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 10,
    Font = Enum.Font.GothamMedium,
    TextXAlignment = Enum.TextXAlignment.Left,
    ClearTextOnFocus = false,
    ZIndex = 7,
    Parent = searchFrame,
})

local list = new("ScrollingFrame", {
    Position = UDim2.fromOffset(0, 68),
    Size = UDim2.new(1, 0, 1, -88),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 2,
    ScrollBarImageColor3 = Color3.fromRGB(210, 210, 210),
    CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollingDirection = Enum.ScrollingDirection.Y,
    ZIndex = 6,
    Parent = content,
})

local grid = new("UIGridLayout", {
    CellPadding = UDim2.fromOffset(6, 6),
    CellSize = UDim2.fromOffset(181, 190),
    FillDirection = Enum.FillDirection.Horizontal,
    FillDirectionMaxCells = 2,
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = list,
})

new("UIPadding", {
    PaddingBottom = UDim.new(0, 6),
    Parent = list,
})

local status = new("TextLabel", {
    AnchorPoint = Vector2.new(0, 1),
    Position = UDim2.new(0, 0, 1, 0),
    Size = UDim2.new(1, 0, 0, 14),
    BackgroundTransparency = 1,
    Text = "Cargando scripts...",
    TextColor3 = Color3.fromRGB(130, 130, 130),
    TextSize = 8,
    Font = Enum.Font.GothamMedium,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 7,
    Parent = content,
})

local cards = {}

local function createCard(data, index)
    if data.Enabled == false then
        return
    end

    local description = clampDescription(
        (data.Description and tostring(data.Description) ~= "" and data.Description)
        or fallbackDescription(data)
    )

    local card = new("Frame", {
        BackgroundColor3 = Color3.fromRGB(10, 10, 10),
        BackgroundTransparency = 0.12,
        BorderSizePixel = 0,
        LayoutOrder = index,
        ClipsDescendants = true,
        ZIndex = 7,
        Parent = list,
    })
    round(card, 12)
    stroke(card, 0.82)

    -- 1) Imagen arriba.
    local imageHolder = new("Frame", {
        Position = UDim2.fromOffset(6, 6),
        Size = UDim2.new(1, -12, 0, 82),
        BackgroundColor3 = Color3.fromRGB(4, 4, 4),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 8,
        Parent = card,
    })
    round(imageHolder, 9)

    new("ImageLabel", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Image = tostring(data.Image or ""),
        ScaleType = Enum.ScaleType.Crop,
        ZIndex = 9,
        Parent = imageHolder,
    })

    -- 2) Título en negrita.
    new("TextLabel", {
        Position = UDim2.fromOffset(9, 96),
        Size = UDim2.new(1, -18, 0, 16),
        BackgroundTransparency = 1,
        Text = tostring(data.Title or "Script"),
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 8,
        Parent = card,
    })

    -- 3) Descripción debajo del título (máximo 100 caracteres).
    new("TextLabel", {
        Position = UDim2.fromOffset(9, 115),
        Size = UDim2.new(1, -18, 0, 27),
        BackgroundTransparency = 1,
        Text = description,
        TextColor3 = Color3.fromRGB(155, 155, 155),
        TextSize = 8,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        ZIndex = 8,
        Parent = card,
    })

    local button = new("TextButton", {
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 1, -7),
        Size = UDim2.new(1, -18, 0, 25),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Text = "EJECUTAR",
        TextColor3 = Color3.new(0, 0, 0),
        TextSize = 8,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        ZIndex = 8,
        Parent = card,
    })
    round(button, 8)

    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.12), {BackgroundTransparency = 0.12}):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.12), {BackgroundTransparency = 0}):Play()
    end)

    button.MouseButton1Click:Connect(function()
        if closing then
            return
        end

        button.Text = "CARGANDO..."
        status.Text = "Preparando " .. tostring(data.Title or "script") .. "..."

        task.spawn(function()
            -- Primero se descarga/compila. Si todo está bien, se cierra el loader y DESPUÉS se ejecuta.
            local ok, result = pcall(function()
                local src = game:HttpGet(data.URL, true)
                local fn, err = loadstring(src)
                if not fn then
                    error(err)
                end
                return fn
            end)

            if not ok then
                if button and button.Parent then
                    button.Text = "ERROR"
                end
                status.Text = "Error al cargar " .. tostring(data.Title or "script")
                warn("[H3X4 Loader] " .. tostring(result))
                task.wait(1.1)
                if button and button.Parent then
                    button.Text = "EJECUTAR"
                end
                return
            end

            local fn = result
            closeLoader(function()
                task.spawn(function()
                    local ran, err = pcall(fn)
                    if not ran then
                        warn("[H3X4 Loader] Error al ejecutar: " .. tostring(err))
                    end
                end)
            end)
        end)
    end)

    table.insert(cards, {
        Frame = card,
        Title = tostring(data.Title or ""):lower(),
        Description = description:lower(),
    })
end

local function updateSearch()
    local q = search.Text:lower()
    local found = 0

    for _, c in ipairs(cards) do
        local visible = q == ""
            or string.find(c.Title, q, 1, true) ~= nil
            or string.find(c.Description, q, 1, true) ~= nil

        c.Frame.Visible = visible
        if visible then
            found += 1
        end
    end

    if q == "" then
        status.Text = tostring(#cards) .. " scripts disponibles."
    else
        status.Text = tostring(found) .. " resultados"
    end
end

search:GetPropertyChangedSignal("Text"):Connect(updateSearch)

local function loadCatalog()
    local ok, result = pcall(function()
        local src = game:HttpGet(CATALOG_URL, true)
        local fn, err = loadstring(src)
        if not fn then
            error(err)
        end

        local catalog = fn()
        if typeof(catalog) ~= "table" then
            error("loaders.lua debe devolver una tabla")
        end
        return catalog
    end)

    if not ok then
        status.Text = "Error al cargar loaders.lua"
        countBadge.Text = "0 SCRIPTS"
        warn("[H3X4 Loader] " .. tostring(result))
        return
    end

    for i, data in ipairs(result) do
        if typeof(data) == "table" then
            createCard(data, i)
        end
    end

    countBadge.Text = tostring(#cards) .. ((#cards == 1) and " SCRIPT" or " SCRIPTS")
    status.Text = tostring(#cards) .. " scripts disponibles."
end

local dragging = false
local dragInput
local dragStart
local startPos

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

local cam = workspace.CurrentCamera
local function resize()
    if not cam then
        return
    end

    local v = cam.ViewportSize
    local width = math.clamp(v.X - 20, 300, 420)
    local height = math.clamp(v.Y - 34, 300, 330)
    main.Size = UDim2.fromOffset(width, height)

    -- En pantallas pequeñas: una tarjeta por fila. En pantallas amplias: dos.
    if width < 350 then
        grid.FillDirectionMaxCells = 1
        grid.CellSize = UDim2.new(1, -4, 0, 190)
    else
        grid.FillDirectionMaxCells = 2
        grid.CellSize = UDim2.new(0.5, -4, 0, 190)
    end
end

resize()
if cam then
    cam:GetPropertyChangedSignal("ViewportSize"):Connect(resize)
end

loadCatalog()
