local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local CATALOG_URL = "https://raw.githubusercontent.com/NonyH/universalh3xa/refs/heads/main/loaders.lua"
local DISCORD_URL = "https://discord.gg/sewRzHAG5J"


local LANGUAGE_FILE = "H3X4_loader_language.txt"
local FAVORITES_FILE = "H3X4_loader_favorites.json"
local sessionEnv = (typeof(getgenv) == "function" and getgenv()) or _G

local translations = {
    es = {
        loaderSubtitle = "Cargador Universal",
        scripts = "SCRIPTS",
        script = "SCRIPT",
        search = "Buscar script...",
        loadingScripts = "Cargando scripts...",
        noResults = "NO SE ENCONTRARON RESULTADOS",
        execute = "EJECUTAR",
        copyLoadstring = "COPIAR SCRIPT",
        copied = "¡COPIADO!",
        loadstringCopied = "Loadstring copiado al portapapeles.",
        loadstringCopyFailed = "No se pudo copiar el loadstring.",
        loading = "CARGANDO...",
        preparing = "Preparando %s...",
        loadError = "Error al cargar %s",
        available = "%d scripts disponibles.",
        oneAvailable = "1 script disponible.",
        results = "%d resultados",
        oneResult = "1 resultado",
        catalogError = "Error al cargar loaders.lua",
        catalogTableError = "loaders.lua debe devolver una tabla",
        boatFallback = "Script diseñado para Build A Boat For Treasure.",
        universalFallback = "Script universal con herramientas y funciones para múltiples juegos.",
        genericFallback = "Script disponible en el cargador universal H3X4.",
        discordCopied = "Enlace de Discord copiado al portapapeles.",
        discordCopyFailed = "No se pudo copiar el enlace de Discord.",
        details = "DETALLES",
        detailsTitle = "DETALLES DEL SCRIPT",
        closeDetails = "CERRAR",
        favoriteAdded = "Añadido a favoritos.",
        favoriteRemoved = "Eliminado de favoritos.",
        version = "Versión",
        updated = "Actualizado",
        author = "Autor",
        game = "Juego",
        tag = "Etiqueta",
        raw = "RAW",
        enabled = "Disponible",
        yes = "Sí",
        no = "No",
        noExtraInfo = "Sin información adicional.",
    },
    en = {
        loaderSubtitle = "Universal Loader",
        scripts = "SCRIPTS",
        script = "SCRIPT",
        search = "Search script...",
        loadingScripts = "Loading scripts...",
        noResults = "NO RESULTS FOUND",
        execute = "RUN",
        copyLoadstring = "COPY SCRIPT",
        copied = "COPIED!",
        loadstringCopied = "Loadstring copied to clipboard.",
        loadstringCopyFailed = "Could not copy the loadstring.",
        loading = "LOADING...",
        preparing = "Preparing %s...",
        loadError = "Failed to load %s",
        available = "%d scripts available.",
        oneAvailable = "1 script available.",
        results = "%d results",
        oneResult = "1 result",
        catalogError = "Failed to load loaders.lua",
        catalogTableError = "loaders.lua must return a table",
        boatFallback = "Script designed for Build A Boat For Treasure.",
        universalFallback = "Universal script with tools and features for multiple games.",
        genericFallback = "Script available in the H3X4 universal loader.",
        discordCopied = "Discord invite copied to clipboard.",
        discordCopyFailed = "Could not copy the Discord invite.",
        details = "DETAILS",
        detailsTitle = "SCRIPT DETAILS",
        closeDetails = "CLOSE",
        favoriteAdded = "Added to favorites.",
        favoriteRemoved = "Removed from favorites.",
        version = "Version",
        updated = "Updated",
        author = "Author",
        game = "Game",
        tag = "Tag",
        raw = "RAW",
        enabled = "Available",
        yes = "Yes",
        no = "No",
        noExtraInfo = "No additional information.",
    },

}

local function validLanguage(code)
    return code == "es" or code == "en"
end

local function readRememberedLanguage()
    local code = sessionEnv.H3X4LoaderLanguage
    if validLanguage(code) then
        return code
    end

    if type(isfile) == "function" and type(readfile) == "function" then
        local okExists, exists = pcall(isfile, LANGUAGE_FILE)
        if okExists and exists then
            local okRead, saved = pcall(readfile, LANGUAGE_FILE)
            if okRead then
                saved = tostring(saved):match("^%s*(.-)%s*$")
                if validLanguage(saved) then
                    sessionEnv.H3X4LoaderLanguage = saved
                    return saved
                end
            end
        end
    end

    return nil
end

local rememberedLanguage = readRememberedLanguage()
local currentLanguage = rememberedLanguage or "es"

local function T(key)
    local lang = translations[currentLanguage] or translations.es
    return lang[key] or translations.es[key] or key
end

local function saveLanguage(code)
    if not validLanguage(code) then
        return false
    end

    sessionEnv.H3X4LoaderLanguage = code
    rememberedLanguage = code

    if type(writefile) == "function" then
        local ok = pcall(writefile, LANGUAGE_FILE, code)
        return ok
    end

    return false
end

local function clearRememberedLanguage()
    sessionEnv.H3X4LoaderLanguage = nil
    rememberedLanguage = nil

    if type(isfile) == "function" and type(delfile) == "function" then
        pcall(function()
            if isfile(LANGUAGE_FILE) then
                delfile(LANGUAGE_FILE)
            end
        end)
    end
end

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
        return T("boatFallback")
    elseif string.find(lower, "h3x4", 1, true) then
        return T("universalFallback")
    end

    return T("genericFallback")
