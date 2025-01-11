local CATEGORY_NAME = "Utility"
local function GetPronounORM()
	local sqlTableName = "ttt2_pronouns_table"
	local savingKeys = {
		-- steamId is primary key column 'name'
		pronouns = {
			typ = "string",
			default = nil
		}
	}

	if not sql.CreateSqlTable(sqlTableName, savingKeys) then return end
	return orm.Make(sqlTableName)
end

local function setPronouns(target_ply, pronounText, isAdmin)
	local pronounORM = GetPronounORM()
	if not pronounORM then return end
	if pronounText == "nil" then pronounText = nil end
	local pronounData = pronounORM:Find(target_ply:SteamID64())

	if not pronounText then
		if pronounData then
			pronounData:Delete()
		end
	else
		if not pronounData then
		pronounData = pronounORM:New({
			name = target_ply:SteamID64(),
			pronouns = pronounText
		})
		else
			pronounData.pronouns = pronounText
		end
		pronounData:Save()
	end

	net.Start("TTT2PronounBroadcast")
	net.WriteUInt64(target_ply:SteamID64())
	net.WriteString(pronounText or "nil")
	net.Broadcast()

	if not isAdmin then
		if pronounText then
			ULib.tsay(target_ply, "Your pronouns have been updated to (" .. pronounText .. ").")
		else
			ULib.tsay(target_ply, "Your pronouns have been removed.")
		end
	end
end

local function pronouns(calling_ply, pronounText)
	setPronouns(calling_ply, pronounText)
end

local function forcepronouns(calling_ply, target_ply, pronounText)
	setPronouns(target_ply, pronounText, true)
end

local pronounscmd = ulx.command(CATEGORY_NAME, "ulx pronouns", pronouns, "!pronouns")
pronounscmd:addParam{
	type = ULib.cmds.StringArg,
	hint = "pronouns"
}

pronounscmd:defaultAccess(ULib.ACCESS_ALL)
pronounscmd:help("Sets your pronouns for the server. Do not include parentheses; they will be added for you.")

local forcepronounscmd = ulx.command(CATEGORY_NAME, "ulx forcepronouns", forcepronouns, "!forcepronouns")
forcepronounscmd:addParam{
	type = ULib.cmds.PlayersArg
}

forcepronounscmd:addParam{
	type = ULib.cmds.StringArg,
	hint = "pronouns"
}

forcepronounscmd:defaultAccess(ULib.ACCESS_ADMIN)
forcepronounscmd:help("Sets a player's pronouns.")