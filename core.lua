local _, core = ...

core.MAX_LEVEL = 100

function core:Toggle()
	UIMurlokExport:SetShown(not UIMurlokExport:IsShown())
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

function core:Asset(path)
	local assetRootPath = "Interface\\AddOns\\MurlokExport\\assets\\"
	return assetRootPath .. path
end

function core:getRankColor(rank)
	if rank == 0 then return ITEM_LEGENDARY_COLOR:GenerateHexColorMarkup() elseif rank >= 1 and rank < 5 then return EPIC_PURPLE_COLOR:GenerateHexColorMarkup() else return WHITE_FONT_COLOR:GenerateHexColorMarkup() end
end

UIMurlokExportMixin = CreateFromMixins(PortraitFrameMixin)
function UIMurlokExportMixin:OnLoad()
	tinsert(UISpecialFrames, self:GetName())
	self:SetTitle("Murlok Export")
	self.PortraitContainer.portrait:SetTexture(core:Asset("MurlokExport"))
	self.DataExportTime:SetText('Data export time: ' .. MurlokExport["timestamp"])
	self:RegisterForDrag("LeftButton")
	self.ClassListFrame:OnLoad()
	self.TalentsListFrame:OnLoad()
	self.TraitsTreeFrame:OnLoad()
	self.EquipmentsListFrame:OnLoad()
end

function UIMurlokExportMixin:OnShow()
	C_AddOns.LoadAddOn("Blizzard_PlayerSpells")

	self.ClassListFrame:OnShow()

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