end

local function localizedDescription(data)
    local value

    -- Formato recomendado en loaders.lua:
    -- DescriptionES = "Descripción en español"
    -- DescriptionEN = "English description"
    -- También acepta Description = "..." como respaldo.
    if currentLanguage == "en" then
        value = data.DescriptionEN or data.DescriptionEn or data.DescriptionEnglish
    else
        value = data.DescriptionES or data.DescriptionEs or data.DescriptionSpanish
    end

    if value == nil or tostring(value) == "" then
        if typeof(data.Description) == "table" then
            value = data.Description[currentLanguage]
                or data.Description[string.upper(currentLanguage)]
                or data.Description.Default
                or data.Description.default
        else
            value = data.Description
        end
    end

    if value ~= nil and tostring(value) ~= "" then
        return clampDescription(tostring(value))
    end

    return clampDescription(fallbackDescription(data))
end

local function localizedTitle(data)
    local value
    if currentLanguage == "en" then
        value = data.TitleEN or data.TitleEn or data.TitleEnglish
    else
        value = data.TitleES or data.TitleEs or data.TitleSpanish
    end

    if value == nil or tostring(value) == "" then
        value = data.Title
    end

    return tostring(value or "Script")
end

local function fullLocalizedDescription(data)
    local value
    if currentLanguage == "en" then
        value = data.DescriptionEN or data.DescriptionEn or data.DescriptionEnglish
    else
        value = data.DescriptionES or data.DescriptionEs or data.DescriptionSpanish
    end

    if value == nil or tostring(value) == "" then
        if typeof(data.Description) == "table" then
            value = data.Description[currentLanguage]
                or data.Description[string.upper(currentLanguage)]
                or data.Description.Default
                or data.Description.default
        else
            value = data.Description
        end
    end

    if value ~= nil and tostring(value) ~= "" then
        return tostring(value)
    end

    return fallbackDescription(data)
end

local function favoriteKey(data)
    local url = tostring(data.URL or "")
    if url ~= "" then
        return url
    end
    return tostring(data.Title or "Script")
end

local favorites = {}

do
    local saved = sessionEnv.H3X4LoaderFavorites
    if typeof(saved) == "table" then
        for k, v in pairs(saved) do
            if v == true then
                favorites[tostring(k)] = true
            end
        end
    end

    if type(isfile) == "function" and type(readfile) == "function" then
        local okExists, exists = pcall(isfile, FAVORITES_FILE)
        if okExists and exists then
            local okRead, raw = pcall(readfile, FAVORITES_FILE)
            if okRead then
                local okDecode, decoded = pcall(function()
                    return HttpService:JSONDecode(raw)
                end)
                if okDecode and typeof(decoded) == "table" then
                    for k, v in pairs(decoded) do
                        if v == true then
                            favorites[tostring(k)] = true
                        end
                    end
                end
            end
        end
    end

    sessionEnv.H3X4LoaderFavorites = favorites
end

local function saveFavorites()
    sessionEnv.H3X4LoaderFavorites = favorites
    if type(writefile) == "function" then
        pcall(function()
            writefile(FAVORITES_FILE, HttpService:JSONEncode(favorites))
        end)
    end
end

local function isFavorite(data)
    return favorites[favoriteKey(data)] == true
end

local function setFavorite(data, value)
    local key = favoriteKey(data)
    if value then
        favorites[key] = true
    else
        favorites[key] = nil
    end
    saveFavorites()
end

local function parseColor(value)
    if typeof(value) == "Color3" then
        return value
    end

    if type(value) == "string" then
        local hex = value:gsub("#", "")
        if #hex == 6 then
            local r = tonumber(hex:sub(1, 2), 16)
            local g = tonumber(hex:sub(3, 4), 16)
            local b = tonumber(hex:sub(5, 6), 16)
            if r and g and b then
                return Color3.fromRGB(r, g, b)
            end
        end
    elseif typeof(value) == "table" then
        local r = value.R or value.r or value[1]
        local g = value.G or value.g or value[2]
        local b = value.B or value.b or value[3]
        if tonumber(r) and tonumber(g) and tonumber(b) then
            r, g, b = tonumber(r), tonumber(g), tonumber(b)
            if r <= 1 and g <= 1 and b <= 1 then
                return Color3.new(r, g, b)
            end
            return Color3.fromRGB(math.clamp(r, 0, 255), math.clamp(g, 0, 255), math.clamp(b, 0, 255))
        end
    end

    return Color3.new(1, 1, 1)
end

local function getTag(data)
    local tag = data.Tag or data.Label or data.Etiqueta
    if typeof(tag) ~= "table" and typeof(data.Tags) == "table" then
        tag = data.Tags[1]
    end
    if typeof(tag) ~= "table" then
        return nil
    end

    local title = tostring(tag.Title or tag.Text or tag.Name or "")
    if title == "" or string.lower(title) == "none" then
        return nil
    end

    return {
        Title = title,
        Color = parseColor(tag.Color or tag.Colour or tag.RGB),
    }
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
    Size = UDim2.fromOffset(420, 335),
    BackgroundColor3 = Color3.new(0, 0, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    ZIndex = 2,
    Parent = gui,
    Visible = rememberedLanguage ~= nil,
})
round(main, 16)
stroke(main, 0.18).Thickness = 1.35

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


