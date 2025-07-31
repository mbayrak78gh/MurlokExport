local _, core = ...

TraitsTreeFrameMixin = {}
function TraitsTreeFrameMixin:OnLoad()
	self:SetTabs(self.TraitsInset, 4, MURLOKEXPORT_TRAITS_CLASS, MURLOKEXPORT_TRAITS_SPECIALIZATION, MURLOKEXPORT_TRAITS_HERO, MURLOKEXPORT_TRAITS_PVP)
end

function TraitsTreeFrameMixin:OnShow()
	self:SelectedTabOnClick()
end

function TraitsTreeFrameMixin:OnClick(hero_atlas)
	self.traits.HeroTalentsContainer.HeroSpecButton.Icon:SetAtlas(hero_atlas)
	self:SelectedTabOnClick()
end

function TraitsTreeFrameMixin:SelectedTabOnClick()
	local tabId = 1
	if self.TraitsInset.selectedTab and self.TraitsInset.selectedTab > 0 then
		tabId = self.TraitsInset.selectedTab
	end
	self:TabOnClick(_G[self.TraitsInset:GetName().."TraitsTab"..tabId])
end

function TraitsTreeFrameMixin:TabOnClick(tab)
	-- if self.traits.tabId == tab:GetID() then
	-- 	return
	-- end

	self.traits.tabId = tab:GetID()
	PanelTemplates_SetTab(self.TraitsInset, tab:GetID())

	if not UIMurlokExport.ClassListFrame.activeSpecId or not UIMurlokExport.ClassListFrame.activeStats then
		return
	end

	self.traits.HeroTalentsContainer:SetShown(tab:GetID() == 3)
	self.traits.PvPTraits:SetShown(tab:GetID() == 4)
	self.traits.ReloadButton:SetShown(false)

	if tab:GetID() ~= 4 then
		local configId = Constants.TraitConsts.VIEW_TRAIT_CONFIG_ID
		self.traits:SetConfigID(configId)
		self.traits:SetTalentTreeID(C_ClassTalents.GetTraitTreeForSpec(UIMurlokExport.ClassListFrame.activeSpecId), true)
	else
		self.traits:ReleaseAllTalentButtons()
		self.traits.PvPTraits:Update()
	end
end

function TraitsTreeFrameMixin:SetTabs(frame, numTabs, ...)
	frame.numTabs = numTabs

	local frameName = frame:GetName()
	for i = 1, numTabs do
		local tab = CreateFrame("Button", frameName .. "TraitsTab" .. i, frame, "PanelTopTabButtonTemplate")
		tab:SetID(i)
		tab:SetText(select(i, ...))
		tab:SetScript("OnClick", function() self:TabOnClick(tab) end)
		if (i == 1) then
			tab:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 5, 36)
		else
			tab:SetPoint("TOPLEFT", _G[frameName .. "TraitsTab" .. (i - 1)], "TOPRIGHT", 5, 0)
		end
	end
end

PvPTraitsButtonMixin = {}
function PvPTraitsButtonMixin:Init(elementData)
	self.talentId = elementData.talentId
	self.talentInfo = C_SpecializationInfo.GetPvpTalentInfo(elementData.talentId)
	self.Name:SetText(self.talentInfo.name)
	self.SpendText:SetText(core:getRankColor(elementData.rank) .. elementData.count .. "|r")
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
	view:SetPadding(1, 0, 0, 0, PVP_TALENT_LIST_BUTTON_OFFSET)

	self.ScrollBox:Init(view)
end

function PvPTraitsMixin:Update()
	local dataProvider = CreateDataProvider()
	local traits = UIMurlokExport.ClassListFrame.activeStats['traits']['pvp']
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
	local traits = UIMurlokExport.ClassListFrame.activeStats['traits'][traitsCategories[self.tabId]]
	local specId = UIMurlokExport.ClassListFrame.activeSpecId

    C_ClassTalents.InitializeViewLoadout(specId, core.MAX_LEVEL)
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
						firstSpendRank = core:getRankColor(trait.rank)
					end
					if #button.nodeInfo.entryIDs == 1 and (firstSpendValue or 0) > 0 then
						TalentButtonUtil.SetSpendText(button, firstSpendRank..firstSpendValue.."|r")
						button:SetVisualState(TalentButtonUtil.BaseVisualState.Normal)
					elseif #button.nodeInfo.entryIDs == 2 and i == 2 and ((firstSpendValue or 0) > 0 or (trait.count or 0) > 0) then
						TalentButtonUtil.SetSpendText(button, (firstSpendRank or core:getRankColor(-1)) .. (firstSpendValue or "0") .. "|r" .. "||" .. core:getRankColor(trait.rank) .. (trait.count or "0") .. "|r")
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

function TraitsFrameMixin:IsInspecting()
	return true
end

function TraitsFrameMixin:OnLoad()
	TalentFrameBaseMixin.OnLoad(self)
end

function TraitsFrameMixin:OnShow()
	TalentFrameBaseMixin.OnShow(self)
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
