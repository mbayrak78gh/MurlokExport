--TODO
--- localization
--- get rid of lib icon dependency


local _, core = ...
local classId, specId

ClassConfig = {
	["death-knight"] = {
		class = {id = 6, icon = 135771},
		specs = {
			["blood"] = {id = 250, icon = 135770},
			["frost"] = {id = 251, icon = 1135773},
			["unholy"] = {id = 252, icon = 1135775}
		}
	},
	["demon-hunter"] = {
		class = {id = 12, icon = 1260827},
		specs = {
			["havoc"] = {id = 577, icon = 1247264},
			["vengeance"] = {id = 581, icon = 1247265}
		}
	},
	["druid"] = {
		class = {id = 11, icon = 625999},
		specs = {
			["balance"] = {id = 102, icon = 136096},
			["feral"] = {id = 103, icon = 132115},
			["guardian"] = {id = 104, icon = 132276},
			["restoration"] = {id = 105, icon = 136041}
		}
	},
	["evoker"] = {
		class = {id = 13, icon = 4574311},
		specs = {
			["devastation"] = {id = 1467, icon = 4511811},
			["preservation"] = {id = 1468, icon = 4511812},
			["augmentation"] = {id = 1473, icon = 5198700}
		}
	},
	["hunter"] = {
		class = {id = 3, icon = 626000},
		specs = {
			["beast-mastery"] = {id = 253, icon = 461112},
			["marksmanship"] = {id = 254, icon = 236179},
			["survival"] = {id = 255, icon = 461113}
		}
	},
	["mage"] = {
		class = {id = 8, icon = 626001},
		specs = {
			["arcane"] = {id = 62, icon = 135932},
			["fire"] = {id = 63, icon = 135810},
			["frost"] = {id = 64, icon = 135846}
		}
	},
	["monk"] = {
		class = {id = 10, icon = 626002},
		specs = {
			["brewmaster"] = {id = 268, icon = 608951},
			["windwalker"] = {id = 269, icon = 608953},
			["mistweaver"] = {id = 270, icon = 608952}
		}
	},
	["paladin"] = {
		class = {id = 2, icon = 626003},
		specs = {
			["holy"] = {id = 65, icon = 135920},
			["protection"] = {id = 66, icon = 236264},
			["retribution"] = {id = 70, icon = 135873}
		}
	},
	["priest"] = {
		class = {id = 5, icon = 626004},
		specs = {
			["discipline"] = {id = 256, icon = 135940},
			["holy"] = {id = 257, icon = 237542},
			["shadow"] = {id = 258, icon = 136207}
		}
	},
	["rogue"] = {
		class = {id = 4, icon = 626005},
		specs = {
			["assassination"] = {id = 259, icon = 236270},
			["outlaw"] = {id = 260, icon = 236286},
			["subtlety"] = {id = 261, icon = 132320}
		}
	},
	["shaman"] = {
		class = {id = 7, icon = 626006},
		specs = {
			["elemental"] = {id = 262, icon = 136048},
			["enhancement"] = {id = 263, icon = 237581},
			["restoration"] = {id = 264, icon = 136052}
		}
	},
	["warlock"] = {
		class = {id = 9, icon = 626007},
		specs = {
			["affliction"] = {id = 265, icon = 136145},
			["demonology"] = {id = 266, icon = 136172},
			["destruction"] = {id = 267, icon = 136186}
		}
	},
	["warrior"] = {
		class = {id = 1, icon = 626008},
		specs = {
			["arms"] = {id = 71, icon = 132355},
			["fury"] = {id = 72, icon = 132347},
			["protection"] = {id = 73, icon = 132341}
		}
	}
}

SlotConfig = {
	["head"] = "HEADSLOT",
	["neck"] = "NECKSLOT",
	["shoulders"] = "SHOULDERSLOT",
	["back"] = "BACKSLOT",
	["chest"] = "CHESTSLOT",
	["waist"] = "WAISTSLOT",
	["legs"] = "LEGSSLOT",
	["feet"] = "FEETSLOT",
	["wrist"] = "WRISTSLOT",
	["hands"] = "HANDSSLOT",
	["ring-1"] = "FINGER0SLOT",
	["ring-2"] = "FINGER1SLOT",
	["trinket-1"] = "TRINKET0SLOT",
	["trinket-2"] = "TRINKET1SLOT",
	["main-hand"] = "MAINHANDSLOT",
	["off-hand"] = "SECONDARYHANDSLOT"
}