-- Pantalla inicial de idioma: ocupa toda la pantalla y usa el mismo fondo galaxia.
local languageScreen = new("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.new(0, 0, 0),
    BorderSizePixel = 0,
    ClipsDescendants = true,
    ZIndex = 50,
    Visible = rememberedLanguage == nil,
    Parent = gui,
})

do
    for i = 1, 145 do
        local size = math.random(1, 3)
        local star = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(math.random(), math.random()),
            Size = UDim2.fromOffset(size, size),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BackgroundTransparency = math.random(10, 55) / 100,
            BorderSizePixel = 0,
            ZIndex = 51,
            Parent = languageScreen,
        })
        round(star, 999)
        animateStar(star)
    end
end

local languagePanel = new("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(360, 232),
    BackgroundColor3 = Color3.fromRGB(5, 5, 5),
    BackgroundTransparency = 0.08,
    BorderSizePixel = 0,
    ZIndex = 52,
    Parent = languageScreen,
})
round(languagePanel, 18)
stroke(languagePanel, 0.18).Thickness = 1.4

local languagePanelScale = new("UIScale", {
    Scale = 0.86,
    Parent = languagePanel,
})
if rememberedLanguage == nil then
    TweenService:Create(languagePanelScale, TweenInfo.new(0.38, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
end

new("TextLabel", {
    Position = UDim2.fromOffset(18, 16),
    Size = UDim2.new(1, -36, 0, 22),
    BackgroundTransparency = 1,
    Text = "SELECT LANGUAGE",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 16,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Center,
    ZIndex = 53,
    Parent = languagePanel,
})

new("TextLabel", {
    Position = UDim2.fromOffset(18, 40),
    Size = UDim2.new(1, -36, 0, 18),
    BackgroundTransparency = 1,
    Text = "Selecciona • Select",
    TextColor3 = Color3.fromRGB(150, 150, 150),
    TextSize = 9,
    Font = Enum.Font.GothamMedium,
    TextXAlignment = Enum.TextXAlignment.Center,
    ZIndex = 53,
    Parent = languagePanel,
})

local rememberChoice = false
local rememberButton = new("TextButton", {
    AnchorPoint = Vector2.new(0.5, 1),
    Position = UDim2.new(0.5, 0, 1, -16),
    Size = UDim2.new(1, -36, 0, 34),
    BackgroundColor3 = Color3.fromRGB(16, 16, 16),
    BackgroundTransparency = 0.05,
    BorderSizePixel = 0,
    Text = "○  RECORDAR IDIOMA / REMEMBER LANGUAGE",
    TextColor3 = Color3.fromRGB(190, 190, 190),
    TextSize = 9,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
    ZIndex = 53,
    Parent = languagePanel,
})
round(rememberButton, 10)
stroke(rememberButton, 0.76)

local function updateRememberButton()
    rememberButton.Text = (rememberChoice and "●  " or "○  ") .. "RECORDAR IDIOMA / REMEMBER LANGUAGE"
    rememberButton.TextColor3 = rememberChoice and Color3.new(1, 1, 1) or Color3.fromRGB(190, 190, 190)
    rememberButton.BackgroundTransparency = rememberChoice and 0.82 or 0.05
end

rememberButton.MouseButton1Click:Connect(function()
    rememberChoice = not rememberChoice
    if not rememberChoice then
        clearRememberedLanguage()
    end
    updateRememberButton()
end)

updateRememberButton()

local languageButtonsHolder = new("Frame", {
    Position = UDim2.fromOffset(18, 72),
    Size = UDim2.new(1, -36, 0, 86),
    BackgroundTransparency = 1,
    ZIndex = 53,
    Parent = languagePanel,
})

local languageList = new("UIListLayout", {
    FillDirection = Enum.FillDirection.Vertical,
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
    VerticalAlignment = Enum.VerticalAlignment.Top,
    Padding = UDim.new(0, 7),
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = languageButtonsHolder,
})

local languageButtonDefs = {
    {code = "es", flag = "🇪🇸", label = "Español"},
    {code = "en", flag = "🇬🇧", label = "English"},
}

local languageChosen = false
local languageCallbacks = {}

for i, info in ipairs(languageButtonDefs) do
    local b = new("TextButton", {
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = Color3.fromRGB(14, 14, 14),
        BackgroundTransparency = 0.06,
        BorderSizePixel = 0,
        Text = info.flag .. "   " .. info.label,
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        LayoutOrder = i,
        ZIndex = 54,
        Parent = languageButtonsHolder,
    })
    round(b, 11)
    stroke(b, 0.78)

    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.12), {BackgroundTransparency = 0.82}):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.12), {BackgroundTransparency = 0.06}):Play()
    end)

    b.MouseButton1Click:Connect(function()
        if languageChosen then return end
        languageChosen = true
        currentLanguage = info.code
        if rememberChoice then
            saveLanguage(info.code)
        end
        if languageCallbacks.onSelected then
            languageCallbacks.onSelected()
        end
    end)
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

