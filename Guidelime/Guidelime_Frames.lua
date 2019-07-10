local addonName, addon = ...
local L = addon.L

function addon.addSliderOption(frame, optionsTable, option, min, max, step, text, tooltip, updateFunction)
    local slider = CreateFrame("Slider", addonName .. option, frame, "OptionsSliderTemplate")
	frame.options[option] = slider
    slider.editbox = CreateFrame("EditBox", nil, slider, "InputBoxTemplate")
    slider:SetMinMaxValues(min, max)
    slider:SetValueStep(step)
	slider:SetValue(optionsTable[option])
    slider.text = _G[addonName .. option .. "Text"]
    slider.text:SetText(text)
    slider.textLow = _G[addonName .. option .. "Low"]
    slider.textHigh = _G[addonName .. option .. "High"]
    slider.textLow:SetText(floor(min))
    slider.textHigh:SetText(floor(max))
    slider.textLow:SetTextColor(0.8,0.8,0.8)
    slider.textHigh:SetTextColor(0.8,0.8,0.8)
    slider:SetObeyStepOnDrag(true)
    slider.editbox:SetSize(45,30)
    slider.editbox:ClearAllPoints()
    slider.editbox:SetPoint("LEFT", slider, "RIGHT", 15, 0)
    slider.editbox:SetText(tostring(optionsTable[option]))
    slider.editbox:SetCursorPosition(0)
    slider.editbox:SetAutoFocus(false)
    slider:SetScript("OnValueChanged", function(self)
        slider.editbox:SetText(tostring(slider:GetValue()))
    	slider.editbox:SetCursorPosition(0)
		optionsTable[option] = slider:GetValue()
		if updateFunction ~= nil then updateFunction() end
    end)
    slider.editbox:SetScript("OnEnterPressed", function()
        local val = slider.editbox:GetText()
        if tonumber(val) then
            slider:SetValue(val)
            slider.editbox:ClearFocus()
			if mouseUpFunction ~= nil then mouseUpFunction() end
        end
    end)
	if tooltip ~= nil then
		slider.tooltip = tooltip
		slider:SetScript("OnEnter", function(self) if self.tooltip ~= nil and self.tooltip ~= "" then GameTooltip:SetOwner(self, "ANCHOR_RIGHT",0,-32);  GameTooltip:SetText(self.tooltip); GameTooltip:Show() end end)
		slider:SetScript("OnLeave", function(self) if self.tooltip ~= nil and self.tooltip ~= "" then GameTooltip:Hide() end end)
	end
    return slider
end

function addon.addCheckbox(frame, text, tooltip)
	local checkbox = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
	if text ~= nil then
		checkbox.text:SetText(text)
		checkbox.text:SetFontObject("GameFontNormal")
	end
	if tooltip ~= nil then
		checkbox.tooltip = tooltip
		checkbox:SetScript("OnEnter", function(self) if self.tooltip ~= nil and self.tooltip ~= "" then GameTooltip:SetOwner(self, "ANCHOR_RIGHT",0,-32);  GameTooltip:SetText(self.tooltip); GameTooltip:Show() end end)
		checkbox:SetScript("OnLeave", function(self) if self.tooltip ~= nil and self.tooltip ~= "" then GameTooltip:Hide() end end)
	end
	return checkbox
end

function addon.addCheckOption(frame, optionsTable, option, text, tooltip, updateFunction)
	local checkbox = addon.addCheckbox(frame, text, tooltip)
	frame.options[option] = checkbox
	if optionsTable[option] ~= false then checkbox:SetChecked(true) end
	checkbox:SetScript("OnClick", function()
		optionsTable[option] = checkbox:GetChecked() 
		if updateFunction ~= nil then updateFunction() end
	end)
	return checkbox
end