function core:Toggle()
	UIMurlokExport:SetShown(not UIMurlokExport:IsShown())
end

function core:GetThemeColor()
	return 0, 0.8, 1, "00ccff"
end

function core:GetPlayerClassSpec()
    local specId = GetSpecializationInfo(GetSpecialization())
	local _, classId = UnitClassBase("player")
    return classId, specId
end

function core:Capitialize(str)
	return (str:gsub("^%l", string.upper))
end

function core:Pairs(t, f)
	local a = {}
	for n in pairs(t) do table.insert(a, n) end
	table.sort(a, f)
	local i = 0
	local iter = function ()
	  i = i + 1
	  if a[i] == nil then return nil
	  else return a[i], t[a[i]]
	  end
	end
	return iter
end

function core:IPairs(t, f, asc)
	local a = {}
	for n, m in pairs(t) do table.insert(a, {n, m}) end
	if f == nil then
		if not asc then
			table.sort(a, function (k1, k2) return k1 ~= nil and k2 ~= nil and k1[2] > k2[2] end)
		else
			table.sort(a, function (k1, k2) return k1 ~= nil and k2 ~= nil and k1[2] < k2[2] end)
		end
	else
		table.sort(a, f)
	end
	local i = 0
	local iter = function ()
	  i = i + 1
	  if a[i] == nil then return nil
	  else return a[i][1], a[i][2]
	  end
	end
	return iter
end

function core:TableLength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

local assetRootPath = "Interface\\AddOns\\MurlokExport\\assets\\"
function core:Asset(path)
	return assetRootPath .. path
end

function core:GetPlayerStats()
	local playerStats = {}

	local spellCrit, rangedCrit, meleeCrit
	local critChance

	local holySchool = 2
	local minCrit = GetSpellCritChance(holySchool)
	for i=(holySchool+1), MAX_SPELL_SCHOOLS do
		spellCrit = GetSpellCritChance(i)
		minCrit = min(minCrit, spellCrit)
	end
	spellCrit = minCrit
	rangedCrit = GetRangedCritChance()
	meleeCrit = GetCritChance()

	if (spellCrit >= rangedCrit and spellCrit >= meleeCrit) then
		critChance = spellCrit
	elseif (rangedCrit >= meleeCrit) then
		critChance = rangedCrit
	else
		critChance = meleeCrit
	end
	playerStats["crit"] = critChance
	playerStats["haste"] = GetHaste()
	playerStats["mastery"] = GetMasteryEffect()
	playerStats["versatility"] = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE)
	playerStats["avoidance"] = GetAvoidance()
	playerStats["leech"] = GetLifesteal()
	playerStats["speed"] = GetSpeed()

	return playerStats
end

local function getRankColor(rank)
	if rank == 0 then return ITEM_LEGENDARY_COLOR:GenerateHexColorMarkup() elseif rank >= 1 and rank < 5 then return EPIC_PURPLE_COLOR:GenerateHexColorMarkup() else return WHITE_FONT_COLOR:GenerateHexColorMarkup() end
end

function UIMurlokExport_OnLoad(self)
	self:SetTitle("Murlok Export")
	tinsert(UISpecialFrames, self:GetName())
	UIMurlokExportPortrait:SetTexture(core:Asset("murlok"))

	UIMurlokExport:RegisterForDrag("LeftButton")

	ClassFrame_SetTabs(UIMurlokExport.ClassInset, 2, "Mythic+", "Solo PvP")

	local classView = CreateScrollBoxListLinearView()
	classView:SetElementInitializer("ClassListButtonTemplate", function(button, elementData) UIMurlokExport_InitClassButton(button, elementData) end)
	classView:SetPadding(0,0,84,0,0)
	ScrollUtil.InitScrollBoxListWithScrollBar(self.ClassScrollBox, self.ClassScrollBar, classView)
	UIMurlokExport.ClassSelectionBehavior = ScrollUtil.AddSelectionBehavior(self.ClassScrollBox, SelectionBehaviorFlags.Intrusive)
	UIMurlokExport.ClassSelectionBehavior:RegisterCallback(SelectionBehaviorMixin.Event.OnSelectionChanged, ClassListItem_OnSelectionChanged)

	local talentsView = CreateScrollBoxListLinearView()
	talentsView:SetElementInitializer("TalentsListTemplate", function(frame, elementData) UIMurlokExport_InitTalentFrame(frame, elementData) end)
	talentsView:SetPadding(25,10,10,10,0)
	ScrollUtil.InitScrollBoxListWithScrollBar(self.TalentsScrollBox, self.TalentsScrollBar, talentsView)

	local equipmentsView = CreateScrollBoxListLinearView()
	equipmentsView:SetElementInitializer("EquipmentsListTemplate", function(frame, elementData) UIMurlokExport_InitEquipmentFrame(frame, elementData) end)
	equipmentsView:SetPadding(0,280,60,60,0)
	ScrollUtil.InitScrollBoxListWithScrollBar(self.EquipmentsScrollBox, self.EquipmentsScrollBar, equipmentsView)
