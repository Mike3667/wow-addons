--===================================================
--								Standard Item Menu
--							GHI_StandardItemMenu.lua.lua
--
--		Application Interface for scripts to execute functions relevant for actions
--		Handles relevant security checks on the API calls.
--
-- 						(c)2012 The Gryphonheart Team
--								All rights reserved
--===================================================

local UnitName = UnitName;
local UnitGUID = UnitGUID;
  local loc = GHI_Loc()
local simpleActions = {
	{ "expression", "GHI_ExpressionMenu", loc.EXPRESSION },
	{ "random_expression", "GHI_RandomExpressionMenu", loc.RANDOM_EXPRESSION },
	{ "message", "GHI_MessageMenu", loc.MESSAGE_TEXT_U },
	{ "bag", "GHI_BagMenu", loc.BAG },
	{ "sound", "GHI_SoundMenu", loc.SOUND },
	{ "book", "GHI_BookMenu", loc.BOOK },
	{ "buff", "GHI_BuffMenu", loc.BUFF },
	{ "remove_buff", "GHI_RemoveBuffMenu", loc.REMOVE_BUFF },
	{ "equip_item", "GHI_EquipItemMenu", loc.EQUIP_ITEM },
	{ "produce_item", "GHI_ProduceItemMenu", loc.PRODUCE_ITEM },
	{ "consume_item", "GHI_ConsumeItemMenu", loc.CONSUME },
	{ "screen_effect", "GHI_ScreenEffectMenu", loc.SCREEN_EFFECT },
	{ "script", "GHI_ScriptMenu", loc.SCRIPT },
};