function addon.addMultilineText(frame, text, width, tooltip, clickFunc, doubleClickFunc)
	textbox = CreateFrame("EditBox", nil, frame)
	textbox:SetMultiLine(true)
	textbox:SetFontObject("GameFontNormal")
	if text ~= nil then textbox:SetText(text) end
	if tooltip ~= nil then
		textbox.tooltip = tooltip
		textbox:SetScript("OnEnter", function(self) if self.tooltip ~= nil and self.tooltip ~= "" then GameTooltip:SetOwner(self, "ANCHOR_RIGHT",0,-32);  GameTooltip:SetText(self.tooltip); GameTooltip:Show() end end)
		textbox:SetScript("OnLeave", function(self) if self.tooltip ~= nil and self.tooltip ~= "" then GameTooltip:Hide() end end)
	end
	if clickFunc ~= nil or doubleClickFunc ~= nil then
		textbox:SetScript("OnMouseUp", function(self, button)
			if clickFunc ~= nil then clickFunc(self, button) end
			-- Double-Click?				
			if doubleClickFunc ~= nil then
			    if self.timer ~= nil and self.timer < time() then
			        self.timer = nil
			    elseif self.timer ~= nil and self.timer == time() then
			        self.timer = nil
					doubleClickFunc(self, button)
			    else
			        self.timer = time()
			    end
			end
		end)
	end
	textbox:SetScript("OnEditFocusGained", function (self) self:ClearFocus() end)
	textbox:SetAutoFocus(false)
	textbox:SetWidth(width)

	return textbox
end

function addon.addTextbox(frame, text, width, tooltip)
	local textbox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
	textbox.text = frame:CreateFontString(nil, frame, "GameFontNormal")
	textbox.text:SetText(text)
	textbox:SetFontObject("GameFontNormal")
	textbox:SetHeight(10)
	textbox:SetWidth(width)
	textbox:SetTextColor(255,255,255,255)
	if tooltip ~= nil then
		textbox.tooltip = tooltip
		textbox:SetScript("OnEnter", function(self) if self.tooltip ~= nil and self.tooltip ~= "" then GameTooltip:SetOwner(self, "ANCHOR_RIGHT",0,-32);  GameTooltip:SetText(self.tooltip); GameTooltip:Show() end end)
		textbox:SetScript("OnLeave", function(self) if self.tooltip ~= nil and self.tooltip ~= "" then GameTooltip:Hide() end end)
	end
	return textbox
end
function addon.createPopupFrame(message, okFunc, hasCancel, height)

	local popupFrame = CreateFrame("FRAME", nil, UIParent)
	popupFrame:SetWidth(550)
	if height == nil then height = 100 end
	popupFrame:SetHeight(height)
	popupFrame:SetPoint("CENTER", UIParent, "CENTER")
	popupFrame:SetBackdrop({
		bgFile = "Interface/Addons/Guidelime/Icons/Black", --"Interface/DialogFrame/UI-DialogBox-Background",
		edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
		tile = true, tileSize = 32, edgeSize = 32,
		insets = { left = 11, right = 12, top = 12, bottom = 11}
	})
	popupFrame:SetBackdropColor(0,0,0,1)
	popupFrame:SetFrameLevel(999)
	popupFrame:SetFrameStrata("DIALOG")
	popupFrame:SetMovable(true)
	popupFrame:SetScript("OnKeyDown", function(self,key) 
		if key == "ESCAPE" then
			self:Hide(); 
		end 
	end)
	  
	popupFrame:EnableMouse(true)
	popupFrame:SetScript("OnMouseDown", function(this) this:StartMoving() end)
	popupFrame:SetScript("OnMouseUp", function(this) this:StopMovingOrSizing() end)
	
	if message ~= nil then
		popupFrame.message = popupFrame:CreateFontString(nil, popupFrame, "GameFontNormal")
		popupFrame.message:SetText(message);
		popupFrame.message:SetPoint("TOPLEFT", 20, -30 )
	end

	popupFrame.okBtn = CreateFrame("BUTTON", nil, popupFrame, "UIPanelButtonTemplate")
	popupFrame.okBtn:SetWidth(128)
	popupFrame.okBtn:SetHeight(24)
	popupFrame.okBtn:SetText( OKAY )
	if hasCancel then
		popupFrame.okBtn:SetPoint("BOTTOM", popupFrame, -70, 12)
	else
		popupFrame.okBtn:SetPoint("BOTTOM", popupFrame, 70, 12)
	end
	popupFrame.okBtn:SetScript("OnClick", function(self) 
		if okFunc ~= nil then okFunc(self:GetParent()) end
		self:GetParent():Hide()
	end)

	if hasCancel then
		popupFrame.cancelBtn = CreateFrame("BUTTON", nil, popupFrame, "UIPanelButtonTemplate")
		popupFrame.cancelBtn:SetWidth(128)
		popupFrame.cancelBtn:SetHeight(24)
		popupFrame.cancelBtn:SetText( CANCEL )
		popupFrame.cancelBtn:SetPoint("BOTTOM", popupFrame, 70, 12)
		popupFrame.cancelBtn:SetScript("OnClick", function(self) 
			self:GetParent():Hide()
		end)
	end

	return popupFrame
end