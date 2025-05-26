local _, core = ...

function core:Print(...)
    local hex = select(4, self:GetThemeColor())
    local prefix = string.format("|cff%s%s|r %s", hex:upper(), "Murlok", "Export:")
    DEFAULT_CHAT_FRAME:AddMessage(string.join(" ", prefix, ...))
end

function core:init(event, name)
	if (name ~= "MurlokExport") then return end

	-- allows using left and right buttons to move through chat 'edit' box
	-- for i = 1, NUM_CHAT_WINDOWS do
	-- 	_G["ChatFrame"..i.."EditBox"]:SetAltArrowKeyMode(false)
	-- end

    -- SLASH_RELOADUI1 = "/rl"
    -- SlashCmdList.RELOADUI = ReloadUI

    SLASH_ME1 = "/murlokexport"
    SLASH_ME2 = "/me"
    SlashCmdList.ME = function(msg, editBox)
        core:Toggle()
    end

    -- SLASH_FRAMESTK1 = "/fs"
    -- SlashCmdList.FRAMESTK = function ()
    --     C_AddOns.LoadAddOn('Blizzard_DebugTools')
    --     FrameStackTooltip_Toggle()
    -- end

    -- core:Print("Welcome back", UnitName("player") .. "!")
end

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:SetScript("OnEvent", core.init)