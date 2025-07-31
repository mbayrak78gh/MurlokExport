local _, core = ...

local defaults = {
    CompactView = false,
    ShowOnlyCurrentClass = false
}

function core:init(event, name)
	if (name ~= MURLOKEXPORT_TITLE) then return end

    SLASH_RELOADUI1 = "/rl"
    SlashCmdList.RELOADUI = ReloadUI

    SLASH_ME1 = "/murlokexport"
    SLASH_ME2 = "/me"
    SlashCmdList.ME = function(msg, editBox) core:Toggle() end

    if UIMurlokExport.OptionsPanel == nil then
        local optionsPanel = CreateFrame("Frame", nil, nil, "OptionsPanelTemplate")
        optionsPanel:Register()
        UIMurlokExport.OptionsPanel = optionsPanel
    end

    MurlokExportConfig = MurlokExportConfig or CopyTable(defaults)
end

UIMurlokExport:RegisterEvent("ADDON_LOADED")
UIMurlokExport:SetScript("OnEvent", core.init)