local _, core = ...

function core:init(event, name)
	if (name ~= "MurlokExport") then return end

    SLASH_RELOADUI1 = "/rl"
    SlashCmdList.RELOADUI = ReloadUI

    SLASH_ME1 = "/murlokexport"
    SLASH_ME2 = "/me"
    SlashCmdList.ME = function(msg, editBox) core:Toggle() end
end

UIMurlokExport:RegisterEvent("ADDON_LOADED")
UIMurlokExport:SetScript("OnEvent", core.init)