end

function ClassListItem_OnSelectionChanged(self, elementData, selected)
    local button = UIMurlokExport.ClassScrollBox:FindFrameByPredicate(function(frame, edata) return edata.classId == elementData.classId and edata.specId == elementData.specId and edata.hero == elementData.hero end)
	if button then
		button.hilightFrame.ActiveTexture:SetShown(selected)
		button.selectedTexture:SetShown(selected)
	end
end

function ClassFrame_SelectedTabOnClick()
	local tabId = 1
	if UIMurlokExport.ClassInset.selectedTab and UIMurlokExport.ClassInset.selectedTab > 0 then
		tabId = UIMurlokExport.ClassInset.selectedTab
	end
	ClassFrame_TabOnClick(_G[UIMurlokExport.ClassInset:GetName().."ContentTab"..tabId])
end

function ClassFrame_TabOnClick(self)
	PanelTemplates_SetTab(self:GetParent(), self:GetID())
	local tabToContent = {'mm+', 'solo'}
	UIMurlokExport_UpdateClassList(tabToContent[self:GetID()])
	if UIMurlokExport.activeClassId and UIMurlokExport.activeSpecId and UIMurlokExport.activeHero then
		local function predicate(edata) return edata.classId == UIMurlokExport.activeClassId and edata.specId == UIMurlokExport.activeSpecId and edata.hero == UIMurlokExport.activeHero end
    	local button = UIMurlokExport.ClassScrollBox:FindFrameByPredicate(function(frame, edata) return predicate(edata) end)
		if button then
			-- UIMurlokExport.ClassScrollBox:ScrollToElementDataByPredicate(function(edata) return predicate(edata) end, button.elementData, ScrollBoxConstants.AlignNearest, true)
			button:OnClick("LeftButton")
		end
	end
end

function ClassFrame_SetTabs(frame, numTabs, ...)
	frame.numTabs = numTabs

	local frameName = frame:GetName()
	for i = 1, numTabs do
		local tab = CreateFrame("Button", frameName.."ContentTab"..i, frame, "CharacterFrameTabTemplate")
		tab:SetID(i)
		tab:SetText(select(i, ...))
		tab:SetScript("OnClick", ClassFrame_TabOnClick)
		if (i == 1) then
			tab:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 5, -12)
		else
			tab:SetPoint("TOPLEFT", _G[frameName.."ContentTab"..(i - 1)], "TOPRIGHT", 5, 0)
		end
	end
end

function UIMurlokExport_OnShow(self)
	C_AddOns.LoadAddOn("Blizzard_PlayerSpells")

	ClassFrame_SelectedTabOnClick()

	local classId, specId = core:GetPlayerClassSpec()
	if UIMurlokExport.activeClassId == nil and UIMurlokExport.activeSpecId == nil and UIMurlokExport.activeHero == nil then
		local button = UIMurlokExport.ClassScrollBox:FindFrameByPredicate(function(frame, edata) return edata.classId == classId and edata.specId == specId end)
		if button then 
			button:OnClick("LeftButton")
		end
	end

	-- add cancel/delete button to loadouts
	local ls = PlayerSpellsFrame.TalentsFrame.LoadSystem
	local f = ls.Dropdown
	f.OnMenuOpened = function(dropdown)
		local menu = dropdown.menu
		local children = {menu:GetChildren()}
		local index = 1
		for i, child in ipairs(children) do
			if child:GetObjectType() == "Button" then
				local id = ls.possibleSelections[index]
				index = index + 1
				if ls:IsSelectionIDValidAndEnabled(id) then
					local buttons = {child:GetChildren()}
					local cancelButton = MenuTemplates.AttachAutoHideCancelButton(child)
					cancelButton:SetPoint("RIGHT", buttons[1], "LEFT")
					cancelButton:SetScript("OnClick", function()
						C_ClassTalents.DeleteConfig(id)
						menu:Close()
					end)
				end
			end
		end
		f:TriggerEvent(f.Event.OnMenuOpen, f)
	end
