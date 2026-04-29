--!strict
-- [[ SHADOW X FLY - LUAU EDITION ]] --

-- 1. Đợi game và nhân vật load xong (Chống lỗi Index Nil)
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- Đợi nhân vật xuất hiện
local character = player.Character or player.CharacterAdded:Wait()

-- 2. Cấu hình
local flying: boolean = false
local speed: number = 100
local bv: BodyVelocity? = nil
local bg: BodyGyro? = nil

-- 3. Tạo Giao diện (GUI)
local sg = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
sg.Name = "ShadowX_Global"
sg.ResetOnSpawn = false

local FlyBtn = Instance.new("TextButton", sg)
FlyBtn.Size = UDim2.new(0, 120, 0, 45)
FlyBtn.Position = UDim2.new(0.5, -60, 0.05, 0)
FlyBtn.Text = "SHADOW X: OFF"
FlyBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
FlyBtn.TextColor3 = Color3.new(1, 1, 1)
FlyBtn.Font = Enum.Font.GothamBold
FlyBtn.Draggable = true

local corner = Instance.new("UICorner", FlyBtn)
corner.CornerRadius = UDim.new(0, 10)

-- 4. Hàm điều khiển bay
local function toggleFly()
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart") :: BasePart?
    local hum = char:FindFirstChildOfClass("Humanoid")
    
    if not root or not hum then return end

    if not flying then
        -- Bật bay
        bv = Instance.new("BodyVelocity", root)
        bv.Name = "ShadowX_Vel"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        
        bg = Instance.new("BodyGyro", root)
        bg.Name = "ShadowX_Gyro"
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bg.P = 5000
        
        hum:ChangeState(Enum.HumanoidStateType.Physics)
        flying = true
        FlyBtn.Text = "SHADOW X: ON"
        FlyBtn.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
    else
        -- Tắt bay
        flying = false
        FlyBtn.Text = "SHADOW X: OFF"
        FlyBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
    end
end

FlyBtn.MouseButton1Click:Connect(toggleFly)

-- 5. Vòng lặp di chuyển Joystick 3D
RunService.RenderStepped:Connect(function()
    if flying and player.Character then
        local char = player.Character
        local root = char:FindFirstChild("HumanoidRootPart") :: BasePart?
        local hum = char:FindFirstChildOfClass("Humanoid")
        local cam = workspace.CurrentCamera.CFrame
        
        if root and hum and bv and bg then
            local moveDir = hum.MoveDirection
            bg.CFrame = cam
            
            if moveDir.Magnitude > 0 then
                -- Bay theo hướng camera nhìn
                local finalDir = (cam.LookVector * -moveDir.Z) + (cam.RightVector * moveDir.X)
                bv.Velocity = finalDir.Unit * speed
            else
                bv.Velocity = Vector3.new(0, 0, 0)
            end
            root.Velocity = Vector3.new(0, 0, 0)
        end
    end
end)

-- 6. Hỗ trợ reset nhân vật
player.CharacterAdded:Connect(function(newChar)
    task.wait(1)
    if flying then
        flying = false -- Reset trạng thái để start lại sạch sẽ
        toggleFly()
    end
end)

print("Shadow X Fly Loaded Successfully!")
