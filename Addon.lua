--[[--------------------------------------------------------------------
	HandyNotes: Field Photographer
	Shows where to take selfies for the achievement.
	Copyright (c) 2015-2018 Phanx <addons@phanx.net>. All rights reserved.
----------------------------------------------------------------------]]
local ADDON_NAME = ...
local HandyNotes = LibStub("AceAddon-3.0"):GetAddon("HandyNotes")

local ACHIEVEMENT_ID = 9924
local _, ACHIEVEMENT_NAME = GetAchievementInfo(ACHIEVEMENT_ID)
ACHIEVEMENT_NAME = ACHIEVEMENT_NAME or "Field Photographer"

local ADDON_TITLE = C_AddOns.GetAddOnMetadata(ADDON_NAME, "Title")
local ICON = "Interface\\AddOns\\"..ADDON_NAME.."\\Camera"

local L = setmetatable({}, { __index = function(t, k) t[k] = k return k end })
if GetLocale() == "deDE" then
	L["Anywhere in the city"] = "Irgendwo in der Stadt"
	L["Anywhere in the zone"] = "Irgendwo in der Zone"
	L["Continent Alpha"] = "Kontinentsopazität"
	L["Continent Scale"] = "Kontinentsgröße"
	L["Ctrl-Right-Click for all waypoints"] = "STRG-Rechtsklick, um alle Zielpunkte zu setzen"
	L["Inside the instance"] = "Innerhalb der Instanz"
	L["Inside the instance, must kill bosses to reach The Lich King"] = "Innerhalb der Instanz, man müsst Bosse töten, um den Lichkönig zu erreichen"
	L["Neverest Pinnacle doesn't count"] = "Gipfel des Nimmerlaya zählt nicht"
	L["On the surface is OK"] = "Auf der Erdoberfläche ist zulässig"
	L["Right-Click for this waypoint"] = "Rechtsklick, um Zielpunkt zu setzen"
	L["Show icons on continent maps"] = "Symbole auf Kontinentskarten anzeigen"
	L["The opacity of icons on continent maps"] = "Die Undurchsichtigkeit der Symbole auf Kontinentskarten"
	L["The opacity of icons on zone maps"] = "Die Undurchsichtigkeit der Symbole auf Zonekarten"
	L["The size of icons on continent maps"] = "Die Größe der Symbole auf Kontinentskarten"
	L["The size of icons on zone maps"] = "Die Größe der Symbole auf Zonekarten"
	L["Zone Alpha"] = "Symbolsopazität"
	L["Zone Scale"] = "Symbolsgröße"
elseif GetLocale():match("^es") then
	L["Anywhere in the city"] = "En cualquier parte de la ciudad"
	L["Anywhere in the zone"] = "En cualquier parte de la zona"
	L["Continent Alpha"] = "Opacidad en continente"
	L["Continent Scale"] = "Tamaño en continente"
	L["Ctrl-Right-Click for all waypoints"] = "Ctrl+clic derecho para todos waypoints"
	L["Inside the instance"] = "Dentro de la instancia"
	L["Inside the instance, must kill bosses to reach The Lich King"] = "Dentro de la instancia, matar a jefes para llegar al Rey Exánime"
	L["Neverest Pinnacle doesn't count"] = "Cumbre del Nieverest no cuenta"
	L["On the surface is OK"] = "En la superficie está bien"
	L["Right-Click for this waypoint"] = "Clic derecho para un waypoint"
	L["Show icons on continent maps"] = "Mostrar iconos en mapas de continentes"
	L["The opacity of icons on continent maps"] = "La opacidad de los iconos en mapas de continentes"
	L["The opacity of icons on zone maps"] = "La opacidad de los iconos en mapas de zonas"
	L["The size of icons on continent maps"] = "El tamaño de los iconos en mapas de continentes"
	L["The size of icons on zone maps"] = "El tamaño de los iconos en mapas de zonas"
	L["Zone Alpha"] = "Opacidad en zona"
	L["Zone Scale"] = "Tamaño en zona"
