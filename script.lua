-- إعداد الرتب
local Owners = {"s2ikx2", "Ex1Owner", "TylerHub", "name4", "name5", "name6", "name7"}
local Admins = {"noob_zombie91", "The_king6096", "admin3"}

-- إعدادات عامة
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ChatService = game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local prefix = "!"

-- حفظ الإحداثيات عند respawn
local savedPosition = nil
local spamOn = false
local spamText = ""
local lastCharCommand = nil

-- رسائل عند التشغيل
local function sendStartupMessages()
    for _, msg in pairs({
        "تم تشغيل السكربت",
        "تم تصميم السكربت بواسطة تايلر",
        "حقوق الساااطي تايلر"
    }) do
        game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
    end
end

sendStartupMessages()

-- تصنيف الرتبة
local function getRank(name)
    for _, v in ipairs(Owners) do
        if v:lower() == name:lower() then return "Owner" end
    end
    for _, v in ipairs(Admins) do
        if v:lower() == name:lower() then return "Admin" end
    end
    return "User"
end

-- إظهار إشعار
local function notify(title, text)
    game.StarterGui:SetCore("SendNotification", {
        Title = title;
        Text = text;
        Duration = 5;
    })
end

-- طيران
function flyFunc(state)
    local IsOnMobile = UserInputService.TouchEnabled
    if state then
        if not IsOnMobile then
            if _G.NOFLY then _G.NOFLY() end
            wait()
            if _G.sFLY then _G.sFLY() end
        else
            if _G.mobilefly then _G.mobilefly(LocalPlayer) end
        end
    else
        if not IsOnMobile then
            if _G.NOFLY then _G.NOFLY() end
        else
            if _G.unmobilefly then _G.unmobilefly(LocalPlayer) end
        end
    end
end

-- تنفيذ أمر بنج
local function executeBang(targetName, speaker)
    local target = nil
    -- البحث عن اللاعب باستخدام الأسم الجزئي (الاسم غير حساس لحالة الحروف)
    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Name:lower():find(targetName:lower()) then
            target = plr
            break
        end
    end
    if not target then return end

    local humanoid = speaker.Character and speaker.Character:FindFirstChildWhichIsA("Humanoid")
    if not humanoid then return end

    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://148840371"
    local loadedAnim = humanoid:LoadAnimation(anim)
    loadedAnim:Play()
    loadedAnim:AdjustSpeed(3)

    local hrp = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    local speakerHRP = speaker.Character and speaker.Character:FindFirstChild("HumanoidRootPart")

    if hrp and speakerHRP then
        for i = 1, 60 do
            RunService.RenderStepped:Wait()
            speakerHRP.CFrame = hrp.CFrame * CFrame.new(0, 0, 1.1)
        end
    end

    loadedAnim:Stop()
    anim:Destroy()
end

-- أمر bang/unbang
local function unBang()
    if _G.bang then _G.bang:Stop() end
    if _G.bangAnim then _G.bangAnim:Destroy() end
    if _G.bangLoop then _G.bangLoop:Disconnect() end
end

