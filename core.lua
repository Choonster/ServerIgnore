local addon, ns = ...

local units = {
	["target"] = true,
	["focus"] = true,
	["mouseover"] = true
}

for i = 1, 40 do
	if i <= 4 then
		units["party" .. i] = true
	end
	
	if i <= 5 then
		units["arena" .. i] = true
	end
	
	units["raid" .. i] = true
end

local db;

local function filterFunc(self, event, msg, author, ...)
	local name, realm = author:lower():match("([^-]+)[-]?([^-]*)")
	
	if db[realm] then
		return true
	end
end

local function AddFilters()
	ChatFrame_AddMessageEventFilter("CHAT_MSG_ACHIEVEMENT", filterFunc)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_AFK", filterFunc)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BATTLEGROUND", filterFunc)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BATTLEGROUND_LEADER", filterFunc)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", filterFunc)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_DND", filterFunc)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_EMOTE", filterFunc)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", filterFunc)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", filterFunc)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", filterFunc)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", filterFunc)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_WARNING", filterFunc)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", filterFunc)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_TEXT_EMOTE", filterFunc)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", filterFunc)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", filterFunc)
end

local function RemoveFilters()
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_ACHIEVEMENT", filterFunc)
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_AFK", filterFunc)
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_BATTLEGROUND", filterFunc)
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_BATTLEGROUND_LEADER", filterFunc)
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_CHANNEL", filterFunc)
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_DND", filterFunc)
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_EMOTE", filterFunc)
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_PARTY", filterFunc)
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_PARTY_LEADER", filterFunc)
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_RAID", filterFunc)
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_RAID_LEADER", filterFunc)
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_RAID_WARNING", filterFunc)
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_SAY", filterFunc)
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_TEXT_EMOTE", filterFunc)
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_WHISPER", filterFunc)
	ChatFrame_RemoveMessageEventFilter("CHAT_MSG_YELL", filterFunc)
end

SLASH_SERVERIGNORE1, SLASH_SERVERIGNORE2 = "/serverignore", "/signore"

local function q(s)
	return ("%q"):format(tostring(s))
end

local prefix = "|cff33ff99ServerIgnore:|r"	

SlashCmdList.SERVERIGNORE = function(input)
	local cmd, name = input:lower():trim():match("^(%S+)%s*(.*)$")
	
	if cmd == "toggle" then
		SERVERIGNORE_ENABLED = not SERVERIGNORE_ENABLED
		
		if SERVERIGNORE_ENABLED then
			print(prefix, "|cff00ff00Enabled|r")
			AddFilters()
		else
			print(prefix, "|cff0000Disabled|r")
			RemoveFilters()
		end
	elseif cmd == "reset" then
		wipe(db)
		print(prefix, "Ignore list reset.")
	elseif cmd == "add" and name and name ~= "" then
		local serverName, _;
		if units[name] then
			_, serverName = UnitName(name)
		else
			serverName = name
		end
		
		if db[serverName] then
			print(prefix, ("Server %s is already on your ignore list."):format(serverName))
		elseif serverName then
			db[serverName] = true
			print(prefix, ("Server %s added to your ignore list."):format(serverName))
		else
			print(prefix, ("Unit %q is on your server."):format(name))
		end
	elseif cmd == "remove" and name and name ~= "" then
		local serverName, _;
		if units[name] then
			_, serverName = UnitName(name)
		else
			serverName = name
		end
		
		if db[serverName] then
			db[serverName] = nil
			print(prefix, ("Server %s removed from your ignore list."):format(serverName))
		elseif serverName then
			print(prefix, ("Server %s is not on your ignore list."):format(serverName))
		else
			print(preifx, ("Unit %s is on your server."):format(name))
		end
	elseif cmd == "list" then
		local str = next(db)
		local empty = true
		local count = 0
		
		for server in next, db, str do
			empty = false
			count = (i % 3) + 1
			str = ("%s, %s"):format(str, server)
		end
		print(prefix, "Ignored Servers:")
		print(empty and "You have not ignored any servers yet." or str)
	else
		print(prefix, "Slash Command Usage")
		print("|cffff0000/serveringore|r or |cffff0000/signore cmd server||unit")
		print("    |cffff0000toggle|r -- Enable/disable the AddOn.")
		print("    |cffff0000reset|r -- Resets your ignore list.")
		print("    |cffff0000add server||unit|r -- Adds a sever to your ignore list. You can either specify a server by name or use a unitID to ingore that unit's server. Valid unitIDs are target, focus, mouseover partyN, raidN and arenaN (where N is some number).")
		print("        You cannot add your own server to the list using a unitID (but you can by specifying its name). Messages from your own server will never be ignored (even if it's on the list).")
		print("    |cffff0000remove server||unit|r -- Removes a sever to your ignore list.")
		print("    |cffff0000list|r -- List the servers you have on ignore.")		
	end
end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(self, event, name)
	if name == addon then
		SERVERIGNORE_ENABLED = SERVERIGNORE_ENABLED == nil and true or SERVERIGNORE_ENABLED
		
		if SERVERIGNORE_ENABLED then
			AddFilters()
		end
		
		SERVERIGNORE_DB = SERVERIGNORE_DB or {}
		db = SERVERIGNORE_DB
		
		self:UnregisterEvent("ADDON_LOADED")
	end
end)