if rememberedLanguage ~= nil then
    TweenService:Create(overlay, TweenInfo.new(0.25), {BackgroundTransparency = 0.36}):Play()
    TweenService:Create(scale, TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
end

local header = new("Frame", {
    Size = UDim2.new(1, 0, 0, 30),
    BackgroundTransparency = 1,
    ZIndex = 6,
    Parent = content,
})

new("TextLabel", {
    Size = UDim2.new(1, -220, 0, 18),
    BackgroundTransparency = 1,
    Text = "H3X4",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 15,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 7,
    Parent = header,
})

local subtitleLabel = new("TextLabel", {
    Position = UDim2.fromOffset(0, 16),
    Size = UDim2.new(1, -220, 0, 12),
    BackgroundTransparency = 1,
    Text = T("loaderSubtitle"),
    TextColor3 = Color3.fromRGB(145, 145, 145),
    TextSize = 8,
    Font = Enum.Font.GothamMedium,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 7,
    Parent = header,
})

local countBadge = new("TextLabel", {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -67, 0, 1),
    Size = UDim2.fromOffset(74, 22),
    BackgroundColor3 = Color3.new(1, 1, 1),
    BackgroundTransparency = 0.9,
    BorderSizePixel = 0,
    Text = "0 " .. T("scripts"),
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 8,
    Font = Enum.Font.GothamBold,
    ZIndex = 7,
    Parent = header,
})
round(countBadge, 8)
stroke(countBadge, 0.86)

-- Botón destacado para unirse al Discord del script.
local discordButton = new("TextButton", {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -147, 0, 1),
    Size = UDim2.fromOffset(66, 22),
    BackgroundColor3 = Color3.new(1, 1, 1),
    BackgroundTransparency = 0.03,
    BorderSizePixel = 0,
    Text = "Discord",
    TextColor3 = Color3.new(0, 0, 0),
    TextSize = 9,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
    ZIndex = 8,
    Parent = header,
})
round(discordButton, 8)
local discordStroke = stroke(discordButton, 0.02)
discordStroke.Thickness = 1.5

-- Efecto blanco/neón sutil al pasar el cursor.
discordButton.MouseEnter:Connect(function()
    TweenService:Create(discordButton, TweenInfo.new(0.12), {BackgroundTransparency = 0.12}):Play()
    TweenService:Create(discordStroke, TweenInfo.new(0.12), {Thickness = 2.2, Transparency = 0}):Play()
end)

discordButton.MouseLeave:Connect(function()
    TweenService:Create(discordButton, TweenInfo.new(0.12), {BackgroundTransparency = 0.03}):Play()
    TweenService:Create(discordStroke, TweenInfo.new(0.12), {Thickness = 1.5, Transparency = 0.02}):Play()
end)

-- Botón superior para volver a abrir el selector de idioma en cualquier momento.
local languageButton = new("TextButton", {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -31, 0, 0),
    Size = UDim2.fromOffset(30, 24),
    BackgroundColor3 = Color3.new(1, 1, 1),
    BackgroundTransparency = 0.92,
    BorderSizePixel = 0,
    Text = string.upper(currentLanguage),
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 8,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
    ZIndex = 7,
    Parent = header,
})
round(languageButton, 9)
stroke(languageButton, 0.82)

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
    Size = UDim2.new(1, 0, 0, 30),
    BackgroundColor3 = Color3.fromRGB(22, 22, 22),
    BackgroundTransparency = 0.04,
    BorderSizePixel = 0,
    ZIndex = 6,
    Parent = content,
})
round(searchFrame, 10)
local searchStroke = stroke(searchFrame, 0.28)
searchStroke.Thickness = 1.5

local search = new("TextBox", {
    Position = UDim2.fromOffset(10, 0),
    Size = UDim2.new(1, -20, 1, 0),
    BackgroundTransparency = 1,
    PlaceholderText = T("search"),
    PlaceholderColor3 = Color3.fromRGB(205, 205, 205),
    Text = "",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 11,
    Font = Enum.Font.GothamSemibold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ClearTextOnFocus = false,
    ZIndex = 7,
    Parent = searchFrame,
})

-- Hace que el buscador destaque todavía más al seleccionarlo.
search.Focused:Connect(function()
    TweenService:Create(searchFrame, TweenInfo.new(0.14), {
        BackgroundColor3 = Color3.fromRGB(32, 32, 32),
        BackgroundTransparency = 0
    }):Play()
    TweenService:Create(searchStroke, TweenInfo.new(0.14), {
        Transparency = 0.05,
        Thickness = 2
    }):Play()
end)

search.FocusLost:Connect(function()
    TweenService:Create(searchFrame, TweenInfo.new(0.14), {
        BackgroundColor3 = Color3.fromRGB(22, 22, 22),
        BackgroundTransparency = 0.04
    }):Play()
    TweenService:Create(searchStroke, TweenInfo.new(0.14), {
        Transparency = 0.28,
        Thickness = 1.5
    }):Play()
end)

local list = new("ScrollingFrame", {
    Position = UDim2.fromOffset(0, 70),
    Size = UDim2.new(1, 0, 1, -90),
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
    PaddingTop = UDim.new(0, 5),
    PaddingBottom = UDim.new(0, 8),
    PaddingLeft = UDim.new(0, 2),
    PaddingRight = UDim.new(0, 2),
    Parent = list,
})

local status = new("TextLabel", {
    AnchorPoint = Vector2.new(0, 1),
    Position = UDim2.new(0, 0, 1, 0),
    Size = UDim2.new(1, 0, 0, 14),
    BackgroundTransparency = 1,
    Text = T("loadingScripts"),
    TextColor3 = Color3.fromRGB(130, 130, 130),
    TextSize = 8,
    Font = Enum.Font.GothamMedium,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 7,
    Parent = content,
})

-- Mensaje central que aparece únicamente cuando una búsqueda no encuentra scripts.
local noResults = new("TextLabel", {
    Position = UDim2.fromOffset(0, 68),
    Size = UDim2.new(1, 0, 1, -88),
    BackgroundTransparency = 1,
    Text = T("noResults"),
    TextColor3 = Color3.fromRGB(180, 180, 180),
    TextSize = 12,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Center,
    TextYAlignment = Enum.TextYAlignment.Center,
    Visible = false,
    ZIndex = 8,
    Parent = content,
})

