local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local CATALOG_URL = "https://raw.githubusercontent.com/NonyH/universalh3xa/refs/heads/main/loaders.lua"

local function new(class, props)
    local o = Instance.new(class)
    for k,v in pairs(props or {}) do o[k] = v end
    return o
end

local function round(obj, px)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, px or 12)
    c.Parent = obj
end

local function stroke(obj, t)
    local s = Instance.new("UIStroke")
    s.Color = Color3.new(1,1,1)
    s.Transparency = t or .9
    s.Thickness = 1
    s.Parent = obj
end

local parent = Player:WaitForChild("PlayerGui")
if typeof(gethui) == "function" then
    local ok, p = pcall(gethui)
    if ok and p then parent = p end
end

local old = parent:FindFirstChild("H3X4UniversalLoader")
if old then old:Destroy() end

local gui = new("ScreenGui", {
    Name = "H3X4UniversalLoader",
    IgnoreGuiInset = true,
    ResetOnSpawn = false,
    DisplayOrder = 999999,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = parent
})

local overlay = new("Frame", {
    Size = UDim2.fromScale(1,1),
    BackgroundColor3 = Color3.new(0,0,0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Parent = gui
})

local main = new("Frame", {
    AnchorPoint = Vector2.new(.5,.5),
    Position = UDim2.fromScale(.5,.5),
    Size = UDim2.fromOffset(540,360),
    BackgroundColor3 = Color3.fromRGB(8,8,8),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Parent = gui
})
round(main, 22)
stroke(main, .82)

local scale = new("UIScale", {Scale=.84, Parent=main})

local bg = new("Frame", {
    Size = UDim2.fromScale(1,1),
    BackgroundColor3 = Color3.new(0,0,0),
    BorderSizePixel = 0,
    Parent = main
})

local grad = new("UIGradient", {
    Rotation = -25,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0,0,0)),
        ColorSequenceKeypoint.new(.3, Color3.fromRGB(20,20,20)),
        ColorSequenceKeypoint.new(.5, Color3.fromRGB(58,58,58)),
        ColorSequenceKeypoint.new(.7, Color3.fromRGB(16,16,16)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0,0,0)),
    }),
    Parent = bg
})
grad.Offset = Vector2.new(-1,0)

TweenService:Create(grad, TweenInfo.new(6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
    Offset = Vector2.new(1,0)
}):Play()

for i=1,6 do
    local orb = new("Frame", {
        Size = UDim2.fromOffset(math.random(90,180), math.random(90,180)),
        Position = UDim2.fromScale(math.random(), math.random()),
        BackgroundColor3 = Color3.new(1,1,1),
        BackgroundTransparency = .93,
        BorderSizePixel = 0,
        Parent = bg
    })
    round(orb, 999)
    TweenService:Create(orb, TweenInfo.new(math.random(7,12), Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
        Position = UDim2.fromScale(math.random(), math.random())
    }):Play()
end

TweenService:Create(overlay, TweenInfo.new(.25), {BackgroundTransparency=.38}):Play()
TweenService:Create(main, TweenInfo.new(.25), {BackgroundTransparency=0}):Play()
TweenService:Create(scale, TweenInfo.new(.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale=1}):Play()

local content = new("Frame", {
    Size = UDim2.fromScale(1,1),
    BackgroundTransparency = 1,
    Parent = main
})
new("UIPadding", {
    PaddingTop=UDim.new(0,16), PaddingBottom=UDim.new(0,14),
    PaddingLeft=UDim.new(0,16), PaddingRight=UDim.new(0,16),
    Parent=content
})

local header = new("Frame", {
    Size=UDim2.new(1,0,0,46),
    BackgroundTransparency=1,
    Parent=content
})

new("TextLabel", {
    Size=UDim2.new(1,-60,0,26),
    BackgroundTransparency=1,
    Text="H3X4",
    TextColor3=Color3.new(1,1,1),
    TextSize=21,
    Font=Enum.Font.GothamBold,
    TextXAlignment=Enum.TextXAlignment.Left,
    Parent=header
})

