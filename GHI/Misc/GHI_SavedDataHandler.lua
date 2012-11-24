--===================================================
--
--			GHI_SavedDataHandler
--			GHI_SavedData.lua
--
--	          (description)
--
--		(c)2012 The Gryphonheart Team
--			All rights reserved
--===================================================
local UPGRADE_DETECTED = false;
local ERROR_MSG = "GHI ERROR. PARTIAL DATA CORRUPTION!";
local VARS_LOADED;
GHI_Event("VARIABLES_LOADED", function()
	if type(GHI_ActionBarData) == "table" then
		UPGRADE_DETECTED = true;
	end
	VARS_LOADED = true;
end)

function GHI_SavedData(saveTableName)
	GHCheck("GHI_SavedData(saveTableName)", { "string" }, { saveTableName });
	local class = GHClass("GHI_SavedData")
	local data = {};
	local cs_n;
	local loaded;

	local GenerateCS;
	GenerateCS = function(v)
		local t = type(v);
		if t == "table" then
			local c = 0;
			for i, v2 in pairs(v) do
				local c2 = math.floor(GenerateCS(v2) * (GenerateCS(i) / 10));
				c = c + c2;
			end
			return mod(c, 10 ^ 9);
		elseif t == "number" then
			return math.floor(v * 1.5);
		elseif t == "string" then
			local c = 0;
			for i = 1, string.len(v) do
				c = c + string.byte(v, i) * i;
			end
			return c;
		elseif t == "function" then
			return 0;
		elseif t then
			return 2;
		else
			return 3;
		end
	end

	local UCS = function(s)
		local c = "";
		for i = 1, string.len(s) do
			local v = string.byte(s, i);
			if v > 80 then
				c = c .. string.char(v - mod(i, 5));
			else
				c = c .. string.char(v - mod(i, 5));
			end
		end
		return c;
	end

	local Load = function()
		data = _G[saveTableName] or {};
		_G[saveTableName] = data;

		cs_n = GenerateCS(saveTableName) + GenerateCS(UnitName("player")) + GenerateCS(GetRealmName());
		GHI_CS = GHI_CS or {};
		local cr = false;
		--print("loading",saveTableName);
		if not (UPGRADE_DETECTED) then
			--if not( GHI_CS[cs_n]) then print("cs table not found for",cs_n) end
			local cs = GHI_CS[cs_n] or {};
			for i, v in pairs(data) do
				if not (GenerateCS(v) == cs[UCS(i)]) then
					data[i] = nil;
					cr = true;
				end
			end
		else --print("Upgrade")
			local cs = {};
			for i, v in pairs(data) do
				cs[UCS(i)] = GenerateCS(v); --print(i,"cs",cs[UCS(i)])
			end
			GHI_CS[cs_n] = cs;
			--print("CS table saved to",cs_n)
		end
		loaded = true;
		if cr == true then
			print(ERROR_MSG)
		end
	end

	class.GetVar = function(index)
		if not (VARS_LOADED) then error("Variables not loaded yet.") end
		if not (loaded) then Load(); end
		return data[index];
	end

	class.SetVar = function(index, var)
		if not (VARS_LOADED) then error("Variables not loaded yet.") end
		if not (loaded) then Load(); end
		data[index] = var;
		GHI_CS[cs_n] = GHI_CS[cs_n] or {};
		if var ~= nil then
			GHI_CS[cs_n][UCS(index)] = GenerateCS(var);
		else
			GHI_CS[cs_n][UCS(index)] = nil;
		end
	end

	class.GetAll = function()
		if not (VARS_LOADED) then error("Variables not loaded yet.") end
		if not (loaded) then Load(); end
		local t = {};
		for i, v in pairs(data) do
			t[i] = v;
		end
		return t;
	end

	return class
end