-- Panel modal de detalles del script.
local detailsShade = new("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.new(0, 0, 0),
    BackgroundTransparency = 0.22,
    BorderSizePixel = 0,
    Visible = false,
    Active = true,
    ZIndex = 30,
    Parent = main,
})
round(detailsShade, 16)

local detailsPanel = new("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.new(0.86, 0, 0.84, 0),
    BackgroundColor3 = Color3.fromRGB(8, 8, 8),
    BackgroundTransparency = 0.02,
    BorderSizePixel = 0,
    ZIndex = 31,
    Parent = detailsShade,
})
round(detailsPanel, 14)
local detailsPanelStroke = stroke(detailsPanel, 0.22)
detailsPanelStroke.Thickness = 1.5

local detailsHeader = new("TextLabel", {
    Position = UDim2.fromOffset(14, 10),
    Size = UDim2.new(1, -55, 0, 22),
    BackgroundTransparency = 1,
    Text = T("detailsTitle"),
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 13,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 32,
    Parent = detailsPanel,
})

local detailsClose = new("TextButton", {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -10, 0, 8),
    Size = UDim2.fromOffset(28, 28),
    BackgroundColor3 = Color3.new(1, 1, 1),
    BackgroundTransparency = 0.9,
    BorderSizePixel = 0,
    Text = "×",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 17,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
    ZIndex = 33,
    Parent = detailsPanel,
})
round(detailsClose, 9)

local detailsImageHolder = new("Frame", {
    Position = UDim2.fromOffset(14, 42),
    Size = UDim2.new(0.34, 0, 0, 100),
    BackgroundColor3 = Color3.fromRGB(4, 4, 4),
    BorderSizePixel = 0,
    ClipsDescendants = true,
    ZIndex = 32,
    Parent = detailsPanel,
})
round(detailsImageHolder, 10)
stroke(detailsImageHolder, 0.75)

local detailsImage = new("ImageLabel", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Image = "",
    ScaleType = Enum.ScaleType.Fit,
    ZIndex = 33,
    Parent = detailsImageHolder,
})

local detailsName = new("TextLabel", {
    Position = UDim2.new(0.37, 6, 0, 44),
    Size = UDim2.new(0.63, -20, 0, 24),
    BackgroundTransparency = 1,
    Text = "Script",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 16,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTruncate = Enum.TextTruncate.AtEnd,
    ZIndex = 32,
    Parent = detailsPanel,
})

local detailsTag = new("TextLabel", {
    Position = UDim2.new(0.37, 6, 0, 74),
    Size = UDim2.fromOffset(90, 22),
    BackgroundColor3 = Color3.new(1, 1, 1),
    BackgroundTransparency = 0.05,
    BorderSizePixel = 0,
    Text = "",
    TextColor3 = Color3.new(0, 0, 0),
    TextSize = 9,
    Font = Enum.Font.GothamBold,
    Visible = false,
    ZIndex = 32,
    Parent = detailsPanel,
})
round(detailsTag, 7)

local detailsScroll = new("ScrollingFrame", {
    Position = UDim2.fromOffset(14, 152),
    Size = UDim2.new(1, -28, 1, -166),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 2,
    ScrollBarImageColor3 = Color3.fromRGB(210, 210, 210),
    CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollingDirection = Enum.ScrollingDirection.Y,
    ZIndex = 32,
    Parent = detailsPanel,
})

local detailsText = new("TextLabel", {
    Size = UDim2.new(1, -6, 0, 0),
    AutomaticSize = Enum.AutomaticSize.Y,
    BackgroundTransparency = 1,
    Text = "",
    TextColor3 = Color3.fromRGB(205, 205, 205),
    TextSize = 12,
    Font = Enum.Font.GothamMedium,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    TextWrapped = true,
    RichText = false,
    ZIndex = 33,
    Parent = detailsScroll,
})

local currentDetailsData = nil

local function detailScalar(value)
    if value == nil then return nil end
    if typeof(value) == "boolean" then
        return value and T("yes") or T("no")
    end
    if typeof(value) == "string" or typeof(value) == "number" then
        local txt = tostring(value)
        if txt ~= "" then return txt end
    end
    return nil
end

local function buildDetailsText(data)
    local lines = {}
    local fullDescription = fullLocalizedDescription(data)
    if fullDescription ~= "" then
        table.insert(lines, fullDescription)
        table.insert(lines, "")
    end

    local tag = getTag(data)
    local standard = {
        {T("version"), data.Version},
        {T("author"), data.Author or data.Creator},
        {T("game"), data.Game or data.GameName},
        {T("tag"), tag and tag.Title or nil},
    }

    for _, item in ipairs(standard) do
        local value = detailScalar(item[2])
        if value then
            table.insert(lines, item[1] .. ": " .. value)
        end
    end

    -- Cualquier campo simple adicional del RAW también aparece en Detalles.
    local ignored = {
        Title=true, TitleES=true, TitleEs=true, TitleEN=true, TitleEn=true,
        TitleSpanish=true, TitleEnglish=true,
        Description=true, DescriptionES=true, DescriptionEs=true, DescriptionEN=true,
        DescriptionEn=true, DescriptionSpanish=true, DescriptionEnglish=true,
        Image=true, URL=true, Enabled=true, Tag=true, Tags=true, Label=true, Etiqueta=true,
        Version=true, Author=true, Creator=true,
        Game=true, GameName=true,
    }
    local extras = {}
    for k, v in pairs(data) do
        if not ignored[k] then
            local scalar = detailScalar(v)
            if scalar then
                table.insert(extras, {Key=tostring(k), Value=scalar})
            end
        end
    end
    table.sort(extras, function(a, b) return a.Key < b.Key end)
    for _, item in ipairs(extras) do
        table.insert(lines, item.Key .. ": " .. item.Value)
    end

    if #lines == 0 then
        return T("noExtraInfo")
    end
    return table.concat(lines, "\n")
