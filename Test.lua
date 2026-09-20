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

local TweenService = game:GetService("TweenService")
local CoreGui      = game:GetService("CoreGui")

local function CreateMiniClicker(opts)
    opts = opts or {}

    local defaultText = opts.defaultText or "Click Me"
    local clickedText = opts.clickedText or "Clicked!"
    local onToggle    = opts.callback    or function() end
    local W           = opts.width       or 120
    local H           = opts.height      or 90
    local isClicked   = opts.default     or false

    -- ScreenGui
    local sg = Instance.new("ScreenGui")
    sg.Name           = "BBGMiniClicker"
    sg.ResetOnSpawn   = false
    sg.DisplayOrder   = 1006
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    if not pcall(function() sg.Parent = CoreGui end) then
        sg.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    end

    -- Main Button 
    local btn = Instance.new("TextButton", sg)
    btn.Name                   = "ClickerBtn"
    btn.Size                   = UDim2.new(0, W, 0, H)
    btn.Position               = UDim2.new(0, 100, 0.5, -(H / 2))
    btn.BackgroundColor3       = Color3.fromHex("1c0606")
    btn.BackgroundTransparency = 0.15
    btn.Text                   = isClicked and clickedText or defaultText
    btn.Font                   = Enum.Font.GothamBold
    btn.TextSize               = 13
    btn.TextColor3             = Color3.new(1, 1, 1)
    btn.TextXAlignment         = Enum.TextXAlignment.Center
    btn.Active                 = true
    btn.Draggable              = true

    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 8)

    local stroke = Instance.new("UIStroke", btn)
    stroke.Color           = Color3.fromHex("ef4444")
    stroke.Thickness       = 1.2
    stroke.Transparency    = 0.75
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    -- Click Logic
    btn.MouseButton1Click:Connect(function()
        isClicked = not isClicked
        btn.Text  = isClicked and clickedText or defaultText
        TweenService:Create(btn, TweenInfo.new(0.1), {
            BackgroundColor3 = isClicked
                and Color3.fromHex("3d0a0a")
                or  Color3.fromHex("1c0606")
        }):Play()
        pcall(onToggle, isClicked)
    end)

    -- Hover Effect
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {
            BackgroundTransparency = 0.05
        }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {
            BackgroundTransparency = 0.15
        }):Play()
    end)

    -- Public API
    return {
        ScreenGui = sg,
        Frame     = btn,
        SetState  = function(state)
            isClicked = state
            btn.Text  = state and clickedText or defaultText
        end,
        Destroy = function() sg:Destroy() end,
    }
end

return CreateMiniClicker
