--===================================================
--									
--									GHI Timer
--								GHI_Timer.lua
--
--				Calling of functions on a requested interval
--	
-- 						(c)2012 The Gryphonheart Team
--								All rights reserved
--===================================================

function GHI_Timer(func, interval, onceOnly, identifier)
	GHCheck("GHI_Timer", { "function", "number", "nilBoolean" }, { func, interval, onceOnly });
	local class = GHClass("GHI_Timer","frame");

	local lastCall = GetTime();

	class:SetScript("OnUpdate", function(self)
		if GetTime() > lastCall + interval then
			lastCall = GetTime();
			if onceOnly then
				class:SetScript("OnUpdate", function(self) end);
			end
			func();

			--[[UpdateAddOnMemoryUsage()
			local memoryBefore = GetAddOnMemoryUsage("GHI");
			func();
			UpdateAddOnMemoryUsage()
			local memoryDiff = GetAddOnMemoryUsage("GHI") - memoryBefore;
			if (memoryDiff) > 0 then
				print(memoryDiff,"id",identifier)
				--error("high memory",memoryDiff)
			end --]]
		end
	end);

	return class;
end
