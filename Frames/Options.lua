local _, core = ...

OptionsPanelTemplateMixin = {}
function OptionsPanelTemplateMixin:Open()
    Settings.OpenToCategory(MURLOKEXPORT_TITLE, true);
end

function OptionsPanelTemplateMixin:Register()
    local category = Settings.RegisterCanvasLayoutCategory(self, MURLOKEXPORT_TITLE);
    category.ID = MURLOKEXPORT_TITLE
    Settings.RegisterAddOnCategory(category)
end

function OptionsPanelTemplateMixin:OnLoad()
    self.Title:SetText(MURLOKEXPORT_TITLE);
    self.SubText:SetText(MURLOKEXPORT_OPTIONS_SUBTEXT);
end

function OptionsPanelTemplateMixin:CompactViewCheckButtonOnShow()
    if UIMurlokExport.OptionsPanel ~= nil then
        local checkBox = UIMurlokExport.OptionsPanel.CompactViewCheckButton
        checkBox.Text:SetText(MURLOKEXPORT_OPTIONS_COMPACT_VIEW)
        checkBox:SetChecked(MurlokExportConfig.CompactView)
    end
end

function OptionsPanelTemplateMixin:CompactViewCheckButtonOnClick()
    MurlokExportConfig.CompactView = UIMurlokExport.OptionsPanel.CompactViewCheckButton:GetChecked()
end

function OptionsPanelTemplateMixin:ShowOnlyCurrentClassCheckButtonOnShow()
    if UIMurlokExport.OptionsPanel ~= nil then
        local checkBox = UIMurlokExport.OptionsPanel.ShowOnlyCurrentClassCheckButton
        checkBox.Text:SetText(MURLOKEXPORT_OPTIONS_SHOW_ONLY_CURRENT_CLASS)
        checkBox:SetChecked(MurlokExportConfig.ShowOnlyCurrentClass)
    end
end

function OptionsPanelTemplateMixin:ShowOnlyCurrentClassCheckButtonOnClick()
    MurlokExportConfig.ShowOnlyCurrentClass = UIMurlokExport.OptionsPanel.ShowOnlyCurrentClassCheckButton:GetChecked()
end
