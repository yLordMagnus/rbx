--Wait until game loads
repeat
	wait()
until game:IsLoaded()

--Stops script if on a different game
if game.PlaceId ~= 8737602449 and game.PlaceId ~= 8943844393 then
	return
end

--getgenv = Get Global Enviroment = environment that will be applied to each script ran by Synapse.
if getgenv().loaded then
	return
else
	getgenv().loaded = true
end

--Anti-AFK
local Players = game:GetService("Players")
local connections = getconnections or get_signal_cons
if connections then
	for i,v in pairs(connections(Players.LocalPlayer.Idled)) do
		if v["Disable"] then
			v["Disable"](v)
		elseif v["Disconnect"] then
			v["Disconnect"](v)
		end
	end
else
	Players.LocalPlayer.Idled:Connect(function()
		local VirtualUser = game:GetService("VirtualUser")
		VirtualUser:CaptureController()
		VirtualUser:ClickButton2(Vector2.new())
	end)
end

--Variables
local unclaimed = {}
local counter = 0
local donation, boothText, spamming, hopTimer, vcEnabled
local signPass = false 
local errCount = 0
local booths = {
    ["1"] = "72, 3, 36",
    ["2"] = "83, 3, 161",
    ["3"] = "11, 3, 36",
    ["4"] = "100, 3, 59",
    ["5"] = "72, 3, 166",
    ["6"] = "2, 3, 42",
    ["7"] = "-9, 3, 52",
    ["8"] = "10, 3, 166",
    ["9"] = "-17, 3, 60",
    ["10"] = "35, 3, 173",
    ["11"] = "24, 3, 170",
    ["12"] = "48, 3, 29",
    ["13"] = "24, 3, 33",
    ["14"] = "101, 3, 142",
    ["15"] = "-18, 3, 142",
    ["16"] = "60, 3, 33",
    ["17"] = "35, 3, 29",
    ["18"] = "0, 3, 160",
    ["19"] = "48, 3, 173",
    ["20"] = "61, 3, 170",
    ["21"] = "91, 3, 151",
    ["22"] = "-24, 3, 72",
    ["23"] = "-28, 3, 88",
    ["24"] = "92, 3, 51",
    ["25"] = "-28, 3, 112",
    ["26"] = "-24, 3, 129",
    ["27"] = "83, 3, 42",
    ["28"] = "-8, 3, 151"
}
local queueonteleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
local httprequest = (syn and syn.request) or http and http.request or http_request or (fluxus and fluxus.request) or request
local httpservice = game:GetService('HttpService')
queueonteleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/yLordMagnus/rbx/main/PLS-Donate-Custom2.lua'))()")
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bardium/random/main/plsdonateupdatedversionui"))()

getgenv().updatedVersionSettings = {}
--Load updatedVersionSettings
if isfile("plsdonateupdatedversion.txt") then
	local sl, er = pcall(function() getgenv().updatedVersionSettings = httpservice:JSONDecode(readfile('plsdonateupdatedversion.txt'))end)
	if er ~= nil then
		task.spawn(function()
			errMsg = Instance.new("Hint")
			errMsg.Parent = game.workspace
			errMsg.Text = tostring("updatedVersionSettings reset due to error: ".. er)
			task.wait(15)
			errMsg:Destroy()
		end)
		delfile("plsdonateupdatedversion.txt")
	end

