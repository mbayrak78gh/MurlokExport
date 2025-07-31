local _, core = ...

TalentsListFrameMixin = {}
function TalentsListFrameMixin:OnLoad()
	local talentsView = CreateScrollBoxListLinearView()
	talentsView:SetElementInitializer("TalentsListTemplate", function(frame, elementData) self:InitTalentFrame(frame, elementData) end)
	talentsView:SetPadding(25,10,10,10,0)
	ScrollUtil.InitScrollBoxListWithScrollBar(self.TalentsScrollBox, self.TalentsScrollBar, talentsView)
end

function TalentsListFrameMixin:InitTalentFrame(frame, elementData)
	frame.talentBox.EditBox:SetAutoFocus(false)
	frame.talentBox.CharCount:Hide()
	frame.talentBox.EditBox:SetText(elementData.talentString)

	frame.talentIndex:SetText(core:getRankColor(elementData.index - 1)..elementData.index..".|r")
	frame.tryOutTalentButton.tryOutTalentTexture:SetAtlas(elementData.hero_atlas, true)
	frame.tryOutTalentButton.talentBox = frame.talentBox
end

function TalentsListFrameMixin:OnClick(talents, hero_atlas)
    local talentsDataProvider = CreateDataProvider()
    for index, talentString in ipairs(talents) do
        talentsDataProvider:Insert({
            index = index,
            talentString = talentString,
            hero_atlas = hero_atlas
        })
    end
    self.TalentsScrollBox:SetDataProvider(talentsDataProvider, ScrollBoxConstants.RetainScrollPosition)
end

TalentsTryOutMixin = {}
function TalentsTryOutMixin:OnClick(button)
	if button == "LeftButton" then
		PlayerSpellsFrame:Show()
		PlayerSpellsFrame:SetTab(PlayerSpellsFrame.talentTabID)
		UIMurlokExport:Hide()

		local mode = ""
		if UIMurlokExport.ClassListFrame.ClassInset.selectedTab == 1 then
			mode = "mythic_plus_"
		elseif UIMurlokExport.ClassListFrame.ClassInset.selectedTab == 2 then
			mode = "solo_pvp_"
		end
		PlayerSpellsFrame.TalentsFrame:ImportLoadout(self.talentBox.EditBox:GetText(), "ME_" .. mode .. date("%Y-%m-%dT%H:%M"))
	end
end