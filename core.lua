local addon, ns = ...

-- List globals here for Mikk's FindGlobals script
-- GLOBALS: SLASH_SERVERIGNORE1, SLASH_SERVERIGNORE2, SERVERIGNORE_ENABLED, SERVERIGNORE_DB, ChatFrame_AddMessageEventFilter, ChatFrame_RemoveMessageEventFilter, UnitName

local print, wipe, pairs, tconcat = print, wipe, pairs, table.concat

-- Chat events (without the CHAT_MSG_ prefix) to filter
local Events = {
	"ACHIEVEMENT",
	"AFK",
	"BATTLEGROUND",
	"BATTLEGROUND_LEADER",
	"CHANNEL",
	"DND",
	"EMOTE",
	"INSTANCE_CHAT",
	"INSTANCE_CHAT_LEADER",
	"PARTY",
	"PARTY_LEADER",
	"RAID",
	"RAID_LEADER",
	"RAID_WARNING",
	"SAY",
	"TEXT_EMOTE",
	"WHISPER",
	"YELL",
}

-- Valid unitIDs
local Units = {
	["player"] = true, -- It's entirely possible someone will try to ignore their own server
	["target"] = true,
	["focus"] = true,
	["mouseover"] = true
}

for i = 1, 40 do
	if i <= 4 then
		Units["party" .. i] = true
	end

	if i <= 5 then
		Units["arena" .. i] = true
	end

	Units["raid" .. i] = true
end

local DB;

local function FilterFunc(chatFrame, event, msg, author, ...)
	local name, realm = author:lower():match("([^-]+)[-]?([^-]*)")

	if DB[realm] then
		return true
	end
end

local function AddFilters()
	for i = 1, #Events do
		ChatFrame_AddMessageEventFilter("CHAT_MSG_" .. Events[i], FilterFunc)
	end
end

local function RemoveFilters()
	for i = 1, #Events do
		ChatFrame_RemoveMessageEventFilter("CHAT_MSG_" .. Events[i], FilterFunc)
	end
end

SLASH_SERVERIGNORE1, SLASH_SERVERIGNORE2 = "/serverignore", "/signore"

do
	local function printf(formatString, ...)
		print("|cFF33ff99ServerIgnore:|r", formatString:format(...))
	end

	local serverListTemp = {}

	local playerServer = GetRealmName():lower()

	local function ResolveServerName(name)
		if Units[name] then
			local _, serverName = UnitName(name)
			return serverName and serverName:lower() -- UnitName returns the server name in proper case, we want lowercase for the DB keys
		else
			return name
		end
	end

	SlashCmdList.SERVERIGNORE = function(input)
		local cmd, name = input:lower():trim():match("^(%S+)%s*(.*)$")

		if cmd == "toggle" then
			SERVERIGNORE_ENABLED = not SERVERIGNORE_ENABLED

			if SERVERIGNORE_ENABLED then
				printf("|cFF00ff00Enabled|r")
				AddFilters()
			else
				printf("|cFFff0000Disabled|r")
				RemoveFilters()
			end
		elseif cmd == "reset" then
			wipe(DB)
			printf("Ignore list reset.")
		elseif cmd == "add" and name and name ~= "" then
			local serverName = ResolveServerName(name)

			if not serverName or serverName == playerServer then
				printf("You cannot ignore your own server.")
			elseif DB[serverName] then
				printf("Server %s is already on your ignore list.", serverName)
			else
				DB[serverName] = true
				printf("Server %s added to your ignore list.", serverName)
			end
		elseif cmd == "remove" and name and name ~= "" then
			local serverName = ResolveServerName(name)

			if not serverName or serverName == playerServer then
				printf("You cannot ignore your own server.")
			elseif DB[serverName] then
				DB[serverName] = nil
				printf("Server %s removed from your ignore list.", serverName)
			else
				printf("Server %s is not on your ignore list.", serverName)
			end
		elseif cmd == "list" then
			local count = 0
			for server, _ in pairs(DB) do
				count = count + 1
				serverListTemp[count] = server
			end

			if count == 0 then
				printf("You have not ignored any servers yet.")
			else
				printf("Ignored Servers: %s", tconcat(serverListTemp, ", ", 1, count))
			end
		else
			printf("Slash Command Usage")
			print("|cFFff0000/serveringore|r or |cffff0000/signore cmd server||unit")
			print("    |cFFff0000toggle|r -- Enable/disable the AddOn.")
			print("    |cFFff0000reset|r -- Resets your ignore list.")
			print("    |cFFff0000add server||unit|r -- Adds a sever to your ignore list. You can either specify a server by name or use a unitID to ingore that unit's server. Valid unitIDs are target, focus, mouseover partyN, raidN and arenaN (where N is some number). You cannot ignore your own server.")
			print("    |cFFff0000remove server||unit|r -- Removes a sever from your ignore list.")
			print("    |cFFff0000list|r -- List the servers you have on ignore.")
		end
	end
end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(self, event, name)
	if name == addon then
		if SERVERIGNORE_ENABLED == nil then
			SERVERIGNORE_ENABLED = true
		end

		if SERVERIGNORE_ENABLED then
			AddFilters()
		end

		SERVERIGNORE_DB = SERVERIGNORE_DB or {}
		DB = SERVERIGNORE_DB

		self:UnregisterEvent("ADDON_LOADED")
	end
end)