new("TextLabel", {
    Position=UDim2.fromOffset(0,25),
    Size=UDim2.new(1,-60,0,16),
    BackgroundTransparency=1,
    Text="Universal Loader",
    TextColor3=Color3.fromRGB(130,130,130),
    TextSize=10,
    Font=Enum.Font.GothamMedium,
    TextXAlignment=Enum.TextXAlignment.Left,
    Parent=header
})

local close = new("TextButton", {
    AnchorPoint=Vector2.new(1,0),
    Position=UDim2.new(1,0,0,0),
    Size=UDim2.fromOffset(34,34),
    BackgroundColor3=Color3.new(1,1,1),
    BackgroundTransparency=.94,
    BorderSizePixel=0,
    Text="×",
    TextColor3=Color3.new(1,1,1),
    TextSize=21,
    Font=Enum.Font.GothamMedium,
    AutoButtonColor=false,
    Parent=header
})
round(close, 11)

close.MouseButton1Click:Connect(function()
    TweenService:Create(scale, TweenInfo.new(.2), {Scale=.84}):Play()
    TweenService:Create(overlay, TweenInfo.new(.2), {BackgroundTransparency=1}):Play()
    task.wait(.2)
    gui:Destroy()
end)

local searchFrame = new("Frame", {
    Position=UDim2.fromOffset(0,54),
    Size=UDim2.new(1,0,0,42),
    BackgroundColor3=Color3.new(1,1,1),
    BackgroundTransparency=.95,
    BorderSizePixel=0,
    Parent=content
})
round(searchFrame, 14)
stroke(searchFrame, .9)

local search = new("TextBox", {
    Position=UDim2.fromOffset(14,0),
    Size=UDim2.new(1,-28,1,0),
    BackgroundTransparency=1,
    PlaceholderText="Buscar script...",
    PlaceholderColor3=Color3.fromRGB(115,115,115),
    Text="",
    TextColor3=Color3.new(1,1,1),
    TextSize=13,
    Font=Enum.Font.GothamMedium,
    TextXAlignment=Enum.TextXAlignment.Left,
    ClearTextOnFocus=false,
    Parent=searchFrame
})

local list = new("ScrollingFrame", {
    Position=UDim2.fromOffset(0,108),
    Size=UDim2.new(1,0,1,-134),
    BackgroundTransparency=1,
    BorderSizePixel=0,
    ScrollBarThickness=2,
    ScrollBarImageColor3=Color3.fromRGB(210,210,210),
    CanvasSize=UDim2.new(),
    AutomaticCanvasSize=Enum.AutomaticSize.Y,
    Parent=content
})
new("UIListLayout", {Padding=UDim.new(0,9), SortOrder=Enum.SortOrder.LayoutOrder, Parent=list})
new("UIPadding", {PaddingRight=UDim.new(0,3), PaddingBottom=UDim.new(0,4), Parent=list})

local status = new("TextLabel", {
    AnchorPoint=Vector2.new(0,1),
    Position=UDim2.new(0,0,1,0),
    Size=UDim2.new(1,0,0,17),
    BackgroundTransparency=1,
    Text="Cargando scripts...",
    TextColor3=Color3.fromRGB(120,120,120),
    TextSize=9,
    Font=Enum.Font.GothamMedium,
    TextXAlignment=Enum.TextXAlignment.Left,
    Parent=content
})

local cards = {}

local function runScript(data)
    local src = game:HttpGet(data.URL, true)
    local fn, err = loadstring(src)
    if not fn then error(err) end
    return fn()
end

