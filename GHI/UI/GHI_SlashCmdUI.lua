--===================================================
--									
--										GHI SlashCmd
--									GHI_SlashCmdUI.lua
--
--							Slash Command handler
--	
-- 						(c)2012 The Gryphonheart Team
--								All rights reserved
--===================================================	

function GHI_SlashCmd(mainSlashPrefix)
	local class = GHClass("GHI_SlashCmd");
	local commandFunctions = {};
	local defaultFunc;

	local RunDefaultFunc = function(arg1)
		if defaultFunc then
			defaultFunc(arg1);
		end
	end

	local RunCmdFunc = function(name, arg1)
		local lname = strlower(name);
		if type(commandFunctions[lname ]) == "function" then
			commandFunctions[lname ](arg1);
		else
			RunDefaultFunc(name .." ".. (arg1 or ""));
		end
	end

	local ExtractPrefixAndSuffixFromString = function(str)
		local firstSpace = string.find(str, " ");
		local prefix, suffix = str, "";

		if firstSpace and firstSpace > 0 then
			prefix = strsub(str, 0, firstSpace - 1) or "";
			suffix = strsub(str, firstSpace + 1 or "");
		end
		return prefix, suffix;
	end


	local OnSlashCommand = function(slashCmdMsg)
		local prefix, suffix = ExtractPrefixAndSuffixFromString(slashCmdMsg);
		RunCmdFunc(prefix, suffix);
	end


	class.SetDefaultFunc = function(func)
		assert(type(func) == "function");
		defaultFunc = func;
	end

	class.RegisterSubPrefix = function(subPrefix, func)
		assert(type(subPrefix) == "string");
		assert(type(func) == "function");
		commandFunctions[strlower(subPrefix)] = func;
	end

	-- setup
	SlashCmdList[mainSlashPrefix] = OnSlashCommand;
	_G["SLASH_" .. mainSlashPrefix .. "1"] = "/" .. mainSlashPrefix;

	return class;
end