end

local function refreshDetails()
    if not currentDetailsData then return end
    local data = currentDetailsData
    detailsHeader.Text = T("detailsTitle")
    detailsName.Text = localizedTitle(data)
    detailsImage.Image = tostring(data.Image or "")
    detailsText.Text = buildDetailsText(data)

    local tag = getTag(data)
    if tag then
        detailsTag.Visible = true
        detailsTag.Text = tag.Title
        detailsTag.BackgroundColor3 = tag.Color
        local luminance = (tag.Color.R * 0.299) + (tag.Color.G * 0.587) + (tag.Color.B * 0.114)
        detailsTag.TextColor3 = luminance > 0.62 and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
    else
        detailsTag.Visible = false
    end
end

local function openDetails(data)
    currentDetailsData = data
    refreshDetails()
    detailsShade.Visible = true
end

local function closeDetailsPanel()
    detailsShade.Visible = false
    currentDetailsData = nil
end

detailsClose.MouseButton1Click:Connect(closeDetailsPanel)
detailsShade.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Escape then
        closeDetailsPanel()
    end
end)

-- Copia el enlace del servidor al pulsar Discord.
discordButton.MouseButton1Click:Connect(function()
    local copied = false

    if type(setclipboard) == "function" then
        copied = pcall(setclipboard, DISCORD_URL)
    elseif type(toclipboard) == "function" then
        copied = pcall(toclipboard, DISCORD_URL)
    end

    if copied then
        status.Text = T("discordCopied")
        local oldText = discordButton.Text
        discordButton.Text = "✓ Discord"
        task.delay(1.1, function()
            if discordButton and discordButton.Parent then
                discordButton.Text = oldText
            end
        end)
    else
        status.Text = T("discordCopyFailed")
    end
end)

local cards = {}

-- Detecta el tipo de dispositivo también para adaptar el diseño interno de las tarjetas.
local function cardIsMobile()
    return UIS.TouchEnabled and not (UIS.KeyboardEnabled and UIS.MouseEnabled)
end