end

function UIMurlokExport_UpdateClassList(content)
	local newDataProvider = CreateDataProvider()
	local index = 0
	classId = core:GetPlayerClassSpec()
	for class, config in core:Pairs(MurlokExport[content]) do
		if ClassConfig[class].class.id == classId then
			index = UIMurlokExport_InsertSpec(index, newDataProvider, class, config)
		end
	end
	for class, config in core:Pairs(MurlokExport[content]) do
		if ClassConfig[class].class.id ~= classId then
			index = UIMurlokExport_InsertSpec(index, newDataProvider, class, config)
		end
	end
	UIMurlokExport.ClassScrollBox:SetDataProvider(newDataProvider, ScrollBoxConstants.RetainScrollPosition)
end

function UIMurlokExport_InsertSpec(index, newDataProvider, class, config)
	for spec, heros in core:Pairs(config) do
		local _, _, _, specIcon = GetSpecializationInfoByID(ClassConfig[class].specs[spec].id)
		for hero, stats in core:Pairs(heros) do
			index = index + 1
			newDataProvider:Insert({
				classIndex = index,
				classId = ClassConfig[class].class.id,
				classIcon = ClassConfig[class].class.icon,
				specId = ClassConfig[class].specs[spec].id,
				specIcon = specIcon,
				hero = core:Capitialize(hero):gsub('-', ' '),
				hero_atlas = "talents-heroclass-"..class:gsub('-', '').."-"..hero:gsub('-', ''):gsub('\'', ''),
				count = stats["count"],
				stats = stats
			})
		end
	end
	return index
end

function UIMurlokExport_InitClassButton(button, elementData)
	button.classIcon:SetTexture(elementData.classIcon)
	button.specIcon:SetTexture(elementData.specIcon)
	button.name:SetText(elementData.hero)
	button.hero_atlas = elementData.hero_atlas
	button.heroIcon:SetAtlas(elementData.hero_atlas)
	button.count:SetText(elementData.count)
	button.hilightFrame.ActiveTexture:Hide()
	button.classId = elementData.classId
	button.specId = elementData.specId
	button.hero = elementData.hero
	button.classIndex = elementData.classIndex
	button.stats = elementData.stats
end

function UIMurlokExport_InitTalentFrame(frame, elementData)
	frame.talentBox.EditBox:SetAutoFocus(false)
	frame.talentBox.CharCount:Hide()
	frame.talentBox.EditBox:SetText(elementData.talentString)

	frame.talentIndex:SetText(getRankColor(elementData.index - 1)..elementData.index..".|r")
	frame.tryOutTalentButton.tryOutTalentTexture:SetAtlas(elementData.hero_atlas, true)
	frame.tryOutTalentButton.talentBox = frame.talentBox
end

function UIMurlokExport_InitEquipmentFrame(frame, elementData)
	frame.equipmentSlot:SetText(core:Capitialize(elementData.equipmentSlot))

	local index = 1
	local enchants = {}
	for k, v in core:IPairs(elementData.equipment.enchantments, function (k1, k2) return k1[2].count > k2[2].count end) do
		enchants[index] = k
	end

	index  = 1
	for k, v in core:IPairs(elementData.equipment.items, function (k1, k2) return k1[2].count > k2[2].count end) do
		local bonus = ""
		if v.bonus then 
			bonus = #v.bonus .. ":" .. table.concat(v.bonus, ":")
		end
		local enchant = ""
		if enchants[index] then
			enchant = enchants[index]
		end
		local link = ( "|Hitem:"..k..":"..enchant.."::::::::"..elementData.specId..":::"..bonus.."|h")
		frame["itemButton"..index]:SetItem(link)
		frame["itemButton"..index].Count:SetText(getRankColor(v.rank) .. v.count .. "|r")
		frame["itemButton"..index].Count:Show()
		frame["itemButton"..index]:Show()
		index = index + 1
	end
	for i=index,5 do
		frame["itemButton"..i]:SetItem(nil)
		frame["itemButton"..i]:SetItemButtonCount(0)
		frame["itemButton"..i]:Hide()
	end

	index = 1
	for k, v in core:IPairs(elementData.equipment.gems, function (k1, k2) return k1[2].count > k2[2].count end) do
		local link = ( "|Hitem:"..k.."|h")
		frame["gemButton"..index]:SetItem(link)
		frame["gemButton"..index].Count:SetText(getRankColor(v.rank) .. v.count .. "|r")
		frame["gemButton"..index].Count:Show()
		frame["gemButton"..index]:Show()
		index = index + 1
	end
	for i=index,5 do
		frame["gemButton"..i]:SetItem(nil)
		frame["gemButton"..i]:SetItemButtonCount(0)
		frame["gemButton"..i]:Hide()
	end
