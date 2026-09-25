-- Mount Sorry: AUTO RESET CHECKPOINT + AUTO GIFT
-- Target: RiEzKhI | Gift timeout: 5 seconds

local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local CoreGui=game:GetService("CoreGui")
local LP=Players.LocalPlayer

local TARGET_NAME="RiEzKhI"
local GIFT_TIMEOUT=5
local AutoReset=false
local AutoGift=false
local GiftRunning=false
local LastReset=0

local LavaKit=ReplicatedStorage:WaitForChild("LavaSummitKit")
local LavaRemotes=LavaKit:WaitForChild("Remotes")
local ResetCheckpoint=LavaRemotes:WaitForChild("ResetCheckpoint")
local SummitReached=LavaRemotes:WaitForChild("SummitReached")

local FishingSystem=ReplicatedStorage:WaitForChild("FishingSystem")
local TransferRequest=FishingSystem:WaitForChild("TransferRequest")

local Gui=Instance.new("ScreenGui")
Gui.Name="MountSorry_AutoTools"
Gui.ResetOnSpawn=false
Gui.Parent=CoreGui

local Frame=Instance.new("Frame")
Frame.Size=UDim2.fromOffset(250,155)
Frame.Position=UDim2.new(0,15,0.42,0)
Frame.BackgroundColor3=Color3.fromRGB(25,25,30)
Frame.BorderSizePixel=0
Frame.Parent=Gui

local Title=Instance.new("TextLabel")
Title.Size=UDim2.new(1,0,0,32)
Title.BackgroundTransparency=1
Title.Text="MOUNT SORRY"
Title.TextColor3=Color3.new(1,1,1)
Title.TextScaled=true
Title.Parent=Frame

local ResetButton=Instance.new("TextButton")
ResetButton.Size=UDim2.new(1,-20,0,36)
ResetButton.Position=UDim2.fromOffset(10,38)
ResetButton.Text="AUTO RESET: OFF"
ResetButton.TextColor3=Color3.new(1,1,1)
ResetButton.TextScaled=true
ResetButton.BackgroundColor3=Color3.fromRGB(170,50,50)
ResetButton.Parent=Frame

local GiftButton=Instance.new("TextButton")
GiftButton.Size=UDim2.new(1,-20,0,36)
GiftButton.Position=UDim2.fromOffset(10,78)
GiftButton.Text="AUTO GIFT → RiEzKhI: OFF"
GiftButton.TextColor3=Color3.new(1,1,1)
GiftButton.TextScaled=true
GiftButton.BackgroundColor3=Color3.fromRGB(170,50,50)
GiftButton.Parent=Frame

local Status=Instance.new("TextLabel")
Status.Size=UDim2.new(1,-20,0,25)
Status.Position=UDim2.fromOffset(10,119)
Status.BackgroundTransparency=1
Status.Text="Ready"
Status.TextColor3=Color3.new(1,1,1)
Status.TextScaled=true
Status.Parent=Frame

local function DoReset()
    if not AutoReset or os.clock()-LastReset<2 then return end
    LastReset=os.clock()
    task.wait(1)
    pcall(function() ResetCheckpoint:FireServer() end)
    Status.Text="Checkpoint reset"
end

pcall(function()
    SummitReached.OnClientEvent:Connect(DoReset)
end)

task.spawn(function()
    local leaderstats=LP:WaitForChild("leaderstats")
    local Summits=leaderstats:WaitForChild("Summits")
    local last=tonumber(Summits.Value) or 0
    Summits:GetPropertyChangedSignal("Value"):Connect(function()
        local n=tonumber(Summits.Value) or 0
        if n>last then last=n; DoReset() else last=n end
    end)
end)

local function GetTarget()
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP and p.Name:lower()==TARGET_NAME:lower() then return p end
    end
end

local function GetInventoryFish()
    local list,seen={},{}
    local roots={LP:FindFirstChild("PlayerGui"),LP:FindFirstChild("Backpack"),LP}
    for _,root in ipairs(roots) do
        if root then
            for _,obj in ipairs(root:GetDescendants()) do
                local id=obj:GetAttribute("FishId")
                if id~=nil then
                    id=tostring(id)
                    if id~="" and not seen[id] then seen[id]=true; table.insert(list,id) end
                end
                if obj:IsA("StringValue") and obj.Name:lower()=="fishid" then
                    local v=tostring(obj.Value)
                    if v~="" and not seen[v] then seen[v]=true; table.insert(list,v) end
                end
            end
        end
    end
    return list
end

local function StartGift()
    if GiftRunning then return end
    GiftRunning=true
    local target=GetTarget()
    if not target then Status.Text="RiEzKhI tidak ada"; GiftRunning=false; return end
    local fish=GetInventoryFish()
    if #fish==0 then Status.Text="FishId tidak ditemukan"; GiftRunning=false; return end

    for i,id in ipairs(fish) do
        if not AutoGift then break end
        Status.Text="Gift "..i.."/"..#fish
        pcall(function() TransferRequest:FireServer(target,id) end)
        local start=os.clock()
        while AutoGift and os.clock()-start<GIFT_TIMEOUT do task.wait(0.1) end
    end
    Status.Text=AutoGift and "Auto Gift selesai" or "Auto Gift mati"
    GiftRunning=false
end

ResetButton.Activated:Connect(function()
    AutoReset=not AutoReset
    if AutoReset then
        ResetButton.Text="AUTO RESET: ON"
        ResetButton.BackgroundColor3=Color3.fromRGB(50,170,80)
        Status.Text="Auto Reset aktif"
    else
        ResetButton.Text="AUTO RESET: OFF"
        ResetButton.BackgroundColor3=Color3.fromRGB(170,50,50)
        Status.Text="Auto Reset mati"
    end
end)

GiftButton.Activated:Connect(function()
    AutoGift=not AutoGift
    if AutoGift then
        GiftButton.Text="AUTO GIFT → RiEzKhI: ON"
        GiftButton.BackgroundColor3=Color3.fromRGB(50,170,80)
        if not GiftRunning then task.spawn(StartGift) end
    else
        GiftButton.Text="AUTO GIFT → RiEzKhI: OFF"
        GiftButton.BackgroundColor3=Color3.fromRGB(170,50,50)
        Status.Text="Auto Gift mati"
    end
end)
