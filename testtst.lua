--[[
  ____  ____   ____     ____                  _ 
 | __ )| __ ) / ___|   |  _ \ __ _ _ __   ___| |
 |  _ \|  _ \| |  _    | |_) / _` | '_ \ / _ \ |
 | |_) | |_) | |_| |   |  __/ (_| | | | |  __/ |
 |____/|____/ \____|   |_|   \__,_|_| |_|\___|_|

Author: BBG's Art | BBG Panel Owner
Discord: https://discord.gg/cSthtkp5dD
CreateMacroWindow({title, slots, onStart, onStop})
]]

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui          = game:GetService("CoreGui")

-- Theme 
local T = {
    bg          = Color3.fromRGB(30, 30, 30),
    bgAlpha     = 0.1,
    rowBg       = Color3.fromRGB(20, 20, 20),
    rowAlpha    = 0.3,
    inputBg     = Color3.fromRGB(176, 176, 176),
    inputAlpha  = 0.3,
    dropBg      = Color3.fromRGB(25, 25, 25),
    dropAlpha   = 0.1,
    dropHover   = Color3.fromRGB(50, 50, 50),
    text        = Color3.fromRGB(255, 255, 255),
    subtext     = Color3.fromRGB(180, 180, 180),
    toggleOn    = Color3.fromRGB(80, 200, 80),
    toggleOff   = Color3.fromRGB(80, 80, 80),
    startOn     = Color3.fromRGB(50, 150, 50),
    startOff    = Color3.fromRGB(150, 50, 50),
    titleBg     = Color3.fromRGB(20, 20, 20),
    titleAlpha  = 0.2,
    font        = Enum.Font.GothamBold,
}

-- Helper 
local function corner(obj, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r)
    c.Parent = obj
end

local function tw(obj, t, props)
    TweenService:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Quint), props):Play()
end

-- Builder 
local function CreateMacroWindow(opts)
    opts       = opts or {}
    local title     = opts.title    or "BBG Macro"
    local slotCount = opts.slots    or 8
    local onStart   = opts.onStart  or function() end
    local onStop    = opts.onStop   or function() end

    local slotData = {}

    -- ScreenGui 
    local sg = Instance.new("ScreenGui")
    sg.Name           = "BBGMacroLibUI"
    sg.ResetOnSpawn   = false
    sg.DisplayOrder   = 1005
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    if not pcall(function() sg.Parent = CoreGui end) then
        sg.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    end

    -- Main Frame 
    local W = 210
    local SLOT_H = 118
    local TITLE_H = 30
    local BTN_H   = 32
    local PAD     = 6
    local SCROLL_H = 300

    local frame = Instance.new("Frame", sg)
    frame.Name                   = "MacroFrame"
    frame.Size                   = UDim2.new(0, W, 0, TITLE_H + SCROLL_H + PAD)
    frame.Position               = UDim2.new(0.1, 0, 0.3, 0)
    frame.BackgroundColor3       = T.bg
    frame.BackgroundTransparency = T.bgAlpha
    frame.Active                 = true
    corner(frame, 10)

    -- Floating Logo
    local logo = Instance.new("ImageButton", sg)
    logo.Size                   = UDim2.new(0, 38, 0, 38)
    logo.Position               = UDim2.new(0, 20, 0.5, -19)
    logo.BackgroundTransparency = 1
    logo.Image                  = "rbxassetid://104418583710842"
    logo.Active                 = true
    logo.Draggable              = true
    local logoCorner = Instance.new("UICorner", logo)
    logoCorner.CornerRadius = UDim.new(0, 12)

    logo.MouseButton1Click:Connect(function()
        frame.Visible = not frame.Visible
        if not frame.Visible then closeDropdown() end
    end)

    -- Drag
    local dragging, dragStart, frameStart = false, nil, nil
    local cam = workspace.CurrentCamera
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging   = true
            dragStart  = input.Position
            frameStart = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement or
            input.UserInputType == Enum.UserInputType.Touch
        ) then
            local d  = input.Position - dragStart
            local vp = cam.ViewportSize
            frame.Position = UDim2.new(0,
                math.clamp(frameStart.X.Offset + d.X, 0, vp.X - frame.AbsoluteSize.X),
                0,
                math.clamp(frameStart.Y.Offset + d.Y, 0, vp.Y - frame.AbsoluteSize.Y)
            )
            if dropMenu.Visible then dropMenu.Visible = false end
        end
    end)

    -- Title
    local titleLbl = Instance.new("TextLabel", frame)
    titleLbl.Size                   = UDim2.new(1, -12, 0, TITLE_H - 8)
    titleLbl.Position               = UDim2.new(0, 6, 0, 4)
    titleLbl.BackgroundColor3       = T.titleBg
    titleLbl.BackgroundTransparency = T.titleAlpha
    titleLbl.Text                   = title
    titleLbl.Font                   = T.font
    titleLbl.TextSize               = 12
    titleLbl.TextColor3             = T.text
    titleLbl.TextXAlignment         = Enum.TextXAlignment.Left
    local tp = Instance.new("UIPadding", titleLbl)
    tp.PaddingLeft = UDim.new(0, 8)
    corner(titleLbl, 8)

    -- ScrollingFrame
    local scroll = Instance.new("ScrollingFrame", frame)
    scroll.Size                = UDim2.new(1, -12, 0, SCROLL_H)
    scroll.Position            = UDim2.new(0, 6, 0, TITLE_H)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel     = 0
    scroll.ScrollBarThickness  = 4
    scroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.CanvasSize          = UDim2.new(0, 0, 0, 0)
    scroll.ScrollingDirection  = Enum.ScrollingDirection.Y
    scroll.ClipsDescendants    = true

    -- Shared Dropdown 
    local dropMenu = Instance.new("Frame", sg)
    dropMenu.Active = false
    dropMenu.Name                   = "MacroDropMenu"
    dropMenu.BackgroundColor3       = T.dropBg
    dropMenu.BackgroundTransparency = T.dropAlpha
    dropMenu.Visible                = false
    dropMenu.ZIndex                 = 20
    corner(dropMenu, 6)

    local dropLayout = Instance.new("UIListLayout", dropMenu)
    dropLayout.SortOrder = Enum.SortOrder.LayoutOrder
    dropLayout.Padding   = UDim.new(0, 0)

    local activeDropBtn = nil

    local function closeDropdown()
        dropMenu.Visible = false
        dropMenu.Active  = false
        activeDropBtn    = nil
    end

    local function openDropdown(triggerBtn, options, onSelect)
        if activeDropBtn == triggerBtn then
            closeDropdown(); return
        end
        activeDropBtn = triggerBtn

        for _, ch in ipairs(dropMenu:GetChildren()) do
            if ch:IsA("TextButton") then ch:Destroy() end
        end

        local itemH  = 22
        local absPos = triggerBtn.AbsolutePosition
        local absSize = triggerBtn.AbsoluteSize

        dropMenu.Size     = UDim2.new(0, absSize.X, 0, #options * itemH)
        dropMenu.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 2)

        for idx, opt in ipairs(options) do
            local btn = Instance.new("TextButton", dropMenu)
            btn.Size                   = UDim2.new(1, 0, 0, itemH)
            btn.BackgroundTransparency = 1
            btn.Text                   = opt
            btn.Font                   = T.font
            btn.TextSize               = 11
            btn.TextColor3             = T.subtext
            btn.TextXAlignment         = Enum.TextXAlignment.Left
            btn.ZIndex                 = 21
            btn.LayoutOrder            = idx

            local pad = Instance.new("UIPadding", btn)
            pad.PaddingLeft = UDim.new(0, 8)

            btn.MouseEnter:Connect(function()
                btn.BackgroundColor3       = T.dropHover
                btn.BackgroundTransparency = 0.3
            end)
            btn.MouseLeave:Connect(function()
                btn.BackgroundTransparency = 1
            end)
            btn.MouseButton1Click:Connect(function()
                onSelect(opt)
                closeDropdown()
            end)
        end

        dropMenu.Visible = true
        dropMenu.Active  = true
    end

    -- Close on outside click
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            if not dropMenu.Visible then return end
            task.wait(0.15)
            if not dropMenu.Visible then return end
            local mousePos = UserInputService:GetMouseLocation()
            local absPos   = dropMenu.AbsolutePosition
            local absSize  = dropMenu.AbsoluteSize
            local inside   = mousePos.X >= absPos.X
                and mousePos.X <= absPos.X + absSize.X
                and mousePos.Y >= absPos.Y
                and mousePos.Y <= absPos.Y + absSize.Y
            if not inside then closeDropdown() end
        end
    end)

    -- Slot Builder 
    local targets     = {"None", "Melee", "Sword", "Fruit", "Gun"}
    local movesByType = {
        None  = {"None"},
        Melee = {"None", "Z", "X", "C"},
        Sword = {"None", "Z", "X"},
        Fruit = {"None", "Z", "X", "C", "V", "F"},
        Gun   = {"None", "Z", "X"},
    }

    for i = 1, slotCount do
        local slot = {
            index  = i,
            type   = "None",
            move   = "None",
            delay  = 0.05,
            hold   = 0.0,
            active = false,
        }
        slotData[i] = slot

        local yOff = (i - 1) * (SLOT_H + 6)

        -- Slot container
        local container = Instance.new("Frame", scroll)
        container.Size                   = UDim2.new(1, 0, 0, SLOT_H)
        container.Position               = UDim2.new(0, 0, 0, yOff)
        container.BackgroundColor3       = T.rowBg
        container.BackgroundTransparency = T.rowAlpha
        corner(container, 8)

        -- Slot label
        local slotLbl = Instance.new("TextLabel", container)
        slotLbl.Size                   = UDim2.new(1, -12, 0, 20)
        slotLbl.Position               = UDim2.new(0, 6, 0, 4)
        slotLbl.BackgroundTransparency = 1
        slotLbl.Text                   = "Slot " .. i
        slotLbl.Font                   = T.font
        slotLbl.TextSize               = 11
        slotLbl.TextColor3             = T.subtext
        slotLbl.TextXAlignment         = Enum.TextXAlignment.Left

        -- Row 1: Delay + Hold 
        local function makeInput(parent, x, w, default, onChange)
            local bg = Instance.new("Frame", parent)
            bg.Size             = UDim2.new(0, w, 0, 20)
            bg.Position         = UDim2.new(0, x, 0.5, -10)
            bg.BackgroundColor3 = T.inputBg
            bg.BackgroundTransparency = T.inputAlpha
            corner(bg, 5)

            local box = Instance.new("TextBox", bg)
            box.Size                   = UDim2.new(1, -6, 1, 0)
            box.Position               = UDim2.new(0, 3, 0, 0)
            box.BackgroundTransparency = 1
            box.Text                   = default
            box.Font                   = T.font
            box.TextSize               = 11
            box.TextColor3             = T.text
            box.TextXAlignment         = Enum.TextXAlignment.Center
            box.ClearTextOnFocus       = false
            box.FocusLost:Connect(function()
                local n = tonumber(box.Text)
                if n then onChange(math.max(0, n)) end
            end)
            return box
        end

        -- Row 1 frame
        local row1 = Instance.new("Frame", container)
        row1.Size                   = UDim2.new(1, -12, 0, 24)
        row1.Position               = UDim2.new(0, 6, 0, 26)
        row1.BackgroundTransparency = 1

        -- Delay label + box
        local delayLbl = Instance.new("TextLabel", row1)
        delayLbl.Size = UDim2.new(0, 36, 1, 0); delayLbl.Position = UDim2.new(0, 0, 0, 0)
        delayLbl.BackgroundTransparency = 1; delayLbl.Text = "Delay"
        delayLbl.Font = T.font; delayLbl.TextSize = 10; delayLbl.TextColor3 = T.subtext
        delayLbl.TextXAlignment = Enum.TextXAlignment.Left

        makeInput(row1, 38, 50, "0.05", function(n) slot.delay = n end)

        -- Hold label + box
        local holdLbl = Instance.new("TextLabel", row1)
        holdLbl.Size = UDim2.new(0, 30, 1, 0); holdLbl.Position = UDim2.new(0, 96, 0, 0)
        holdLbl.BackgroundTransparency = 1; holdLbl.Text = "Hold"
        holdLbl.Font = T.font; holdLbl.TextSize = 10; holdLbl.TextColor3 = T.subtext
        holdLbl.TextXAlignment = Enum.TextXAlignment.Left

        makeInput(row1, 128, 50, "0.0", function(n) slot.hold = n end)

        -- Row 2: Type dropdown 
        local row2 = Instance.new("Frame", container)
        row2.Size                   = UDim2.new(1, -12, 0, 24)
        row2.Position               = UDim2.new(0, 6, 0, 54)
        row2.BackgroundTransparency = 1

        local typeLbl = Instance.new("TextLabel", row2)
        typeLbl.Size = UDim2.new(0, 36, 1, 0); typeLbl.Position = UDim2.new(0, 0, 0, 0)
        typeLbl.BackgroundTransparency = 1; typeLbl.Text = "Type"
        typeLbl.Font = T.font; typeLbl.TextSize = 10; typeLbl.TextColor3 = T.subtext
        typeLbl.TextXAlignment = Enum.TextXAlignment.Left

        local typeBtn = Instance.new("TextButton", row2)
        typeBtn.Size                   = UDim2.new(0, 140, 0, 20)
        typeBtn.Position               = UDim2.new(0, 38, 0.5, -10)
        typeBtn.BackgroundColor3       = T.dropBg
        typeBtn.BackgroundTransparency = 0.1
        typeBtn.Text                   = "None"
        typeBtn.Font                   = T.font
        typeBtn.TextSize               = 11
        typeBtn.TextColor3             = T.text
        corner(typeBtn, 5)

        -- Move dropdown button (declared here, used below)
        local moveBtn

        typeBtn.MouseButton1Click:Connect(function()
            openDropdown(typeBtn, targets, function(val)
                slot.type = val
                slot.move = "None"
                typeBtn.Text = val
                if moveBtn then moveBtn.Text = "None" end
            end)
        end)

        -- Row 3: Move dropdown 
        local row3 = Instance.new("Frame", container)
        row3.Size                   = UDim2.new(1, -12, 0, 24)
        row3.Position               = UDim2.new(0, 6, 0, 82)
        row3.BackgroundTransparency = 1

        local moveLbl = Instance.new("TextLabel", row3)
        moveLbl.Size = UDim2.new(0, 36, 1, 0); moveLbl.Position = UDim2.new(0, 0, 0, 0)
        moveLbl.BackgroundTransparency = 1; moveLbl.Text = "Move"
        moveLbl.Font = T.font; moveLbl.TextSize = 10; moveLbl.TextColor3 = T.subtext
        moveLbl.TextXAlignment = Enum.TextXAlignment.Left

        moveBtn = Instance.new("TextButton", row3)
        moveBtn.Size                   = UDim2.new(0, 100, 0, 20)
        moveBtn.Position               = UDim2.new(0, 38, 0.5, -10)
        moveBtn.BackgroundColor3       = T.dropBg
        moveBtn.BackgroundTransparency = 0.1
        moveBtn.Text                   = "None"
        moveBtn.Font                   = T.font
        moveBtn.TextSize               = 11
        moveBtn.TextColor3             = T.text
        corner(moveBtn, 5)

        -- Enable toggle (right side of move row)
        local track = Instance.new("Frame", row3)
        track.Size             = UDim2.new(0, 36, 0, 18)
        track.Position         = UDim2.new(1, -36, 0.5, -9)
        track.BackgroundColor3 = T.toggleOff
        corner(track, 9)

        local handle = Instance.new("Frame", track)
        handle.Size             = UDim2.new(0, 14, 0, 14)
        handle.Position         = UDim2.new(0, 2, 0.5, -7)
        handle.BackgroundColor3 = Color3.new(1, 1, 1)
        corner(handle, 7)

        local trackBtn = Instance.new("TextButton", row3)
        trackBtn.Size                   = UDim2.new(0, 36, 0, 18)
        trackBtn.Position               = UDim2.new(1, -36, 0.5, -9)
        trackBtn.BackgroundTransparency = 1
        trackBtn.Text                   = ""
        trackBtn.ZIndex                 = 10

        local togOn = false
        trackBtn.MouseButton1Click:Connect(function()
            togOn      = not togOn
            slot.active = togOn
            tw(track, 0.1, { BackgroundColor3 = togOn and T.toggleOn or T.toggleOff })
            TweenService:Create(handle, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Position = togOn
                    and UDim2.new(1, -16, 0.5, -7)
                    or  UDim2.new(0,  2,  0.5, -7)
            }):Play()
        end)

        moveBtn.MouseButton1Click:Connect(function()
            local moves = movesByType[slot.type] or {"None"}
            openDropdown(moveBtn, moves, function(val)
                slot.move = val
                moveBtn.Text = val
            end)
        end)
    end

    -- Start / Stop Button
    local isRunning = false

    local startBtn = Instance.new("TextButton", frame)
    startBtn.Size                   = UDim2.new(1, -12, 0, 32)
    startBtn.Position               = UDim2.new(0, 6, 1, -38)
    startBtn.BackgroundColor3       = T.startOff
    startBtn.BackgroundTransparency = 0.1
    startBtn.Text                   = "Start"
    startBtn.Font                   = T.font
    startBtn.TextSize               = 13
    startBtn.TextColor3             = T.text
    corner(startBtn, 8)

    startBtn.MouseButton1Click:Connect(function()
        isRunning = not isRunning
        if isRunning then
            tw(startBtn, 0.15, { BackgroundColor3 = T.startOn })
            startBtn.Text = "Stop"
            onStart(slotData)
        else
            tw(startBtn, 0.15, { BackgroundColor3 = T.startOff })
            startBtn.Text = "Start"
            onStop()
        end
    end)

    return {
        ScreenGui = sg,
        Frame     = frame,
        Logo      = logo,
        SlotData  = slotData,
        Destroy   = function()
            closeDropdown()
            sg:Destroy()
        end,
    }
end

return CreateMacroWindow