end

function EquipmentsItemSlotButton_OnLoad(self)
	self:RegisterForClicks("LeftButtonUp")

	local id, textureName = GetInventorySlotInfo(strsub(self:GetParentKey(), 10))
	self:SetID(id)
	self.icon:SetTexture(textureName)
	self.emptyTexture = textureName
end

function EquipmentsItemSlotButton_OnShow(self)
	local link = GetInventoryItemLink("player", self:GetID())
	if link then
		self:SetItem(link)
	else
		self:SetItem(nil)
		self.icon:SetTexture(self.emptyTexture)
		self.icon:SetShown(self.emptyTexture ~= nil)
	end
end

function EquipmentsItemSlotButton_OnClick(self, button)
	if button == "LeftButton" and self:GetID() then
		UIMurlokExport.EquipmentsScrollBox:ScrollToElementDataByPredicate(function(e) return e.slotId == self:GetID() end, ScrollBoxConstants.AlignBegin, 0, true)
	end
	self:OnClick()
end

EnchantingItemButtonMixin = {}
function EnchantingItemButtonMixin:CheckUpdateTooltip(tooltipOwner)
	if self == tooltipOwner then
		if self:HasItem() then
			self:UpdateTooltip()
		else
			GameTooltip:Hide()
		end
	end
end

function EnchantingItemButtonMixin:OnEnter()
	self:OnUpdate()
end

function EnchantingItemButtonMixin:OnLeave()
	GameTooltip_Hide()
end

function EnchantingItemButtonMixin:OnUpdate()
	if self:GetItem() then
		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		EnchantingItemButton_CalculateItemTooltipAnchors(self, GameTooltip)
		GameTooltip:SetHyperlink(self:GetItem())
	end
end

function EnchantingItemButtonMixin:OnClick()
	if self:GetItem() then
		local _, link = C_Item.GetItemInfo(self:GetItem())
		HandleModifiedItemClick(link)
	end
end

function EnchantingItemButton_CalculateItemTooltipAnchors(self, mainTooltip)
	local x = self:GetRight()
	local anchorFromLeft = x < GetScreenWidth() / 2
	if ( anchorFromLeft ) then
		mainTooltip:SetAnchorType("ANCHOR_RIGHT", 0, 0)
		mainTooltip:SetPoint("BOTTOMLEFT", self, "TOPRIGHT")
	else
		mainTooltip:SetAnchorType("ANCHOR_LEFT", 0, 0)
		mainTooltip:SetPoint("BOTTOMRIGHT", self, "TOPLEFT")
	end
end

ClassListItemMixin = {}
function ClassListItemMixin:OnUpdate()
	local active = self.classId and self.specId and self.hero and UIMurlokExport.activeSpecId == self.specId and UIMurlokExport.activeClassId == self.classId and UIMurlokExport.activeHero == self.hero
	self.hilightFrame.ActiveTexture:SetShown(active)
	self.selectedTexture:SetShown(active)
end

