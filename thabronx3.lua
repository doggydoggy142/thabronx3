print('Your thabronx3 auto farm script has been executed.')
getgenv().cfg = {
    ["switch_servers_when_no_wood"] = true, -- change to false to autofarm in 1 server MUST HAVE SCRIPT IN AUTOEXEC TO WORK
    ["serverhop_timeout"] = 80 -- after this amount of seconds u will serverhop, change to 999999 to make it never serverhop
}

pcall(function()
repeat task.wait(3) until game:IsLoaded()
repeat task.wait(3) until game:GetService("Players").LocalPlayer.PlayerGui.BronxLoadscreen
end)
pcall(function()
repeat firesignal(game:GetService("Players").LocalPlayer.PlayerGui.BronxLoadscreen.Frame.play.MouseButton1Click) until not game:GetService("Players").LocalPlayer.PlayerGui.BronxLoadscreen
end)
pcall(function()
repeat task.wait(1) until not game:GetService("Players").LocalPlayer.PlayerGui.BronxLoadscreen
end)

start = tick()

local job = workspace.ConstructionStuff["Start Job"].CFrame

-- made in 30 mins b4 som1 complains about messy code

local function startjob()
if not game.Players.LocalPlayer:GetAttribute("WorkingJob") or game.Players.LocalPlayer:GetAttribute("WorkingJob") == false then
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = job
fireproximityprompt(workspace.ConstructionStuff["Start Job"].Prompt)
end
end

local function autoequipwood()
if game:GetService("Players").LocalPlayer.Backpack.PlyWood then
game:GetService("Players").LocalPlayer.Backpack.PlyWood.Parent = game:GetService("Players").LocalPlayer.Character
end
end

local function wood()
for i, v in pairs(workspace.ConstructionStuff:GetDescendants()) do
if v:IsA("ProximityPrompt") and v.ActionText == "Wall" then
fireproximityprompt(v)
end
end
end

local function grabwood()
for i, v in pairs(workspace.ConstructionStuff["Grab Wood"]:GetChildren()) do
if v:IsA("ProximityPrompt") and v.ActionText == "Wood" then
fireproximityprompt(v)
end
end
end

local function mainautofarm()
for i, v in pairs(workspace.ConstructionStuff:GetDescendants()) do
if v:IsA("Part") and string.find(v.Name, "Prompt") then
local text = v:FindFirstChild("Attachment"):FindFirstChild("Gui"):FindFirstChild("Label").Text 
if not string.find(text, "RESETS") then
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.CFrame
end
end
end
if not (game.Players.LocalPlayer.Backpack:FindFirstChild("PlyWood") or game.Players.LocalPlayer.Character:FindFirstChild("PlyWood")) then
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1728, 371, -1177)
end
end

task.spawn(function()
while task.wait(1/4) do
xpcall(startjob, debug.traceback)
end
end)

task.spawn(function()
while task.wait(1/6) do
xpcall(wood, debug.traceback)
xpcall(grabwood, debug.traceback)
xpcall(autoequipwood, debug.traceback)
xpcall(mainautofarm, debug.traceback)
end
end)

-- tp script below forked from https://github.com/ProbTom/ServerHop/blob/main/SH.lua
local PlaceID = game.PlaceId
local AllIDs = {}
local foundAnything = ""
local actualHour = os.date("!*t").hour
local Deleted = false
local File = pcall(function()
    AllIDs = game:GetService('HttpService'):JSONDecode(readfile("NotSameServers.json"))
end)
if not File then
    table.insert(AllIDs, actualHour)
    writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(AllIDs))
end
function TPReturner()
    local Site;
    if foundAnything == "" then
        Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100'))
    else
        Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100&cursor=' .. foundAnything))
    end
    local ID = ""
    if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then
        foundAnything = Site.nextPageCursor
    end
    local num = 0;
    for i,v in pairs(Site.data) do
        local Possible = true
        ID = tostring(v.id)
        if tonumber(v.maxPlayers) > tonumber(v.playing) then
            for _,Existing in pairs(AllIDs) do
                if num ~= 0 then
                    if ID == tostring(Existing) then
                        Possible = false
                    end
                else
                    if tonumber(actualHour) ~= tonumber(Existing) then
                        local delFile = pcall(function()
                            delfile("NotSameServers.json")
                            AllIDs = {}
                            table.insert(AllIDs, actualHour)
                        end)
                    end
                end
                num = num + 1
            end
            if Possible == true then
                table.insert(AllIDs, ID)
                wait()
                pcall(function()
                    writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(AllIDs))
                    wait()
                    game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, ID, game.Players.LocalPlayer)
                end)
                wait(4)
            end
        end
    end
end

function Teleport()
    while wait() do
        pcall(function()
            TPReturner()
            if foundAnything ~= "" then
                TPReturner()
            end
        end)
    end
end
-- end of fork

local function checkfornowood()
if not cfg["switch_servers_when_no_wood"] then return end
local x = true
for i, v in pairs(workspace.ConstructionStuff:GetDescendants()) do
if v:IsA("Part") and string.find(v.Name, "Prompt") then
local text = v:FindFirstChild("Attachment"):FindFirstChild("Gui"):FindFirstChild("Label").Text 
if not string.find(text, "RESETS") then
x = false
break
end
end
end
if x then Teleport() end
end

local function timeout()
while true do
task.wait(1)
local currenttime = tick() - start
if currenttime >= cfg["serverhop_timeout"] then
Teleport()
end
end
end

task.spawn(function()
timeout()
end)

while task.wait(4) do
    xpcall(checkfornowood, debug.traceback)
end
