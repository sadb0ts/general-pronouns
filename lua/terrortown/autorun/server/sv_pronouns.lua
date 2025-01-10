util.AddNetworkString("TTT2PronounBroadcast")
util.AddNetworkString("TTT2PronounGetAll")

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

net.Receive("TTT2PronounGetAll", function(_, ply)
	local pronounORM = GetPronounORM()
	local pronouns = pronounORM:All()
	if #pronouns == 0 then return end
	net.Start("TTT2PronounGetAll")
	net.WriteUInt(#pronouns, 16)
	for i = 1, #pronouns do
		net.WriteUInt64(pronouns[i].name)
		net.WriteString(pronouns[i].pronouns)
	end

	net.Send(ply)
	print("Sent " .. #pronouns .. " entries of pronoun data to connected player.")
end)