function ClassListItemMixin:OnClick(button)
	if button == "LeftButton" then
		local playerStats = core:GetPlayerStats()
		
		local index = 1
		for k, v in core:IPairs(self.stats.secondary_stats, function (k1, k2) return k1 ~= nil and k2 ~= nil and k1[2].value > k2[2].value end) do
			UIMurlokExport.stats["secStatIcon"..index]:SetTexture(core:Asset("Attribute_"..k))
			UIMurlokExport.stats["secStatName"..index]:SetText(core:Capitialize(k).."\n"..v.value.." / "..v.percent.."%\n".."["..format("%d%%", playerStats[k] + 0.5).."]")
			index = index + 1
		end

		local index = 1
		for k, v in core:IPairs(self.stats.minor_stats, function (k1, k2) return k1 ~= nil and k2 ~= nil and k1[2].value > k2[2].value end) do
			UIMurlokExport.stats["minorStatIcon"..index]:SetTexture(core:Asset("Attribute_"..k))
			UIMurlokExport.stats["minorStatName"..index]:SetText(core:Capitialize(k).."\n"..v.value.." / "..v.percent.."%\n".."["..format("%d%%", playerStats[k] + 0.5).."]")
			index = index + 1
		end
		UIMurlokExport.stats.ratingStatName:SetText(getRankColor(0) .. self.stats.rating .. "|r")

		UIMurlokExport.activeClassId = self.classId
		UIMurlokExport.activeSpecId = self.specId
		UIMurlokExport.activeHero = self.hero
		UIMurlokExport.activeStats = self.stats
		UIMurlokExport.ClassSelectionBehavior:Select(self)

		local talentsDataProvider = CreateDataProvider()
		for index, talentString in ipairs(self.stats.talents) do
			talentsDataProvider:Insert({
				index = index,
				talentString = talentString,
				hero_atlas = self.hero_atlas
			})
		end
		UIMurlokExport.TalentsScrollBox:SetDataProvider(talentsDataProvider, ScrollBoxConstants.RetainScrollPosition)

		UIMurlokExport.traits.HeroTalentsContainer.HeroSpecButton.Icon:SetAtlas(self.hero_atlas)
		TraitsFrame_SelectedTabOnClick()
	
		local equipmentsDataProvider = CreateDataProvider()
		local index = 1
		for slot, equip in core:IPairs(self.stats.equips, function (k1, k2) return k1 ~= nil and k2 ~= nil and k1[2].order < k2[2].order end) do
			equipmentsDataProvider:Insert({
				index = index,
				equipmentSlot = slot,
				slotId = GetInventorySlotInfo(SlotConfig[slot]),
				specId = self.specId,
				equipment = equip
			})
			index = index + 1
		end
		UIMurlokExport.EquipmentsScrollBox:SetDataProvider(equipmentsDataProvider, ScrollBoxConstants.RetainScrollPosition)
		UIMurlokExport.EquipmentsItemsFrame:Hide()
		UIMurlokExport.EquipmentsItemsFrame:Show()
	end
end

function TraitsFrame_SelectedTabOnClick()
	local tabId = 1
	if UIMurlokExport.TraitsInset.selectedTab and UIMurlokExport.TraitsInset.selectedTab > 0 then
		tabId = UIMurlokExport.TraitsInset.selectedTab
	end
	TraitsFrame_TabOnClick(_G[UIMurlokExport.TraitsInset:GetName().."TraitsTab"..tabId])
end

function TraitsFrame_TabOnClick(self)
	PanelTemplates_SetTab(self:GetParent(), self:GetID())

	if not UIMurlokExport.activeStats then
		return
	end

	UIMurlokExport.traits.HeroTalentsContainer:SetShown(self:GetID() == 3)
	UIMurlokExport.traits.PvPTraits:SetShown(self:GetID() == 4)
	UIMurlokExport.traits.ReloadButton:SetShown(false)

	if self:GetID() ~= 4 then
		local configId = Constants.TraitConsts.VIEW_TRAIT_CONFIG_ID
		UIMurlokExport.traits.tabId = self:GetID()
		UIMurlokExport.traits:SetConfigID(configId)
		UIMurlokExport.traits:SetTalentTreeID(C_ClassTalents.GetTraitTreeForSpec(UIMurlokExport.activeSpecId), true)
	else
		UIMurlokExport.traits:ReleaseAllTalentButtons()
		UIMurlokExport.traits.PvPTraits:Update()
	end
end

function TraitsFrame_SetTabs(frame, numTabs, ...)
	frame.numTabs = numTabs

	local frameName = frame:GetName()
	for i = 1, numTabs do
		local tab = CreateFrame("Button", frameName.."TraitsTab"..i, frame, "CharacterFrameTabTemplate")
		tab:SetID(i)
		tab:SetText(select(i, ...))
		tab:SetScript("OnClick", TraitsFrame_TabOnClick)
		if (i == 1) then
			tab:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 5, -12)
		else
			tab:SetPoint("TOPLEFT", _G[frameName.."TraitsTab"..(i - 1)], "TOPRIGHT", 5, 0)
		end
	end
end

PvPTraitsButtonMixin = {}
function PvPTraitsButtonMixin:Init(elementData)
	self.talentId = elementData.talentId
	self.talentInfo = C_SpecializationInfo.GetPvpTalentInfo(elementData.talentId)
	self.Name:SetText(self.talentInfo.name)
	self.SpendText:SetText(getRankColor(elementData.rank)..elementData.count.."|r")
	self.Icon:SetTexture(self.talentInfo.icon)
	self.SpendText:SetScale(0.7)

	if GameTooltip:GetOwner() == self then
		self:OnEnter()
	end