local function createCard(data, index)
    if data.Enabled == false then return end

    local card = new("Frame", {
        Size=UDim2.new(1,-1,0,88),
        BackgroundColor3=Color3.fromRGB(18,18,18),
        BackgroundTransparency=.12,
        BorderSizePixel=0,
        LayoutOrder=index,
        Parent=list
    })
    round(card, 16)
    stroke(card, .9)

    local holder = new("Frame", {
        Position=UDim2.fromOffset(8,8),
        Size=UDim2.fromOffset(72,72),
        BackgroundColor3=Color3.new(0,0,0),
        BorderSizePixel=0,
        ClipsDescendants=true,
        Parent=card
    })
    round(holder, 13)

    new("ImageLabel", {
        Size=UDim2.fromScale(1,1),
        BackgroundTransparency=1,
        Image=tostring(data.Image or ""),
        ScaleType=Enum.ScaleType.Crop,
        Parent=holder
    })

    new("TextLabel", {
        Position=UDim2.fromOffset(92,19),
        Size=UDim2.new(1,-220,0,23),
        BackgroundTransparency=1,
        Text=tostring(data.Title or "Script"),
        TextColor3=Color3.new(1,1,1),
        TextSize=15,
        Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left,
        TextTruncate=Enum.TextTruncate.AtEnd,
        Parent=card
    })

    new("TextLabel", {
        Position=UDim2.fromOffset(92,43),
        Size=UDim2.new(1,-220,0,18),
        BackgroundTransparency=1,
        Text="Disponible",
        TextColor3=Color3.fromRGB(120,120,120),
        TextSize=10,
        Font=Enum.Font.GothamMedium,
        TextXAlignment=Enum.TextXAlignment.Left,
        Parent=card
    })

    local button = new("TextButton", {
        AnchorPoint=Vector2.new(1,.5),
        Position=UDim2.new(1,-11,.5,0),
        Size=UDim2.fromOffset(102,37),
        BackgroundColor3=Color3.new(1,1,1),
        BorderSizePixel=0,
        Text="EJECUTAR",
        TextColor3=Color3.new(0,0,0),
        TextSize=10,
        Font=Enum.Font.GothamBold,
        AutoButtonColor=false,
        Parent=card
    })
    round(button, 11)

    button.MouseButton1Click:Connect(function()
        button.Text="CARGANDO..."
        status.Text="Cargando "..tostring(data.Title or "script").."..."

        task.spawn(function()
            local ok, err = pcall(function() runScript(data) end)
            if ok then
                button.Text="LISTO"
                status.Text=tostring(data.Title or "Script").." ejecutado."
            else
                button.Text="ERROR"
                status.Text="Error al ejecutar "..tostring(data.Title or "script")
                warn("[H3X4 Loader] "..tostring(err))
            end
            task.wait(1.2)
            if button and button.Parent then button.Text="EJECUTAR" end
        end)
    end)

    table.insert(cards, {Frame=card, Title=tostring(data.Title or ""):lower()})
end

search:GetPropertyChangedSignal("Text"):Connect(function()
    local q = search.Text:lower()
    local found = 0
    for _,c in ipairs(cards) do
        local visible = q == "" or string.find(c.Title, q, 1, true) ~= nil
        c.Frame.Visible = visible
        if visible then found += 1 end
    end
    status.Text = q == "" and (tostring(#cards).." scripts disponibles.") or (tostring(found).." resultados")
end)

local function loadCatalog()
    local ok, result = pcall(function()
        local src = game:HttpGet(CATALOG_URL, true)
        local fn, err = loadstring(src)
        if not fn then error(err) end
        local catalog = fn()
        if typeof(catalog) ~= "table" then error("loaders.lua debe devolver una tabla") end
        return catalog
    end)

    if not ok then
        status.Text="Error al cargar loaders.lua"
        warn("[H3X4 Loader] "..tostring(result))
        return
    end

    for i,data in ipairs(result) do
        if typeof(data) == "table" then createCard(data, i) end
    end
    status.Text=tostring(#cards).." scripts disponibles."
end

local dragging, dragInput, dragStart, startPos = false, nil, nil, nil

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging=true
        dragStart=input.Position
        startPos=main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging=false end
        end)
    end
end)

header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput=input
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local d=input.Position-dragStart
        main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
    end
end)

local cam=workspace.CurrentCamera
local function resize()
    if not cam then return end
    local v=cam.ViewportSize
    main.Size=UDim2.fromOffset(math.clamp(v.X-30,335,540), math.clamp(v.Y-55,340,360))
end
resize()
if cam then cam:GetPropertyChangedSignal("ViewportSize"):Connect(resize) end

loadCatalog()
