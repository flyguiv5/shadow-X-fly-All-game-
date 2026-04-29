-- SHADOW X FLY - JOYSTICK 3D CONTROL
local p = game.Players.LocalPlayer
local run = game:GetService("RunService")

local flying = false
local speed = 100
local bv, bg

-- Nút Bật/Tắt nhỏ gọn
local sg = Instance.new("ScreenGui", p:WaitForChild("PlayerGui"))
local FlyBtn = Instance.new("TextButton", sg)
FlyBtn.Size = UDim2.new(0, 100, 0, 40)
FlyBtn.Position = UDim2.new(0.5, -50, 0.05, 0)
FlyBtn.Text = "FLY: OFF"
FlyBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
FlyBtn.TextColor3 = Color3.new(1, 1, 1)
FlyBtn.Draggable = true

local function startFly()
    local char = p.Character
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end
    
    bv = Instance.new("BodyVelocity", root)
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.new(0,0,0)
    
    bg = Instance.new("BodyGyro", root)
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.CFrame = root.CFrame
    
    hum:ChangeState(Enum.HumanoidStateType.Physics)
    flying = true
    FlyBtn.Text = "FLY: ON"
    FlyBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
end

local function stopFly()
    flying = false
    FlyBtn.Text = "FLY: OFF"
    FlyBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
    if p.Character and p.Character:FindFirstChildOfClass("Humanoid") then 
        p.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.GettingUp)
    end
    if bv then bv:Destroy() end
    if bg then bg:Destroy() end
end

FlyBtn.MouseButton1Click:Connect(function()
    if flying then stopFly() else startFly() end
end)

run.RenderStepped:Connect(function()
    if flying and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
        local root = p.Character.HumanoidRootPart
        local hum = p.Character:FindFirstChildOfClass("Humanoid")
        local cam = workspace.CurrentCamera.CFrame
        
        -- Lấy hướng di chuyển thô từ Joystick
        local moveDir = hum.MoveDirection
        
        -- Luôn xoay nhân vật theo hướng Camera nhìn
        bg.CFrame = cam
        
        if moveDir.Magnitude > 0 then
            -- BÍ KÍP Ở ĐÂY:
            -- Lấy hướng Camera (cam.LookVector) nhân với độ mạnh của Joystick
            -- Nếu mày đẩy Joystick "tới", nó sẽ bay thẳng theo hướng tâm màn hình
            
            -- Tính toán vận tốc 3D
            local lookV = cam.LookVector
            local rightV = cam.RightVector
            
            -- Chuyển đổi MoveDirection sang hệ tọa độ Camera 3D
            -- moveDir.Z âm là đang đẩy Joystick tới
            local finalDir = (lookV * -moveDir.Z) + (rightV * moveDir.X)
            
            bv.Velocity = finalDir.Unit * speed
        else
            -- Đứng im lơ lửng khi không chạm Joystick
            bv.Velocity = Vector3.new(0, 0, 0)
        end
        
        -- Triệt tiêu trọng lực
        root.Velocity = Vector3.new(0,0,0)
    end
end)

-- Reset khi chết
p.CharacterAdded:Connect(function()
    task.wait(0.5)
    stopFly()
end)