end

local names, mapToContinent, db, wasInCamera = {}, {}

local data = {
	[93] = { [39439262] = 27874 }, [17] = { [54605317] = 27866 }, [36] = { [25022128] = 27968 },
	[127] = { [34003700] = 27867 }, [42] = { [46987490] = 27876 }, [207] = { [59005900] = 27955 },
	[115] = { [87005100] = 27879, [60005300] = 27880 }, [27] = { [59533303] = 27873 },
	[1] = { [62027726] = 27971, [45001000] = 27869 }, [47] = { [74875097] = 27956 },
	[70] = { [52407642] = 27865 }, [23] = { [78005336] = 27954 }, [463] = { [38283533] = 27971 },
	[37] = { [66503505] = 27873, [33005000] = 27864 }, [69] = { [48562076] = 27963 },
	[100] = { [64002100] = 27974 }, [25] = { [70594495] = 27970 }, [117] = { [61005900] = 27973 },
	[118] = { [53008700] = 27863 }, [87] = { [80315213] = 27873 }, [418] = { [72003100] = 27976 },
	[379] = { [43505220] = 27964 }, [48] = { [20897417] = 27960 }, [80] = { [56766652] = 27965 },
	[198] = { [63492337] = 27953 }, [550] = { [72992066] = 27962 }, [107] = { [60112341] = 27962 },
	[109] = { [44503400] = 27966 }, [85] = { [51498109] = 27869 }, [32] = { [34938343] = 27968 },
	[539] = { [71284658] = 27871 }, [81] = { [33718109] = 27969 }, [84] = { [67193389] = 27873, [50005000] = 27864 },
	[224] = { [41445414] = 27877, [34267367] = 27868 }, [535] = { [46357388] = 27977 },
	[71] = { [63255059] = 27967 }, [108] = { [29382255] = 27952 }, [210] = { [46252601] = 27877, [35406367] = 27868 },
	[249] = { [71775195] = 27978 }, [78] = { [81784645] = 27957 }, [390] = { [50005000] = 27870 },
	[376] = { [52004800] = 27975 }, [203] = { [72173877] = 27959 }, [22] = { [46542031] = 27875, [51928248] = 27972 },
	[52] = { [42567167] = 27878, [30538642] = 27961 }, [56] = { [51210962] = 27874 }, [123] = { [49861623] = 27958 },
}

local factions = { [27869] = "Horde", [27864] = "Alliance" }
local continents = { [572] = true, [13] = true, [12] = true, [113] = true, [101] = true, [424] = true }
local notes = { [27863] = L["Inside the instance, must kill bosses to reach The Lich King"], [27864] = L["Anywhere in the city"], [27867] = L["Anywhere in the city"], [27870] = L["Anywhere in the zone"], [27873] = L["Inside the instance"], [27876] = L["Inside the instance"], [27878] = L["Inside the instance"], [27879] = L["Inside the instance"], [27959] = L["Anywhere in the zone"], [27964] = L["Neverest Pinnacle doesn't count"], [27967] = L["On the surface is OK"], [27977] = L["Inside the instance"], [27978] = L["Inside the instance"], [27869] = L["Anywhere in the city"] }

local cameraBuffs = {
	[(C_Spell.GetSpellName(181765)) or ""] = true,
	[(C_Spell.GetSpellName(181884)) or ""] = true,
}

local defaults = { profile = { zoneAlpha = 1, zoneScale = 1.5, continentScale = 1, showOnContinents = true } }

