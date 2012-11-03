--[[
 Copyright (c) 2012 Robin Schoonover

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to
 deal in the Software without restriction, including without limitation the
 rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 sell copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 IN THE SOFTWARE.
]]

local MAJOR, MINOR = "LibPetJournal-2.0", 16
local lib, oldminor = LibStub:NewLibrary(MAJOR, MINOR)

if not lib then return end

--
-- GLOBALS: PetJournal
--

local _G = _G
local hooksecurefunc, tinsert, pairs, wipe = _G.hooksecurefunc, _G.table.insert, _G.pairs, _G.wipe
local ipairs = _G.ipairs
local C_PetJournal = _G.C_PetJournal

--
--
--

lib.callbacks = lib.callbacks or LibStub("CallbackHandler-1.0"):New(lib)
lib.event_frame = lib.event_frame or CreateFrame("FRAME")
lib.event_frame:SetScript("OnEvent", function(frame, event, ...)
    frame[event](frame, ...)
end)

--
-- filter handling
--

do
    local PJ_FLAG_FILTERS = {
        [LE_PET_JOURNAL_FLAG_COLLECTED] = true,
        [LE_PET_JOURNAL_FLAG_NOT_COLLECTED] = true,
        [LE_PET_JOURNAL_FLAG_FAVORITES] = false
    }

    local s_search_filter
    local flag_filters = {}
    local type_filters = {}
    local source_filters = {}
    
    lib._filter_hooks = lib._filter_hooks or {}

    -- hook C_PetJournal.SetSearchFilter
    local last_search_filter
    if not lib._filter_hooks.SetSearchFilter then
        hooksecurefunc(C_PetJournal, "SetSearchFilter", function(...)
             lib._filter_hooks.SetSearchFilter(...)
        end)
    end
    lib._filter_hooks.SetSearchFilter = function(str)
        last_search_filter = str
    end
    
    -- hook C_PetJournal.ClearSearchFilter
    if not lib._filter_hooks.ClearSearchFilter then
        hooksecurefunc(C_PetJournal, "ClearSearchFilter", function(...)
             lib._filter_hooks.ClearSearchFilter(...)
        end)
    end
    lib._filter_hooks.ClearSearchFilter = function()
        last_search_filter = ""
    end

    --- Save and clear the PetJournal filters.
    -- Also prevents LibPetJournal or the PetJournal from reacting to filter
    -- events until :RestoreFilters() is called.  This is called
    -- automatically by LibPetJournal.
    -- @name LibPetJournal:ClearFilters()
    function lib:ClearFilters()
        assert(not lib._filters_cleared, "ClearFilters() already called")
        lib._filters_cleared = true
        
        if PetJournal then
            PetJournal:UnregisterEvent("PET_JOURNAL_LIST_UPDATE")
        end
        lib.event_frame:UnregisterEvent("PET_JOURNAL_LIST_UPDATE")

        for flag, value in pairs(PJ_FLAG_FILTERS) do
            flag_filters[flag] = not C_PetJournal.IsFlagFiltered(flag)
            if flag_filters[flag] ~= value then
                C_PetJournal.SetFlagFilter(flag, value)
            end
        end
        
        local need_add_all = false
        local ntypes = C_PetJournal.GetNumPetTypes()
        for i=1,ntypes do
            type_filters[i] = not C_PetJournal.IsPetTypeFiltered(i)
            if not type_filters[i] then
                need_add_all = true
            end
        end
        if need_add_all then
            C_PetJournal.AddAllPetTypesFilter()
        end
        
        need_add_all = false
        local nsources = C_PetJournal.GetNumPetSources()
        for i=1,nsources do
            source_filters[i] = not C_PetJournal.IsPetSourceFiltered(i)
            if not source_filters[i] then
                need_add_all = true
            end
        end
        if need_add_all then
            C_PetJournal.AddAllPetSourcesFilter()
        end

        if last_search_filter == nil then
            -- There's no way to actually get the current search filter without hooking it,
            -- and anyone loading earlier (especially if we are LOD) could have set it
            -- before our hook, so always clear the first time
            last_search_filter = ""
            C_PetJournal.ClearSearchFilter()
        elseif last_search_filter ~= "" then
            s_search_filter = last_search_filter
            C_PetJournal.ClearSearchFilter()
        else
            s_search_filter = nil
        end
    end

    --- Restore PetJournal filters after a :ClearFilters() call.
    -- Also reenables PetJournal and LibPetJournal reacting to the updated pet
    -- journal event. This is called automatically by LibPetJournal.
    -- @name LibPetJournal:RestoreFilters()
    function lib:RestoreFilters()
        assert(lib._filters_cleared, "ClearFilters() not called yet")
        lib._filters_cleared = false
        
        if s_search_filter and s_search_filter ~= "" then
            C_PetJournal.SetSearchFilter(s_search_filter)
        end
        
        for flag, value in pairs(flag_filters) do
            if value ~= PJ_FLAG_FILTERS[flag] then
                C_PetJournal.SetFlagFilter(flag, value)
            end
        end
        
        for flag,value in pairs(type_filters) do
            if value ~= true then
                C_PetJournal.SetPetTypeFilter(flag, value)
            end
        end
        
        for flag,value in pairs(source_filters) do
            if value ~= true then
                C_PetJournal.SetPetSourceFilter(flag, value)
            end
        end
    
        if PetJournal then
            PetJournal:RegisterEvent("PET_JOURNAL_LIST_UPDATE")
        end
        lib.event_frame:RegisterEvent("PET_JOURNAL_LIST_UPDATE")
    end