local function createCard(data, index)
    if data.Enabled == false then
        return
    end

    local title = localizedTitle(data)
    local description = localizedDescription(data)
    local tag = getTag(data)

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

    local mobileCard = cardIsMobile()
    local imageHeight = mobileCard and 84 or 145
    local titleY = mobileCard and 98 or 159
    local descriptionY = mobileCard and 117 or 178

    local imageHolder = new("Frame", {
        Position = UDim2.fromOffset(6, 6),
        Size = UDim2.new(1, -12, 0, imageHeight),
        BackgroundColor3 = Color3.fromRGB(4, 4, 4),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 8,
        Parent = card,
    })
    round(imageHolder, 9)
    stroke(imageHolder, 0.9)

    new("ImageLabel", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Image = tostring(data.Image or ""),
        ScaleType = mobileCard and Enum.ScaleType.Fit or Enum.ScaleType.Crop,
        ZIndex = 9,
        Parent = imageHolder,
    })

    -- Etiqueta controlada completamente desde loaders.lua.
    local tagLabel
    if tag then
        local tagWidth = math.clamp(26 + (#tag.Title * 6), 58, 118)
        tagLabel = new("TextLabel", {
            Position = UDim2.fromOffset(8, 8),
            Size = UDim2.fromOffset(tagWidth, 20),
            BackgroundColor3 = tag.Color,
            BackgroundTransparency = 0.03,
            BorderSizePixel = 0,
            Text = tag.Title,
            TextSize = 8,
            Font = Enum.Font.GothamBold,
            ZIndex = 11,
            Parent = imageHolder,
        })
        local luminance = (tag.Color.R * 0.299) + (tag.Color.G * 0.587) + (tag.Color.B * 0.114)
        tagLabel.TextColor3 = luminance > 0.62 and Color3.new(0, 0, 0) or Color3.new(1, 1, 1)
        round(tagLabel, 7)
    end

    -- Favorito: se guarda por URL para persistir aunque cambie el título.
    local favoriteButton = new("TextButton", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -8, 0, 8),
        Size = UDim2.fromOffset(26, 26),
        BackgroundColor3 = Color3.fromRGB(8, 8, 8),
        BackgroundTransparency = 0.18,
        BorderSizePixel = 0,
        Text = isFavorite(data) and "★" or "☆",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        ZIndex = 12,
        Parent = imageHolder,
    })
    round(favoriteButton, 8)
    stroke(favoriteButton, 0.7)

    local titleLabel = new("TextLabel", {
        Position = UDim2.fromOffset(9, titleY),
        Size = UDim2.new(1, -18, 0, 16),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 8,
        Parent = card,
    })

    local descriptionLabel = new("TextLabel", {
        Position = UDim2.fromOffset(9, descriptionY),
        Size = UDim2.new(1, -18, 0, mobileCard and 38 or 50),
        BackgroundTransparency = 1,
        Text = description,
        TextColor3 = Color3.fromRGB(155, 155, 155),
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        ZIndex = 8,
        Parent = card,
    })

    -- Tres acciones: ejecutar, detalles y copiar script.
    local button = new("TextButton", {
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 9, 1, -7),
        Size = UDim2.new(0.34, -10, 0, 25),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Text = T("execute"),
        TextColor3 = Color3.new(0, 0, 0),
        TextSize = mobileCard and 7 or 8,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        ZIndex = 8,
        Parent = card,
    })
    round(button, 8)

    local detailsButton = new("TextButton", {
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 1, -7),
        Size = UDim2.new(0.32, -8, 0, 25),
        BackgroundColor3 = Color3.fromRGB(126, 96, 28),
        BackgroundTransparency = 0.03,
        BorderSizePixel = 0,
        Text = T("details"),
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = mobileCard and 6 or 8,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        ZIndex = 8,
        Parent = card,
    })
    round(detailsButton, 8)
    local detailsGoldStroke = stroke(detailsButton, 0.32)
    detailsGoldStroke.Color = Color3.fromRGB(208, 165, 58)
    detailsGoldStroke.Thickness = 1.15

    local copyButton = new("TextButton", {
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -9, 1, -7),
        Size = UDim2.new(0.34, -10, 0, 25),
        BackgroundColor3 = Color3.fromRGB(108, 80, 22),
        BackgroundTransparency = 0.04,
        BorderSizePixel = 0,
        Text = T("copyLoadstring"),
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = mobileCard and 6 or 7,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        ZIndex = 8,
        Parent = card,
    })
    round(copyButton, 8)
    local copyGoldStroke = stroke(copyButton, 0.34)
    copyGoldStroke.Color = Color3.fromRGB(194, 148, 46)
    copyGoldStroke.Thickness = 1.15

    favoriteButton.MouseButton1Click:Connect(function()
        local newValue = not isFavorite(data)
        setFavorite(data, newValue)
        favoriteButton.Text = newValue and "★" or "☆"
        status.Text = newValue and T("favoriteAdded") or T("favoriteRemoved")
    end)

    detailsButton.MouseButton1Click:Connect(function()
        openDetails(data)
    end)

    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.12), {BackgroundTransparency = 0.12}):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.12), {BackgroundTransparency = 0}):Play()
    end)
    detailsButton.MouseEnter:Connect(function()
        TweenService:Create(detailsButton, TweenInfo.new(0.12), {BackgroundTransparency = 0}):Play()
    end)
    detailsButton.MouseLeave:Connect(function()
        TweenService:Create(detailsButton, TweenInfo.new(0.12), {BackgroundTransparency = 0.03}):Play()
    end)
    copyButton.MouseEnter:Connect(function()
        TweenService:Create(copyButton, TweenInfo.new(0.12), {BackgroundTransparency = 0}):Play()
    end)
    copyButton.MouseLeave:Connect(function()
        TweenService:Create(copyButton, TweenInfo.new(0.12), {BackgroundTransparency = 0.04}):Play()
    end)

    copyButton.MouseButton1Click:Connect(function()
        local url = tostring(data.URL or "")
        if url == "" then
            status.Text = T("loadstringCopyFailed")
            return
        end

        local loadstringText = "loadstring(game:HttpGet(" .. string.format("%q", url) .. ", true))()"
        local copied = false
        if type(setclipboard) == "function" then
            copied = pcall(setclipboard, loadstringText)
        elseif type(toclipboard) == "function" then
            copied = pcall(toclipboard, loadstringText)
        end

        if copied then
            status.Text = T("loadstringCopied")
            copyButton.Text = T("copied")
            task.delay(1.0, function()
                if copyButton and copyButton.Parent then
                    copyButton.Text = T("copyLoadstring")
                end
            end)
        else
            status.Text = T("loadstringCopyFailed")
        end
    end)

    button.MouseButton1Click:Connect(function()
        if closing then return end

        local activeTitle = localizedTitle(data)
        button.Text = T("loading")
        status.Text = string.format(T("preparing"), activeTitle)

        task.spawn(function()
            local ok, result = pcall(function()
                local src = game:HttpGet(data.URL, true)
                local fn, err = loadstring(src)
                if not fn then error(err) end
                return fn
            end)

            if not ok then
                if button and button.Parent then button.Text = "ERROR" end
                status.Text = string.format(T("loadError"), activeTitle)
                warn("[H3X4 Loader] " .. tostring(result))
                task.wait(1.1)
                if button and button.Parent then button.Text = T("execute") end
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
        Data = data,
        TitleLabel = titleLabel,
        DescriptionLabel = descriptionLabel,
        Button = button,
        DetailsButton = detailsButton,
        CopyButton = copyButton,
        FavoriteButton = favoriteButton,
        TagLabel = tagLabel,
        Title = title:lower(),
        Description = description:lower(),
        Tag = tag and tag.Title:lower() or "",
    })
end

