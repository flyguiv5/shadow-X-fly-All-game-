--!strict
-- [[ SHADOW X FLY - LUAU EDITION ]]
-- Loader: loadstring(game:HttpGet("https://raw.githubusercontent.com/flyguiv5/shadow-X-fly-All-game-/main/shadowx.luau"))()

-- 1. CHỜ GAME LOAD (Task Wait & Repeat chuẩn Luau)
if not game:IsLoaded() then
    game.Loaded:Wait()
end

repeat task.wait() until game.Players.LocalPlayer
local p = game.Players.LocalPlayer
repeat task.wait() until p.Character and p.Character:FindFirstChild("HumanoidRootPart")

local run = game:GetService("RunService")
local uis = game:GetService("UserInputService")

-- 2. CẤU HÌNH
local flying = false
local speed = 100
local bv: BodyVelocity? = nil
local bg: BodyGyro? = nil

-- 3. GIAO DIỆN NÚT BẤM (GUI)
local sg = Instance.new("ScreenGui", p:WaitForChild("PlayerGui"))
sg.Name = "ShadowX_Global"
sg.ResetOnSpawn = false

local FlyBtn = Instance.new("TextButton", sg)
FlyBtn.Size = UDim2.new(0, 120, 0, 45)
FlyBtn.Position = UDim2.new(0.5, -60, 0.05, 0)
FlyBtn.Text = "SHADOW X: OFF"
FlyBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
FlyBtn.TextColor3 = Color3.new(1, 1, 1)
FlyBtn.Font = Enum.Font.GothamBold
FlyBtn.Draggable = true

local corner = Instance.new("UICorner", FlyBtn)
corner.CornerRadius = UDim.new(0, 10)

-- 4. HÀM ĐIỀU KHIỂN
local function toggleFly()
    local char = p.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart") :: BasePart?
    local hum = char:FindFirstChildOfClass("Humanoid")
    
    if not root or not hum then return end

    if not flying then
        -- Bật bay
        bv = Instance.new("BodyVelocity", root)
        bv.Name = "ShadowX_Vel"
        bv.MaxForce = Vector3.new(1, 1, 1) * math.huge
        bv.Velocity = Vector3.new(0, 0, 0)
        
        bg = Instance.new("BodyGyro", root)
        bg.Name = "ShadowX_Gyro"
        bg.MaxTorque = Vector3.new(1, 1, 1) * math.huge
        bg.P = 5000
        bg.CFrame = root.CFrame
        
        hum:ChangeState(Enum.HumanoidStateType.Physics)
        flying = true
        FlyBtn.Text = "SHADOW X: ON"
        FlyBtn.BackgroundColor3 = Color3.fromRGB(138, 43, 226) -- Màu tím Luau
    else
        -- Tắt bay
        flying = false
        FlyBtn.Text = "SHADOW X: OFF"
        FlyBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
    end
end

-- 5. KẾT NỐI SỰ KIỆN
FlyBtn.MouseButton1Click:Connect(toggleFly)

-- Phím tắt Q cho PC hoặc bàn phím rời
uis.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.Q then
        toggleFly()
    end
end)

-- 6. VÒNG LẶP DI CHUYỂN (Joystick 3D)
run.RenderStepped:Connect(function()
    if flying and p.Character then
        local char = p.Character
        local root = char:FindFirstChild("HumanoidRootPart") :: BasePart?
        local hum = char:FindFirstChildOfClass("Humanoid")
        local cam = workspace.CurrentCamera.CFrame
        
        if root and hum and bv and bg then
            local moveDir = hum.MoveDirection
            bg.CFrame = cam
            
            if moveDir.Magnitude > 0 then
                -- Bay theo hướng camera nhìn bằng Joystick
                local finalDir = (cam.LookVector * -moveDir.Z) + (cam.RightVector * moveDir.X)
                bv.Velocity = finalDir.Unit * speed
            else
                bv.Velocity = Vector3.new(0, 0, 0)
            end
            root.Velocity = Vector3.new(0, 0, 0)
        end
    end
end)

-- Reset khi nhân vật chết
p.CharacterAdded:Connect(function()
    task.wait(1)
    if flying then
        flying = false
        toggleFly()
    end
end)

print("Shadow X Fly: Luau Version Loaded!")
