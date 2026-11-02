if not game:IsLoaded() then
	game.Loaded:Wait()
end
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
	task.wait()
	LocalPlayer = Players.LocalPlayer
end
local genv = (getgenv and getgenv()) or _G
if genv.AnimeAdventureHub and genv.AnimeAdventureHub.destroy then
	pcall(genv.AnimeAdventureHub.destroy)
end

local OrderUI = (function()
    local library = {}
    local uiInput = cloneref(game:GetService("UserInputService"))
    local uiTween = cloneref(game:GetService("TweenService"))
    local uiPlayers = cloneref(game:GetService("Players"))
    local theme = {
        Base = Color3.fromRGB(14, 14, 14),
        Rail = Color3.fromRGB(8, 8, 8),
        Card = Color3.fromRGB(22, 22, 22),
        CardStroke = Color3.fromRGB(42, 42, 42),
        Line = Color3.fromRGB(34, 34, 34),
        Field = Color3.fromRGB(32, 32, 32),
        FieldHover = Color3.fromRGB(44, 44, 44),
        Off = Color3.fromRGB(58, 58, 58),
        Text = Color3.fromRGB(245, 245, 245),
        TextOff = Color3.fromRGB(196, 196, 196),
        Sub = Color3.fromRGB(150, 150, 150),
        Muted = Color3.fromRGB(102, 102, 102),
        Accent = Color3.fromRGB(236, 118, 44),
        AccentText = Color3.fromRGB(250, 250, 250),
        AccentDark = Color3.fromRGB(236, 118, 44),
        AccentLight = Color3.fromRGB(250, 250, 250),
        Gold = Color3.fromRGB(236, 118, 44),
        GoldSoft = Color3.fromRGB(110, 62, 30),
        KnobOff = Color3.fromRGB(150, 150, 150),
        LogoImage = "rbxassetid://78067731406782",
        ShadowImage = "rbxassetid://6014261993",
        OnTint = Color3.fromRGB(36, 23, 14),
        TabTop = Color3.fromRGB(246, 142, 64),
        TabBottom = Color3.fromRGB(220, 94, 32),
        GoodBg = Color3.fromRGB(30, 30, 30),
        GoodText = Color3.fromRGB(245, 245, 245),
        WarnBg = Color3.fromRGB(30, 30, 30),
        WarnText = Color3.fromRGB(150, 150, 150),
        StatusDot = Color3.fromRGB(236, 118, 44)
    }
    local fontFamily = "rbxasset://fonts/families/BuilderSans.json"
    local fontRegular = Font.new(fontFamily, Enum.FontWeight.Regular)
    local fontMedium = Font.new(fontFamily, Enum.FontWeight.Medium)
    local fontBold = Font.new(fontFamily, Enum.FontWeight.Bold)
    local dimAmount = 0.6

    local function create(className, props)
        local object = Instance.new(className)
        local parent = props.Parent
        props.Parent = nil
        if object:IsA("GuiObject") then
            object.BorderSizePixel = 0
        end
        for key, value in pairs(props) do
            object[key] = value
        end
        if parent then
            object.Parent = parent
        end
        return object
    end

    local function corner(parent, radius)
        return create("UICorner", { CornerRadius = UDim.new(0, radius), Parent = parent })
    end

    local function stroke(parent, color)
        return create("UIStroke", { Color = color, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = parent })
    end

    local function padding(parent, left, right, top, bottom)
        return create("UIPadding", {
            PaddingLeft = UDim.new(0, left),
            PaddingRight = UDim.new(0, right),
            PaddingTop = UDim.new(0, top),
            PaddingBottom = UDim.new(0, bottom),
            Parent = parent
        })
    end

    local function listLayout(parent, gap, horizontal)
        return create("UIListLayout", {
            Padding = UDim.new(0, gap),
            SortOrder = Enum.SortOrder.LayoutOrder,
            FillDirection = horizontal and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical,
            Parent = parent
        })
    end

    local function textLabel(props)
        local merged = {
            BackgroundTransparency = 1,
            FontFace = fontRegular,
            TextColor3 = theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            Text = ""
        }
        for key, value in pairs(props) do
            merged[key] = value
        end
        return create("TextLabel", merged)
    end

    local function clickArea(props)
        local merged = { BackgroundTransparency = 1, Text = "", AutoButtonColor = false }
        for key, value in pairs(props) do
            merged[key] = value
        end
        return create("TextButton", merged)
    end

    local function pill(parent, text, bg, fg, props, outline)
        local holder = create("Frame", {
            AnchorPoint = Vector2.new(1, 0.5),
            Size = UDim2.fromOffset(0, 20),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundColor3 = bg,
            Parent = parent
        })
        for key, value in pairs(props or {}) do
            holder[key] = value
        end
        corner(holder, 10)
        if outline then
            stroke(holder, outline)
        end
        padding(holder, 8, 8, 0, 0)
        local label = textLabel({
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            Text = text,
            FontFace = fontMedium,
            TextSize = 12,
            TextColor3 = fg,
            Parent = holder
        })
        return holder, label
    end

    local function chevron(parent, props)
        local holder = create("Frame", {
            AnchorPoint = Vector2.new(1, 0.5),
            Size = UDim2.fromOffset(12, 12),
            BackgroundTransparency = 1,
            Parent = parent
        })
        for key, value in pairs(props or {}) do
            holder[key] = value
        end
        for _, spec in ipairs({ { 3.5, 45 }, { 8.5, -45 } }) do
            create("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromOffset(spec[1], 6),
                Size = UDim2.fromOffset(7, 2),
                Rotation = spec[2],
                BackgroundColor3 = theme.Sub,
                Parent = holder
            })
        end
        return holder
    end

    local function tween(object, props, duration)
        pcall(function()
            uiTween:Create(object, TweenInfo.new(duration or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
        end)
    end

    local function isPress(input)
        return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
    end

    local function isMove(input)
        return input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch
    end

    local function fillArt(art, data)
        for _, child in ipairs(art:GetChildren()) do
            if not child:IsA("UICorner") and not child:IsA("UIStroke") and not child:IsA("UIGradient") then
                child:Destroy()
            end
        end
        if not art:FindFirstChildOfClass("UIGradient") then
            art.BackgroundColor3 = Color3.new(1, 1, 1)
            create("UIGradient", {
                Color = ColorSequence.new(Color3.fromRGB(40, 40, 40), Color3.fromRGB(10, 10, 10)),
                Rotation = 90,
                Parent = art
            })
        end
        local shown = false
        if typeof(data.Viewport) == "Instance" then
            pcall(function()
                local source = data.Viewport
                local copy = source:Clone()
                if copy then
                    copy.AnchorPoint = Vector2.new(0.5, 0.5)
                    copy.Position = UDim2.fromScale(0.5, 0.5)
                    copy.Size = UDim2.fromScale(1, 1)
                    copy.BackgroundTransparency = 1
                    copy.Visible = true
                    copy.ZIndex = 1
                    local camera = copy:FindFirstChildOfClass("Camera")
                    if not camera and source.CurrentCamera then
                        camera = Instance.new("Camera")
                        camera.CFrame = source.CurrentCamera.CFrame
                        camera.FieldOfView = source.CurrentCamera.FieldOfView
                        camera.Parent = copy
                    end
                    if camera then
                        copy.CurrentCamera = camera
                    end
                    for _, item in ipairs(copy:GetDescendants()) do
                        if item:IsA("GuiObject") then
                            item.Visible = false
                        end
                    end
                    if type(data.Prepare) == "function" then
                        pcall(data.Prepare, copy)
                    end
                    copy.Parent = art
                    local fade = create("Frame", {
                        AnchorPoint = Vector2.new(0, 1),
                        Position = UDim2.fromScale(0, 1),
                        Size = UDim2.fromScale(1, 0.32),
                        BackgroundColor3 = Color3.fromRGB(10, 10, 10),
                        ZIndex = 2,
                        Parent = art
                    })
                    create("UIGradient", {
                        Rotation = 90,
                        Transparency = NumberSequence.new(1, 0.1),
                        Parent = fade
                    })
                    shown = true
                end
            end)
        end
        if not shown and data.Image and tostring(data.Image) ~= "" then
            create("ImageLabel", {
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                Image = tostring(data.Image),
                ScaleType = Enum.ScaleType.Fit,
                Parent = art
            })
            shown = true
        end
        if not shown then
            textLabel({
                Size = UDim2.fromScale(1, 1),
                Text = tostring(data.Placeholder or "?"),
                FontFace = fontBold,
                TextSize = 22,
                TextColor3 = theme.Muted,
                TextXAlignment = Enum.TextXAlignment.Center,
                Parent = art
            })
        end
    end

    local function guiParent()
        local parent = nil
        pcall(function()
            parent = gethui()
        end)
        if not parent then
            pcall(function()
                parent = cloneref(game:GetService("CoreGui"))
            end)
        end
        if not parent then
            parent = uiPlayers.LocalPlayer:WaitForChild("PlayerGui")
        end
        return parent
    end

    function library:Window(settings)
        settings = settings or {}
        local window = {}
        local connections = {}
        local tabs = {}
        local popups = {}
        local currentTab = nil
        local searchQuery = ""
        local groupCount = 0
        local orderCounter = 0
        local windowState = true
        local unloaded = false
        local unloadCallback = nil
        local notificationsEnabled = true
        local menuKey = settings.Keybind or Enum.KeyCode.RightControl

        local function track(connection)
            table.insert(connections, connection)
            return connection
        end

        local function nextOrder()
            orderCounter = orderCounter + 1
            return orderCounter
        end

        local screen = create("ScreenGui", {
            Name = "OrderHubModern",
            ResetOnSpawn = false,
            IgnoreGuiInset = true,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            DisplayOrder = 50
        })

        local holder = create("Frame", {
            Name = "Holder",
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = settings.Size or UDim2.fromOffset(800, 500),
            BackgroundTransparency = 1,
            Parent = screen
        })
        local baseScale = create("UIScale", { Scale = 1, Parent = holder })
        local userScale = 1
        local scaleTween = nil

        local function animateScale(target, duration)
            if scaleTween then
                pcall(function()
                    scaleTween:Cancel()
                end)
                scaleTween = nil
            end
            pcall(function()
                scaleTween = uiTween:Create(baseScale, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = target })
                scaleTween:Play()
            end)
        end
        create("ImageLabel", {
            Name = "Shadow",
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.new(1, 80, 1, 80),
            BackgroundTransparency = 1,
            Image = theme.ShadowImage,
            ImageColor3 = Color3.new(0, 0, 0),
            ImageTransparency = 0.35,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(49, 49, 450, 450),
            ZIndex = 0,
            Parent = holder
        })
        local base = create("Frame", {
            Name = "Base",
            Size = UDim2.fromScale(1, 1),
            BackgroundColor3 = theme.Base,
            ClipsDescendants = true,
            Parent = holder
        })
        corner(base, 16)
        stroke(base, theme.CardStroke)

        local rail = create("Frame", {
            Name = "Rail",
            Size = UDim2.new(0, 72, 1, 0),
            BackgroundColor3 = theme.Rail,
            Parent = base
        })
        corner(rail, 16)
        create("Frame", {
            Size = UDim2.new(0, 16, 1, 0),
            Position = UDim2.new(1, -16, 0, 0),
            BackgroundColor3 = theme.Rail,
            Parent = rail
        })
        create("Frame", {
            Size = UDim2.new(0, 1, 1, 0),
            Position = UDim2.new(1, 0, 0, 0),
            BackgroundColor3 = theme.Line,
            Parent = rail
        })

        local logo = create("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0),
            Position = UDim2.new(0.5, 0, 0, 10),
            Size = UDim2.fromOffset(40, 40),
            BackgroundTransparency = 1,
            Image = tostring(settings.Logo or theme.LogoImage),
            ScaleType = Enum.ScaleType.Fit,
            Parent = rail
        })
        corner(logo, 11)

        local railList = create("ScrollingFrame", {
            Position = UDim2.new(0, 0, 0, 58),
            Size = UDim2.new(1, 0, 1, -62),
            BackgroundTransparency = 1,
            ScrollBarThickness = 0,
            CanvasSize = UDim2.new(),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            Parent = rail
        })
        local railLayout = listLayout(railList, 2)
        railLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        padding(railList, 0, 0, 2, 6)

        local content = create("Frame", {
            Position = UDim2.new(0, 73, 0, 0),
            Size = UDim2.new(1, -73, 1, 0),
            BackgroundTransparency = 1,
            Parent = base
        })

        local header = create("Frame", {
            Size = UDim2.new(1, 0, 0, 58),
            BackgroundTransparency = 1,
            Parent = content
        })
        local dragHandle = create("Frame", {
            Size = UDim2.new(1, -330, 1, 0),
            BackgroundTransparency = 1,
            Active = true,
            Parent = header
        })
        local titleLabel = textLabel({
            Position = UDim2.new(0, 20, 0, 12),
            Size = UDim2.new(1, -20, 0, 18),
            Text = tostring(settings.Title or "Hub"),
            FontFace = fontBold,
            TextSize = 17,
            Parent = dragHandle
        })
        local subtitleLabel = textLabel({
            Position = UDim2.new(0, 20, 0, 31),
            Size = UDim2.new(1, -20, 0, 14),
            Text = tostring(settings.Subtitle or ""),
            TextSize = 12,
            TextColor3 = theme.Sub,
            Parent = dragHandle
        })

        local searchFrame = create("Frame", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -94, 0.5, 0),
            Size = UDim2.fromOffset(220, 32),
            BackgroundColor3 = theme.Field,
            Parent = header
        })
        corner(searchFrame, 10)
        local searchStroke = stroke(searchFrame, theme.CardStroke)
        local searchIcon = create("Frame", {
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 11, 0.5, 0),
            Size = UDim2.fromOffset(14, 14),
            BackgroundTransparency = 1,
            Parent = searchFrame
        })
        local searchRing = create("Frame", {
            Size = UDim2.fromOffset(10, 10),
            BackgroundTransparency = 1,
            Parent = searchIcon
        })
        corner(searchRing, 5)
        stroke(searchRing, theme.Muted).Thickness = 1.5
        create("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromOffset(11, 11),
            Size = UDim2.fromOffset(5, 2),
            Rotation = 45,
            BackgroundColor3 = theme.Muted,
            Parent = searchIcon
        })
        local searchBox = create("TextBox", {
            Position = UDim2.new(0, 32, 0, 0),
            Size = UDim2.new(1, -60, 1, 0),
            BackgroundTransparency = 1,
            ClearTextOnFocus = false,
            Text = "",
            PlaceholderText = "Search this tab",
            PlaceholderColor3 = theme.Muted,
            TextColor3 = theme.Text,
            FontFace = fontRegular,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = searchFrame
        })
        local searchClear = clickArea({
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -6, 0.5, 0),
            Size = UDim2.fromOffset(22, 22),
            Text = "X",
            FontFace = fontMedium,
            TextSize = 12,
            TextColor3 = theme.Muted,
            Visible = false,
            Parent = searchFrame
        })

        local minimizeButton = clickArea({
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -54, 0.5, 0),
            Size = UDim2.fromOffset(32, 32),
            BackgroundTransparency = 0,
            BackgroundColor3 = theme.Field,
            Parent = header
        })
        corner(minimizeButton, 9)
        create("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(11, 2),
            BackgroundColor3 = theme.Sub,
            Parent = minimizeButton
        })

        local closeButton = clickArea({
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -16, 0.5, 0),
            Size = UDim2.fromOffset(32, 32),
            BackgroundTransparency = 0,
            BackgroundColor3 = theme.Field,
            Text = "X",
            FontFace = fontMedium,
            TextSize = 14,
            TextColor3 = theme.Sub,
            Parent = header
        })
        corner(closeButton, 9)

        create("Frame", {
            Position = UDim2.new(0, 0, 0, 58),
            Size = UDim2.new(1, 0, 0, 1),
            BackgroundColor3 = theme.Line,
            Parent = content
        })

        local pageTitle = textLabel({
            Position = UDim2.new(0, 20, 0, 68),
            Size = UDim2.new(1, -40, 0, 24),
            FontFace = fontBold,
            TextSize = 20,
            Parent = content
        })
        local pageDescription = textLabel({
            Position = UDim2.new(0, 20, 0, 92),
            Size = UDim2.new(1, -40, 0, 16),
            TextSize = 13,
            TextColor3 = theme.Muted,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = content
        })

        local footerHeight = 32
        local pages = create("Frame", {
            Position = UDim2.new(0, 0, 0, 118),
            Size = UDim2.new(1, 0, 1, -118 - footerHeight),
            BackgroundTransparency = 1,
            ClipsDescendants = true,
            Parent = content
        })
        local footer = create("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            Position = UDim2.new(0, 0, 1, 0),
            Size = UDim2.new(1, 0, 0, footerHeight),
            BackgroundColor3 = theme.Rail,
            Parent = content
        })
        create("Frame", {
            Size = UDim2.new(1, 0, 0, 1),
            BackgroundColor3 = theme.Line,
            Parent = footer
        })
        local statusDot = create("Frame", {
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 20, 0.5, 0),
            Size = UDim2.fromOffset(7, 7),
            BackgroundColor3 = theme.Muted,
            Parent = footer
        })
        corner(statusDot, 4)
        local statusLabel = textLabel({
            Position = UDim2.new(0, 34, 0, 0),
            Size = UDim2.new(1, -190, 1, 0),
            Text = "Ready",
            TextSize = 12,
            TextColor3 = theme.Sub,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = footer
        })
        local keyHint = textLabel({
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -18, 0, 0),
            Size = UDim2.new(0, 150, 1, 0),
            Text = tostring(menuKey.Name) .. " to hide",
            TextSize = 12,
            TextColor3 = theme.Muted,
            TextXAlignment = Enum.TextXAlignment.Right,
            Parent = footer
        })
        local statusExplicit = false
        local statusSource = nil

        local function setFooter(text, active)
            statusLabel.Text = tostring(text)
            statusDot.BackgroundColor3 = active and theme.Accent or theme.Muted
        end

        local function footerFromBody(body)
            local plain = string.gsub(tostring(body or ""), "<[^>]+>", "")
            local parts = {}
            for line in string.gmatch(plain, "[^\n]+") do
                local trimmed = string.match(line, "^%s*(.-)%s*$")
                if trimmed ~= "" then
                    table.insert(parts, trimmed)
                end
            end
            if #parts == 0 then
                return "Ready", false
            end
            local first = string.lower(parts[1])
            local idle = string.find(first, "idle", 1, true) ~= nil or string.find(first, "loading", 1, true) ~= nil
            return table.concat(parts, "   |   "), not idle
        end
        local emptyLabel = textLabel({
            Position = UDim2.new(0, 20, 0, 10),
            Size = UDim2.new(1, -40, 0, 20),
            Text = "Nothing in this tab matches your search.",
            TextColor3 = theme.Muted,
            Visible = false,
            ZIndex = 3,
            Parent = pages
        })

        local toastHolder = create("Frame", {
            AnchorPoint = Vector2.new(1, 1),
            Position = UDim2.new(1, -16, 1, -16),
            Size = UDim2.fromOffset(280, 400),
            BackgroundTransparency = 1,
            Parent = screen
        })
        local toastLayout = listLayout(toastHolder, 8)
        toastLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom

        local function applyFilter()
            local anyInCurrent = false
            local pagesToFilter = table.clone(tabs)
            for _, popup in ipairs(popups) do
                table.insert(pagesToFilter, popup)
            end
            for _, tab in ipairs(pagesToFilter) do
                local query = (tab == currentTab) and searchQuery or ""
                for _, card in ipairs(tab.Cards) do
                    local titleMatch = query == "" or string.find(string.lower(card.Title), query, 1, true) ~= nil
                    local anyVisible = false
                    local anyMatch = false
                    for _, entry in ipairs(card.Entries) do
                        local match = titleMatch or string.find(entry.Name, query, 1, true) ~= nil
                        local usable = (not entry.Hidden) and match
                        if usable then
                            anyMatch = true
                        end
                        local visible = usable and (query ~= "" or not card.Collapsed)
                        entry.Frame.Visible = visible
                        if visible then
                            anyVisible = true
                        end
                    end
                    local cardVisible = (not card.Hidden) and (anyMatch or (#card.Entries == 0 and titleMatch))
                    if card.HasHead and card.Collapsed and query == "" then
                        cardVisible = (not card.Hidden) and (anyMatch or #card.Entries == 0)
                    end
                    card.Frame.Visible = cardVisible
                    if card.Chevron then
                        card.Chevron.Rotation = (card.Collapsed and query == "") and -90 or 0
                    end
                    if card.HeadLine then
                        card.HeadLine.Visible = anyVisible
                    end
                    if tab == currentTab and cardVisible then
                        anyInCurrent = true
                    end
                end
            end
            emptyLabel.Visible = searchQuery ~= "" and not anyInCurrent
        end

        local function selectTab(tab)
            currentTab = tab
            for _, other in ipairs(tabs) do
                local active = other == tab
                other.Page.Visible = active
                other.Button.BackgroundTransparency = active and 0 or 1
                other.Icon.ImageColor3 = active and theme.AccentLight or theme.Sub
                other.NameLabel.TextColor3 = active and theme.AccentLight or theme.Sub
                other.Indicator.Visible = active
            end
            pageTitle.Text = tab.Name
            pageDescription.Text = tab.Description
            local hasDescription = tab.Description ~= ""
            pageDescription.Visible = hasDescription
            local top = hasDescription and 118 or 100
            pages.Position = UDim2.new(0, 0, 0, top)
            pages.Size = UDim2.new(1, 0, 1, 0 - top - footerHeight)
            tab.Page.CanvasPosition = Vector2.new(0, 0)
            tab.Page.Position = UDim2.fromOffset(0, 12)
            tween(tab.Page, { Position = UDim2.fromOffset(0, 0) }, 0.22)
            applyFilter()
        end

        local function makeSection(tab, sectionSettings)
            local side = (typeof(sectionSettings) == "table" and sectionSettings.Side == "Right") and "Right" or "Left"
            local container = create("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                LayoutOrder = nextOrder(),
                Parent = tab.Columns[side]
            })
            listLayout(container, 12)

            local section = {}
            local currentCard = nil

            local function refreshEntryDim(entry)
                local dim = entry.Card.Locked or entry.Done
                for _, target in ipairs(entry.Dimmables) do
                    local object, property, baseValue = target[1], target[2], target[3]
                    object[property] = dim and (baseValue + (1 - baseValue) * dimAmount) or baseValue
                end
            end

            local function refreshCount(card)
                if not card.CountPill then
                    return
                end
                card.CountPill.Visible = card.OnCount > 0
                card.CountLabel.Text = tostring(card.OnCount) .. " on"
            end

            local function newCard(title)
                local card = { Title = title or "", Entries = {}, Hidden = false, NeedsLine = false, Collapsed = false, Locked = false, OnCount = 0 }
                card.Frame = create("Frame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = theme.Card,
                    LayoutOrder = nextOrder(),
                    Parent = container
                })
                corner(card.Frame, 12)
                stroke(card.Frame, theme.CardStroke)
                listLayout(card.Frame, 0)
                if title then
                    card.HasHead = true
                    local head = clickArea({
                        Size = UDim2.new(1, 0, 0, 42),
                        LayoutOrder = 0,
                        Parent = card.Frame
                    })
                    local chip = create("Frame", {
                        AnchorPoint = Vector2.new(0, 0.5),
                        Position = UDim2.new(0, 14, 0.5, 0),
                        Size = UDim2.fromOffset(4, 16),
                        BackgroundColor3 = theme.Gold,
                        Parent = head
                    })
                    corner(chip, 2)
                    card.TitleLabel = textLabel({
                        Position = UDim2.new(0, 26, 0, 0),
                        Size = UDim2.new(1, -150, 1, 0),
                        Text = string.upper(title),
                        FontFace = fontBold,
                        TextSize = 12,
                        TextColor3 = theme.Sub,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        Parent = head
                    })
                    card.Chevron = chevron(head, { Position = UDim2.new(1, -14, 0.5, 0) })
                    local badges = create("Frame", {
                        AnchorPoint = Vector2.new(1, 0.5),
                        Position = UDim2.new(1, -34, 0.5, 0),
                        Size = UDim2.fromOffset(0, 20),
                        AutomaticSize = Enum.AutomaticSize.X,
                        BackgroundTransparency = 1,
                        Parent = head
                    })
                    local badgeLayout = listLayout(badges, 6, true)
                    badgeLayout.VerticalAlignment = Enum.VerticalAlignment.Center
                    badgeLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
                    card.LockPill, card.LockLabel = pill(badges, "Locked", theme.WarnBg, theme.WarnText, { AnchorPoint = Vector2.new(0, 0), LayoutOrder = 1, Visible = false }, theme.CardStroke)
                    card.CountPill, card.CountLabel = pill(badges, "0 on", theme.GoodBg, theme.Text, { AnchorPoint = Vector2.new(0, 0), LayoutOrder = 2, Visible = false }, theme.GoldSoft)
                    card.HeadLine = create("Frame", {
                        Position = UDim2.new(0, 0, 1, -1),
                        Size = UDim2.new(1, 0, 0, 1),
                        BackgroundColor3 = theme.Line,
                        Parent = head
                    })
                    track(head.MouseButton1Click:Connect(function()
                        if searchQuery ~= "" then
                            return
                        end
                        card.Collapsed = not card.Collapsed
                        applyFilter()
                    end))
                end
                table.insert(tab.Cards, card)
                currentCard = card
                return card
            end

            local function addRow(height, name)
                local card = currentCard or newCard(nil)
                local row = create("Frame", {
                    Size = UDim2.new(1, 0, 0, height),
                    BackgroundColor3 = theme.FieldHover,
                    BackgroundTransparency = 1,
                    LayoutOrder = nextOrder(),
                    Parent = card.Frame
                })
                if height > 0 then
                    local tint = create("Frame", {
                        Name = "Tint",
                        Position = UDim2.new(0, 5, 0, 3),
                        Size = UDim2.new(1, -10, 0, height - 6),
                        BackgroundColor3 = theme.FieldHover,
                        BackgroundTransparency = 1,
                        ZIndex = 0,
                        Parent = row
                    })
                    corner(tint, 8)
                end
                if card.NeedsLine then
                    create("Frame", {
                        Position = UDim2.new(0, 14, 0, 0),
                        Size = UDim2.new(1, -28, 0, 1),
                        BackgroundColor3 = theme.Line,
                        Parent = row
                    })
                end
                card.NeedsLine = true
                local entry = { Frame = row, Name = string.lower(tostring(name or "")), Hidden = false, Card = card, Done = false, Dimmables = {} }
                table.insert(card.Entries, entry)
                return row, entry
            end

            local function dimmable(entry, object, property)
                table.insert(entry.Dimmables, { object, property, object[property] })
            end

            local function commonApi(api, entry, nameLabel)
                function api:UpdateName(newName)
                    if nameLabel then
                        nameLabel.Text = tostring(newName)
                    end
                    entry.Name = string.lower(tostring(newName))
                    applyFilter()
                end
                function api:SetVisibility(visible)
                    entry.Hidden = not visible
                    applyFilter()
                end
                return api
            end

            local function hoverRow(button, row, isOn)
                local tint = row:FindFirstChild("Tint")
                if not tint then
                    return function() end
                end
                local hovering = false
                local function paint()
                    local on = isOn ~= nil and isOn() == true
                    tint.BackgroundColor3 = on and theme.OnTint or theme.FieldHover
                    tween(tint, { BackgroundTransparency = on and 0 or (hovering and 0.4 or 1) }, 0.14)
                end
                track(button.MouseEnter:Connect(function()
                    hovering = true
                    paint()
                end))
                track(button.MouseLeave:Connect(function()
                    hovering = false
                    paint()
                end))
                return paint
            end

            function section:Header(headerSettings)
                local title = tostring((headerSettings and (headerSettings.Text or headerSettings.Name)) or "")
                local card = newCard(title)
                local api = {}
                function api:UpdateName(newName)
                    card.Title = tostring(newName)
                    if card.TitleLabel then
                        card.TitleLabel.Text = string.upper(card.Title)
                    end
                    applyFilter()
                end
                function api:SetVisibility(visible)
                    card.Hidden = not visible
                    applyFilter()
                end
                function api:SetLocked(locked, note)
                    card.Locked = locked == true
                    card.LockPill.Visible = card.Locked
                    card.LockLabel.Text = tostring(note or "Locked")
                    for _, entry in ipairs(card.Entries) do
                        refreshEntryDim(entry)
                    end
                end
                function api:SetCollapsed(collapsed)
                    card.Collapsed = collapsed == true
                    applyFilter()
                end
                return api
            end

            function section:Toggle(toggleSettings)
                local row, entry = addRow(40, toggleSettings.Name)
                local card = entry.Card
                local state = toggleSettings.Default == true
                local button = clickArea({ Size = UDim2.fromScale(1, 1), ZIndex = 2, Parent = row })
                local nameLabel = textLabel({
                    Position = UDim2.new(0, 14, 0, 0),
                    Size = UDim2.new(1, -74, 1, 0),
                    Text = tostring(toggleSettings.Name or ""),
                    TextColor3 = state and theme.Text or theme.TextOff,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    Parent = row
                })
                local switch = create("Frame", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -14, 0.5, 0),
                    Size = UDim2.fromOffset(38, 22),
                    BackgroundColor3 = state and theme.Accent or theme.Off,
                    Parent = row
                })
                corner(switch, 11)
                local knob = create("Frame", {
                    AnchorPoint = Vector2.new(0, 0.5),
                    Position = state and UDim2.new(0, 19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
                    Size = UDim2.fromOffset(16, 16),
                    BackgroundColor3 = state and theme.AccentText or theme.KnobOff,
                    Parent = switch
                })
                corner(knob, 8)
                local donePill = pill(row, "Done", theme.GoodBg, theme.GoodText, { Position = UDim2.new(1, -60, 0.5, 0), Visible = false }, theme.GoldSoft)
                dimmable(entry, nameLabel, "TextTransparency")
                dimmable(entry, switch, "BackgroundTransparency")
                dimmable(entry, knob, "BackgroundTransparency")
                if card.Locked then
                    refreshEntryDim(entry)
                end
                if state then
                    card.OnCount = card.OnCount + 1
                    refreshCount(card)
                end

                local paintRow = hoverRow(button, row, function()
                    return state
                end)
                paintRow()

                local function setState(newState)
                    local before = state
                    state = newState and true or false
                    if before ~= state then
                        card.OnCount = math.max(0, card.OnCount + (state and 1 or -1))
                        refreshCount(card)
                    end
                    tween(switch, { BackgroundColor3 = state and theme.Accent or theme.Off })
                    tween(knob, { Position = state and UDim2.new(0, 19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0), BackgroundColor3 = state and theme.AccentText or theme.KnobOff })
                    nameLabel.TextColor3 = state and theme.Text or theme.TextOff
                    paintRow()
                end

                local api = commonApi({}, entry, nameLabel)
                function api:UpdateState(newState)
                    setState(newState)
                    if toggleSettings.Callback then
                        toggleSettings.Callback(state)
                    end
                end
                function api:Toggle()
                    api:UpdateState(not state)
                end
                function api:GetState()
                    return state
                end
                function api:SetDone(done)
                    entry.Done = done == true
                    donePill.Visible = entry.Done
                    nameLabel.Size = entry.Done and UDim2.new(1, -130, 1, 0) or UDim2.new(1, -74, 1, 0)
                    refreshEntryDim(entry)
                end

                track(button.MouseButton1Click:Connect(function()
                    setState(not state)
                    if toggleSettings.Callback then
                        toggleSettings.Callback(state)
                    end
                end))
                return api
            end

            function section:Button(buttonSettings)
                local row, entry = addRow(40, buttonSettings.Name)
                local button = clickArea({ Size = UDim2.fromScale(1, 1), ZIndex = 2, Parent = row })
                local nameLabel = textLabel({
                    Position = UDim2.new(0, 14, 0, 0),
                    Size = UDim2.new(1, -96, 1, 0),
                    Text = tostring(buttonSettings.Name or ""),
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    Parent = row
                })
                local runPill = create("Frame", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -14, 0.5, 0),
                    Size = UDim2.fromOffset(60, 26),
                    BackgroundColor3 = theme.Field,
                    Parent = row
                })
                corner(runPill, 8)
                stroke(runPill, theme.CardStroke)
                local runLabel = textLabel({
                    Size = UDim2.fromScale(1, 1),
                    Text = "Run",
                    FontFace = fontMedium,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    Parent = runPill
                })
                dimmable(entry, nameLabel, "TextTransparency")
                dimmable(entry, runLabel, "TextTransparency")
                if entry.Card.Locked then
                    refreshEntryDim(entry)
                end
                local api = commonApi({}, entry, nameLabel)
                hoverRow(button, row)
                track(button.MouseButton1Click:Connect(function()
                    runPill.BackgroundColor3 = theme.Off
                    tween(runPill, { BackgroundColor3 = theme.Field }, 0.4)
                    if buttonSettings.Callback then
                        buttonSettings.Callback()
                    end
                end))
                return api
            end

            function section:Slider(sliderSettings)
                local row, entry = addRow(60, sliderSettings.Name)
                local minimum = tonumber(sliderSettings.Minimum) or 0
                local maximum = tonumber(sliderSettings.Maximum) or 100
                local precision = tonumber(sliderSettings.Precision) or 0
                local value = minimum
                local sliding = false
                local nameLabel = textLabel({
                    Position = UDim2.new(0, 14, 0, 8),
                    Size = UDim2.new(1, -100, 0, 22),
                    Text = tostring(sliderSettings.Name or ""),
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    Parent = row
                })
                local valueBox = create("Frame", {
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(1, -14, 0, 8),
                    Size = UDim2.fromOffset(0, 22),
                    AutomaticSize = Enum.AutomaticSize.X,
                    BackgroundColor3 = theme.Field,
                    Parent = row
                })
                corner(valueBox, 7)
                padding(valueBox, 8, 8, 0, 0)
                local valueLabel = create("TextBox", {
                    Size = UDim2.new(0, 0, 1, 0),
                    AutomaticSize = Enum.AutomaticSize.X,
                    BackgroundTransparency = 1,
                    ClearTextOnFocus = false,
                    TextSize = 13,
                    FontFace = fontMedium,
                    TextColor3 = theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    Text = "",
                    Parent = valueBox
                })
                local bar = clickArea({
                    Position = UDim2.new(0, 14, 0, 42),
                    Size = UDim2.new(1, -28, 0, 6),
                    BackgroundTransparency = 0,
                    BackgroundColor3 = theme.Off,
                    Parent = row
                })
                corner(bar, 3)
                local fill = create("Frame", {
                    Size = UDim2.fromScale(0, 1),
                    BackgroundColor3 = theme.Accent,
                    Parent = bar
                })
                corner(fill, 3)
                local knob = create("Frame", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.fromScale(0, 0.5),
                    Size = UDim2.fromOffset(14, 14),
                    BackgroundColor3 = theme.Text,
                    Parent = bar
                })
                corner(knob, 7)
                stroke(knob, theme.Base).Thickness = 2
                dimmable(entry, nameLabel, "TextTransparency")
                dimmable(entry, valueLabel, "TextTransparency")
                dimmable(entry, fill, "BackgroundTransparency")
                if entry.Card.Locked then
                    refreshEntryDim(entry)
                end

                local function roundValue(raw)
                    local factor = 10 ^ precision
                    return math.floor(raw * factor + 0.5) / factor
                end

                local function formatValue(raw)
                    if precision > 0 then
                        return string.format("%." .. tostring(precision) .. "f", raw)
                    end
                    return tostring(math.floor(raw + 0.5))
                end

                local function setValue(raw, fire)
                    local clamped = math.clamp(tonumber(raw) or minimum, minimum, math.max(minimum, maximum))
                    value = roundValue(clamped)
                    local span = maximum - minimum
                    local alpha = span > 0 and (value - minimum) / span or 0
                    fill.Size = UDim2.fromScale(alpha, 1)
                    knob.Position = UDim2.fromScale(alpha, 0.5)
                    valueLabel.Text = formatValue(value)
                    if fire and sliderSettings.Callback then
                        sliderSettings.Callback(value)
                    end
                end

                local function slideTo(x)
                    local width = bar.AbsoluteSize.X
                    if width <= 0 then
                        return
                    end
                    local alpha = math.clamp((x - bar.AbsolutePosition.X) / width, 0, 1)
                    local nextValue = roundValue(minimum + (maximum - minimum) * alpha)
                    if nextValue ~= value then
                        setValue(nextValue, true)
                    end
                end

                setValue(sliderSettings.Default, false)

                track(valueLabel.FocusLost:Connect(function()
                    local typed = tonumber(string.match(valueLabel.Text, "%-?%d+%.?%d*"))
                    if typed and roundValue(math.clamp(typed, minimum, math.max(minimum, maximum))) ~= value then
                        setValue(typed, true)
                    else
                        valueLabel.Text = formatValue(value)
                    end
                end))

                track(bar.InputBegan:Connect(function(input)
                    if isPress(input) then
                        sliding = true
                        slideTo(input.Position.X)
                    end
                end))
                track(uiInput.InputChanged:Connect(function(input)
                    if sliding and isMove(input) then
                        slideTo(input.Position.X)
                    end
                end))
                track(uiInput.InputEnded:Connect(function(input)
                    if isPress(input) then
                        sliding = false
                    end
                end))

                local api = commonApi({}, entry, nameLabel)
                function api:UpdateValue(newValue)
                    setValue(newValue, true)
                end
                function api:GetValue()
                    return value
                end
                return api
            end

            function section:Dropdown(dropdownSettings)
                local row, entry = addRow(40, dropdownSettings.Name)
                row.AutomaticSize = Enum.AutomaticSize.Y
                local multi = dropdownSettings.Multi == true
                local options = {}
                local optionObjects = {}
                local selected = {}
                local isOpen = false
                local api = {}

                local top = clickArea({ Size = UDim2.new(1, 0, 0, 40), ZIndex = 2, Parent = row })
                local nameLabel = textLabel({
                    Position = UDim2.new(0, 14, 0, 0),
                    Size = UDim2.new(0.5, -14, 0, 40),
                    Text = tostring(dropdownSettings.Name or ""),
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    Parent = row
                })
                local valueBox = create("Frame", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -14, 0, 20),
                    Size = UDim2.new(0.5, -14, 0, 28),
                    BackgroundColor3 = theme.Field,
                    Parent = row
                })
                corner(valueBox, 8)
                local valueStroke = stroke(valueBox, theme.CardStroke)
                local valueLabel = textLabel({
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -32, 1, 0),
                    TextSize = 13,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    Parent = valueBox
                })
                local arrow = chevron(valueBox, { Position = UDim2.new(1, -9, 0.5, 0) })
                dimmable(entry, nameLabel, "TextTransparency")
                dimmable(entry, valueLabel, "TextTransparency")
                if entry.Card.Locked then
                    refreshEntryDim(entry)
                end

                local listHolder = create("Frame", {
                    Position = UDim2.new(0, 0, 0, 40),
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Visible = false,
                    Parent = row
                })
                padding(listHolder, 14, 14, 0, 12)
                listLayout(listHolder, 6)

                local optionSearch = nil
                if dropdownSettings.Search then
                    local searchHolder = create("Frame", {
                        Size = UDim2.new(1, 0, 0, 30),
                        BackgroundColor3 = theme.Field,
                        LayoutOrder = 0,
                        Parent = listHolder
                    })
                    corner(searchHolder, 8)
                    optionSearch = create("TextBox", {
                        Position = UDim2.new(0, 10, 0, 0),
                        Size = UDim2.new(1, -20, 1, 0),
                        BackgroundTransparency = 1,
                        ClearTextOnFocus = false,
                        Text = "",
                        PlaceholderText = "Search options",
                        PlaceholderColor3 = theme.Muted,
                        TextColor3 = theme.Text,
                        FontFace = fontRegular,
                        TextSize = 13,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = searchHolder
                    })
                end

                local optionScroll = create("ScrollingFrame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    BackgroundTransparency = 1,
                    ScrollBarThickness = 3,
                    ScrollBarImageColor3 = theme.Off,
                    CanvasSize = UDim2.new(),
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    ScrollingDirection = Enum.ScrollingDirection.Y,
                    LayoutOrder = 1,
                    Parent = listHolder
                })
                listLayout(optionScroll, 2)

                local function optionIndex(name)
                    return table.find(options, name) or math.huge
                end

                local function refreshDisplay()
                    if multi then
                        table.sort(selected, function(a, b)
                            return optionIndex(a) < optionIndex(b)
                        end)
                    end
                    local display = "None"
                    if #selected > 3 then
                        display = tostring(selected[1]) .. ", " .. tostring(selected[2]) .. " +" .. tostring(#selected - 2)
                    elseif #selected > 0 then
                        local names = {}
                        for _, name in ipairs(selected) do
                            table.insert(names, tostring(name))
                        end
                        display = table.concat(names, ", ")
                    end
                    valueLabel.Text = display
                    valueLabel.TextColor3 = #selected > 0 and theme.Text or theme.Muted
                    for name, object in pairs(optionObjects) do
                        local picked = table.find(selected, name) ~= nil
                        object.Check.BackgroundColor3 = picked and theme.Accent or theme.Off
                        object.Dot.Visible = picked
                        object.Label.TextColor3 = picked and theme.Text or theme.Sub
                    end
                    api.Value = multi and table.clone(selected) or selected[1]
                end

                local function resizeList()
                    local query = optionSearch and string.lower(optionSearch.Text) or ""
                    local shown = 0
                    for name, object in pairs(optionObjects) do
                        local visible = query == "" or string.find(string.lower(tostring(name)), query, 1, true) ~= nil
                        object.Button.Visible = visible
                        if visible then
                            shown = shown + 1
                        end
                    end
                    optionScroll.Size = UDim2.new(1, 0, 0, math.min(shown, 7) * 32)
                end

                local function selectionMap()
                    local map = {}
                    for _, name in ipairs(selected) do
                        map[name] = true
                    end
                    return map
                end

                local function setOpen(open)
                    isOpen = open
                    listHolder.Visible = open
                    arrow.Rotation = open and 180 or 0
                    valueStroke.Color = open and theme.GoldSoft or theme.CardStroke
                end

                local function choose(name)
                    if multi then
                        local index = table.find(selected, name)
                        if index then
                            if dropdownSettings.Required and #selected <= 1 then
                                return
                            end
                            table.remove(selected, index)
                        else
                            table.insert(selected, name)
                        end
                        refreshDisplay()
                        if dropdownSettings.Callback then
                            dropdownSettings.Callback(selectionMap())
                        end
                    else
                        setOpen(false)
                        if selected[1] == name then
                            return
                        end
                        selected = { name }
                        refreshDisplay()
                        if dropdownSettings.Callback then
                            dropdownSettings.Callback(name)
                        end
                    end
                end

                local function addOption(name)
                    if optionObjects[name] then
                        return
                    end
                    local button = clickArea({
                        Size = UDim2.new(1, -6, 0, 30),
                        BackgroundTransparency = 1,
                        BackgroundColor3 = theme.FieldHover,
                        LayoutOrder = #options,
                        Parent = optionScroll
                    })
                    corner(button, 7)
                    local check = create("Frame", {
                        AnchorPoint = Vector2.new(0, 0.5),
                        Position = UDim2.new(0, 8, 0.5, 0),
                        Size = UDim2.fromOffset(16, 16),
                        BackgroundColor3 = theme.Off,
                        Parent = button
                    })
                    corner(check, multi and 5 or 8)
                    local dot = create("Frame", {
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.fromScale(0.5, 0.5),
                        Size = UDim2.fromOffset(6, 6),
                        BackgroundColor3 = theme.AccentText,
                        Visible = false,
                        Parent = check
                    })
                    corner(dot, 3)
                    local label = textLabel({
                        Position = UDim2.new(0, 32, 0, 0),
                        Size = UDim2.new(1, -38, 1, 0),
                        Text = tostring(name),
                        TextSize = 13,
                        TextColor3 = theme.Sub,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        Parent = button
                    })
                    optionObjects[name] = { Button = button, Check = check, Dot = dot, Label = label }
                    track(button.MouseEnter:Connect(function()
                        button.BackgroundTransparency = 0.4
                    end))
                    track(button.MouseLeave:Connect(function()
                        button.BackgroundTransparency = 1
                    end))
                    track(button.MouseButton1Click:Connect(function()
                        choose(name)
                    end))
                end

                local function applyDefault()
                    local default = dropdownSettings.Default
                    if multi then
                        if typeof(default) == "table" then
                            for _, name in ipairs(default) do
                                if table.find(options, name) and not table.find(selected, name) then
                                    table.insert(selected, name)
                                end
                            end
                        end
                    elseif typeof(default) == "number" then
                        if options[default] ~= nil then
                            selected = { options[default] }
                        end
                    elseif default ~= nil and table.find(options, default) then
                        selected = { default }
                    end
                end

                local function insertOptions(newOptions)
                    for _, name in ipairs(newOptions or {}) do
                        if not table.find(options, name) then
                            table.insert(options, name)
                            addOption(name)
                        end
                    end
                end

                insertOptions(dropdownSettings.Options)
                applyDefault()
                refreshDisplay()
                resizeList()

                if optionSearch then
                    track(optionSearch:GetPropertyChangedSignal("Text"):Connect(resizeList))
                end
                hoverRow(top, row)
                track(top.MouseButton1Click:Connect(function()
                    setOpen(not isOpen)
                end))

                commonApi(api, entry, nameLabel)
                function api:UpdateSelection(newSelection)
                    selected = {}
                    if typeof(newSelection) == "number" then
                        if options[newSelection] ~= nil then
                            selected = { options[newSelection] }
                        end
                    elseif typeof(newSelection) == "string" then
                        if table.find(options, newSelection) then
                            selected = { newSelection }
                        end
                    elseif typeof(newSelection) == "table" then
                        for key, item in pairs(newSelection) do
                            local name = nil
                            if typeof(key) == "number" then
                                name = item
                            elseif item then
                                name = key
                            end
                            if name ~= nil and table.find(options, name) and not table.find(selected, name) then
                                table.insert(selected, name)
                            end
                        end
                        if not multi and #selected > 1 then
                            selected = { selected[1] }
                        end
                    end
                    refreshDisplay()
                end
                function api:InsertOptions(newOptions)
                    dropdownSettings.Options = newOptions
                    insertOptions(newOptions)
                    if #selected == 0 then
                        applyDefault()
                    end
                    refreshDisplay()
                    resizeList()
                end
                function api:ClearOptions()
                    for _, object in pairs(optionObjects) do
                        object.Button:Destroy()
                    end
                    optionObjects = {}
                    options = {}
                    selected = {}
                    refreshDisplay()
                    resizeList()
                end
                function api:RemoveOptions(removeList)
                    for _, name in ipairs(removeList or {}) do
                        local object = optionObjects[name]
                        if object then
                            object.Button:Destroy()
                            optionObjects[name] = nil
                        end
                        local optionPos = table.find(options, name)
                        if optionPos then
                            table.remove(options, optionPos)
                        end
                        local selectedPos = table.find(selected, name)
                        if selectedPos then
                            table.remove(selected, selectedPos)
                        end
                    end
                    refreshDisplay()
                    resizeList()
                end
                function api:GetOptions()
                    local status = {}
                    for _, name in ipairs(options) do
                        status[name] = table.find(selected, name) ~= nil
                    end
                    return status
                end
                function api:IsOption(name)
                    return table.find(options, name) ~= nil
                end
                return api
            end

            function section:Paragraph(paragraphSettings)
                local row, entry = addRow(0, paragraphSettings.Header)
                row.AutomaticSize = Enum.AutomaticSize.Y
                local inner = create("Frame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Parent = row
                })
                padding(inner, 14, 14, 10, 12)
                listLayout(inner, 6)
                local headRow = create("Frame", {
                    Size = UDim2.new(1, 0, 0, 18),
                    BackgroundTransparency = 1,
                    LayoutOrder = 1,
                    Parent = inner
                })
                local dot = create("Frame", {
                    AnchorPoint = Vector2.new(0, 0.5),
                    Position = UDim2.new(0, 0, 0.5, 0),
                    Size = UDim2.fromOffset(7, 7),
                    BackgroundColor3 = theme.StatusDot,
                    Parent = headRow
                })
                corner(dot, 4)
                local headerLabel = textLabel({
                    Position = UDim2.new(0, 14, 0, 0),
                    Size = UDim2.new(1, -14, 1, 0),
                    Text = tostring(paragraphSettings.Header or ""),
                    FontFace = fontMedium,
                    Parent = headRow
                })
                local bodyHolder = create("Frame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = theme.Rail,
                    LayoutOrder = 2,
                    Parent = inner
                })
                corner(bodyHolder, 8)
                padding(bodyHolder, 10, 10, 8, 8)
                local bodyLabel = textLabel({
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Text = tostring(paragraphSettings.Body or ""),
                    TextSize = 13,
                    TextColor3 = theme.Sub,
                    TextWrapped = true,
                    RichText = true,
                    TextYAlignment = Enum.TextYAlignment.Top,
                    LineHeight = 1.15,
                    Parent = bodyHolder
                })
                local api = commonApi({}, entry, headerLabel)
                function api:UpdateHeader(newHeader)
                    api:UpdateName(newHeader)
                end
                function api:UpdateBody(newBody)
                    bodyLabel.Text = tostring(newBody)
                    if statusSource == api and not statusExplicit then
                        setFooter(footerFromBody(newBody))
                    end
                end
                if statusSource == nil and tostring(paragraphSettings.Header or "") == "Status" then
                    statusSource = api
                    if not statusExplicit then
                        setFooter(footerFromBody(paragraphSettings.Body))
                    end
                end
                return api
            end

            function section:RankList(rankSettings)
                local row, entry = addRow(0, rankSettings.Name)
                row.AutomaticSize = Enum.AutomaticSize.Y
                local options = {}
                local value = {}
                local api = {}
                local inner = create("Frame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Parent = row
                })
                padding(inner, 14, 14, 10, 12)
                listLayout(inner, 8)
                local headRow = create("Frame", {
                    Size = UDim2.new(1, 0, 0, 18),
                    BackgroundTransparency = 1,
                    LayoutOrder = 1,
                    Parent = inner
                })
                local nameLabel = textLabel({
                    Size = UDim2.new(1, -60, 1, 0),
                    Text = tostring(rankSettings.Name or ""),
                    FontFace = fontMedium,
                    Parent = headRow
                })
                local countLabel = textLabel({
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.fromScale(1, 0),
                    Size = UDim2.new(0, 60, 1, 0),
                    TextSize = 12,
                    TextColor3 = theme.Sub,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = headRow
                })
                local rankHolder = create("Frame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = theme.Rail,
                    LayoutOrder = 2,
                    Parent = inner
                })
                corner(rankHolder, 8)
                padding(rankHolder, 6, 6, 6, 6)
                listLayout(rankHolder, 4)
                local poolLabel = textLabel({
                    Size = UDim2.new(1, 0, 0, 16),
                    Text = tostring(rankSettings.PoolText or "Tap to add"),
                    TextSize = 12,
                    TextColor3 = theme.Muted,
                    LayoutOrder = 3,
                    Parent = inner
                })
                local poolHolder = create("Frame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    LayoutOrder = 4,
                    Parent = inner
                })
                local poolLayout = listLayout(poolHolder, 6, true)
                poolLayout.Wraps = true
                dimmable(entry, nameLabel, "TextTransparency")
                if entry.Card.Locked then
                    refreshEntryDim(entry)
                end

                local render

                local function changed()
                    render()
                    if rankSettings.Callback then
                        rankSettings.Callback(table.clone(value))
                    end
                end

                local function iconButton(parent, order, draw, onClick, enabled)
                    local button = clickArea({
                        Size = UDim2.fromOffset(24, 22),
                        BackgroundTransparency = 1,
                        BackgroundColor3 = theme.FieldHover,
                        LayoutOrder = order,
                        Parent = parent
                    })
                    corner(button, 6)
                    local color = enabled and theme.Sub or theme.Off
                    draw(button, color)
                    if enabled then
                        button.MouseEnter:Connect(function()
                            button.BackgroundTransparency = 0
                        end)
                        button.MouseLeave:Connect(function()
                            button.BackgroundTransparency = 1
                        end)
                        button.MouseButton1Click:Connect(onClick)
                    end
                    return button
                end

                local function drawArrow(up)
                    return function(button, color)
                        local mark = chevron(button, {
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            Position = UDim2.fromScale(0.5, 0.5),
                            Rotation = up and 180 or 0
                        })
                        for _, bar in ipairs(mark:GetChildren()) do
                            bar.BackgroundColor3 = color
                        end
                    end
                end

                local function drawCross(button, color)
                    for _, angle in ipairs({ 45, -45 }) do
                        create("Frame", {
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            Position = UDim2.fromScale(0.5, 0.5),
                            Size = UDim2.fromOffset(10, 2),
                            Rotation = angle,
                            BackgroundColor3 = color,
                            Parent = button
                        })
                    end
                end

                local function move(index, offset)
                    local target = index + offset
                    if target < 1 or target > #value then
                        return
                    end
                    value[index], value[target] = value[target], value[index]
                    changed()
                end

                local function rankRow(index, name)
                    local line = create("Frame", {
                        Size = UDim2.new(1, 0, 0, 28),
                        BackgroundColor3 = theme.Field,
                        LayoutOrder = index,
                        Parent = rankHolder
                    })
                    corner(line, 7)
                    local chip = create("Frame", {
                        AnchorPoint = Vector2.new(0, 0.5),
                        Position = UDim2.new(0, 5, 0.5, 0),
                        Size = UDim2.fromOffset(20, 20),
                        BackgroundColor3 = index == 1 and theme.Accent or theme.Off,
                        Parent = line
                    })
                    corner(chip, 6)
                    textLabel({
                        Size = UDim2.fromScale(1, 1),
                        Text = tostring(index),
                        FontFace = fontBold,
                        TextSize = 12,
                        TextColor3 = theme.AccentText,
                        TextXAlignment = Enum.TextXAlignment.Center,
                        Parent = chip
                    })
                    textLabel({
                        Position = UDim2.new(0, 32, 0, 0),
                        Size = UDim2.new(1, -116, 1, 0),
                        Text = tostring(name),
                        TextSize = 13,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        Parent = line
                    })
                    local tools = create("Frame", {
                        AnchorPoint = Vector2.new(1, 0.5),
                        Position = UDim2.new(1, -3, 0.5, 0),
                        Size = UDim2.fromOffset(80, 22),
                        BackgroundTransparency = 1,
                        Parent = line
                    })
                    local toolLayout = listLayout(tools, 4, true)
                    toolLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
                    iconButton(tools, 1, drawArrow(true), function()
                        move(index, -1)
                    end, index > 1)
                    iconButton(tools, 2, drawArrow(false), function()
                        move(index, 1)
                    end, index < #value)
                    iconButton(tools, 3, drawCross, function()
                        table.remove(value, index)
                        changed()
                    end, true)
                end

                local function poolChip(order, name)
                    local chip = clickArea({
                        Size = UDim2.fromOffset(0, 26),
                        AutomaticSize = Enum.AutomaticSize.X,
                        BackgroundTransparency = 0,
                        BackgroundColor3 = theme.Field,
                        Text = "+  " .. tostring(name),
                        FontFace = fontMedium,
                        TextSize = 12,
                        TextColor3 = theme.TextOff,
                        LayoutOrder = order,
                        Parent = poolHolder
                    })
                    corner(chip, 13)
                    stroke(chip, theme.CardStroke)
                    padding(chip, 10, 10, 0, 0)
                    chip.MouseEnter:Connect(function()
                        chip.BackgroundColor3 = theme.FieldHover
                    end)
                    chip.MouseLeave:Connect(function()
                        chip.BackgroundColor3 = theme.Field
                    end)
                    chip.MouseButton1Click:Connect(function()
                        if not table.find(value, name) then
                            table.insert(value, name)
                            changed()
                        end
                    end)
                end

                render = function()
                    for _, holder in ipairs({ rankHolder, poolHolder }) do
                        for _, child in ipairs(holder:GetChildren()) do
                            if child:IsA("GuiObject") then
                                child:Destroy()
                            end
                        end
                    end
                    for index, name in ipairs(value) do
                        rankRow(index, name)
                    end
                    if #value == 0 then
                        textLabel({
                            Size = UDim2.new(1, 0, 0, 28),
                            Text = tostring(rankSettings.EmptyText or "Empty"),
                            TextSize = 13,
                            TextColor3 = theme.Muted,
                            TextXAlignment = Enum.TextXAlignment.Center,
                            Parent = rankHolder
                        })
                    end
                    local free = 0
                    for _, name in ipairs(options) do
                        if not table.find(value, name) then
                            free = free + 1
                            poolChip(free, name)
                        end
                    end
                    poolLabel.Visible = free > 0
                    poolHolder.Visible = free > 0
                    countLabel.Text = tostring(#value) .. " / " .. tostring(math.max(#options, #value))
                    api.Value = table.clone(value)
                end

                local function cleanList(list)
                    local out = {}
                    for _, name in ipairs(typeof(list) == "table" and list or {}) do
                        if not table.find(out, name) then
                            table.insert(out, name)
                        end
                    end
                    return out
                end

                options = cleanList(rankSettings.Options)
                value = cleanList(rankSettings.Default)
                render()

                commonApi(api, entry, nameLabel)
                function api:SetOptions(newOptions)
                    options = cleanList(newOptions)
                    render()
                end
                function api:SetValue(newValue)
                    value = cleanList(newValue)
                    render()
                end
                function api:GetValue()
                    return table.clone(value)
                end
                return api
            end

            function section:Label(labelSettings)
                local text = tostring((labelSettings and (labelSettings.Text or labelSettings.Name)) or "")
                local row, entry = addRow(34, text)
                local nameLabel = textLabel({
                    Position = UDim2.new(0, 14, 0, 0),
                    Size = UDim2.new(1, -28, 1, 0),
                    Text = text,
                    TextColor3 = theme.Sub,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    Parent = row
                })
                return commonApi({}, entry, nameLabel)
            end

            function section:SubLabel(labelSettings)
                return section:Label(labelSettings)
            end

            function section:Input(inputSettings)
                local row, entry = addRow(40, inputSettings.Name)
                local nameLabel = textLabel({
                    Position = UDim2.new(0, 14, 0, 0),
                    Size = UDim2.new(0.5, -14, 1, 0),
                    Text = tostring(inputSettings.Name or ""),
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    Parent = row
                })
                local boxFrame = create("Frame", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -14, 0.5, 0),
                    Size = UDim2.new(0.5, -14, 0, 28),
                    BackgroundColor3 = theme.Field,
                    Parent = row
                })
                corner(boxFrame, 8)
                local box = create("TextBox", {
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -20, 1, 0),
                    BackgroundTransparency = 1,
                    ClearTextOnFocus = false,
                    Text = tostring(inputSettings.Default or ""),
                    PlaceholderText = tostring(inputSettings.Placeholder or ""),
                    PlaceholderColor3 = theme.Muted,
                    TextColor3 = theme.Text,
                    FontFace = fontRegular,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = boxFrame
                })
                track(box.FocusLost:Connect(function()
                    if inputSettings.Callback then
                        inputSettings.Callback(box.Text)
                    end
                end))
                local api = commonApi({}, entry, nameLabel)
                function api:GetInput()
                    return box.Text
                end
                function api:UpdateText(newText)
                    box.Text = tostring(newText)
                end
                function api:UpdatePlaceholder(newText)
                    box.PlaceholderText = tostring(newText)
                end
                return api
            end

            function section:UnitGrid(gridSettings)
                gridSettings = gridSettings or {}
                local count = math.max(1, math.floor(tonumber(gridSettings.Count) or 6))
                local columns = math.max(1, math.floor(tonumber(gridSettings.Columns) or 3))
                local tileHeight = tonumber(gridSettings.TileHeight) or 124
                local gap = 8
                local rowCount = math.ceil(count / columns)
                local row, entry = addRow(rowCount * tileHeight + (rowCount - 1) * gap + 20, gridSettings.Name)
                local grid = create("Frame", {
                    Position = UDim2.fromOffset(12, 10),
                    Size = UDim2.new(1, -24, 1, -20),
                    BackgroundTransparency = 1,
                    Parent = row
                })
                create("UIGridLayout", {
                    CellSize = UDim2.new(1 / columns, -math.ceil(gap * (columns - 1) / columns), 0, tileHeight),
                    CellPadding = UDim2.fromOffset(gap, gap),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = grid
                })
                local tiles = {}
                for index = 1, count do
                    local tile = { Dim = false }
                    tile.Button = clickArea({
                        BackgroundTransparency = 0,
                        BackgroundColor3 = theme.Field,
                        LayoutOrder = index,
                        Parent = grid
                    })
                    corner(tile.Button, 10)
                    tile.Stroke = stroke(tile.Button, theme.CardStroke)
                    tile.Art = create("Frame", {
                        Position = UDim2.fromOffset(6, 6),
                        Size = UDim2.new(1, -12, 1, -48),
                        BackgroundColor3 = theme.Rail,
                        ClipsDescendants = true,
                        Parent = tile.Button
                    })
                    corner(tile.Art, 8)
                    fillArt(tile.Art, { Placeholder = tostring(index) })
                    tile.Badge = textLabel({
                        Position = UDim2.fromOffset(10, 10),
                        Size = UDim2.fromOffset(20, 18),
                        BackgroundTransparency = 0,
                        BackgroundColor3 = theme.Base,
                        Text = tostring(index),
                        FontFace = fontBold,
                        TextSize = 11,
                        TextColor3 = theme.Text,
                        TextXAlignment = Enum.TextXAlignment.Center,
                        ZIndex = 3,
                        Parent = tile.Button
                    })
                    corner(tile.Badge, 6)
                    tile.Tag = textLabel({
                        AnchorPoint = Vector2.new(1, 0),
                        Position = UDim2.new(1, -10, 0, 10),
                        Size = UDim2.fromOffset(0, 18),
                        AutomaticSize = Enum.AutomaticSize.X,
                        BackgroundTransparency = 0,
                        BackgroundColor3 = theme.Base,
                        Text = "",
                        FontFace = fontMedium,
                        TextSize = 11,
                        TextColor3 = theme.Text,
                        Visible = false,
                        ZIndex = 3,
                        Parent = tile.Button
                    })
                    corner(tile.Tag, 6)
                    padding(tile.Tag, 6, 6, 0, 0)
                    stroke(tile.Tag, theme.GoldSoft)
                    tile.Title = textLabel({
                        Position = UDim2.new(0, 8, 1, -40),
                        Size = UDim2.new(1, -16, 0, 18),
                        Text = "Slot " .. tostring(index),
                        FontFace = fontBold,
                        TextSize = 13,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        Parent = tile.Button
                    })
                    tile.Sub = textLabel({
                        Position = UDim2.new(0, 8, 1, -22),
                        Size = UDim2.new(1, -16, 0, 16),
                        Text = "Empty",
                        TextSize = 11,
                        TextColor3 = theme.Sub,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        Parent = tile.Button
                    })
                    track(tile.Button.MouseEnter:Connect(function()
                        tween(tile.Button, { BackgroundColor3 = theme.FieldHover }, 0.12)
                        tile.Stroke.Color = theme.Accent
                    end))
                    track(tile.Button.MouseLeave:Connect(function()
                        tween(tile.Button, { BackgroundColor3 = theme.Field }, 0.12)
                        tile.Stroke.Color = theme.CardStroke
                    end))
                    track(tile.Button.MouseButton1Click:Connect(function()
                        if gridSettings.Callback then
                            gridSettings.Callback(index)
                        end
                    end))
                    tiles[index] = tile
                end
                local api = commonApi({}, entry, nil)
                function api:SetTile(index, data)
                    local tile = tiles[index]
                    if not tile or type(data) ~= "table" then
                        return
                    end
                    if data.Title ~= nil then
                        tile.Title.Text = tostring(data.Title)
                    end
                    if data.Subtitle ~= nil then
                        tile.Sub.Text = tostring(data.Subtitle)
                    end
                    if data.Tag ~= nil then
                        tile.Tag.Text = tostring(data.Tag)
                        tile.Tag.Visible = tostring(data.Tag) ~= ""
                    end
                    if data.Viewport ~= nil or data.Image ~= nil or data.Placeholder ~= nil then
                        if data.Viewport ~= tile.SourceRef or data.Image ~= tile.ImageRef or data.Placeholder ~= tile.PlaceholderRef or not tile.Filled then
                            tile.SourceRef, tile.ImageRef, tile.PlaceholderRef, tile.Filled = data.Viewport, data.Image, data.Placeholder, true
                            fillArt(tile.Art, { Viewport = data.Viewport, Image = data.Image, Placeholder = data.Placeholder or tostring(index), Prepare = data.Prepare })
                        end
                    end
                    if data.Dim ~= nil then
                        tile.Dim = data.Dim == true
                        tile.Title.TextColor3 = tile.Dim and theme.Muted or theme.Text
                        tile.Art.BackgroundTransparency = tile.Dim and 0.5 or 0
                    end
                end
                return api
            end

            function section:Divider()
                local row, entry = addRow(8, "")
                local api = commonApi({}, entry, nil)
                function api:Remove()
                    row:Destroy()
                end
                return api
            end

            function section:Spacer()
                return section:Divider()
            end

            return section
        end

        local function makeTab(tabSettings)
            tabSettings = tabSettings or {}
            local tab = { Name = tostring(tabSettings.Name or "Tab"), Description = tostring(tabSettings.Description or ""), Cards = {} }
            tab.Button = clickArea({
                Size = UDim2.fromOffset(58, 46),
                BackgroundTransparency = 1,
                BackgroundColor3 = Color3.new(1, 1, 1),
                LayoutOrder = nextOrder(),
                Parent = railList
            })
            corner(tab.Button, 12)
            create("UIGradient", {
                Color = ColorSequence.new(theme.TabTop, theme.TabBottom),
                Rotation = 90,
                Parent = tab.Button
            })
            tab.Indicator = create("Frame", {
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, -5, 0.5, 0),
                Size = UDim2.fromOffset(3, 18),
                BackgroundColor3 = theme.Gold,
                Visible = false,
                Parent = tab.Button
            })
            corner(tab.Indicator, 2)
            tab.Icon = create("ImageLabel", {
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.new(0.5, 0, 0, 6),
                Size = UDim2.fromOffset(20, 20),
                BackgroundTransparency = 1,
                Image = tostring(tabSettings.Image or ""),
                ImageColor3 = theme.Sub,
                Parent = tab.Button
            })
            tab.NameLabel = textLabel({
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.new(0.5, 0, 0, 29),
                Size = UDim2.new(1, -4, 0, 12),
                Text = tab.Name,
                FontFace = fontMedium,
                TextSize = 11,
                TextColor3 = theme.Sub,
                TextXAlignment = Enum.TextXAlignment.Center,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = tab.Button
            })
            tab.Page = create("ScrollingFrame", {
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                ScrollBarThickness = 3,
                ScrollBarImageColor3 = theme.Off,
                CanvasSize = UDim2.new(),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollingDirection = Enum.ScrollingDirection.Y,
                Visible = false,
                Parent = pages
            })
            padding(tab.Page, 20, 20, 0, 18)
            local pageLayout = listLayout(tab.Page, 12, true)
            pageLayout.VerticalAlignment = Enum.VerticalAlignment.Top
            tab.Columns = {}
            for index, side in ipairs({ "Left", "Right" }) do
                local column = create("Frame", {
                    Size = UDim2.new(0.5, -6, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    LayoutOrder = index,
                    Parent = tab.Page
                })
                listLayout(column, 12)
                tab.Columns[side] = column
            end

            function tab:Section(sectionSettings)
                return makeSection(tab, sectionSettings)
            end
            function tab:Select()
                selectTab(tab)
            end

            track(tab.Button.MouseEnter:Connect(function()
                if currentTab ~= tab then
                    tab.Icon.ImageColor3 = theme.Text
                    tab.NameLabel.TextColor3 = theme.Text
                    tab.Button.BackgroundTransparency = 0.86
                end
            end))
            track(tab.Button.MouseLeave:Connect(function()
                if currentTab ~= tab then
                    tab.Button.BackgroundTransparency = 1
                    tab.Icon.ImageColor3 = theme.Sub
                    tab.NameLabel.TextColor3 = theme.Sub
                end
            end))
            track(tab.Button.MouseButton1Click:Connect(function()
                selectTab(tab)
            end))

            table.insert(tabs, tab)
            if not currentTab then
                selectTab(tab)
            end
            return tab
        end

        function window:TabGroup()
            groupCount = groupCount + 1
            if groupCount > 1 then
                create("Frame", {
                    Size = UDim2.fromOffset(28, 1),
                    BackgroundColor3 = theme.Line,
                    LayoutOrder = nextOrder(),
                    Parent = railList
                })
            end
            local group = {}
            function group:Tab(tabSettings)
                return makeTab(tabSettings)
            end
            return group
        end

        function window:Popup(popupSettings)
            popupSettings = popupSettings or {}
            local popup = { Name = tostring(popupSettings.Title or ""), Description = "", Cards = {}, Columns = {}, IsOpen = false }
            local overlay = clickArea({
                Name = "Popup",
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                BackgroundColor3 = Color3.new(0, 0, 0),
                Visible = false,
                ZIndex = 20,
                Parent = base
            })
            local panel = create("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.new(0, tonumber(popupSettings.Width) or 440, 1, -44),
                BackgroundColor3 = theme.Base,
                Active = true,
                Parent = overlay
            })
            corner(panel, 14)
            stroke(panel, theme.CardStroke)
            local panelScale = create("UIScale", { Scale = 1, Parent = panel })
            local art = create("Frame", {
                Position = UDim2.fromOffset(16, 14),
                Size = UDim2.fromOffset(64, 64),
                BackgroundColor3 = theme.Rail,
                ClipsDescendants = true,
                Parent = panel
            })
            corner(art, 10)
            stroke(art, theme.GoldSoft)
            fillArt(art, { Placeholder = popupSettings.Placeholder or "?" })
            local popupTitle = textLabel({
                Position = UDim2.fromOffset(94, 22),
                Size = UDim2.new(1, -150, 0, 22),
                Text = popup.Name,
                FontFace = fontBold,
                TextSize = 18,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = panel
            })
            local popupSubtitle = textLabel({
                Position = UDim2.fromOffset(94, 46),
                Size = UDim2.new(1, -150, 0, 16),
                Text = tostring(popupSettings.Subtitle or ""),
                TextSize = 12,
                TextColor3 = theme.Sub,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = panel
            })
            local popupClose = clickArea({
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, -14, 0, 14),
                Size = UDim2.fromOffset(32, 32),
                BackgroundTransparency = 0,
                BackgroundColor3 = theme.Field,
                Text = "X",
                FontFace = fontMedium,
                TextSize = 14,
                TextColor3 = theme.Sub,
                Parent = panel
            })
            corner(popupClose, 9)
            create("Frame", {
                Position = UDim2.fromOffset(0, 92),
                Size = UDim2.new(1, 0, 0, 1),
                BackgroundColor3 = theme.Line,
                Parent = panel
            })
            local scroll = create("ScrollingFrame", {
                Position = UDim2.fromOffset(0, 93),
                Size = UDim2.new(1, 0, 1, -93),
                BackgroundTransparency = 1,
                ScrollBarThickness = 3,
                ScrollBarImageColor3 = theme.Off,
                CanvasSize = UDim2.new(),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollingDirection = Enum.ScrollingDirection.Y,
                Parent = panel
            })
            padding(scroll, 16, 16, 14, 16)
            listLayout(scroll, 12)
            popup.Page = scroll
            popup.Columns.Left = scroll
            popup.Columns.Right = scroll

            function popup:Section(sectionSettings)
                return makeSection(popup, sectionSettings)
            end
            function popup:SetHeader(headerSettings)
                headerSettings = headerSettings or {}
                if headerSettings.Title ~= nil then
                    popup.Name = tostring(headerSettings.Title)
                    popupTitle.Text = popup.Name
                end
                if headerSettings.Subtitle ~= nil then
                    popupSubtitle.Text = tostring(headerSettings.Subtitle)
                end
                if headerSettings.Viewport ~= nil or headerSettings.Image ~= nil or headerSettings.Placeholder ~= nil then
                    if headerSettings.Viewport ~= popup.SourceRef or headerSettings.Image ~= popup.ImageRef or headerSettings.Placeholder ~= popup.PlaceholderRef then
                        popup.SourceRef, popup.ImageRef, popup.PlaceholderRef = headerSettings.Viewport, headerSettings.Image, headerSettings.Placeholder
                        fillArt(art, headerSettings)
                    end
                end
            end
            function popup:Open()
                for _, other in ipairs(popups) do
                    if other ~= popup and other.IsOpen then
                        other:Close(true)
                    end
                end
                popup.IsOpen = true
                scroll.CanvasPosition = Vector2.new(0, 0)
                overlay.Visible = true
                overlay.BackgroundTransparency = 1
                panelScale.Scale = 0.94
                tween(overlay, { BackgroundTransparency = 0.45 }, 0.18)
                tween(panelScale, { Scale = 1 }, 0.2)
                applyFilter()
                if popupSettings.OnOpen then
                    task.spawn(popupSettings.OnOpen)
                end
            end
            function popup:Close(instant)
                if not popup.IsOpen then
                    return
                end
                popup.IsOpen = false
                if instant then
                    overlay.Visible = false
                    return
                end
                tween(overlay, { BackgroundTransparency = 1 }, 0.14)
                tween(panelScale, { Scale = 0.94 }, 0.14)
                task.spawn(function()
                    task.wait(0.14)
                    if not popup.IsOpen then
                        overlay.Visible = false
                    end
                end)
            end
            track(overlay.MouseButton1Click:Connect(function()
                popup:Close()
            end))
            track(popupClose.MouseButton1Click:Connect(function()
                popup:Close()
            end))
            track(popupClose.MouseEnter:Connect(function()
                popupClose.BackgroundColor3 = theme.FieldHover
            end))
            track(popupClose.MouseLeave:Connect(function()
                popupClose.BackgroundColor3 = theme.Field
            end))
            table.insert(popups, popup)
            return popup
        end

        function window:Notify(notifySettings)
            notifySettings = notifySettings or {}
            local api = {}
            if not notificationsEnabled then
                function api:UpdateTitle() end
                function api:UpdateDescription() end
                function api:Resize() end
                function api:Cancel() end
                return api
            end
            local toast = create("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = theme.Card,
                LayoutOrder = nextOrder(),
                Parent = toastHolder
            })
            corner(toast, 12)
            stroke(toast, theme.CardStroke)
            padding(toast, 14, 14, 10, 12)
            listLayout(toast, 4)
            local toastTitle = textLabel({
                Size = UDim2.new(1, 0, 0, 18),
                Text = tostring(notifySettings.Title or ""),
                FontFace = fontBold,
                TextColor3 = theme.Text,
                LayoutOrder = 1,
                Parent = toast
            })
            local toastBody = textLabel({
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Text = tostring(notifySettings.Description or ""),
                TextSize = 13,
                TextColor3 = theme.Sub,
                TextWrapped = true,
                TextYAlignment = Enum.TextYAlignment.Top,
                LayoutOrder = 2,
                Parent = toast
            })
            function api:UpdateTitle(newTitle)
                toastTitle.Text = tostring(newTitle)
            end
            function api:UpdateDescription(newText)
                toastBody.Text = tostring(newText)
            end
            function api:Resize() end
            function api:Cancel()
                if toast.Parent then
                    toast:Destroy()
                end
            end
            local lifetime = tonumber(notifySettings.Lifetime)
            if lifetime then
                task.spawn(function()
                    task.wait(lifetime)
                    api:Cancel()
                end)
            end
            return api
        end

        function window:SetNotificationsState(enabled)
            notificationsEnabled = enabled == true
        end

        function window:GetNotificationsState()
            return notificationsEnabled
        end

        function window:SetState(visible)
            windowState = visible == true
            if windowState then
                holder.Visible = true
                baseScale.Scale = userScale * 0.94
                animateScale(userScale, 0.2)
            else
                animateScale(userScale * 0.94, 0.12)
                task.spawn(function()
                    task.wait(0.12)
                    if not windowState then
                        holder.Visible = false
                        baseScale.Scale = userScale
                    end
                end)
            end
        end

        function window:SetStatus(text, active)
            statusExplicit = true
            setFooter(text, active ~= false)
        end

        function window:GetState()
            return windowState
        end

        function window:Unload()
            if unloaded then
                return
            end
            unloaded = true
            if unloadCallback then
                pcall(unloadCallback)
            end
            for _, connection in ipairs(connections) do
                pcall(function()
                    connection:Disconnect()
                end)
            end
            connections = {}
            pcall(function()
                screen:Destroy()
            end)
        end

        window.onUnloaded = function(callback)
            unloadCallback = callback
        end

        function window:SetKeybind(keyCode)
            menuKey = keyCode
            keyHint.Text = tostring(keyCode.Name) .. " to hide"
        end

        function window:SetScale(scaleValue)
            userScale = tonumber(scaleValue) or 1
            if scaleTween then
                pcall(function()
                    scaleTween:Cancel()
                end)
                scaleTween = nil
            end
            baseScale.Scale = userScale
        end

        function window:GetScale()
            return userScale
        end

        function window:SetSize(newSize)
            holder.Size = newSize
        end

        function window:GetSize()
            return holder.Size
        end

        function window:UpdateTitle(newTitle)
            titleLabel.Text = tostring(newTitle)
        end

        function window:UpdateSubtitle(newSubtitle)
            subtitleLabel.Text = tostring(newSubtitle)
        end

        function window:SetAcrylicBlurState() end

        function window:GetAcrylicBlurState()
            return false
        end

        function window:SetUserInfoState() end

        function window:GetUserInfoState()
            return false
        end

        local dragging = false
        local dragStart = nil
        local startPosition = nil
        track(dragHandle.InputBegan:Connect(function(input)
            if isPress(input) then
                dragging = true
                dragStart = input.Position
                startPosition = holder.Position
            end
        end))
        track(uiInput.InputChanged:Connect(function(input)
            if dragging and isMove(input) then
                local delta = input.Position - dragStart
                holder.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
            end
        end))
        track(uiInput.InputEnded:Connect(function(input)
            if isPress(input) then
                dragging = false
            end
        end))

        track(uiInput.InputBegan:Connect(function(input, processed)
            if processed then
                return
            end
            if input.KeyCode == menuKey then
                window:SetState(not windowState)
            end
        end))

        create("TextButton", {
            Name = "CursorUnlock",
            Size = UDim2.fromOffset(0, 0),
            BackgroundTransparency = 1,
            Text = "",
            Modal = true,
            Parent = holder
        })
        local cursorRun = cloneref(game:GetService("RunService"))
        track(cursorRun.RenderStepped:Connect(function()
            if not windowState or unloaded then
                return
            end
            pcall(function()
                uiInput.MouseIconEnabled = true
                if uiInput.MouseBehavior == Enum.MouseBehavior.LockCenter and not uiInput:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                    uiInput.MouseBehavior = Enum.MouseBehavior.Default
                end
            end)
        end))

        track(searchBox:GetPropertyChangedSignal("Text"):Connect(function()
            searchQuery = string.lower((string.gsub(searchBox.Text, "^%s+", "")))
            searchClear.Visible = searchBox.Text ~= ""
            applyFilter()
        end))
        track(searchBox.Focused:Connect(function()
            searchStroke.Color = theme.GoldSoft
        end))
        track(searchBox.FocusLost:Connect(function()
            searchStroke.Color = theme.CardStroke
        end))
        track(searchClear.MouseButton1Click:Connect(function()
            searchBox.Text = ""
        end))

        for _, button in ipairs({ minimizeButton, closeButton }) do
            track(button.MouseEnter:Connect(function()
                button.BackgroundColor3 = theme.FieldHover
            end))
            track(button.MouseLeave:Connect(function()
                button.BackgroundColor3 = theme.Field
            end))
        end
        track(minimizeButton.MouseButton1Click:Connect(function()
            window:SetState(false)
            window:Notify({
                Title = tostring(settings.Title or "Hub"),
                Description = "Hidden. Press " .. tostring(menuKey.Name) .. " or the floating button to open it again.",
                Lifetime = 4
            })
        end))
        track(closeButton.MouseButton1Click:Connect(function()
            window:Unload()
        end))

        baseScale.Scale = 0.94
        screen.Parent = guiParent()
        animateScale(userScale, 0.25)
        return window
    end

    return library
end)()


local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

local PATHS = {
	root = "Order Hub",
	game = "Order Hub/Anime Adventure",
	configs = "Order Hub/Anime Adventure/configs",
	macros = "Order Hub/Anime Adventure/macros",
	legacy = "Anime Adventure/AnimeAdventureConfig.json",
}
PATHS.config = PATHS.configs .. "/" .. LocalPlayer.Name .. ".json"

local hub = {
	alive = true,
	jobId = game.JobId,
	conns = {},
	threads = {},
	settings = {},
	macros = {},
	remotes = {},
	pending = {},
	worlds = {},
	levelsByWorld = {},
	status = "Ready",
	gameClock = os.clock(),
	lastStarted = false,
	finishedAt = nil,
	replayAt = nil,
	joinedAt = 0,
	lobbyName = nil,
	joining = false,
	nextVote = 0,
	nextFinish = 0,
	finishTries = 0,
	macroState = "idle",
	playInfo = nil,
	macroText = "",
	round = 0,
	playedRound = -1,
	lastMessage = nil,
	lastMessageAt = 0,
}
genv.AnimeAdventureHub = hub

local ui = {}

local defaults = {
	world = "",
	level = "",
	difficulty = "Normal",
	autoJoin = false,
	autoStart = false,
	autoVote = true,
	afterFinish = "Replay",
	autoNextPortal = false,
	portalNames = {},
	autoSkip = true,
	playMacro = false,
	macro = "",
	uiScale = "Auto",
	hideName = true,
	autoPlay = false,
	autoPlayUpgrade = true,
	autoPlaySkill = false,
	sequentialUpgrade = true,
	leftoverUpgrade = false,
	autoSummerHunt = false,
	summerMode = "Solo",
	summerJoinRule = "Always",
	summerSkipWeathers = {},
	summerClaimBingo = true,
	summerBuyStars = false,
	summerKeepPearls = 5000,
	autoRogue = false,
	rogueMode = "Good first",
	roguePrefer = {},
	roguePriority = {},
	rogueAvoid = {},
	rogueSeen = {},
	rogueTierRule = "Higher tier first",
	modeTeams = {},
	lobbyOrder = { "Challenge", "Summer Hunt", "Dungeon", "Infinity Mansion", "Portal", "Auto Join" },
	autoMansion = false,
	mansionDifficulty = "Hard",
	autoChallenge = false,
	challengeRewards = {},
	challengeSeen = {},
	challengeSkip = 0,
	challengeTry = {},
	autoMerchant = false,
	merchantItems = {},
	merchantSeen = {},
	merchantDone = {},
	webhookOn = false,
	webhookUrl = "",
	webhookDungeonRooms = false,
	webhookSession = {},
	webhookPing = "",
	autoExec = true,
	slotWorth = true,
	slotStyle = "Worth bar",
	customLevel = "",
	fastMode = false,
	blackScreen = false,
	dungeonHud = true,
	autoDungeon = false,
	dungeonPrefer = { "Gold Chest", "Chest", "Shop" },
	dungeonOrder = {},
	dungeonAvoid = { "Curse" },
	dungeonChestDepths = { "20 (last room)" },
	dungeonOpenGold = true,
	dungeonBuy = {},
	dungeonShrine = false,
	dungeonRetry = true,
	buffLoop = false,
	buffLoopMode = "Max buff 100% (4 per type)",
	buffUnitCap = 4,
	autoPlaySlots = {},
	autoPlayProfiles = {},
	autoPlayAnchors = {},
	autoPlayRadius = 12,
	autoPlayFarmRadius = 8,
	useFarmArea = true,
	showPlacementArea = true,
	pathPlace = false,
	pathGround = 50,
	pathHill = 50,
	pathBuff = 50,
	sellAllWave = 0,
	sellFarmWave = 0,
	upgradeAllWave = 0,
	waveRuleModes = {},
	autoSummon = false,
	summonBanner = "EventClover",
	summonMode = "Gems x10",
	useLuckPotion = false,
	wantedUnits = {},
	stopOnWanted = true,
	stopOnPity = false,
	keepGems = 0,
}

local finishOptions = { "Replay", "Next Story", "Back To Lobby", "Do Nothing" }
local scaleOptions = { "Auto", "40%", "50%", "60%", "70%", "80%", "90%", "100%" }
local difficultyOptions = { "Normal", "Hard" }

local actionRemotes = {
	use_active_attack = true,
	use_custom_unit_control = true,
	use_ingame_spell = true,
	change_priority = true,
}
local trackedRemotes = {
	spawn_unit = true,
	upgrade_unit_ingame = true,
	sell_unit_ingame = true,
	use_active_attack = true,
	use_custom_unit_control = true,
	use_ingame_spell = true,
	change_priority = true,
}

local function connect(signal, fn)
	local connection = signal:Connect(fn)
	table.insert(hub.conns, connection)
	return connection
end

local function spawnThread(fn)
	local thread = task.spawn(fn)
	table.insert(hub.threads, thread)
	return thread
end

local function ensureFolders()
	for _, folder in ipairs({ PATHS.root, PATHS.game, PATHS.configs, PATHS.macros }) do
		pcall(function()
			if not isfolder(folder) then
				makefolder(folder)
			end
		end)
	end
end

local function macroFileName(name)
	local clean = string.gsub(tostring(name), "[^%w _]", "")
	clean = string.gsub(clean, "^%s+", "")
	clean = string.gsub(clean, "%s+$", "")
	if clean == "" then
		clean = "Macro"
	end
	return clean
end

local function macroPath(name)
	return PATHS.macros .. "/" .. macroFileName(name) .. ".json"
end

local function validEvents(events)
	if type(events) ~= "table" or #events == 0 then
		return false
	end
	for _, event in ipairs(events) do
		if type(event) ~= "table" or type(event.name) ~= "string" or type(event.args) ~= "table" or type(event.t) ~= "number" or type(event.n) ~= "number" then
			return false
		end
	end
	return true
end

local function saveMacro(name)
	local macro = hub.macros[name]
	if not macro then
		return
	end
	ensureFolders()
	pcall(function()
		writefile(macroPath(name), HttpService:JSONEncode({ orderHubMacro = 1, name = name, level = macro.level, events = macro.events }))
	end)
end

local function deleteMacroFile(name)
	pcall(function()
		local path = macroPath(name)
		if isfile(path) then
			delfile(path)
		end
	end)
end

local function macroFileList()
	local names = {}
	local ok, files = pcall(listfiles, PATHS.macros)
	if ok and type(files) == "table" then
		for _, path in ipairs(files) do
			local normalized = string.gsub(path, "\\", "/")
			local fileName = string.match(normalized, "([^/]+)%.json$")
			if fileName then
				table.insert(names, { name = fileName, path = path })
			end
		end
	end
	table.sort(names, function(a, b)
		return a.name < b.name
	end)
	return names
end

local function loadMacros()
	local found = {}
	local signature = {}
	for _, entry in ipairs(macroFileList()) do
		table.insert(signature, entry.name)
		local ok, data = pcall(function()
			return HttpService:JSONDecode(readfile(entry.path))
		end)
		if ok and type(data) == "table" and validEvents(data.events) then
			found[entry.name] = { level = data.level, events = data.events }
		end
	end
	hub.macros = found
	hub.macroSignature = table.concat(signature, "|")
end

local function loadConfig()
	for key, value in pairs(defaults) do
		hub.settings[key] = value
	end
	ensureFolders()
	local function apply(data)
		if type(data) == "table" and type(data.settings) == "table" then
			for key in pairs(defaults) do
				if data.settings[key] ~= nil then
					hub.settings[key] = data.settings[key]
				end
			end
			if data.settings.autoStart == nil and data.settings.autoJoin then
				hub.settings.autoStart = true
			end
		end
	end
	local loaded = false
	pcall(function()
		if isfile(PATHS.config) then
			apply(HttpService:JSONDecode(readfile(PATHS.config)))
			loaded = true
		end
	end)
	if not loaded then
		pcall(function()
			if isfile(PATHS.legacy) then
				local data = HttpService:JSONDecode(readfile(PATHS.legacy))
				apply(data)
				if type(data.macros) == "table" then
					for name, macro in pairs(data.macros) do
						if type(macro) == "table" and validEvents(macro.events) and not isfile(macroPath(name)) then
							pcall(function()
								writefile(macroPath(name), HttpService:JSONEncode({ orderHubMacro = 1, name = macroFileName(name), level = macro.level, events = macro.events }))
							end)
						end
					end
				end
			end
		end)
	end
	loadMacros()
	if not table.find(finishOptions, hub.settings.afterFinish) then
		hub.settings.afterFinish = "Replay"
	end
	if not table.find(scaleOptions, hub.settings.uiScale) then
		hub.settings.uiScale = "Auto"
	end
	if not table.find(difficultyOptions, hub.settings.difficulty) then
		hub.settings.difficulty = "Normal"
	end
	hub.settings.autoPlayFarmAnchors = nil
	hub.settings.webhookToday = nil
	for _, key in ipairs({ "autoFoolsHunt", "foolsMode", "eventFreeze", "eventArrive", "aprilFreeze", "aprilFreezeMobile", "aprilPowersOn", "aprilCarryCount", "aprilSellJunk", "aprilAlwaysSell", "aprilPowerPolicy", "aprilFocus", "aprilSpellVariant", "aprilSeenUnits" }) do
		hub.settings[key] = nil
	end
	if type(hub.settings.lobbyOrder) == "table" then
		local order = table.clone(hub.settings.lobbyOrder)
		local old = table.find(order, "Fool's Hunt")
		if old then
			if table.find(order, "Summer Hunt") then
				table.remove(order, old)
			else
				order[old] = "Summer Hunt"
			end
			hub.settings.lobbyOrder = order
		end
	end
	if type(hub.settings.modeTeams) == "table" then
		hub.settings.modeTeams["Fool's Hunt"] = nil
	end
	if not table.find({ "Solo", "Party", "Find Match" }, hub.settings.summerMode) then
		hub.settings.summerMode = "Solo"
	end
	if hub.settings.rogueMode == "Bad first (more coins)" then
		hub.settings.rogueMode = "Bad first (more pearls)"
	end
	if hub.settings.buffLoopMode ~= "Max buff 100% (4 per type)" and hub.settings.buffLoopMode ~= "Keep buff up only" then
		hub.settings.buffLoopMode = "Max buff 100% (4 per type)"
	end
	if not hub.macros[hub.settings.macro] then
		hub.settings.macro = macroFileName(hub.settings.macro)
	end
end

local function saveConfig()
	if hub.saveQueued then
		return
	end
	hub.saveQueued = true
	task.delay(0.5, function()
		hub.saveQueued = false
		ensureFolders()
		pcall(function()
			writefile(PATHS.config, HttpService:JSONEncode({ settings = hub.settings }))
		end)
	end)
end

local function setFlag(key, value)
	hub.settings[key] = value
	if (value == true and (key == "webhookOn" or key == "autoDungeon" or key == "autoJoin" or key == "autoSummerHunt" or key == "autoChallenge" or key == "autoNextPortal")) or (key == "afterFinish" and value ~= "Do Nothing") then
		hub.settings.webhookSession = nil
	end
	saveConfig()
end

hub.shareConfig = {
	prefix = "OrderHubAA:",
	skip = { webhookUrl = true, webhookPing = true, webhookSession = true, webhookOn = true, rogueSeen = true, challengeSeen = true, challengeTry = true, challengeSkip = true, merchantSeen = true, merchantDone = true, customLevel = true, macro = true, playMacro = true },
}

function hub.shareConfig.export()
	local out = {}
	for key in pairs(defaults) do
		if not hub.shareConfig.skip[key] and hub.settings[key] ~= nil then
			out[key] = hub.settings[key]
		end
	end
	return hub.shareConfig.prefix .. HttpService:JSONEncode({ v = 1, settings = out })
end

function hub.shareConfig.import(text)
	text = (string.gsub(tostring(text or ""), "^%s+", ""))
	text = (string.gsub(text, "%s+$", ""))
	if text == "" then
		return false, "Paste a config code first"
	end
	local prefix = hub.shareConfig.prefix
	if string.sub(text, 1, #prefix) == prefix then
		text = string.sub(text, #prefix + 1)
	end
	local ok, data = pcall(function()
		return HttpService:JSONDecode(text)
	end)
	if not ok or type(data) ~= "table" or type(data.settings) ~= "table" then
		return false, "That is not a valid config code"
	end
	local count = 0
	for key, value in pairs(data.settings) do
		if defaults[key] ~= nil and not hub.shareConfig.skip[key] and type(value) == type(defaults[key]) then
			hub.settings[key] = value
			count += 1
		end
	end
	if count == 0 then
		return false, "The code had no settings to load"
	end
	saveConfig()
	return true, "Loaded " .. count .. " settings from the code"
end

local function setStatus(text)
	hub.status = text
	if ui.status then
		pcall(function()
			ui.status:UpdateBody(text)
		end)
	end
end

local function setToggle(toggle, value)
	if not toggle then
		return
	end
	ui.suppress = true
	pcall(function()
		toggle:UpdateState(value)
	end)
	ui.suppress = false
end

local function endpointFolder()
	local endpoints = ReplicatedStorage:FindFirstChild("endpoints")
	return endpoints and endpoints:FindFirstChild("client_to_server")
end

local function serverEvents()
	local endpoints = ReplicatedStorage:FindFirstChild("endpoints")
	return endpoints and endpoints:FindFirstChild("server_to_client")
end

local function invoke(name, ...)
	local remote = hub.remotes[name]
	if not remote or not remote.Parent then
		local folder = endpointFolder()
		remote = folder and folder:FindFirstChild(name)
		hub.remotes[name] = remote
	end
	if not remote then
		return false, "missing remote", false
	end
	local args = table.pack(...)
	local packed = nil
	task.spawn(function()
		packed = table.pack(pcall(remote.InvokeServer, remote, table.unpack(args, 1, args.n)))
	end)
	local untilTime = os.clock() + 10
	while not packed and os.clock() < untilTime do
		task.wait(0.03)
	end
	if not packed then
		return false, "timeout", false
	end
	if not packed[1] then
		return false, packed[2], false
	end
	return packed[2], packed[3], true
end

function hub.isMobile()
	local ok, mobile = pcall(function()
		local input = game:GetService("UserInputService")
		return input.TouchEnabled and not input.KeyboardEnabled
	end)
	return ok and mobile == true
end

local function gameState()
	local data = workspace:FindFirstChild("_DATA")
	local started = data and data:FindFirstChild("GameStarted")
	if started then
		return true, started.Value == true
	end
	return false, false
end

local function ownedByMe(model)
	local stats = model:FindFirstChild("_stats")
	local owner = stats and stats:FindFirstChild("player")
	if not owner then
		return false
	end
	local value = owner.Value
	return value == LocalPlayer or value == LocalPlayer.Name
end

local function isSummon(model)
	local stats = model:FindFirstChild("_stats")
	local parent = stats and stats:FindFirstChild("parent_unit")
	return parent ~= nil and parent.Value ~= nil and parent.Value ~= ""
end

local function unitModels()
	local list = {}
	local folder = workspace:FindFirstChild("_UNITS")
	if folder then
		for _, child in ipairs(folder:GetChildren()) do
			if child:IsA("Model") and ownedByMe(child) and not isSummon(child) then
				table.insert(list, child)
			end
		end
	end
	return list
end

local function modelUuid(model)
	local stats = model:FindFirstChild("_stats")
	local value = stats and stats:FindFirstChild("uuid")
	return value and tostring(value.Value) or nil
end

local function unitNear(position, map, uuid)
	local bestModel, bestDist = nil, 2.5
	for _, model in ipairs(unitModels()) do
		local placedUuid = modelUuid(model)
		local sameType = not uuid or not placedUuid or placedUuid == uuid
		if sameType and not map.modelToIdx[model] then
			local ok, pivot = pcall(function()
				return model:GetPivot().Position
			end)
			if ok then
				local flat = Vector3.new(pivot.X - position.X, 0, pivot.Z - position.Z).Magnitude
				if flat < bestDist then
					bestDist = flat
					bestModel = model
				end
			end
		end
	end
	return bestModel
end

local function baseUnitId(name)
	return string.match(tostring(name), "^[^:]+") or tostring(name)
end

local function equippedUnits()
	local result = { uuidToId = {}, idToUuid = {}, count = 0 }
	local gui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
	local frame = gui and gui:FindFirstChild("spawn_units")
	frame = frame and frame:FindFirstChild("Lives")
	frame = frame and frame:FindFirstChild("Frame")
	frame = frame and frame:FindFirstChild("Units")
	if not frame then
		return result
	end
	for _, slot in ipairs(frame:GetChildren()) do
		local uuid = slot:GetAttribute("_equipped_frame_unit_uuid")
		local main = slot:FindFirstChild("Main")
		local view = main and main:FindFirstChild("View")
		local world = view and view:FindFirstChild("WorldModel")
		local model = world and world:FindFirstChildOfClass("Model")
		if type(uuid) == "string" and model then
			local id = baseUnitId(model.Name)
			result.uuidToId[uuid] = id
			result.count += 1
			if not result.idToUuid[id] then
				result.idToUuid[id] = uuid
			end
		end
	end
	return result
end

local function uuidArgIndex(event)
	if event.uuidArg then
		return event.uuidArg
	end
	for i = 1, event.n do
		local item = event.args[i]
		if type(item) == "string" and string.match(item, "^{%x+%-") then
			return i
		end
	end
	return nil
end

local function newMap()
	return { idxToModel = {}, modelToIdx = {} }
end

local function queueResolve(map, idx, position, event)
	table.insert(hub.pending, { map = map, idx = idx, pos = position, born = os.clock(), event = event })
end

local function resolvePending()
	if #hub.pending == 0 then
		return
	end
	local models = unitModels()
	for i = #hub.pending, 1, -1 do
		local item = hub.pending[i]
		local bestModel, bestDist = nil, 7
		for _, model in ipairs(models) do
			if not item.map.modelToIdx[model] then
				local ok, pivot = pcall(function()
					return model:GetPivot().Position
				end)
				if ok then
					local flat = Vector3.new(pivot.X - item.pos.X, 0, pivot.Z - item.pos.Z).Magnitude
					if flat < bestDist then
						bestDist = flat
						bestModel = model
					end
				end
			end
		end
		if bestModel then
			item.map.idxToModel[item.idx] = bestModel
			item.map.modelToIdx[bestModel] = item.idx
			if item.event then
				item.event.unit = bestModel.Name
				if not item.event.unitId then
					local stats = bestModel:FindFirstChild("_stats")
					local idValue = stats and stats:FindFirstChild("id")
					item.event.unitId = idValue and tostring(idValue.Value) or baseUnitId(bestModel.Name)
				end
			end
			table.remove(hub.pending, i)
		elseif os.clock() - item.born > 15 then
			table.remove(hub.pending, i)
			local rec = hub.rec
			if rec and item.event then
				local at = table.find(rec.events, item.event)
				if at then
					table.remove(rec.events, at)
				end
			end
		end
	end
end

local function serialize(value, map)
	local kind = typeof(value)
	if kind == "string" or kind == "number" or kind == "boolean" then
		return value, true
	elseif kind == "CFrame" then
		return { _t = "cf", c = { value:GetComponents() } }, true
	elseif kind == "Vector3" then
		return { _t = "v3", x = value.X, y = value.Y, z = value.Z }, true
	elseif kind == "Instance" then
		local idx = map.modelToIdx[value]
		if idx then
			return { _t = "unit", i = idx }, true
		end
		return nil, false
	elseif kind == "table" then
		local out = {}
		for key, item in pairs(value) do
			local encoded, ok = serialize(item, map)
			if not ok then
				return nil, false
			end
			out[key] = encoded
		end
		return out, true
	end
	return nil, false
end

local function deserialize(value, map)
	if type(value) ~= "table" then
		return value, true
	end
	if value._t == "cf" then
		return CFrame.new(unpack(value.c)), true
	elseif value._t == "v3" then
		return Vector3.new(value.x, value.y, value.z), true
	elseif value._t == "unit" then
		local model = map.idxToModel[value.i]
		if model and model.Parent then
			return model, true
		end
		return nil, false
	end
	local out = {}
	for key, item in pairs(value) do
		local decoded, ok = deserialize(item, map)
		if not ok then
			return nil, false
		end
		out[key] = decoded
	end
	return out, true
end

local function unitIndexOf(value)
	if type(value) ~= "table" then
		return nil
	end
	if value._t == "unit" then
		return value.i
	end
	for _, item in pairs(value) do
		local idx = unitIndexOf(item)
		if idx then
			return idx
		end
	end
	return nil
end

local function unitLabels(events)
	local labels, counts = {}, {}
	for _, event in ipairs(events) do
		if event.name == "spawn_unit" and event.idx then
			local id = event.unitId or (event.unit and baseUnitId(event.unit)) or "unit"
			counts[id] = (counts[id] or 0) + 1
			labels[event.idx] = id .. " no." .. tostring(counts[id])
		end
	end
	return labels
end

local function describeEvent(event, labels)
	labels = labels or {}
	local name = event.name
	local idx = unitIndexOf(event.args)
	local target = (idx and labels[idx]) or "unit"
	if name == "spawn_unit" then
		return "Place " .. (labels[event.idx] or tostring(event.unitId or "unit"))
	elseif name == "upgrade_unit_ingame" then
		return "Upgrade " .. target
	elseif name == "sell_unit_ingame" then
		return "Sell " .. target
	elseif name == "use_active_attack" or name == "use_custom_unit_control" then
		return "Skill of " .. target
	elseif name == "use_ingame_spell" then
		return "Spell " .. tostring(event.args[1])
	elseif name == "change_priority" then
		return "Target of " .. target .. " to " .. tostring(event.args[2])
	end
	return name
end

local function macroStatusText()
	local rec = hub.rec
	if rec then
		local last = rec.events[#rec.events]
		return string.format("Mode: Recording\nActions so far: %d\nLast: %s", #rec.events, last and describeEvent(last, unitLabels(rec.events)) or "none yet, place a unit")
	end
	local info = hub.playInfo
	if hub.macroState == "playing" and info then
		local eta = math.max(0, math.ceil(info.at - os.clock()))
		return string.format("Mode: Playing %s\nStep %d of %d\nNext: %s in %ds", info.name, info.index, info.total, info.desc, eta)
	end
	local head = hub.macroState == "done" and "Mode: Finished\n" or "Mode: Idle\n"
	local macro = hub.macros[hub.settings.macro]
	if macro then
		return head .. string.format("Selected: %s, %d actions\nAuto play: %s", hub.settings.macro, #macro.events, hub.settings.playMacro and "on" or "off")
	end
	return head .. "No macro yet. Turn on Record Macro, then play a level."
end

local function refreshMacroStatus()
	local text = macroStatusText()
	if text ~= hub.macroText and ui.macroStatus then
		hub.macroText = text
		pcall(function()
			ui.macroStatus:UpdateBody(text)
		end)
	end
end

local function recordEvent(name, args)
	local rec = hub.rec
	if not rec then
		return
	end
	local t = (args.t or os.clock()) - (hub.gameClock or rec.t0)
	local position
	if name == "spawn_unit" then
		for i = 1, args.n do
			if typeof(args[i]) == "CFrame" then
				position = args[i].Position
				break
			end
		end
		if not position then
			return
		end
		local encoded = {}
		for i = 1, args.n do
			local item, ok = serialize(args[i], rec.map)
			if not ok then
				return
			end
			encoded[i] = item
		end
		rec.count += 1
		local idx = rec.count
		local event = { t = t, name = name, idx = idx, args = encoded, n = args.n }
		local equipped = equippedUnits()
		for i = 1, args.n do
			if type(args[i]) == "string" and equipped.uuidToId[args[i]] then
				event.uuidArg = i
				event.unitId = equipped.uuidToId[args[i]]
				break
			end
		end
		queueResolve(rec.map, idx, position, event)
		table.insert(rec.events, event)
	else
		local deadline = os.clock() + 4
		while os.clock() < deadline do
			local encoded, complete = {}, true
			for i = 1, args.n do
				local item, ok = serialize(args[i], rec.map)
				if not ok then
					complete = false
					break
				end
				encoded[i] = item
			end
			if complete then
				table.insert(rec.events, { t = t, name = name, args = encoded, n = args.n })
				break
			end
			task.wait(0.1)
		end
	end
	refreshMacroStatus()
end

local function unitUpgradeLevel(model)
	local ok, value = pcall(function()
		return model._stats.upgrade.Value
	end)
	return ok and tonumber(value) or nil
end

local function confirmAndRecord(name, args)
	if not hub.rec then
		return
	end
	if name == "upgrade_unit_ingame" or name == "sell_unit_ingame" then
		local model = args[1]
		if typeof(model) ~= "Instance" then
			return
		end
		local before = args.before
		local deadline = os.clock() + 3
		local confirmed = false
		while os.clock() < deadline do
			if name == "sell_unit_ingame" then
				if not model.Parent then
					confirmed = true
					break
				end
			else
				local now = unitUpgradeLevel(model)
				if before and now and now > before then
					confirmed = true
					break
				end
			end
			task.wait(0.1)
		end
		if not confirmed then
			return
		end
	end
	recordEvent(name, args)
end

local function hookHandler(self, ...)
	if not hub.rec or typeof(self) ~= "Instance" then
		return
	end
	local name = self.Name
	if not trackedRemotes[name] then
		return
	end
	local args = table.pack(...)
	args.t = os.clock()
	if name == "upgrade_unit_ingame" and typeof(args[1]) == "Instance" then
		args.before = unitUpgradeLevel(args[1])
	end
	task.defer(function()
		pcall(confirmAndRecord, name, args)
	end)
end

local function installHook()
	genv.AnimeAdventureHandler = nil
	genv.AnimeAdventureRecorder = hookHandler
	if genv.AnimeAdventureHookV2 then
		return true
	end
	if not hookmetamethod or not newcclosure or not getnamecallmethod then
		return false
	end
	local ok = pcall(function()
		local old
		old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
			local recorder = genv.AnimeAdventureRecorder
			if recorder and not checkcaller() then
				local method = getnamecallmethod()
				if method == "InvokeServer" then
					pcall(recorder, self, ...)
					if setnamecallmethod then
						pcall(setnamecallmethod, method)
					end
				end
			end
			return old(self, ...)
		end))
	end)
	if ok then
		genv.AnimeAdventureHookV2 = true
	end
	return ok
end

local function macroNames()
	local names = {}
	for name in pairs(hub.macros) do
		table.insert(names, name)
	end
	table.sort(names)
	return names
end

local function refreshMacroDropdown()
	if not ui.macroDropdown then
		return
	end
	ui.suppress = true
	pcall(function()
		ui.macroDropdown:ClearOptions()
		ui.macroDropdown:InsertOptions(macroNames())
		if hub.macros[hub.settings.macro] then
			ui.macroDropdown:UpdateSelection(hub.settings.macro)
		end
	end)
	ui.suppress = false
end

local function startRecording()
	if hub.rec then
		return true
	end
	if hub.macroState == "playing" then
		setStatus("Turn off Play Macro before recording")
		return false
	end
	if not installHook() then
		setStatus("Recording needs hookmetamethod, not supported here")
		return false
	end
	hub.rec = { events = {}, map = newMap(), count = 0, t0 = os.clock() }
	setStatus("Recording: place and upgrade units, use skills")
	refreshMacroStatus()
	return true
end

local function stopRecording(save)
	local rec = hub.rec
	if not rec then
		return
	end
	hub.rec = nil
	setToggle(ui.recordToggle, false)
	if not save then
		setStatus("Recording discarded")
		refreshMacroStatus()
		return
	end
	if #rec.events == 0 then
		setStatus("Nothing was recorded")
		refreshMacroStatus()
		return
	end
	table.sort(rec.events, function(a, b)
		return a.t < b.t
	end)
	local typed = ui.macroName and ui.macroName:GetInput() or ""
	local name = macroFileName(typed)
	if string.match(typed, "^%s*$") then
		local index = #macroNames() + 1
		name = "Macro " .. tostring(index)
		while hub.macros[name] do
			index += 1
			name = "Macro " .. tostring(index)
		end
	end
	hub.macros[name] = { level = hub.settings.level, events = rec.events }
	hub.settings.macro = name
	saveMacro(name)
	saveConfig()
	loadMacros()
	refreshMacroDropdown()
	setStatus("Saved " .. name .. " (" .. tostring(#rec.events) .. " actions) to the macros folder")
	refreshMacroStatus()
end

local function syncMacroFiles(force)
	local names = {}
	for _, entry in ipairs(macroFileList()) do
		table.insert(names, entry.name)
	end
	local signature = table.concat(names, "|")
	if force or signature ~= hub.macroSignature then
		loadMacros()
		refreshMacroDropdown()
		refreshMacroStatus()
	end
end

local nameMask = { text = "Order Hub", on = false, originals = setmetatable({}, { __mode = "k" }), hooked = setmetatable({}, { __mode = "k" }), heads = setmetatable({}, { __mode = "k" }) }

function nameMask.mine(text)
	return text == LocalPlayer.DisplayName or text == LocalPlayer.Name or text == "@" .. LocalPlayer.Name
end

function nameMask.isName(object)
	return object:IsA("TextLabel") and (object.Name == "Owner" or object.Name == "Name_Text")
end

function nameMask.redraw(label)
	if label.TextScaled then
		label.TextScaled = false
		task.spawn(function()
			task.wait(0.15)
			label.TextScaled = true
		end)
	end
end

function nameMask.cover(label)
	if nameMask.on and label.Text ~= nameMask.text and nameMask.mine(label.Text) then
		nameMask.originals[label] = label.Text
		label.Text = nameMask.text
		nameMask.redraw(label)
	end
end

function nameMask.setLevel(label)
	local custom = hub.alive and string.sub(string.gsub(tostring(hub.settings.customLevel or ""), "^%s*(.-)%s*$", "%1"), 1, 12) or ""
	if custom ~= "" then
		if label.Text ~= custom then
			if label.Text ~= nameMask.lastLevel then
				nameMask.realLevel = label.Text
			end
			label.Text = custom
			nameMask.redraw(label)
		end
		nameMask.lastLevel = custom
	elseif nameMask.realLevel then
		if label.Text == nameMask.lastLevel then
			label.Text = nameMask.realLevel
			nameMask.redraw(label)
		end
		nameMask.realLevel = nil
		nameMask.lastLevel = nil
	end
end

function nameMask.watch(label)
	if not nameMask.hooked[label] then
		nameMask.hooked[label] = true
		label:GetPropertyChangedSignal("Text"):Connect(function()
			if hub.alive then
				pcall(nameMask.cover, label)
			end
		end)
	end
	nameMask.cover(label)
end

local function applyHideName()
	local want = hub.alive and hub.settings.hideName == true
	if want ~= nameMask.on then
		nameMask.on = want
		if want then
			for index, object in ipairs(workspace:GetDescendants()) do
				if nameMask.isName(object) then
					pcall(nameMask.watch, object)
				end
				if index % 1500 == 0 then
					task.wait()
				end
			end
		else
			for label, text in pairs(nameMask.originals) do
				pcall(function()
					label.Text = text
					nameMask.redraw(label)
				end)
			end
			table.clear(nameMask.originals)
		end
	end
	local character = LocalPlayer.Character
	local head = character and character:FindFirstChild("Head")
	local overhead = head and head:FindFirstChild("_overhead")
	if overhead and overhead:IsA("BillboardGui") then
		local frame = overhead:FindFirstChild("Frame")
		if not nameMask.heads[overhead] then
			nameMask.heads[overhead] = true
			overhead.Enabled = true
			local nameFrame = frame and frame:FindFirstChild("Name_Frame")
			local nameText = nameFrame and nameFrame:FindFirstChild("Name_Text")
			if nameText then
				nameMask.redraw(nameText)
			end
		end
		local guild = frame and frame:FindFirstChild("Guild_Frame")
		if guild and guild.Visible == want then
			guild.Visible = not want
		end
		local levelFrame = frame and frame:FindFirstChild("Level_Frame")
		local level = levelFrame and levelFrame:FindFirstChild("Level")
		if level and level:IsA("TextLabel") then
			nameMask.setLevel(level)
		end
	end
end

local function stopPlayback()
	if hub.playThread then
		pcall(task.cancel, hub.playThread)
		hub.playThread = nil
	end
	hub.play = nil
	hub.playInfo = nil
	if hub.macroState == "playing" then
		hub.macroState = "idle"
	end
end

local function referencesFailed(value, failed)
	local idx = unitIndexOf(value)
	return idx ~= nil and failed[idx] == true
end

local function unitData(id)
	if not hub.unitsData then
		local ok, data = pcall(function()
			return require(ReplicatedStorage.src.Data.Units)
		end)
		hub.unitsData = (ok and type(data) == "table") and data or {}
	end
	return id and hub.unitsData[id] or nil
end

local function modelUnitId(model)
	local stats = model:FindFirstChild("_stats")
	local idValue = stats and stats:FindFirstChild("id")
	return idValue and tostring(idValue.Value) or baseUnitId(model.Name)
end

local function ownedWithUuid(uuid)
	local list = {}
	for _, model in ipairs(unitModels()) do
		if uuid and modelUuid(model) == uuid then
			table.insert(list, model)
		end
	end
	return list
end

local function myResource()
	local stats = LocalPlayer:FindFirstChild("_stats")
	local value = stats and stats:FindFirstChild("resource")
	return value and tonumber(value.Value) or math.huge
end

hub.gcScans = {}

function hub.gcFind(key, keys, match, retry)
	local scan = hub.gcScans[key]
	if not scan then
		scan = {}
		hub.gcScans[key] = scan
	end
	if scan.found then
		local ok, valid = pcall(match, scan.found)
		if ok and valid then
			return scan.found
		end
		scan.found = nil
	end
	if scan.running or os.clock() < (scan.nextAt or 0) then
		return nil
	end
	scan.running = true
	spawnThread(function()
		pcall(function()
			if type(filtergc) == "function" then
				local ok, hit = pcall(filtergc, "table", { Keys = keys }, true)
				if ok and type(hit) == "table" and match(hit) then
					scan.found = hit
					return
				end
			end
			local list = getgc(true)
			local budget = os.clock()
			for index = 1, #list do
				local value = list[index]
				if type(value) == "table" and match(value) then
					scan.found = value
					break
				end
				if index % 1500 == 0 and os.clock() - budget > 0.006 then
					task.wait()
					budget = os.clock()
				end
			end
		end)
		scan.running = false
		scan.nextAt = os.clock() + (retry or 10)
	end)
	return nil
end

local function gameSession()
	if hub.session and type(hub.session.profile_data) == "table" then
		return hub.session
	end
	hub.session = hub.gcFind("session", { "profile_data", "inventory", "collection" }, function(value)
		return type(rawget(value, "profile_data")) == "table" and rawget(value, "inventory") ~= nil and rawget(value, "collection") ~= nil
	end, 5)
	return hub.session
end

local eventTeam = {
	level = "summer2_event",
	state = "Off",
	shopState = "Off",
	weathers = { "rain", "windy", "snow", "fire", "sandstorm", "mana", "underwater", "downpour", "meteor_shower" },
	weatherNames = { rain = "Rainy", windy = "Windy", snow = "Blizzard", fire = "Inferno", sandstorm = "Sandstorm", mana = "Magical", underwater = "Flooded", downpour = "Stormy", meteor_shower = "Starfall", clear = "Clear" },
	joinRules = { "Always", "New map or weather", "New map only", "New weather only" },
	playModes = { "Solo", "Party", "Find Match" },
	mapNames = {},
}
hub.eventTeam = eventTeam

function eventTeam.inRoom(lobby, player)
	local owner = lobby:FindFirstChild("Owner")
	if owner and owner.Value == player then
		return true
	end
	local players = lobby:FindFirstChild("Players")
	for _, entry in ipairs(players and players:GetChildren() or {}) do
		if entry.Name == player.Name or entry.Name == tostring(player.UserId) then
			return true
		end
		if entry:IsA("ObjectValue") and entry.Value == player then
			return true
		end
		if entry:IsA("StringValue") and (entry.Value == player.Name or entry.Value == tostring(player.UserId)) then
			return true
		end
		if (entry:IsA("IntValue") or entry:IsA("NumberValue")) and entry.Value == player.UserId then
			return true
		end
	end
	return false
end

function eventTeam.rooms()
	local list = {}
	local root = workspace:FindFirstChild("_LOBBIES")
	for _, group in ipairs(root and root:GetChildren() or {}) do
		for _, lobby in ipairs(group:GetChildren()) do
			if lobby:FindFirstChild("Owner") then
				table.insert(list, lobby)
			end
		end
	end
	return list
end

function eventTeam.inEventLobby()
	local portals = workspace:FindFirstChild("_PORTALS")
	local folder = portals and portals:FindFirstChild("Lobbies")
	local list = folder and folder:GetChildren() or {}
	for _, lobby in ipairs(eventTeam.rooms()) do
		table.insert(list, lobby)
	end
	for _, lobby in ipairs(list) do
		local level = lobby:FindFirstChild("Level")
		if level and level:IsA("StringValue") and level.Value == eventTeam.level and eventTeam.inRoom(lobby, LocalPlayer) then
			return true, lobby
		end
	end
	return false
end

function eventTeam.party()
	return hub.settings.autoSummerHunt == true and hub.settings.summerMode == "Party"
end

function eventTeam.partyInfo()
	local id = LocalPlayer:GetAttribute("PartyId")
	if id == nil or id == "" then
		return nil
	end
	local members = {}
	for _, player in ipairs(Players:GetPlayers()) do
		if player:GetAttribute("PartyId") == id then
			table.insert(members, player)
		end
	end
	return { owner = tonumber(LocalPlayer:GetAttribute("PartyOwnerId")) == LocalPlayer.UserId, members = members }
end

function eventTeam.partyMember()
	if not eventTeam.party() then
		return false
	end
	local info = eventTeam.partyInfo()
	return info ~= nil and not info.owner
end

function eventTeam.ownedRoom()
	local portals = workspace:FindFirstChild("_PORTALS")
	local folder = portals and portals:FindFirstChild("Lobbies")
	local list = folder and folder:GetChildren() or {}
	for _, lobby in ipairs(eventTeam.rooms()) do
		table.insert(list, lobby)
	end
	for _, lobby in ipairs(list) do
		local owner = lobby:FindFirstChild("Owner")
		local level = lobby:FindFirstChild("Level")
		if owner and owner.Value == LocalPlayer and level and level.Value == eventTeam.level then
			return lobby
		end
	end
	return nil
end

function eventTeam.roomTick()
	local room = eventTeam.ownedRoom()
	if not room then
		eventTeam.roomSince = nil
		if os.clock() < (eventTeam.nextRequest or 0) then
			return
		end
		eventTeam.nextRequest = os.clock() + 10
		eventTeam.nextStart = os.clock() + 2
		local result, _, done = invoke("open_event_portal", eventTeam.level, { difficulty = "Hard", friends_only = true })
		setStatus(done and result and "Summer Hunt: opened your room" or "Summer Hunt: could not open a room, retrying")
		return
	end
	eventTeam.roomSince = eventTeam.roomSince or os.clock()
	local teleporting = room:FindFirstChild("Teleporting")
	if teleporting and teleporting.Value then
		if hub.status ~= "Summer Hunt: teleporting" then
			setStatus("Summer Hunt: teleporting")
		end
		return
	end
	if hub.settings.summerMode == "Party" then
		local info = eventTeam.partyInfo()
		local missing = 0
		for _, player in ipairs(info and info.members or {}) do
			if player ~= LocalPlayer and not eventTeam.inRoom(room, player) then
				missing += 1
			end
		end
		if missing > 0 and os.clock() - eventTeam.roomSince < 90 then
			local text = string.format("Summer Hunt party: waiting for %d member(s) (%ds)", missing, math.floor(90 - (os.clock() - eventTeam.roomSince)))
			if hub.status ~= text then
				setStatus(text)
			end
			return
		end
	end
	if os.clock() >= (eventTeam.nextStart or 0) then
		eventTeam.nextStart = os.clock() + 5
		invoke("request_start_game", room.Name)
		setStatus("Summer Hunt: starting your room")
	end
end

function eventTeam.weatherName(id)
	return eventTeam.weatherNames[tostring(id)] or tostring(id or "?")
end

function eventTeam.mapName(id)
	id = tostring(id or "")
	if id == "" then
		return "?"
	end
	if eventTeam.mapNames[id] == nil then
		local name = id
		pcall(function()
			local data = require(ReplicatedStorage.src.Data.Maps)[id]
			if type(data) == "table" and type(data.name) == "string" then
				name = data.name
			end
		end)
		eventTeam.mapNames[id] = name
	end
	return eventTeam.mapNames[id]
end

function eventTeam.rotation()
	local service = eventTeam.service
	if not (service and type(rawget(service, "_CURRENT_EVENT_CHALLENGES")) == "table") then
		service = hub.gcFind("eventChallenges", { "_CURRENT_EVENT_CHALLENGES" }, function(value)
			return type(rawget(value, "_CURRENT_EVENT_CHALLENGES")) == "table"
		end, 10)
		eventTeam.service = service
	end
	local current = service and rawget(service, "_CURRENT_EVENT_CHALLENGES")
	local entry = type(current) == "table" and current[eventTeam.level]
	if type(entry) ~= "table" then
		return nil
	end
	local levelData = type(entry.current_level_data) == "table" and entry.current_level_data or {}
	local forecast = type(entry.forecast) == "table" and entry.forecast or {}
	return { weather = entry.current_weather, map = levelData.map, nextWeather = forecast.weather }
end

function eventTeam.wins()
	local session = gameSession()
	local wins = session and type(session.profile_data) == "table" and session.profile_data._summer2_hunt_wins
	wins = type(wins) == "table" and wins or {}
	return type(wins.maps) == "table" and wins.maps or {}, type(wins.weathers) == "table" and wins.weathers or {}
end

function eventTeam.pearls()
	local session = gameSession()
	local resources = session and type(session.profile_data) == "table" and session.profile_data.resources
	return type(resources) == "table" and tonumber(resources.SummerPearls) or 0
end

function eventTeam.allowed(weather, map)
	local skip = type(hub.settings.summerSkipWeathers) == "table" and hub.settings.summerSkipWeathers or {}
	if weather and table.find(skip, eventTeam.weatherName(weather)) then
		return false, "skipping " .. eventTeam.weatherName(weather)
	end
	local rule = hub.settings.summerJoinRule
	if rule == nil or rule == eventTeam.joinRules[1] then
		return true, nil
	end
	local maps, weathers = eventTeam.wins()
	local newMap = map ~= nil and not maps[map]
	local newWeather = weather ~= nil and not weathers[weather]
	if rule == eventTeam.joinRules[2] and not (newMap or newWeather) then
		return false, "map and weather already won"
	elseif rule == eventTeam.joinRules[3] and not newMap then
		return false, "map already won"
	elseif rule == eventTeam.joinRules[4] and not newWeather then
		return false, "weather already won"
	end
	return true, nil
end

function eventTeam.joinCheck()
	local info = eventTeam.rotation()
	if not info then
		eventTeam.missingSince = eventTeam.missingSince or os.clock()
		if os.clock() - eventTeam.missingSince < 30 then
			eventTeam.state = "Reading the event rotation"
			return false
		end
		eventTeam.state = "Rotation unknown, joining anyway"
		return true
	end
	eventTeam.missingSince = nil
	local ok, reason = eventTeam.allowed(info.weather, info.map)
	local now = eventTeam.weatherName(info.weather) .. " on " .. eventTeam.mapName(info.map)
	local nextText = info.nextWeather and (", next " .. eventTeam.weatherName(info.nextWeather)) or ""
	eventTeam.state = ok and ("Ready: " .. now .. nextText) or ("Waiting: " .. now .. " (" .. tostring(reason) .. ")" .. nextText)
	return ok
end

function eventTeam.levelAllowed()
	local ok, data = pcall(function()
		return require(ReplicatedStorage.src.Loader).LevelData
	end)
	if not (ok and type(data) == "table") then
		return false
	end
	local allowed = eventTeam.allowed(data._weather, data.map)
	return allowed
end

function eventTeam.onMatchmaking(...)
	for _, value in ipairs({ ... }) do
		if value == eventTeam.level then
			eventTeam.matching = true
		end
	end
end

function eventTeam.leaveQueue()
	if eventTeam.matching and eventTeam.requested then
		invoke("leave_matchmaking")
		eventTeam.matching = false
	end
	eventTeam.requested = false
end

function eventTeam.lobbyTick()
	local character = LocalPlayer.Character
	if not (character and character:FindFirstChild("HumanoidRootPart")) then
		return
	end
	if eventTeam.partyMember() then
		local text = eventTeam.inEventLobby() and "Summer Hunt party: in the host's room" or "Summer Hunt party: waiting for the host"
		if hub.status ~= text then
			setStatus(text)
		end
		return
	end
	if hub.settings.summerMode ~= "Find Match" then
		if eventTeam.matching and eventTeam.requested then
			eventTeam.leaveQueue()
		end
		if not eventTeam.teleporting then
			eventTeam.roomTick()
		end
		return
	end
	local room = eventTeam.ownedRoom()
	if room and not (room:FindFirstChild("Teleporting") and room.Teleporting.Value) then
		invoke("request_leave_lobby", room.Name)
	end
	if eventTeam.matching then
		if hub.status ~= "Summer Hunt: looking for a match" then
			setStatus("Summer Hunt: looking for a match")
		end
		return
	end
	if eventTeam.teleporting or os.clock() < (eventTeam.nextRequest or 0) then
		return
	end
	eventTeam.nextRequest = os.clock() + 15
	eventTeam.requested = true
	invoke("request_matchmaking", eventTeam.level)
	setStatus("Summer Hunt: joining matchmaking")
end

function eventTeam.onMatchmakingEnded()
	eventTeam.matching = false
end

function eventTeam.onTeleport(state)
	if state == Enum.TeleportState.Failed then
		eventTeam.teleporting = false
	elseif state == Enum.TeleportState.Started or state == Enum.TeleportState.InProgress then
		eventTeam.teleporting = true
	end
end

function eventTeam.shopTick()
	if not (hub.settings.summerClaimBingo or hub.settings.summerBuyStars) or os.clock() < (eventTeam.nextShop or 0) then
		return
	end
	eventTeam.nextShop = os.clock() + 3
	if hub.settings.summerClaimBingo then
		local count = 0
		for _ in pairs((eventTeam.wins())) do
			count += 1
		end
		if count > 0 and (count ~= eventTeam.claimKey or os.clock() >= (eventTeam.nextClaim or 0)) then
			eventTeam.claimKey = count
			eventTeam.nextClaim = os.clock() + 600
			local result, _, done = invoke("claim_summer2_map_board_lines")
			if done and result then
				eventTeam.shopState = "Claimed bingo rewards"
				setStatus("Summer: claimed bingo rewards")
			end
		end
	end
	if hub.settings.summerBuyStars then
		local pearls = eventTeam.pearls()
		local spare = pearls - math.max(tonumber(hub.settings.summerKeepPearls) or 0, 0)
		if spare >= 150 then
			local amount = spare >= 1500 and "10" or "1"
			local before = pearls
			invoke("buy_item_generic", "capsule_summer2", "event", eventTeam.shopGui or "event_shop", amount)
			task.wait(1.5)
			if eventTeam.pearls() < before then
				eventTeam.bought = (eventTeam.bought or 0) + tonumber(amount)
				eventTeam.shopState = "Bought " .. eventTeam.bought .. " Sunny Stars this session"
			else
				eventTeam.nextShop = os.clock() + 60
				eventTeam.shopState = "Star purchase did not go through, retry in 60 s"
			end
		end
	end
end

function eventTeam.progressText()
	if os.clock() < (eventTeam.nextProgress or 0) and eventTeam.progress then
		return eventTeam.progress
	end
	eventTeam.nextProgress = os.clock() + 3
	local maps, weathers = eventTeam.wins()
	local mapCount, weatherCount = 0, 0
	for _ in pairs(maps) do
		mapCount += 1
	end
	for id in pairs(weathers) do
		if table.find(eventTeam.weathers, id) then
			weatherCount += 1
		end
	end
	local missing = {}
	for _, id in ipairs(eventTeam.weathers) do
		if not weathers[id] then
			table.insert(missing, eventTeam.weatherName(id))
		end
	end
	eventTeam.progress = string.format("Pearls %s | maps won %d | weathers won %d/%d%s", hub.webhook and hub.webhook.comma(eventTeam.pearls()) or tostring(eventTeam.pearls()), mapCount, weatherCount, #eventTeam.weathers, #missing > 0 and (" (missing " .. table.concat(missing, ", ") .. ")") or "")
	return eventTeam.progress
end

eventTeam.pickModes = { "Good first", "Bad first (more pearls)" }
eventTeam.knownPicks = { "+ Attack", "+ Range", "- Cooldown", "+ Boss Damage", "+ Yen", "+ Random Blessings", "+ Enemy Health", "+ Enemy Shield", "+ Enemy Speed", "+ Enemy Regen", "+ Explosive Deaths", "+ Resistant Enemies", "+ Spellproof Enemies", "+ Plated Enemies", "+ Random Curses", "+ New Path" }

function eventTeam.baseTitle(title)
	return (string.gsub(tostring(title or ""), "%s+[IVX]+$", ""))
end

function eventTeam.pickNames()
	local names, seen = {}, {}
	local stored = type(hub.settings.rogueSeen) == "table" and hub.settings.rogueSeen or {}
	for _, list in ipairs({ eventTeam.knownPicks, stored }) do
		for _, name in ipairs(list) do
			if not seen[name] then
				seen[name] = true
				table.insert(names, name)
			end
		end
	end
	return names
end

function eventTeam.priority()
	local list = type(hub.settings.roguePriority) == "table" and hub.settings.roguePriority or {}
	if #list == 0 and type(hub.settings.roguePrefer) == "table" and #hub.settings.roguePrefer > 0 then
		list = table.clone(hub.settings.roguePrefer)
		hub.settings.roguePriority = list
	end
	return list
end

eventTeam.tierRules = { "Higher tier first", "Priority first" }

function eventTeam.tierOf(title)
	local numeral = string.match(tostring(title or ""), "%s([IVX]+)$")
	if not numeral then
		return 1
	end
	local values = { I = 1, V = 5, X = 10 }
	local total, previous = 0, 0
	for index = #numeral, 1, -1 do
		local value = values[string.sub(numeral, index, index)] or 0
		if value < previous then
			total -= value
		else
			total += value
			previous = value
		end
	end
	return math.max(total, 1)
end

function eventTeam.choose(options)
	local rank = {}
	local priority = eventTeam.priority()
	for index, name in ipairs(priority) do
		rank[name] = index
	end
	local avoid = {}
	for _, name in ipairs(type(hub.settings.rogueAvoid) == "table" and hub.settings.rogueAvoid or {}) do
		avoid[name] = true
	end
	local list = {}
	local topRank, topSide = nil, nil
	for key, option in pairs(options) do
		if type(option) == "table" then
			local name = eventTeam.baseTitle(option.title)
			local item = { key = key, rank = rank[name] or (#priority + 1), tier = eventTeam.tierOf(option.title), good = option.option_type == "Good", avoid = avoid[name] == true }
			table.insert(list, item)
			if not item.avoid and rank[name] and (not topRank or item.rank < topRank) then
				topRank, topSide = item.rank, item.good
			end
		end
	end
	local wantGood = topSide
	if wantGood == nil then
		wantGood = hub.settings.rogueMode ~= eventTeam.pickModes[2]
	end
	local tierFirst = hub.settings.rogueTierRule ~= eventTeam.tierRules[2]
	local best, bestScore = nil, nil
	for _, item in ipairs(list) do
		local score = 0
		if item.avoid then
			score = -1e9
		else
			if item.good == wantGood then
				score += 1e6
			end
			if tierFirst then
				score += item.tier * 1000 - item.rank
			else
				score += (100 - item.rank) * 1000 + item.tier
			end
		end
		if not bestScore or score > bestScore then
			best, bestScore = item.key, score
		end
	end
	return best
end

function eventTeam.learn(options)
	local stored = type(hub.settings.rogueSeen) == "table" and hub.settings.rogueSeen or {}
	local known = {}
	for _, name in ipairs(eventTeam.pickNames()) do
		known[name] = true
	end
	local added = false
	for _, option in pairs(options) do
		if type(option) == "table" then
			local name = eventTeam.baseTitle(option.title)
			if name ~= "" and not known[name] then
				known[name] = true
				table.insert(stored, name)
				added = true
			end
		end
	end
	if added then
		setFlag("rogueSeen", stored)
		if eventTeam.refreshPickers then
			pcall(eventTeam.refreshPickers)
		end
	end
end

function eventTeam.voteFolder()
	local data = workspace:FindFirstChild("_DATA")
	return data and data:FindFirstChild("Roguelike")
end

function eventTeam.waiting()
	local folder = eventTeam.voteFolder()
	local flag = folder and folder:FindFirstChild("WaitingForRoguelikeChoice")
	return flag ~= nil and flag.Value == true
end

function eventTeam.gameUi()
	if eventTeam.uiRef then
		return eventTeam.uiRef
	end
	if os.clock() < (eventTeam.uiRetryAt or 0) or not getconnections then
		return nil
	end
	eventTeam.uiRetryAt = os.clock() + 10
	pcall(function()
		local remote = ReplicatedStorage.endpoints.server_to_client.show_roguelike_options
		for _, connection in ipairs(getconnections(remote.OnClientEvent)) do
			for _, value in pairs(debug.getupvalues(connection.Function)) do
				if type(value) == "table" and type(rawget(value, "callback")) == "function" then
					local gui = getfenv(value.callback).GUIService
					if type(gui) == "table" and type(gui.roguelike_select_ui) == "table" then
						eventTeam.uiRef = gui.roguelike_select_ui
					end
				end
			end
		end
	end)
	return eventTeam.uiRef
end

function eventTeam.optionsFromScreen()
	local ui = eventTeam.gameUi()
	if not (ui and type(ui.option_frames) == "table") then
		return nil
	end
	local options, count = {}, 0
	for key, frame in pairs(ui.option_frames) do
		if typeof(frame) == "Instance" and frame.Parent then
			local title = ""
			local kind = "Good"
			pcall(function()
				title = frame.bg.Main.Title.TextLabel.Text
				if frame.bg.Main:FindFirstChild("UIGradientDebuff") then
					kind = "Bad"
				end
			end)
			if title ~= "" then
				options[key] = { title = title, option_type = kind }
				count += 1
			end
		end
	end
	return count > 0 and options or nil
end

function eventTeam.voteLoop()
	local token = {}
	eventTeam.voteToken = token
	task.wait(0.5)
	for _ = 1, 15 do
		if eventTeam.voteToken ~= token or not hub.alive or not hub.settings.autoRogue then
			return
		end
		if not eventTeam.waiting() and os.clock() - (eventTeam.voteAt or 0) > 3 then
			return
		end
		local options = eventTeam.voteOptions or eventTeam.optionsFromScreen()
		local pick = options and eventTeam.choose(options)
		if pick ~= nil then
			local folder = eventTeam.voteFolder()
			local counter = folder and folder:FindFirstChild(tostring(pick))
			local before = counter and counter.Value or 0
			local result = invoke("select_roguelike_option", pick)
			local untilTime = os.clock() + 1.5
			while os.clock() < untilTime and not (counter and counter.Value > before) do
				task.wait(0.1)
			end
			if (counter and counter.Value > before) or result == true then
				eventTeam.voted = true
				eventTeam.lastPick = tostring(options[pick].title)
				setStatus("Picked " .. eventTeam.lastPick)
				if ui.lastPickLabel then
					pcall(function()
						ui.lastPickLabel:UpdateName("Last pick: " .. eventTeam.lastPick)
					end)
				end
				return
			end
		end
		task.wait(1)
	end
end

function eventTeam.onOptions(_, options)
	if type(options) ~= "table" then
		return
	end
	eventTeam.voteOptions = options
	eventTeam.voteAt = os.clock()
	eventTeam.voted = false
	eventTeam.learn(options)
	if hub.settings.autoRogue then
		eventTeam.voteLoop()
	end
end

function eventTeam.voteTick()
	if not hub.settings.autoRogue then
		return
	end
	if not eventTeam.waiting() then
		if os.clock() - (eventTeam.voteAt or 0) > 5 then
			eventTeam.voteOptions = nil
			eventTeam.voted = false
		end
		return
	end
	if eventTeam.voted or os.clock() < (eventTeam.nextVoteTry or 0) then
		return
	end
	if eventTeam.voteToken and os.clock() - (eventTeam.voteAt or 0) < 20 then
		return
	end
	eventTeam.nextVoteTry = os.clock() + 20
	eventTeam.voteAt = os.clock()
	task.spawn(eventTeam.voteLoop)
end


local function singularTrait(uuid)
	if not uuid then
		return nil
	end
	local session = gameSession()
	if not session then
		return nil
	end
	local ok, result = pcall(function()
		local unit = session.collection:get_unit_by_uuid(uuid)
		if type(unit) ~= "table" or type(unit.traits) ~= "table" then
			return nil
		end
		hub.traitData = hub.traitData or require(ReplicatedStorage.src.Data.Traits)
		for _, trait in pairs(unit.traits) do
			local traitId = type(trait) == "table" and trait.trait
			local info = traitId and hub.traitData[traitId]
			if type(info) == "table" and (traitId == "unique" or info.id == "unique") then
				return tostring(info.name or traitId)
			end
		end
		return nil
	end)
	return ok and result or nil
end

local function placeLimit(unitId, uuid)
	local trait = singularTrait(uuid)
	if trait then
		return 1, trait .. " trait"
	end
	local ids = { unitId }
	local baseId = string.gsub(tostring(unitId), "_evolved$", "")
	if baseId ~= unitId then
		table.insert(ids, baseId)
	end
	for _, id in ipairs(ids) do
		local info = unitData(id)
		if info then
			if tonumber(info.spawn_cap) then
				return tonumber(info.spawn_cap)
			end
			if info.show_custom_unique_info or info.unique or info._unique then
				return 1, "unique"
			end
		end
	end
	return nil
end

local costRules = {}

function costRules.levelScale()
	local scale = 1
	pcall(function()
		scale = tonumber(workspace._DATA.LevelModifiers.player_cost_scale.Value) or 1
	end)
	return scale
end

function costRules.capped(value)
	if (tonumber(LocalPlayer:GetAttribute("_negate_high_cost")) or 0) > 0 then
		return math.min(value, 1)
	end
	return value
end

function costRules.spawn(baseCost)
	return math.ceil((tonumber(baseCost) or 0) * costRules.capped(costRules.levelScale()))
end

function costRules.isCostBuffer(unitId)
	local info = unitData(unitId)
	if not info then
		return false
	end
	local function hasCostBuff(aura)
		if type(aura) ~= "table" or type(aura.buffs) ~= "table" then
			return false
		end
		for _, buff in pairs(aura.buffs) do
			if type(buff) == "table" and buff.name == "upgrade_cost_buff" then
				return true
			end
		end
		return false
	end
	if hasCostBuff(info.aura_buff) then
		return true
	end
	for _, step in ipairs(type(info.upgrade) == "table" and info.upgrade or {}) do
		if type(step) == "table" and hasCostBuff(step.aura_buff) then
			return true
		end
	end
	return false
end

local function upgradeCost(model, fallbackId)
	local stats = model:FindFirstChild("_stats")
	local info = unitData(modelUnitId(model)) or unitData(fallbackId)
	if not stats or not info then
		return nil
	end
	local level = stats:FindFirstChild("upgrade")
	local maxLevel = stats:FindFirstChild("max_upgrade")
	local current = level and tonumber(level.Value) or 0
	if maxLevel and tonumber(maxLevel.Value) and current >= tonumber(maxLevel.Value) then
		return "max"
	end
	local steps = type(info.upgrade) == "table" and info.upgrade or nil
	local step = steps and steps[current + 1]
	if type(step) ~= "table" then
		return steps and "max" or nil
	end
	local multiplier = stats:FindFirstChild("upgrade_cost_multiplier")
	local scale = costRules.capped(costRules.levelScale() * ((multiplier and tonumber(multiplier.Value)) or 1))
	return math.ceil((tonumber(step.cost) or 0) * scale)
end

local function refusedMessage(since)
	if since then
		if (hub.lastMessageAt or 0) < since then
			return nil
		end
	elseif os.clock() - (hub.lastMessageAt or 0) > 1.5 then
		return nil
	end
	local message = string.lower(hub.lastMessage or "")
	for _, key in ipairs({ "cannot place", "may not be placed", "unique", "max", "limit", "cannot be placed" }) do
		if string.find(message, key, 1, true) then
			return hub.lastMessage
		end
	end
	return nil
end

local function playMacro()
	local macro = hub.macros[hub.settings.macro]
	if not macro or #macro.events == 0 then
		setStatus("Select a macro first")
		return false
	end
	if hub.rec then
		setStatus("Turn off Record Macro first")
		return false
	end
	stopPlayback()
	local play = { map = newMap(), failed = {} }
	hub.play = play
	hub.macroState = "playing"
	local name = hub.settings.macro
	hub.playThread = task.spawn(function()
		local t0 = os.clock()
		local total = #macro.events
		local startEquipped = equippedUnits()
		local filled = false
		for _, event in ipairs(macro.events) do
			if event.name == "spawn_unit" and not event.unitId then
				local argIndex = uuidArgIndex(event)
				local unitId = argIndex and startEquipped.uuidToId[event.args[argIndex]]
				if unitId then
					event.unitId = unitId
					filled = true
				end
			end
		end
		if filled then
			saveMacro(name)
		end
		local labels = unitLabels(macro.events)
		local skipped = 0
		for index, event in ipairs(macro.events) do
			local desc = describeEvent(event, labels)
			local delay = math.max(0, event.t - (os.clock() - t0))
			hub.playInfo = { name = name, index = index, total = total, desc = desc, at = os.clock() + delay }
			setStatus("Macro " .. name .. ": step " .. tostring(index) .. " of " .. tostring(total))
			if delay > 0 then
				task.wait(delay)
			end
			local isAction = actionRemotes[event.name] == true
			local deadline = os.clock() + (isAction and 6 or 40)
			local moneyUntil = os.clock() + 300
			local done = false
			local skipReason = nil
			local override = {}

			if event.name == "spawn_unit" then
				local spawnPos = nil
				for i = 1, event.n do
					local item = event.args[i]
					if type(item) == "table" and item._t == "cf" then
						spawnPos = Vector3.new(item.c[1], item.c[2], item.c[3])
						break
					end
				end
				local targetUuid = nil
				local argIndex = uuidArgIndex(event)
				local equipped = equippedUnits()
				if argIndex and equipped.count > 0 then
					local recorded = event.args[argIndex]
					local unitId = event.unitId or equipped.uuidToId[recorded]
					targetUuid = (unitId and equipped.idToUuid[unitId]) or (equipped.uuidToId[recorded] and recorded)
					if targetUuid then
						override[argIndex] = targetUuid
					else
						skipReason = tostring(unitId or "a unit") .. " is not in your team"
					end
				elseif argIndex then
					targetUuid = event.args[argIndex]
				end
				local existing = (not skipReason) and spawnPos and unitNear(spawnPos, play.map, targetUuid)
				if existing then
					play.map.idxToModel[event.idx] = existing
					play.map.modelToIdx[existing] = event.idx
					done = true
				end
				if not done and not skipReason and event.unitId and targetUuid then
					local limit = placeLimit(event.unitId, targetUuid)
					local owned = ownedWithUuid(targetUuid)
					if limit and #owned >= limit then
						local spare, spareDist = nil, math.huge
						for _, model in ipairs(owned) do
							if not play.map.modelToIdx[model] then
								local dist = spawnPos and (model:GetPivot().Position - spawnPos).Magnitude or 0
								if dist < spareDist then
									spare, spareDist = model, dist
								end
							end
						end
						if spare then
							play.map.idxToModel[event.idx] = spare
							play.map.modelToIdx[spare] = event.idx
							done = true
						else
							skipReason = event.unitId .. " is already at its limit"
						end
					end
				end
			end

			local refusals = 0
			while not done and not skipReason and os.clock() <= deadline do
				if not select(1, gameState()) then
					done = true
					break
				end
				local args = {}
				local complete = true
				for i = 1, event.n do
					local item, ok = deserialize(event.args[i], play.map)
					if not ok then
						complete = false
						break
					end
					if override[i] ~= nil then
						item = override[i]
					end
					args[i] = item
				end
				if not complete then
					if referencesFailed(event.args, play.failed) then
						skipReason = "its unit was not placed"
						break
					end
					task.wait(0.5)
					continue
				end
				local cost = nil
				if event.name == "spawn_unit" then
					local info = unitData(event.unitId)
					cost = info and tonumber(info.cost)
				elseif event.name == "upgrade_unit_ingame" and typeof(args[1]) == "Instance" then
					cost = upgradeCost(args[1])
					if cost == "max" then
						done = true
						break
					end
				end
				if cost and myResource() < cost and os.clock() < moneyUntil then
					hub.playInfo.desc = desc .. " (waiting for money)"
					deadline = math.max(deadline, os.clock() + 5)
					task.wait(0.5)
					continue
				end
				hub.playInfo.desc = desc
				local result, _, called = invoke(event.name, unpack(args, 1, event.n))
				if result or (isAction and called) then
					done = true
					if event.name == "spawn_unit" then
						for i = 1, event.n do
							if typeof(args[i]) == "CFrame" then
								queueResolve(play.map, event.idx, args[i].Position)
								break
							end
						end
						local resolveUntil = os.clock() + 4
						while not play.map.idxToModel[event.idx] and os.clock() < resolveUntil do
							task.wait(0.1)
						end
					end
					break
				end
				task.wait(0.3)
				local refused = refusedMessage()
				if refused then
					skipReason = refused
					break
				end
				refusals += 1
				if refusals >= 3 then
					skipReason = "the game refused it 3 times"
					break
				end
				task.wait(1)
			end
			if not done then
				if event.name == "spawn_unit" then
					play.failed[event.idx] = true
				end
				skipped += 1
				setStatus("Skipped " .. desc .. ": " .. tostring(skipReason or "timed out"))
			end
		end
		hub.macroState = "done"
		hub.playInfo = nil
		hub.playThread = nil
		setStatus("Macro " .. name .. " finished, " .. tostring(skipped) .. " skipped")
	end)
	return true
end

local summon = {
	featured = {},
	rotation = nil,
	nextFetch = 0,
	pulls = 0,
	failures = 0,
	pauseUntil = 0,
	busyUntil = 0,
	state = "Off",
	lastPity = nil,
	got = nil,
	text = "",
}
hub.summon = summon

local bannerLabels = { EventClover = "Special", Legacy = "Legacy", SakamotoEvent = "Assassin Event", April2025 = "Event", Standard = "Standard" }
local summonModes = { "Gems x10", "Gems x1", "Tickets first, then gems", "Tickets only" }

local function bannersData()
	if not hub.bannersData then
		local ok, data = pcall(function()
			return require(ReplicatedStorage.src.Data.Banners)
		end)
		hub.bannersData = (ok and type(data) == "table") and data or {}
	end
	return hub.bannersData
end

local function bannerLabel(id)
	return (bannerLabels[id] or id) .. " (" .. id .. ")"
end

local function labelId(label)
	return string.match(tostring(label), "%(([^%(%)]+)%)%s*$") or tostring(label)
end

local function bannerOptions()
	local list = {}
	for id, data in pairs(bannersData()) do
		if type(id) == "string" and type(data) == "table" and data.active then
			table.insert(list, bannerLabel(id))
		end
	end
	table.sort(list)
	return list
end

local function unitLabel(id)
	local info = unitData(id)
	return tostring(info and info.name or id) .. " (" .. tostring(id) .. ")"
end

local function wantedOptions()
	if hub.wantedOptions then
		return hub.wantedOptions
	end
	local list = {}
	unitData("")
	local data = hub.unitsData or {}
	for id, info in pairs(data) do
		if type(id) == "string" and type(info) == "table" and (info.rarity == "Mythic" or info.rarity == "Secret") and not string.find(id, "_evolved", 1, true) then
			table.insert(list, unitLabel(id))
		end
	end
	table.sort(list)
	hub.wantedOptions = list
	return list
end

local function itemCount(id)
	local session = gameSession()
	if not session then
		return 0
	end
	local ok, amount = pcall(function()
		return session.inventory:get_number_of_owned_item(id)
	end)
	return (ok and tonumber(amount)) or 0
end

local function statValue(name)
	local stats = LocalPlayer:FindFirstChild("_stats")
	local value = stats and stats:FindFirstChild(name)
	return value and tonumber(value.Value) or 0
end

local function pityInfo(bannerId)
	local info = bannersData()[bannerId]
	if type(info) ~= "table" then
		return nil, nil, "Pity"
	end
	local session = gameSession()
	local pity = session and session.profile_data.pity_data and session.profile_data.pity_data[bannerId]
	local cap, value, label
	if info._show_mythic_pity then
		cap, value, label = info._show_mythic_pity, pity and pity.opens_since_mythic, "Mythic pity"
	elseif info._show_featured_pity then
		cap, value, label = info._show_featured_pity, pity and pity.opens_since_featured, "Featured pity"
	else
		cap, value, label = nil, pity and pity.opens_since_legendary, "Legendary pity"
	end
	if pity and not info._pity_dont_reset and summon.rotation and pity.banner_id ~= summon.rotation then
		value = 0
	end
	return tonumber(value) or 0, cap, label
end

local function pityOpens(bannerId)
	local session = gameSession()
	local pity = session and session.profile_data.pity_data and session.profile_data.pity_data[bannerId]
	return (pity and tonumber(pity.opens)) or 0
end

local function hatchedSnapshot()
	local snapshot = {}
	local session = gameSession()
	local stats = session and session.profile_data._hatched_unit_stats
	if type(stats) == "table" then
		for unitId, counts in pairs(stats) do
			if type(counts) == "table" then
				snapshot[unitId] = (tonumber(counts.normal) or 0) + (tonumber(counts.shiny) or 0)
			end
		end
	end
	return snapshot
end

local function refreshFeatured()
	summon.nextFetch = os.clock() + 120
	local folder = endpointFolder()
	local remote = folder and folder:FindFirstChild("get_hatch_setup_data")
	if not remote then
		return
	end
	local ok, units, _, _, rotation = pcall(remote.InvokeServer, remote)
	if ok and type(units) == "table" then
		for bannerId, data in pairs(units) do
			if type(data) == "table" and type(data.rateup_units) == "table" then
				summon.featured[bannerId] = data.rateup_units
			end
		end
		summon.rotation = rotation
	end
end

local function wantedSet()
	local set, count = {}, 0
	for _, label in ipairs(hub.settings.wantedUnits or {}) do
		set[labelId(label)] = true
		count += 1
	end
	return set, count
end

local function featuredList(bannerId)
	local list = {}
	for _, id in pairs(summon.featured[bannerId] or {}) do
		table.insert(list, id)
	end
	table.sort(list)
	return list
end

local function luckActive()
	local session = gameSession()
	local boost = session and session.profile_data.active_boosts and session.profile_data.active_boosts.LuckyNew
	if not boost then
		return false
	end
	return summon.rotation == nil or boost.start_banner_id == summon.rotation
end

local function summonStatusText()
	local bannerId = hub.settings.summonBanner
	local names = {}
	local wanted = wantedSet()
	for _, id in ipairs(featuredList(bannerId)) do
		local info = unitData(id)
		table.insert(names, tostring(info and info.name or id) .. (wanted[id] and " *" or ""))
	end
	local value, cap, label = pityInfo(bannerId)
	local pityLine = label .. ": " .. tostring(value or 0) .. (cap and ("/" .. tostring(cap)) or "")
	return string.format(
		"State: %s\nBanner now: %s\n%s\nGems %d | Tickets %d | Luck Potions %d%s\nSummoned this session: %d" .. (summon.lastGot and ("\nLast new unit: " .. summon.lastGot) or ""),
		summon.state,
		#names > 0 and table.concat(names, ", ") or "loading",
		pityLine,
		statValue("gem_amount"),
		itemCount("summon_ticket"),
		itemCount("LuckPotion"),
		luckActive() and " (luck on)" or "",
		summon.pulls
	)
end

local function refreshSummonStatus()
	local text = summonStatusText()
	if text ~= summon.text and ui.summonStatus then
		summon.text = text
		pcall(function()
			ui.summonStatus:UpdateBody(text)
		end)
	end
end

local function stopSummon(reason)
	hub.settings.autoSummon = false
	saveConfig()
	setToggle(ui.summonToggle, false)
	summon.state = reason
	setStatus("Auto Summon stopped: " .. reason)
end

local function onUnitsHatched(uuids)
	if type(uuids) ~= "table" then
		return
	end
	local session = gameSession()
	local wanted, count = wantedSet()
	for _, uuid in pairs(uuids) do
		local ok, unit = pcall(function()
			return session.collection:get_unit_by_uuid(uuid)
		end)
		local unitId = ok and type(unit) == "table" and unit.unit_id
		if unitId and count > 0 and wanted[unitId] then
			summon.got = unitId
			local info = unitData(unitId)
			if hub.settings.autoSummon and hub.settings.stopOnWanted then
				stopSummon("got " .. tostring(info and info.name or unitId))
			end
		end
	end
end

local function summonTick()
	local inLobby = workspace:FindFirstChild("_LOBBIES") ~= nil
	if inLobby and os.clock() >= summon.nextFetch then
		refreshFeatured()
	end
	if not hub.settings.autoSummon then
		summon.state = "Off"
		return 1
	end
	if not inLobby then
		summon.state = "Waiting for the lobby"
		return 2
	end
	if os.clock() < summon.pauseUntil then
		return 1
	end
	local bannerId = hub.settings.summonBanner
	local info = bannersData()[bannerId]
	if type(info) ~= "table" then
		summon.state = "Pick a banner"
		return 2
	end
	if os.clock() >= summon.nextFetch then
		refreshFeatured()
	end
	local wanted, count = wantedSet()
	if count > 0 then
		local inBanner = false
		for _, id in ipairs(featuredList(bannerId)) do
			if wanted[id] then
				inBanner = true
			end
		end
		if not inBanner then
			summon.state = "Waiting for a wanted unit to be in the banner"
			return 5
		end
	end
	if hub.settings.useLuckPotion and not luckActive() and itemCount("LuckPotion") > 0 then
		invoke("use_item", "LuckPotion")
		task.wait(1)
	end
	local mode = hub.settings.summonMode
	local tickets = itemCount("summon_ticket")
	local arg = "gems10"
	if mode == "Gems x1" then
		arg = "gems"
	elseif mode == "Tickets first, then gems" and tickets > 0 and not info._no_summon_ticket then
		arg = "ticket"
	elseif mode == "Tickets only" then
		if tickets <= 0 or info._no_summon_ticket then
			stopSummon("no summon tickets left")
			return 1
		end
		arg = "ticket"
	end
	if arg ~= "ticket" and tonumber(info.gem_cost) then
		local need = tonumber(info.gem_cost) * (arg == "gems10" and 10 or 1)
		if statValue("gem_amount") - need < (tonumber(hub.settings.keepGems) or 0) then
			stopSummon("keeping " .. tostring(hub.settings.keepGems) .. " gems")
			return 1
		end
	end
	local before = pityInfo(bannerId)
	local opensBefore = pityOpens(bannerId)
	local statsBefore = hatchedSnapshot()
	summon.busyUntil = os.clock() + 15
	summon.state = "Summoning (" .. arg .. ")"
	invoke("buy_from_banner", bannerId, arg)
	local waitUntil = os.clock() + 4
	while pityOpens(bannerId) <= opensBefore and os.clock() < waitUntil do
		task.wait(0.2)
	end
	local gained = pityOpens(bannerId) - opensBefore
	if gained > 0 then
		summon.failures = 0
		summon.pulls += gained
		task.wait(0.5)
		local gotWanted = nil
		for unitId, amount in pairs(hatchedSnapshot()) do
			if amount > (statsBefore[unitId] or 0) then
				local info = unitData(unitId)
				summon.lastGot = tostring(info and info.name or unitId)
				if wanted[unitId] then
					gotWanted = unitId
				end
			end
		end
		if gotWanted then
			summon.got = gotWanted
			if hub.settings.stopOnWanted then
				local info = unitData(gotWanted)
				stopSummon("got " .. tostring(info and info.name or gotWanted))
				return 1
			end
		end
		local after = pityInfo(bannerId)
		if hub.settings.stopOnPity and before and after and after < before then
			stopSummon("pity guarantee hit")
			return 1
		end
		return 1
	end
	summon.failures += 1
	task.wait(0.3)
	if summon.failures >= 3 then
		stopSummon("the game refused: " .. tostring(hub.lastMessage or "not enough currency"))
	end
	return 2
end

local autoPlay = {
	mapKey = nil,
	path = {},
	candidates = {},
	coverage = {},
	badSpots = {},
	blocked = {},
	fails = {},
	placeRest = {},
	consumed = {},
	nextSkill = setmetatable({}, { __mode = "k" }),
	upgradeFails = setmetatable({}, { __mode = "k" }),
	state = "Off",
	text = "",
	placed = 0,
	upgraded = 0,
	team = {},
}
hub.autoPlay = autoPlay

function autoPlay.noCap()
	if autoPlay.noCapFlag == nil then
		local ok, flag = pcall(function()
			local data = require(ReplicatedStorage.src.Loader).LevelData
			if type(data) ~= "table" then
				return nil
			end
			return data._randomequippedmode ~= nil
		end)
		if ok and flag ~= nil then
			autoPlay.noCapFlag = flag
		end
		return ok and flag == true
	end
	return autoPlay.noCapFlag
end

function autoPlay.gameCap(unitId, uuid)
	if autoPlay.noCap() then
		return math.huge
	end
	return placeLimit(unitId, uuid) or 6
end

autoPlay.modes = { "Story", "Legend", "Infinite", "Challenge", "Raid", "Portal", "Infinite Tower", "Event Contract", "Tournament", "Dungeon", "Summer Hunt" }

function autoPlay.modeOf(data)
	local id = tostring(data.id or "")
	local gamemode = tostring(data._gamemode or data._OVERRIDE_GAMEMODE or "")
	if id == eventTeam.level or (type(data._roguelike_mode) == "table" and type(data._MATCHMAKING) == "table") then
		return "Summer Hunt"
	elseif data._dungeon then
		return "Dungeon"
	elseif data._tournament then
		return "Tournament"
	elseif data._event_contract then
		return "Event Contract"
	elseif gamemode == "infinite_tower" then
		return "Infinite Tower"
	elseif data.portal_group or data._portal_only_level then
		return "Portal"
	elseif gamemode == "raid" or data.is_raid then
		return "Raid"
	elseif gamemode == "challenge" or data._challenge then
		return "Challenge"
	elseif gamemode == "infinite" or data.infinite then
		return "Infinite"
	elseif string.find(id, "legend", 1, true) then
		return "Legend"
	end
	return "Story"
end

function autoPlay.levelMode()
	if autoPlay.modeName == nil then
		local ok, mode = pcall(function()
			local data = require(ReplicatedStorage.src.Loader).LevelData
			if type(data) ~= "table" or not (data.id or data.map or data._dungeon) then
				return nil
			end
			return autoPlay.modeOf(data)
		end)
		if ok and mode then
			autoPlay.modeName = mode
		end
		return ok and mode or nil
	end
	return autoPlay.modeName
end

function autoPlay.activeMode()
	return autoPlay.levelMode() or "Story"
end

function autoPlay.profile(mode)
	hub.settings.autoPlaySlots = type(hub.settings.autoPlaySlots) == "table" and hub.settings.autoPlaySlots or {}
	hub.settings.autoPlayProfiles = type(hub.settings.autoPlayProfiles) == "table" and hub.settings.autoPlayProfiles or {}
	local profiles = hub.settings.autoPlayProfiles
	profiles.Normal = nil
	profiles.Story = hub.settings.autoPlaySlots
	if type(profiles[mode]) ~= "table" then
		profiles[mode] = {}
	end
	return profiles[mode]
end

function autoPlay.resetProfile(mode)
	if mode == "Story" or mode == nil then
		hub.settings.autoPlaySlots = {}
	end
	if mode == nil then
		hub.settings.autoPlayProfiles = {}
	elseif type(hub.settings.autoPlayProfiles) == "table" then
		hub.settings.autoPlayProfiles[mode] = nil
	end
	autoPlay.profile("Story")
	saveConfig()
end

local function slotConfig(slot, mode)
	local profile = autoPlay.profile(mode or autoPlay.activeMode())
	local key = tostring(slot)
	local config = profile[key]
	if type(config) ~= "table" then
		config = {}
		profile[key] = config
	end
	if config.place == nil then
		config.place = true
	end
	config.max = tonumber(config.max) or 6
	config.upgradeTo = tonumber(config.upgradeTo) or 15
	config.priority = tonumber(config.priority) or tonumber(slot) or 6
	if config.skill == nil then
		config.skill = hub.settings.autoPlaySkill == true
	end
	config.skillWave = tonumber(config.skillWave) or 1
	config.skillBossOnly = config.skillBossOnly == true
	config.placeWave = tonumber(config.placeWave) or 1
	return config
end

function autoPlay.wave()
	local value = workspace:FindFirstChild("_wave_num")
	return value and tonumber(value.Value) or 0
end

function autoPlay.waveLocked(config)
	return (tonumber(config.placeWave) or 1) > 1 and autoPlay.wave() < config.placeWave
end

local function laneWaypoints()
	local lanes = {}
	local bases = workspace:FindFirstChild("_BASES")
	local pve = bases and bases:FindFirstChild("pve")
	local laneFolder = pve and pve:FindFirstChild("LANES")
	if not laneFolder then
		return lanes
	end
	for _, lane in ipairs(laneFolder:GetChildren()) do
		local points = {}
		local spawnPart = lane:FindFirstChild("spawn")
		if spawnPart and spawnPart:IsA("BasePart") then
			table.insert(points, spawnPart.Position)
		end
		local numbered = {}
		for _, child in ipairs(lane:GetChildren()) do
			local index = tonumber(child.Name)
			if index and child:IsA("BasePart") then
				table.insert(numbered, { index = index, pos = child.Position })
			end
		end
		table.sort(numbered, function(a, b)
			return a.index < b.index
		end)
		for _, item in ipairs(numbered) do
			table.insert(points, item.pos)
		end
		local finalPart = lane:FindFirstChild("final")
		if finalPart and finalPart:IsA("BasePart") then
			table.insert(points, finalPart.Position)
		end
		if #points >= 2 then
			table.insert(lanes, points)
		end
	end
	return lanes
end

local function flat(a, b)
	return Vector3.new(a.X - b.X, 0, a.Z - b.Z).Magnitude
end

local function placementParams()
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	local list = {}
	for _, name in ipairs({ "_terrain", "_road" }) do
		local folder = workspace:FindFirstChild(name)
		if folder then
			table.insert(list, folder)
		end
	end
	params.FilterDescendantsInstances = list
	return params
end

local function surfaceAt(x, z, topY, params)
	local result = workspace:Raycast(Vector3.new(x, topY + 60, z), Vector3.new(0, -160, 0), params)
	if not result then
		return nil
	end
	local instance = result.Instance
	if instance.Name == "_donotplace" then
		return "blocked", result.Position
	end
	local road = workspace:FindFirstChild("_road")
	if road and instance:IsDescendantOf(road) then
		return "road", result.Position
	end
	local terrain = workspace:FindFirstChild("_terrain")
	local hill = terrain and terrain:FindFirstChild("hill")
	if hill and instance:IsDescendantOf(hill) then
		return "hill", result.Position
	end
	local ground = terrain and terrain:FindFirstChild("ground")
	if ground and instance:IsDescendantOf(ground) then
		return "ground", result.Position
	end
	return "blocked", result.Position
end

function autoPlay.loadBounds()
	autoPlay.bounds = {}
	pcall(function()
		local folder = ReplicatedStorage:FindFirstChild("_bounds") or (workspace:FindFirstChild("ignore") and workspace.ignore:FindFirstChild("_bounds"))
		for _, part in ipairs(folder and folder:GetDescendants() or {}) do
			if part:IsA("BasePart") then
				table.insert(autoPlay.bounds, { cframe = part.CFrame, half = part.Size / 2 })
			end
		end
	end)
	autoPlay.roadParams = OverlapParams.new()
	autoPlay.roadParams.FilterType = Enum.RaycastFilterType.Include
	autoPlay.roadParams.FilterDescendantsInstances = { workspace:FindFirstChild("_road") }
end

function autoPlay.blockedAt(point)
	for _, box in ipairs(autoPlay.bounds or {}) do
		local relative = box.cframe:PointToObjectSpace(point)
		if math.abs(relative.X) <= box.half.X + 1.3 and math.abs(relative.Z) <= box.half.Z + 1.3 and relative.Y >= -(box.half.Y + 2.9) and relative.Y <= box.half.Y - 0.5 then
			return true
		end
	end
	if autoPlay.roadParams and workspace:FindFirstChild("_road") then
		local ok, touching = pcall(function()
			return workspace:GetPartBoundsInRadius(point + Vector3.new(0, 1, 0), 1.4, autoPlay.roadParams)
		end)
		if ok and touching and #touching > 0 then
			return true
		end
	end
	return false
end

local function tryCandidate(x, z, baseY, params, seen)
	local gridKey = string.format("%d,%d", math.floor(x / 1.5), math.floor(z / 1.5))
	if seen[gridKey] then
		return
	end
	seen[gridKey] = true
	autoPlay.scanCount = (autoPlay.scanCount or 0) + 1
	if autoPlay.scanCount % 120 == 0 then
		task.wait()
	end
	local kind, hit = surfaceAt(x, z, baseY, params)
	if kind ~= "ground" and kind ~= "hill" then
		return
	end
	for _, offset in ipairs({ Vector3.new(1.6, 0, 0), Vector3.new(-1.6, 0, 0), Vector3.new(0, 0, 1.6), Vector3.new(0, 0, -1.6) }) do
		local around = surfaceAt(x + offset.X, z + offset.Z, baseY, params)
		if around == "road" or around == nil then
			return
		end
	end
	if autoPlay.blockedAt(hit) then
		return
	end
	table.insert(autoPlay.candidates, { pos = hit, kind = kind, key = gridKey })
end

autoPlay.presetAnchors = {
	dungeon_assassin_park = Vector3.new(248.792, 0.821, -2.671),
	dungeon_demonslayer = Vector3.new(-2884.818, 34.347, -153.614),
}

function autoPlay.savedAnchor()
	local anchors = hub.settings.autoPlayAnchors
	if type(anchors) ~= "table" then
		anchors = {}
	end
	if not autoPlay.mapKey then
		return nil
	end
	local anchor = anchors[autoPlay.mapKey]
	if type(anchor) ~= "table" and autoPlay.legacyKey and type(anchors[autoPlay.legacyKey]) == "table" then
		anchor = anchors[autoPlay.legacyKey]
		anchors[autoPlay.mapKey] = { x = anchor.x, y = anchor.y, z = anchor.z }
		autoPlay.migrated = true
	end
	if type(anchor) == "table" and tonumber(anchor.x) and tonumber(anchor.z) then
		return Vector3.new(tonumber(anchor.x), tonumber(anchor.y) or 0, tonumber(anchor.z))
	end
	local preset = autoPlay.presetAnchors[autoPlay.mapKey]
	if preset then
		return preset, true
	end
	return nil
end

local function mapAnchor(kind)
	if kind == "farm" and not hub.settings.useFarmArea then
		return nil
	end
	return autoPlay.savedAnchor() or autoPlay.defaultCenter
end

local function areaRadius(kind)
	local value = kind == "farm" and hub.settings.autoPlayFarmRadius or hub.settings.autoPlayRadius
	return math.floor(math.clamp(tonumber(value) or 12, 4, 30))
end

function autoPlay.laneKey()
	local key = ""
	for _, lane in ipairs(laneWaypoints()) do
		key = key .. string.format("%.0f_%.0f_", lane[1].X, lane[1].Z)
	end
	return key
end

local function currentMapKey()
	local lanes = autoPlay.laneKey()
	if lanes == "" then
		return ""
	end
	local ok, key = pcall(function()
		local data = require(ReplicatedStorage.src.Loader).LevelData
		if type(data) == "table" then
			if data._dungeon then
				return "dungeon_" .. tostring(data.map)
			end
			if data.id then
				return "level_" .. tostring(data.id)
			end
			if data.map then
				return "map_" .. tostring(data.map)
			end
		end
		return nil
	end)
	return (ok and key) or lanes
end

local function buildCandidates(force)
	local key = currentMapKey()
	if not force and key == autoPlay.mapKey and #autoPlay.candidates > 0 then
		return
	end
	autoPlay.mapKey = key
	autoPlay.legacyKey = autoPlay.laneKey()
	autoPlay.defaultCenter = nil
	autoPlay.path = {}
	autoPlay.candidates = {}
	autoPlay.coverage = {}
	if key ~= autoPlay.builtKey then
		autoPlay.builtKey = key
		autoPlay.badSpots = {}
		autoPlay.blocked = {}
		autoPlay.fails = {}
		autoPlay.placeRest = {}
		autoPlay.consumed = {}
	end
	local lanes = laneWaypoints()
	if #lanes == 0 then
		return
	end
	local params = placementParams()
	autoPlay.loadBounds()
	for laneIndex, lane in ipairs(lanes) do
		local total = 0
		for i = 1, #lane - 1 do
			total += flat(lane[i], lane[i + 1])
		end
		local walked = 0
		for i = 1, #lane - 1 do
			local a, b = lane[i], lane[i + 1]
			local length = flat(a, b)
			local steps = math.max(1, math.floor(length / 1.5))
			for s = 0, steps - 1 do
				local alpha = s / steps
				table.insert(autoPlay.path, { pos = a:Lerp(b, alpha), progress = (walked + length * alpha) / math.max(total, 1), lane = laneIndex })
			end
			walked += length
		end
	end
	local middle, middleGap = nil, nil
	for _, sample in ipairs(autoPlay.path) do
		local gap = math.abs(sample.progress - 0.5)
		if not middleGap or gap < middleGap then
			middle, middleGap = sample.pos, gap
		end
	end
	autoPlay.defaultCenter = middle
	local seen = {}
	for index, sample in ipairs(autoPlay.path) do
		if index % 2 == 1 then
			local nextSample = autoPlay.path[math.min(index + 1, #autoPlay.path)]
			local direction = Vector3.new(nextSample.pos.X - sample.pos.X, 0, nextSample.pos.Z - sample.pos.Z)
			if direction.Magnitude < 0.01 then
				direction = Vector3.new(1, 0, 0)
			end
			direction = direction.Unit
			local side = Vector3.new(-direction.Z, 0, direction.X)
			for _, distance in ipairs({ 3.5, 5, 7, 9.5, 12 }) do
				for _, sign in ipairs({ 1, -1 }) do
					local point = sample.pos + side * distance * sign
					tryCandidate(point.X, point.Z, sample.pos.Y, params, seen)
				end
			end
		end
	end
	local terrain = workspace:FindFirstChild("_terrain")
	local hillFolder = terrain and terrain:FindFirstChild("hill")
	for _, part in ipairs(hillFolder and hillFolder:GetDescendants() or {}) do
		if part:IsA("BasePart") then
			local size = part.Size
			local step = math.max(1.75, math.sqrt(size.X * size.Z / 90))
			for lx = -size.X / 2 + 1, size.X / 2 - 1, step do
				for lz = -size.Z / 2 + 1, size.Z / 2 - 1, step do
					local point = part.CFrame * Vector3.new(lx, size.Y / 2, lz)
					tryCandidate(point.X, point.Z, point.Y, params, seen)
				end
			end
		end
	end
	local anchor = mapAnchor("unit")
	if autoPlay.migrated then
		autoPlay.migrated = nil
		saveConfig()
	end
	if anchor then
		local reach = math.max(areaRadius("unit"), mapAnchor("farm") and areaRadius("farm") or 0) + 2
		for dx = -reach, reach, 2 do
			for dz = -reach, reach, 2 do
				if dx * dx + dz * dz <= reach * reach then
					tryCandidate(anchor.X + dx, anchor.Z + dz, anchor.Y, params, seen)
				end
			end
		end
	end
end

local function coverageFor(range)
	range = math.max(4, tonumber(range) or 10)
	local cacheKey = tostring(math.floor(range))
	if autoPlay.coverage[cacheKey] then
		return autoPlay.coverage[cacheKey]
	end
	local scores = {}
	for index, candidate in ipairs(autoPlay.candidates) do
		if index % 60 == 0 then
			task.wait()
		end
		local score = 0
		for _, sample in ipairs(autoPlay.path) do
			if flat(candidate.pos, sample.pos) <= range then
				score += 0.5 + sample.progress
			end
		end
		scores[index] = score
	end
	autoPlay.coverage[cacheKey] = scores
	return scores
end

local function teamUnits()
	local team = {}
	local gui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
	local frame = gui and gui:FindFirstChild("spawn_units")
	frame = frame and frame:FindFirstChild("Lives")
	frame = frame and frame:FindFirstChild("Frame")
	frame = frame and frame:FindFirstChild("Units")
	local session = gameSession()
	if frame then
		for _, slotFrame in ipairs(frame:GetChildren()) do
			local uuid = slotFrame:GetAttribute("_equipped_frame_unit_uuid")
			local slot = tonumber(slotFrame.Name)
			if type(uuid) == "string" and slot then
				local unitId = nil
				if session then
					local ok, unit = pcall(function()
						return session.collection:get_unit_by_uuid(uuid)
					end)
					if ok and type(unit) == "table" then
						unitId = unit.unit_id
					end
				end
				if not unitId then
					local main = slotFrame:FindFirstChild("Main")
					local view = main and main:FindFirstChild("View")
					local world = view and view:FindFirstChild("WorldModel")
					local model = world and world:FindFirstChildOfClass("Model")
					unitId = model and baseUnitId(model.Name)
				end
				if unitId then
					table.insert(team, { slot = slot, uuid = uuid, unitId = unitId })
				end
			end
		end
	end
	table.sort(team, function(a, b)
		return a.slot < b.slot
	end)
	autoPlay.team = team
	return team
end

local function isFarm(unitId)
	local info = unitData(unitId)
	return info ~= nil and (tonumber(info.farm_amount) or 0) > 0
end

local function unitName(unitId)
	local info = unitData(unitId)
	return tostring(info and info.name or unitId)
end

autoPlay.hitboxes = setmetatable({}, { __mode = "k" })

function autoPlay.hitboxOf(model)
	local cached = autoPlay.hitboxes[model]
	if cached then
		return cached
	end
	local radius = 1.87
	local box = model:FindFirstChild("_hitbox")
	if box and box:IsA("BasePart") then
		radius = math.max(box.Size.Y, box.Size.Z) / 2
	end
	autoPlay.hitboxes[model] = radius
	return radius
end

function autoPlay.occupancy()
	local list = {}
	for _, model in ipairs((workspace:FindFirstChild("_UNITS") or workspace):GetChildren()) do
		local stats = model:FindFirstChild("_stats")
		local owner = stats and stats:FindFirstChild("player")
		if owner and owner.Value then
			local ok, pivot = pcall(function()
				return model:GetPivot().Position
			end)
			if ok then
				table.insert(list, { pos = pivot, radius = autoPlay.hitboxOf(model) })
			end
		end
	end
	return list
end

local function spotIsFree(candidate, radius, occupied)
	if autoPlay.badSpots[candidate.key] then
		return false
	end
	for _, item in ipairs(occupied or autoPlay.occupancy()) do
		if flat(item.pos, candidate.pos) < math.max(radius, item.radius) + 0.4 then
			return false
		end
	end
	return true
end

function autoPlay.pathDist(candidate)
	if not candidate.pathDist then
		local nearest = math.huge
		for _, sample in ipairs(autoPlay.path) do
			nearest = math.min(nearest, flat(sample.pos, candidate.pos))
		end
		candidate.pathDist = nearest
	end
	return candidate.pathDist
end

function autoPlay.pathPercent(kind)
	local key = kind == "buff" and "pathBuff" or kind == "hill" and "pathHill" or "pathGround"
	return math.clamp(math.floor(tonumber(hub.settings[key]) or 50), 0, 100)
end

function autoPlay.pathTargets(percent)
	local want = 1 - math.clamp(percent, 0, 100) / 100
	local best = {}
	for _, sample in ipairs(autoPlay.path or {}) do
		local lane = sample.lane or 1
		local gap = math.abs(sample.progress - want)
		if not best[lane] or gap < best[lane].gap then
			best[lane] = { pos = sample.pos, gap = gap }
		end
	end
	local list = {}
	for _, item in pairs(best) do
		table.insert(list, item.pos)
	end
	return list
end

function autoPlay.pathKind(unitId, isBuff)
	if isBuff then
		return "buff"
	end
	local info = unitData(unitId) or {}
	return info.hill_unit == true and "hill" or "ground"
end

local function bestSpot(unitId, cluster, isBuff)
	local info = unitData(unitId) or {}
	local wantHill = info.hill_unit == true
	local allowBoth = info.hybrid_placement == true
	local radius = tonumber(info.override_hitbox_radius) or 1.87
	local farm = isFarm(unitId)
	local area = (farm and mapAnchor("farm")) and "farm" or "unit"
	local anchor = mapAnchor(area)
	local targets = nil
	if hub.settings.pathPlace and not farm then
		targets = autoPlay.pathTargets(autoPlay.pathPercent(autoPlay.pathKind(unitId, isBuff)))
		if #targets == 0 then
			targets = nil
		end
	end
	local inner, outer = 0, areaRadius(area)
	if mapAnchor("farm") then
		local other = areaRadius(area == "farm" and "unit" or "farm")
		if outer > other then
			inner = other + 1
		end
	end
	local scores = (not anchor and not targets) and coverageFor(info.range) or nil
	local occupied = autoPlay.occupancy()
	local bestIndex, bestScore = nil, nil
	for index, candidate in ipairs(autoPlay.candidates) do
		local kindOk = allowBoth or (wantHill and candidate.kind == "hill") or (not wantHill and candidate.kind == "ground")
		if kindOk and spotIsFree(candidate, radius, occupied) then
			local score
			if targets then
				local nearest = math.huge
				for _, point in ipairs(targets) do
					nearest = math.min(nearest, flat(candidate.pos, point))
				end
				score = -nearest
			elseif anchor then
				local distance = flat(candidate.pos, anchor)
				if area == "farm" then
					score = autoPlay.pathDist(candidate) - distance * 0.05
				else
					score = -math.abs(distance - inner)
				end
				if distance < inner then
					score -= 100000 + (inner - distance) * 10
				elseif distance > outer then
					score -= 100000 + (distance - outer) * 10
				end
			else
				score = scores[index] or 0
				if farm then
					score = -score
				else
					score -= autoPlay.pathDist(candidate) * 0.01
				end
			end
			if allowBoth and candidate.kind == "hill" then
				score -= 50000
			end
			if cluster and #cluster > 0 then
				local total = 0
				local nearest = math.huge
				for _, pos in ipairs(cluster) do
					local gap = flat(candidate.pos, pos)
					total += gap
					nearest = math.min(nearest, gap)
				end
				score -= (total / #cluster) * 0.8
				if cluster.reach and nearest > cluster.reach then
					score -= 1000 + nearest
				end
			end
			if not bestScore or score > bestScore then
				bestIndex, bestScore = index, score
			end
		end
	end
	return bestIndex and autoPlay.candidates[bestIndex] or nil
end

local function placedByUuid(uuid)
	local list = {}
	for _, model in ipairs(unitModels()) do
		if modelUuid(model) == uuid then
			table.insert(list, model)
		end
	end
	return list
end

local function modelLevel(model)
	local stats = model:FindFirstChild("_stats")
	local level = stats and stats:FindFirstChild("upgrade")
	return level and tonumber(level.Value) or 0
end

local buffLoop = { info = {}, groups = {}, pending = setmetatable({}, { __mode = "k" }), failStreak = setmetatable({}, { __mode = "k" }), since = setmetatable({}, { __mode = "k" }), modes = { "Max buff 100% (4 per type)", "Keep buff up only" } }
buffLoop.scripted = {
	["leafa:buff"] = { flag = "damage_buff__magic", time = 30, range = 25, liveRange = true, name = "Verdant Enchantment", types = { magic = true }, rate = 0.5 },
}
buffLoop.scriptedUnits = { leafa_evolved = "leafa:buff" }
buffLoop.typeNames = { damage_buff__magic = "Magic buff", damage_buff__physical = "Physical buff" }

function buffLoop.skillInfo(attack)
	if type(attack) ~= "string" or attack == "" then
		return nil
	end
	if buffLoop.scripted[attack] then
		return buffLoop.scripted[attack]
	end
	if buffLoop.info[attack] == nil then
		local result = false
		pcall(function()
			local data = require(ReplicatedStorage.src.Data.Attacks)[attack]
			if type(data) ~= "table" or type(data.aoe) ~= "table" then
				return
			end
			local range = 0
			if type(data.range) == "table" then
				for _, value in pairs(data.range) do
					range = math.max(range, tonumber(value) or 0)
				end
			end
			for _, aoe in pairs(data.aoe) do
				if type(aoe) == "table" and aoe.hit_allies and type(aoe.hit) == "table" and type(aoe.hit.buffs) == "table" then
					for _, buff in pairs(aoe.hit.buffs) do
						if type(buff) == "table" and type(buff.name) == "string" and string.find(buff.name, "damage_buff", 1, true) then
							local types, rate = nil, nil
							local params = type(buff.params) == "table" and buff.params
							if params and type(params.damage_types) == "table" then
								types = {}
								for damageType, detail in pairs(params.damage_types) do
									types[damageType] = true
									rate = math.max(rate or 0, type(detail) == "table" and tonumber(detail.rate) or 0)
								end
							end
							result = { flag = buff.name, time = tonumber(buff.time) or 30, range = range > 0 and range or 20, name = tostring(data.name or attack), types = types, rate = rate and rate > 0 and rate or nil }
						end
					end
				end
			end
		end)
		buffLoop.info[attack] = result
	end
	return buffLoop.info[attack] or nil
end

function buffLoop.isBuffUnit(unitId)
	if buffLoop.baseId then
		unitId = buffLoop.baseId(unitId)
	end
	local info = unitData(unitId)
	return info ~= nil and buffLoop.skillInfo(buffLoop.scriptedUnits[unitId] or info.active_attack) ~= nil
end

autoPlay.smart = {}

function autoPlay.smart.dataDps(unitId, level)
	local info = unitData(unitId)
	if not info then
		return 0
	end
	local damage = tonumber(info.damage) or 0
	local cooldown = tonumber(info.attack_cooldown) or 0
	if type(info.upgrade) == "table" then
		for index = 1, math.min(level, #info.upgrade) do
			local step = info.upgrade[index]
			if type(step) == "table" then
				damage = tonumber(step.damage) or damage
				cooldown = tonumber(step.attack_cooldown) or cooldown
			end
		end
	end
	if cooldown <= 0 then
		return 0
	end
	return damage / math.max(cooldown, 1)
end

function autoPlay.smart.farmAt(unitId, level)
	local info = unitData(unitId)
	if not info then
		return 0
	end
	local amount = tonumber(info.farm_amount) or 0
	if type(info.upgrade) == "table" then
		for index = 1, math.min(level, #info.upgrade) do
			local step = info.upgrade[index]
			if type(step) == "table" then
				amount = tonumber(step.farm_amount) or amount
			end
		end
	end
	return amount
end

function autoPlay.smart.dps(model)
	local stats = model:FindFirstChild("_stats")
	local damage = stats and stats:FindFirstChild("damage")
	local cooldown = stats and stats:FindFirstChild("attack_cooldown")
	local seconds = cooldown and tonumber(cooldown.Value) or 0
	if seconds <= 0 then
		seconds = tonumber((unitData(modelUnitId(model)) or {}).attack_cooldown) or 0
	end
	if seconds <= 0 then
		return 0
	end
	return (damage and tonumber(damage.Value) or 0) / math.max(seconds, 1)
end

autoPlay.farmPlan = {}
autoPlay.waveSold = setmetatable({}, { __mode = "k" })

function autoPlay.waveReached(key)
	local wave = tonumber(hub.settings[key]) or 0
	if wave <= 0 or autoPlay.wave() < wave then
		return false
	end
	local modes = type(hub.settings.waveRuleModes) == "table" and hub.settings.waveRuleModes or {}
	return #modes == 0 or table.find(modes, autoPlay.activeMode()) ~= nil
end

function autoPlay.farmPlan.lastWave()
	local last = workspace:FindFirstChild("_is_last_wave")
	return last ~= nil and last.Value == true
end

function autoPlay.farmPlan.mult(entry, model)
	if model then
		local stats = model:FindFirstChild("_stats")
		local live = stats and stats:FindFirstChild("farm_amount")
		local base = autoPlay.smart.farmAt(entry.unitId, modelLevel(model))
		local value = live and tonumber(live.Value)
		if value and value > 0 and base > 0 then
			return value / base
		end
	end
	local unit = hub.slotWorth and hub.slotWorth.unit(entry.uuid)
	for _, trait in pairs(unit and type(unit.traits) == "table" and unit.traits or {}) do
		if (type(trait) == "table" and trait.trait or trait) == "golden" then
			return 1.2
		end
	end
	return 1
end

function autoPlay.farmPlan.payback(entry, level, firstCost, mult, limit)
	local info = unitData(entry.unitId)
	if type(info) ~= "table" then
		return math.huge
	end
	local steps = type(info.upgrade) == "table" and info.upgrade or {}
	local function stepCost(from)
		if from < 0 then
			return tonumber(info.cost)
		end
		local step = steps[from + 1]
		return type(step) == "table" and tonumber(step.cost) or nil
	end
	local function value(at)
		return at < 0 and 0 or autoPlay.smart.farmAt(entry.unitId, at)
	end
	local first = stepCost(level)
	local scale = (first and first > 0 and firstCost and firstCost > 0) and firstCost / first or 1
	local best, sumCost, sumGain = math.huge, 0, 0
	for from = level, math.min(level + 3, (limit or #steps) - 1) do
		local cost = stepCost(from)
		if not cost then
			break
		end
		sumCost += cost * scale
		sumGain += (value(from + 1) - value(from)) * mult
		if sumGain > 0 then
			best = math.min(best, sumCost / sumGain)
		end
	end
	return best
end

local function nextAction()
	local entries = {}
	for _, entry in ipairs(teamUnits()) do
		local config = slotConfig(entry.slot)
		do
			entry.config = config
			entry.models = placedByUuid(entry.uuid)
			entry.cap = math.min(autoPlay.gameCap(entry.unitId, entry.uuid), config.place and config.max or 0)
			if buffLoop.isBuffUnit(entry.unitId) then
				entry.cap = math.min(entry.cap, math.floor(tonumber(hub.settings.buffUnitCap) or 4))
			end
			if autoPlay.waveLocked(config) or autoPlay.blocked[entry.uuid] or autoPlay.consumed[entry.uuid] then
				entry.cap = math.min(entry.cap, #entry.models)
			end
			entry.cost = costRules.spawn((unitData(entry.unitId) or {}).cost)
			entry.farm = isFarm(entry.unitId)
			table.insert(entries, entry)
		end
	end
	local covered = {}
	for _, entry in ipairs(entries) do
		covered[entry.uuid] = true
	end
	local orphans = {}
	for _, model in ipairs(unitModels()) do
		local uuid = modelUuid(model)
		if uuid and not covered[uuid] then
			if not orphans[uuid] then
				local unitId = modelUnitId(model)
				orphans[uuid] = { slot = 100 + #entries, uuid = uuid, unitId = unitId, models = {}, cap = 0, cost = 0, farm = isFarm(unitId), config = { priority = 99, upgradeTo = 99, place = false, max = 0 } }
				table.insert(entries, orphans[uuid])
			end
			table.insert(orphans[uuid].models, model)
		end
	end
	table.sort(entries, function(a, b)
		if a.config.priority ~= b.config.priority then
			return a.config.priority < b.config.priority
		end
		return a.slot < b.slot
	end)

	if not autoPlay.fullCount and autoPlay.noCap() then
		autoPlay.fullCount = 20
	end
	local roomy = true
	if autoPlay.fullCount then
		local total = #unitModels()
		if total >= autoPlay.fullCount then
			autoPlay.belowSince = nil
			roomy = false
		else
			autoPlay.belowSince = autoPlay.belowSince or os.clock()
			roomy = os.clock() - autoPlay.belowSince >= 3
		end
	end
	local sellAll = autoPlay.waveReached("sellAllWave")
	if sellAll or autoPlay.waveReached("sellFarmWave") then
		for _, entry in ipairs(entries) do
			if sellAll or entry.farm then
				entry.cap = 0
				for _, model in ipairs(entry.models) do
					if (autoPlay.waveSold[model] or 0) < 3 then
						return { kind = "sell", entry = entry, model = model, cost = 0, waveSell = sellAll and "all" or "farm" }
					end
				end
			end
		end
		if sellAll then
			return { kind = "idle", text = "Sold every unit at wave " .. tostring(hub.settings.sellAllWave) .. ", not placing again" }
		end
	end
	local lastWave = autoPlay.farmPlan.lastWave()
	for _, entry in ipairs(entries) do
		if #entry.models < entry.cap and roomy and not (lastWave and entry.farm) and os.clock() >= (autoPlay.placeRest[entry.uuid] or 0) then
			return { kind = "place", entry = entry, cost = entry.cost }
		end
	end
	if autoPlay.waveReached("upgradeAllWave") then
		local money = myResource()
		local cheapest = nil
		for _, entry in ipairs(entries) do
			if not (lastWave and entry.farm) then
				for _, model in ipairs(entry.models) do
					local cost = (autoPlay.upgradeFails[model] or 0) < 3 and upgradeCost(model, entry.unitId) or nil
					if type(cost) == "number" then
						local action = { kind = "upgrade", entry = entry, model = model, cost = cost, level = modelLevel(model), all = true }
						if cost <= money then
							return action
						end
						if not cheapest or cost < cheapest.cost then
							cheapest = action
						end
					end
				end
			end
		end
		if cheapest then
			return cheapest
		end
	end
	if not hub.settings.autoPlayUpgrade then
		return nil
	end

	local sequential = hub.settings.sequentialUpgrade ~= false
	local money = myResource()
	local passes = hub.settings.leftoverUpgrade and 2 or 1
	autoPlay.costMissing = nil
	for pass = 1, passes do
		local extra = pass == 2
		local waiting = nil
		local index = 1
		while index <= #entries do
			local priority = entries[index].config.priority
			local options = {}
			while index <= #entries and entries[index].config.priority == priority do
				local entry = entries[index]
				for _, model in ipairs(entry.models) do
					local level = modelLevel(model)
					if (extra or level < entry.config.upgradeTo) and (autoPlay.upgradeFails[model] or 0) < 3 then
						local cost = upgradeCost(model, entry.unitId)
						if cost == nil and not extra then
							autoPlay.costMissing = entry.unitId
						end
						if type(cost) == "number" and not (lastWave and entry.farm) then
							local payback = nil
							if entry.farm then
								payback = autoPlay.farmPlan.payback(entry, level, cost, autoPlay.farmPlan.mult(entry, model), not extra and entry.config.upgradeTo or nil)
							end
							table.insert(options, { kind = "upgrade", entry = entry, model = model, cost = cost, level = level, extra = extra, payback = payback })
						end
					end
				end
				index += 1
			end
			table.sort(options, function(a, b)
				if a.level ~= b.level then
					return a.level < b.level
				end
				if a.cost ~= b.cost then
					return a.cost < b.cost
				end
				return a.entry.slot < b.entry.slot
			end)
			local farmSpots, farmOptions = {}, {}
			for spot, action in ipairs(options) do
				if action.payback then
					table.insert(farmSpots, spot)
					table.insert(farmOptions, action)
				end
			end
			if #farmOptions > 1 then
				table.sort(farmOptions, function(a, b)
					if a.payback ~= b.payback then
						return a.payback < b.payback
					end
					return a.cost < b.cost
				end)
				for order, spot in ipairs(farmSpots) do
					options[spot] = farmOptions[order]
				end
			end
			if options[1] then
				for _, action in ipairs(options) do
					if action.cost <= money then
						return action
					end
				end
				if sequential then
					return options[1]
				end
				waiting = waiting or options[1]
			end
		end
		if waiting then
			return waiting
		end
	end
	return nil
end

function buffLoop.baseId(id)
	if type(id) ~= "string" or id == "" or unitData(id) then
		return id
	end
	if buffLoop.skinOwners == nil then
		buffLoop.skinOwners = {}
		pcall(function()
			for skinId, skin in pairs(require(ReplicatedStorage.src.Data.Skins)) do
				if type(skin) == "table" and type(skin.for_unit) == "string" then
					buffLoop.skinOwners[skinId] = skin.for_unit
				end
			end
		end)
	end
	local owner = buffLoop.skinOwners[id]
	if owner and unitData(owner) then
		return owner
	end
	local head = string.match(id, "^[^:]+")
	if head and unitData(head) then
		return head
	end
	return id
end

function buffLoop.unitOf(model)
	return buffLoop.baseId(modelUnitId(model))
end

function buffLoop.attackOf(model)
	local stats = model:FindFirstChild("_stats")
	local value = stats and stats:FindFirstChild("active_attack")
	local attack = value and value.Value
	if buffLoop.skillInfo(attack) ~= nil then
		return attack
	end
	local unitId = buffLoop.unitOf(model) or ""
	if buffLoop.scriptedUnits[unitId] then
		return buffLoop.scriptedUnits[unitId]
	end
	if type(attack) ~= "string" or attack == "" then
		local info = unitData(unitId)
		if info and buffLoop.skillInfo(info.active_attack) ~= nil then
			return info.active_attack
		end
	end
	return attack
end

function buffLoop.rangeOf(model, info)
	if info.liveRange then
		local stats = model:FindFirstChild("_stats")
		local live = stats and stats:FindFirstChild("range")
		local value = live and tonumber(live.Value)
		if value and value > 0 then
			return value
		end
	end
	return info.range
end

function buffLoop.cooldown(model)
	local stats = model:FindFirstChild("_stats")
	local live = stats and stats:FindFirstChild("active_attack_cooldown")
	if live and tonumber(live.Value) and tonumber(live.Value) > 0 then
		return tonumber(live.Value)
	end
	local info = unitData(buffLoop.unitOf(model)) or {}
	local cooldown = type(info.active_attack_stats) == "table" and tonumber(info.active_attack_stats.attack_cooldown)
	if not cooldown and type(info.upgrade) == "table" then
		local level = modelLevel(model)
		for index, step in ipairs(info.upgrade) do
			if index <= level and type(step) == "table" and type(step.active_attack_stats) == "table" then
				cooldown = tonumber(step.active_attack_stats.attack_cooldown) or cooldown
			end
		end
	end
	return cooldown or 60
end

function buffLoop.ready(model)
	if (buffLoop.pending[model] or 0) > os.clock() then
		return false
	end
	local stats = model:FindFirstChild("_stats")
	local last = stats and stats:FindFirstChild("last_active_cast")
	local lastCast = last and tonumber(last.Value) or -math.huge
	return tick() - lastCast >= buffLoop.cooldown(model) + 0.15, lastCast
end

function buffLoop.value(model, info)
	local stats = model:FindFirstChild("_stats")
	if not stats then
		return 0
	end
	local best = 0
	for damageType in pairs(info.types or { physical = true }) do
		best = math.max(best, tonumber(stats:GetAttribute("_dmg_buff_" .. damageType)) or 0)
	end
	if best <= 0 then
		local folder = model:FindFirstChild("buffs") or model:FindFirstChild("_buffs")
		local flag = folder and info.flag and folder:FindFirstChild(info.flag)
		if flag and flag:IsA("ValueBase") and (tonumber(flag.Value) or (flag.Value == true and 1) or 0) > 0 then
			best = info.rate or 0.25
		end
	end
	return best
end

function buffLoop.cooldownLeft(model)
	local stats = model:FindFirstChild("_stats")
	local last = stats and stats:FindFirstChild("last_active_cast")
	local lastCast = last and tonumber(last.Value) or -math.huge
	return buffLoop.cooldown(model) - (tick() - lastCast)
end

function buffLoop.isTarget(model, info)
	local stats = model:FindFirstChild("_stats")
	local base = stats and stats:FindFirstChild("base_damage")
	if not base or (tonumber(base.Value) or 0) <= 0 then
		return false
	end
	if info.types then
		local data = unitData(buffLoop.unitOf(model)) or {}
		if info.types[tostring(data._base_damage_type or "physical")] then
			return true
		end
		for damageType, on in pairs(type(data._secondary_damage_types) == "table" and data._secondary_damage_types or {}) do
			if on and info.types[tostring(damageType)] then
				return true
			end
		end
		return false
	end
	return true
end

function buffLoop.pick(group, targets, needBuffed, exclude)
	local best, bestScore = nil, nil
	for _, caster in ipairs(group.casters) do
		if not exclude[caster] then
			local ready, lastCast = buffLoop.ready(caster)
			local strength = buffLoop.value(caster, group.info)
			if ready and (strength > 0 or not needBuffed) then
				local covered = 0
				local pos = caster:GetPivot().Position
				local reach = group.ranges and group.ranges[caster] or group.info.range
				for _, target in ipairs(targets) do
					if flat(target:GetPivot().Position, pos) <= reach then
						covered += 1
					end
				end
				local score = strength * 1000 + covered * 10 + math.min(tick() - lastCast, 600) * 0.001
				if (#targets == 0 or covered > 0) and (not bestScore or score > bestScore) then
					best, bestScore = caster, score
				end
			end
		end
	end
	return best
end

function buffLoop.cast(model, state, onFail)
	buffLoop.pending[model] = os.clock() + 3
	state.casts = (state.casts or 0) + 1
	task.spawn(function()
		local stats = model:FindFirstChild("_stats")
		local last = stats and stats:FindFirstChild("last_active_cast")
		local before = last and last.Value
		invoke("use_active_attack", model)
		local untilTime = os.clock() + 1.5
		while last and last.Value == before and os.clock() < untilTime do
			task.wait(0.05)
		end
		if last and last.Value == before then
			local streak = (buffLoop.failStreak[model] or 0) + 1
			buffLoop.failStreak[model] = streak
			buffLoop.pending[model] = os.clock() + math.min(0.25 * 2 ^ (streak - 1), 4)
			state.casts -= 1
			state.fails = (state.fails or 0) + 1
			if onFail then
				onFail()
			end
		else
			buffLoop.failStreak[model] = nil
		end
	end)
end

function buffLoop.duration(models, info)
	local best = 0
	for _, model in ipairs(models) do
		local stats = model:FindFirstChild("_stats")
		if stats then
			for damageType in pairs(info.types or { physical = true }) do
				best = math.max(best, tonumber(stats:GetAttribute("_dmg_buff_duration_" .. damageType)) or 0)
			end
		end
	end
	if best > 0 then
		info.liveTime = best
	end
	return info.liveTime or info.time
end

function buffLoop.plan(casters, duration, maxMode)
	local cooldown = 0
	for _, caster in ipairs(casters) do
		cooldown = math.max(cooldown, buffLoop.cooldown(caster))
	end
	local gap = math.max(cooldown / math.max(#casters, 1) + 0.2, duration / 2 + 0.5)
	if not maxMode or #casters < 2 or gap > duration - 1 then
		return nil, cooldown
	end
	return gap, cooldown
end

local skillRules = { ranges = {} }

function skillRules.wave()
	local value = workspace:FindFirstChild("_wave_num")
	return value and tonumber(value.Value) or 0
end

function skillRules.slotOf(model)
	local uuid = modelUuid(model)
	for _, entry in ipairs(autoPlay.team or {}) do
		if entry.uuid == uuid then
			return entry.slot
		end
	end
	return nil
end

function skillRules.reach(attack)
	if type(attack) ~= "string" then
		return nil
	end
	if skillRules.ranges[attack] == nil then
		local reach = false
		pcall(function()
			local data = require(ReplicatedStorage.src.Data.Attacks)[attack]
			if type(data) == "table" and not data.dont_need_target and type(data.range) == "table" then
				local far = tonumber(data.range[2]) or 0
				if far > 0 and far < 500 then
					reach = far
				end
			end
		end)
		skillRules.ranges[attack] = reach
	end
	return skillRules.ranges[attack] or nil
end

function skillRules.bossNear(model, attack)
	local folder = workspace:FindFirstChild("_UNITS")
	if not folder then
		return false
	end
	local reach = skillRules.reach(attack)
	local ok, origin = pcall(function()
		return model:GetPivot().Position
	end)
	if not ok then
		return false
	end
	for _, enemy in ipairs(folder:GetChildren()) do
		local stats = enemy:FindFirstChild("_stats")
		local owner = stats and stats:FindFirstChild("player")
		local id = stats and stats:FindFirstChild("id")
		if id and not (owner and owner.Value) then
			local info = unitData(id.Value)
			if info and info.boss then
				if not reach then
					return true
				end
				local found, pivot = pcall(function()
					return enemy:GetPivot().Position
				end)
				if found and flat(pivot, origin) <= reach then
					return true
				end
			end
		end
	end
	return false
end

function skillRules.allowed(model, attack, ignoreBoss)
	local slot = skillRules.slotOf(model)
	if not slot then
		return true
	end
	local config = slotConfig(slot)
	if not config.skill or skillRules.wave() < config.skillWave then
		return false
	end
	if config.skillBossOnly and not ignoreBoss and not skillRules.bossNear(model, attack) then
		return false
	end
	return true
end

function buffLoop.expected()
	if buffLoop.capsAt and os.clock() - buffLoop.capsAt < 2 then
		return buffLoop.caps
	end
	local caps = {}
	local limit = math.floor(tonumber(hub.settings.buffUnitCap) or 4)
	if hub.settings.autoPlay then
		local full = autoPlay.fullCount and #unitModels() >= autoPlay.fullCount
		for _, entry in ipairs(teamUnits()) do
			if buffLoop.isBuffUnit(entry.unitId) then
				local config = slotConfig(entry.slot)
				local cap = math.min(autoPlay.gameCap(entry.unitId, entry.uuid), config.place and config.max or 0, limit)
				if full or autoPlay.waveLocked(config) or autoPlay.blocked[entry.uuid] or autoPlay.consumed[entry.uuid] then
					cap = math.min(cap, #placedByUuid(entry.uuid))
				end
				local id = buffLoop.baseId(entry.unitId)
				caps[id] = (caps[id] or 0) + cap
			end
		end
	end
	buffLoop.caps, buffLoop.capsAt = caps, os.clock()
	return caps
end

function buffLoop.stopForeign()
	if os.clock() < (buffLoop.nextForeign or 0) then
		return
	end
	buffLoop.nextForeign = os.clock() + 5
	pcall(function()
		for _, key in ipairs({ "AABuffV2", "AABuffV3" }) do
			local other = genv[key]
			if type(other) == "table" and other.active ~= false and type(other.StopAll) == "function" then
				pcall(other.StopAll)
				buffLoop.foreignStopped = key
			end
		end
		if genv.AutoBuff == true then
			genv.AutoBuff = false
			buffLoop.foreignStopped = "AutoBuff"
		end
	end)
end

function buffLoop.step()
	buffLoop.stopForeign()
	local models = unitModels()
	local groups = {}
	for _, model in ipairs(models) do
		local attack = buffLoop.attackOf(model)
		local info = buffLoop.skillInfo(attack)
		if info then
			local key = info.flag or attack
			local group = groups[key]
			if not group then
				group = { info = info, casters = {}, set = {}, ranges = {}, names = {} }
				groups[key] = group
			end
			table.insert(group.casters, model)
			group.set[model] = true
			group.ranges[model] = buffLoop.rangeOf(model, info)
			if not table.find(group.names, info.name) then
				table.insert(group.names, info.name)
			end
		end
	end
	local caps = buffLoop.expected()
	local maxMode = hub.settings.buffLoopMode == buffLoop.modes[1]
	for attack, group in pairs(groups) do
		local need, seenIds = 0, {}
		for _, caster in ipairs(group.casters) do
			local id = buffLoop.unitOf(caster)
			if id and not seenIds[id] then
				seenIds[id] = true
				need += caps[id] or 0
			end
		end
		local state = buffLoop.groups[attack]
		if maxMode and #group.casters < need then
			group.waitNeed = need
			if state then
				state.waitSince = state.waitSince or os.clock()
				if os.clock() - state.waitSince > 45 then
					group.waitNeed = nil
				end
			end
		elseif state then
			state.waitSince = nil
		end
	end
	for attack, state in pairs(buffLoop.groups) do
		if not groups[attack] then
			buffLoop.groups[attack] = nil
		end
	end
	local now = os.clock()
	for attack, group in pairs(groups) do
		local state = buffLoop.groups[attack] or {}
		buffLoop.groups[attack] = state
		state.name = #group.names > 1 and string.format("%s (%s)", buffLoop.typeNames[attack] or "Buff", table.concat(group.names, " + ")) or group.info.name
		local targets, buffed, weakest = {}, 0, nil
		for _, model in ipairs(models) do
			if not group.set[model] and buffLoop.isTarget(model, group.info) then
				local pos = model:GetPivot().Position
				for _, caster in ipairs(group.casters) do
					if flat(caster:GetPivot().Position, pos) <= group.ranges[caster] then
						table.insert(targets, model)
						local strength = buffLoop.value(model, group.info)
						if strength > 0 then
							buffed += 1
							weakest = math.min(weakest or strength, strength)
						end
						break
					end
				end
			end
		end
		state.casters, state.total, state.buffed, state.strength = #group.casters, #targets, buffed, weakest
		state.waitNeed = group.waitNeed
		if not state.typeText then
			local typeList = {}
			for damageType in pairs(group.info.types or {}) do
				table.insert(typeList, tostring(damageType))
			end
			table.sort(typeList)
			state.typeText = #typeList > 0 and table.concat(typeList, "/") or "damage"
		end
		local duration = buffLoop.duration(models, group.info)
		local gap, cooldown = buffLoop.plan(group.casters, duration, maxMode)
		state.gap, state.cooldown, state.duration = gap, cooldown, duration
		if not group.waitNeed and #targets > 0 then
			local lastCast = state.lastCastAt or -math.huge
			for _, caster in ipairs(group.casters) do
				local stats = caster:FindFirstChild("_stats")
				local value = stats and stats:FindFirstChild("last_active_cast")
				local stamp = value and tonumber(value.Value)
				if stamp and stamp > 0 then
					lastCast = math.max(lastCast, now - (tick() - stamp))
				end
			end
			local due
			if gap then
				due = now - lastCast >= gap
				state.nextIn = math.max(0, gap - (now - lastCast), (state.retryAt or 0) - now)
			else
				due = buffed == 0 and now - lastCast >= 1
				state.nextIn = nil
			end
			if due and now >= (state.retryAt or 0) then
				local caster = buffLoop.pick(group, gap and {} or targets, false, {})
				if caster then
					local previous = state.lastCastAt
					state.lastCastAt = now
					buffLoop.cast(caster, state, function()
						if state.lastCastAt == now then
							state.lastCastAt = previous
						end
						state.retryAt = os.clock() + 2
					end)
				end
			end
		end
	end
end

function buffLoop.statusLine()
	local parts = {}
	for _, state in pairs(buffLoop.groups) do
		if state.waitNeed then
			table.insert(parts, string.format("%s waiting for units %d/%d", state.name or "Buff", state.casters or 0, state.waitNeed))
		elseif (state.total or 0) == 0 then
			table.insert(parts, string.format("%s: no %s units in range to buff (%d casters)", state.name or "Buff", state.typeText or "damage", state.casters or 0))
		else
			local strength = state.strength and string.format(" at %d%%", math.floor(state.strength * 100 + 0.5)) or ""
			local rhythm = state.gap and string.format(", cast every %.1fs (cd %.1fs, buff %ds), next in %ds", state.gap, state.cooldown or 0, math.floor((state.duration or 0) + 0.5), math.ceil(state.nextIn or 0)) or ""
			table.insert(parts, string.format("%s %d/%d buffed%s (%d casters%s)", state.name or "Buff", state.buffed or 0, state.total or 0, strength, state.casters or 0, rhythm))
		end
	end
	table.sort(parts)
	local foreign = buffLoop.foreignStopped and (" | Stopped other buff script: " .. buffLoop.foreignStopped) or ""
	return (#parts > 0 and ("Buff loop: " .. table.concat(parts, ", ")) or "Buff loop: no buff units placed") .. foreign
end

autoPlay.skillBusy = setmetatable({}, { __mode = "k" })
autoPlay.skillBackoff = setmetatable({}, { __mode = "k" })

local function useSkills()
	for _, model in ipairs(unitModels()) do
		local info = unitData(modelUnitId(model))
		local stats = model:FindFirstChild("_stats")
		local activeValue = stats and stats:FindFirstChild("active_attack")
		local attack = activeValue and activeValue.Value
		if type(attack) ~= "string" or attack == "" then
			attack = info and info.active_attack
		end
		local skip = hub.settings.buffLoop and (buffLoop.skillInfo(attack) ~= nil or buffLoop.skillInfo(buffLoop.attackOf(model)) ~= nil)
		if type(attack) == "string" and not skip and not autoPlay.skillBusy[model] and os.clock() >= (autoPlay.nextSkill[model] or 0) and buffLoop.cooldownLeft(model) <= 0.1 and skillRules.allowed(model, attack) then
			autoPlay.nextSkill[model] = os.clock() + 0.75
			autoPlay.skillBusy[model] = true
			local castValue = stats and stats:FindFirstChild("last_active_cast")
			local castBefore = castValue and castValue.Value
			local before = nil
			if string.find(attack, "fusion", 1, true) then
				before = {}
				for _, owned in ipairs(unitModels()) do
					local uuid = modelUuid(owned)
					if uuid then
						before[uuid] = true
					end
				end
			end
			task.spawn(function()
				invoke("use_active_attack", model)
				local untilTime = os.clock() + 1
				while castValue and castValue.Value == castBefore and os.clock() < untilTime do
					task.wait(0.1)
				end
				local worked = not (castValue and castValue.Value == castBefore)
				if not worked then
					local backoff = math.min((autoPlay.skillBackoff[model] or 0.5) * 2, 8)
					autoPlay.skillBackoff[model] = backoff
					autoPlay.nextSkill[model] = os.clock() + backoff
				else
					autoPlay.skillBackoff[model] = nil
					if before then
						autoPlay.fusingUntil = os.clock() + 3
					end
				end
				autoPlay.skillBusy[model] = nil
				if before and worked then
					task.wait(3)
					local now = {}
					for _, owned in ipairs(unitModels()) do
						local uuid = modelUuid(owned)
						if uuid then
							now[uuid] = true
						end
					end
					for uuid in pairs(before) do
						if not now[uuid] then
							autoPlay.consumed[uuid] = true
						end
					end
				end
			end)
		end
	end
end

local function autoPlayTick()
	if not hub.settings.autoPlay then
		autoPlay.state = "Off"
		return 1
	end
	if hub.macroState == "playing" or hub.rec then
		autoPlay.state = "Paused while a macro plays or records"
		return 1
	end
	local present, started = gameState()
	if not present then
		autoPlay.state = "Waiting for a level"
		return 2
	end
	if hub.finishedAt then
		autoPlay.state = "Level finished"
		return 2
	end
	if not started then
		autoPlay.state = "Waiting for the level to start"
		return 1
	end
	buildCandidates(false)
	if #autoPlay.candidates == 0 then
		autoPlay.state = "Could not read the path on this map"
		return 5
	end
	autoPlay.skillsLive = os.clock()
	if os.clock() < (autoPlay.fusingUntil or 0) then
		autoPlay.state = "Fusing units"
		return 0.5
	end
	local action = nextAction()
	if not action then
		autoPlay.state = autoPlay.costMissing and ("Done, but the upgrade cost of " .. unitName(autoPlay.costMissing) .. " cannot be read") or "Everything placed and upgraded"
		return 2
	end
	if action.kind == "idle" then
		autoPlay.state = action.text
		return 1
	end
	local entry = action.entry
	local money = myResource()
	if action.kind == "sell" then
		autoPlay.waveSold[action.model] = (autoPlay.waveSold[action.model] or 0) + 1
		autoPlay.state = "Sell " .. unitName(entry.unitId) .. (action.waveSell == "all" and " (Sell All, wave " or " (Sell Farms, wave ") .. tostring(autoPlay.wave()) .. ")"
		invoke("sell_unit_ingame", action.model)
		local untilTime = os.clock() + 1.5
		while action.model.Parent and os.clock() < untilTime do
			task.wait(0.1)
		end
		if not action.model.Parent then
			autoPlay.belowSince = os.clock() - 3
			return 0.05
		end
		return 0.3
	end
	local label = (action.kind == "place" and "Place " or action.all and "Upgrade All: " or action.extra and "Extra upgrade " or "Upgrade ") .. unitName(entry.unitId) .. (entry.slot >= 100 and " (placed)" or (" (slot " .. tostring(entry.slot) .. ")"))
	if action.cost > 0 and money < action.cost then
		autoPlay.state = string.format(action.saving and "%s, saving for a spell %d/%d" or "%s, waiting for money %d/%d", label, math.floor(money), math.floor(action.cost))
		return 0.5
	end
	if action.kind == "upgrade" then
		autoPlay.state = label
		local before = modelLevel(action.model)
		invoke("upgrade_unit_ingame", action.model)
		local untilTime = os.clock() + 1.5
		while modelLevel(action.model) <= before and os.clock() < untilTime do
			task.wait(0.05)
		end
		if modelLevel(action.model) > before or not action.model.Parent then
			autoPlay.upgraded += 1
			autoPlay.upgradeFails[action.model] = 0
			return 0.05
		end
		local fails = (autoPlay.upgradeFails[action.model] or 0) + 1
		autoPlay.upgradeFails[action.model] = fails
		if fails >= 3 then
			task.delay(8, function()
				if autoPlay.upgradeFails[action.model] == fails then
					autoPlay.upgradeFails[action.model] = 0
				end
			end)
		end
		return 0.3
	end
	local cluster = nil
	if buffLoop.isBuffUnit(entry.unitId) then
		cluster = {}
		for _, model in ipairs(unitModels()) do
			if modelUnitId(model) == entry.unitId then
				local ok, pivot = pcall(function()
					return model:GetPivot().Position
				end)
				if ok then
					table.insert(cluster, pivot)
				end
			end
		end
	end
	local spot = bestSpot(entry.unitId, cluster, buffLoop.isBuffUnit(entry.unitId))
	if not spot then
		autoPlay.blocked[entry.uuid] = true
		autoPlay.state = ((unitData(entry.unitId) or {}).hill_unit and "No free hill spot for " or "No free spot for ") .. unitName(entry.unitId)
		return 0.5
	end
	autoPlay.state = label
	local before = #placedByUuid(entry.uuid)
	local calledAt = os.clock()
	invoke("spawn_unit", entry.uuid, CFrame.new(spot.pos))
	local untilTime = os.clock() + 2
	while #placedByUuid(entry.uuid) <= before and os.clock() < untilTime do
		task.wait(0.1)
	end
	if #placedByUuid(entry.uuid) > before then
		autoPlay.placed += 1
		autoPlay.fails[entry.uuid] = 0
		return 0.1
	end
	local refused = refusedMessage(calledAt)
	local lowered = string.lower(refused or "")
	if string.find(lowered, "more than %d+ units") then
		local limit = tonumber(string.match(lowered, "more than (%d+) units")) or math.huge
		autoPlay.fullCount = math.max(math.min(limit, #unitModels()), 1)
		autoPlay.fullLearned = true
		autoPlay.belowSince = nil
		autoPlay.state = "Unit limit reached (" .. tostring(autoPlay.fullCount) .. "), upgrading instead"
		return 0.2
	end
	local spotProblem = not refused or string.find(lowered, "cannot place", 1, true) ~= nil or string.find(lowered, "cannot be placed", 1, true) ~= nil
	if spotProblem then
		for _, candidate in ipairs(autoPlay.candidates) do
			if flat(candidate.pos, spot.pos) <= (refused and 1.2 or 0.1) then
				autoPlay.badSpots[candidate.key] = true
			end
		end
		autoPlay.badCount = (autoPlay.badCount or 0) + 1
	end
	autoPlay.fails[entry.uuid] = (autoPlay.fails[entry.uuid] or 0) + 1
	autoPlay.placeRest[entry.uuid] = os.clock() + 3
	if not spotProblem or autoPlay.fails[entry.uuid] >= 15 then
		autoPlay.blocked[entry.uuid] = true
		autoPlay.state = "Stopped placing " .. unitName(entry.unitId) .. ": " .. tostring(refused or "no spot worked")
	end
	return 0.2
end

local placement = {
	visuals = {},
	closing = {},
	colors = { unit = Color3.fromRGB(236, 118, 44), farm = Color3.fromRGB(245, 245, 245) },
	names = { unit = "UNIT AREA", farm = "FARM AREA" },
}

function placement.radius(kind)
	return areaRadius(kind)
end

function placement.clearPath()
	if placement.pathFolder then
		pcall(function()
			placement.pathFolder:Destroy()
		end)
	end
	placement.pathFolder = nil
	placement.pathKey = nil
end

function placement.drawPath()
	if not hub.settings.pathPlace or not autoPlay.path or #autoPlay.path == 0 then
		placement.clearPath()
		return
	end
	local kinds = { { "ground", "GROUND" }, { "hill", "HILL" }, { "buff", "BUFF" } }
	local key = tostring(autoPlay.mapKey) .. "_" .. #autoPlay.path
	for _, item in ipairs(kinds) do
		key ..= "_" .. autoPlay.pathPercent(item[1])
	end
	if key == placement.pathKey and placement.pathFolder and placement.pathFolder.Parent then
		return
	end
	placement.clearPath()
	placement.pathKey = key
	local make = placement.make
	local folder = make("Folder", { Name = "OrderHubPathMarks" }, nil)
	for index, item in ipairs(kinds) do
		local percent = autoPlay.pathPercent(item[1])
		local color = index == 2 and Color3.new(1, 1, 1) or placement.colors.unit
		for _, pos in ipairs(autoPlay.pathTargets(percent)) do
			local holder = make("Part", { Anchored = true, CanCollide = false, CanQuery = false, CanTouch = false, CastShadow = false, Transparency = 1, Size = Vector3.new(0.2, 0.2, 0.2), CFrame = CFrame.new(pos + Vector3.new(0, 0.3, 0)) }, folder)
			make("SphereHandleAdornment", { Adornee = holder, Color3 = color, Radius = 0.55, Transparency = 0.15, AlwaysOnTop = true, ZIndex = 1 }, holder)
			local billboard = make("BillboardGui", { Adornee = holder, Size = UDim2.fromOffset(96, 20), StudsOffsetWorldSpace = Vector3.new(0, 1.6 + (index - 1) * 1.1, 0), AlwaysOnTop = true, LightInfluence = 0, MaxDistance = 400 }, holder)
			local label = make("TextLabel", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(14, 14, 16), BackgroundTransparency = 0.15, BorderSizePixel = 0, Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = Color3.new(1, 1, 1), Text = item[2] .. " " .. percent .. "%" }, billboard)
			make("UICorner", { CornerRadius = UDim.new(0, 6) }, label)
			make("UIStroke", { Color = color, Thickness = 1, Transparency = 0.2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, label)
		end
	end
	folder.Parent = workspace
	placement.pathFolder = folder
end

function placement.clear(kind, instant)
	if not kind then
		placement.clearPath()
	end
	for name, visual in pairs(placement.visuals) do
		if not kind or name == kind then
			placement.visuals[name] = nil
			if instant or not visual.folder.Parent then
				pcall(function()
					visual.folder:Destroy()
				end)
			else
				visual.closingAt = os.clock()
				visual.radius = 0
				table.insert(placement.closing, visual)
			end
		end
	end
	if instant then
		for _, visual in ipairs(placement.closing) do
			pcall(function()
				visual.folder:Destroy()
			end)
		end
		table.clear(placement.closing)
	end
end

function placement.applyRadius(visual, radius)
	visual.fill.Radius = radius
	visual.glow.Radius = radius + 0.3
	visual.edge.Radius = radius
	pcall(function()
		visual.glow.InnerRadius = math.max(0, radius - 0.55)
		visual.edge.InnerRadius = math.max(0, radius - 0.16)
	end)
	local dashRadius = radius + 0.8
	local length = math.max(0.05, (2 * math.pi * dashRadius / #visual.dashes) * 0.45)
	for index, dash in ipairs(visual.dashes) do
		dash.Size = Vector3.new(length, 0.05, 0.11)
		dash.CFrame = CFrame.Angles(0, (index / #visual.dashes) * math.pi * 2, 0) * CFrame.new(0, 0.05, -dashRadius)
	end
end

function placement.make(className, props, parent)
	local object = Instance.new(className)
	for key, value in pairs(props) do
		object[key] = value
	end
	object.Parent = parent
	return object
end

function placement.build(kind)
	local visual = placement.visuals[kind]
	if visual and visual.folder and visual.folder.Parent then
		return visual
	end
	placement.clear(kind)
	local make = placement.make
	local color = placement.colors[kind]
	local accentColor = kind == "farm" and placement.colors.unit or Color3.new(1, 1, 1)
	local white = Color3.new(1, 1, 1)
	local lay = CFrame.Angles(math.rad(90), 0, 0)
	local folder = make("Folder", { Name = "OrderHubPlacementArea_" .. kind }, nil)
	local partProps = { Anchored = true, CanCollide = false, CanQuery = false, CanTouch = false, CastShadow = false, Transparency = 1, Size = Vector3.new(0.2, 0.2, 0.2) }
	local holder = make("Part", partProps, folder)
	holder.Name = "Center"
	local spinner = make("Part", partProps, folder)
	spinner.Name = "Spinner"
	visual = { kind = kind, folder = folder, holder = holder, spinner = spinner, dotKey = "", dashes = {}, dotList = {}, focus = 0, dotsShown = true, spin = 0, shownRadius = 0.05, radiusVel = 0 }
	visual.fill = make("CylinderHandleAdornment", { Adornee = holder, Color3 = color, Height = 0.04, CFrame = lay }, holder)
	visual.glow = make("CylinderHandleAdornment", { Adornee = holder, Color3 = color, Height = 0.05, CFrame = CFrame.new(0, 0.03, 0) * lay }, holder)
	visual.edge = make("CylinderHandleAdornment", { Adornee = holder, Color3 = color, Height = 0.09, CFrame = CFrame.new(0, 0.06, 0) * lay }, holder)
	visual.base = make("CylinderHandleAdornment", { Adornee = holder, Color3 = white, Radius = 0.42, Height = 0.08, CFrame = CFrame.new(0, 0.08, 0) * lay }, holder)
	visual.beam = make("CylinderHandleAdornment", { Adornee = holder, Color3 = white, Radius = 0.07, Height = 2.6, CFrame = CFrame.new(0, 1.35, 0) * lay }, holder)
	visual.tip = make("SphereHandleAdornment", { Adornee = holder, Color3 = placement.colors.unit, Radius = 0.28, CFrame = CFrame.new(0, 2.7, 0) }, holder)
	visual.ripple = make("CylinderHandleAdornment", { Adornee = holder, Color3 = color, Height = 0.05, Visible = false, CFrame = CFrame.new(0, 0.07, 0) * lay }, holder)
	for index = 1, 36 do
		visual.dashes[index] = make("BoxHandleAdornment", { Adornee = spinner, Color3 = accentColor }, spinner)
	end
	visual.dots = make("Folder", { Name = "Spots" }, holder)
	local billboard = make("BillboardGui", { Adornee = holder, Size = UDim2.fromOffset(210, 46), StudsOffsetWorldSpace = Vector3.new(0, 4.3, 0), AlwaysOnTop = true, LightInfluence = 0, MaxDistance = 400 }, holder)
	local card = make("CanvasGroup", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(14, 14, 16), BackgroundTransparency = 0.1, BorderSizePixel = 0, GroupTransparency = 1 }, billboard)
	make("UICorner", { CornerRadius = UDim.new(0, 10) }, card)
	visual.card = card
	visual.cardScale = make("UIScale", { Scale = 0.85 }, card)
	make("UIStroke", { Color = color, Thickness = 1.2, Transparency = 0.3 }, card)
	local accent = make("Frame", { Size = UDim2.new(0, 3, 1, -16), Position = UDim2.fromOffset(9, 8), BackgroundColor3 = color, BorderSizePixel = 0 }, card)
	make("UICorner", { CornerRadius = UDim.new(1, 0) }, accent)
	visual.title = make("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(20, 6), Size = UDim2.new(1, -28, 0, 14), Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = Color3.fromRGB(160, 160, 166), TextXAlignment = Enum.TextXAlignment.Left, Text = "" }, card)
	visual.value = make("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(20, 21), Size = UDim2.new(1, -28, 0, 18), Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = white, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Text = "" }, card)
	visual.billboard = billboard
	if kind == "farm" then
		visual.base.Visible = false
		visual.beam.Visible = false
		visual.tip.Visible = false
	end
	folder.Parent = workspace
	placement.visuals[kind] = visual
	return visual
end

function placement.draw(kind, center, radius, title, value, showSpots, spotRadius)
	spotRadius = spotRadius or radius
	local visual = placement.build(kind)
	local origin = center + Vector3.new(0, 0.12, 0)
	visual.targetPos = origin
	visual.radius = radius
	if not visual.shown then
		visual.shown = origin
		visual.holder.CFrame = CFrame.new(origin)
	end
	visual.title.Text = title
	local occupied = showSpots and autoPlay.occupancy() or {}
	local unitCount = #occupied
	local dotKey = showSpots and string.format("%.1f_%.1f_%d_%d_%d", center.X, center.Z, spotRadius, #autoPlay.candidates, unitCount) or ""
	if dotKey ~= visual.dotKey then
		visual.dotKey = dotKey
		visual.dots:ClearAllChildren()
		visual.dotList = {}
		visual.dotsBorn = os.clock()
		visual.free, visual.total = 0, 0
		if showSpots then
			for _, candidate in ipairs(autoPlay.candidates) do
				if flat(candidate.pos, center) <= spotRadius then
					visual.total += 1
					local free = spotIsFree(candidate, 1.5, occupied)
					if free then
						visual.free += 1
					end
					if visual.total <= 140 then
						local dot = placement.make("CylinderHandleAdornment", {
							Adornee = visual.holder,
							Radius = 0.05,
							Height = 0.06,
							Color3 = free and Color3.new(1, 1, 1) or placement.colors.unit,
							Transparency = 1,
							Visible = visual.dotsShown,
							CFrame = CFrame.new(candidate.pos + Vector3.new(0, 0.1, 0) - origin) * CFrame.Angles(math.rad(90), 0, 0),
						}, visual.dots)
						table.insert(visual.dotList, {
							dot = dot,
							radius = free and 0.2 or 0.32,
							transparency = free and 0.45 or 0.05,
							delay = flat(candidate.pos, center) * 0.025,
						})
					end
				end
			end
		end
	end
	if value then
		visual.value.Text = value
	elseif kind == "unit" and hub.settings.useFarmArea then
		visual.value.Text = string.format("Units %d  \u{00B7}  Farm %d  \u{00B7}  %d free", radius, areaRadius("farm"), visual.free or 0)
	else
		visual.value.Text = string.format("%d studs  \u{00B7}  %d free of %d", radius, visual.free or 0, visual.total or 0)
	end
end

function placement.animate(dt)
	local now = os.clock()
	local windowOpen = false
	if ui.window then
		local ok, state = pcall(function()
			return ui.window:GetState()
		end)
		windowOpen = ok and state == true
	end
	local target = (placement.picking or windowOpen or now < (placement.focusUntil or 0)) and 1 or 0
	for _, visual in pairs(placement.visuals) do
		if visual.folder.Parent then
			placement.animateOne(visual, dt, now, target)
		end
	end
	local unitVisual, farmVisual = placement.visuals.unit, placement.visuals.farm
	pcall(function()
		if unitVisual and farmVisual then
			local big, small = unitVisual, farmVisual
			if farmVisual.shownRadius > unitVisual.shownRadius then
				big, small = farmVisual, unitVisual
			end
			big.fill.InnerRadius = math.min(small.shownRadius, big.shownRadius - 0.05)
			small.fill.InnerRadius = 0
		elseif unitVisual then
			unitVisual.fill.InnerRadius = 0
		end
	end)
	for index = #placement.closing, 1, -1 do
		local visual = placement.closing[index]
		if now - visual.closingAt > 0.45 or not visual.folder.Parent then
			table.remove(placement.closing, index)
			pcall(function()
				visual.folder:Destroy()
			end)
		else
			placement.animateOne(visual, dt, now, 0)
		end
	end
end

function placement.animateOne(visual, dt, now, target)
	local blend = 1 - math.exp(-dt * 6)
	visual.focus += (target - visual.focus) * blend
	local focus = visual.focus
	local pulse = (math.sin(now * 2.2 + (visual.kind == "farm" and 1.6 or 0)) + 1) / 2
	local goal = visual.targetPos
	if goal then
		if not visual.shown or (visual.shown - goal).Magnitude > 250 then
			visual.shown = goal
		end
		visual.shown = visual.shown:Lerp(goal, 1 - math.exp(-dt * (placement.picking and 20 or 9)))
		visual.holder.CFrame = CFrame.new(visual.shown)
	end
	local goalRadius = visual.radius or 0
	local accel = (goalRadius - visual.shownRadius) * 170 - visual.radiusVel * 17
	visual.radiusVel += accel * math.min(dt, 0.05)
	visual.shownRadius = math.max(0.05, visual.shownRadius + visual.radiusVel * math.min(dt, 0.05))
	if math.abs(visual.shownRadius - (visual.appliedRadius or -1)) > 0.004 then
		visual.appliedRadius = visual.shownRadius
		placement.applyRadius(visual, visual.shownRadius)
	end
	visual.spin = (visual.spin + dt * (placement.picking and 0.9 or 0.3)) % (math.pi * 2)
	visual.spinner.CFrame = visual.holder.CFrame * CFrame.Angles(0, visual.spin, 0)
	if visual.dotsBorn then
		local age = now - visual.dotsBorn
		local finished = true
		for _, item in ipairs(visual.dotList) do
			local t = math.clamp((age - item.delay) / 0.35, 0, 1)
			if t < 1 then
				finished = false
			end
			local ease = 1 - (1 - t) ^ 3
			item.dot.Transparency = 1 - (1 - item.transparency) * ease
			item.dot.Radius = item.radius * (0.25 + 0.75 * ease)
		end
		if finished then
			visual.dotsBorn = nil
		end
	end
	local rippleAt = placement.rippleAt
	if rippleAt and now - rippleAt < 0.85 then
		local t = (now - rippleAt) / 0.85
		local ease = 1 - (1 - t) ^ 3
		local rippleRadius = math.max(0.1, (visual.radius or 1) * (0.15 + 1.05 * ease))
		visual.ripple.Visible = true
		visual.ripple.Radius = rippleRadius
		pcall(function()
			visual.ripple.InnerRadius = math.max(0, rippleRadius - (0.6 * (1 - t) + 0.12))
		end)
		visual.ripple.Transparency = 0.15 + 0.85 * t
	elseif visual.ripple.Visible then
		visual.ripple.Visible = false
	end
	visual.fill.Transparency = 0.95 - 0.07 * focus
	visual.glow.Transparency = 0.92 - (0.22 + 0.12 * pulse) * focus
	visual.edge.Transparency = 0.6 - 0.55 * focus
	visual.base.Transparency = 0.7 - 0.55 * focus
	visual.beam.Transparency = 1 - 0.55 * focus
	visual.tip.Transparency = 1 - (0.75 + 0.25 * pulse) * focus
	local dashVisible = focus > 0.05
	local dashTransparency = 1 - (0.35 + 0.25 * pulse) * focus
	for _, dash in ipairs(visual.dashes) do
		dash.Visible = dashVisible
		dash.Transparency = dashTransparency
	end
	visual.billboard.Enabled = focus > 0.02 and visual.kind ~= "farm"
	visual.card.GroupTransparency = 1 - focus
	visual.cardScale.Scale = 0.85 + 0.15 * (1 - (1 - focus) ^ 2)
	local showDots = focus > 0.3
	if showDots ~= visual.dotsShown then
		visual.dotsShown = showDots
		for _, dot in ipairs(visual.dots:GetChildren()) do
			dot.Visible = showDots
		end
	end
end

function placement.ray(screenPos, isTouch)
	local camera = workspace.CurrentCamera
	if not camera then
		return nil
	end
	local ray = isTouch and camera:ScreenPointToRay(screenPos.X, screenPos.Y) or camera:ViewportPointToRay(screenPos.X, screenPos.Y)
	return workspace:Raycast(ray.Origin, ray.Direction * 1500, placementParams())
end

function placement.refresh()
	local present = gameState()
	if not present or not (hub.settings.showPlacementArea or placement.picking) then
		placement.clear()
		return
	end
	if not autoPlay.mapKey and not placement.picking then
		pcall(buildCandidates, false)
	end
	if placement.picking then
		local targets = placement.pickTargets
		if targets and targets.unit then
			local hint = (UserInputService.TouchEnabled and not UserInputService.MouseEnabled) and "Tap the ground to set" or "Click to set  \u{00B7}  Right click cancels"
			placement.draw("unit", targets.unit, areaRadius("unit"), "PICK THE AREA", hint, false)
			if targets.farm then
				placement.draw("farm", targets.farm, areaRadius("farm"), "", "", false)
			else
				placement.clear("farm")
			end
		end
		return
	end
	local anchor = mapAnchor("unit")
	if not anchor then
		placement.clear()
		return
	end
	local farmOn = mapAnchor("farm") ~= nil
	local spotRadius = math.max(areaRadius("unit"), farmOn and areaRadius("farm") or 0)
	placement.draw("unit", anchor, areaRadius("unit"), autoPlay.savedAnchor() and "PLACEMENT AREA" or "AUTO AREA  \u{00B7}  MAP CENTER", nil, true, spotRadius)
	if farmOn then
		placement.draw("farm", anchor, areaRadius("farm"), "", "", false)
	else
		placement.clear("farm")
	end
	pcall(placement.drawPath)
end

function placement.targetsFor(center)
	return { unit = center, farm = hub.settings.useFarmArea and center or nil }
end

function placement.save(pos)
	local key = currentMapKey()
	if key == "" then
		setStatus("Could not read this map")
		return false
	end
	hub.settings.autoPlayAnchors = type(hub.settings.autoPlayAnchors) == "table" and hub.settings.autoPlayAnchors or {}
	hub.settings.autoPlayAnchors[key] = { x = pos.X, y = pos.Y, z = pos.Z }
	saveConfig()
	autoPlay.mapKey = nil
	autoPlay.blocked = {}
	placement.focusUntil = os.clock() + 6
	placement.rippleAt = os.clock()
	pcall(buildCandidates, true)
	return true
end

function placement.resync()
	autoPlay.mapKey = nil
	autoPlay.blocked = {}
	placement.focusUntil = os.clock() + 6
end

function placement.finishPick(pos)
	placement.picking = false
	placement.pickTargets = nil
	placement.pending = nil
	placement.touchStart = nil
	if placement.hidePanel then
		pcall(placement.hidePanel)
	end
	if ui.window then
		pcall(function()
			ui.window:SetState(true)
		end)
	end
	if pos and placement.save(pos) then
		setStatus("Placement area saved for this map")
	elseif not pos then
		setStatus("Picking the area was cancelled")
	end
end

function placement.startPick()
	if not select(1, gameState()) then
		setStatus("Join a level first, then pick the area on its map")
		return
	end
	local start = mapAnchor("unit")
	local camera = workspace.CurrentCamera
	if not start and camera then
		local result = placement.ray(camera.ViewportSize / 2, false)
		start = result and result.Position
	end
	placement.picking = true
	placement.pending = nil
	placement.pickUntil = os.clock() + 120
	placement.rippleAt = os.clock()
	placement.pickTargets = start and placement.targetsFor(start) or nil
	if placement.pickTargets then
		pcall(placement.refresh)
	end
	if ui.window then
		pcall(function()
			ui.window:SetState(false)
		end)
	end
	if placement.showPanel then
		pcall(placement.showPanel)
	end
	setStatus("Pick a spot, then Confirm. Q cancels.")
end

function placement.choose(screenPos, isTouch)
	local result = placement.ray(screenPos, isTouch)
	if not result then
		setStatus("Pick the ground of the map")
		return
	end
	local road = workspace:FindFirstChild("_road")
	if road and result.Instance:IsDescendantOf(road) then
		setStatus("That is the enemy path, pick the ground next to it")
		return
	end
	placement.pending = result.Position
	placement.pickUntil = os.clock() + 120
	placement.rippleAt = os.clock()
	placement.pickTargets = placement.targetsFor(result.Position)
	pcall(placement.refresh)
	if placement.updatePanel then
		pcall(placement.updatePanel)
	end
end

function placement.confirm()
	if placement.picking and placement.pending then
		placement.finishPick(placement.pending)
	end
end

function placement.onInput(input, processed)
	if not placement.picking then
		return
	end
	if input.KeyCode == Enum.KeyCode.Q and not UserInputService:GetFocusedTextBox() then
		placement.finishPick(nil)
		return
	end
	if (input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.KeypadEnter) and not processed then
		placement.confirm()
		return
	end
	if processed then
		return
	end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local mouse = UserInputService:GetMouseLocation()
		placement.choose(Vector2.new(mouse.X, mouse.Y), false)
	elseif input.UserInputType == Enum.UserInputType.Touch then
		placement.touchStart = Vector2.new(input.Position.X, input.Position.Y)
	end
end

function placement.onInputEnded(input, processed)
	if not placement.picking or input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end
	local start = placement.touchStart
	placement.touchStart = nil
	local finish = Vector2.new(input.Position.X, input.Position.Y)
	if start and not processed and (finish - start).Magnitude < 12 then
		placement.choose(finish, true)
	end
end

function placement.onFrame()
	if not placement.picking then
		return
	end
	if os.clock() > (placement.pickUntil or 0) then
		placement.finishPick(nil)
		return
	end
	if placement.pending or not UserInputService.MouseEnabled then
		return
	end
	local result = placement.ray(UserInputService:GetMouseLocation(), false)
	if result then
		local last = placement.pickTargets and placement.pickTargets.unit
		if not last or flat(last, result.Position) > 0.05 then
			placement.pickTargets = placement.targetsFor(result.Position)
			placement.refresh()
		end
	end
end

local function setAnchorHere()
	local character = LocalPlayer.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root or not select(1, gameState()) then
		setStatus("Stand on the map inside a level first")
		return
	end
	if placement.save(root.Position - Vector3.new(0, 3, 0)) then
		setStatus("Placement area saved for this map")
	end
end

local function clearAnchor()
	local key = currentMapKey()
	if type(hub.settings.autoPlayAnchors) == "table" then
		hub.settings.autoPlayAnchors[key] = nil
		hub.settings.autoPlayAnchors[autoPlay.laneKey()] = nil
	end
	saveConfig()
	autoPlay.mapKey = nil
	setStatus(autoPlay.presetAnchors[key] and "Placement set back to the default for this map" or "Placement set back to automatic")
end

local function autoPlayStatusText()
	local spotMode = "automatic (best path cover)"
	if mapAnchor("unit") then
		local saved, preset = autoPlay.savedAnchor()
		spotMode = (preset and "default " or saved and "your " or "map center ") .. "unit area " .. areaRadius("unit") .. " studs"
		if mapAnchor("farm") then
			spotMode = spotMode .. ", farm area " .. areaRadius("farm") .. " studs"
		end
	elseif mapAnchor("farm") then
		spotMode = "farm area " .. areaRadius("farm") .. " studs, others automatic"
	end
	local lines = {
		"State: " .. autoPlay.state,
		"Spot: " .. spotMode .. ", " .. tostring(#autoPlay.candidates) .. " places found",
		"Placed: " .. tostring(autoPlay.placed) .. " | Upgrades: " .. tostring(autoPlay.upgraded),
	}
	if gameState() then
		local upgradeScale = nil
		for _, model in ipairs(unitModels()) do
			local stats = model:FindFirstChild("_stats")
			local multiplier = stats and stats:FindFirstChild("upgrade_cost_multiplier")
			if multiplier and not costRules.isCostBuffer(modelUnitId(model)) then
				upgradeScale = costRules.capped(costRules.levelScale() * (tonumber(multiplier.Value) or 1))
				break
			end
		end
		table.insert(lines, string.format("Costs: placement x%.2f | upgrades %s", costRules.capped(costRules.levelScale()), upgradeScale and string.format("x%.2f", upgradeScale) or "?"))
	end
	if hub.settings.buffLoop then
		table.insert(lines, buffLoop.statusLine())
	end
	if gameState() then
		table.insert(lines, "Settings: " .. autoPlay.activeMode() .. " mode")
		local parts = {}
		for _, entry in ipairs(autoPlay.team or {}) do
			local config = slotConfig(entry.slot)
			local gameCap, reason = placeLimit(entry.unitId, entry.uuid)
			if autoPlay.noCap() then
				gameCap, reason = nil, nil
			end
			local cap = math.min(autoPlay.gameCap(entry.unitId, entry.uuid), config.place and config.max or 0)
			local buffCap = buffLoop.isBuffUnit(entry.unitId) and math.floor(tonumber(hub.settings.buffUnitCap) or 4) or nil
			local count = #placedByUuid(entry.uuid)
			local note = ""
			if autoPlay.waveLocked(config) then
				note = " from W" .. config.placeWave
			elseif buffCap and buffCap < cap then
				cap = buffCap
				note = " buff loop"
			elseif autoPlay.consumed[entry.uuid] then
				note = " fused"
			elseif reason and cap == 1 then
				note = " " .. reason
			elseif gameCap and cap == gameCap then
				note = " game max"
			end
			table.insert(parts, unitName(entry.unitId) .. " " .. count .. "/" .. cap .. note)
		end
		if #parts > 0 then
			table.insert(lines, "Team: " .. table.concat(parts, ", "))
		end
		if autoPlay.noCap() then
			table.insert(lines, "No unit cap in this mode, using Max placed per unit")
		end
	end
	return table.concat(lines, "\n")
end

local function refreshAutoPlayStatus()
	if os.clock() >= (autoPlay.nextTeamRead or 0) then
		autoPlay.nextTeamRead = os.clock() + 5
		pcall(teamUnits)
	end
	local text = autoPlayStatusText()
	if text ~= autoPlay.text and ui.autoPlayStatus then
		autoPlay.text = text
		pcall(function()
			ui.autoPlayStatus:UpdateBody(text)
		end)
	end
	if ui.refreshTeam and os.clock() >= (autoPlay.nextTeamUi or 0) then
		autoPlay.nextTeamUi = os.clock() + 1
		pcall(ui.refreshTeam)
		if ui.followMode then
			pcall(ui.followMode)
		end
	end
end

local function lobbyList()
	local lobbies = workspace:FindFirstChild("_LOBBIES")
	local story = lobbies and lobbies:FindFirstChild("Story")
	return story and story:GetChildren() or {}
end

local function lobbyFree(lobby)
	local owner = lobby:FindFirstChild("Owner")
	local active = lobby:FindFirstChild("Active")
	local teleporting = lobby:FindFirstChild("Teleporting")
	local locked = lobby:FindFirstChild("Locked")
	if not owner or owner.Value ~= nil then
		return false
	end
	if (active and active.Value) or (teleporting and teleporting.Value) or (locked and locked.Value) then
		return false
	end
	return true
end

local function leaveLobby()
	if hub.lobbyName then
		invoke("request_leave_lobby", hub.lobbyName)
		hub.lobbyName = nil
	end
	hub.joinedAt = 0
end

local function ownedLobby()
	for _, lobby in ipairs(lobbyList()) do
		local owner = lobby:FindFirstChild("Owner")
		if owner and owner.Value == LocalPlayer then
			return lobby
		end
	end
	return nil
end

local function forcedDifficulty(levelId)
	local ok, forced = pcall(function()
		local levels = require(ReplicatedStorage.src.Data.Levels)
		local data = levels[levelId]
		if not data then
			return nil
		end
		if data.infinite then
			return "Hard"
		end
		local worlds = require(ReplicatedStorage.src.Data.Worlds)
		local world = data.world and worlds[data.world]
		if world and (world.legend_stage or world.raid_world) then
			return "Hard"
		end
		return nil
	end)
	return ok and forced or nil
end

local function levelDifficulty(levelId)
	return forcedDifficulty(levelId) or hub.settings.difficulty or "Normal"
end

local function joinLobby()
	if hub.joining then
		return
	end
	local level = hub.settings.level
	if not level or level == "" then
		setStatus("Pick a world and level first")
		return
	end
	local character = LocalPlayer.Character
	if not (character and character:FindFirstChild("HumanoidRootPart")) then
		setStatus("Waiting for your character to load in the lobby")
		return
	end
	hub.joining = true
	local joined = false
	for _, lobby in ipairs(lobbyList()) do
		if lobbyFree(lobby) then
			pcall(function()
				local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
				local pad = lobby:FindFirstChild("Teleport") or lobby:FindFirstChild("primary")
				if root and pad then
					root.CFrame = pad.CFrame + Vector3.new(0, 3, 0)
				end
			end)
			task.wait(0.8)
			hub.nextStart = os.clock() + 8
			hub.emptySince = nil
			if invoke("request_join_lobby", lobby.Name) then
				task.wait(1.5)
				invoke("request_lock_level", lobby.Name, level, false, levelDifficulty(level))
				hub.lobbyName = lobby.Name
				hub.joinedAt = os.clock()
				hub.nextStart = os.clock() + 3
				local levelValue = lobby:FindFirstChild("Level")
				local waitUntil = os.clock() + 3
				while levelValue and levelValue.Value == "" and os.clock() < waitUntil do
					task.wait(0.2)
				end
				if levelValue and levelValue.Value == "" then
					hub.lockFails = (hub.lockFails or 0) + 1
					task.wait(1.5)
					invoke("request_leave_lobby", lobby.Name)
					hub.lobbyName = nil
					hub.joinedAt = 0
					if hub.lockFails >= 3 then
						hub.joinPauseUntil = os.clock() + 60
						setStatus("The game will not start " .. level .. " from a lobby. Pick another level")
					else
						setStatus("Could not pick " .. level .. ", trying another lobby")
					end
					hub.joining = false
					return
				end
				hub.lockFails = 0
				joined = true
				setStatus("Joined " .. lobby.Name .. " with " .. level)
				break
			end
		end
	end
	if not joined then
		setStatus("No free lobby, retrying")
	end
	hub.joining = false
end

local function startLobby()
	local lobby = ownedLobby()
	if not lobby then
		return false
	end
	local teleporting = lobby:FindFirstChild("Teleporting")
	if teleporting and teleporting.Value then
		setStatus("Teleporting to the level")
		return true
	end
	local levelValue = lobby:FindFirstChild("Level")
	if levelValue and levelValue.Value == "" then
		if hub.joining then
			return false
		end
		hub.emptySince = hub.emptySince or os.clock()
		if hub.settings.autoJoin and os.clock() - hub.emptySince > 8 then
			hub.emptySince = nil
			invoke("request_leave_lobby", lobby.Name)
			hub.lobbyName = nil
			hub.joinedAt = 0
			setStatus("Lobby had no level picked, joining again")
		elseif not hub.settings.autoJoin then
			setStatus("Pick a level in your lobby first")
		end
		return false
	end
	hub.emptySince = nil
	invoke("request_start_game", lobby.Name)
	setStatus("Starting " .. tostring(lobby:FindFirstChild("Level") and lobby.Level.Value or "level"))
	return true
end

local function finishAction(kind)
	if kind == "Replay" then
		return invoke("set_game_finished_vote", "replay")
	elseif kind == "Next Story" then
		return invoke("set_game_finished_vote", "next_story")
	elseif kind == "Back To Lobby" then
		return invoke("teleport_back_to_lobby")
	elseif kind == "Next Room" then
		return invoke("request_start_infinite_tower_from_game")
	elseif kind == "Next Portal" then
		local data = hub.portal.levelData()
		local item = data and hub.portal.pick(data.portal_group, data._portal_map_item_uuid)
		if not item then
			return false
		end
		hub.portal.state = "Next: " .. item.name .. " (" .. item.left .. " tries left)"
		local result, _, done = invoke("set_game_finished_vote", "replay", { item_uuid = item.uuid })
		if done then
			hub.portal.voted = hub.finishedAt
			hub.portal.votedAt = os.clock()
		end
		return result
	end
	return false
end

local function sortKey(id)
	return (string.gsub(id, "%d+", function(digits)
		return string.format("%03d", tonumber(digits))
	end))
end

local function buildLevels()
	local ok, levels = pcall(function()
		return require(ReplicatedStorage.src.Data.Levels)
	end)
	local rank = {}
	if ok and type(levels) == "table" then
		for id, data in pairs(levels) do
			if type(id) == "string" and type(data) == "table" and data.world and not data._portal_only_level and not data.is_raid and not data.cant_start and not string.find(id, "template", 1, true) then
				local world = data.world
				if not hub.levelsByWorld[world] then
					hub.levelsByWorld[world] = {}
					rank[world] = data.story_world_rank or 99
					table.insert(hub.worlds, world)
				end
				table.insert(hub.levelsByWorld[world], id)
			end
		end
	end
	table.sort(hub.worlds, function(a, b)
		if rank[a] ~= rank[b] then
			return rank[a] < rank[b]
		end
		return a < b
	end)
	for _, list in pairs(hub.levelsByWorld) do
		table.sort(list, function(a, b)
			local ia, ib = string.find(a, "infinite", 1, true), string.find(b, "infinite", 1, true)
			if (ia ~= nil) ~= (ib ~= nil) then
				return ib ~= nil
			end
			return sortKey(a) < sortKey(b)
		end)
	end
end

local function antiAfkNudge()
	pcall(function()
		local virtualUser = game:GetService("VirtualUser")
		virtualUser:CaptureController()
		virtualUser:ClickButton2(Vector2.new())
	end)
	pcall(function()
		local manager = game:GetService("VirtualInputManager")
		local location = UserInputService:GetMouseLocation()
		manager:SendMouseMoveEvent(location.X + 1, location.Y, game)
		task.wait()
		manager:SendMouseMoveEvent(location.X, location.Y, game)
	end)
	pcall(function()
		local manager = game:GetService("VirtualInputManager")
		manager:SendKeyEvent(true, Enum.KeyCode.F13, false, game)
		task.wait()
		manager:SendKeyEvent(false, Enum.KeyCode.F13, false, game)
	end)
end

local function onGameStart()
	hub.autoPlay.mapKey = nil
	hub.autoPlay.badSpots = {}
	hub.autoPlay.blocked = {}
	hub.autoPlay.fails = {}
	hub.autoPlay.consumed = {}
	hub.gameClock = os.clock()
	hub.finishedAt = nil
	hub.finishTries = 0
	if hub.webhook then
		pcall(hub.webhook.snapshot)
	end
	if hub.macroState == "done" then
		hub.macroState = "idle"
	end
	if hub.settings.playMacro and hub.macros[hub.settings.macro] and not hub.rec and hub.playedRound ~= hub.round then
		hub.playedRound = hub.round
		playMacro()
	end
end

local function onLevelFinished()
	hub.finishedAt = os.clock()
	hub.finishTries = 0
	if hub.webhook then
		task.spawn(function()
			pcall(hub.webhook.onFinish)
		end)
	end
	stopPlayback()
	if hub.rec then
		stopRecording(#hub.rec.events > 0)
	else
		setStatus("Level finished")
	end
end

local dungeon = {
	names = { ["0"] = "Curse", ["1"] = "Shop", ["2"] = "Money", ["3"] = "Gold Chest", ["4"] = "Chest", ["5"] = "Final Boss", ["6"] = "Open Chests", ["7"] = "Shrine" },
	baseScore = { ["0"] = -4, ["1"] = 3, ["2"] = 3, ["3"] = 6, ["4"] = 4, ["5"] = 0, ["6"] = 2, ["7"] = 1 },
	roomOptions = { "Gold Chest", "Chest", "Money", "Shop", "Open Chests", "Shrine", "Curse" },
	chestDepths = { "5", "10", "15", "20 (last room)" },
	items = {
		{ "chest_mock_item", "Treasure Chest", "+1 Treasure Chest", 200 },
		{ "cloak", "Nimble Cloak", "-7% Attack Cooldown", 200 },
		{ "sword1", "Dagger", "+15% Attack", 200 },
		{ "bow1", "Bow", "+20% Range", 200 },
		{ "belt", "Ninja Belt", "-12% Attack Cooldown", 300 },
		{ "sword2", "Sword", "+30% Attack", 300 },
		{ "bow2", "Longbow", "+30% Range", 300 },
		{ "hook", "Fishhook", "+20% Chest Luck", 300 },
		{ "gold_branch", "Golden Branch", "-15% Placement/Upgrade Cost", 300 },
		{ "icebane", "Ice Dagger", "-20% Enemy Speed", 300 },
		{ "axe", "Axe", "+50% Phys Crit Chance", 300 },
		{ "mage_coat", "Mage Coat", "+50% Magic Damage", 300 },
		{ "scythe", "Reaper Scythe", "+75% Boss Damage", 300 },
		{ "boots", "Speedy Boots", "-20% Attack Cooldown", 500 },
		{ "sword3", "Scimitar", "+75% Attack", 500 },
		{ "bow3", "Elf Bow", "+50% Range", 500 },
		{ "hook2", "Golden Fishhook", "+40% Chest Luck", 500 },
		{ "gold_shroom", "Golden Mushroom", "-30% Placement/Upgrade Cost", 500 },
		{ "tome", "Magic Tome", "+100% Magic Damage", 500 },
		{ "fire_axe", "Headsplitter", "+75% Physical Damage", 500 },
		{ "frost_axe", "Glacial Axe", "-30% Enemy Speed", 500 },
		{ "gold_mask", "Mask of Riches", "-50% Placement/Upgrade Cost", 1000 },
		{ "genie_lamp", "Genie Lamp", "+100% Chest Luck", 1000 },
		{ "deathcap", "Archmage's Hat", "+250% Magic Damage", 1000 },
		{ "stormbringer", "Stormbringer", "-50% Attack Cooldown", 1000 },
		{ "hammer_legendary", "Aureus Maul", "+200% Physical Damage", 1000 },
		{ "axe_legendary", "Solar Cleaver", "+100% Phys Crit Chance", 1000 },
		{ "celestial_blade", "Celestial Blade", "+777% True Damage", 1000 },
		{ "bow_legendary", "Sylvanthorn", "+150% Range", 1000 },
		{ "moon_fragment", "Moon Fragment", "+1 Star Remnant per Chest", 1000 },
		{ "philospher_stone", "Philosopher's Stone", "All Chests become Rare", 1000 },
	},
	nextAction = 0,
	tried = {},
	state = "Off",
	text = "",
}

function dungeon.itemLabel(entry)
	return string.format("%s: %s (%d)", entry[2], entry[3], entry[4])
end

function dungeon.itemByLabel(label)
	for _, entry in ipairs(dungeon.items) do
		if dungeon.itemLabel(entry) == label then
			return entry
		end
	end
	return nil
end

function dungeon.itemById(id)
	for _, entry in ipairs(dungeon.items) do
		if entry[1] == id then
			return entry
		end
	end
	return nil
end

function dungeon.core()
	if dungeon.coreTable then
		return dungeon.coreTable
	end
	dungeon.coreTable = hub.gcFind("dungeonCore", { "ITEMS", "TYPES", "NUM_ROOMS" }, function(value)
		return rawget(value, "ITEMS") ~= nil and rawget(value, "TYPES") ~= nil and rawget(value, "NUM_ROOMS") ~= nil
	end, 20)
	return dungeon.coreTable
end

function dungeon.data()
	local session = gameSession()
	local data = session and session.profile_data and session.profile_data.dungeon_data
	return type(data) == "table" and data or nil
end

function dungeon.inDungeonLevel()
	if dungeon.levelFlag == nil then
		local ok, flag = pcall(function()
			local data = require(ReplicatedStorage.src.Loader).LevelData
			if type(data) ~= "table" then
				return nil
			end
			return data._dungeon ~= nil
		end)
		if ok and flag ~= nil then
			dungeon.levelFlag = flag
		end
		return ok and flag == true
	end
	return dungeon.levelFlag
end

function dungeon.setOf(list)
	local set = {}
	for _, value in ipairs(type(list) == "table" and list or {}) do
		set[value] = true
	end
	return set
end

function dungeon.roomTypes(room)
	local list = {}
	if type(room) == "table" and type(room._t) == "table" then
		for typeId in pairs(room._t) do
			table.insert(list, dungeon.names[tostring(typeId)] or tostring(typeId))
		end
	end
	table.sort(list)
	return list
end

function dungeon.order()
	local list = type(hub.settings.dungeonOrder) == "table" and hub.settings.dungeonOrder or {}
	if #list == 0 and type(hub.settings.dungeonPrefer) == "table" and #hub.settings.dungeonPrefer > 0 then
		list = table.clone(hub.settings.dungeonPrefer)
		hub.settings.dungeonOrder = list
	end
	return list
end

function dungeon.roomScore(room)
	if type(room) ~= "table" or type(room._t) ~= "table" then
		return nil
	end
	local order = dungeon.order()
	local rank = {}
	for index, name in ipairs(order) do
		rank[name] = index
	end
	local avoid = dungeon.setOf(hub.settings.dungeonAvoid)
	local score = 0
	for typeId in pairs(room._t) do
		local key = tostring(typeId)
		local name = dungeon.names[key]
		score += (dungeon.baseScore[key] or 0) * 0.5
		if name and rank[name] then
			score += (#order - rank[name] + 1) * 25
		end
		if name and avoid[name] then
			score -= 1000
		end
	end
	local level = type(room._l) == "table" and room._l or nil
	if level and tonumber(level._lobby_difficulty_scale) then
		score -= (tonumber(level._lobby_difficulty_scale) - 1) * 5
	end
	return score
end

function dungeon.pickRoom(data)
	local best, bestScore = nil, nil
	local rooms = type(data.next) == "table" and data.next or {}
	for index = 1, 3 do
		local room = rooms[tostring(index)]
		local score = dungeon.roomScore(room)
		if score then
			local follow = rooms["next" .. index]
			local bestNext = nil
			if type(follow) == "table" then
				for inner = 1, 3 do
					local value = dungeon.roomScore(follow[tostring(inner)])
					if value and (not bestNext or value > bestNext) then
						bestNext = value
					end
				end
			end
			score += (bestNext or 0) * 0.2
			if not bestScore or score > bestScore then
				best, bestScore = tostring(index), score
			end
		end
	end
	return best
end

function dungeon.completedDepth(data)
	if data._finished then
		return 20
	end
	local first = type(data.next) == "table" and data.next["1"]
	local nextDepth = first and tonumber(first._d)
	return nextDepth and (nextDepth - 1) or 0
end

function dungeon.shopPriceMultiplier(data)
	local core = dungeon.core()
	local extra = 0
	if core then
		pcall(function()
			extra = core.sum_item_values(data, "shop_prices")
		end)
	end
	return math.max(0, 1 + extra)
end

function dungeon.openChests()
	for _ = 1, 80 do
		local fresh = dungeon.data()
		local left = fresh and type(fresh._resources) == "table" and fresh._resources or {}
		local goldLeft, normalLeft = tonumber(left.treasure_gold) or 0, tonumber(left.treasure) or 0
		local useGold = hub.settings.dungeonOpenGold and goldLeft > 0
		if not useGold and normalLeft <= 0 then
			return
		end
		dungeon.state = string.format("Opening chests (%d + %d gold left)", normalLeft, goldLeft)
		local before = useGold and goldLeft or normalLeft
		invoke("dungeon_open_chest", useGold or nil)
		local untilTime = os.clock() + 3
		local now = before
		repeat
			task.wait(0.1)
			local check = dungeon.data()
			local counts = check and type(check._resources) == "table" and check._resources or {}
			now = tonumber(useGold and counts.treasure_gold or counts.treasure) or 0
		until now < before or os.clock() > untilTime
		if now >= before then
			return
		end
		task.wait(0.3)
	end
end

function dungeon.handleShop(data, shop)
	local kind = tostring(shop._t)
	local resources = type(data._resources) == "table" and data._resources or {}
	local depth = dungeon.completedDepth(data)
	if kind == "1" then
		local want = dungeon.setOf(hub.settings.dungeonBuy)
		local money = tonumber(resources.money) or 0
		local multiplier = dungeon.shopPriceMultiplier(data)
		for index, offer in pairs(type(shop.data) == "table" and shop.data or {}) do
			local entry = type(offer) == "table" and dungeon.itemById(offer.id)
			local key = tostring(depth) .. ":" .. tostring(index) .. ":" .. tostring(offer and offer.id)
			if entry and want[entry[1]] and not dungeon.tried[key] then
				local cost = math.ceil(entry[4] * multiplier)
				if money >= cost then
					dungeon.tried[key] = true
					invoke("dungeon_buy_shop", index)
					dungeon.state = "Bought " .. entry[2] .. " for " .. cost
					dungeon.nextAction = os.clock() + 1.5
					return
				end
			end
		end
		dungeon.state = "Leaving the shop"
		invoke("dungeon_continue_shop")
	elseif kind == "6" then
		local depths = dungeon.setOf(hub.settings.dungeonChestDepths)
		local openHere = depths[tostring(depth)] or (depth >= 20 and depths["20 (last room)"])
		local normal = tonumber(resources.treasure) or 0
		local gold = tonumber(resources.treasure_gold) or 0
		if dungeon.opening then
			dungeon.nextAction = os.clock() + 0.5
			return
		end
		if openHere and ((hub.settings.dungeonOpenGold and gold > 0) or normal > 0) then
			dungeon.opening = true
			task.spawn(function()
				pcall(dungeon.openChests)
				dungeon.opening = false
				dungeon.nextAction = os.clock() + 1
			end)
			dungeon.nextAction = os.clock() + 0.5
			return
		end
		dungeon.state = openHere and "All chests opened" or ("Keeping chests for later (depth " .. depth .. ")")
		invoke("dungeon_continue_shop")
	elseif kind == "7" then
		if hub.settings.dungeonShrine then
			dungeon.state = "Accepting the shrine"
			invoke("dungeon_shrine_accept")
		else
			dungeon.state = "Skipping the shrine"
			invoke("dungeon_continue_shop")
		end
	else
		invoke("dungeon_continue_shop")
	end
	dungeon.nextAction = os.clock() + 2
end

function dungeon.tick(inLevel)
	if os.clock() < dungeon.nextAction then
		return
	end
	dungeon.nextAction = os.clock() + 2
	local data = dungeon.data()
	if not data then
		dungeon.state = "Waiting for Dungeon data"
		return
	end
	if data._dead then
		dungeon.state = "Run ended at depth " .. tostring(type(data._dead) == "table" and data._dead.depth_reached or "?")
		invoke("dungeon_continue_death")
		dungeon.nextAction = os.clock() + 4
		return
	end
	local shop = type(data.current_shops) == "table" and data.current_shops[1]
	if shop then
		dungeon.handleShop(data, shop)
		return
	end
	if not data._started then
		if inLevel then
			dungeon.state = "Run finished, go back to the lobby to start another"
			return
		end
		if itemCount("dungeon_key") <= 0 then
			dungeon.state = "No Dungeon Key to start a run"
			dungeon.nextAction = os.clock() + 10
			return
		end
		dungeon.state = "Starting a new Dungeon run"
		invoke("dungeon_start")
		dungeon.nextAction = os.clock() + 4
		return
	end
	local choice = nil
	local selected = type(data.selected_next) == "table" and data.selected_next or nil
	if selected and selected.choice_str then
		local lives = tonumber(selected.lives) or 5
		if inLevel and lives < 5 then
			if not hub.settings.dungeonRetry or lives <= 1 then
				dungeon.state = "Lost this room, " .. lives .. " lives left. Retry is off or lives are low"
				dungeon.nextAction = os.clock() + 10
				return
			end
		end
		choice = tostring(selected.choice_str)
	else
		choice = dungeon.pickRoom(data)
	end
	if not choice then
		dungeon.state = "No room to enter"
		return
	end
	local room = type(data.next) == "table" and data.next[choice]
	dungeon.state = "Entering room " .. choice .. " (" .. table.concat(dungeon.roomTypes(room), ", ") .. ")"
	invoke("dungeon_enter_room", choice)
	dungeon.nextAction = os.clock() + 15
end

function dungeon.statusText()
	local data = dungeon.data()
	local lines = { "State: " .. dungeon.state }
	if data and data._started then
		local resources = type(data._resources) == "table" and data._resources or {}
		local selected = type(data.selected_next) == "table" and data.selected_next or nil
		local itemNames = {}
		local core = dungeon.core()
		for _, item in pairs(type(data._items) == "table" and data._items or {}) do
			local entry = dungeon.itemById(item.id)
			local coreItem = core and core.ITEMS and core.ITEMS[item.id]
			table.insert(itemNames, entry and entry[2] or (coreItem and coreItem.name) or tostring(item.id))
		end
		table.insert(lines, string.format("Depth: %d/20 | Money: %s | Chests: %s + %s gold", dungeon.completedDepth(data) + 1, tostring(resources.money or 0), tostring(resources.treasure or 0), tostring(resources.treasure_gold or 0)))
		if selected then
			table.insert(lines, string.format("Chosen room: %s | Lives: %s/5", tostring(selected.choice_str), tostring(selected.lives)))
		end
		local pick = dungeon.pickRoom(data)
		local rooms = type(data.next) == "table" and data.next or {}
		local options = {}
		for index = 1, 3 do
			local room = rooms[tostring(index)]
			if room then
				table.insert(options, index .. ": " .. table.concat(dungeon.roomTypes(room), "+") .. (pick == tostring(index) and " (pick)" or ""))
			end
		end
		if #options > 0 then
			table.insert(lines, "Next rooms: " .. table.concat(options, " | "))
		end
		if #itemNames > 0 then
			table.insert(lines, "Items: " .. table.concat(itemNames, ", "))
		end
	elseif data then
		table.insert(lines, "No run in progress | Keys: " .. tostring(itemCount("dungeon_key")))
	end
	return table.concat(lines, "\n")
end

local lobbyPlan = {
	modes = { "Challenge", "Summer Hunt", "Dungeon", "Infinity Mansion", "Portal", "Auto Join" },
	ordinals = { "1st", "2nd", "3rd", "4th", "5th", "6th" },
	mansionState = "Off",
	mansionNext = 0,
	mansionHardFails = 0,
	knownRewards = { "StarFruitEpic", "StarFruit", "StarFruitGreen", "StarFruitRed", "StarFruitPink", "StarFruitBlue" },
	knownMerchant = { "StarFruit", "StarFruitGreen", "StarFruitRed", "StarFruitPink", "StarFruitBlue", "StarFruitEpic", "star_remnant" },
	labels = {},
	names = {},
	teamTries = {},
	nextChallenge = 0,
	nextMerchant = 0,
	nextTeam = 0,
	nextStart = 0,
	merchantState = "Off",
	challengeState = "Off",
}
hub.lobbyPlan = lobbyPlan

function lobbyPlan.order()
	local order, seen = {}, {}
	for _, name in ipairs(type(hub.settings.lobbyOrder) == "table" and hub.settings.lobbyOrder or {}) do
		if table.find(lobbyPlan.modes, name) and not seen[name] then
			seen[name] = true
			table.insert(order, name)
		end
	end
	for _, name in ipairs(lobbyPlan.modes) do
		if not seen[name] then
			local joinAt = table.find(order, "Auto Join")
			if joinAt and name ~= "Auto Join" then
				table.insert(order, joinAt, name)
			else
				table.insert(order, name)
			end
		end
	end
	return order
end

function lobbyPlan.setSlot(slot, name)
	local order = lobbyPlan.order()
	local from = table.find(order, name)
	if not from or order[slot] == name then
		return
	end
	order[slot], order[from] = name, order[slot]
	setFlag("lobbyOrder", order)
	if ui.refreshOrder then
		pcall(ui.refreshOrder)
	end
end

function lobbyPlan.itemName(id)
	id = tostring(id)
	if lobbyPlan.names[id] then
		return lobbyPlan.names[id]
	end
	local ok, name = pcall(function()
		local items = require(ReplicatedStorage.src.Data.Items)
		return items[id] and items[id].name
	end)
	local label = (ok and type(name) == "string" and name ~= "") and name or id
	lobbyPlan.names[id] = label
	lobbyPlan.labels[label] = id
	return label
end

function lobbyPlan.optionList(known, seenKey)
	local labels, seen = {}, {}
	for _, list in ipairs({ known, type(hub.settings[seenKey]) == "table" and hub.settings[seenKey] or {} }) do
		for _, id in ipairs(list) do
			local label = lobbyPlan.itemName(id)
			if not seen[label] then
				seen[label] = true
				table.insert(labels, label)
			end
		end
	end
	table.sort(labels)
	return labels
end

function lobbyPlan.labelsFor(ids)
	local list = {}
	for _, id in ipairs(type(ids) == "table" and ids or {}) do
		table.insert(list, lobbyPlan.itemName(id))
	end
	return list
end

function lobbyPlan.idsFrom(value)
	local list = {}
	for label, on in pairs(type(value) == "table" and value or {}) do
		if on then
			table.insert(list, lobbyPlan.labels[label] or label)
		end
	end
	table.sort(list)
	return list
end

function lobbyPlan.learn(seenKey, known, id)
	if type(id) ~= "string" or id == "" or table.find(known, id) then
		return false
	end
	local list = type(hub.settings[seenKey]) == "table" and hub.settings[seenKey] or {}
	if table.find(list, id) then
		return false
	end
	local copy = table.clone(list)
	table.insert(copy, id)
	setFlag(seenKey, copy)
	return true
end

function lobbyPlan.rewardIds(data)
	local ids = {}
	local reward = type(data) == "table" and type(data.current_reward) == "table" and data.current_reward or {}
	for _, entry in ipairs(type(reward._show_rewards) == "table" and reward._show_rewards or {}) do
		local id = type(entry) == "table" and type(entry.params) == "table" and entry.params.item_id
		if type(id) == "string" then
			table.insert(ids, id)
		end
	end
	return ids
end

function lobbyPlan.challengeData()
	if os.clock() >= lobbyPlan.nextChallenge then
		lobbyPlan.nextChallenge = os.clock() + 60
		local data = invoke("get_normal_challenge")
		if type(data) == "table" and data.current_uuid then
			lobbyPlan.challenge = data
			local learned = false
			for _, id in ipairs(lobbyPlan.rewardIds(data)) do
				if lobbyPlan.learn("challengeSeen", lobbyPlan.knownRewards, id) then
					learned = true
				end
			end
			if learned and ui.refreshRewardPicker then
				pcall(ui.refreshRewardPicker)
			end
		end
	end
	return lobbyPlan.challenge
end

function lobbyPlan.skip(uuid)
	uuid = tonumber(uuid)
	if uuid and tonumber(hub.settings.challengeSkip) ~= uuid then
		setFlag("challengeSkip", uuid)
	end
end

function lobbyPlan.challengeReady()
	if not hub.settings.autoChallenge then
		lobbyPlan.challengeState = "Off"
		return false
	end
	local session = gameSession()
	if not (session and type(session.profile_data) == "table") then
		lobbyPlan.challengeState = "Waiting for your data"
		return false
	end
	local done = session.profile_data.last_completed_challenge_uuid
	if not workspace:FindFirstChild("_CHALLENGES") then
		local uuid = math.floor(os.time() / 1800)
		if tonumber(hub.settings.challengeSkip) == uuid or tostring(done) == tostring(uuid) then
			lobbyPlan.challengeState = "Next one in " .. tostring(math.ceil(((uuid + 1) * 1800 - os.time()) / 60)) .. " min"
			return false
		end
		lobbyPlan.challengeState = "New challenge is up"
		return true
	end
	local data = lobbyPlan.challengeData()
	if type(data) ~= "table" then
		lobbyPlan.challengeState = "Waiting for challenge data"
		return false
	end
	local rewards = lobbyPlan.labelsFor(lobbyPlan.rewardIds(data))
	local title = tostring(data.current_challenge or "?") .. " | " .. table.concat(rewards, ", ")
	if done ~= nil and tostring(done) == tostring(data.current_uuid) then
		lobbyPlan.skip(data.current_uuid)
		lobbyPlan.challengeState = "Cleared, waiting for the next one | " .. title
		return false
	end
	local try = type(hub.settings.challengeTry) == "table" and hub.settings.challengeTry or {}
	if tonumber(try.uuid) == tonumber(data.current_uuid) and (tonumber(try.count) or 0) >= 2 then
		lobbyPlan.skip(data.current_uuid)
		lobbyPlan.challengeState = "Failed twice, waiting for the next one | " .. title
		return false
	end
	local wanted = type(hub.settings.challengeRewards) == "table" and hub.settings.challengeRewards or {}
	if #wanted > 0 then
		local match = false
		for _, id in ipairs(lobbyPlan.rewardIds(data)) do
			if table.find(wanted, id) then
				match = true
			end
		end
		if not match then
			lobbyPlan.skip(data.current_uuid)
			lobbyPlan.challengeState = "Skipped, rewards not picked | " .. title
			return false
		end
	end
	lobbyPlan.challengeState = "Ready | " .. title
	return true
end

function lobbyPlan.loadouts()
	local session = gameSession()
	local list = session and session.profile_data and session.profile_data.loadouts_v2
	return type(list) == "table" and list or {}
end

function lobbyPlan.teamSlots()
	local ok, count = pcall(function()
		return require(ReplicatedStorage.src.Data.GameplaySettings).NUM_TEAM_SLOTS
	end)
	count = ok and tonumber(count) or 0
	for key in pairs(lobbyPlan.loadouts()) do
		count = math.max(count, tonumber(key) or 0)
	end
	return count > 0 and count or 5
end

function lobbyPlan.loadout(index)
	local list = lobbyPlan.loadouts()
	local entry = list[tostring(index)] or list[tonumber(index)]
	return type(entry) == "table" and entry or nil
end

function lobbyPlan.teamLabel(index)
	local entry = lobbyPlan.loadout(index)
	local name = entry and type(entry.name) == "string" and entry.name ~= "" and entry.name or nil
	return tostring(index) .. (name and (" · " .. name) or "")
end

function lobbyPlan.teamOptions()
	local options = { "Don't change" }
	for index = 1, lobbyPlan.teamSlots() do
		table.insert(options, lobbyPlan.teamLabel(index))
	end
	return options
end

function lobbyPlan.teamUnits(index)
	local entry = lobbyPlan.loadout(index)
	local saved = entry and type(entry.saved_equipped) == "table" and entry.saved_equipped or {}
	local session = gameSession()
	local slots = {}
	for key, uuid in pairs(saved) do
		table.insert(slots, { slot = tonumber(key) or 0, uuid = uuid })
	end
	table.sort(slots, function(a, b)
		return a.slot < b.slot
	end)
	local names = {}
	for _, item in ipairs(slots) do
		local unitId = nil
		pcall(function()
			local unit = session.collection:get_unit_by_uuid(item.uuid)
			unitId = unit and unit.unit_id
		end)
		table.insert(names, unitId and unitName(unitId) or "?")
	end
	return names
end

function lobbyPlan.equipped()
	local session = gameSession()
	local ok, equipped = pcall(function()
		return session.collection.collection_profile_data.equipped_units
	end)
	return ok and type(equipped) == "table" and equipped or nil
end

function lobbyPlan.teamMatches(index)
	local entry = lobbyPlan.loadout(index)
	local equipped = lobbyPlan.equipped()
	if not entry or type(entry.saved_equipped) ~= "table" or not equipped then
		return nil
	end
	local want, have = {}, {}
	for key, uuid in pairs(entry.saved_equipped) do
		want[tostring(key)] = tostring(uuid)
	end
	for key, uuid in pairs(equipped) do
		have[tostring(key)] = tostring(uuid)
	end
	for key, uuid in pairs(want) do
		if have[key] ~= uuid then
			return false
		end
	end
	for key in pairs(have) do
		if not want[key] then
			return false
		end
	end
	return true
end

function lobbyPlan.currentTeam()
	for index = 1, lobbyPlan.teamSlots() do
		if lobbyPlan.teamMatches(index) then
			return index
		end
	end
	return nil
end

function lobbyPlan.useTeam(mode)
	local choice = type(hub.settings.modeTeams) == "table" and hub.settings.modeTeams[mode]
	local index = tonumber(choice)
	if not index then
		return true
	end
	local entry = lobbyPlan.loadout(index)
	if not entry or type(entry.saved_equipped) ~= "table" or next(entry.saved_equipped) == nil then
		return true
	end
	local matches = lobbyPlan.teamMatches(index)
	if matches ~= false then
		lobbyPlan.teamTries[index] = 0
		return true
	end
	if (lobbyPlan.teamTries[index] or 0) >= 3 then
		return true
	end
	if os.clock() < lobbyPlan.nextTeam then
		return false
	end
	lobbyPlan.nextTeam = os.clock() + 3
	lobbyPlan.teamTries[index] = (lobbyPlan.teamTries[index] or 0) + 1
	invoke("load_team_loadout", tostring(index))
	setStatus("Team " .. lobbyPlan.teamLabel(index) .. " for " .. mode)
	return false
end

function lobbyPlan.levelMode(levelId)
	local ok, mode = pcall(function()
		local data = require(ReplicatedStorage.src.Data.Levels)[levelId]
		if type(data) ~= "table" then
			return nil
		end
		local copy = table.clone(data)
		copy.id = copy.id or levelId
		return autoPlay.modeOf(copy)
	end)
	return ok and mode or "Story"
end

function lobbyPlan.lobbyMode(levelMode)
	if levelMode == "Challenge" or levelMode == "Summer Hunt" or levelMode == "Dungeon" then
		return levelMode
	end
	if levelMode == "Infinite Tower" then
		return "Infinity Mansion"
	end
	if levelMode == "Portal" then
		return "Portal"
	end
	return "Auto Join"
end

function lobbyPlan.dungeonRunning()
	local data = dungeon.data()
	return data ~= nil and (data._started or data._dead or (type(data.current_shops) == "table" and data.current_shops[1] ~= nil)) and true or false
end

function lobbyPlan.pick()
	if hub.settings.autoDungeon and lobbyPlan.dungeonRunning() then
		return "Dungeon"
	end
	for _, mode in ipairs(lobbyPlan.order()) do
		if mode == "Challenge" and lobbyPlan.challengeReady() then
			return mode
		elseif mode == "Summer Hunt" and hub.settings.autoSummerHunt and (eventTeam.partyMember() or eventTeam.joinCheck()) then
			return mode
		elseif mode == "Dungeon" and hub.settings.autoDungeon and itemCount("dungeon_key") > 0 then
			return mode
		elseif mode == "Infinity Mansion" and hub.settings.autoMansion then
			return mode
		elseif mode == "Portal" and hub.settings.autoNextPortal and (hub.portal.lobby() or hub.portal.pick(nil)) then
			return mode
		elseif mode == "Auto Join" and hub.settings.autoJoin then
			return mode
		end
	end
	return nil
end

function lobbyPlan.leaveFor(levelMode)
	if not hub.settings.autoChallenge or levelMode == "Dungeon" then
		return false
	end
	if levelMode == "Challenge" then
		return true
	end
	if not lobbyPlan.challengeReady() then
		return false
	end
	local order = lobbyPlan.order()
	return (table.find(order, "Challenge") or 9) < (table.find(order, lobbyPlan.lobbyMode(levelMode)) or 9)
end

function lobbyPlan.challengeLobbies()
	local root = workspace:FindFirstChild("_CHALLENGES")
	local folder = root and root:FindFirstChild("Challenges")
	return folder and folder:GetChildren() or {}
end

function lobbyPlan.insideLobby(lobby)
	local owner = lobby:FindFirstChild("Owner")
	if owner and owner.Value == LocalPlayer then
		return true
	end
	local players = lobby:FindFirstChild("Players")
	for _, entry in ipairs(players and players:GetChildren() or {}) do
		if entry.Name == LocalPlayer.Name or (entry:IsA("ObjectValue") and entry.Value == LocalPlayer) then
			return true
		end
	end
	return false
end

function lobbyPlan.joinChallenge()
	for _, lobby in ipairs(lobbyPlan.challengeLobbies()) do
		if lobbyPlan.insideLobby(lobby) then
			local teleporting = lobby:FindFirstChild("Teleporting")
			local timer = lobby:FindFirstChild("Timer")
			if teleporting and teleporting.Value then
				setStatus("Challenge: teleporting")
			elseif os.clock() >= lobbyPlan.nextStart then
				lobbyPlan.nextStart = os.clock() + 5
				invoke("request_start_game", lobby.Name)
				setStatus("Challenge: starting" .. ((timer and tonumber(timer.Value) or -1) >= 0 and (" in " .. tostring(timer.Value)) or ""))
			end
			return
		end
	end
	if hub.joining or os.clock() < lobbyPlan.nextStart then
		return
	end
	hub.joining = true
	task.spawn(function()
		local joined = false
		for _, lobby in ipairs(lobbyPlan.challengeLobbies()) do
			if lobbyFree(lobby) then
				pcall(function()
					local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
					local pad = lobby:FindFirstChild("Teleport") or lobby:FindFirstChild("primary")
					if root and pad then
						root.CFrame = pad.CFrame + Vector3.new(0, 3, 0)
					end
				end)
				task.wait(0.8)
				if invoke("request_join_lobby", lobby.Name) then
					joined = true
					lobbyPlan.nextStart = os.clock() + 1.5
					setStatus("Challenge: joined " .. lobby.Name)
				end
				break
			end
		end
		if not joined then
			lobbyPlan.nextStart = os.clock() + 5
			setStatus("Challenge: no free lobby, retrying")
		end
		hub.joining = false
	end)
end

function lobbyPlan.leaveChallengeLobby()
	for _, lobby in ipairs(lobbyPlan.challengeLobbies()) do
		local teleporting = lobby:FindFirstChild("Teleporting")
		if lobbyPlan.insideLobby(lobby) and not (teleporting and teleporting.Value) then
			invoke("request_leave_lobby", lobby.Name)
		end
	end
end

function lobbyPlan.mansionReached()
	local session = gameSession()
	local data = session and type(session.profile_data) == "table" and type(session.profile_data.level_data) == "table" and session.profile_data.level_data.infinite_tower
	return type(data) == "table" and math.max(tonumber(data.floor_reached) or 1, 1) or 1
end

function lobbyPlan.mansionDifficulty(room)
	if room > 100 then
		return "Hard"
	end
	if hub.settings.mansionDifficulty == "Hard" and lobbyPlan.mansionHardFails < 3 then
		return "Hard"
	end
	return "Normal"
end

function lobbyPlan.mansionLevel()
	local ok, room, difficulty = pcall(function()
		local data = require(ReplicatedStorage.src.Loader).LevelData
		return tonumber(data._infinite_tower_floor), data._difficulty
	end)
	if ok then
		return room, difficulty
	end
	return nil, nil
end

function lobbyPlan.mansionTick()
	if lobbyPlan.mansionBusy or os.clock() < lobbyPlan.mansionNext then
		return
	end
	lobbyPlan.mansionNext = os.clock() + 12
	local room = lobbyPlan.mansionReached()
	local difficulty = lobbyPlan.mansionDifficulty(room)
	lobbyPlan.mansionBusy = true
	lobbyPlan.mansionState = string.format("Starting Room %d (%s)", room, difficulty)
	setStatus("Infinity Mansion: starting Room " .. room .. " (" .. difficulty .. ")")
	task.spawn(function()
		invoke("request_start_infinite_tower", room, difficulty)
		task.wait(10)
		if hub.alive and not gameState() then
			if difficulty == "Hard" and room <= 100 then
				lobbyPlan.mansionHardFails += 1
			end
			lobbyPlan.mansionState = string.format("Room %d (%s) did not start, retrying", room, difficulty)
		end
		lobbyPlan.mansionBusy = false
	end)
end

function lobbyPlan.merchantTick()
	if not hub.settings.autoMerchant then
		lobbyPlan.merchantState = "Off"
		return
	end
	if lobbyPlan.buying or os.clock() < lobbyPlan.nextMerchant then
		return
	end
	lobbyPlan.nextMerchant = os.clock() + 20
	local folder = workspace:FindFirstChild("travelling_merchant")
	local open = folder and folder:FindFirstChild("is_open")
	if not (open and open.Value) then
		lobbyPlan.merchantState = "Merchant is away"
		return
	end
	lobbyPlan.buying = true
	task.spawn(function()
		local items = invoke("poll_active_items")
		local session = gameSession()
		local bought = session and type(session.profile_data.bought_items) == "table" and session.profile_data.bought_items or {}
		local wanted = type(hub.settings.merchantItems) == "table" and hub.settings.merchantItems or {}
		local learned, selling, got = false, {}, {}
		local moved = false
		local done = {}
		for _, key in ipairs(type(hub.settings.merchantDone) == "table" and hub.settings.merchantDone or {}) do
			if type(items) == "table" and items[key] then
				done[key] = true
			end
		end
		for key, offer in pairs(type(items) == "table" and items or {}) do
			if type(offer) == "table" and type(offer.id) == "string" then
				if lobbyPlan.learn("merchantSeen", lobbyPlan.knownMerchant, offer.id) then
					learned = true
				end
				if not (bought[key] or done[key]) then
					table.insert(selling, lobbyPlan.itemName(offer.id))
				end
				if table.find(wanted, offer.id) and not bought[key] and not done[key] then
					local cost = tonumber(offer.gem_cost) or 0
					if statValue("gem_amount") - cost >= (tonumber(hub.settings.keepGems) or 0) then
						if not moved then
							moved = true
							pcall(function()
								local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
								local area = folder.stand:FindFirstChild("area")
								if root and area then
									root.CFrame = area.CFrame + Vector3.new(0, 3, 0)
								end
							end)
							task.wait(1)
						end
						local gems = statValue("gem_amount")
						done[key] = true
						invoke("buy_travelling_merchant_item", key, "1")
						local untilTime = os.clock() + 3
						while statValue("gem_amount") >= gems and os.clock() < untilTime do
							task.wait(0.2)
						end
						if statValue("gem_amount") < gems or cost <= 0 then
							table.insert(got, lobbyPlan.itemName(offer.id))
						end
					end
				end
			end
		end
		local keep = {}
		for key in pairs(done) do
			table.insert(keep, key)
		end
		table.sort(keep)
		if type(items) == "table" and table.concat(keep, "|") ~= table.concat(type(hub.settings.merchantDone) == "table" and hub.settings.merchantDone or {}, "|") then
			setFlag("merchantDone", keep)
		end
		if learned and ui.refreshMerchantPicker then
			pcall(ui.refreshMerchantPicker)
		end
		if #got > 0 then
			setStatus("Merchant: bought " .. table.concat(got, ", "))
			lobbyPlan.merchantState = "Bought " .. table.concat(got, ", ")
		else
			lobbyPlan.merchantState = "Open: " .. (#selling > 0 and table.concat(selling, ", ") or "nothing left")
		end
		lobbyPlan.buying = false
	end)
end

hub.portal = { state = "Off", nextOpen = 0, nextStart = 0, cacheAt = 0, cache = {}, namesKey = "" }

function hub.portal.items()
	if os.clock() - hub.portal.cacheAt < 2 then
		return hub.portal.cache
	end
	local session = gameSession()
	if not session then
		return {}
	end
	local list = {}
	local ok = pcall(function()
		local items = require(ReplicatedStorage.src.Data.Items)
		local levels = require(ReplicatedStorage.src.Data.Levels)
		for _, entry in pairs(session.inventory.inventory_profile_data.unique_items) do
			local data = type(entry) == "table" and items[entry.item_id]
			if type(data) == "table" and data.item_group == "Portals" and type(data.usage) == "table" and data.usage.type == "open_portal" then
				local extra = type(entry._unique_item_data) == "table" and entry._unique_item_data or {}
				local portalData = type(extra._unique_portal_data) == "table" and extra._unique_portal_data or {}
				local levelId = data.usage.level_id
				if data._unique_portal then
					levelId = portalData.level_id
				end
				local group = nil
				if type(data.static_portal_copy_to_level_params) == "table" then
					group = data.static_portal_copy_to_level_params.portal_group
				elseif levelId and type(levels[levelId]) == "table" then
					group = levels[levelId].portal_group
				end
				local maxTries = tonumber(extra._portal_max_tries) or tonumber(data._portal_max_tries) or 1
				table.insert(list, {
					uuid = entry.uuid,
					name = tostring(data.name or entry.item_id),
					group = group,
					left = maxTries - (tonumber(extra._portal_tries) or 0),
					created = tonumber(entry._creation_time) or 0,
				})
			end
		end
	end)
	if not ok then
		return {}
	end
	hub.portal.cache = list
	hub.portal.cacheAt = os.clock()
	return list
end

function hub.portal.pick(group, skipUuid)
	local names = type(hub.settings.portalNames) == "table" and hub.settings.portalNames or {}
	local best = nil
	for _, item in ipairs(hub.portal.items()) do
		if item.left > 0 and item.uuid ~= skipUuid and table.find(names, item.name) and (group == nil or item.group == group) then
			if not best or item.left < best.left or (item.left == best.left and item.created < best.created) then
				best = item
			end
		end
	end
	return best
end

function hub.portal.names()
	local seen, list = {}, {}
	for _, item in ipairs(hub.portal.items()) do
		if not seen[item.name] then
			seen[item.name] = true
			table.insert(list, item.name)
		end
	end
	for _, name in ipairs(type(hub.settings.portalNames) == "table" and hub.settings.portalNames or {}) do
		if not seen[name] then
			seen[name] = true
			table.insert(list, name)
		end
	end
	table.sort(list)
	return list
end

function hub.portal.levelData()
	local ok, data = pcall(function()
		return require(ReplicatedStorage.src.Loader).LevelData
	end)
	if ok and type(data) == "table" and data._is_map_or_portal_level and data.portal_group then
		return data
	end
	return nil
end

function hub.portal.finishPlan()
	local data = hub.portal.levelData()
	if not data then
		return nil
	end
	if tonumber(data._owner_player_userid) ~= LocalPlayer.UserId then
		hub.portal.state = "Not the portal host, waiting for the host"
		return nil
	end
	if hub.portal.voted == hub.finishedAt and os.clock() - (hub.portal.votedAt or 0) < 30 then
		return "Do Nothing"
	end
	if hub.portal.pick(data.portal_group, data._portal_map_item_uuid) then
		return "Next Portal"
	end
	hub.portal.state = "No picked portal of this kind left, going to lobby"
	return "Back To Lobby"
end

function hub.portal.lobby()
	local root = workspace:FindFirstChild("_PORTALS")
	local folder = root and root:FindFirstChild("Lobbies")
	for _, lobby in ipairs(folder and folder:GetChildren() or {}) do
		local owner = lobby:FindFirstChild("Owner")
		local level = lobby:FindFirstChild("Level")
		if owner and owner.Value == LocalPlayer and not (level and level.Value == eventTeam.level) then
			return lobby
		end
	end
	return nil
end

function hub.portal.lobbyTick()
	local lobby = hub.portal.lobby()
	if lobby then
		local teleporting = lobby:FindFirstChild("Teleporting")
		if teleporting and teleporting.Value then
			hub.portal.state = "Teleporting to the portal"
			if hub.status ~= "Teleporting to the portal" then
				setStatus("Teleporting to the portal")
			end
			return
		end
		if os.clock() >= hub.portal.nextStart then
			hub.portal.nextStart = os.clock() + 5
			invoke("request_start_game", lobby.Name)
			hub.portal.state = "Starting the portal"
			setStatus("Starting the portal")
		end
		return
	end
	if os.clock() < hub.portal.nextOpen then
		return
	end
	local item = hub.portal.pick(nil)
	if not item then
		hub.portal.state = "No picked portal in your items"
		return
	end
	hub.portal.nextOpen = os.clock() + 10
	hub.portal.nextStart = os.clock() + 2
	hub.portal.cacheAt = 0
	invoke("use_portal", item.uuid)
	hub.portal.state = "Opened " .. item.name .. " (" .. item.left .. " tries left)"
	setStatus("Opened " .. item.name)
end

function lobbyPlan.lobbyTick(myLobby)
	local session = gameSession()
	if not (session and type(session.profile_data) == "table" and type(session.profile_data.loadouts_v2) == "table" and lobbyPlan.equipped()) then
		lobbyPlan.current = nil
		if hub.status ~= "Loading your data" then
			setStatus("Loading your data")
		end
		return
	end
	lobbyPlan.merchantTick()
	if lobbyPlan.buying then
		return
	end
	pcall(eventTeam.shopTick)
	if eventTeam.partyMember() and eventTeam.inEventLobby() then
		lobbyPlan.current = "Summer Hunt (party)"
		lobbyPlan.useTeam("Summer Hunt")
		if hub.status ~= "Summer Hunt party: in the host's room" then
			setStatus("Summer Hunt party: in the host's room")
		end
		return
	end
	local pick = lobbyPlan.pick()
	lobbyPlan.current = pick
	if pick ~= "Summer Hunt" then
		if eventTeam.matching and eventTeam.requested then
			eventTeam.leaveQueue()
		end
		local room = hub.settings.autoSummerHunt and eventTeam.roomSince and eventTeam.ownedRoom()
		if room and not (room:FindFirstChild("Teleporting") and room.Teleporting.Value) then
			invoke("request_leave_lobby", room.Name)
			eventTeam.roomSince = nil
		end
	end
	if pick and pick ~= "Challenge" and not hub.joining then
		lobbyPlan.leaveChallengeLobby()
	end
	if pick and pick ~= "Auto Join" and myLobby and not hub.joining then
		local teleporting = myLobby:FindFirstChild("Teleporting")
		if not (teleporting and teleporting.Value) then
			hub.lobbyName = myLobby.Name
			leaveLobby()
		end
	end
	local character = LocalPlayer.Character
	if not (character and character:FindFirstChild("HumanoidRootPart")) then
		return
	end
	if pick == "Challenge" then
		if lobbyPlan.useTeam("Challenge") then
			lobbyPlan.joinChallenge()
		end
	elseif pick == "Summer Hunt" then
		if eventTeam.matching or lobbyPlan.useTeam("Summer Hunt") then
			eventTeam.lobbyTick()
		end
	elseif pick == "Dungeon" then
		if lobbyPlan.useTeam("Dungeon") then
			dungeon.tick(false)
		end
	elseif pick == "Infinity Mansion" then
		if lobbyPlan.useTeam("Infinite Tower") then
			lobbyPlan.mansionTick()
		end
	elseif pick == "Portal" then
		if lobbyPlan.useTeam("Portal") then
			hub.portal.lobbyTick()
		end
	elseif pick == "Auto Join" then
		local inLobby = LocalPlayer:FindFirstChild("AlreadyInLobby")
		if hub.settings.autoStart and myLobby and os.clock() >= (hub.nextStart or 0) then
			hub.nextStart = os.clock() + 5
			startLobby()
		end
		if not hub.joining and os.clock() >= (hub.joinPauseUntil or 0) and not (hub.settings.autoSummon and os.clock() < hub.summon.busyUntil) then
			if inLobby and inLobby.Value then
				if hub.settings.autoStart and hub.joinedAt > 0 and os.clock() - hub.joinedAt > 45 then
					leaveLobby()
					setStatus("Lobby timed out, retrying")
				end
			elseif lobbyPlan.useTeam(lobbyPlan.levelMode(hub.settings.level)) then
				task.spawn(joinLobby)
			end
		end
	else
		if hub.settings.autoDungeon and lobbyPlan.useTeam("Dungeon") then
			dungeon.tick(false)
		end
		if hub.settings.autoStart and myLobby and os.clock() >= (hub.nextStart or 0) then
			hub.nextStart = os.clock() + 5
			startLobby()
		end
	end
end

function lobbyPlan.refreshUi()
	if hub.settings.autoChallenge and os.clock() >= lobbyPlan.nextChallenge then
		lobbyPlan.challengeReady()
	end
	local texts = {
		{ "challengeLabel", hub.settings.autoChallenge and lobbyPlan.challengeState or "Off" },
		{ "merchantLabel", hub.settings.autoMerchant and lobbyPlan.merchantState or "Off" },
		{ "mansionLabel", hub.settings.autoMansion and lobbyPlan.mansionState or "Off" },
		{ "portalLabel", hub.settings.autoNextPortal and hub.portal.state or "Off" },
		{ "summerLabel", hub.settings.autoSummerHunt and eventTeam.state or "Off" },
		{ "summerShopLabel", (hub.settings.summerClaimBingo or hub.settings.summerBuyStars) and eventTeam.shopState or "Off" },
		{ "summerProgressLabel", eventTeam.progressText() },
		{ "priorityLabel", lobbyPlan.current and ("Now: " .. lobbyPlan.current) or "Idle" },
	}
	for _, pair in ipairs(texts) do
		local label = ui[pair[1]]
		if label and lobbyPlan[pair[1]] ~= pair[2] then
			lobbyPlan[pair[1]] = pair[2]
			pcall(function()
				label:UpdateName(pair[2])
			end)
		end
	end
	if ui.refreshTeams and os.clock() >= (lobbyPlan.nextTeamUi or 0) then
		lobbyPlan.nextTeamUi = os.clock() + 5
		ui.refreshTeams()
	end
	if ui.refreshPortalPicker and os.clock() >= (hub.portal.nextNames or 0) then
		hub.portal.nextNames = os.clock() + 10
		local key = table.concat(hub.portal.names(), "|")
		if key ~= hub.portal.namesKey then
			hub.portal.namesKey = key
			pcall(ui.refreshPortalPicker)
		end
	end
end

hub.webhook = { state = "Off", sent = 0, labels = { gem_amount = "Gems", gold_amount = "Gold", player_xp = "XP", trophies = "Trophies" } }

function hub.webhook.comma(value)
	local number = math.floor((tonumber(value) or 0) + 0.5)
	local text = tostring(math.abs(number))
	local formatted = text:reverse():gsub("(%d%d%d)", "%1,"):reverse()
	if formatted:sub(1, 1) == "," then
		formatted = formatted:sub(2)
	end
	return (number < 0 and "-" or "") .. formatted
end

function hub.webhook.statName(key)
	if hub.webhook.labels[key] then
		return hub.webhook.labels[key]
	end
	return (key:gsub("^_resource", ""):gsub("(%l)(%u)", "%1 %2"))
end

function hub.webhook.stats()
	local out = {}
	local stats = LocalPlayer:FindFirstChild("_stats")
	for _, value in ipairs(stats and stats:GetChildren() or {}) do
		local key = value.Name
		local tracked = hub.webhook.labels[key] or (key:sub(1, 9) == "_resource" and not key:find("Legacy", 1, true))
		if tracked and value:IsA("ValueBase") then
			local number = tonumber(value.Value)
			if number and number == number and math.abs(number) < 1e15 then
				out[key] = number
			end
		end
	end
	return out
end

hub.slotWorth = { labels = {} }

function hub.slotWorth.unit(uuid)
	local session = gameSession()
	if not (session and uuid) then
		return nil
	end
	local ok, unit = pcall(function()
		return session.collection:get_unit_by_uuid(uuid)
	end)
	return ok and type(unit) == "table" and unit or nil
end

function hub.slotWorth.values(unit)
	return math.floor(tonumber(unit.total_takedowns) or 0), math.floor(tonumber(unit.stat_luck) or 0)
end

function hub.slotWorth.teamValues()
	local out = {}
	local equipped = lobbyPlan.equipped()
	for slot = 1, 6 do
		local uuid = equipped and (equipped[tostring(slot)] or equipped[slot])
		local unit = uuid and hub.slotWorth.unit(uuid)
		if unit then
			local kills, worth = hub.slotWorth.values(unit)
			out[uuid] = { kills, worth }
		end
	end
	return out
end

function hub.slotWorth.clear()
	for label in pairs(hub.slotWorth.labels) do
		pcall(function()
			label:Destroy()
		end)
	end
	table.clear(hub.slotWorth.labels)
end

hub.slotWorth.styles = { "Pill", "Side chips", "Worth bar", "Minimal" }

function hub.slotWorth.stroke(parent, color, transparency, thickness, border)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Transparency = transparency
	stroke.Thickness = thickness
	if border then
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	end
	stroke.Parent = parent
	return stroke
end

function hub.slotWorth.box(parent, name, anchor, position, size, radius, transparency)
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.AnchorPoint = anchor
	frame.Position = position
	frame.Size = size
	frame.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
	frame.BackgroundTransparency = transparency
	frame.BorderSizePixel = 0
	frame.ZIndex = 5
	local corner = Instance.new("UICorner")
	corner.CornerRadius = radius
	corner.Parent = frame
	frame.Parent = parent
	return frame
end

function hub.slotWorth.text(parent, name, anchor, position, size, maxSize, alignment)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.BackgroundTransparency = 1
	label.AnchorPoint = anchor
	label.Position = position
	label.Size = size
	label.Font = Enum.Font.FredokaOne
	label.TextScaled = true
	label.RichText = true
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextXAlignment = alignment or Enum.TextXAlignment.Center
	label.ZIndex = 7
	local limit = Instance.new("UITextSizeConstraint")
	limit.MaxTextSize = maxSize
	limit.Parent = label
	label.Parent = parent
	return label
end

function hub.slotWorth.make(slot, style)
	local center = Vector2.new(0.5, 0.5)
	local root = Instance.new("Frame")
	root.Name = "OrderWorthPill"
	root.BackgroundTransparency = 1
	root.Size = UDim2.new(1, 0, 1, 0)
	root.ZIndex = 5
	root:SetAttribute("style", style)
	root:SetAttribute("layout", 2)
	if style == "Side chips" then
		local white = Color3.fromRGB(255, 255, 255)
		local kills = hub.slotWorth.box(root, "KillsChip", Vector2.new(0, 1), UDim2.new(0.05, 0, 0.6, 0), UDim2.new(0.53, 0, 0.14, 0), UDim.new(0, 4), 0.25)
		hub.slotWorth.stroke(kills, white, 0.85, 1, true)
		hub.slotWorth.text(kills, "Kills", center, UDim2.new(0.5, 0, 0.5, 0), UDim2.new(1, -4, 1, -2), 12)
		local worth = hub.slotWorth.box(root, "WorthChip", Vector2.new(1, 1), UDim2.new(0.95, 0, 0.6, 0), UDim2.new(0.36, 0, 0.14, 0), UDim.new(0, 4), 0.25)
		hub.slotWorth.stroke(worth, Color3.fromRGB(255, 210, 74), 0.55, 1, true)
		hub.slotWorth.text(worth, "Worth", center, UDim2.new(0.5, 0, 0.5, 0), UDim2.new(1, -4, 1, -2), 12)
	elseif style == "Worth bar" then
		local bar = hub.slotWorth.box(root, "Bar", Vector2.new(0.5, 1), UDim2.new(0.5, 0, 0.6, 0), UDim2.new(0.9, 0, 0.14, 0), UDim.new(0, 4), 0.2)
		hub.slotWorth.stroke(bar, Color3.fromRGB(255, 255, 255), 0.85, 1, true)
		local fill = Instance.new("Frame")
		fill.Name = "Fill"
		fill.BackgroundColor3 = Color3.fromRGB(255, 210, 74)
		fill.BackgroundTransparency = 0.35
		fill.BorderSizePixel = 0
		fill.Size = UDim2.new(0, 0, 1, 0)
		fill.ZIndex = 6
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 4)
		corner.Parent = fill
		fill.Parent = bar
		local label = hub.slotWorth.text(bar, "Text", center, UDim2.new(0.5, 0, 0.5, 0), UDim2.new(1, -6, 1, -2), 12)
		hub.slotWorth.stroke(label, Color3.fromRGB(0, 0, 0), 0.2, 1)
	elseif style == "Minimal" then
		local label = hub.slotWorth.text(root, "Text", Vector2.new(0.5, 1), UDim2.new(0.5, 0, 0.6, 0), UDim2.new(0.96, 0, 0.16, 0), 14)
		hub.slotWorth.stroke(label, Color3.fromRGB(0, 0, 0), 0, 1.5)
	else
		local pill = hub.slotWorth.box(root, "Pill", Vector2.new(0.5, 1), UDim2.new(0.5, 0, 0.6, 0), UDim2.new(0.88, 0, 0.15, 0), UDim.new(1, 0), 0.3)
		hub.slotWorth.stroke(pill, Color3.fromRGB(255, 255, 255), 0.82, 1, true)
		hub.slotWorth.text(pill, "Text", center, UDim2.new(0.5, 0, 0.5, 0), UDim2.new(1, -8, 1, -3), 13)
	end
	root.Parent = slot
	hub.slotWorth.labels[root] = true
	return root
end

function hub.slotWorth.set(label, text)
	if label and label.Text ~= text then
		label.Text = text
	end
end

function hub.slotWorth.fill(root, style, kills, worth)
	local shown = kills >= 10000 and hub.webhook.short(kills) or hub.webhook.comma(kills)
	if style == "Side chips" then
		hub.slotWorth.set(root:FindFirstChild("Kills", true), string.format("<font color=\"#9A9A9A\">K</font> %s", shown))
		hub.slotWorth.set(root:FindFirstChild("Worth", true), string.format("<font color=\"#FFD24A\">%d%%</font>", worth))
	elseif style == "Worth bar" then
		local fill = root:FindFirstChild("Fill", true)
		if fill then
			fill.Size = UDim2.new(math.clamp(worth / 100, 0, 1), 0, 1, 0)
			fill.BackgroundColor3 = worth >= 100 and Color3.fromRGB(80, 210, 110) or Color3.fromRGB(255, 210, 74)
		end
		hub.slotWorth.set(root:FindFirstChild("Text", true), string.format("K %s  ·  %d%%", shown, worth))
	elseif style == "Minimal" then
		hub.slotWorth.set(root:FindFirstChild("Text", true), string.format("<font color=\"#BDBDBD\">K</font> %s  <font color=\"#FFD24A\">%d%%</font>", shown, worth))
	else
		hub.slotWorth.set(root:FindFirstChild("Text", true), string.format("<font color=\"#9A9A9A\">K</font> %s  <font color=\"#9A9A9A\">W</font> <font color=\"#FFD24A\">%d%%</font>", shown, worth))
	end
end

function hub.slotWorth.refresh()
	if not hub.settings.slotWorth then
		if next(hub.slotWorth.labels) then
			hub.slotWorth.clear()
		end
		return
	end
	local gui = LocalPlayer:FindFirstChild("PlayerGui")
	local spawnUnits = gui and gui:FindFirstChild("spawn_units")
	local lives = spawnUnits and spawnUnits:FindFirstChild("Lives")
	local frame = lives and lives:FindFirstChild("Frame")
	local units = frame and frame:FindFirstChild("Units")
	if not units then
		return
	end
	for _, slot in ipairs(units:GetChildren()) do
		if slot:IsA("GuiObject") then
			local uuid = slot:GetAttribute("_equipped_frame_unit_uuid")
			local unit = type(uuid) == "string" and uuid ~= "" and hub.slotWorth.unit(uuid)
			local stale = slot:FindFirstChild("OrderWorth")
			if stale then
				stale:Destroy()
			end
			local pill = slot:FindFirstChild("OrderWorthPill")
			local style = table.find(hub.slotWorth.styles, hub.settings.slotStyle) and hub.settings.slotStyle or "Worth bar"
			if pill and (pill:GetAttribute("style") ~= style or pill:GetAttribute("layout") ~= 2) then
				hub.slotWorth.labels[pill] = nil
				pill:Destroy()
				pill = nil
			end
			if unit then
				pill = pill or hub.slotWorth.make(slot, style)
				local kills, worth = hub.slotWorth.values(unit)
				hub.slotWorth.fill(pill, style, kills, worth)
			elseif pill then
				hub.slotWorth.labels[pill] = nil
				pill:Destroy()
			end
		end
	end
end

hub.autoExec = { state = "Off", loader = "https://api.luarmor.net/files/v4/loaders/d5f45d24c7f98a18797eaee42a60981e.lua" }

function hub.autoExec.setState(text)
	hub.autoExec.state = text
	if ui.autoExecLabel then
		pcall(function()
			ui.autoExecLabel:UpdateName(text)
		end)
	end
end

function hub.autoExec.queueFunction()
	local candidates = {}
	pcall(function()
		table.insert(candidates, queue_on_teleport)
	end)
	pcall(function()
		table.insert(candidates, queueonteleport)
	end)
	pcall(function()
		table.insert(candidates, syn.queue_on_teleport)
	end)
	pcall(function()
		table.insert(candidates, fluxus.queue_on_teleport)
	end)
	for _, candidate in pairs(candidates) do
		if type(candidate) == "function" then
			return candidate
		end
	end
	return nil
end

function hub.autoExec.source()
	local lines = {
		"if not game:IsLoaded() then game.Loaded:Wait() end",
		"local env = getgenv and getgenv() or _G",
		"if env.OrderHubAutoExec then return end",
		"local players = game:GetService(\"Players\")",
		"while not players.LocalPlayer do task.wait() end",
		"local enabled = true",
		"pcall(function()",
		"\tlocal data = game:GetService(\"HttpService\"):JSONDecode(readfile(\"Order Hub/Anime Adventure/configs/\" .. players.LocalPlayer.Name .. \".json\"))",
		"\tif type(data) == \"table\" and type(data.settings) == \"table\" and data.settings.autoExec == false then enabled = false end",
		"end)",
		"if not enabled then return end",
		"env.OrderHubAutoExec = true",
	}
	local key = rawget(genv, "script_key")
	if type(key) == "string" and key:match("^[%w_]+$") then
		table.insert(lines, "script_key = \"" .. key .. "\"")
		table.insert(lines, "env.script_key = \"" .. key .. "\"")
	end
	table.insert(lines, "pcall(function() loadstring(game:HttpGet(\"" .. hub.autoExec.loader .. "\"))() end)")
	return table.concat(lines, "\n")
end

function hub.autoExec.queue()
	genv.OrderHubAutoExec = true
	if not hub.settings.autoExec then
		hub.autoExec.setState(hub.autoExec.queued and "Off (already queued, skips on next server)" or "Off")
		return
	end
	if hub.autoExec.queued or genv.OrderHubQueuedJob == game.JobId then
		hub.autoExec.queued = true
		hub.autoExec.setState("Ready for next teleport")
		return
	end
	local queue = hub.autoExec.queueFunction()
	if not queue then
		hub.autoExec.setState("Executor has no queue_on_teleport")
		return
	end
	local ok, err = pcall(queue, hub.autoExec.source())
	hub.autoExec.queued = ok
	if ok then
		genv.OrderHubQueuedJob = game.JobId
	end
	hub.autoExec.setState(ok and "Ready for next teleport" or ("Failed: " .. tostring(err)))
end

function hub.webhook.snapshot()
	hub.webhook.start = { stats = hub.webhook.stats(), clock = os.clock(), job = game.JobId, worth = hub.slotWorth.teamValues() }
	hub.webhook.sentRound = nil
end

function hub.webhook.validUrl(url)
	url = tostring(url or "")
	return url:match("^https://discord%.com/api/webhooks/%d+/[%w_%-]+$") ~= nil
		or url:match("^https://discordapp%.com/api/webhooks/%d+/[%w_%-]+$") ~= nil
		or url:match("^https://%a+%.discord%.com/api/webhooks/%d+/[%w_%-]+$") ~= nil
end

function hub.webhook.setState(text)
	hub.webhook.state = text
	if ui.webhookLabel then
		pcall(function()
			ui.webhookLabel:UpdateName(text)
		end)
	end
end

function hub.webhook.short(value)
	local number = tonumber(value) or 0
	for _, step in ipairs({ { 1e12, "T" }, { 1e9, "B" }, { 1e6, "M" }, { 1e3, "K" } }) do
		if number >= step[1] then
			return string.format("%.1f%s", number / step[1], step[2])
		end
	end
	return hub.webhook.comma(number)
end

function hub.webhook.clock(seconds)
	seconds = math.floor(tonumber(seconds) or 0)
	if seconds >= 3600 then
		return string.format("%d:%02d:%02d", seconds // 3600, seconds % 3600 // 60, seconds % 60)
	end
	return string.format("%d:%02d", seconds // 60, seconds % 60)
end

function hub.webhook.difficulty()
	local gui = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("ResultsUI")
	local holder = gui and gui.Enabled and gui:FindFirstChild("Holder")
	local label = holder and holder:FindFirstChild("Difficulty")
	if label and label:IsA("TextLabel") and label.Visible and label.Text ~= "" then
		return label.Text
	end
	return nil
end

function hub.webhook.itemLabel(id)
	id = tostring(id)
	local name = lobbyPlan.itemName(id)
	if name ~= id then
		return name
	end
	return (id:gsub("__MOCK$", ""):gsub("_", " "):gsub("(%a)(%w*)", function(first, rest)
		return first:upper() .. rest
	end))
end

function hub.webhook.unitLabel(key, entry)
	local id = entry
	if type(entry) == "table" then
		id = entry.unit_id or entry.id or entry[1]
	elseif type(entry) ~= "string" then
		id = key
	end
	local name = id and unitName(id) or "New unit"
	if type(entry) == "table" and (entry.shiny or entry._shiny) then
		name = "Shiny " .. name
	end
	return name
end

function hub.webhook.logo()
	return nil
end

function hub.webhook.session(result, farm)
	local session = type(hub.settings.webhookSession) == "table" and hub.settings.webhookSession or nil
	farm = tostring(farm or "Story")
	if not session or not tonumber(session.runs) or session.farm ~= farm or os.time() - (tonumber(session.last) or 0) > 1200 then
		session = { runs = 0, wins = 0, losses = 0, last = os.time(), farm = farm }
	end
	if type(result) == "table" then
		session.runs += 1
		if result.victory == false then
			session.losses += 1
		else
			session.wins += 1
		end
		session.last = os.time()
		setFlag("webhookSession", session)
	end
	return session
end

function hub.webhook.rerolls()
	local session = gameSession()
	local value = session and type(session.profile_data) == "table" and session.profile_data.trait_reroll_tokens
	return tonumber(value) or 0
end

function hub.webhook.levelName()
	local ok, name = pcall(function()
		local data = require(ReplicatedStorage.src.Loader).LevelData
		return type(data) == "table" and (data.name or data.id) or nil
	end)
	return ok and type(name) == "string" and name ~= "" and name or "Level"
end

function hub.webhook.rewardLines(result, gains, now)
	local lines = {}
	local comma = hub.webhook.comma
	local function add(amount, label, total)
		amount = tonumber(amount) or 0
		if amount >= 1 then
			table.insert(lines, "+" .. comma(amount) .. " " .. label .. (total and (" [" .. comma(total) .. "]") or ""))
		end
	end
	if type(result) ~= "table" then
		for _, gain in ipairs(gains) do
			add(gain.diff, gain.name)
		end
		return lines
	end
	for key, entry in pairs(type(result.new_units) == "table" and result.new_units or {}) do
		table.insert(lines, "+1 " .. hub.webhook.unitLabel(key, entry) .. " (new unit)")
	end
	add(result.gem_reward, "Gems", now.gem_amount)
	add(result.gold_reward, "Gold", now.gold_amount)
	add(result.trophy_reward, "Trophies", now.trophies)
	add(result.xp_reward, "XP")
	local resources = type(result.resource_reward) == "table" and result.resource_reward or {}
	local keys = {}
	for key in pairs(resources) do
		if not tostring(key):find("Legacy", 1, true) then
			table.insert(keys, tostring(key))
		end
	end
	table.sort(keys)
	for _, key in ipairs(keys) do
		add(resources[key], hub.webhook.statName("_resource" .. key), now["_resource" .. key])
	end
	for _, item in ipairs(type(result.new_items) == "table" and result.new_items or {}) do
		if type(item) == "table" and item.item_id then
			local total = not tostring(item.item_id):find("MOCK", 1, true) and itemCount(item.item_id) or nil
			add(item.amount or 1, hub.webhook.itemLabel(item.item_id), total and total > 0 and total or nil)
		end
	end
	if result.first_completion then
		table.insert(lines, "+ First clear bonus")
	end
	return lines
end

function hub.webhook.teamLines()
	local lines = {}
	local session = gameSession()
	local equipped = lobbyPlan.equipped()
	if not (session and equipped) then
		return lines
	end
	if type(hub.traitData) ~= "table" then
		local ok, data = pcall(require, ReplicatedStorage.src.Data.Traits)
		hub.traitData = ok and data or nil
	end
	for slot = 1, 6 do
		local uuid = equipped[tostring(slot)] or equipped[slot]
		if uuid then
			pcall(function()
				local unit = session.collection:get_unit_by_uuid(uuid)
				if type(unit) ~= "table" or not unit.unit_id then
					return
				end
				local traits = {}
				for _, trait in pairs(type(unit.traits) == "table" and unit.traits or {}) do
					local id = type(trait) == "table" and trait.trait or trait
					local info = type(hub.traitData) == "table" and hub.traitData[id]
					table.insert(traits, tostring(type(info) == "table" and info.name or id))
				end
				local kills, worth = hub.slotWorth.values(unit)
				local before = hub.webhook.start and type(hub.webhook.start.worth) == "table" and hub.webhook.start.worth[uuid]
				local killText = "Kill " .. hub.webhook.comma(kills)
				local worthText = "Worth " .. worth .. "%"
				if before and kills > before[1] then
					killText = killText .. " (+" .. hub.webhook.comma(kills - before[1]) .. ")"
				end
				if before and worth > before[2] then
					worthText = worthText .. " (+" .. (worth - before[2]) .. "%)"
				end
				table.insert(lines, "- " .. unitName(unit.unit_id) .. (#traits > 0 and (" (" .. table.concat(traits, ", ") .. ")") or "") .. " · " .. killText .. " · " .. worthText)
			end)
		end
	end
	return lines
end

function hub.webhook.build(test, info)
	info = info or {}
	local result = not test and type(info.data) == "table" and info.data or nil
	local stats = result and type(result.stats) == "table" and result.stats or {}
	local now = info.stats or hub.webhook.stats()
	local start = info.start
	local gains = {}
	if start and not test and not result then
		for key, value in pairs(now) do
			local diff = value - (start.stats[key] or value)
			if diff >= 1 then
				table.insert(gains, { name = hub.webhook.statName(key), diff = diff })
			end
		end
		table.sort(gains, function(a, b)
			return a.name < b.name
		end)
	end
	local won = test or not result or result.victory ~= false
	local logo = hub.webhook.logo()
	local comma = hub.webhook.comma
	local balance = comma(now.gem_amount) .. " Gems · " .. comma(now.gold_amount) .. " Gold · " .. comma(hub.webhook.rerolls()) .. " Rerolls"
	local embed = {
		title = "Anime Adventure",
		color = won and 5763719 or 15548997,
		timestamp = DateTime.now():ToIsoDate(),
		fields = { { name = "👤 Name", value = "||" .. LocalPlayer.Name .. "||", inline = false } },
	}
	if test then
		table.insert(embed.fields, { name = "📊 Result", value = "Webhook connected", inline = false })
		table.insert(embed.fields, { name = "💰 Balance", value = balance, inline = false })
		local team = hub.webhook.teamLines()
		if #team > 0 then
			table.insert(embed.fields, { name = "🛡️ Team", value = table.concat(team, "\n"), inline = false })
		end
		embed.footer = { text = "Order HUB" }
	else
		local session = hub.webhook.session(result or {}, info.mode)
		local stage = result and type(result.title) == "string" and result.title ~= "" and result.title or hub.webhook.levelName()
		local tags = {}
		if (info.mode or "Story") ~= stage then
			table.insert(tags, info.mode or "Story")
		end
		if info.difficulty then
			table.insert(tags, info.difficulty)
		end
		local seconds = tonumber(stats.time_taken) or (start and (os.clock() - start.clock)) or 0
		local waves = tonumber(stats.waves_completed)
		local totalWaves = tonumber(stats.num_waves)
		local rewards = hub.webhook.rewardLines(result, gains, now)
		local lines = {
			"**" .. stage .. "**" .. (#tags > 0 and (" (" .. table.concat(tags, " · ") .. ")") or "") .. " · " .. (won and "🏆 Victory" or "💀 Defeat"),
			"- Time: " .. hub.webhook.clock(seconds),
		}
		if waves then
			table.insert(lines, "- Waves: " .. waves .. (totalWaves and totalWaves > 0 and ("/" .. totalWaves) or ""))
		end
		if stats.damage_dealt then
			table.insert(lines, "- Damage: " .. hub.webhook.short(stats.damage_dealt))
		end
		table.insert(embed.fields, { name = "📊 Result", value = table.concat(lines, "\n"), inline = false })
		table.insert(embed.fields, { name = "🎁 Reward", value = #rewards > 0 and table.concat(rewards, "\n") or "None", inline = false })
		table.insert(embed.fields, { name = "💰 Balance", value = balance, inline = false })
		local team = hub.webhook.teamLines()
		if #team > 0 then
			table.insert(embed.fields, { name = "🛡️ Team", value = table.concat(team, "\n"), inline = false })
		end
		local rate = session.runs > 0 and math.floor(session.wins / session.runs * 100 + 0.5) or 0
		embed.footer = { text = string.format("Order HUB · Run #%d · %dW %dL (%d%%)", session.runs, session.wins, session.losses, rate) }
	end
	local payload = { username = "Order HUB", avatar_url = logo, embeds = { embed } }
	local pingId = tostring(hub.settings.webhookPing or "")
	local newUnit = result and type(result.new_units) == "table" and next(result.new_units) ~= nil
	if not test and pingId:match("^%d+$") and #pingId >= 15 and (newUnit or not won) then
		payload.content = "<@" .. pingId .. ">" .. (newUnit and " New unit!" or " Defeat")
		payload.allowed_mentions = { users = { pingId } }
	end
	return payload
end

function hub.webhook.post(payload)
	local url = tostring(hub.settings.webhookUrl or "")
	if not hub.webhook.validUrl(url) then
		hub.webhook.setState("Invalid URL")
		return false
	end
	local send = request or http_request or (syn and syn.request) or (http and http.request)
	if type(send) ~= "function" then
		hub.webhook.setState("No request function")
		return false
	end
	local body = HttpService:JSONEncode(payload)
	local reply = nil
	task.spawn(function()
		reply = table.pack(pcall(send, {
			Url = url,
			Method = "POST",
			Headers = { ["Content-Type"] = "application/json" },
			Body = body,
		}))
	end)
	local untilTime = os.clock() + 15
	while not reply and os.clock() < untilTime do
		task.wait(0.1)
	end
	if not reply then
		hub.webhook.setState("Failed (timeout)")
		return false
	end
	local ok, response = reply[1], reply[2]
	local code = ok and type(response) == "table" and tonumber(response.StatusCode) or nil
	if code and code >= 200 and code < 300 then
		hub.webhook.sent += 1
		hub.webhook.setState("Sent " .. os.date("%H:%M"))
		return true
	end
	hub.webhook.setState("Failed" .. (code and (" (" .. code .. ")") or ""))
	return false
end

function hub.webhook.test()
	hub.webhook.post(hub.webhook.build(true))
end

function hub.webhook.onFinish()
	if not hub.settings.webhookOn then
		return
	end
	local key = game.JobId .. ":" .. hub.round
	if hub.webhook.sentRound == key then
		return
	end
	hub.webhook.sentRound = key
	local began = os.clock()
	local data
	repeat
		task.wait(0.25)
		local saved = hub.webhook.result
		if saved and saved.job == game.JobId and saved.at >= began - 3 then
			data = saved.data
		end
	until data or os.clock() - began > 6 or not hub.alive
	task.wait(1)
	local info = { data = data, mode = autoPlay.levelMode() or "Story", difficulty = hub.webhook.difficulty(), stats = hub.webhook.stats(), start = hub.webhook.start }
	if dungeon.inDungeonLevel() and not hub.settings.webhookDungeonRooms then
		local untilTime = os.clock() + 12
		local over = false
		repeat
			local state = dungeon.data()
			over = state ~= nil and (not lobbyPlan.dungeonRunning() or dungeon.completedDepth(state) >= 20)
			if not over then
				task.wait(1)
			end
		until over or os.clock() > untilTime or not hub.alive
		if not over then
			return
		end
	end
	if hub.alive then
		hub.webhook.post(hub.webhook.build(false, info))
	end
end

pcall(function()
	local present, started = gameState()
	if present and started and not hub.finishedAt then
		hub.webhook.snapshot()
	end
end)

local function mainTick()
	local present, started = gameState()
	if present then
		hub.lobbyName = nil
		hub.joining = false
		local flag = workspace._DATA:FindFirstChild("GameFinished")
		if flag and flag.Value and not hub.finishedAt then
			onLevelFinished()
		elseif flag and not flag.Value and hub.finishedAt and started then
			hub.finishedAt = nil
		end
		if started and (not hub.lastStarted or (hub.replayAt and os.clock() - hub.replayAt > 3)) then
			hub.replayAt = nil
			onGameStart()
		end
		if not started and os.clock() >= hub.nextVote then
			hub.nextVote = os.clock() + 3
			local voteData = workspace._DATA:FindFirstChild("VoteStart")
			local voteDone = voteData and voteData:FindFirstChild("VotingFinished")
			if hub.settings.autoVote and not (voteDone and voteDone.Value) then
				invoke("vote_start")
				setStatus("Voted to start the level")
			end
		end
		local action = hub.settings.afterFinish
		if hub.finishedAt and hub.settings.autoSummerHunt and autoPlay.levelMode() == "Summer Hunt" then
			if action ~= "Replay" or not eventTeam.levelAllowed() or eventTeam.partyMember() then
				action = "Back To Lobby"
			end
		end
		if started and not lobbyPlan.counted and autoPlay.levelMode() == "Challenge" then
			lobbyPlan.counted = true
			local uuid = math.floor(os.time() / 1800)
			local try = type(hub.settings.challengeTry) == "table" and hub.settings.challengeTry or {}
			if try.job ~= game.JobId then
				setFlag("challengeTry", { uuid = uuid, job = game.JobId, count = (tonumber(try.uuid) == uuid and (tonumber(try.count) or 0) or 0) + 1 })
			end
		end
		if hub.settings.autoMansion and autoPlay.levelMode() == "Infinite Tower" then
			local room, difficulty = lobbyPlan.mansionLevel()
			lobbyPlan.mansionState = string.format(hub.finishedAt and "Room %s (%s) finished, going on" or "In Room %s (%s)", tostring(room or "?"), tostring(difficulty or "?"))
			action = "Next Room"
		end
		if hub.finishedAt and hub.settings.autoNextPortal then
			action = hub.portal.finishPlan() or action
		end
		if hub.finishedAt and action ~= "Back To Lobby" and lobbyPlan.leaveFor(autoPlay.levelMode()) then
			action = "Back To Lobby"
		end
		if dungeon.inDungeonLevel() then
			action = "Do Nothing"
			if hub.settings.autoDungeon and hub.finishedAt and os.clock() - hub.finishedAt > 4 then
				dungeon.tick(true)
				if dungeon.data() and not dungeon.opening and not lobbyPlan.dungeonRunning() then
					action = "Back To Lobby"
				end
			end
		end
		if hub.finishedAt and action ~= "Do Nothing" and os.clock() - hub.finishedAt > 3 and os.clock() >= hub.nextFinish then
			hub.nextFinish = os.clock() + 5
			hub.finishTries += 1
			if action == "Next Story" and hub.finishTries > 3 then
				action = "Replay"
			end
			if action == "Next Portal" and hub.finishTries > 4 then
				action = "Back To Lobby"
			end
			finishAction(action)
			setStatus("Level finished, " .. action)
		end
		hub.lastStarted = started
	else
		if hub.lastStarted then
			stopPlayback()
		end
		hub.lastStarted = false
		hub.finishedAt = nil
		local myLobby = ownedLobby()
		if myLobby then
			hub.lobbyName = myLobby.Name
		end
		lobbyPlan.lobbyTick(myLobby)
	end
end

local function hubGuiParent()
	local ok, parent = pcall(function()
		return gethui()
	end)
	if ok and parent then
		return parent
	end
	ok, parent = pcall(function()
		return game:GetService("CoreGui")
	end)
	if ok and parent then
		return parent
	end
	return LocalPlayer:FindFirstChildOfClass("PlayerGui")
end

local function applyScale()
	if not ui.window then
		return
	end
	local camera = workspace.CurrentCamera
	local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
	local scaleValue = math.clamp(math.min(viewport.X / 900, viewport.Y / 620), 0.35, 1)
	if hub.settings.uiScale ~= "Auto" then
		scaleValue = (tonumber(string.match(hub.settings.uiScale, "%d+")) or 100) / 100
	end
	pcall(function()
		ui.window:SetScale(scaleValue)
	end)
end

local function createFloatingButton()
	local parent = hubGuiParent()
	if not parent then
		return
	end
	pcall(function()
		local existing = parent:FindFirstChild("AnimeAdventureHubButton")
		if existing then
			existing:Destroy()
		end
	end)
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "AnimeAdventureHubButton"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local button = Instance.new("TextButton")
	button.Size = UDim2.fromOffset(46, 46)
	button.Position = UDim2.new(0, 15, 0.5, -23)
	button.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
	button.BackgroundTransparency = 0.1
	button.BorderSizePixel = 0
	button.Text = ""
	button.AutoButtonColor = false
	button.Active = true
	button.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 14)
	corner.Parent = button

	local icon = Instance.new("ImageLabel")
	icon.AnchorPoint = Vector2.new(0.5, 0.5)
	icon.Position = UDim2.fromScale(0.5, 0.5)
	icon.Size = UDim2.new(1, -8, 1, -8)
	icon.BackgroundTransparency = 1
	icon.Image = "rbxassetid://78067731406782"
	icon.ScaleType = Enum.ScaleType.Fit
	icon.Parent = button

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(236, 118, 44)
	stroke.Thickness = 1.5
	stroke.Parent = button

	local dragging, dragStart, startPos, moved = false, nil, nil, false
	connect(button.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = button.Position
			moved = false
		end
	end)
	connect(button.InputChanged, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			if delta.Magnitude > 6 then
				moved = true
			end
			button.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	connect(button.InputEnded, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
			dragging = false
			if not moved then
				if ui.window then
					pcall(function()
						ui.window:SetState(not ui.window:GetState())
					end)
				elseif ui.reopen then
					ui.reopen()
				end
			end
		end
	end)
	screenGui.DisplayOrder = 60
	screenGui.Parent = parent
	ui.floatingGui = screenGui
end

local display = {
	orange = Color3.fromRGB(236, 118, 44),
	softOrange = Color3.fromRGB(110, 62, 30),
	icons = {
		chest = "rbxassetid://116030223007249",
		gold = "rbxassetid://131900384494075",
		key = "rbxassetid://74348422304433",
		gem = "rbxassetid://71405874061254",
		reroll = "rbxassetid://104698264984753",
		logo = "rbxassetid://78067731406782",
	},
	startedAt = os.clock(),
	nextTick = 0,
}

function display.make(className, props, parent)
	local object = Instance.new(className)
	for key, value in pairs(props) do
		object[key] = value
	end
	if parent then
		object.Parent = parent
	end
	return object
end

function display.round(object, radius)
	display.make("UICorner", { CornerRadius = UDim.new(0, radius) }, object)
end

function display.outline(object, color, thickness)
	display.make("UIStroke", { Color = color or display.softOrange, Thickness = thickness or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, object)
end

function display.short(value)
	value = tonumber(value) or 0
	if value >= 1000000 then
		return string.format("%.1fM", value / 1000000)
	elseif value >= 10000 then
		return string.format("%.1fK", value / 1000)
	end
	return tostring(math.floor(value))
end

function display.playerLevel()
	if display.levelCore == nil then
		display.levelCore = false
		pcall(function()
			display.levelCore = require(ReplicatedStorage.src.Loader).load_core_service(script, "LevelServiceCore") or false
		end)
	end
	local level = nil
	if display.levelCore then
		pcall(function()
			level = display.levelCore:calculate_level(statValue("player_xp"))
		end)
	end
	return tonumber(level)
end

function display.rerolls()
	local session = gameSession()
	local tokens = session and tonumber(session.profile_data.trait_reroll_tokens) or 0
	return tokens + itemCount("star_remnant") + itemCount("star_remnant_limited")
end

function display.dungeonInfo()
	local data = dungeon.data()
	if not data or not data._started then
		return nil
	end
	local resources = type(data._resources) == "table" and data._resources or {}
	return {
		floor = math.min(dungeon.completedDepth(data) + 1, 20),
		chests = tonumber(resources.treasure) or 0,
		gold = tonumber(resources.treasure_gold) or 0,
	}
end

function display.stats()
	local list = {}
	local run = hub.settings.autoDungeon and display.dungeonInfo() or nil
	if run then
		table.insert(list, { label = "Floor", value = run.floor .. "/20" })
		table.insert(list, { label = "Chests", value = tostring(run.chests), icon = display.icons.chest })
		table.insert(list, { label = "Gold", value = tostring(run.gold), icon = display.icons.gold })
		table.insert(list, { label = "Keys", value = tostring(itemCount("dungeon_key")), icon = display.icons.key })
	else
		local level = display.playerLevel()
		table.insert(list, { label = "Level", value = level and tostring(level) or "?" })
	end
	table.insert(list, { label = "Gems", value = display.short(statValue("gem_amount")), icon = display.icons.gem })
	table.insert(list, { label = "Rerolls", value = display.short(display.rerolls()), icon = display.icons.reroll })
	return list, run ~= nil
end

function display.stripPart(object)
	pcall(function()
		if object:IsA("Decal") or object:IsA("Texture") then
			object.Transparency = 1
		elseif object:IsA("SurfaceAppearance") then
			object:Destroy()
		elseif object:IsA("MeshPart") then
			object.TextureID = ""
			object.Material = Enum.Material.SmoothPlastic
			object.Reflectance = 0
			object.CastShadow = false
		elseif object:IsA("SpecialMesh") then
			object.TextureId = ""
		elseif object:IsA("BasePart") then
			object.Material = Enum.Material.SmoothPlastic
			object.Reflectance = 0
			object.CastShadow = false
		elseif object:IsA("ParticleEmitter") or object:IsA("Trail") or object:IsA("Smoke") or object:IsA("Fire") or object:IsA("Sparkles") or object:IsA("Beam") then
			object.Enabled = false
		elseif object:IsA("PostEffect") or object:IsA("Atmosphere") or object:IsA("Clouds") then
			pcall(function()
				object.Enabled = false
			end)
			if object:IsA("Atmosphere") then
				object.Density = 0
			end
		end
	end)
end

function display.setFast(enabled)
	display.fastOn = enabled == true
	if display.fastConn then
		pcall(function()
			display.fastConn:Disconnect()
		end)
		display.fastConn = nil
	end
	if not display.fastOn then
		if setfpscap then
			pcall(setfpscap, 60)
		end
		return
	end
	pcall(function()
		local lighting = game:GetService("Lighting")
		lighting.GlobalShadows = false
		lighting.FogEnd = 9e9
		for _, effect in ipairs(lighting:GetChildren()) do
			display.stripPart(effect)
		end
	end)
	pcall(function()
		local terrain = workspace:FindFirstChildOfClass("Terrain")
		if terrain then
			terrain.WaterWaveSize = 0
			terrain.WaterWaveSpeed = 0
			terrain.WaterReflectance = 0
			terrain.WaterTransparency = 0
			if sethiddenproperty then
				sethiddenproperty(terrain, "Decoration", false)
			end
		end
	end)
	pcall(function()
		settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
	end)
	pcall(function()
		settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04
	end)
	if setfpscap then
		pcall(setfpscap, hub.isMobile() and 60 or 240)
	end
	display.fastConn = workspace.DescendantAdded:Connect(function(object)
		if display.fastOn then
			display.stripPart(object)
		end
	end)
	task.spawn(function()
		for index, object in ipairs(workspace:GetDescendants()) do
			if not display.fastOn or not hub.alive then
				return
			end
			display.stripPart(object)
			if index % 800 == 0 then
				task.wait()
			end
		end
	end)
end

function display.statCard(parent, order)
	local card = display.make("Frame", { Size = UDim2.fromOffset(118, 74), BackgroundColor3 = Color3.fromRGB(16, 16, 16), LayoutOrder = order }, parent)
	display.round(card, 10)
	display.outline(card)
	local icon = display.make("ImageLabel", { Size = UDim2.fromOffset(26, 26), Position = UDim2.new(0.5, -13, 0, 8), BackgroundTransparency = 1, ScaleType = Enum.ScaleType.Fit }, card)
	local value = display.make("TextLabel", { Size = UDim2.new(1, -8, 0, 22), Position = UDim2.new(0, 4, 0, 34), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 18, TextColor3 = Color3.new(1, 1, 1), Text = "" }, card)
	local label = display.make("TextLabel", { Size = UDim2.new(1, -8, 0, 14), Position = UDim2.new(0, 4, 0, 55), BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = Color3.fromRGB(150, 150, 150), Text = "" }, card)
	local function noIcon(hidden)
		value.Position = UDim2.new(0, 4, 0, hidden and 14 or 34)
		value.Size = UDim2.new(1, -8, 0, hidden and 36 or 22)
		value.TextSize = hidden and 26 or 18
	end
	return { frame = card, icon = icon, value = value, label = label, noIcon = noIcon }
end

function display.fillCards(holder, cards, list, builder)
	for index, stat in ipairs(list) do
		local card = cards[index]
		if not card then
			card = builder(holder, index)
			cards[index] = card
		end
		card.frame.Visible = true
		card.value.Text = stat.value
		card.label.Text = string.upper(stat.label)
		card.icon.Image = stat.icon or ""
		card.icon.Visible = stat.icon ~= nil
		if card.noIcon then
			card.noIcon(stat.icon == nil)
		end
	end
	for index = #list + 1, #cards do
		cards[index].frame.Visible = false
	end
end

function display.buildBlack()
	local parent = hubGuiParent()
	if not parent then
		return
	end
	local screen = display.make("ScreenGui", { Name = "AnimeAdventureBlackScreen", IgnoreGuiInset = true, ResetOnSpawn = false, DisplayOrder = 30, ZIndexBehavior = Enum.ZIndexBehavior.Sibling })
	local cover = display.make("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(6, 6, 6), BorderSizePixel = 0, Active = true }, screen)
	display.make("UIGradient", { Rotation = 90, Color = ColorSequence.new(Color3.fromRGB(22, 14, 9), Color3.fromRGB(4, 4, 4)) }, cover)
	local column = display.make("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.47), Size = UDim2.fromOffset(760, 420), BackgroundTransparency = 1 }, cover)
	display.make("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }, column)
	display.make("ImageLabel", { Size = UDim2.fromOffset(104, 104), BackgroundTransparency = 1, Image = display.icons.logo, ScaleType = Enum.ScaleType.Fit, LayoutOrder = 1 }, column)
	display.make("TextLabel", { Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, Font = Enum.Font.GothamBlack, TextSize = 36, TextColor3 = Color3.new(1, 1, 1), Text = "ORDER HUB", LayoutOrder = 2 }, column)
	display.make("TextLabel", { Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, TextSize = 15, TextColor3 = Color3.fromRGB(150, 150, 150), Text = "Anime Adventure", LayoutOrder = 3 }, column)
	local bar = display.make("Frame", { Size = UDim2.fromOffset(64, 3), BackgroundColor3 = display.orange, BorderSizePixel = 0, LayoutOrder = 4 }, column)
	display.round(bar, 2)
	local statusBox = display.make("Frame", { Size = UDim2.fromOffset(420, 40), BackgroundColor3 = Color3.fromRGB(14, 14, 14), LayoutOrder = 5 }, column)
	display.round(statusBox, 10)
	display.outline(statusBox)
	local dot = display.make("Frame", { Size = UDim2.fromOffset(8, 8), Position = UDim2.new(0, 14, 0.5, -4), BackgroundColor3 = display.orange, BorderSizePixel = 0 }, statusBox)
	display.round(dot, 4)
	local statusMain = display.make("TextLabel", { Size = UDim2.new(1, -44, 1, 0), Position = UDim2.new(0, 30, 0, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 15, TextColor3 = Color3.new(1, 1, 1), TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Text = "" }, statusBox)
	local row = display.make("Frame", { Size = UDim2.new(1, 0, 0, 74), BackgroundTransparency = 1, LayoutOrder = 6 }, column)
	display.make("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center, Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }, row)
	local footer = display.make("TextLabel", { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -18), Size = UDim2.new(1, -40, 0, 16), BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Color3.fromRGB(90, 90, 90), Text = "" }, cover)
	local scale = display.make("UIScale", { Scale = 1 }, column)
	display.black = { gui = screen, statusMain = statusMain, dot = dot, row = row, cards = {}, footer = footer, scale = scale }
	local ok = pcall(function()
		screen.Parent = parent
	end)
	if not ok then
		screen.Parent = LocalPlayer:FindFirstChildOfClass("PlayerGui")
	end
end

function display.setBlack(enabled)
	pcall(function()
		game:GetService("RunService"):Set3dRenderingEnabled(not enabled)
	end)
	if display.black then
		pcall(function()
			display.black.gui:Destroy()
		end)
		display.black = nil
	end
	if enabled then
		display.buildBlack()
		display.nextTick = 0
	end
end

function display.uptime()
	local total = math.floor(os.clock() - display.startedAt)
	local hours = math.floor(total / 3600)
	local minutes = math.floor(total % 3600 / 60)
	if hours > 0 then
		return string.format("%dh %02dm", hours, minutes)
	end
	return string.format("%dm %02ds", minutes, total % 60)
end

function display.activity(inDungeon)
	local present, started = gameState()
	local text = nil
	if present and started and hub.settings.autoPlay then
		text = tostring(autoPlay.state)
	elseif inDungeon then
		text = tostring(dungeon.state)
	elseif hub.settings.playMacro then
		text = "Playing macro"
	else
		text = present and "In game" or "Lobby"
	end
	text = string.gsub(text, " %(slot %d+%)", "")
	text = string.gsub(text, ", waiting for money ", "  \u{00B7}  ")
	return text
end

function display.refreshBlack()
	local black = display.black
	if not black or not black.gui.Parent then
		return
	end
	local list, inDungeon = display.stats()
	black.statusMain.Text = display.activity(inDungeon)
	display.fillCards(black.row, black.cards, list, display.statCard)
	black.dot.BackgroundTransparency = (math.floor(os.clock() * 2) % 2 == 0) and 0 or 0.6
	black.footer.Text = display.uptime()
	local camera = workspace.CurrentCamera
	if camera then
		local size = camera.ViewportSize
		black.scale.Scale = math.clamp(math.min(size.X / 820, size.Y / 560), 0.5, 1.2)
	end
end

function display.hudCard(parent, order)
	local card = display.make("Frame", { Size = UDim2.fromOffset(0, 34), AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = Color3.fromRGB(14, 14, 14), BackgroundTransparency = 0.12, LayoutOrder = order }, parent)
	display.round(card, 9)
	display.outline(card)
	display.make("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 10) }, card)
	display.make("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, card)
	local icon = display.make("ImageLabel", { Size = UDim2.fromOffset(24, 24), BackgroundTransparency = 1, ScaleType = Enum.ScaleType.Fit, LayoutOrder = 1 }, card)
	local value = display.make("TextLabel", { Size = UDim2.fromOffset(0, 20), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = Color3.new(1, 1, 1), LayoutOrder = 2, Text = "" }, card)
	local label = display.make("TextLabel", { Size = UDim2.fromOffset(0, 20), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = Color3.fromRGB(150, 150, 150), LayoutOrder = 3, Text = "" }, card)
	return { frame = card, icon = icon, value = value, label = label }
end

function display.refreshHud()
	local run = nil
	if hub.settings.dungeonHud and hub.settings.autoDungeon and not display.black and dungeon.inDungeonLevel() then
		run = display.dungeonInfo()
	end
	if not run then
		if display.hud then
			display.hud.gui.Enabled = false
		end
		return
	end
	if not display.hud or not display.hud.gui.Parent then
		local parent = hubGuiParent()
		if not parent then
			return
		end
		local screen = display.make("ScreenGui", { Name = "AnimeAdventureDungeonBar", ResetOnSpawn = false, DisplayOrder = 20, ZIndexBehavior = Enum.ZIndexBehavior.Sibling })
		local row = display.make("Frame", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 6), Size = UDim2.fromOffset(0, 34), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1 }, screen)
		display.make("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, row)
		local logo = display.make("ImageLabel", { Size = UDim2.fromOffset(34, 34), BackgroundColor3 = Color3.fromRGB(14, 14, 14), BackgroundTransparency = 0.12, Image = display.icons.logo, ScaleType = Enum.ScaleType.Fit, LayoutOrder = 0 }, row)
		display.round(logo, 9)
		display.outline(logo, display.orange)
		display.hud = { gui = screen, row = row, cards = {} }
		screen.Parent = parent
	end
	display.hud.gui.Enabled = true
	display.fillCards(display.hud.row, display.hud.cards, {
		{ label = "FLOOR", value = run.floor .. "/20" },
		{ label = "CHESTS", value = tostring(run.chests), icon = display.icons.chest },
		{ label = "GOLD", value = tostring(run.gold), icon = display.icons.gold },
		{ label = "KEYS", value = tostring(itemCount("dungeon_key")), icon = display.icons.key },
	}, display.hudCard)
end

function display.tick()
	if os.clock() < display.nextTick then
		return
	end
	display.nextTick = os.clock() + 1
	if display.black then
		pcall(display.refreshBlack)
	end
	pcall(display.refreshHud)
end

function display.cleanup()
	display.fastOn = false
	if display.fastConn then
		pcall(function()
			display.fastConn:Disconnect()
		end)
		display.fastConn = nil
	end
	if display.black then
		pcall(display.setBlack, false)
	end
	if display.hud then
		pcall(function()
			display.hud.gui:Destroy()
		end)
		display.hud = nil
	end
	pcall(placement.hidePanel)
end

function placement.pickButton(parent, text, primary, position, callback)
	local button = display.make("TextButton", { AnchorPoint = Vector2.new(0, 1), Position = position, Size = UDim2.new(0.5, -18, 0, 40), BackgroundColor3 = primary and display.orange or Color3.fromRGB(30, 30, 30), AutoButtonColor = false, Font = Enum.Font.GothamBold, TextSize = 15, TextColor3 = Color3.new(1, 1, 1), Text = text }, parent)
	display.round(button, 10)
	if not primary then
		display.outline(button)
	end
	button.Activated:Connect(function()
		if hub.alive then
			pcall(callback)
		end
	end)
	return button
end

function placement.showPanel()
	placement.hidePanel()
	local parent = hubGuiParent()
	if not parent then
		return
	end
	local touch = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
	local screen = display.make("ScreenGui", { Name = "AnimeAdventurePickPanel", IgnoreGuiInset = true, ResetOnSpawn = false, DisplayOrder = 61, ZIndexBehavior = Enum.ZIndexBehavior.Sibling })
	local panel = display.make("Frame", { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -24), Size = UDim2.fromOffset(340, 110), BackgroundColor3 = Color3.fromRGB(14, 14, 14), BackgroundTransparency = 0.06, Active = true }, screen)
	display.round(panel, 12)
	display.outline(panel)
	local chip = display.make("Frame", { Position = UDim2.fromOffset(14, 14), Size = UDim2.fromOffset(3, 12), BackgroundColor3 = display.orange, BorderSizePixel = 0 }, panel)
	display.round(chip, 2)
	display.make("TextLabel", { Position = UDim2.fromOffset(24, 11), Size = UDim2.new(1, -36, 0, 18), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = Color3.fromRGB(150, 150, 150), TextXAlignment = Enum.TextXAlignment.Left, Text = "PLACEMENT AREA" }, panel)
	local hint = display.make("TextLabel", { Position = UDim2.fromOffset(14, 32), Size = UDim2.new(1, -28, 0, 20), BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, TextSize = 14, TextColor3 = Color3.new(1, 1, 1), TextXAlignment = Enum.TextXAlignment.Left, Text = "" }, panel)
	placement.pickButton(panel, touch and "Cancel" or "Cancel (Q)", false, UDim2.new(0, 12, 1, -12), function()
		placement.finishPick(nil)
	end)
	local confirm = placement.pickButton(panel, "Confirm", true, UDim2.new(0.5, 6, 1, -12), placement.confirm)
	local scale = display.make("UIScale", { Scale = 1 }, panel)
	local camera = workspace.CurrentCamera
	if camera then
		scale.Scale = math.clamp(camera.ViewportSize.X / 420, 0.7, 1)
	end
	placement.panel = { gui = screen, hint = hint, confirm = confirm, touch = touch }
	screen.Parent = parent
	placement.updatePanel()
end

function placement.updatePanel()
	local panel = placement.panel
	if not panel then
		return
	end
	local ready = placement.pending ~= nil
	panel.hint.Text = ready and "Spot set. Confirm or pick again" or (panel.touch and "Tap the ground" or "Click the ground")
	panel.confirm.BackgroundTransparency = ready and 0 or 0.65
	panel.confirm.TextTransparency = ready and 0 or 0.45
end

function placement.hidePanel()
	if placement.panel then
		local gui = placement.panel.gui
		placement.panel = nil
		pcall(function()
			gui:Destroy()
		end)
	end
end

local function buildUi()
	if genv.HubWindow then
		pcall(function()
			genv.HubWindow:Unload()
		end)
		genv.HubWindow = nil
	end
	local window = OrderUI:Window({
		Title = "Order HUB",
		Subtitle = "Anime Adventure",
		Size = UDim2.fromOffset(800, 500),
	})
	ui.window = window
	genv.HubWindow = window
	applyScale()
	if not ui.scaleWatch and workspace.CurrentCamera then
		ui.scaleWatch = connect(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), function()
			if hub.settings.uiScale == "Auto" then
				applyScale()
			end
		end)
	end

	local group = window:TabGroup()
	local stageTab = group:Tab({ Name = "Main", Image = "rbxassetid://10723407389" })
	local summerTab = group:Tab({ Name = "Summer", Image = "rbxassetid://10747363809" })
	local macroTab = group:Tab({ Name = "Macro", Image = "rbxassetid://10734897250" })
	local autoPlayTab = group:Tab({ Name = "Auto Play", Image = "rbxassetid://92980588705520" })
	local teamTab = group:Tab({ Name = "Team", Image = "rbxassetid://137726256442333" })
	local summonTab = group:Tab({ Name = "Summon", Image = "rbxassetid://10723345518" })
	local dungeonTab = group:Tab({ Name = "Dungeon", Image = "rbxassetid://10723407389" })
	local miscTab = group:Tab({ Name = "Misc", Image = "rbxassetid://10723376114" })

	local stageLeft = stageTab:Section({ Side = "Left" })
	local stageRight = stageTab:Section({ Side = "Right" })

	stageLeft:Header({ Text = "Status" })
	ui.status = stageLeft:Paragraph({ Header = "Status", Body = hub.status })

	stageLeft:Header({ Text = "Level" })
	local worldDefault = table.find(hub.worlds, hub.settings.world) or 1
	local currentWorld = hub.worlds[worldDefault]
	if currentWorld and hub.settings.world ~= currentWorld then
		hub.settings.world = currentWorld
	end
	ui.levelDropdown = nil
	ui.worldDropdown = stageLeft:Dropdown({
		Name = "World",
		Search = true,
		Required = true,
		Options = hub.worlds,
		Default = worldDefault,
		Callback = function(value)
			if type(value) ~= "string" or ui.suppress then
				return
			end
			setFlag("world", value)
			local levels = hub.levelsByWorld[value] or {}
			if ui.levelDropdown then
				ui.suppress = true
				ui.levelDropdown:ClearOptions()
				ui.levelDropdown:InsertOptions(levels)
				ui.levelDropdown:UpdateSelection(1)
				ui.suppress = false
			end
			setFlag("level", levels[1] or "")
		end,
	})
	local worldLevels = hub.levelsByWorld[currentWorld or ""] or {}
	local levelDefault = table.find(worldLevels, hub.settings.level) or 1
	if worldLevels[levelDefault] then
		hub.settings.level = worldLevels[levelDefault]
	end
	ui.levelDropdown = stageLeft:Dropdown({
		Name = "Level",
		Required = true,
		Options = worldLevels,
		Default = levelDefault,
		Callback = function(value)
			if type(value) == "string" and not ui.suppress then
				setFlag("level", value)
			end
		end,
	})
	stageLeft:Dropdown({
		Name = "Difficulty",
		Required = true,
		Options = difficultyOptions,
		Default = table.find(difficultyOptions, hub.settings.difficulty) or 1,
		Callback = function(value)
			if type(value) == "string" and not ui.suppress then
				setFlag("difficulty", value)
			end
		end,
	})
	ui.autoJoin = stageLeft:Toggle({
		Name = "Auto Join",
		Default = hub.settings.autoJoin,
		Callback = function(value)
			if ui.suppress then
				return
			end
			setFlag("autoJoin", value)
			if value then
				setStatus("Auto Join on, looking for a free lobby")
			else
				hub.joining = false
				setStatus("Auto Join off")
			end
		end,
	})
	ui.autoStart = stageLeft:Toggle({
		Name = "Auto Start Lobby",
		Default = hub.settings.autoStart,
		Callback = function(value)
			if ui.suppress then
				return
			end
			setFlag("autoStart", value)
			setStatus(value and "Auto Start on, starts your lobby when you are in one" or "Auto Start off")
		end,
	})

	local summerLeft = summerTab:Section({ Side = "Left" })
	local summerRight = summerTab:Section({ Side = "Right" })

	summerLeft:Header({ Text = "Summer Hunt" })
	summerLeft:Toggle({
		Name = "Auto Summer Hunt",
		Default = hub.settings.autoSummerHunt,
		Callback = function(value)
			if not ui.suppress then
				setFlag("autoSummerHunt", value)
				eventTeam.nextRequest = 0
				if not value then
					task.spawn(pcall, eventTeam.leaveQueue)
				end
				setStatus(value and "Auto Summer Hunt on" or "Auto Summer Hunt off")
			end
		end,
	})
	summerLeft:Dropdown({
		Name = "Play",
		Required = true,
		Options = eventTeam.playModes,
		Default = table.find(eventTeam.playModes, hub.settings.summerMode) or 1,
		Callback = function(value)
			if type(value) == "string" and not ui.suppress then
				setFlag("summerMode", value)
				eventTeam.nextRequest = 0
				eventTeam.roomSince = nil
			end
		end,
	})
	summerLeft:Dropdown({
		Name = "Join When",
		Required = true,
		Options = eventTeam.joinRules,
		Default = table.find(eventTeam.joinRules, hub.settings.summerJoinRule) or 1,
		Callback = function(value)
			if type(value) == "string" and not ui.suppress then
				setFlag("summerJoinRule", value)
			end
		end,
	})
	ui.weatherOptions = {}
	for _, id in ipairs(eventTeam.weathers) do
		table.insert(ui.weatherOptions, eventTeam.weatherName(id))
	end
	summerLeft:Dropdown({
		Name = "Skip Weathers",
		Multi = true,
		Required = false,
		Options = ui.weatherOptions,
		Default = type(hub.settings.summerSkipWeathers) == "table" and hub.settings.summerSkipWeathers or {},
		Callback = function(value)
			if ui.suppress or type(value) ~= "table" then
				return
			end
			local list = {}
			for _, name in ipairs(ui.weatherOptions) do
				if value[name] then
					table.insert(list, name)
				end
			end
			setFlag("summerSkipWeathers", list)
		end,
	})
	summerLeft:Label({ Text = "Weather and map rotate for the whole server. Join When / Skip Weathers wait in the lobby until the rotation fits (new map helps the Bingo board, new weather helps Weather Report). After a hunt: Replay only if After Level is Replay and the rules still fit, else back to lobby. Play: Solo opens your own friends-only room and starts at once. Party: the party host opens a friends-only room, waits up to 90 s for every party member, then starts; members wait for the host. Find Match: public matchmaking (up to 6 players)" })
	ui.summerLabel = summerLeft:Label({ Text = "Off" })

	summerLeft:Header({ Text = "Buff Vote" })
	summerLeft:Toggle({
		Name = "Auto Pick Buffs",
		Default = hub.settings.autoRogue,
		Callback = function(value)
			if not ui.suppress then
				setFlag("autoRogue", value)
			end
		end,
	})
	summerLeft:Dropdown({
		Name = "Fallback",
		Required = true,
		Options = eventTeam.pickModes,
		Default = table.find(eventTeam.pickModes, hub.settings.rogueMode) or 1,
		Callback = function(value)
			if type(value) == "string" and not ui.suppress then
				setFlag("rogueMode", value)
			end
		end,
	})
	summerLeft:Dropdown({
		Name = "Tier Rule",
		Required = true,
		Options = eventTeam.tierRules,
		Default = table.find(eventTeam.tierRules, hub.settings.rogueTierRule) or 1,
		Callback = function(value)
			if type(value) == "string" and not ui.suppress then
				setFlag("rogueTierRule", value)
			end
		end,
	})
	summerLeft:Label({ Text = "Top Priority item sets buff or debuff side; other side only if nothing fits. Debuffs raise the Summer Pearl multiplier. Weather picks (with an emoji) are learned when seen" })
	ui.avoidDropdown = summerLeft:Dropdown({
		Name = "Never Pick",
		Multi = true,
		Required = false,
		Options = eventTeam.pickNames(),
		Default = hub.settings.rogueAvoid or {},
		Callback = function(value)
			if ui.suppress or type(value) ~= "table" then
				return
			end
			local list = {}
			for name, on in pairs(value) do
				if on then
					table.insert(list, name)
				end
			end
			table.sort(list)
			setFlag("rogueAvoid", list)
		end,
	})
	ui.lastPickLabel = summerLeft:Label({ Text = "Last pick: none" })

	summerRight:Header({ Text = "Rewards" })
	summerRight:Toggle({
		Name = "Auto Claim Bingo",
		Default = hub.settings.summerClaimBingo,
		Callback = function(value)
			if not ui.suppress then
				setFlag("summerClaimBingo", value)
				eventTeam.nextClaim = 0
			end
		end,
	})
	summerRight:Toggle({
		Name = "Auto Buy Sunny Star",
		Default = hub.settings.summerBuyStars,
		Callback = function(value)
			if not ui.suppress then
				setFlag("summerBuyStars", value)
				eventTeam.nextShop = 0
			end
		end,
	})
	summerRight:Slider({
		Name = "Keep Pearls",
		Minimum = 0,
		Maximum = 60000,
		DisplayMethod = "Value",
		Precision = 0,
		Default = math.clamp(math.floor(tonumber(hub.settings.summerKeepPearls) or 5000), 0, 60000),
		Callback = function(value)
			if not ui.suppress then
				setFlag("summerKeepPearls", math.clamp(math.floor(tonumber(value) or 0), 0, 60000))
			end
		end,
	})
	summerRight:Label({ Text = "Bingo: claims every finished row, column or diagonal of the map board (2000 Pearls + 10 Star Remnants each). Sunny Star costs 150 Pearls; buys 10 at a time while Pearls stay above Keep Pearls. Lobby only" })
	ui.summerShopLabel = summerRight:Label({ Text = "Off" })
	ui.summerProgressLabel = summerRight:Label({ Text = "Progress: loading" })

	summerRight:Header({ Text = "Buff Priority" })
	ui.rogueOrder = summerRight:RankList({
		Name = "Priority",
		Options = eventTeam.pickNames(),
		Default = eventTeam.priority(),
		EmptyText = "Empty, uses Fallback",
		Callback = function(list)
			setFlag("roguePrefer", {})
			setFlag("roguePriority", list)
		end,
	})
	summerRight:Button({
		Name = "Clear Priority",
		Callback = function()
			setFlag("roguePrefer", {})
			setFlag("roguePriority", {})
			pcall(function()
				ui.rogueOrder:SetValue({})
			end)
		end,
	})
	eventTeam.refreshPickers = function()
		ui.suppress = true
		pcall(function()
			ui.avoidDropdown:ClearOptions()
			ui.avoidDropdown:InsertOptions(eventTeam.pickNames())
			ui.avoidDropdown:UpdateSelection(type(hub.settings.rogueAvoid) == "table" and hub.settings.rogueAvoid or {})
		end)
		ui.suppress = false
		pcall(function()
			ui.rogueOrder:SetOptions(eventTeam.pickNames())
			ui.rogueOrder:SetValue(eventTeam.priority())
		end)
	end

	stageRight:Header({ Text = "Mode Priority" })
	ui.prioritySlots = {}
	local priorityOrder = lobbyPlan.order()
	for slot = 1, #lobbyPlan.modes do
		ui.prioritySlots[slot] = stageRight:Dropdown({
			Name = lobbyPlan.ordinals[slot] or tostring(slot),
			Required = true,
			Options = lobbyPlan.modes,
			Default = table.find(lobbyPlan.modes, priorityOrder[slot]) or slot,
			Callback = function(value)
				if not ui.suppress and type(value) == "string" then
					lobbyPlan.setSlot(slot, value)
				end
			end,
		})
	end
	ui.refreshOrder = function()
		local order = lobbyPlan.order()
		ui.suppress = true
		for slot, dropdown in ipairs(ui.prioritySlots or {}) do
			pcall(function()
				dropdown:UpdateSelection(order[slot])
			end)
		end
		ui.suppress = false
	end
	ui.priorityLabel = stageRight:Label({ Text = "Idle" })

	stageRight:Header({ Text = "Challenge" })
	stageRight:Toggle({
		Name = "Auto Challenge",
		Default = hub.settings.autoChallenge,
		Callback = function(value)
			if not ui.suppress then
				setFlag("autoChallenge", value)
				lobbyPlan.nextChallenge = 0
			end
		end,
	})
	local rewardDropdown = stageRight:Dropdown({
		Name = "Rewards",
		Multi = true,
		Required = false,
		Options = lobbyPlan.optionList(lobbyPlan.knownRewards, "challengeSeen"),
		Default = lobbyPlan.labelsFor(hub.settings.challengeRewards),
		Callback = function(value)
			if not ui.suppress and type(value) == "table" then
				setFlag("challengeRewards", lobbyPlan.idsFrom(value))
			end
		end,
	})
	ui.refreshRewardPicker = function()
		ui.suppress = true
		pcall(function()
			rewardDropdown:ClearOptions()
			rewardDropdown:InsertOptions(lobbyPlan.optionList(lobbyPlan.knownRewards, "challengeSeen"))
			rewardDropdown:UpdateSelection(lobbyPlan.labelsFor(hub.settings.challengeRewards))
		end)
		ui.suppress = false
	end
	ui.challengeLabel = stageRight:Label({ Text = "Off" })

	stageRight:Header({ Text = "Infinity Mansion" })
	stageRight:Toggle({
		Name = "Auto Infinity Mansion",
		Default = hub.settings.autoMansion,
		Callback = function(value)
			if not ui.suppress then
				setFlag("autoMansion", value)
				lobbyPlan.mansionNext = 0
				lobbyPlan.mansionHardFails = 0
			end
		end,
	})
	stageRight:Dropdown({
		Name = "Difficulty",
		Required = true,
		Options = { "Hard", "Normal" },
		Default = hub.settings.mansionDifficulty == "Normal" and 2 or 1,
		Callback = function(value)
			if not ui.suppress and type(value) == "string" then
				setFlag("mansionDifficulty", value)
				lobbyPlan.mansionHardFails = 0
			end
		end,
	})
	stageRight:Label({ Text = "Starts at your furthest room and keeps going. Normal clears 1 room, Hard skips 2. Rooms past 100 are Hard only. Team: Infinite Tower in Team Per Mode" })
	ui.mansionLabel = stageRight:Label({ Text = "Off" })

	stageLeft:Header({ Text = "In Level" })
	stageLeft:Toggle({
		Name = "Auto Vote Start",
		Default = hub.settings.autoVote,
		Callback = function(value)
			if not ui.suppress then
				setFlag("autoVote", value)
			end
		end,
	})
	stageLeft:Toggle({
		Name = "Auto Skip Waves",
		Default = hub.settings.autoSkip,
		Callback = function(value)
			if not ui.suppress then
				setFlag("autoSkip", value)
			end
		end,
	})

	stageLeft:Header({ Text = "After Level" })
	ui.finishToggles = {}
	local function finishToggle(label, kind)
		ui.finishToggles[kind] = stageLeft:Toggle({
			Name = label,
			Default = hub.settings.afterFinish == kind,
			Callback = function(value)
				if ui.suppress then
					return
				end
				if value then
					setFlag("afterFinish", kind)
					for otherKind, toggle in pairs(ui.finishToggles) do
						if otherKind ~= kind then
							setToggle(toggle, false)
						end
					end
				elseif hub.settings.afterFinish == kind then
					setFlag("afterFinish", "Do Nothing")
				end
			end,
		})
	end
	finishToggle("Auto Replay", "Replay")
	finishToggle("Auto Next Story", "Next Story")
	finishToggle("Auto Back To Lobby", "Back To Lobby")
	stageLeft:Toggle({
		Name = "Auto Next Portal",
		Default = hub.settings.autoNextPortal,
		Callback = function(value)
			if not ui.suppress then
				setFlag("autoNextPortal", value)
				hub.portal.nextOpen = 0
				hub.portal.cacheAt = 0
			end
		end,
	})
	ui.portalDropdown = stageLeft:Dropdown({
		Name = "Portals To Use",
		Multi = true,
		Required = false,
		Options = hub.portal.names(),
		Default = type(hub.settings.portalNames) == "table" and hub.settings.portalNames or {},
		Callback = function(value)
			if not ui.suppress and type(value) == "table" then
				local list = {}
				for name, on in pairs(value) do
					if on then
						table.insert(list, name)
					end
				end
				table.sort(list)
				setFlag("portalNames", list)
			end
		end,
	})
	ui.refreshPortalPicker = function()
		ui.suppress = true
		pcall(function()
			ui.portalDropdown:ClearOptions()
			ui.portalDropdown:InsertOptions(hub.portal.names())
			ui.portalDropdown:UpdateSelection(type(hub.settings.portalNames) == "table" and hub.settings.portalNames or {})
		end)
		ui.suppress = false
	end
	stageLeft:Label({ Text = "Portal levels: the host picks the next portal of the same kind from your picked portals. Other cases: back to lobby, open one, then start. Lobby order: Portal in Mode Priority" })
	ui.portalLabel = stageLeft:Label({ Text = "Off" })

	local macroLeft = macroTab:Section({ Side = "Left" })
	local macroRight = macroTab:Section({ Side = "Right" })

	macroLeft:Header({ Text = "Macro" })
	ui.recordToggle = macroLeft:Toggle({
		Name = "Record Macro",
		Default = false,
		Callback = function(value)
			if ui.suppress then
				return
			end
			if value then
				if not startRecording() then
					setToggle(ui.recordToggle, false)
				end
			else
				stopRecording(true)
			end
		end,
	})
	ui.playToggle = macroLeft:Toggle({
		Name = "Play Macro",
		Default = hub.settings.playMacro,
		Callback = function(value)
			if ui.suppress then
				return
			end
			if value and hub.rec then
				setStatus("Turn off Record Macro first")
				setToggle(ui.playToggle, false)
				return
			end
			setFlag("playMacro", value)
			if value and hub.settings.autoPlay then
				setFlag("autoPlay", false)
				setToggle(ui.autoPlayToggle, false)
			end
			if value then
				local present, started = gameState()
				if present and started then
					hub.playedRound = hub.round
					playMacro()
				else
					setStatus("Macro will play when the level starts")
				end
			else
				stopPlayback()
				setStatus("Playback stopped")
			end
			refreshMacroStatus()
		end,
	})
	ui.macroDropdown = macroLeft:Dropdown({
		Name = "Macro",
		Required = false,
		Options = macroNames(),
		Default = hub.macros[hub.settings.macro] and hub.settings.macro or nil,
		Callback = function(value)
			if type(value) == "string" and not ui.suppress then
				setFlag("macro", value)
				refreshMacroStatus()
			end
		end,
	})
	ui.macroName = macroLeft:Input({
		Name = "Macro Name",
		Placeholder = "auto",
		Default = "",
		Callback = function() end,
	})
	macroLeft:Button({
		Name = "Delete Macro",
		Callback = function()
			local name = hub.settings.macro
			if hub.macros[name] then
				deleteMacroFile(name)
				hub.settings.macro = ""
				saveConfig()
				syncMacroFiles(true)
				setStatus("Deleted " .. name)
			end
		end,
	})

	macroRight:Header({ Text = "Macro Status" })
	ui.macroStatus = macroRight:Paragraph({ Header = "Macro Status", Body = macroStatusText() })

	local autoPlayLeft = autoPlayTab:Section({ Side = "Left" })
	local autoPlayRight = autoPlayTab:Section({ Side = "Right" })
	autoPlayLeft:Header({ Text = "Auto Play" })
	ui.autoPlayToggle = autoPlayLeft:Toggle({
		Name = "Auto Play",
		Default = hub.settings.autoPlay,
		Callback = function(value)
			if ui.suppress then
				return
			end
			setFlag("autoPlay", value)
			if value and hub.settings.playMacro then
				setFlag("playMacro", false)
				stopPlayback()
				setToggle(ui.playToggle, false)
			end
			hub.autoPlay.blocked = {}
			hub.autoPlay.fails = {}
			setStatus(value and "Auto Play on" or "Auto Play off")
		end,
	})
	autoPlayLeft:Toggle({
		Name = "Auto Upgrade",
		Default = hub.settings.autoPlayUpgrade,
		Callback = function(value)
			if not ui.suppress then
				setFlag("autoPlayUpgrade", value)
			end
		end,
	})
	autoPlayLeft:Toggle({
		Name = "Sequential Upgrade",
		Default = hub.settings.sequentialUpgrade,
		Callback = function(value)
			if not ui.suppress then
				setFlag("sequentialUpgrade", value)
			end
		end,
	})
	autoPlayLeft:Toggle({
		Name = "Spend Leftover Money",
		Default = hub.settings.leftoverUpgrade,
		Callback = function(value)
			if not ui.suppress then
				setFlag("leftoverUpgrade", value)
			end
		end,
	})
	autoPlayLeft:Header({ Text = "Wave Rules" })
	autoPlayLeft:Paragraph({ Header = "Wave Rules", Body = "0 = off. Sell All sells every unit at that wave and stops placing. Sell Farms sells only farm units. Upgrade All upgrades any unit you can afford, in no order, and ignores Upgrade To. Use In Modes: the rules only work in the picked modes, none picked = every mode." })
	for _, item in ipairs({ { "Sell All At Wave", "sellAllWave" }, { "Sell Farms At Wave", "sellFarmWave" }, { "Upgrade All From Wave", "upgradeAllWave" } }) do
		autoPlayLeft:Slider({
			Name = item[1],
			Minimum = 0,
			Maximum = 200,
			Default = math.clamp(math.floor(tonumber(hub.settings[item[2]]) or 0), 0, 200),
			DisplayMethod = "Value",
			Precision = 0,
			Callback = function(value)
				setFlag(item[2], math.clamp(math.floor(tonumber(value) or 0), 0, 200))
			end,
		})
	end
	autoPlayLeft:Dropdown({
		Name = "Use In Modes",
		Multi = true,
		Required = false,
		Options = autoPlay.modes,
		Default = type(hub.settings.waveRuleModes) == "table" and hub.settings.waveRuleModes or {},
		Callback = function(value)
			if not ui.suppress and type(value) == "table" then
				local list = {}
				for _, mode in ipairs(autoPlay.modes) do
					if value[mode] then
						table.insert(list, mode)
					end
				end
				setFlag("waveRuleModes", list)
			end
		end,
	})
	local function slotViewport(slot)
		local view = nil
		pcall(function()
			view = LocalPlayer.PlayerGui.spawn_units.Lives.Frame.Units[tostring(slot)].Main.View
		end)
		return view
	end

	local function cleanViewport(copy)
		local world = copy:FindFirstChildOfClass("WorldModel")
		local root = world and world:FindFirstChildOfClass("Model")
		if not root then
			return
		end
		for _, item in ipairs(root:GetDescendants()) do
			if item:IsA("Model") and (item:FindFirstChild("RootPart") or item:FindFirstChild("HumanoidRootPart") or item:FindFirstChildOfClass("Humanoid")) then
				pcall(function()
					item:Destroy()
				end)
			end
		end
		for _, item in ipairs(root:GetDescendants()) do
			if item:IsA("BasePart") and math.max(item.Size.X, item.Size.Y, item.Size.Z) > 4 then
				pcall(function()
					item:Destroy()
				end)
			end
		end
	end

	ui.editMode = autoPlay.activeMode()

	local function slotSummary(slot)
		local config = slotConfig(slot, ui.editMode)
		if not config.place then
			return "Not placed"
		end
		return string.format("P%d · x%d · Lv%d", config.priority, config.max, config.upgradeTo) .. (config.placeWave > 1 and (" · W" .. config.placeWave) or "")
	end

	local function skillText(unitId)
		local info = unitData(unitId)
		if not info then
			return "No unit in this slot."
		end
		local attack, level = info.active_attack, 0
		if not attack and type(info.upgrade) == "table" then
			for index, step in ipairs(info.upgrade) do
				if type(step) == "table" and step.active_attack then
					attack, level = step.active_attack, index
					break
				end
			end
		end
		if not attack then
			return "This unit has no active skill."
		end
		local name = attack
		pcall(function()
			local data = require(ReplicatedStorage.src.Data.Attacks)[attack]
			name = tostring(type(data) == "table" and data.name or attack)
		end)
		local lines = { "Skill: " .. name .. (level > 0 and (" (unlocks at upgrade " .. level .. ")") or "") }
		local reach = skillRules.reach(attack)
		table.insert(lines, reach and ("Boss only: the boss must be within " .. reach .. " studs of this unit.") or "Boss only: any boss on the map counts, this skill has no range limit.")
		if buffLoop.skillInfo(attack) then
			table.insert(lines, "Buff skill: while Buff Loop is on, Buff Loop casts it (boss only is ignored).")
		elseif string.find(attack, "fusion", 1, true) then
			table.insert(lines, "Fusion: the unit that presses it becomes the base. Turn Auto Skill on for only one of the pair.")
		end
		return table.concat(lines, "\n")
	end

	ui.slotPopups = {}
	for slot = 1, 6 do
		local popup = window:Popup({ Title = "Slot " .. tostring(slot), Subtitle = "Empty slot", Placeholder = tostring(slot) })
		local body = popup:Section()
		local config = slotConfig(slot, ui.editMode)
		local controls = {}
		local function changed()
			saveConfig()
			if ui.refreshTeam then
				pcall(ui.refreshTeam)
			end
		end
		local function setValue(key, value)
			if not ui.suppress then
				slotConfig(slot, ui.editMode)[key] = value
				changed()
			end
		end
		body:Header({ Text = "Placement" })
		controls.place = body:Toggle({
			Name = "Place this unit",
			Default = config.place,
			Callback = function(value)
				setValue("place", value)
			end,
		})
		controls.max = body:Slider({
			Name = "Max Placed",
			Minimum = 1,
			Maximum = 30,
			Default = config.max,
			DisplayMethod = "Value",
			Precision = 0,
			Callback = function(value)
				setValue("max", math.floor(tonumber(value) or 6))
			end,
		})
		controls.upgradeTo = body:Slider({
			Name = "Upgrade To",
			Minimum = 0,
			Maximum = 15,
			Default = config.upgradeTo,
			DisplayMethod = "Value",
			Precision = 0,
			Callback = function(value)
				setValue("upgradeTo", math.floor(tonumber(value) or 15))
			end,
		})
		controls.priority = body:Slider({
			Name = "Priority",
			Minimum = 1,
			Maximum = 6,
			Default = config.priority,
			DisplayMethod = "Value",
			Precision = 0,
			Callback = function(value)
				setValue("priority", math.floor(tonumber(value) or slot))
			end,
		})
		controls.placeWave = body:Slider({
			Name = "Place From Wave",
			Minimum = 1,
			Maximum = 200,
			Default = config.placeWave,
			DisplayMethod = "Value",
			Precision = 0,
			Callback = function(value)
				setValue("placeWave", math.floor(tonumber(value) or 1))
			end,
		})
		body:Header({ Text = "Skill" })
		controls.skill = body:Toggle({
			Name = "Auto Skill",
			Default = config.skill,
			Callback = function(value)
				setValue("skill", value)
			end,
		})
		controls.skillWave = body:Slider({
			Name = "From Wave",
			Minimum = 1,
			Maximum = 200,
			Default = config.skillWave,
			DisplayMethod = "Value",
			Precision = 0,
			Callback = function(value)
				setValue("skillWave", math.floor(tonumber(value) or 1))
			end,
		})
		controls.skillBossOnly = body:Toggle({
			Name = "Boss Only",
			Default = config.skillBossOnly,
			Callback = function(value)
				setValue("skillBossOnly", value)
			end,
		})
		local skillInfo = body:Paragraph({ Header = "This unit's skill", Body = "Not in team" })
		ui.slotPopups[slot] = { popup = popup, skillInfo = skillInfo, controls = controls }
	end

	ui.showMode = function(mode)
		ui.editMode = mode
		ui.suppress = true
		for slot = 1, 6 do
			local pop = ui.slotPopups and ui.slotPopups[slot]
			local config = slotConfig(slot, mode)
			if pop then
				pcall(function()
					pop.controls.place:UpdateState(config.place)
					pop.controls.max:UpdateValue(config.max)
					pop.controls.upgradeTo:UpdateValue(config.upgradeTo)
					pop.controls.priority:UpdateValue(config.priority)
					pop.controls.placeWave:UpdateValue(config.placeWave)
					pop.controls.skill:UpdateState(config.skill)
					pop.controls.skillWave:UpdateValue(config.skillWave)
					pop.controls.skillBossOnly:UpdateState(config.skillBossOnly)
				end)
			end
		end
		ui.suppress = false
		pcall(ui.modeText)
		pcall(ui.refreshTeam)
	end

	ui.modeText = function()
		if not ui.modeLabel then
			return
		end
		local playing = autoPlay.levelMode()
		local text
		if not playing then
			text = "In lobby"
		elseif playing == ui.editMode then
			text = "Playing " .. playing .. " (active)"
		else
			text = "Playing " .. playing .. " | editing " .. ui.editMode
		end
		if ui.modeShown ~= text then
			ui.modeShown = text
			ui.modeLabel:UpdateName(text)
		end
	end

	ui.followMode = function()
		local playing = autoPlay.levelMode()
		if playing and playing ~= ui.followed then
			local previous = ui.followed
			ui.followed = playing
			if previous == nil or ui.editMode == previous or ui.editMode == "Story" then
				if ui.modeDropdown then
					pcall(function()
						ui.modeDropdown:UpdateSelection(table.find(autoPlay.modes, playing) or 1)
					end)
				end
				ui.showMode(playing)
				return
			end
		end
		pcall(ui.modeText)
	end

	ui.refreshTeam = function()
		if not ui.teamGrid or not ui.slotPopups then
			return
		end
		local bySlot = {}
		for _, entry in ipairs(autoPlay.team or {}) do
			bySlot[entry.slot] = entry
		end
		for slot = 1, 6 do
			local entry = bySlot[slot]
			local config = slotConfig(slot, ui.editMode)
			local view = entry and slotViewport(slot) or nil
			local name = entry and unitName(entry.unitId) or ("Slot " .. tostring(slot))
			local summary = entry and slotSummary(slot) or "Empty"
			local tag = ""
			if entry and config.skill then
				tag = config.skillBossOnly and "Boss" or (config.skillWave > 1 and ("W" .. config.skillWave) or "Skill")
			end
			ui.teamGrid:SetTile(slot, { Title = name, Subtitle = summary, Tag = tag, Dim = entry == nil or not config.place, Viewport = view, Placeholder = tostring(slot), Prepare = cleanViewport })
			local pop = ui.slotPopups[slot]
			pop.popup:SetHeader({ Title = name, Subtitle = "Slot " .. tostring(slot) .. " · " .. summary, Viewport = view, Placeholder = tostring(slot), Prepare = cleanViewport })
			local text = entry and skillText(entry.unitId) or "Put this unit in your team to see its skill."
			if pop.text ~= text then
				pop.text = text
				pop.skillInfo:UpdateBody(text)
			end
		end
	end

	autoPlayLeft:Header({ Text = "Team" })
	ui.modeDropdown = autoPlayLeft:Dropdown({
		Name = "Mode",
		Required = true,
		Options = autoPlay.modes,
		Default = table.find(autoPlay.modes, ui.editMode) or 1,
		Callback = function(value)
			if type(value) == "string" and table.find(autoPlay.modes, value) then
				ui.showMode(value)
			end
		end,
	})
	ui.modeLabel = autoPlayLeft:Label({ Text = "" })
	ui.followed = autoPlay.levelMode()
	pcall(ui.modeText)
	autoPlayLeft:Button({
		Name = "Copy From Story",
		Callback = function()
			if ui.editMode == "Story" then
				setStatus("Pick another mode first")
				return
			end
			local profile = autoPlay.profile(ui.editMode)
			for key, config in pairs(autoPlay.profile("Story")) do
				if type(config) == "table" then
					profile[key] = table.clone(config)
				end
			end
			saveConfig()
			ui.showMode(ui.editMode)
			setStatus("Copied Story settings into " .. ui.editMode)
		end,
	})
	autoPlayLeft:Button({
		Name = "Reset This Mode",
		Callback = function()
			autoPlay.resetProfile(ui.editMode)
			ui.showMode(ui.editMode)
			setStatus(ui.editMode .. " slot settings back to default")
		end,
	})
	autoPlayLeft:Button({
		Name = "Reset All Modes",
		Callback = function()
			if os.clock() > (ui.resetAllArmed or 0) then
				ui.resetAllArmed = os.clock() + 5
				setStatus("Press Reset All Modes again within 5 s to reset every mode")
				return
			end
			ui.resetAllArmed = 0
			autoPlay.resetProfile(nil)
			ui.showMode(ui.editMode)
			setStatus("Every mode's slot settings back to default")
		end,
	})
	ui.teamGrid = autoPlayLeft:UnitGrid({
		Name = "team units slot settings skill",
		Count = 6,
		Columns = 3,
		Callback = function(slot)
			pcall(teamUnits)
			pcall(ui.refreshTeam)
			ui.slotPopups[slot].popup:Open()
		end,
	})

	autoPlayLeft:Header({ Text = "Buff Loop" })
	autoPlayLeft:Toggle({
		Name = "Buff Loop",
		Default = hub.settings.buffLoop,
		Callback = function(value)
			if not ui.suppress then
				setFlag("buffLoop", value)
				buffLoop.groups = {}
			end
		end,
	})
	autoPlayLeft:Dropdown({
		Name = "Buff Mode",
		Required = true,
		Options = buffLoop.modes,
		Default = table.find(buffLoop.modes, hub.settings.buffLoopMode) or 1,
		Callback = function(value)
			if type(value) == "string" and not ui.suppress then
				setFlag("buffLoopMode", value)
			end
		end,
	})
	autoPlayLeft:Slider({
		Name = "Units Per Type",
		Minimum = 1,
		Maximum = 6,
		Default = math.floor(tonumber(hub.settings.buffUnitCap) or 4),
		DisplayMethod = "Value",
		Precision = 0,
		Callback = function(value)
			setFlag("buffUnitCap", math.floor(tonumber(value) or 4))
		end,
	})

	autoPlayRight:Header({ Text = "Auto Play Status" })
	ui.autoPlayStatus = autoPlayRight:Paragraph({ Header = "Auto Play Status", Body = "Off" })

	local function ringSlider(name, radiusFlag)
		autoPlayRight:Slider({
			Name = name,
			Minimum = 4,
			Maximum = 30,
			Default = math.floor(math.clamp(tonumber(hub.settings[radiusFlag]) or 12, 4, 30)),
			DisplayMethod = "Value",
			Precision = 0,
			Callback = function(value)
				local radius = math.floor(tonumber(value) or 12)
				if radius == hub.settings[radiusFlag] then
					return
				end
				setFlag(radiusFlag, radius)
				placement.resyncAt = os.clock() + 0.4
				placement.focusUntil = os.clock() + 6
			end,
		})
	end

	autoPlayRight:Header({ Text = "Placement Area" })
	autoPlayRight:Button({
		Name = "Pick Area",
		Callback = placement.startPick,
	})
	autoPlayRight:Button({
		Name = "Area Here",
		Callback = setAnchorHere,
	})
	ringSlider("Unit ring size (orange)", "autoPlayRadius")
	autoPlayRight:Toggle({
		Name = "Farm Ring",
		Default = hub.settings.useFarmArea,
		Callback = function(value)
			if ui.suppress then
				return
			end
			setFlag("useFarmArea", value)
			placement.resync()
		end,
	})
	ringSlider("Farm ring size (white)", "autoPlayFarmRadius")
	autoPlayRight:Toggle({
		Name = "Show Area",
		Default = hub.settings.showPlacementArea,
		Callback = function(value)
			if not ui.suppress then
				setFlag("showPlacementArea", value)
			end
		end,
	})
	autoPlayRight:Button({
		Name = "Reset Area",
		Callback = clearAnchor,
	})

	autoPlayRight:Header({ Text = "Path Position" })
	autoPlayRight:Toggle({
		Name = "Place By Path %",
		Default = hub.settings.pathPlace,
		Callback = function(value)
			if ui.suppress then
				return
			end
			setFlag("pathPlace", value)
			autoPlay.blocked = {}
			placement.focusUntil = os.clock() + 6
		end,
	})
	autoPlayRight:Paragraph({ Header = "How it works", Body = "0% = next to your base, 100% = in front of the enemy spawn. Farms still use the farm ring." })
	for _, item in ipairs({ { "Ground units %", "pathGround" }, { "Hill units %", "pathHill" }, { "Buff units %", "pathBuff" } }) do
		autoPlayRight:Slider({
			Name = item[1],
			Minimum = 0,
			Maximum = 100,
			Default = math.clamp(math.floor(tonumber(hub.settings[item[2]]) or 50), 0, 100),
			DisplayMethod = "Value",
			Precision = 0,
			Callback = function(value)
				local percent = math.clamp(math.floor(tonumber(value) or 50), 0, 100)
				if percent == hub.settings[item[2]] then
					return
				end
				setFlag(item[2], percent)
				placement.focusUntil = os.clock() + 6
			end,
		})
	end
	pcall(ui.refreshTeam)

	local summonLeft = summonTab:Section({ Side = "Left" })
	local summonRight = summonTab:Section({ Side = "Right" })

	summonLeft:Header({ Text = "Auto Summon" })
	ui.summonToggle = summonLeft:Toggle({
		Name = "Auto Summon",
		Default = hub.settings.autoSummon,
		Callback = function(value)
			if ui.suppress then
				return
			end
			setFlag("autoSummon", value)
			summon.failures = 0
			summon.nextFetch = 0
			setStatus(value and "Auto Summon on" or "Auto Summon off")
		end,
	})
	local banners = bannerOptions()
	summonLeft:Dropdown({
		Name = "Banner",
		Required = true,
		Options = banners,
		Default = table.find(banners, bannerLabel(hub.settings.summonBanner)) or 1,
		Callback = function(value)
			if type(value) == "string" and not ui.suppress then
				setFlag("summonBanner", labelId(value))
				summon.text = ""
			end
		end,
	})
	summonLeft:Dropdown({
		Name = "Pay with",
		Required = true,
		Options = summonModes,
		Default = table.find(summonModes, hub.settings.summonMode) or 1,
		Callback = function(value)
			if type(value) == "string" and not ui.suppress then
				setFlag("summonMode", value)
			end
		end,
	})
	summonLeft:Toggle({
		Name = "Luck Potion",
		Default = hub.settings.useLuckPotion,
		Callback = function(value)
			if not ui.suppress then
				setFlag("useLuckPotion", value)
			end
		end,
	})
	summonLeft:Slider({
		Name = "Keep Gems",
		Minimum = 0,
		Maximum = 50000,
		Default = tonumber(hub.settings.keepGems) or 0,
		DisplayMethod = "Value",
		Precision = 0,
		Callback = function(value)
			setFlag("keepGems", math.floor(tonumber(value) or 0))
		end,
	})

	summonLeft:Header({ Text = "Wanted Units" })
	summonLeft:Dropdown({
		Name = "Wanted",
		Multi = true,
		Search = true,
		Required = false,
		Options = wantedOptions(),
		Default = hub.settings.wantedUnits or {},
		Callback = function(value)
			if ui.suppress or type(value) ~= "table" then
				return
			end
			local list = {}
			for name, on in pairs(value) do
				if on then
					table.insert(list, name)
				end
			end
			table.sort(list)
			setFlag("wantedUnits", list)
			summon.text = ""
		end,
	})
	summonLeft:Toggle({
		Name = "Stop On Wanted",
		Default = hub.settings.stopOnWanted,
		Callback = function(value)
			if not ui.suppress then
				setFlag("stopOnWanted", value)
			end
		end,
	})
	summonLeft:Toggle({
		Name = "Stop On Pity",
		Default = hub.settings.stopOnPity,
		Callback = function(value)
			if not ui.suppress then
				setFlag("stopOnPity", value)
			end
		end,
	})

	summonLeft:Header({ Text = "Travelling Merchant" })
	summonLeft:Toggle({
		Name = "Auto Buy",
		Default = hub.settings.autoMerchant,
		Callback = function(value)
			if not ui.suppress then
				setFlag("autoMerchant", value)
				lobbyPlan.nextMerchant = 0
			end
		end,
	})
	local merchantDropdown = summonLeft:Dropdown({
		Name = "Items",
		Multi = true,
		Required = false,
		Options = lobbyPlan.optionList(lobbyPlan.knownMerchant, "merchantSeen"),
		Default = lobbyPlan.labelsFor(hub.settings.merchantItems),
		Callback = function(value)
			if not ui.suppress and type(value) == "table" then
				setFlag("merchantItems", lobbyPlan.idsFrom(value))
				lobbyPlan.nextMerchant = 0
			end
		end,
	})
	ui.refreshMerchantPicker = function()
		ui.suppress = true
		pcall(function()
			merchantDropdown:ClearOptions()
			merchantDropdown:InsertOptions(lobbyPlan.optionList(lobbyPlan.knownMerchant, "merchantSeen"))
			merchantDropdown:UpdateSelection(lobbyPlan.labelsFor(hub.settings.merchantItems))
		end)
		ui.suppress = false
	end
	ui.merchantLabel = summonLeft:Label({ Text = "Off" })

	local teamLeft = teamTab:Section({ Side = "Left" })
	local teamRight = teamTab:Section({ Side = "Right" })
	teamLeft:Header({ Text = "Team Per Mode" })
	ui.teamDropdowns = {}
	for _, mode in ipairs(autoPlay.modes) do
		local options = lobbyPlan.teamOptions()
		local saved = type(hub.settings.modeTeams) == "table" and tonumber(hub.settings.modeTeams[mode]) or nil
		ui.teamDropdowns[mode] = teamLeft:Dropdown({
			Name = mode,
			Required = true,
			Options = options,
			Default = saved and math.min(saved + 1, #options) or 1,
			Callback = function(value)
				if ui.suppress or type(value) ~= "string" then
					return
				end
				local copy = table.clone(type(hub.settings.modeTeams) == "table" and hub.settings.modeTeams or {})
				copy[mode] = tonumber(string.match(value, "^(%d+)"))
				setFlag("modeTeams", copy)
				lobbyPlan.teamTries = {}
			end,
		})
	end
	teamRight:Header({ Text = "Saved Teams" })
	ui.teamsParagraph = teamRight:Paragraph({ Header = "Saved Teams", Body = "Loading" })
	ui.refreshTeams = function()
		local options = lobbyPlan.teamOptions()
		local key = table.concat(options, "|")
		if key ~= ui.teamKey then
			ui.teamKey = key
			ui.suppress = true
			for mode, dropdown in pairs(ui.teamDropdowns or {}) do
				pcall(function()
					local saved = type(hub.settings.modeTeams) == "table" and tonumber(hub.settings.modeTeams[mode]) or nil
					dropdown:ClearOptions()
					dropdown:InsertOptions(options)
					dropdown:UpdateSelection(saved and options[saved + 1] or options[1])
				end)
			end
			ui.suppress = false
		end
		local lines = {}
		local current = lobbyPlan.currentTeam()
		for index = 1, lobbyPlan.teamSlots() do
			local units = lobbyPlan.teamUnits(index)
			table.insert(lines, (current == index and "> " or "") .. lobbyPlan.teamLabel(index) .. ": " .. (#units > 0 and table.concat(units, ", ") or "empty"))
		end
		local text = table.concat(lines, "\n")
		if text ~= ui.teamsText and ui.teamsParagraph then
			ui.teamsText = text
			pcall(function()
				ui.teamsParagraph:UpdateBody(text)
			end)
		end
	end
	pcall(ui.refreshTeams)

	summonRight:Header({ Text = "Summon Status" })
	ui.summonStatus = summonRight:Paragraph({ Header = "Summon Status", Body = "Loading" })

	local dungeonLeft = dungeonTab:Section({ Side = "Left" })
	local dungeonRight = dungeonTab:Section({ Side = "Right" })
	local function listFlag(flag)
		return function(value)
			if ui.suppress or type(value) ~= "table" then
				return
			end
			local list = {}
			for name, on in pairs(value) do
				if on then
					table.insert(list, name)
				end
			end
			table.sort(list)
			setFlag(flag, list)
		end
	end
	dungeonLeft:Header({ Text = "Auto Dungeon" })
	dungeonLeft:Toggle({
		Name = "Auto Dungeon",
		Default = hub.settings.autoDungeon,
		Callback = function(value)
			if ui.suppress then
				return
			end
			setFlag("autoDungeon", value)
			dungeon.nextAction = 0
			dungeon.state = value and "Starting" or "Off"
			setStatus(value and "Auto Dungeon on" or "Auto Dungeon off")
		end,
	})
	dungeonLeft:Toggle({
		Name = "Retry Lost Room",
		Default = hub.settings.dungeonRetry,
		Callback = function(value)
			if not ui.suppress then
				setFlag("dungeonRetry", value)
			end
		end,
	})
	dungeonLeft:Header({ Text = "Room Choice" })
	ui.roomOrder = dungeonLeft:RankList({
		Name = "Room Priority",
		Options = dungeon.roomOptions,
		Default = dungeon.order(),
		EmptyText = "Empty, uses default order",
		Callback = function(list)
			setFlag("dungeonOrder", list)
			setFlag("dungeonPrefer", list)
		end,
	})
	dungeonLeft:Dropdown({
		Name = "Avoid",
		Multi = true,
		Required = false,
		Options = dungeon.roomOptions,
		Default = hub.settings.dungeonAvoid or {},
		Callback = listFlag("dungeonAvoid"),
	})
	dungeonLeft:Header({ Text = "Chests" })
	dungeonLeft:Dropdown({
		Name = "Open At Depth",
		Multi = true,
		Required = false,
		Options = dungeon.chestDepths,
		Default = hub.settings.dungeonChestDepths or {},
		Callback = listFlag("dungeonChestDepths"),
	})
	dungeonLeft:Toggle({
		Name = "Gold Chests",
		Default = hub.settings.dungeonOpenGold,
		Callback = function(value)
			if not ui.suppress then
				setFlag("dungeonOpenGold", value)
			end
		end,
	})
	dungeonLeft:Toggle({
		Name = "Dungeon Bar",
		Default = hub.settings.dungeonHud,
		Callback = function(value)
			if not ui.suppress then
				setFlag("dungeonHud", value)
				display.nextTick = 0
			end
		end,
	})
	dungeonLeft:Header({ Text = "Shop and Shrine" })
	local itemLabels = {}
	local chosenLabels = {}
	local chosenIds = dungeon.setOf(hub.settings.dungeonBuy)
	for _, entry in ipairs(dungeon.items) do
		local label = dungeon.itemLabel(entry)
		table.insert(itemLabels, label)
		if chosenIds[entry[1]] then
			table.insert(chosenLabels, label)
		end
	end
	dungeonLeft:Dropdown({
		Name = "Buy Items",
		Multi = true,
		Search = true,
		Required = false,
		Options = itemLabels,
		Default = chosenLabels,
		Callback = function(value)
			if ui.suppress or type(value) ~= "table" then
				return
			end
			local list = {}
			for label, on in pairs(value) do
				local entry = on and dungeon.itemByLabel(label)
				if entry then
					table.insert(list, entry[1])
				end
			end
			table.sort(list)
			setFlag("dungeonBuy", list)
		end,
	})
	dungeonLeft:Toggle({
		Name = "Accept Shrines",
		Default = hub.settings.dungeonShrine,
		Callback = function(value)
			if not ui.suppress then
				setFlag("dungeonShrine", value)
			end
		end,
	})
	dungeonRight:Header({ Text = "Dungeon Status" })
	ui.dungeonStatus = dungeonRight:Paragraph({ Header = "Dungeon Status", Body = "Off" })

	local miscLeft = miscTab:Section({ Side = "Left" })
	miscLeft:Header({ Text = "Interface" })
	miscLeft:Dropdown({
		Name = "UI size",
		Required = true,
		Options = scaleOptions,
		Default = table.find(scaleOptions, hub.settings.uiScale) or 1,
		Callback = function(value)
			if type(value) == "string" and not ui.suppress then
				setFlag("uiScale", value)
				applyScale()
			end
		end,
	})
	miscLeft:Toggle({
		Name = "Show Kill / Worth on slots",
		Default = hub.settings.slotWorth,
		Callback = function(value)
			if not ui.suppress then
				setFlag("slotWorth", value)
				task.spawn(pcall, hub.slotWorth.refresh)
			end
		end,
	})
	miscLeft:Dropdown({
		Name = "Slot style",
		Required = true,
		Options = hub.slotWorth.styles,
		Default = table.find(hub.slotWorth.styles, hub.settings.slotStyle) or 1,
		Callback = function(value)
			if type(value) == "string" and not ui.suppress then
				setFlag("slotStyle", value)
				task.spawn(pcall, hub.slotWorth.refresh)
			end
		end,
	})
	miscLeft:Header({ Text = "Auto Execute" })
	miscLeft:Toggle({
		Name = "Auto execute after teleport",
		Default = hub.settings.autoExec,
		Callback = function(value)
			if not ui.suppress then
				setFlag("autoExec", value)
				task.spawn(pcall, hub.autoExec.queue)
			end
		end,
	})
	miscLeft:Label({ Text = "Reloads the hub on every new server, no autoexec file needed" })
	ui.autoExecLabel = miscLeft:Label({ Text = hub.autoExec.state })
	miscLeft:Header({ Text = "Performance" })
	miscLeft:Toggle({
		Name = "Fast Mode",
		Default = hub.settings.fastMode,
		Callback = function(value)
			if not ui.suppress then
				setFlag("fastMode", value)
				task.spawn(display.setFast, value)
			end
		end,
	})
	miscLeft:Toggle({
		Name = "Black Screen",
		Default = hub.settings.blackScreen,
		Callback = function(value)
			if not ui.suppress then
				setFlag("blackScreen", value)
				display.setBlack(value)
			end
		end,
	})
	miscLeft:Header({ Text = "Privacy" })
	miscLeft:Toggle({
		Name = "Hide My Name",
		Default = hub.settings.hideName,
		Callback = function(value)
			if not ui.suppress then
				setFlag("hideName", value)
				applyHideName()
			end
		end,
	})
	miscLeft:Input({
		Name = "Custom Level",
		Placeholder = "real level",
		Default = tostring(hub.settings.customLevel or ""),
		Callback = function(value)
			setFlag("customLevel", string.sub(tostring(value or ""), 1, 12))
			pcall(applyHideName)
		end,
	})

	miscLeft:Header({ Text = "Share Config" })
	ui.shareLabel = miscLeft:Label({ Text = "Copy your settings or paste a friend's code" })
	ui.shareState = function(text)
		pcall(function()
			ui.shareLabel:UpdateName(text)
		end)
		setStatus(text)
	end
	miscLeft:Button({
		Name = "Copy My Config",
		Callback = function()
			local ok, code = pcall(hub.shareConfig.export)
			if not ok or type(code) ~= "string" then
				ui.shareState("Could not build the config code")
				return
			end
			local copied = pcall(setclipboard, code) or pcall(toclipboard, code)
			ui.shareState(copied and ("Config copied (" .. #code .. " chars)") or "This executor cannot copy to the clipboard")
		end,
	})
	ui.shareInput = miscLeft:Input({
		Name = "Paste Code",
		Placeholder = "OrderHubAA:...",
		Default = "",
	})
	miscLeft:Button({
		Name = "Load Pasted Config",
		Callback = function()
			local text = ""
			pcall(function()
				text = ui.shareInput:GetInput()
			end)
			local ok, result = hub.shareConfig.import(text)
			ui.shareState(result)
			if ok then
				pcall(applyHideName)
				pcall(display.setBlack, hub.settings.blackScreen == true)
				task.defer(function()
					local current = ui.window
					if current then
						pcall(function()
							current:Unload()
						end)
						if ui.window == current then
							ui.window = nil
						end
					end
					task.wait(0.2)
					pcall(ui.reopen)
					setStatus(result)
				end)
			end
		end,
	})

	local miscRight = miscTab:Section({ Side = "Right" })
	miscRight:Header({ Text = "Webhook" })
	miscRight:Toggle({
		Name = "Webhook",
		Default = hub.settings.webhookOn,
		Callback = function(value)
			if not ui.suppress then
				setFlag("webhookOn", value)
				hub.webhook.setState(value and "On" or "Off")
			end
		end,
	})
	miscRight:Input({
		Name = "URL",
		Placeholder = "discord webhook",
		Default = tostring(hub.settings.webhookUrl or ""),
		Callback = function(value)
			local url = tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", "")
			setFlag("webhookUrl", url)
			hub.webhook.setState(url == "" and "No URL" or (hub.webhook.validUrl(url) and "Saved" or "Invalid URL"))
		end,
	})
	miscRight:Input({
		Name = "Ping ID",
		Placeholder = "unit / defeat",
		Default = tostring(hub.settings.webhookPing or ""),
		Callback = function(value)
			setFlag("webhookPing", (tostring(value or ""):gsub("%D", "")))
		end,
	})
	miscRight:Dropdown({
		Name = "Dungeon",
		Required = true,
		Options = { "Once per run", "Every room" },
		Default = hub.settings.webhookDungeonRooms and 2 or 1,
		Callback = function(value)
			if type(value) == "string" and not ui.suppress then
				setFlag("webhookDungeonRooms", value == "Every room")
			end
		end,
	})
	miscRight:Button({
		Name = "Test",
		Callback = function()
			task.spawn(hub.webhook.test)
		end,
	})
	ui.webhookLabel = miscRight:Label({ Text = hub.settings.webhookOn and "On" or "Off" })

	window.onUnloaded(function()
		if ui.window == window then
			ui.window = nil
			ui.status = nil
			ui.macroStatus = nil
			ui.macroDropdown = nil
			ui.macroName = nil
			ui.levelDropdown = nil
			ui.worldDropdown = nil
			ui.recordToggle = nil
			ui.playToggle = nil
			ui.summonToggle = nil
			ui.summonStatus = nil
			ui.autoPlayStatus = nil
			ui.autoPlayToggle = nil
			ui.teamGrid = nil
			ui.slotPopups = nil
			ui.modeLabel = nil
			ui.modeDropdown = nil
			eventTeam.refreshPickers = nil
			ui.followMode = nil
			ui.refreshRewardPicker = nil
			ui.refreshPortalPicker = nil
			ui.portalDropdown = nil
			ui.portalLabel = nil
			ui.refreshMerchantPicker = nil
			ui.refreshOrder = nil
			ui.refreshTeams = nil
			ui.prioritySlots = nil
			ui.teamDropdowns = nil
			ui.teamsParagraph = nil
			ui.teamsText = nil
			ui.teamKey = nil
			ui.challengeLabel = nil
			ui.priorityLabel = nil
			ui.merchantLabel = nil
			ui.mansionLabel = nil
			ui.webhookLabel = nil
			ui.shareLabel = nil
			ui.shareInput = nil
			ui.autoExecLabel = nil
			ui.rogueOrder = nil
			ui.lastPickLabel = nil
			ui.summerLabel = nil
			ui.summerShopLabel = nil
			ui.summerProgressLabel = nil
			ui.avoidDropdown = nil
			lobbyPlan.summerLabel = nil
			lobbyPlan.summerShopLabel = nil
			lobbyPlan.summerProgressLabel = nil
			lobbyPlan.challengeLabel = nil
			lobbyPlan.priorityLabel = nil
			lobbyPlan.merchantLabel = nil
			lobbyPlan.mansionLabel = nil
			lobbyPlan.portalLabel = nil
			hub.portal.namesKey = ""
		end
		if genv.HubWindow == window then
			genv.HubWindow = nil
		end
	end)

	hub.macroText = ""
	stageTab:Select()
end

ui.reopen = function()
	if ui.window or not hub.alive then
		return
	end
	local ok, err = pcall(buildUi)
	if not ok then
		setStatus("Reopen failed: " .. tostring(err))
	end
end

function hub.destroy()
	hub.alive = false
	genv.AnimeAdventureHandler = nil
	stopPlayback()
	hub.rec = nil
	for _, connection in ipairs(hub.conns) do
		pcall(function()
			connection:Disconnect()
		end)
	end
	table.clear(hub.conns)
	for _, thread in ipairs(hub.threads) do
		pcall(task.cancel, thread)
	end
	table.clear(hub.threads)
	pcall(applyHideName)
	pcall(display.cleanup)
	pcall(hub.slotWorth.clear)
	if ui.floatingGui then
		pcall(function()
			ui.floatingGui:Destroy()
		end)
		ui.floatingGui = nil
	end
	if ui.window then
		local window = ui.window
		ui.window = nil
		pcall(function()
			window:Unload()
		end)
	end
	placement.picking = false
	pcall(placement.clear, nil, true)
	if genv.AnimeAdventureRecorder == hookHandler then
		genv.AnimeAdventureRecorder = nil
	end
	if genv.AnimeAdventureHub == hub then
		genv.AnimeAdventureHub = nil
	end
end

hub.api = { startRecording = startRecording, stopRecording = stopRecording, playMacro = playMacro, stopPlayback = stopPlayback, joinLobby = joinLobby, startLobby = startLobby, finishAction = finishAction, setFlag = setFlag, setAnchorHere = setAnchorHere, clearAnchor = clearAnchor, placement = placement, buffLoop = buffLoop, dungeon = dungeon, skillRules = skillRules, slotConfig = slotConfig, bestSpot = bestSpot, buildCandidates = buildCandidates, display = display, eventTeam = eventTeam, showMode = function(mode)
	if ui.showMode then
		ui.showMode(mode)
	end
end }
loadConfig()
saveConfig()
buildLevels()
genv.AnimeAdventureHandler = nil

local okUi, errUi = pcall(buildUi)
if not okUi then
	hub.status = "UI failed: " .. tostring(errUi)
end
createFloatingButton()
if hub.settings.fastMode then
	task.spawn(display.setFast, true)
end
if hub.settings.blackScreen then
	pcall(display.setBlack, true)
end

connect(workspace.DescendantAdded, function(object)
	if nameMask.on and nameMask.isName(object) then
		task.defer(pcall, nameMask.watch, object)
	end
end)
connect(LocalPlayer.OnTeleport, function(state)
	pcall(eventTeam.onTeleport, state)
end)
connect(LocalPlayer.Idled, antiAfkNudge)
connect(UserInputService.InputBegan, function(input, processed)
	pcall(placement.onInput, input, processed)
end)
connect(UserInputService.InputEnded, function(input, processed)
	pcall(placement.onInputEnded, input, processed)
end)
connect(game:GetService("RunService").RenderStepped, function(dt)
	if placement.picking then
		pcall(placement.onFrame)
	end
	if next(placement.visuals) or #placement.closing > 0 then
		pcall(placement.animate, dt)
	end
end)
spawnThread(function()
	while hub.alive do
		task.wait(60)
		antiAfkNudge()
	end
end)

spawnThread(function()
	while hub.alive do
		pcall(resolvePending)
		pcall(refreshMacroStatus)
		pcall(applyHideName)
		if ui.dungeonStatus and os.clock() >= (dungeon.nextStatus or 0) then
			dungeon.nextStatus = os.clock() + 1
			local ok, text = pcall(dungeon.statusText)
			if ok and text ~= dungeon.text then
				dungeon.text = text
				pcall(function()
					ui.dungeonStatus:UpdateBody(text)
				end)
			end
		end
		pcall(display.tick)
		pcall(eventTeam.voteTick)
		if placement.resyncAt and os.clock() >= placement.resyncAt then
			placement.resyncAt = nil
			pcall(placement.resync)
		end
		if not placement.picking then
			pcall(placement.refresh)
		end
		task.wait(0.25)
	end
end)

spawnThread(function()
	while hub.alive do
		pcall(mainTick)
		pcall(lobbyPlan.refreshUi)
		task.wait(1)
	end
end)

spawnThread(function()
	while hub.alive do
		pcall(hub.slotWorth.refresh)
		task.wait(2)
	end
end)

task.spawn(pcall, hub.autoExec.queue)

spawnThread(function()
	while hub.alive do
		local present, started = gameState()
		if hub.settings.buffLoop and present and started and not hub.finishedAt then
			pcall(buffLoop.step)
			task.wait(0.15)
		else
			task.wait(0.5)
		end
	end
end)

spawnThread(function()
	while hub.alive do
		local ok, waitTime = pcall(autoPlayTick)
		if not ok then
			hub.autoPlay.state = "Error: " .. tostring(waitTime)
		end
		pcall(refreshAutoPlayStatus)
		task.wait((ok and tonumber(waitTime)) or 2)
	end
end)

spawnThread(function()
	while hub.alive do
		if hub.settings.autoPlay and os.clock() - (autoPlay.skillsLive or 0) < 4 and not hub.finishedAt then
			pcall(useSkills)
			task.wait(0.25)
		else
			task.wait(0.5)
		end
	end
end)

spawnThread(function()
	while hub.alive do
		local ok, waitTime = pcall(summonTick)
		pcall(refreshSummonStatus)
		task.wait((ok and tonumber(waitTime)) or 2)
	end
end)

spawnThread(function()
	while hub.alive do
		task.wait(1)
		pcall(refreshSummonStatus)
	end
end)

spawnThread(function()
	while hub.alive do
		task.wait(10)
		if not hub.rec then
			pcall(syncMacroFiles, false)
		end
	end
end)

hub.listen = function(name, fn)
	spawnThread(function()
		local remote
		local untilTime = os.clock() + 300
		while hub.alive and not remote and os.clock() < untilTime do
			local events = serverEvents()
			remote = events and events:FindFirstChild(name)
			if not remote then
				task.wait(1)
			end
		end
		if remote and hub.alive then
			connect(remote.OnClientEvent, fn)
		end
	end)
end

do
	local listen = hub.listen
	listen("matchmaking_started", function(...)
		pcall(eventTeam.onMatchmaking, ...)
	end)
	listen("matchmaking_ended", function()
		pcall(eventTeam.onMatchmakingEnded)
	end)
	listen("show_roguelike_options", function(...)
		local args = { ... }
		task.spawn(function()
			pcall(eventTeam.onOptions, table.unpack(args))
		end)
	end)
	listen("normal_challenge_changed", function()
		lobbyPlan.nextChallenge = 0
	end)
	listen("game_finished", function(result)
		if type(result) == "table" then
			hub.webhook.result = { data = result, job = game.JobId, at = os.clock() }
		end
		if not hub.finishedAt then
			onLevelFinished()
		end
	end)
	local function onMessage(text)
		hub.lastMessage = typeof(text) == "string" and text or tostring(text)
		hub.lastMessageAt = os.clock()
	end
	listen("show_message", onMessage)
	listen("units_hatched_through_banner", function(uuids)
		pcall(onUnitsHatched, uuids)
	end)
	listen("hatch_banner_changed", function()
		summon.nextFetch = 0
	end)
	listen("show_quick_message", onMessage)
	listen("replay_started", function()
		hub.round += 1
		hub.finishedAt = nil
		hub.replayAt = os.clock()
		hub.lastStarted = false
		stopPlayback()
		setStatus("Replaying level")
	end)
	listen("start_vote_wave_skip", function()
		if hub.settings.autoSkip then
			task.spawn(function()
				invoke("vote_wave_skip")
			end)
		end
	end)
end
