local _, core = ...

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

local function GetPlayerClassSpec()
    local specId = GetSpecializationInfo(GetSpecialization())
	local _, classId = UnitClassBase("player")
    return classId, specId
end

ClassListFrameMixin = {}
function ClassListFrameMixin:OnLoad()
	self:SetTabs(self.ClassInset, 2, "Mythic+", "Solo PvP")

	local classView = CreateScrollBoxListLinearView()
	classView:SetElementInitializer("ClassListButtonTemplate", function(button, elementData) self:InitClassButton(button, elementData) end)
	classView:SetPadding(0,0,84,0,0)
	ScrollUtil.InitScrollBoxListWithScrollBar(self.ClassScrollBox, self.ClassScrollBar, classView)
	self.ClassSelectionBehavior = ScrollUtil.AddSelectionBehavior(self.ClassScrollBox, SelectionBehaviorFlags.Intrusive)
	self.ClassSelectionBehavior:RegisterCallback(SelectionBehaviorMixin.Event.OnSelectionChanged, self.OnSelectionChanged)
end

function ClassListFrameMixin:OnShow()
	self:SelectedTabOnClick()

	local classId, specId = GetPlayerClassSpec()
	if self.activeClassId == nil and self.activeSpecId == nil and self.activeHero == nil then
		local button = self.ClassScrollBox:FindFrameByPredicate(function(frame, edata) return edata.classId == classId and edata.specId == specId end)
		if button then
			button:OnClick("LeftButton")
		end
	end
end

function ClassListFrameMixin:UpdateClassList(content)
	local newDataProvider = CreateDataProvider()
	local index = 0
	local classId = GetPlayerClassSpec()
	for class, config in core:Pairs(MurlokExport[content]) do
		if ClassConfig[class].class.id == classId then
			index = self:InsertSpec(index, newDataProvider, class, config)
		end
	end
	for class, config in core:Pairs(MurlokExport[content]) do
		if ClassConfig[class].class.id ~= classId then
			index = self:InsertSpec(index, newDataProvider, class, config)
		end
	end
	self.ClassScrollBox:SetDataProvider(newDataProvider, ScrollBoxConstants.RetainScrollPosition)
end

function ClassListFrameMixin:InsertSpec(index, newDataProvider, class, config)
	for spec, heros in core:Pairs(config) do
        local specId = ClassConfig[class].specs[spec].id
        C_ClassTalents.InitializeViewLoadout(specId, core.MAX_LEVEL)
        C_ClassTalents.ViewLoadout({})
		local _, specName, _, specIcon, _, _, className  = GetSpecializationInfoByID(specId)
		for _, stats in core:Pairs(heros) do
			index = index + 1
			local subTreeInfo = C_Traits.GetSubTreeInfo(Constants.TraitConsts.VIEW_TRAIT_CONFIG_ID, stats["id"])
			newDataProvider:Insert({
				classIndex = index,
				classId = ClassConfig[class].class.id,
				classIcon = ClassConfig[class].class.icon,
				specId = specId,
				specIcon = specIcon,
				className = className,
				specName = specName,
				heroId = stats["id"],
				hero = subTreeInfo.name,
				hero_atlas = subTreeInfo.iconElementID,
				count = stats["count"],
				stats = stats
			})
		end
	end
	return index
end

function ClassListFrameMixin:InitClassButton(button, elementData)
	button.classIcon:SetTexture(elementData.classIcon)
	button.specIcon:SetTexture(elementData.specIcon)
	button.className:SetText(elementData.className)
	button.specName:SetText(elementData.specName)
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

function ClassListFrameMixin:OnSelectionChanged(elementData, selected)
    local button = UIMurlokExport.ClassListFrame.ClassScrollBox:FindFrameByPredicate(function(frame, edata) return edata.classId == elementData.classId and edata.specId == elementData.specId and edata.hero == elementData.hero end)
	if button then
		button.hilightFrame.ActiveTexture:SetShown(selected)
		button.selectedTexture:SetShown(selected)
	end
end

function ClassListFrameMixin:SelectedTabOnClick()
	local tabId = 1
	if self.ClassInset.selectedTab and self.ClassInset.selectedTab > 0 then
		tabId = self.ClassInset.selectedTab
	end
	self:TabOnClick(_G[self.ClassInset:GetName() .. "ContentTab" .. tabId])
end

function ClassListFrameMixin:TabOnClick(tab)
	PanelTemplates_SetTab(self.ClassInset, tab:GetID())
	local tabToContent = {'mm+', 'solo'}
	self:UpdateClassList(tabToContent[tab:GetID()])
	if self.activeClassId and self.activeSpecId and self.activeHero then
		local function predicate(edata) return edata.classId == self.activeClassId and edata.specId == self.activeSpecId and edata.hero == self.activeHero end
    	local button = self.ClassScrollBox:FindFrameByPredicate(function(frame, edata) return predicate(edata) end)
		if button then
			-- self.ClassScrollBox:ScrollToElementDataByPredicate(function(edata) return predicate(edata) end, button.elementData, ScrollBoxConstants.AlignNearest, true)
			button:OnClick("LeftButton")
		end
	end
end

function ClassListFrameMixin:SetTabs(frame, numTabs, ...)
	frame.numTabs = numTabs

	local frameName = frame:GetName()
	for i = 1, numTabs do
		local tab = CreateFrame("Button", frameName .. "ContentTab" .. i, frame, "CharacterFrameTabTemplate")
		tab:SetID(i)
		tab:SetText(select(i, ...))
		tab:SetScript("OnClick", function() self:TabOnClick(tab) end)
		if (i == 1) then
			tab:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 5, -12)
		else
			tab:SetPoint("TOPLEFT", _G[frameName .. "ContentTab" .. (i - 1)], "TOPRIGHT", 5, 0)
		end
	end
end

ClassListItemMixin = {}
function ClassListItemMixin:OnUpdate()
    local frame = UIMurlokExport.ClassListFrame
	local active = self.classId and self.specId and self.hero and frame.activeSpecId == self.specId and frame.activeClassId == self.classId and frame.activeHero == self.hero
	self.hilightFrame.ActiveTexture:SetShown(active)
	self.selectedTexture:SetShown(active)
end

function ClassListItemMixin:OnClick(button)
	if button == "LeftButton" then
        local frame = UIMurlokExport.ClassListFrame
		frame.activeClassId = self.classId
		frame.activeSpecId = self.specId
		frame.activeHero = self.hero
		frame.activeStats = self.stats
		frame.ClassSelectionBehavior:Select(self)

        UIMurlokExport.StatsFrame:OnClick(self.stats)
        UIMurlokExport.TalentsListFrame:OnClick(self.stats.talents, self.hero_atlas)
        UIMurlokExport.TraitsTreeFrame:OnClick(self.hero_atlas)
        UIMurlokExport.EquipmentsListFrame:OnClick(self.stats, self.specId)
	end
end