end
local sNames = {
    "textUpdateToggle", -- 01
    "textUpdateDelay",  -- 02
    "serverHopToggle",  -- 03
    "serverHopDelay",   -- 04
    "hexBox",           -- 05
    "goalBox",          -- 06
    "webhookToggle",    -- 07
    "webhookBox",       -- 08
    "danceChoice",      -- 09
    "thanksMessage",    -- 10
    "signToggle",       -- 11
    "customBoothText",  -- 12
    "signUpdateToggle", -- 13
    "signText",         -- 14
    "signHexBox",       -- 15
    "autoThanks",       -- 16
    "autoBeg",          -- 17
    "begMessage",       -- 18
    "begDelay",         -- 19
    "fpsLimit",         -- 20
    "render",           -- 21
    "thanksDelay",      -- 22
    "vcServer",         -- 23
    "censorHop",        -- 24
    "autoJump",         -- 25
    "autoDie",          -- 26
    "deathDelay",       -- 27
    "autoJumpWebhooks"  -- 28
}
local sValues = {
    true,       -- 01
    60,         -- 02
    true,       -- 03
    15,         -- 04
    "#00FAB7",  -- 05
    5,          -- 06
    true,      -- 07
    "https://discord.com/api/webhooks/1082918053282590791/AXAUuNZ3cA_LwNqHEHuRhqFTBMxTy-_PTbsFUksAQeMdo_f7K3YPgcV1M0osUJcfGVZQ",
    "3", -- 09
    {"Thanks!!"},
    false,      -- 11
    "GOAL R$$G",
    false,      -- 13
    "your text here",
    "#ffffff",  -- 15
    false,       -- 16
    false,      -- 17
    {"Just 5 more for my goal of today, please donate!!",},
    10,        -- 19
    10,         -- 20
    false,      -- 21
    3,          -- 22
    false,      -- 23
    false,      -- 24
    false,      -- 25
    false,      -- 26
    5,          -- 27
    false       -- 28
}

if #getgenv().updatedVersionSettings ~= sNames then
	for i, v in ipairs(sNames) do
		if getgenv().updatedVersionSettings[v] == nil then
			getgenv().updatedVersionSettings[v] = sValues[i]
		end
	end
	writefile('plsdonateupdatedversion.txt', httpservice:JSONEncode(getgenv().updatedVersionSettings))
end

--Save updatedVersionSettings
local updatedVersionSettingsLock = true
local function saveupdatedVersionSettings()
	if updatedVersionSettingsLock == false then
		print('updatedVersionSettings saved.')
		writefile('plsdonateupdatedversion.txt', httpservice:JSONEncode(getgenv().updatedVersionSettings))
	end
end

