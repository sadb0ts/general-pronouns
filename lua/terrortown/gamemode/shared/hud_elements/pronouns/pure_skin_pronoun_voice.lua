local base = "pure_skin_element"

DEFINE_BASECLASS(base)

HUDELEMENT.Base = base

if CLIENT then
	local function GetPronounORM()
		local sqlTableName = "ttt2_pronouns_table"
		local savingKeys = {
			// steamId is primary key column 'name'
			pronouns = {
				typ = "string",
				default = nil
			}
		}

		if not sql.CreateSqlTable(sqlTableName, savingKeys) then return end
		return orm.Make(sqlTableName)
	end

	local padding = 6
	local colorPronounBox = Color(0, 0, 0, 150)

	local baseDefaults = {
		basepos = { x = 240, y = 0 },
		size = { w = 240, h = 21 },
		minsize = { w = 120, h = 21 },
	}

	function HUDELEMENT:Initialize()
		self.scale = 1.0
		self.padding = padding

		BaseClass.Initialize(self)
	end

	function HUDELEMENT:IsResizable()
		return true, false
	end

	function HUDELEMENT:GetDefaults()
		baseDefaults["basepos"] = {
			x = 250 * self.scale, // X offset by width of voice HUD, 240.
			y = 10 * self.scale,
		}

		return baseDefaults
	end

	function HUDELEMENT:PerformLayout()
		self.scale = appearance.GetGlobalScale()
		self.padding = padding * self.scale

		BaseClass.PerformLayout(self)
	end

	function HUDELEMENT:DrawPronounBox(pronoun, xPos, yPos, maxWidth, h)
		local fontScale = self.scale * 0.75
		local maxPronounWidth = maxWidth - self.padding * 2

		draw.AdvancedText(
			draw.GetLimitedLengthText(pronoun, maxPronounWidth, "PureSkinPopupText", "...", fontScale),
			"PureSkinPopupText",
			xPos + self.padding,
			yPos + h * 0.5 - 1,
			util.GetDefaultColor(colorPronounBox),
			TEXT_ALIGN_LEFT,
			TEXT_ALIGN_CENTER,
			true,
			fontScale
		)
	end

	function HUDELEMENT:Draw()
		local shouldVoiceDisplay = GetConVar("ttt2_pronouns_voice"):GetBool()
		if not shouldVoiceDisplay then return end

		local client = LocalPlayer()

		local pos = self:GetPos()
		local size = self:GetSize()
		local x, y = pos.x, pos.y
		local w, h = size.w, size.h

		y = y + (h * 2 - h) / 2

		local plys = player.GetAll()
		local plysSorted = {}

		for i = 1, #plys do
			local ply = plys[i]

			if not VOICE.IsSpeaking(ply) then
				continue
			end

			if ply == client then
				table.insert(plysSorted, 1, ply)

				continue
			end

			plysSorted[#plysSorted + 1] = ply
		end

		local pronounORM = GetPronounORM()
		for i = 1, #plysSorted do
			local ply = plysSorted[i]

			local pronouns = ""
			if pronounORM then
				local userTable = pronounORM:Find(ply:SteamID64())
				if userTable then
					pronouns = "(" .. userTable.pronouns .. ") "
				end
			end

			// Ensure that blank pronouns are still drawn without error.
			if not pronouns or pronouns == "" then pronouns = "" end

			self:DrawPronounBox(pronouns, x, y, w, h)

			y = y + h * 2 + self.padding
		end
	end
end