function GHI_StandardItemMenu()
	local class = GHClass("GHI_StandardItemMenu");

	local menuFrame, itemTooltip, item, edit, UpdateTooltip;
	local itemList = GHI_ItemInfoList();
	local containerList = GHI_ContainerList();
	local guidCreator = GHI_GUID();
	local miscApi = GHI_MiscAPI().GetAPI();
	local inUse = false;
	local actionDD, actionList, UpdateActionList;
	local actionsChanged;
	local advItemMenuList = GHI_AdvancedItemMenuList();

	local menuIndex = 1;
	while _G["GHI_Standard_Item_Menu" .. menuIndex] do menuIndex = menuIndex + 1; end

	local UpdateMenu = function()
		local name, icon, quality, stackSize = item.GetItemInfo();
		local white1, white2, comment, useText = item.GetFlavorText();
		menuFrame.ForceLabel("name", name);
		menuFrame.ForceLabel("white1", white1);
		menuFrame.ForceLabel("white2", white2);
		menuFrame.ForceLabel("comment", comment);
		menuFrame.ForceLabel("quality", quality);
		menuFrame.ForceLabel("icon", icon);
		menuFrame.ForceLabel("stackSize", stackSize);
		menuFrame.ForceLabel("copyable", item.IsCopyable());
		menuFrame.ForceLabel("editable", item.IsEditable());
		menuFrame.ForceLabel("useText", useText);
		menuFrame.ForceLabel("consumed", item.IsConsumed());
		menuFrame.ForceLabel("cooldown", item.GetCooldown());
		actionList.Clear();
		UpdateActionList();
	end

	local SetupWithEditItem = function()
		inUse = true;
		edit = true;
		actionsChanged = false;

		UpdateMenu();
		UpdateTooltip();
	end

	local SetupWithNewItem = function()
		inUse = true;
		edit = false;
		item = GHI_ItemInfo({
			authorName = UnitName("player"),
			authorGuid = UnitGUID("player"),
			guid = guidCreator.MakeGUID();
		});
		UpdateMenu();
		UpdateTooltip();
	end

	UpdateTooltip = function()
		if item then
			local lines = item.GetTooltipLines();

			ShowUIPanel(itemTooltip);
			if (not itemTooltip:IsShown()) then
				itemTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE");
			end

			itemTooltip:ClearLines();
			for _, line in pairs(lines) do
				itemTooltip:AddLine(line.text, line.r, line.g, line.b, true);
			end
			itemTooltip:Show()
			--itemTooltip:SetFrameLevel(20);
			itemTooltip:SetWidth(245)
			itemTooltip:SetHeight(min(itemTooltip:GetHeight(), 180));
		end
		
	end

	local OnOk = function()
		--if (edit) then
			item.IncreaseVersion(actionsChanged);
		--end
		itemList.UpdateItem(item);
		if not (edit) then
			containerList.InsertItemInMainBag(item.GetGUID());
		end
		menuFrame:Hide();
		GHI_MiscData.lastUpdateItemTime = GetTime();
	end

	UpdateActionList = function()
		if item then
			for i = 1, item.GetSimpleActionCount() do
				local action = item.GetSimpleAction(i);
				local name, icon, details = action.GetActionInfo();

				local existsAlready = false;
				for j = 1, actionList.GetTubleCount() do
					local t = actionList.GetTuble(j);
					if action == t.action then
						t.icon = icon;
						t.actionType = name;
						t.details = details;
						existsAlready = true;
						break;
					end
				end

				if existsAlready == false then
					local t = { icon = icon, actionType = name, details = details, action = action };
					actionList.SetTuble(actionList.GetTubleCount() + 1, t)
				end
			end

			-- delete all that doesn't exist
			local total = actionList.GetTubleCount();
			local newData = {};
			for j = 1, total do
				local t = actionList.GetTuble(j);
				for i = 1, item.GetSimpleActionCount() do
					if t.action == item.GetSimpleAction(i) then
						table.insert(newData, t);
						break;
					end
				end
			end
			actionList.data = newData;
			actionList.UpdateAll()
			menuFrame.SetLabel(actionList.label, actionList.data);

			local marked = actionList.GetMarked();
			if marked then
				menuFrame.GetLabelFrame("editActionButton"):Enable();
				menuFrame.GetLabelFrame("deleteActionButton"):Enable();
			else
				menuFrame.GetLabelFrame("editActionButton"):Disable();
				menuFrame.GetLabelFrame("deleteActionButton"):Disable();
			end
		end
	end

	local AddNewAction = function(action)
		item.AddSimpleAction(action);
		actionsChanged = true;
		UpdateActionList();
	end

	local NewAction = function(index)
		if _G[simpleActions[index][2]] then
			_G[simpleActions[index][2]](AddNewAction);
		else
			print(string.format("Menu for %s not found.", simpleActions[index][3] or "'Unknown'"))
		end
	end

	local EditMarkedAction = function()
		local marked = actionList.GetMarked();
		if marked then
			local t = actionList.GetTuble(marked);
			local action = t.action;
			if action then
				local actionType = action.GetType();
				for _, actionMenu in pairs(simpleActions) do
					if actionType == actionMenu[1] then
						_G[actionMenu[2]](function()
							actionsChanged = true;
							UpdateActionList()
						end, action);
						return;
					end
				end
				print(string.format("Menu for %s not found.", actionType or "'Unknown'"))
			end
		end
	end

	local DeleteMarkedAction = function()
		local marked = actionList.GetMarked();
		if marked then
			local t = actionList.GetTuble(marked);
			item.RemoveSimpleAction(t.action);
			UpdateActionList();
		end
	end

	local SetUpActionDD = function(parent)
		actionDD = CreateFrame("Frame", "GHI_StandardItemMenuActionDD" .. menuIndex, parent, "UIDropDownMenuTemplate");
		UIDropDownMenu_Initialize(actionDD, function(self)
			for i = 1, #(simpleActions) do
				local info = {};
				info.text = simpleActions[i][3];
				info.value = i;
				info.notCheckable = true;
				info.owner = self;
				info.func = function(self)
					NewAction(i)
				end;
				UIDropDownMenu_AddButton(info);
			end
		end, "MENU")
	end

	local newActionClick = function(self)
		if not (actionDD) then
			SetUpActionDD(self)
		end
		ToggleDropDownMenu(1, nil, actionDD, self, 0, 0);
	end

	local UpgradeItem = function(item)
       local info = item.Serialize("toAdvanced");
       --info.itemComplexity = "advanced";
       return GHI_ItemInfo(info);

     end
	local Convert = function()
		local newItem = UpgradeItem(item)
		if edit then
			advItemMenuList.Edit(newItem);
		else
			advItemMenuList.New(newItem);
		end
		menuFrame:Hide();
	end
	local ConvertToAdvItem = function()
		if item.GotBookAction() then
			StaticPopupDialogs["GHI_CONVERT_BOOK_WARNING"] = {
				text = "Warning: This item contains one or more book actions. They can not be converted to an advanced action. Converting it will loose the book data.\n\nContinue?",
				button1 = YES,
				button2 = NO,
				OnAccept = function()
					Convert();
				end,
				timeout = 0,
				whileDead = true,
				hideOnEscape = true,
				showAlert  = true,
				preferredIndex = 3,
			};
			StaticPopup_Show("GHI_CONVERT_BOOK_WARNING");
		else
			Convert();
		end
	end

	menuFrame = GHM_NewFrame(class, {
		onOk = function(self) end,
		{
			{
				{
					align = "l",
					type = "Editbox",
					text = loc.NAME;
					tooltip = loc.NAME_TT;
					label = "name",
					texture = "Tooltip",
					OnTextChanged = function(self)
						item.SetName(self:GetText())
						UpdateTooltip();
					end,
				},
			},
			{
				{
					align = "l",
					type = "Editbox",
					text = loc.WHITE_TEXT_1;
                         tooltip = loc.WHITE_TEXT_1_TT;
					label = "white1",
					texture = "Tooltip",
					OnTextChanged = function(self)
						item.SetWhite1(self:GetText())
						UpdateTooltip();
					end,
				},
			},
			{
				{
					align = "l",
					type = "Editbox",
					text = loc.WHITE_TEXT_2;
                         tooltip = loc.WHITE_TEXT_2_TT;
					label = "white2",
					texture = "Tooltip",
					OnTextChanged = function(self)
						item.SetWhite2(self:GetText())
						UpdateTooltip();
					end,
				},
			},
			{
				{
					align = "l",
					type = "Editbox",
					text = loc.YELLOW_QUOTE;
                         tooltip = loc.YELLOW_QUOTE_TT;
					label = "comment",
					texture = "Tooltip",
					OnTextChanged = function(self)
						item.SetComment(self:GetText())
						UpdateTooltip();
					end,
				},
			},
			{
				{
					align = "r",
					type = "QualityDD",
					text = loc.QUALITY;
                         tooltip = loc.QUALITY_TT;
					label = "quality",
					OnValueChanged = function(newValue)
						item.SetQuality(newValue);
						UpdateTooltip();
					end,
				},
				{
					type = "Icon",
					text = loc.ICON,
					align = "c",
					label = "icon",
					framealign = "r",
					CloseOnChoosen = true,
					OnChanged = function(icon)
						item.SetIcon(icon);
					end
				},
				{
					type = "CheckBox",
					text = loc.COPYABLE,
                         tooltip = loc.COPYABLE_TT;
					align = "l",
					label = "copyable",
					OnClick = function(self)
						item.SetCopyable(self:GetChecked());
					end,
				},
			},
			{
				{
					type = "StackSlider",
					text = loc.STACK_SIZE,
                         tooltip = loc.STACK_SIZE_TT;
					align = "c",
					label = "stackSize",
					OnValueChanged = function(size)
						item.SetStackSize(size);
					end,
				},
				{
					type = "CheckBox",
					text = loc.EDITABLE,
                         tooltip = loc.EDITABLE_TT;
					align = "l",
					label = "editable",
					OnClick = function(self)
						item.SetEditable(self:GetChecked());
					end,
				},
				{
					type = "Button",
					text = loc.CONVERT_ADV_ITEM,
					align = "r",
					label = "convert",
					compact = true,
					OnClick = ConvertToAdvItem,
				},
			},
			{
				{
					type = "Dummy",
					height = 10,
					width = 10,
					align = "r",
				}
			},
			{
				{
					type = "HBar",
					align = "c",
					width = 480,
				},
			},
			{
				{
					type = "Button",
					text = loc.NEW_ACTION,
					align = "l",
					label = "newActionButton",
					compact = true,
					OnClick = newActionClick,
				},
				{
					type = "Button",
					text = loc.DELETE_ACTION,
					align = "r",
					label = "deleteActionButton",
					compact = true,
					OnClick = DeleteMarkedAction,
				},
				{
					type = "Dummy",
					height = 10,
					width = 10,
					align = "r",
				},
				{
					type = "Button",
					text = loc.EDIT_ACTION,
					align = "r",
					label = "editActionButton",
					compact = true,
					OnClick = EditMarkedAction,
				},
			},
			{
				{
					type = "List",
					lines = 4,
					align = "l",
					label = "actions",
					column = {
						{
							type = "Icon",
							catagory = "",
							width = 20,
							label = "icon",
						},
						{
							type = "Text",
							catagory = loc.TYPE_U,
							width = 150,
							label = "actionType",
						},
						{
							type = "Text",
							catagory = loc.DETAILS,
							width = 295,
							label = "details",
						},
					},
					OnLoad = function(obj)
						obj:SetBackdropColor(0, 0, 0, 0.5);
					end,
					OnMarked = UpdateActionList,
				},
			},
			{
				{
					align = "l",
					type = "Editbox",
					text = loc.USE;
					label = "useText",
					texture = "Tooltip",
					OnTextChanged = function(self)
						item.SetUseText(self:GetText())
						UpdateTooltip();
					end,
				},
				{
					type = "TimeSlider",
					text = loc.ITEM_CD,
					align = "r",
					label = "cooldown",
					OnValueChanged = function(cd)
						item.SetCooldown(cd);
					end,
				},
				{
					type = "Dummy",
					height = 10,
					width = 30,
					align = "r",
				},
				{
					type = "CheckBox",
					text = loc.CONSUMED,
					align = "r",
					label = "consumed",
					OnClick = function(self)

						item.SetConsumed(self:GetChecked());
					end
				},
			},
			{
				{
					type = "Dummy",
					height = 10,
					width = 10,
					align = "c",
				},
			},
			{
				{
					type = "Dummy",
					height = 10,
					width = 100,
					align = "l",
				},
				{
					type = "Button",
					text = OKAY,
					align = "l",
					label = "ok",
					compact = false,
					OnClick = OnOk,
				},
				{
					type = "Dummy",
					height = 10,
					width = 100,
					align = "r",
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
		title = loc.CREATE_TITLE,
		name = "GHI_Standard_Item_Menu" .. menuIndex,
		theme = "BlankTheme",
		width = 500,
		useWindow = true,
		----background = "INTERFACE\\GLUES\\MODELS\\UI_BLOODELF\\bloodelf_mountains",
		OnShow = UpdateTooltip,
		OnHide = function()
			if not (menuFrame.window:IsShown()) then
				inUse = false;
			end
		end,
	});

	class.IsInUse = function()
		return inUse and menuFrame.window:IsShown()
	end

	class.GetItemGuid = function()
		return item.GetGUID();
	end

	class.New = function()
		menuFrame:AnimatedShow();


		SetupWithNewItem();
	end

	class.Edit = function(guid)
		local editItem = itemList.GetItemInfo(guid);
		if not (editItem.IsEditable() or editItem.IsCreatedByPlayer()) then
			GHI_Message(loc.CAN_NOT_EDIT);
			menuFrame:Hide();
			return
		end



		item = editItem.CloneItem();

		assert(editItem.GetItemComplexity() == "standard","Attempted to edit a non standard item",editItem.GetItemComplexity());

		menuFrame:AnimatedShow();

		SetupWithEditItem();
	end

	itemTooltip = CreateFrame("GameTooltip", "GHI_StandardItemMenuItemTooltip" .. menuIndex, menuFrame, "GHI_StandardItemMenuItemTooltip");
	_G["GHI_StandardItemMenuItemTooltip" .. menuIndex .. "TextLabel"]:SetText(loc.PREVIEW)

	itemTooltip:SetPoint("TOPRIGHT", 10, -24)
	menuFrame.window:AddScript("OnMinimize", function()
		if menuFrame.iconFrame then
			menuFrame.iconFrame:Hide();
		end
	end);

	actionList = menuFrame.GetLabelFrame("actions");


	return class;
end