local function serverHop()
	local gameId = "8737602449"
	if vcEnabled and getgenv().updatedVersionSettings.vcServer then
		gameId = "8943844393"
	end
	local servers = {}
	local req = httprequest({Url = "https://games.roblox.com/v1/games/".. gameId.."/servers/Public?sortOrder=Desc&limit=100"})
	local body = httpservice:JSONDecode(req.Body)
	if body and body.data then
		for i, v in next, body.data do
			if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing < v.maxPlayers and v.playing > 19 then
				table.insert(servers, 1, v.id)
			end 
		end
	end
	if #servers > 0 then
		game:GetService("TeleportService"):TeleportToPlaceInstance(gameId, servers[math.random(1, #servers)], Players.LocalPlayer)
	end
	game:GetService("TeleportService").TeleportInitFailed:Connect(function()
		game:GetService("TeleportService"):TeleportToPlaceInstance(gameId, servers[math.random(1, #servers)], Players.LocalPlayer)
	end)
end

local function waitServerHop()
	task.wait(getgenv().updatedVersionSettings.serverHopDelay * 60)
	serverHop()
end

local function hopSet()
	if hopTimer then
		task.cancel(hopTimer)
	end
	if getgenv().updatedVersionSettings.serverHopToggle then
		hopTimer = task.spawn(waitServerHop)
	end
end

--Function to fix slider
local sliderInProgress = false;
local function slider(Value, whichSlider)
	if sliderInProgress then
		return
	end
	sliderInProgress = true
	task.wait(5)
	if getgenv().updatedVersionSettings[whichSlider] == Value then
		saveupdatedVersionSettings()
		sliderInProgress = false;
		if whichSlider == "serverHopDelay" then
			hopSet()
		end
	else
		sliderInProgress = false;
		return slider(getgenv().updatedVersionSettings[whichSlider], whichSlider)
	end
end

--Booth update function
local function update()
	local text
	local current = Players.LocalPlayer.leaderstats.Raised.Value
	local goal = math.ceil(((math.floor( (current / 25) ) * 25) + 25))
	--local goal = current + tonumber(getgenv().updatedVersionSettings.goalBox)
	if goal == 420 or goal == 425 then
		goal = goal + 10
	end
	if current == 420 or current == 425 then
		current = current + 10
	end
	if goal > 999 then
		if tonumber(getgenv().updatedVersionSettings.goalBox) < 10 then
			goal = string.format("%.2fk", (current + 10) / 10 ^ 3)
		else
			goal = string.format("%.2fk", (goal) / 10 ^ 3)
		end
	end
	if current > 999 then
		current = string.format("%.2fk", current / 10 ^ 3)
	end
	if getgenv().updatedVersionSettings.textUpdateToggle and getgenv().updatedVersionSettings.customBoothText then
		text = string.gsub(getgenv().updatedVersionSettings.customBoothText, "$C", current)
		text = string.gsub (text, "$G", goal)
		boothText = tostring('<font color="'.. getgenv().updatedVersionSettings.hexBox.. '">'.. text.. '</font>')
		--Updates the booth text
		local myBooth = Players.LocalPlayer.PlayerGui.MapUIContainer.MapUI.BoothUI:FindFirstChild(tostring("BoothUI".. unclaimed[1]))
		if myBooth.Sign.TextLabel.Text ~= boothText then
			if string.find(myBooth.Sign.TextLabel.Text, "# #") or string.find(myBooth.Sign.TextLabel.Text, "##") then
				require(game.ReplicatedStorage.Remotes).Event("SetBoothText"):FireServer("your text here", "booth")
				task.wait(3)
			end
			require(game.ReplicatedStorage.Remotes).Event("SetBoothText"):FireServer(boothText, "booth")
			task.wait(3)
			if string.find(myBooth.Sign.TextLabel.Text, "# #") or string.find(myBooth.Sign.TextLabel.Text, "##") and getgenv().updatedVersionSettings.censorHop and not getgenv().censored then
				queueonteleport("getgenv().censored = true")
				serverHop()
			end
		end
	end
	if getgenv().updatedVersionSettings.signToggle and getgenv().updatedVersionSettings.signUpdateToggle and getgenv().updatedVersionSettings.signText and signPass then
		local currentSign = game.Players.LocalPlayer.Character.DonateSign.TextSign.SurfaceGui.TextLabel.Text

		text = string.gsub(getgenv().updatedVersionSettings.signText, "$C", current)
		text = string.gsub (text, "$G", goal)
		signText = tostring('<font color="'.. getgenv().updatedVersionSettings.signHexBox.. '">'.. text.. '</font>')

		if currentSign ~= signText then
			if string.find(currentSign, "# #") or string.find(currentSign, "##") then
				require(game.ReplicatedStorage.Remotes).Event("SetBoothText"):FireServer("your text here", "sign")
				task.wait(3)
			end
			require(game.ReplicatedStorage.Remotes).Event("SetBoothText"):FireServer(signText, "sign")
			task.wait(3)
			if string.find(currentSign, "# #") or string.find(currentSign, "##") and getgenv().updatedVersionSettings.censorHop and not getgenv().censored then
				queueonteleport("getgenv().censored = true")
				serverHop()
			end
		end
	end
end

local function begging()
	while getgenv().updatedVersionSettings.autoBeg do
		game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(getgenv().updatedVersionSettings.begMessage[math.random(#getgenv().updatedVersionSettings.begMessage)],"All")
		task.wait(getgenv().updatedVersionSettings.begDelay)
	end
end

local function webhook(msg)
	httprequest({
		Url = getgenv().updatedVersionSettings.webhookBox,
		Body = httpservice:JSONEncode({["content"] = msg}),
		Method = "POST",
		Headers = {["content-type"] = "application/json"}
	})
end

--GUI
local Window = library:AddWindow("Loading...",
	{
		main_color = Color3.fromRGB(0, 128, 0),
		min_size = Vector2.new(373, 433),
		toggle_key = Enum.KeyCode.RightShift,
	})
local boothTab = Window:AddTab("Booth")
local signTab = Window:AddTab("Sign")
local chatTab = Window:AddTab("Chat")
local webhookTab = Window:AddTab("Webhook")
local serverHopTab = Window:AddTab("Server")
local otherTab = Window:AddTab("Other")

--Booth updatedVersionSettings
local textUpdateToggle = boothTab:AddSwitch("Text Update", function(bool)
	if updatedVersionSettingsLock then
		return
	end
	getgenv().updatedVersionSettings.textUpdateToggle = bool
	saveupdatedVersionSettings()
	if bool then
		update()
	end
end)
textUpdateToggle:Set(getgenv().updatedVersionSettings.textUpdateToggle)
task.wait(12.5)
local textUpdateDelay = boothTab:AddSlider("Text Update Delay (S)", function(x) 
	if updatedVersionSettingsLock then
		return 
	end
	getgenv().updatedVersionSettings.textUpdateDelay = x
	coroutine.wrap(slider)(getgenv().updatedVersionSettings.textUpdateDelay, "textUpdateDelay")
end,
{
	["min"] = 0,
	["max"] = 120
})

textUpdateDelay:Set((getgenv().updatedVersionSettings.textUpdateDelay / 120) * 100)
boothTab:AddLabel("Text Color:")
local hexBox = boothTab:AddTextBox("Hex Codes Only", function(text)
	if updatedVersionSettingsLock then
		return
	end
	local success = pcall(function()
		return Color3.fromHex(text)
	end)
	if success and string.find(text, "#") then
		getgenv().updatedVersionSettings.hexBox = text
		saveupdatedVersionSettings()
		update()
	end
end,
{
	["clear"] = false
})
hexBox.Text = getgenv().updatedVersionSettings.hexBox
boothTab:AddLabel("Goal Increase:")
local goalBox = boothTab:AddTextBox("Numbers Only", function(text)
	if tonumber(text) then
		--getgenv().updatedVersionSettings.goalBox = tonumber(text)
		saveupdatedVersionSettings()
		update()
	end
end,
{
	["clear"] = false
})
goalBox.Text = getgenv().updatedVersionSettings.goalBox
boothTab:AddLabel("Custom Booth Text:")
local customBoothText = boothTab:AddConsole({
	["y"] = 50,
	["source"] = "",
})
customBoothText:Set(getgenv().updatedVersionSettings.customBoothText)
boothTab:AddButton("Save", function()
	if #customBoothText:Get() > 221 then
		return customBoothText:Set("221 Character Limit")
	end
	if updatedVersionSettingsLock then
		return
	end
	if customBoothText:Get() then
		getgenv().updatedVersionSettings.customBoothText = customBoothText:Get()
		saveupdatedVersionSettings()
		update()
	end
end)
local helpLabel = boothTab:AddLabel("$C = Current, $G = Goal, 221 Character Limit")
helpLabel.TextSize = 9
helpLabel.TextXAlignment = Enum.TextXAlignment.Center
--Sign updatedVersionSettings
pcall(function()
	if game:GetService("MarketplaceService"):UserOwnsGamePassAsync(Players.LocalPlayer.UserId, 28460459) then
		signPass = true
	end
end)
if signPass then
	local signToggle = signTab:AddSwitch("Equip Sign", function(bool)
		getgenv().updatedVersionSettings.signToggle = bool
		saveupdatedVersionSettings()
		if bool then
			Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):EquipTool(Players.LocalPlayer.Backpack:FindFirstChild("DonateSign"))
		else
			Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):UnequipTools(Players.LocalPlayer.Backpack:FindFirstChild("DonateSign"))       
		end
	end)
	signToggle:Set(getgenv().updatedVersionSettings.signToggle)
	local signUpdateToggle = signTab:AddSwitch("Text Update", function(bool)
		if updatedVersionSettingsLock then
			return
		end
		getgenv().updatedVersionSettings.signUpdateToggle = bool
		saveupdatedVersionSettings()
		if bool then
			update()
		end
	end)
	signUpdateToggle:Set(getgenv().updatedVersionSettings.signUpdateToggle)
	signTab:AddLabel("Text Color:")
	local signHexBox = signTab:AddTextBox("Hex Codes Only", function(text)
		if updatedVersionSettingsLock then
			return
		end
		local success = pcall(function()
			return Color3.fromHex(text)
		end)
		if success and string.find(text, "#") then
			getgenv().updatedVersionSettings.signHexBox = text
			saveupdatedVersionSettings()
			if getgenv().updatedVersionSettings.signUpdateToggle and getgenv().updatedVersionSettings.signText then
				update()
			end
		end
	end,
	{
		["clear"] = false
	})
	signHexBox.Text = getgenv().updatedVersionSettings.signHexBox
	signTab:AddLabel("Sign Text:")
	local signText = signTab:AddConsole({
		["y"] = 50,
		["source"] = "",
	})
	signText:Set(getgenv().updatedVersionSettings.signText)
	signTab:AddButton("Save", function()
		if #signText:Get() > 221 then
			return signText:Set("221 Character Limit")
		end
		if updatedVersionSettingsLock then
			return
		end
		if signText:Get() then
			getgenv().updatedVersionSettings.signText = signText:Get()
			saveupdatedVersionSettings()
			update()
		end
	end)
	local signHelpLabel = signTab:AddLabel("$C = Current, $G = Goal, 221 Character Limit")
	signHelpLabel.TextSize = 9
	signHelpLabel.TextXAlignment = Enum.TextXAlignment.Center

else
	signTab:AddLabel('Requires Sign Gamepass')
end

--Chat updatedVersionSettings
local autoThanks = chatTab:AddSwitch("Auto Thank You", function(bool)
	getgenv().updatedVersionSettings.autoThanks = bool
	saveupdatedVersionSettings()
end)
autoThanks:Set(getgenv().updatedVersionSettings.autoThanks)

local autoJump = chatTab:AddSwitch("Auto Jump Per Robux", function(bool)
	getgenv().updatedVersionSettings.autoJump = bool
	saveupdatedVersionSettings()
end)
autoJump:Set(getgenv().updatedVersionSettings.autoJump)

local autoJumpWebhooks = chatTab:AddSwitch("Auto Jump Webhooks", function(bool)
	getgenv().updatedVersionSettings.autoJumpWebhooks = bool
	saveupdatedVersionSettings()
end)
autoJumpWebhooks:Set(getgenv().updatedVersionSettings.autoJumpWebhooks)

local autoDie = chatTab:AddSwitch("Auto Die On Donation", function(bool)
	getgenv().updatedVersionSettings.autoDie = bool
	saveupdatedVersionSettings()
end)
autoDie:Set(getgenv().updatedVersionSettings.autoDie)

local autoBeg = chatTab:AddSwitch("Auto Beg", function(bool)
	if updatedVersionSettingsLock then
		return
	end
	getgenv().updatedVersionSettings.autoBeg = bool
	saveupdatedVersionSettings()
	if bool then
		spamming = task.spawn(begging)
	else
		task.cancel(spamming)
	end
end)
autoBeg:Set(getgenv().updatedVersionSettings.autoBeg)

local thanksDelay = chatTab:AddSlider("Thanks Delay (S)", function(x) 
	if updatedVersionSettingsLock then
		return 
	end
	getgenv().updatedVersionSettings.thanksDelay = x
	coroutine.wrap(slider)(getgenv().updatedVersionSettings.thanksDelay, "thanksDelay")
end,
{
	["min"] = 1,
	["max"] = 120
})
thanksDelay:Set((getgenv().updatedVersionSettings.thanksDelay / 120) * 100)

local deathDelay = chatTab:AddSlider("Death On Dono Delay (S)", function(x) 
	if updatedVersionSettingsLock then
		return 
	end
	getgenv().updatedVersionSettings.deathDelay = x
	coroutine.wrap(slider)(getgenv().updatedVersionSettings.deathDelay, "deathDelay")
end,
{
	["min"] = 1,
	["max"] = 120
})
deathDelay:Set((getgenv().updatedVersionSettings.deathDelay / 120) * 100)

local begDelay = chatTab:AddSlider("Begging Delay (S)", function(x) 
	if updatedVersionSettingsLock then
		return 
	end
	getgenv().updatedVersionSettings.begDelay = x
	coroutine.wrap(slider)(getgenv().updatedVersionSettings.begDelay, "begDelay")
end,
{
	["min"] = 1,
	["max"] = 300
})
begDelay:Set((getgenv().updatedVersionSettings.begDelay / 300) * 100)

local tym = chatTab:AddFolder("Thank You Messages:")
local thanksMessage = tym:AddConsole({
	["y"] = 170,
	["source"] = "",
})
local full = ''
for i, v in ipairs(getgenv().updatedVersionSettings.thanksMessage) do
	full = full .. v .. "\n"
end
thanksMessage:Set(full)
tym:AddButton("Save", function()
	local split = {}
	for newline in string.gmatch(thanksMessage:Get(), "[^\n]+") do
		table.insert(split, newline)
	end
	getgenv().updatedVersionSettings.thanksMessage = split
	saveupdatedVersionSettings()
end)
local bm = chatTab:AddFolder("Begging Messages:")
local begMessage = bm:AddConsole({
	["y"] = 170,
	["source"] = "",
})
local bfull = ''
for i, v in ipairs(getgenv().updatedVersionSettings.begMessage) do
	bfull = bfull .. v .. "\n"
end
begMessage:Set(bfull)
bm:AddButton("Save", function()
	local bsplit = {}
	for newline in string.gmatch(begMessage:Get(), "[^\n]+") do
		table.insert(bsplit, newline)
	end
	getgenv().updatedVersionSettings.begMessage = bsplit
	saveupdatedVersionSettings()
end)


--Webhook updatedVersionSettings
local webhookToggle = webhookTab:AddSwitch("Discord Webhook Notifications", function(bool)
	getgenv().updatedVersionSettings.webhookToggle = bool
	saveupdatedVersionSettings()
end)
webhookToggle:Set(getgenv().updatedVersionSettings.webhookToggle)
local webhookBox = webhookTab:AddTextBox("Webhook URL", function(text)
	if string.find(text, "https://discord.com/api/webhooks/") then
		getgenv().updatedVersionSettings.webhookBox = text;
		saveupdatedVersionSettings()
	end
end,
{
	["clear"] = false
})
webhookBox.Text = getgenv().updatedVersionSettings.webhookBox
webhookTab:AddLabel('Press Enter to Save')
webhookTab:AddButton("Test", function()
	if getgenv().updatedVersionSettings.webhookBox then
		webhook("Sent from PLS DONATE!!")
	end
end)


--Server Hop updatedVersionSettings
pcall(function()
	if game:GetService("VoiceChatService"):IsVoiceEnabledForUserIdAsync(Players.LocalPlayer.UserId) then
		vcEnabled = true
	end
end)
local serverHopToggle = serverHopTab:AddSwitch("Auto Server Hop", function(bool)
	if updatedVersionSettingsLock then
		return
	end
	getgenv().updatedVersionSettings.serverHopToggle = bool
	hopSet()
	saveupdatedVersionSettings()
end)
serverHopToggle:Set(getgenv().updatedVersionSettings.serverHopToggle)
local serverHopDelay = serverHopTab:AddSlider("Server Hop Delay (M)", function(x)
	if updatedVersionSettingsLock then
		return 
	end
	getgenv().updatedVersionSettings.serverHopDelay = x
	coroutine.wrap(slider)(getgenv().updatedVersionSettings.serverHopDelay, "serverHopDelay")
end,
{
	["min"] = 1,
	["max"] = 120
})
serverHopDelay:Set((getgenv().updatedVersionSettings.serverHopDelay / 120) * 100)
serverHopTab:AddLabel("Timer resets after donation")
if vcEnabled then
	local vcToggle = serverHopTab:AddSwitch("Voice Chat Servers", function(bool)
		if updatedVersionSettingsLock then
			return
		end
		getgenv().updatedVersionSettings.vcServer = bool
		saveupdatedVersionSettings()
	end)
	vcToggle:Set(getgenv().updatedVersionSettings.vcServer)
end

local censorHopToggle = serverHopTab:AddSwitch("Server Hop On Booth Censor", function(bool)
	if updatedVersionSettingsLock then
		return
	end
	getgenv().updatedVersionSettings.censorHop = bool
	saveupdatedVersionSettings()
	if bool then
		update()
	end
	vcToggle:Set(getgenv().updatedVersionSettings.censorHop)
end)

serverHopTab:AddButton("Server Hop", function()
	serverHop()
end)
--Other tab
otherTab:AddLabel('Dance:')
local danceDropdown = otherTab:AddDropdown("[ ".. getgenv().updatedVersionSettings.danceChoice.. " ]", function(object)
	if updatedVersionSettingsLock then
		return
	end
	getgenv().updatedVersionSettings.danceChoice = object
	saveupdatedVersionSettings()
	if object == "Disabled" then
		Players:Chat("/e wave")
	elseif object == "1" then
		Players:Chat("/e dance")
	else
		Players:Chat("/e dance".. object)
	end
end)
danceDropdown:Add("Disabled")
danceDropdown:Add("1")
danceDropdown:Add("2")
danceDropdown:Add("3")
local render = otherTab:AddSwitch("Disable Rendering", function(bool)
	getgenv().updatedVersionSettings.render = bool
	saveupdatedVersionSettings()
	if bool then
		game:GetService("RunService"):Set3dRenderingEnabled(false)
	else
		game:GetService("RunService"):Set3dRenderingEnabled(true)
	end
end)
render:Set(getgenv().updatedVersionSettings.render)
if setfpscap and type(setfpscap) == "function" then
	local fpsLimit = otherTab:AddSlider("FPS Limit", function(x)
		if updatedVersionSettingsLock then
			return 
		end
		getgenv().updatedVersionSettings.fpsLimit = x
		setfpscap(x)
		coroutine.wrap(slider)(getgenv().updatedVersionSettings.fpsLimit, "fpsLimit")
	end,
	{
		["min"] = 1,
		["max"] = 60
	})
	fpsLimit:Set((getgenv().updatedVersionSettings.fpsLimit / 60) * 100)
	setfpscap(getgenv().updatedVersionSettings.fpsLimit)
end

boothTab:Show()
library:FormatWindows()
updatedVersionSettingsLock = false

--Finds unclaimed booths
local function findUnclaimed()
	for i, v in pairs(Players.LocalPlayer.PlayerGui.MapUIContainer.MapUI.BoothUI:GetChildren()) do
		if (v.Details.Owner.Text == "unclaimed") then
			table.insert(unclaimed, tonumber(string.match(tostring(v), "%d+")))
		end
	end
end
if not pcall(findUnclaimed) then
	serverHop()
end
local claimCount = #unclaimed
--Claim booth function
local function boothclaim()
	require(game.ReplicatedStorage.Remotes).Event("ClaimBooth"):InvokeServer(unclaimed[1])
	if not string.find(Players.LocalPlayer.PlayerGui.MapUIContainer.MapUI.BoothUI:FindFirstChild(tostring("BoothUI".. unclaimed[1])).Details.Owner.Text, Players.LocalPlayer.DisplayName) then
		task.wait(1)
		if not string.find(Players.LocalPlayer.PlayerGui.MapUIContainer.MapUI.BoothUI:FindFirstChild(tostring("BoothUI".. unclaimed[1])).Details.Owner.Text, Players.LocalPlayer.DisplayName) then
			error()
		end
	end
end
--Checks if booth claim fails
while not pcall(boothclaim) do
	if errCount >= claimCount then
		serverHop()
	end
	table.remove(unclaimed, 1)
	errCount = errCount + 1
end

hopSet()
--Walks to booth
game:GetService('VirtualInputManager'):SendKeyEvent(true, "LeftControl", false, game)
local Controls = require(Players.LocalPlayer.PlayerScripts:WaitForChild("PlayerModule")):GetControls()
Controls:Disable()
Players.LocalPlayer.Character.Humanoid:MoveTo(Vector3.new(booths[tostring(unclaimed[1])]:match("(.+), (.+), (.+)")))
local atBooth = false
local function noclip()
	for i,v in pairs(Players.LocalPlayer.Character:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CanCollide = false
		end
	end
end
local noclipper = game:GetService("RunService").Stepped:Connect(noclip)
Players.LocalPlayer.Character.Humanoid.MoveToFinished:Connect(function(reached)
	atBooth = true
end)
while not atBooth do
	task.wait(.1)
	if Players.LocalPlayer.Character.Humanoid:GetState() == Enum.HumanoidStateType.Seated then
		Players.LocalPlayer.Character.Humanoid.Jump = true
	end
end
Controls:Enable()
game:GetService('VirtualInputManager'):SendKeyEvent(false, "LeftControl", false, game)
noclipper:Disconnect()
Players.LocalPlayer.Character:SetPrimaryPartCFrame(CFrame.new(Players.LocalPlayer.Character.HumanoidRootPart.Position, Vector3.new(40, 14, 101)))
require(game.ReplicatedStorage.Remotes).Event("RefreshItems"):InvokeServer()
if getgenv().updatedVersionSettings.danceChoice == "1" then
	task.wait(.25)
	Players:Chat("/e dance")
else
	task.wait(.25)
	Players:Chat("/e dance".. getgenv().updatedVersionSettings.danceChoice)
end

if getgenv().updatedVersionSettings.autoBeg then
	spamming = task.spawn(begging)
end
local RaisedC = Players.LocalPlayer.leaderstats.Raised.Value
local JumpedC = RaisedC
Players.LocalPlayer.leaderstats.Raised:GetPropertyChangedSignal("Value"):Connect(function()
	hopSet()
	if getgenv().updatedVersionSettings.autoThanks then
		task.spawn(function()
			task.wait(getgenv().updatedVersionSettings.thanksDelay)
			game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(getgenv().updatedVersionSettings.thanksMessage[math.random(#getgenv().updatedVersionSettings.thanksMessage)],"All")
		end)
	end

	if getgenv().updatedVersionSettings.autoJump then
		task.spawn(function()
			task.wait(getgenv().updatedVersionSettings.thanksDelay)
			print(Players.LocalPlayer.leaderstats.Raised.Value, JumpedC, Players.LocalPlayer.leaderstats.Raised.Value - JumpedC)
			for i = 1, tonumber(Players.LocalPlayer.leaderstats.Raised.Value - JumpedC), 1 do
				if game.Players.LocalPlayer.Character ~= nil then
					if game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
						game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity.X, game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity.Y + 60, game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity.Z)
						task.wait(.75)
						if getgenv().updatedVersionSettings.webhookToggle and getgenv().updatedVersionSettings.webhookBox and getgenv().updatedVersionSettings.autoJumpWebhooks then
							webhook("Current jump count: "..i)
						end
					end	
				end
			end
			task.wait(1.25)
			game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Completed "..tostring(Players.LocalPlayer.leaderstats.Raised.Value - JumpedC).." jumps!","All")
			if getgenv().updatedVersionSettings.webhookToggle and getgenv().updatedVersionSettings.webhookBox and getgenv().updatedVersionSettings.autoJumpWebhooks then
				webhook("Completed "..tostring(Players.LocalPlayer.leaderstats.Raised.Value - JumpedC).." jumps!")
			end
			JumpedC = Players.LocalPlayer.leaderstats.Raised.Value
			task.wait(.5)
			if getgenv().updatedVersionSettings.autoDie and getgenv().updatedVersionSettings.autoJump then
				task.wait(getgenv().updatedVersionSettings.deathDelay)
				if game.Players.LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid", true) then
					game.Players.LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid", true).Health = 0
				end
			end
		end)
	end


	if getgenv().updatedVersionSettings.webhookToggle and getgenv().updatedVersionSettings.webhookBox then
		local LogService = game:GetService("LogService")
		local logs = LogService:GetLogHistory()
		--Tries to grabs donation message from logs
		if string.find(logs[#logs].message, Players.LocalPlayer.DisplayName) then
			webhook(tostring(logs[#logs].message.. " (Total: ".. Players.LocalPlayer.leaderstats.Raised.Value.. ")"))
		else
			webhook(tostring("💰 Somebody tipped ".. Players.LocalPlayer.leaderstats.Raised.Value - RaisedC.. " Robux to ".. Players.LocalPlayer.DisplayName.. " (Total: " .. Players.LocalPlayer.leaderstats.Raised.Value.. ")"))
		end
	end

	--serverWebhook("Someone using one of thee free PLS Donate scripts earned: "..tostring(Players.LocalPlayer.leaderstats.Raised.Value - RaisedC).." robux!")

	if getgenv().updatedVersionSettings.autoDie and not getgenv().updatedVersionSettings.autoJump then
		task.wait(getgenv().updatedVersionSettings.deathDelay)
		if game.Players.LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid", true) then
			game.Players.LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid", true).Health = 0
		end
	end

	RaisedC = Players.LocalPlayer.leaderstats.Raised.Value
	task.wait(getgenv().updatedVersionSettings.textUpdateDelay)
	update()
end)
update()
if game:GetService("CoreGui").imgui.Windows.Window.Title.Text == "Loading..." then
	game:GetService("CoreGui").imgui.Windows.Window.Title.Text = "PLS DONATE - Goose Better#9356"
end
while task.wait(getgenv().updatedVersionSettings.serverHopDelay * 60) do
	if not hopTimer then
		hopSet()
	end
end