end

function PvPTraitsButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_LEFT")
	GameTooltip:SetPvpTalent(self.talentId, true)
	GameTooltip:Show()
end

PvPTraitsMixin = {}
function PvPTraitsMixin:OnLoad()
	local view = CreateScrollBoxListLinearView()
	view:SetElementInitializer("PvPTraitsButtonTemplate", function(button, elementData) button:Init(elementData) end)
	view:SetPadding(1,0,0,0,PVP_TALENT_LIST_BUTTON_OFFSET)

	self.ScrollBox:Init(view)
end

function PvPTraitsMixin:Update()
	local dataProvider = CreateDataProvider()
	local traits = UIMurlokExport.activeStats['traits']['pvp']
	for talentId, data in core:IPairs(traits, function (k1, k2) return k1[2].count > k2[2].count end) do
		dataProvider:Insert({talentId=talentId, count=data.count, rank=data.rank})
	end
	self.ScrollBox:SetDataProvider(dataProvider)
end

function PvPTraitsMixin:OnShow()
	self.ScrollBox:ScrollToBegin()
end

TraitsFrameMixin = CreateFromMixins(TalentFrameBaseMixin)
function TraitsFrameMixin:ShouldInstantiateNode(nodeId, nodeInfo)
	if nodeInfo.subTreeID then
		nodeInfo.subTreeActive = true
	end
	return nodeInfo.isVisible and self.requiredNodeIds[nodeId]
end

function TraitsFrameMixin:LoadTalentTreeInternal()
	local traitsCategories = {'class', 'spec', 'hero'}
	local traits = UIMurlokExport.activeStats['traits'][traitsCategories[self.tabId]]
	local specId = UIMurlokExport.activeSpecId

    C_ClassTalents.InitializeViewLoadout(specId, 10)
    C_ClassTalents.ViewLoadout({})

	local requiredNodeIds = {}
	local groupIds = {}
	-- warriror spec groupids to exclude
	local excludedGroupIds = {[9033]=true, [9034]=true}
	local function addIds(source, target)
		for _, id in ipairs(source) do
			if not excludedGroupIds[id] then
				if not target[id] then
					target[id] = 0
				end
				target[id] = target[id] + 1
			end
		end
	end
	for k, nodeId in ipairs(C_Traits.GetTreeNodes(self:GetTalentTreeID())) do		
		local nodeInfo = C_Traits.GetNodeInfo(self:GetConfigID(), nodeId)
		for i, entryId in core:IPairs(nodeInfo.entryIDs) do
			local entryInfo = C_Traits.GetEntryInfo(self:GetConfigID(), entryId)
			if traits[entryInfo.definitionID] ~= nil then
				requiredNodeIds[nodeId] = nodeInfo
				if i == 1 then
					addIds(nodeInfo.groupIDs, groupIds)
				end
			end
		end
	end

	-- for k, v in core:IPairs(groupIds, function(k1, k2) return k1[2] > k2[2] or k1[2] == k2[2] and k1[1] > k2[1] end) do
	-- 	print(k,v)
	-- end
	-- print("---")
	local maxGroupId = core:IPairs(groupIds, function(k1, k2) return k1[2] > k2[2] or k1[2] == k2[2] and k1[1] > k2[1] end)()
	for _, nodeId in ipairs(C_Traits.GetTreeNodes(self:GetTalentTreeID())) do
		if requiredNodeIds[nodeId] == nil then
			local nodeInfo = C_Traits.GetNodeInfo(self:GetConfigID(), nodeId)
			if tContains(nodeInfo.groupIDs, maxGroupId) then
				requiredNodeIds[nodeId] = nodeInfo
			end
		end
	end

	if core:TableLength(requiredNodeIds) == 0 then
		self:ReleaseAllTalentButtons()
		self:ClearInfoCaches()
		self.ReloadButton:SetShown(true)
		self.HeroTalentsContainer:SetShown(false)
		return
	end

	for _, nodeInfo in pairs(requiredNodeIds) do
		for _, entryId in ipairs(nodeInfo.entryIDs) do
			local entryInfo = C_Traits.GetEntryInfo(self:GetConfigID(), entryId)
			if entryInfo and entryInfo.definitionID and traits[entryInfo.definitionID] == nil then
				traits[entryInfo.definitionID] = {["count"] = 0, ["rank"] = -1}
			end
		end
	end

	self.requiredNodeIds = requiredNodeIds
	TalentFrameBaseMixin.LoadTalentTreeInternal(self)

	local zoomFactor = 0.7
	self:SetZoomLevelInternal(zoomFactor)
	self:DisableZoomAndPan()
	self.gatePool:ReleaseAll()
	self.HeroTalentsContainer:SetScale(0.78)
	
	local minX = nil
	local maxY = nil
	local maxX = nil
	local minY = nil

	for _, button in pairs(self.nodeIDToButton) do
		local _, _, _, offsetX, offsetY = button:GetPointByName("CENTER")
		if minX == nil or math.abs(offsetX) < minX then minX = math.abs(offsetX) end
		if maxY == nil or math.abs(offsetY) > maxY then maxY = math.abs(offsetY) end
		if maxX == nil or math.abs(offsetX) > maxX then maxX = math.abs(offsetX) end
		if minY == nil or math.abs(offsetY) < minY then minY = math.abs(offsetY) end
		
		button:SetVisualState(TalentButtonUtil.BaseVisualState.Locked)

		button.SpendText:ClearAllPoints()
		button.SpendText:SetPoint("BOTTOMLEFT", button, "BOTTOMRIGHT", -15, -5)
		TalentButtonUtil.SetSpendText(button, nil)
		
		local firstSpendValue = nil
		local firstSpendRank = nil
		for i, entryId in ipairs(button.nodeInfo.entryIDs) do
			local entryInfo = C_Traits.GetEntryInfo(self:GetConfigID(), entryId)
			local trait = traits[entryInfo.definitionID]
			if entryInfo and entryInfo.definitionID and trait then
				if trait.count > 0 or #button.nodeInfo.entryIDs == 2 then			
					if i == 1 then
						firstSpendValue = trait.count
						firstSpendRank = getRankColor(trait.rank)
					end
					if #button.nodeInfo.entryIDs == 1 and (firstSpendValue or 0) > 0 then
						TalentButtonUtil.SetSpendText(button, firstSpendRank..firstSpendValue.."|r")
						button:SetVisualState(TalentButtonUtil.BaseVisualState.Normal)
					elseif #button.nodeInfo.entryIDs == 2 and i == 2 and ((firstSpendValue or 0) > 0 or (trait.count or 0) > 0) then
						TalentButtonUtil.SetSpendText(button, (firstSpendRank or getRankColor(-1))..(firstSpendValue or "0").."|r".."||"..getRankColor(trait.rank)..(trait.count or "0").."|r")
						button:SetVisualState(TalentButtonUtil.BaseVisualState.Normal)
					end
				end
			end
		end
	end
	
	if minX and maxX and minY and maxY then
		local dX = (self.ButtonsParent:GetWidth() - math.abs(maxX - minX))/2
		local dY = (self.ButtonsParent:GetHeight() - math.abs(maxY - minY))/2
		for _, button in pairs(self.nodeIDToButton) do
			button:AdjustPointsOffset(-minX + dX, minY - dY)
		end
	end