local options = {
	type = "group", name = ACHIEVEMENT_NAME,
	get = function(info) return db[info[#info]] end,
	set = function(info, v) db[info[#info]] = v HandyNotes:SendMessage("HandyNotes_NotifyUpdate", ACHIEVEMENT_NAME) end,
	args = {
		zoneAlpha = { order = 2, name = L["Zone Alpha"], type = "range", min = 0, max = 1, step = 0.05, isPercent = true },
		zoneScale = { order = 4, name = L["Zone Scale"], type = "range", min = 0.25, max = 2, step = 0.05, isPercent = true },
		showOnContinents = { order = 6, name = L["Show icons on continent maps"], type = "toggle", width = "full" },
		continentAlpha = { order = 8, name = L["Continent Alpha"], type = "range", min = 0, max = 1, step = 0.05, isPercent = true, disabled = function() return not db.showOnContinents end },
		continentScale = { order = 10, name = L["Continent Scale"], type = "range", min = 0.25, max = 2, step = 0.05, isPercent = true, disabled = function() return not db.showOnContinents end },
	}
}

local pluginHandler = {}
function pluginHandler:OnEnter(mapID, coord)
	local tooltip = GameTooltip
	tooltip:SetOwner(self, "ANCHOR_RIGHT")
	local criteria = data[mapID] and data[mapID][coord]
	if criteria then
		tooltip:AddLine(names[criteria])
		tooltip:AddLine(ACHIEVEMENT_NAME, 1, 1, 1)
		if notes[criteria] then tooltip:AddLine(notes[criteria], 1, 1, 1) end
		tooltip:Show()
	end
end
function pluginHandler:OnLeave() GameTooltip:Hide() end

local waypoints = {}
local function setWaypoint(mapID, coord)
	local criteria = data[mapID][coord]
	local x, y = HandyNotes:getXY(coord)
	if TomTom then
		waypoints[criteria] = TomTom:AddWaypoint(mapID, x, y, { title = (names[criteria] or criteria) .. "\n" .. ACHIEVEMENT_NAME })
	end
end

function pluginHandler:OnClick(button, down, mapID, coord)
	if button == "RightButton" and TomTom then setWaypoint(mapID, coord) end
end

do
	local scale, alpha
	local function iterator(t, prev)
		if not t then return end
		local coord, v = next(t, prev)
		if coord then return coord, nil, ICON, scale * 1.4, alpha end
	end
	function pluginHandler:GetNodes2(mapID)
		local isCont = continents[mapID]
		if isCont and not db.showOnContinents then return function() end end
		scale, alpha = isCont and db.continentScale or db.zoneScale, isCont and db.continentAlpha or db.zoneAlpha
		return iterator, data[mapID]
	end
end

local Addon = CreateFrame("Frame")
Addon:RegisterEvent("PLAYER_LOGIN")
Addon:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)

function Addon:PLAYER_LOGIN()
	HandyNotes:RegisterPluginDB(ACHIEVEMENT_NAME, pluginHandler, options)
	self.db = LibStub("AceDB-3.0"):New("HNFieldPhotographerDB", defaults, true)
	db = self.db.profile
	local faction = UnitFactionGroup("player")
	for m, cs in pairs(data) do
		for c, crit in pairs(cs) do
			if factions[crit] and factions[crit] ~= faction then cs[c] = nil end
		end
	end
	self:RegisterEvent("UPDATE_OVERRIDE_ACTIONBAR")
	self:CRITERIA_UPDATE()
end

function Addon:UPDATE_OVERRIDE_ACTIONBAR()
	local inCamera = false
	for i = 1, 40 do
		local aura = C_UnitAuras.GetBuffDataByIndex("player", i)
		if not aura then break end
		
		local name = aura.name
		if name and cameraBuffs[name] then
			inCamera = true
			break
		end
	end
	if wasInCamera ~= inCamera then
		wasInCamera = inCamera
		if inCamera then
			self:RegisterEvent("CRITERIA_UPDATE")
		else
			self:UnregisterEvent("CRITERIA_UPDATE")
		end
	end
end

function Addon:CRITERIA_UPDATE()
	for m, cs in pairs(data) do
		for c, crit in pairs(cs) do
			local name, _, complete = GetAchievementCriteriaInfoByID(ACHIEVEMENT_ID, crit)
			if complete then cs[c] = nil else names[crit] = name end
		end
	end
	HandyNotes:SendMessage("HandyNotes_NotifyUpdate", ACHIEVEMENT_NAME)
end  