end

--
--
--

lib._petids = lib._petids or {}
lib._speciesids = lib._speciesids or {}
lib._set_speciesids = lib._set_speciesids or {}
lib._creatureids = lib._creatureids or {}
lib._set_creatureids = lib._set_creatureids or {}

--- Get an iterator over the list of pet ids.
-- The specific order of pet ids returned should not be relied upon.
-- @name LibPetJournal:IteratePetIDs()
function lib:IteratePetIDs()
    return ipairs(lib._petids)
end
lib.IteratePetIds = lib.IteratePetIDs

--- Get an iterator over the list of species ids.
-- @name LibPetJournal:IterateSpeciesIDs()
function lib:IterateSpeciesIDs()
    return ipairs(lib._speciesids)
end
lib.IterateSpeciesIds = lib.IterateSpeciesIDs

--- Get an iterator over the list of creature ids.
-- @name LibPetJournal:IterateCreatureIDs()
function lib:IterateCreatureIDs()
    return ipairs(lib._creatureids)
end

--- Return the species id for a given creature id.
-- @name LibPetJournal:GetSpeciesIDForCreatureID()
function lib:GetSpeciesIDForCreatureID(creatureid)
    return self._set_creatureids[creatureid]
end

--- Load pets stored in the PetJournal.
-- Under normal circumstances with API will run on its own in response to
-- updates to the Pet Journal.
-- @name LibPetJournal:LoadPets()
function lib:LoadPets()
    if lib._running then
        return false
    end
    
    lib._running = true
    self:ClearFilters()
    
    -- scan pets
    wipe(lib._petids)
    
    local total, owned = C_PetJournal.GetNumPets(false)
    if total == 0 and owned == 0 then
        self:RestoreFilters()
        self.event_frame:Show()
        lib._running = false
        return
    end
    
    for i = 1,total do
        local petID, speciesID, isOwned, _, _, _, _, _, _, _, creatureID = C_PetJournal.GetPetInfoByIndex(i, false)
        
        if isOwned then
            tinsert(lib._petids, petID)
        end
        
        if not lib._set_speciesids[speciesID] then
            lib._set_speciesids[speciesID] = true
            tinsert(lib._speciesids, speciesID)
        end
        
        if not lib._set_creatureids[creatureID] then
            lib._set_creatureids[creatureID] = speciesID
            tinsert(lib._creatureids, creatureID)
        end
    end
    
    -- Signal
    self.callbacks:Fire("PetListUpdated", self)
    
    -- restore PJ filters
    self:RestoreFilters()
    
    self.event_frame:Hide()
    lib._running = false
    
    return true
end

--- Determine if the pet list has been loaded.
-- @name LibPetJournal:IsLoaded()
-- @return boolean indicating whether the pet list has been loaded.
function lib:IsLoaded()
    return #lib._petids > 0 or #lib._speciesids > 0
end

--- Determine how many pets the player owns.
-- @name LibPetJournal:NumPets()
-- @return number of owned pets
function lib:NumPets()
    return #lib._petids
end

lib.event_frame:RegisterEvent("COMPANION_UPDATE")
function lib.event_frame:COMPANION_UPDATE(...)
    local ctype = ...
    -- Usually PET_JOURNAL_LIST_UPDATE is the correct event to watch for, 
    -- but on login, pets are not usually properly loaded yet.  Worse, not 
    -- even at P_E_W will this information be available.  After pets are
    -- loaded, this event only seems to fire when changing pets.
    if (ctype == nil or ctype == "CRITTER") and #lib._petids == 0 then
        lib:LoadPets()
    end
end

lib.event_frame:RegisterEvent("PET_JOURNAL_LIST_UPDATE")
function lib.event_frame:PET_JOURNAL_LIST_UPDATE()
    local total, owned = C_PetJournal.GetNumPets(false)
    
    if lib._last_owned ~= owned then
        lib._last_owned = owned
        if not lib:LoadPets() then
            lib.event_frame:Show()
            return
        end
    end
    
    lib.callbacks:Fire("PetsUpdated", self)
end

lib.event_frame:RegisterEvent("ADDON_LOADED")
function lib.event_frame:ADDON_LOADED()
    lib.event_frame:UnregisterEvent("ADDON_LOADED")
    if not lib:IsLoaded() then
        lib:LoadPets()
    end
end

local timer = 0
lib.event_frame:SetScript("OnUpdate", function(frame, elapsed)
    timer = timer + elapsed
    if timer > 2 then        
        lib:LoadPets()
        timer = 0
    end
end)
