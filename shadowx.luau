--!strict
--[[
    SHADOW X - LUAU EDITION
    Tối ưu hóa cho Delta X & Mobile
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local flying: boolean = false
local speed: number = 100

-- Khai báo Type để Luau check lỗi cho xịn
type FlightCore = {
    bv: BodyVelocity?,
    bg: BodyGyro?
}

local core: FlightCore = {
    bv = nil,
    bg = nil
}

-- Giao diện Shadow X
local sg = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
sg.Name = "ShadowX_Luau"

local FlyBtn = Instance.new("TextButton", sg)
FlyBtn.Size = UDim2.new(0, 120, 0, 45)
FlyBtn.Position = UDim2.new(0.5, -60, 0.05, 0)
FlyBtn.Text = "LUAU FLY: OFF"
FlyBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
FlyBtn.TextColor3 = Color3.new(1, 1, 1)
FlyBtn.Draggable = true

Instance.new("UICorner", FlyBtn).CornerRadius = UDim.new(0, 10)

local function toggleFlight()
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart") :: BasePart?
    local hum = char:FindFirstChildOfClass("Humanoid")
    
    if not root or not hum then return end

    if not flying then
        -- Start Flying
        core.bv = Instance.new("BodyVelocity", root)
        core.bv.Name = "ShadowX_Vel"
        core.bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        
        core.bg = Instance.new("BodyGyro", root)
        core.bg.Name = "ShadowX_Gyro"
        core.bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        
        hum:ChangeState(Enum.HumanoidStateType.Physics)
        flying = true
        FlyBtn.Text = "LUAU FLY: ON"
        FlyBtn.BackgroundColor3 = Color3.fromRGB(138, 43, 226) -- Màu tím Luau
    else
        -- Stop Flying
        flying = false
        FlyBtn.Text = "LUAU FLY: OFF"
        FlyBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        if core.bv then core.bv:Destroy() end
        if core.bg then core.bg:Destroy() end
    end
end

FlyBtn.MouseButton1Click:Connect(toggleFlight)

-- Vòng lặp xử lý logic (Dùng task.spawn để tối ưu hiệu năng Luau)
RunService.RenderStepped:Connect(function()
    if flying and player.Character then
        local root = player.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        local cam = workspace.CurrentCamera.CFrame
        
        if root and hum and core.bv and core.bg then
            local moveDir = hum.MoveDirection
            core.bg.CFrame = cam
            
            if moveDir.Magnitude > 0 then
                -- Joystick 3D Logic
                local finalDir = (cam.LookVector * -moveDir.Z) + (cam.RightVector * moveDir.X)
                core.bv.Velocity = finalDir.Unit * speed
            else
                core.bv.Velocity = Vector3.new(0, 0, 0)
            end
            root.Velocity = Vector3.new(0, 0, 0)
        end
    end
end)
