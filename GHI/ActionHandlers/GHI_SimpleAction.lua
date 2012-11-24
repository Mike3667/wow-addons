--===================================================
--
--				GHI_SimpleAction
--  			GHI_SimpleAction.lua
--
--	   Data for a simple action of any type. This reflects most actions in GHI v.1.x.
--
-- 	  (c)2012 The Gryphonheart Team
--			All rights reserved
--===================================================
local ScriptFormat = function(script,...)
	local args = {...};
	for i,v in pairs(args) do
		local t = type(v);

		if t == "string" then
			v = gsub(v,"\\","\\\\");
			v = gsub(v,"\"","\\\"");
			args[i] = v;
		elseif t == "boolean" then
			if v == true then
				v = "true";
			else
				v = "false";
			end
			args[i] = v;
		end
	end
	return string.format(script,unpack(args));
end


local miscAPI;
local GetActionScript = function(info,oldVersion)
	local actionType = info.Type;
	if (actionType == "script" or info.dynamic_rc_type) and info.dynamic_rc == true then
		local dynamicTypeName = info.dynamic_rc_type;
		if dynamicTypeName == "produce_item" then
			if oldVersion then
				return string.format([[
					local ID = "ITEM_ID"; if not(ID) then GHI_Message("Could not identify source ID"); return; end;
				    local info = GHI_GetRightClickInfo(ID);
				    local produceGuid = "%s";
				    local t={};
				    if type(info) == "table" then
				    	for i=1,#(info) do
				    		if (info[i].id == produceGuid) or (info[i].guid == produceGuid)  and info[i].dynamic_rc_type == "produce_item" then
				    			t=info[i];
				    		end
				    	end
				    end
				    UpdateItemInfo(t.id or t.guid,t["item_data"]);
				    local amount = %s;
				    if (GHI_ProduceItem(produceGuid,amount)) then
				    	if amount > 1 then
				        	GHI_Message((recieve_text[t.loot_text] or "").." "..(GHI_GenerateLink(produceGuid) or "unknown").."x"..amount..".");
				    	else
				    		GHI_Message((recieve_text[t.loot_text] or "").." "..(GHI_GenerateLink(produceGuid) or "unknown"));
				    	end
				    end
				]],info.guid or info.id, info.amount)
               end
               --print(info.amount)
			if info.loot_text == nil then
				return string.format("GHI_ProduceItem(\"%s\",%s);", info.guid or info.id, info.amount),info.delay;
			else
				return string.format("if GHI_ProduceItem(\"%s\",%s) then GHI_Message(\"You %s: \"..(GHI_GenerateLink(\"%s\"))..\" x%s\"); end", info.guid or info.id, info.amount, info.loot_text, info.guid or info.id, info.amount),info.delay;
			end
		elseif dynamicTypeName == "message" then
			local colors = miscAPI.GHI_GetColors()
			local color = colors[info.color];
			--[[
			if info.output_type == 1 then
				return "DEFAULT_CHAT_FRAME:AddMessage(\"" .. info.text .. "\"," .. color.r .. "," .. color.g .. "," .. color.b .. ");", info.delay or 0;
			elseif info.output_type == 2 then
				return "UIErrorsFrame:AddMessage(\"" .. info.text .. "\"," .. color.r .. "," .. color.g .. "," .. color.b .. ",53,5);", info.delay or 0;
			end
			return "", 0;    --]]

			if info.output_type == 1 then
				return ScriptFormat("DEFAULT_CHAT_FRAME:AddMessage(\"%s\",%s,%s,%s);",info.text,color.r , color.g , color.b), info.delay or 0;
			elseif info.output_type == 2 then
				return ScriptFormat("UIErrorsFrame:AddMessage(\"%s\",%s,%s,%s,53,5);",info.text,color.r , color.g , color.b), info.delay or 0;
			end
			return "", 0;
		elseif dynamicTypeName == "screen_effect" then
			local color = info.color
			local fade_in = info.fade_in;
			local fade_out = info.fade_out;
			local duration = info.duration;
               local delay = info.delay or 0;

			if oldVersion then
				return ScriptFormat([[
					if not (GHFlashFrame) then
						GHFlashFrame = CreateFrame("Frame", "GHFlashFrame", UIParent);
						GHFlashFrame:SetFrameStrata("BACKGROUND");
						GHFlashFrame:SetAllPoints(UIParent);
						GHFlashFrame.bg = GHFlashFrame:CreateTexture(nil, "CENTER")

						GHFlashFrame.bg:SetAllPoints(GHFlashFrame)
					end

					local fadeIn, fadeOut, duration, color = %s,%s,%s,{r=%s,g=%s,b=%s};

				    GHFlashFrame.bg:SetTexture(color.r, color.g, color.b)
					if UIFrameIsFading and UIFrameIsFading(GHFlashFrame) then return end --previous flash check
					UIFrameFlash(GHFlashFrame, fadeIn, fadeOut, duration, false, 0, duration - (fadeIn+fadeOut))
				]],fade_in, fade_out, duration or "nil",color.r,color.g,color.b)
			end

			local script = ScriptFormat("GHI_ScreenFlash(%s,%s,%s,{r=%s,g=%s,b=%s})", fade_in, fade_out, duration or "nil",color.r,color.g,color.b);
			return script, delay;

		elseif dynamicTypeName == "remove_buff" then
			local name = info.name or ""
			local filter = info.filter or "Helpful"
			local amount = info.amount or 1
			local delay = info.delay or 0

			return ScriptFormat("GHI_RemoveBuff(\"%s\",\"%s\",%s,%s)", name, filter, amount, delay or "nil");
		elseif dynamicTypeName == "consume_item" then
			local amount = info.amount or 1
			local guid = info.id or ""
               local delay = info.delay or 0;

			local script = ScriptFormat("GHI_ConsumeItem(\"%s\",%s)",  guid or "nil",amount);
			return script,delay;
		else
			return info.script or "GHI_Message(\"Dynamic Item script not found. " .. (dynamicTypeName or "nil") .. "\");", info.delay or 0;
		end
	elseif actionType == "script" then
		return string.join("", unpack(info.code)), info.delay or 0;
	elseif actionType == "buff" then
		local buffName = info.buffName or "Unknown";
		local buffIcon = info.buffIcon or "";
		local buffDetails = info.buffDetails or "";
		local untilCanceled = "false";
		if info.untilCanceled or info.untillCanceled then
			untilCanceled = "true";
		end
		local filter = info.filter or "Helpful";
		local buffType = info.buffType or "Magic";
		local buffDuration = info.buffDuration or 0;
		local cancelable = "false";
		if info.cancelable then
			cancelable = "true";
		end
		local stackable = "false";
		if info.stackable then
			stackable = "true";
		end
		local count = info.count or 1;
		local delay = info.delay or 0;
		local range = info.range or 0;
		local alwaysCastOnSelf = "false";
		if info.castOnSelf then
			alwaysCastOnSelf = "true";
		end

		local script = ScriptFormat("GHI_ApplyBuff(\"%s\",\"%s\",\"%s\",%s,\"%s\",\"%s\",%s,%s,%s,%s,%s,%s,%s);", buffName, buffDetails, buffIcon, untilCanceled, filter, buffType, buffDuration, cancelable, stackable, count, delay, range, alwaysCastOnSelf);

		--script = gsub(script, "\\", "\\\\")
		return script, 0; -- the buff handler handles the delay
	elseif actionType == "equip_item" then
		return ScriptFormat("EquipItemByName(\"%s\");", info.item_name), info.delay or 0;
	elseif actionType == "expression" then
		local script;
		--local text = gsub(info.text,"\"","\\\"");
		if string.lower(info.expression_type) == "say" then
			return ScriptFormat("GHI_Say(\"%s\",%s)", info.text, info.delay or "nil"),0;
		elseif string.lower(info.expression_type) == "emote" then
			return ScriptFormat("GHI_Emote(\"%s\",%s)", info.text, info.delay or "nil"),0;
		end
		--script = gsub(script, "\\", "\\\\");
		--script = gsub(script, "\\\\\"", "\\\"");
		--return script, 0;
	elseif actionType == "random_expression" then
		local strings = {};
		for i, text in pairs(info.text) do
			--text = gsub(text, "\\", "\\\\")
			if string.lower(info.expression_type[i] or "") == "say" or info.expression_type[i] == 1 then
				table.insert(strings, ScriptFormat("GHI_Say(\"%s\")", text));
			else
				table.insert(strings, ScriptFormat("GHI_Emote(\"%s\")", text));
			end
		end

		local determinationPart;
		if not (info.allow_same == true or info.allow_same == 1) then
			determinationPart = string.format("local n = %s; local r = random(n); local index = (stack.GetItemGuid() or '')..'_RandomExp';  while(_G[index] == r) do  r = random(n); end _G[index] = r", #(strings));
		else
			determinationPart = "local r = random(" .. #(strings) .. ");"
		end

		local executionPart = "";
		for i = 1, #(strings) do
			if not (i == #(strings)) then
				executionPart = string.format("%sif r == %s then %s else", executionPart, i, strings[i])
			else
				executionPart = string.format("%sif r == %s then %s end", executionPart, i, strings[i])
			end
		end

		return string.format("%s\n%s", determinationPart, executionPart), 0;
	elseif actionType == "bag" then
         -- print(info.size)
		return ScriptFormat("GHI_OpenBag(stack.GetContainerGuid(),stack.GetContainerSlot(),%s,\"%s\");", info.size, info.texture or ""), 0;
	elseif actionType == "book" then
		--syntax : GHI_ShowBook(title,pages,material,font,normalSize,h1Size,h2Size)

		local pageScript = "{";
		for i = 1, #(info) do
			if type(info[i]) == "table" then
				local page = "";
				for j = 1, 10 do
					if info[i]["text" .. j] then
						page = page .. info[i]["text" .. j];
					end
				end
				--page = gsub(page, "\\", "\\\\")
				--page = gsub(page, "\"", "\\\"");
				pageScript = string.format("%s\"%s\",", pageScript,ScriptFormat("%s",page));
			end
		end
		pageScript = pageScript .. "}";

		if (pageScript == "{}") then
			pageScript = "{\"\"}";
		end
		pageScript = gsub(pageScript, "\r", "");
		local script = string.format("GHI_ShowBook(stack.GetContainerGuid(),stack.GetContainerSlot(),\"%s\",%s,\"%s\",\"%s\",%s,%s,%s);",ScriptFormat("%s",info.title or ""), pageScript, info.material or "nil", string.gsub(info.font or "nil","\\","\\\\"), info.n or "nil", info.h1 or "nil", info.h2 or "nil");

		return script, 0;
	elseif actionType == "sound" then
		local path = info.sound_path;
		local soundDelay = info.delay or 0;
		local range = info.range or 0;
		local script;
		if range > 0 then
			return ScriptFormat("GHI_PlayAreaSound(\"%s\",%s,%s)", path, range, soundDelay);
		else
			return ScriptFormat("GHI_PlaySound(\"%s\",%s)", path, soundDelay);
		end
		--return gsub(script, "\\", "\\\\"), 0;
    elseif actionType == "requirement" then --legacy script handler

               --print(info.req_type)
               --print(info.req_alias)
              -- print(info.req_detail)
              --info.req
               --IsRquirmentFullfilled(info.req_type,info.req_alias,info.req_detail,info.req)
		return ScriptFormat("return IsRequirementFullfilled(%q,%q,GHI_DoScript)",info.req_type,info.req_detail);
	else
		return info.script or "GHI_Message(\"Item script not found. " .. (actionType or "nil") .. "\")", info.delay or 0; -- return script,delay,requiredItems
	end
end

local guidMaker;
local conversionMatrix = {
	produce_item = function(info)
		return {
			{
				actionGuid = "delay_01",
				guid = guidMaker.MakeGUID(),
				inputs = {
					delay = {
						type = "static",
						info = info.delay,
					},
				},
			},
			{
				actionGuid = "prod_01",
				guid = guidMaker.MakeGUID(),
				inputs = {
					item = {
						type = "static",
						info = info.guid or info.id,
					},
					amount = {
						type = "static",
						info = info.amount,
					},
					text = {
						type = "static",
						info = info.loot_text:lower(),
					},
				},
				portConnection = {
					setup = {
						instanceIndexDiff = -1,
						port = "delayed",
					},
				},
				nextPort = {
					instanceIndexDiff = -2,
					port = "onsetup",
				},
			},
		};
	end,
	message = function(info)
		local colors = miscAPI.GHI_GetColors()
		local color = colors[info.color];
		return {
			{
				actionGuid = "delay_01",
				guid = guidMaker.MakeGUID(),
				inputs = {
					delay = {
						type = "static",
						info = info.delay,
					},
				},
			},
			{
				actionGuid = "msg_01",
				guid = guidMaker.MakeGUID(),
				inputs = {
					msg = {
						type = "static",
						info = info.text,
					},
					color = {
						type = "static",
						info = color,
					},
					outputType = {
						type = "static",
						info = info.output_type,
					},
				},
				portConnection = {
					setup = {
						instanceIndexDiff = -1,
						port = "delayed",
					},
				},
				nextPort = {
					instanceIndexDiff = -2,
					port = "onsetup",
				},
			},
		};
	end,
	screen_effect = function(info)
		return {
			{
				actionGuid = "delay_01",
				guid = guidMaker.MakeGUID(),
				inputs = {
					delay = {
						type = "static",
						info = info.delay,
					},
				},
			},
			{
				actionGuid = "Screen_01",
				guid = guidMaker.MakeGUID(),
				inputs = {
					fadein = {
						type = "static",
						info = info.fade_in,
					},
					fadeout = {
						type = "static",
						info = info.fade_out,
					},
					duration = {
						type = "static",
						info = info.duration,
					},
					inputcolor = {
						type = "static",
						info = info.color,
					},
				},
				portConnection = {
					setup = {
						instanceIndexDiff = -1,
						port = "delayed",
					},
				},
				nextPort = {
					instanceIndexDiff = -2,
					port = "onsetup",
				},
			},
		};
	end,
	remove_buff = function(info)
		return {
			{
				actionGuid = "buff_02",
				guid = guidMaker.MakeGUID(),
				inputs = {
					buffName = {
						type = "static",
						info = info.name,
					},
					filter = {
						type = "static",
						info = ({"helpful","harmful"})[info.filter],
					},
					amount = {
						type = "static",
						info = info.amount,
					},
					delay = {
						type = "static",
						info = info.delay,
					},
				},
				nextPort = {
					instanceIndexDiff = -1,
					port = "onsetup",
				},
			},
		};
	end,
	consume_item = function(info)
		return {
			{
				actionGuid = "delay_01",
				guid = guidMaker.MakeGUID(),
				inputs = {
					delay = {
						type = "static",
						info = info.delay,
					},
				},
			},
			{
				actionGuid = "cons_01",
				guid = guidMaker.MakeGUID(),
				inputs = {
					item = {
						type = "static",
						info = info.id,
					},
					amount = {
						type = "static",
						info = info.amount,
					},
				},
				portConnection = {
					setup = {
						instanceIndexDiff = -1,
						port = "delayed",
					},
				},
				nextPort = {
					instanceIndexDiff = -2,
					port = "onsetup",
				},
			},
		};
	end,
	script = function(info)
		return {
			{
				actionGuid = "delay_01",
				guid = guidMaker.MakeGUID(),
				inputs = {
					delay = {
						type = "static",
						info = info.delay,
					},
				},
			},
			{
				actionGuid = "script_01",
				guid = guidMaker.MakeGUID(),
				inputs = {
					code = {
						type = "static",
						info = string.join("", unpack(info.code)),
					},
				},
				portConnection = {
					setup = {
						instanceIndexDiff = -1,
						port = "delayed",
					},
				},
				nextPort = {
					instanceIndexDiff = -2,
					port = "onsetup",
				},
			},
		};
	end,
	buff = function(info)
		local buffName = info.buffName or "Unknown";
		local buffIcon = info.buffIcon or "";
		local buffDetails = info.buffDetails or "";
		local untilCanceled = false;
		if info.untilCanceled or info.untillCanceled then
			untilCanceled = true;
		end
		local filter = info.filter or "Helpful";
		local buffType = info.buffType or "Magic";
		local buffDuration = info.buffDuration or 0;
		local cancelable = false;
		if info.cancelable then
			cancelable = true;
		end
		local stackable = false;
		if info.stackable then
			stackable = true;
		end
		local count = info.count or 1;
		local delay = info.delay or 0;
		local range = info.range or 0;
		local alwaysCastOnSelf = false;
		if info.castOnSelf then
			alwaysCastOnSelf = true;
		end

		return {
			{
				actionGuid = "buff_01",
				guid = guidMaker.MakeGUID(),
				inputs = {
					buffName = {
						type = "static",
						info = buffName,
					},
					buffDetails = {
						type = "static",
						info = buffDetails,
					},
					buffIcon = {
						type = "static",
						info = buffIcon,
					},
					untilCanceled = {
						type = "static",
						info = untilCanceled,
					},
					filter = {
						type = "static",
						info = filter,
					},
					buffType = {
						type = "static",
						info = buffType,
					},
					duration = {
						type = "static",
						info = buffDuration,
					},
					cancelable = {
						type = "static",
						info = cancelable,
					},
					stackable = {
						type = "static",
						info = stackable,
					},
					count = {
						type = "static",
						info = count,
					},
					delay = {
						type = "static",
						info = delay,
					},
					range = {
						type = "static",
						info = range,
					},
					alwaysCastOnSelf = {
						type = "static",
						info = alwaysCastOnSelf,
					},
				},
				nextPort = {
					instanceIndexDiff = -1,
					port = "onsetup",
				},

			},
		};
	end,
	equip_item = function(info)
		return {
			{
				actionGuid = "delay_01",
				guid = guidMaker.MakeGUID(),
				inputs = {
					delay = {
						type = "static",
						info = info.delay,
					},
				},
			},
			{
				actionGuid = "equip_01",
				guid = guidMaker.MakeGUID(),
				inputs = {
					equip = {
						type = "static",
						info = info.item_name,
					},
				},
				portConnection = {
					setup = {
						instanceIndexDiff = -1,
						port = "delayed",
					},
				},
				nextPort = {
					instanceIndexDiff = -2,
					port = "onsetup",
				},
			},
		};
	end,
	expression = function(info)
		if string.lower(info.expression_type) == "say" then
			return {
				{
					actionGuid = "delay_01",
					guid = guidMaker.MakeGUID(),
					inputs = {
						delay = {
							type = "static",
							info = info.delay,
						},
					},
				},
				{
					actionGuid = "expression_01",
					guid = guidMaker.MakeGUID(),
					inputs = {
						expressSay = {
							type = "static",
							info = info.text,
						},
					},
					portConnection = {
						setup = {
							instanceIndexDiff = -1,
							port = "delayed",
						},
					},
					nextPort = {
						instanceIndexDiff = -2,
						port = "onsetup",
					},
				},
			};
		elseif string.lower(info.expression_type) == "emote" then
			return {
				{
					actionGuid = "delay_01",
					guid = guidMaker.MakeGUID(),
					inputs = {
						delay = {
							type = "static",
							info = info.delay,
						},
					},
				},
				{
					actionGuid = "expression_02",
					guid = guidMaker.MakeGUID(),
					inputs = {
						expressEmote = {
							type = "static",
							info = info.text,
						},
					},
					portConnection = {
						setup = {
							instanceIndexDiff = -1,
							port = "delayed",
						},
					},
					nextPort = {
						instanceIndexDiff = -2,
						port = "onsetup",
					},
				},
			};
		end
	end,
	random_expression = function(info)
		local t = {
		    {
				actionGuid = "rand_02",
				guid = guidMaker.MakeGUID(),
				inputs = {

				},
			},
		};

		for i=1,6 do
			local val = 0;
			if i <= #(info.text) then
				val = 1;
			end
			t[1].inputs["randomscale"..i] = {
				type = "static",
				info = val,
			};
		end

		for i=1,#(info.text) do
			local text = info.text[i];
			local guid = "expression_02";
			local index = "expressEmote";
			if string.lower(info.expression_type[i] or "") == "say" or info.expression_type[i] == 1 then
				guid = "expression_01";
				index = "expressSay";
			end
			table.insert(t,{
				actionGuid = guid,
				guid = guidMaker.MakeGUID(),
				inputs = {
					[index] = {
						type = "static",
						info = text,
					},
				},
				portConnection = {
					setup = {
						instanceIndexDiff = -i,
						port = "randomport"..i,
					},
				},
			})

		end
		t[#(t)].nextPort = {
			instanceIndexDiff = -( #(info.text) + 1),
			port = "onsetup",
		};

		return t;
	end,
	bag = function(info)
		return {
			{
				actionGuid = "bag_01",
				guid = guidMaker.MakeGUID(),
				inputs = {
					size = {
						type = "static",
						info = info.size,
					},
					texture = {
						type = "static",
						info = info.texture,
					},
				},
				nextPort = {
					instanceIndexDiff = -1,
					port = "onsetup",
				},
			},
		};
	end,
	sound = function(info)
		local path = info.sound_path;
		local soundDelay = info.delay or 0;
		local range = info.range or 0;

		if range > 0 then
			return {
				{
					actionGuid = "sound_02",
					guid = guidMaker.MakeGUID(),
					inputs = {
						sound = {
							type = "static",
							info = {path=path},
						},
						range = {
							type = "static",
							info = range,
						},
						delay = {
							type = "static",
							info = soundDelay,
						},
					},
					nextPort = {
						instanceIndexDiff = -1,
						port = "onsetup",
					},
				},
			};
		else
			return {
				{
					actionGuid = "delay_01",
					guid = guidMaker.MakeGUID(),
					inputs = {
						delay = {
							type = "static",
							info = soundDelay,
						},
					},
				},
				{
					actionGuid = "sound_01",
					guid = guidMaker.MakeGUID(),
					inputs = {
						sound = {
							type = "static",
							info = {path=path},
						},
					},
					portConnection = {
						setup = {
							instanceIndexDiff = -1,
							port = "delayed",
						},
					},
					nextPort = {
						instanceIndexDiff = -2,
						port = "onsetup",
					},
				},
			};
		end
	end,
};

local ConvertActionToAdvanced = function(info)
 	local actionType = info.Type;
	if (actionType == "script" or info.dynamic_rc_type) and info.dynamic_rc == true then
		actionType = info.dynamic_rc_type;
	end

	if not(guidMaker) then
		guidMaker = GHI_GUID();
	end

	if conversionMatrix[actionType] then
		return conversionMatrix[actionType](info);
	end
	print("Warning. An action could not be converted:",actionType)
	return {};
end

function GHI_SimpleAction(info)
	GHCheck("GHI_SimpleAction(info):", { "table" }, { info });
	local class = GHClass("GHI_SimpleAction");
	local guid = GHI_GUID().MakeGUID();
	local actionApiHandler = GHI_ActionAPI();
	local itemInfoList = GHI_ItemInfoList();
	local log = GHI_Log();

	if not (miscAPI) then
		miscAPI = GHI_MiscAPI().GetAPI();
	end

	local details, dependingItems, script, delay, itemInfoList, icon, details, actionName, executionOrder, actionType;

	local Initialize = function()
		script = "";
		icon = info.icon;
		actionName = info.type_name; -- localized action name
		details = info.details;
		script, delay = GetActionScript(info)
		executionOrder = info.req or 1;
		actionType = info.Type;

		if info.ItemInfo then
			local itemTable = info.ItemInfo or {};
			local producedItem = GHI_ItemInfo(itemTable);
			itemInfoList.UpdateItem(producedItem)
			dependingItems = { producedItem.GetGUID() };
		end

		dependingItems = { info.guid or info.id }
	end

	class.Serialize = function(stype)
		if stype == "action" then
			-- send info but without script, iteminfo etc
			local t = {};
			for i, v in pairs(info) do
				t[i] = v;
			end
			t.item_data = nil;
			--t.code = nil;
			return t;
		elseif stype == "oldAction" then

			local t = {};
			for i, v in pairs(info) do
				t[i] = v;
			end
			if info.dynamic_rc then
				t.code = {GetActionScript(info,true)};
			end
			t.item_data = nil;
			if not(t.id) then
				t.id = t.guid
			end

			-- if there is produce item or adv produce item  then these need to be inserted too
			if #(dependingItems) > 0 then
				local dependingGuid = dependingItems[1];
				local dependingItem = itemInfoList.GetItemInfo(dependingGuid);
				t.item_data = dependingItem.Serialize();
			end
			return t;
		elseif stype == "toAdvanced" then
			return ConvertActionToAdvanced(info);
		else
			return info;
		end
	end

	class.GetDependingItems = function()
		return dependingItems;
	end

	class.Execute = function(scriptingEnv, stack)
		log.Add(3,"Executed simple action: "..actionName,{details=details})
		local combinedGuid = guid .. stack.GetGUID();

		if stack then
			scriptingEnv.SetValue("stack_" .. combinedGuid, stack.GetStackAPI(true));
		end

		local preScript = [[
			local stack = stack_DYN_GUID;
			local oldDoScript = DoScript;
			local DoScript = function(s,d) oldDoScript(s,d,"DYN_GUID"); end
			local oldDoScript = nil;
			_SetActionAPIItemGuid(stack.GetItemGuid());
		]];
		preScript = string.gsub(preScript, "DYN_GUID", combinedGuid);
		scriptingEnv.SetHeaderApi(combinedGuid, preScript, "")

		return scriptingEnv.ExecuteScript(script, delay,combinedGuid)
	end

	class.GetType = function()
		if info.dynamic_rc == true then
			return info.dynamic_rc_type;
		end
		return info.Type;
	end

	class.GetInfo = function()
		return info;
	end
	class.UpdateInfo = function(_info)
		info = _info;
		Initialize();
	end

	class.GetActionInfo = function()
		return actionName, icon, details;
	end

	class.GetExecutionOrder = function()
		return executionOrder;
	end

	class.GetActionType = function()
		return actionType;
	end



	Initialize();

	return class;
end