local function updateSearch()
    local q = search.Text:lower()
    local found = 0

    for _, c in ipairs(cards) do
        local visible = q == ""
            or string.find(c.Title, q, 1, true) ~= nil
            or string.find(c.Description, q, 1, true) ~= nil
            or string.find(c.Tag or "", q, 1, true) ~= nil

        c.Frame.Visible = visible
        if visible then
            found += 1
        end
    end

    if q == "" then
        noResults.Visible = false
        status.Text = (#cards == 1) and T("oneAvailable") or string.format(T("available"), #cards)
    else
        noResults.Visible = found == 0
        status.Text = (found == 1) and T("oneResult") or string.format(T("results"), found)
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
            error(T("catalogTableError"))
        end
        return catalog
    end)

    if not ok then
        status.Text = T("catalogError")
        countBadge.Text = "0 " .. T("scripts")
        warn("[H3X4 Loader] " .. tostring(result))
        return
    end

    -- Orden manual de recientes: se respeta exactamente el orden de loaders.lua.
    -- Pon primero el script que quieras mostrar como más reciente.
    for i, data in ipairs(result) do
        if typeof(data) == "table" then
            createCard(data, i)
        end
    end

    countBadge.Text = tostring(#cards) .. " " .. ((#cards == 1) and T("script") or T("scripts"))
    status.Text = (#cards == 1) and T("oneAvailable") or string.format(T("available"), #cards)
end


local catalogLoaded = false

local function refreshCardsLanguage()
    for _, c in ipairs(cards) do
        if c.Data then
            local title = localizedTitle(c.Data)
            local description = localizedDescription(c.Data)

            c.Title = title:lower()
            c.Description = description:lower()

            if c.TitleLabel and c.TitleLabel.Parent then
                c.TitleLabel.Text = title
            end
            if c.DescriptionLabel and c.DescriptionLabel.Parent then
                c.DescriptionLabel.Text = description
            end
            if c.Button and c.Button.Parent then
                c.Button.Text = T("execute")
            end
            if c.CopyButton and c.CopyButton.Parent then
                c.CopyButton.Text = T("copyLoadstring")
            end
            if c.DetailsButton and c.DetailsButton.Parent then
                c.DetailsButton.Text = T("details")
            end
            local tag = getTag(c.Data)
            c.Tag = tag and tag.Title:lower() or ""
        end
    end
end

local function applyLanguageToUI()
    subtitleLabel.Text = T("loaderSubtitle")
    search.PlaceholderText = T("search")
    noResults.Text = T("noResults")
    languageButton.Text = string.upper(currentLanguage)
    detailsHeader.Text = T("detailsTitle")
    if detailsShade.Visible and currentDetailsData then
        refreshDetails()
    end

    if not catalogLoaded then
        status.Text = T("loadingScripts")
        countBadge.Text = "0 " .. T("scripts")
    else
        refreshCardsLanguage()
        countBadge.Text = tostring(#cards) .. " " .. ((#cards == 1) and T("script") or T("scripts"))
        updateSearch()
    end
end

local function openMainLoader()
    applyLanguageToUI()
    main.Visible = true
    scale.Scale = 0.82
    overlay.BackgroundTransparency = 1
    TweenService:Create(overlay, TweenInfo.new(0.25), {BackgroundTransparency = 0.36}):Play()
    TweenService:Create(scale, TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()

    if not catalogLoaded then
        catalogLoaded = true
        loadCatalog()
    end
end

local function hideLanguageSelector()
    applyLanguageToUI()
    TweenService:Create(languagePanelScale, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = 0.9}):Play()
    TweenService:Create(languageScreen, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()

    task.delay(0.21, function()
        languageScreen.Visible = false
        languageScreen.BackgroundTransparency = 0
        openMainLoader()
    end)
end

local function openLanguageSelector()
    languageChosen = false
    rememberChoice = readRememberedLanguage() ~= nil
    updateRememberButton()

    languageScreen.BackgroundTransparency = 0
    languageScreen.Visible = true
    languagePanelScale.Scale = 0.86
    TweenService:Create(languagePanelScale, TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
end

languageCallbacks.onSelected = hideLanguageSelector

languageButton.MouseButton1Click:Connect(function()
    if closing then
        return
    end
    openLanguageSelector()
end)

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

-- Detecta automáticamente si el loader se está usando desde móvil o PC.
-- En móvil usa un tamaño compacto; en PC sigue siendo más grande, pero más contenido.
local function isMobileDevice()
    return cardIsMobile()
end

local function resize()
    if not cam then
        return
    end

    local v = cam.ViewportSize
    local mobile = isMobileDevice()
    local width
    local height

    if mobile then
        -- Celular: un poco más compacto.
        width = math.clamp(v.X - 24, 306, 420)
        height = math.clamp(v.Y - 38, 304, 335)
    else
        -- PC: más grande que móvil, pero reducido respecto a la versión anterior.
        width = math.min(math.clamp(v.X * 0.55, 500, 610), math.max(306, v.X - 36))
        height = math.min(math.clamp(v.Y * 0.56, 370, 430), math.max(304, v.Y - 46))
    end

    main.Size = UDim2.fromOffset(width, height)

    -- Una tarjeta por fila solo cuando el ancho es realmente pequeño.
    -- En PC se mantienen dos columnas, pero cada tarjeta aprovecha el espacio extra.
    if width < 350 then
        grid.FillDirectionMaxCells = 1
        grid.CellSize = UDim2.new(1, -8, 0, 190)
    else
        grid.FillDirectionMaxCells = 2
        grid.CellSize = UDim2.new(0.5, -6, 0, mobile and 190 or 270)
    end
end

resize()
if cam then
    cam:GetPropertyChangedSignal("ViewportSize"):Connect(resize)
end

-- Si cambian las capacidades de entrada (por ejemplo, teclado/ratón conectado),
-- vuelve a calcular automáticamente el tamaño del panel.
UIS:GetPropertyChangedSignal("TouchEnabled"):Connect(resize)
UIS:GetPropertyChangedSignal("KeyboardEnabled"):Connect(resize)
UIS:GetPropertyChangedSignal("MouseEnabled"):Connect(resize)

if rememberedLanguage ~= nil then
    openMainLoader()
end