-- تنفيذ الأمر
local function executeCommand(message)
    if not message:match("^"..prefix) then return end
    local args = message:sub(#prefix+1):split(" ")
    local cmd = args[1]:lower()
    local rank = getRank(LocalPlayer.Name)

    -- أوامر العاديين
    if cmd == "fly" then flyFunc(true)
    elseif cmd == "unfly" then flyFunc(false)
    elseif cmd == "to" then
        local target = Players:FindFirstChild(args[2])
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(2, 0, 2)
        end
    elseif cmd == "atb" then
        local originalPos = LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame
        for i = 1, 5 do
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(9999*i, 9999*i, 9999*i)
            wait(2)
            LocalPlayer.Character.HumanoidRootPart.CFrame = originalPos
            wait(3)
        end
    elseif cmd == "char" then
        if lastCharCommand == nil then
            lastCharCommand = "char"
            game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(";char me", "All")
        elseif lastCharCommand == "char" then
            lastCharCommand = "unchar"
            game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(";unchar", "All")
        end
    elseif cmd == "re" then
        savedPosition = LocalPlayer.Character.HumanoidRootPart.Position
        LocalPlayer.Character:BreakJoints()
        LocalPlayer.CharacterAdded:Wait():WaitForChild("HumanoidRootPart").CFrame = CFrame.new(savedPosition)
    elseif cmd == "antikill" then
        LocalPlayer.Character:WaitForChild("Humanoid").Health = 999999
        LocalPlayer.Character.Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
            LocalPlayer.Character.Humanoid.Health = 999999
        end)
    elseif cmd == "antibang" then
        local originalPos = LocalPlayer.Character.HumanoidRootPart.CFrame
        for i = 1, 3 do
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-760.4, -503.3, 491.9)
            wait(2)
            LocalPlayer.Character.HumanoidRootPart.CFrame = originalPos
            wait(1)
        end
    elseif cmd == "dkick" then
        pcall(function()
            workspace.Model:GetChildren()[1044]:Destroy()
            workspace.Model:GetChildren()[1045]:Destroy()
        end)
    elseif cmd == "bang" then
        executeBang(args[2], LocalPlayer)
    elseif cmd == "unbang" then
        unBang()
    elseif cmd == "spam" then
        spamOn = true
        spamText = table.concat(args, " ", 2)
        coroutine.wrap(function()
            while spamOn do
                game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(spamText, "All")
                wait(0.7)
            end
        end)()
    elseif cmd == "unspam" then
        spamOn = false
    elseif cmd == "nv" then
        for _, v in pairs(Players:GetPlayers()) do
            if v.Character and v.Character:FindFirstChild("Head") then
                local tag = Instance.new("BillboardGui", v.Character.Head)
                tag.Size = UDim2.new(0, 200, 0, 50)
                tag.StudsOffset = Vector3.new(0, 3, 0)
                tag.AlwaysOnTop = true
                local text = Instance.new("TextLabel", tag)
                text.Size = UDim2.new(1, 0, 1, 0)
                text.BackgroundTransparency = 1
                text.Text = v.Name
                text.TextColor3 = Color3.fromRGB(255, 255, 255)
                text.TextScaled = true
            end
        end
    elseif cmd == "unnv" then
        for _, v in pairs(Players:GetPlayers()) do
            if v.Character and v.Character:FindFirstChild("Head") then
                for _, g in pairs(v.Character.Head:GetChildren()) do
                    if g:IsA("BillboardGui") then g:Destroy() end
                end
            end
        end
    elseif cmd == "lgg" then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-10965870.0, 31274242.0, -3855789.5)
    elseif cmd == "unlgg" and savedPosition then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(savedPosition)
    end

    -- أوامر الرتب فقط
    if rank ~= "User" then
        if cmd == "checkusers" then
            for _, plr in pairs(Players:GetPlayers()) do
                if getRank(LocalPlayer.Name) == "Owner" or (getRank(LocalPlayer.Name) == "Admin" and getRank(plr.Name) == "User") then
                    game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("انا استخدم السكربت", "All")
                end
            end
        elseif cmd == "kick" then
            local target = Players:FindFirstChild(args[2])
            if target and (rank == "Owner" or (rank == "Admin" and getRank(target.Name) == "User")) then
                target:Kick("تم طردك")
            end
        elseif cmd == "tp" then
            local target = Players:FindFirstChild(args[2])
            if target and (rank == "Owner" or (rank == "Admin" and getRank(target.Name) == "User")) then
                target.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
            end
        end
    end
end

-- استماع للدردشة
LocalPlayer.Chatted:Connect(executeCommand)

-- إشعار حسب الرتبة
notify("تم تشغيل السكربت", "رتبتك: "..getRank(LocalPlayer.Name))

-- طباعة أوامر الرتبة
print("[سكربت تايلر] تم التشغيل. رتبتك: "..getRank(LocalPlayer.Name))