end

function TraitsFrameMixin:OnLoad()
	TalentFrameBaseMixin.OnLoad(self)
	TraitsFrame_SetTabs(UIMurlokExport.TraitsInset, 4, "Class Traits", "Spec Traits", "Hero Traits", "PvP Traits")
end

function TraitsFrameMixin:OnShow()
	TalentFrameBaseMixin.OnShow(self)
	TraitsFrame_SelectedTabOnClick()
end

function TraitsFrameMixin:OnHide()
	TalentFrameBaseMixin.OnHide(self)
end

function TraitsFrameMixin:OnEvent(event, ...)
	TalentFrameBaseMixin.OnEvent(self, event, ...)
end

function TraitsFrameMixin:ReleaseAllTalentButtons()
	TalentFrameBaseMixin.ReleaseAllTalentButtons(self)
end

TalentsTryOutMixin = {}
function TalentsTryOutMixin:OnClick(button)
	if button == "LeftButton" then
		PlayerSpellsFrame:Show()
		UIMurlokExport:Hide()
		PlayerSpellsFrame.TalentsFrame:ImportLoadout(self.talentBox.EditBox:GetText(), "MurlokExport_".. date("%Y-%m-%dT%H:%M"))
	end
end

local icon = LibStub("LibDBIcon-1.0")
local meLDB = LibStub("LibDataBroker-1.1"):NewDataObject("Murlok Export", {
	type = "data source",  
	text = "Murlok Export",  
	icon = core:Asset("murlok"),  
	OnClick = function() core:Toggle() end,
})
icon:Register("Murlok Export", meLDB)