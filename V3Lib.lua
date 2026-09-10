--[[
  ____  ____   ____     ____                  _ 
 | __ )| __ ) / ___|   |  _ \ __ _ _ __   ___| |
 |  _ \|  _ \| |  _    | |_) / _` | '_ \ / _ \ |
 | |_) | |_) | |_| |   |  __/ (_| | | | |  __/ |
 |____/|____/ \____|   |_|   \__,_|_| |_|\___|_|

Author: BBG's Art | BBG Panel Owner
Discord: https://discord.gg/cSthtkp5dD
V3: Simple Clickable Label, Crimson Theme, 4:3 Rectangle
]]

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui          = game:GetService("CoreGui")

local function CreateMiniClicker(opts)
    opts = opts or {}

    local defaultText = opts.defaultText or "Click Me"
    local clickedText = opts.clickedText or "Clicked!"
    local onToggle    = opts.callback    or function() end

    local W = opts.width  or 120
    local H = opts.height or 90  -- ~4:3

    local isClicked = opts.default or false

    -- ScreenGui 
    local sg = Instance.new("ScreenGui")
    sg.Name           = "BBGMiniClicker"
    sg.ResetOnSpawn   = false
    sg.DisplayOrder   = 1003
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    if not pcall(function() sg.Parent = CoreGui end) then
        sg.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    end

    -- Main Frame 
    local frame = Instance.new("Frame", sg)
    frame.Name                   = "ClickerFrame"
    frame.Size                   = UDim2.new(0, W, 0, H)
    frame.Position               = UDim2.new(0, 100, 0.5, -(H / 2))
    frame.BackgroundColor3       = Color3.fromHex("1c0606")
    frame.BackgroundTransparency = 0.15
    frame.Active                 = true

    -- Drag logic
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
            local delta = input.Position - dragStart
            local vp    = cam.ViewportSize
            frame.Position = UDim2.new(0,
                math.clamp(frameStart.X.Offset + delta.X, 0, vp.X - frame.AbsoluteSize.X),
                0,
                math.clamp(frameStart.Y.Offset + delta.Y, 0, vp.Y - frame.AbsoluteSize.Y)
            )
        end
    end)

    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 8)

    local stroke = Instance.new("UIStroke", frame)
    stroke.Color           = Color3.fromHex("ef4444")
    stroke.Thickness       = 1.2
    stroke.Transparency    = 0.75
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local grad = Instance.new("UIGradient", frame)
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromHex("2c0808")),
        ColorSequenceKeypoint.new(1, Color3.fromHex("110303")),
    })
    grad.Rotation = 140
    grad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.3),
        NumberSequenceKeypoint.new(1, 0.0),
    })

    -- Clickable Label 
    local btn = Instance.new("TextButton", frame)
    btn.Size                   = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text                   = isClicked and clickedText or defaultText
    btn.Font                   = Enum.Font.GothamBold
    btn.TextSize               = 13
    btn.TextColor3             = Color3.fromHex("fef2f2")
    btn.TextXAlignment         = Enum.TextXAlignment.Center
    btn.ZIndex                 = 10

    -- Click logic 
    btn.MouseButton1Click:Connect(function()
        isClicked = not isClicked
        btn.Text  = isClicked and clickedText or defaultText
        TweenService:Create(frame, TweenInfo.new(0.1), {
            BackgroundColor3 = isClicked
                and Color3.fromHex("3d0a0a")
                or  Color3.fromHex("1c0606")
        }):Play()
        pcall(onToggle, isClicked)
    end)

    -- Hover effect 
    btn.MouseEnter:Connect(function()
        TweenService:Create(frame, TweenInfo.new(0.1), {
            BackgroundTransparency = 0.05
        }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(frame, TweenInfo.new(0.1), {
            BackgroundTransparency = 0.15
        }):Play()
    end)

    -- Public API 
    return {
        ScreenGui = sg,
        Frame     = frame,
        SetState  = function(state)
            isClicked = state
            btn.Text  = state and clickedText or defaultText
        end,
        Destroy   = function() sg:Destroy() end,
    }
end

return CreateMiniClicker