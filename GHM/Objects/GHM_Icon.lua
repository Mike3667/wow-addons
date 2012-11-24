--===================================================
--
--				GHM_Icon
--  			GHM_Icon.lua
--
--	          (description)
--
-- 	  (c)2011 The Gryphonheart Team
--			All rights reserved
--===================================================
 --[[local loc;
local frame  = CreateFrame("Frame");
frame:RegisterEvent("VARIABLES_LOADED");
frame:SetScript("OnEvent",function()
     loc = GHI_Loc();
end)
]]--

local count = 1;

function GHM_Icon(parent, main, profile)
     local loc = GHI_Loc();
	local frame = CreateFrame("Frame", "GHM_Icon" .. count, parent, "GHM_Icon_Template");
	local button = _G[frame:GetName().."Button"];
	count = count + 1;

	profile = profile or {};
	button.main = main;
	if profile.framealign then
		button.framealign = profile.framealign;
	else
		button.framealign = "c";
	end



	local label = _G[frame:GetName() .. "TextLabel"];
	if type(profile.text) == "string" then
		label:SetText(profile.text);
	else
		label:SetText(loc.ICON_TEXT)
	end

	frame:SetWidth(37);
	frame:SetHeight(37);
	--height = height + label:GetHeight() * 1.8;
	--offsetY = -10;
	--[[
	if profile.framealign then
		obj.framealign = profile.framealign;
	else
		obj.framealign = "c";
	end  --]]
	frame.OnChanged = profile.OnChanged;

	-- positioning
	local extraX = profile.xOff or 0;
	local extraY = profile.yOff or 0;

	if profile.align == "c" then
		frame:SetPoint("CENTER", parent, "CENTER", extraX, extraY);
	elseif profile.align == "r" then
		frame:SetPoint("RIGHT", parent.lastRight or parent, "RIGHT", extraX, extraY);
		parent.lastRight = frame;
	else
		if parent.lastLeft then frame:SetPoint("LEFT", parent.lastLeft, "RIGHT", extraX, extraY); else frame:SetPoint("LEFT", parent, "LEFT", extraX, extraY); end
		parent.lastLeft = frame;
	end

	-- functions
	local varAttFrame;
	local iconPath = "Interface\\Icons\\INV_Misc_QuestionMark";
	SetItemButtonTexture(button, iconPath);
	button.IconChoosen = function(orig,icon)

		SetItemButtonTexture(button,icon.path);
		iconPath = icon.path;
		if frame.CloseOnChoosen == true then
			icon:GetParent():Hide();
		end
		if frame.OnChanged then
			frame.OnChanged(icon.path);
		end
	end

	local Force1 = function(data)
		if type(data) == "string" or type(data) == "number" then
			iconPath = data;
			SetItemButtonTexture(button,iconPath);
		end
	end

	local Force2 = function(inputType, inputValue)
		if (inputType == "attribute" or inputType == "variable") and varAttFrame then
			--editBox:SetText("");
			varAttFrame:SetValue(inputType, inputValue);

		else -- static
			varAttFrame:Clear();
			iconPath = inputValue;
			SetItemButtonTexture(button,iconPath);
		end
	end

	frame.Force = function(self, ...)
		if self ~= frame then return frame.Force(frame, self, ...); end
		local numInput = #({ ... });

		if numInput == 1 then
			Force1(...);
		elseif numInput == 2 then
			Force2(...);
		end
	end

	frame.Clear = function(self)
		local iconPath = "Interface\\Icons\\INV_Misc_QuestionMark";
		SetItemButtonTexture(button, iconPath);
	end


	frame.EnableVariableAttributeInput = function(self, scriptingEnv, item)
		frame:SetWidth(120);
		frame:SetHeight(37);
		if not (varAttFrame) then
			varAttFrame = GHM_VarAttInput(frame, button, frame:GetWidth());
			frame:SetHeight(frame:GetHeight());
		end
		varAttFrame:EnableVariableAttributeInput(scriptingEnv, item, profile.outputOnly)
	end

	frame.GetValue = function(self)
		if (varAttFrame and not (varAttFrame:IsStaticTabShown())) then
			return varAttFrame:GetValue();
		else
			return iconPath;
		end
     end

     --frame.UpdateTheme = function()
     -- Update the theme using the theme functions
     -- Example:
     -- local color = GHM_GetDetailsTextColor();
     --  someLabel:SetTextColor(color.r,color.g,color.b);
          --local background = GHM_GetBackground();
	     --local titleBarColor = GHM_GetTitleBarColor();
	     --local titleBarTextColor = GHM_GetTitleBarTextColor();
		--local backgroundColor = GHM_SetBackgroundColor();
		--local buttonColor = GHM_GetButtonColor();
		--local mainTextColor = GHM_GetHeadTextColor();
		--local detailsTextColor = GHM_GetDetailsTextColor();

         -- button:SetVertexColor(GHM_GetButtonColor())
          --frame:SetTexture(background);
          --local label = _G[frame:GetName() .. "TextLabel"];
          --label:SetTextColor(mainTextColor.r,mainTextColor.g,mainTextColor.b)

    -- end

    -- GHM_AddThemedObject(frame)



	if type(profile.OnLoad) == "function" then
		profile.OnLoad(frame);
	end
	frame:Show();

	return frame;
end

local count = 1;
function GHM_IconSelectionMenu()

	local inUse;
	local loc = GHI_Loc();

	local menuFrame;
	local selected;
	local OnOkCallback;
	menuFrame = GHM_NewFrame(class, {
		onOk = function(self) end,
		{
			{
				{
					type = "Dummy",
					height = 380,
					width = 10,
					align = "c",
					label = "anchor",
				},
			},
			{
				{
					type = "Button",
					text = OKAY,
					align = "l",
					label = "ok",
					compact = false,
					OnClick = function()
						if OnOkCallback then
							OnOkCallback(selected);
						end
						menuFrame:Hide();
					end,
				},
				{
					type = "Button",
					text = CANCEL,
					align = "r",
					label = "cancel",
					compact = false,
					OnClick = function(obj)
						menuFrame:Hide();
					end,
				},
			},
		},
		title = loc.SELECT_ICON,
		name = "GHM_IconSelectionMenu"..count,
		theme = "BlankTheme",
		width = 180,
		useWindow = true,
		OnShow = function(self)		end,
		icon = "INTERFACE\\ICONS\\priest_icon_chakra_blue",
		lineSpacing = 20,
		OnHide = function()
			if not (menuFrame.window:IsShown()) then
				inUse = false;
			end
		end,
	});
	count = count + 1;
	local anchor = menuFrame:GetLabelFrame("anchor");

   	local iconFrame = CreateFrame("Frame",menuFrame:GetName().."Icons",menuFrame,"GHM_IconFrame_Template");
	iconFrame:SetParent(menuFrame);
	iconFrame:SetPoint("CENTER", menuFrame, "CENTER", 10, 0)
	iconFrame:Show();
	iconFrame:SetBackdrop(nil);
	_G[iconFrame:GetName().."Plate"]:Hide();
	_G[iconFrame:GetName().."Close"]:Hide();
	iconFrame.from = {};


	iconFrame.from.IconChoosen = function(_,icon)
		selected = icon.path;
	end

	menuFrame.New = function(_OnOkCallback)
		OnOkCallback = _OnOkCallback;
		menuFrame:Show();
		inUse = true;
	end

	menuFrame.IsInUse = function()
		 return inUse;
	end

	menuFrame:Hide();
	return menuFrame;
end

