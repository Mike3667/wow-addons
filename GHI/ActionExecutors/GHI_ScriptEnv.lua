﻿--===================================================
--								GHI Script Enviroment
--									GHI_ScriptEnv.lua
--
--		Limited enviroment for execution of scripts
--	
-- 						(c)2012 The Gryphonheart Team
--								All rights reserved
--===================================================	

function GHI_ScriptEnviroment(ownerGuid)
	local class = GHClass("GHI_ScriptEnviroment"); -- a class object
	local delayedScripts = {};
	local executingStackIndex;
	local stacks = {};
     local loc = GHI_Loc();
	-- create special objects
	local GHUIParent = CreateFrame("Frame", UIParent);
	GHUIParent:SetAllPoints(UIParent);
	GHUIParent.GetParent = nil;
	GHUIParent.GetPoint = nil;

	local GHWorldFrame = CreateFrame("Frame", WorldFrame);
	GHWorldFrame:SetAllPoints(WorldFrame);
	GHWorldFrame.GetParent = nil;
	GHWorldFrame.GetPoint = nil;


	-- set up the allowed functions
	local environment = {
		-- Standard lua functions
		assert = assert,
		collectgarbage = collectgarbage,
		date = date,
		error = error,
		getmetatable = getmetatable,
		next = next,
		newproxy = newproxy,
		pcall = pcall,
		select = select,
		setmetatable = setmetatable,
		time = time,
		type = type,
		unpack = unpack,

		-- Math functions
		abs = abs,
		acos = acos,
		asin = asin,
		atan = atan,
		atan2 = atan2,
		ceil = ceil,
		cos = cos,
		deg = deg,
		exp = exp,
		floor = floor,
		frexp = frexp,
		ldexp = ldexp,
		log = log,
		log10 = log10,
		max = max,
		min = min,
		mod = mod,
		rad = rad,
		random = random,
		sin = sin,
		sqrt = sqrt,
		tan = tan,
		math = math,

		-- string functions
		format = format,
		gsub = gsub,
		strbyte = strbyte,
		strchar = strchar,
		strfind = strfind,
		strlen = strlen,
		strlower = strlower,
		strmatch = strmatch,
		strrep = strrep,
		strrev = strrev,
		strsub = strsub,
		strupper = strupper,
		tonumber = tonumber,
		tostring = tostring,
		strlenutf8 = strlenutf8,
		strtrim = strtrim,
		strsplit = strsplit,
		strjoin = strjoin,
		strconcat = strconcat,
		tostringall = tostringall,
		string = string,

		-- table functions
		foreach = foreach,
		foreachi = foreachi,
		getn = getn,
		ipairs = ipairs,
		pairs = pairs,
		sort = sort,
		tContains = tContains,
		tinsert = tinsert,
		tremove = tremove,
		wipe = wipe,
		["#"] = table.getn,
		table = table,

		-- bit functions
		bit = bit,
		--coroutine=coroutine,

		SetCVar = SetCVar,
		GetCVar = GetCVar,


		-- ===========  WoW API ===============
		-- Achievement
		AddTrackedAchievement = AddTrackedAchievement,
		CanShowAchievementUI = CanShowAchievementUI,
		ClearAchievementComparisonUnit = ClearAchievementComparisonUnit,
		GetAchievementCategory = GetAchievementCategory,
		GetAchievementComparisonInfo = GetAchievementComparisonInfo,
		GetAchievementComparisonUnitInfo = GetAchievementComparisonUnitInfo,
		GetAchievementCriteriaInfo = GetAchievementCriteriaInfo,
		GetAchievementInfo = GetAchievementInfo,
		GetAchievementInfoFromCriteria = GetAchievementInfoFromCriteria,
		GetAchievementLink = GetAchievementLink,
		GetAchievementNumCriteria = GetAchievementNumCriteria,
		GetAchievementNumRewards = GetAchievementNumRewards,
		GetCategoryInfo = GetCategoryInfo,
		GetCategoryList = GetCategoryList,
		GetCategoryNumAchievements = GetCategoryNumAchievements,
		GetComparisonStatistic = GetComparisonStatistic,
		GetLatestCompletedAchievements = GetLatestCompletedAchievements,
		GetLatestCompletedComparisonAchievements = GetLatestCompletedComparisonAchievements,
		GetLatestUpdatedComparisonStats = GetLatestUpdatedComparisonStats,
		GetLatestUpdatedStats = GetLatestUpdatedStats,
		GetNextAchievement = GetNextAchievement,
		GetNumComparisonCompletedAchievements = GetNumComparisonCompletedAchievements,
		GetNumCompletedAchievements = GetNumCompletedAchievements,
		GetPreviousAchievement = GetPreviousAchievement,
		GetStatistic = GetStatistic,
		GetStatisticsCategoryList = GetStatisticsCategoryList,
		GetTotalAchievementPoints = GetTotalAchievementPoints,
		GetTrackedAchievement = GetTrackedAchievement,
		GetNumTrackedAchievements = GetNumTrackedAchievements,
		RemoveTrackedAchievement = RemoveTrackedAchievement,
		SetAchievementComparisonUnit = SetAchievementComparisonUnit,

		-- Action functions
		ActionHasRange = ActionHasRange,
		GetActionBarPage = GetActionBarPage,
		GetActionBarToggles = GetActionBarToggles,
		GetActionCooldown = GetActionCooldown,
		GetActionCount = GetActionCount,
		GetActionInfo = GetActionInfo,
		GetActionText = GetActionText,
		GetActionTexture = GetActionTexture,
		GetBonusBarOffset = GetBonusBarOffset,
		GetMouseButtonClicked = GetMouseButtonClicked,
		GetMultiCastBarOffset = GetMultiCastBarOffset,
		GetPossessInfo = GetPossessInfo,
		HasAction = HasAction,

		-- Selected functions
		Dismount = Dismount,
		GetPVPTimer = GetPVPTimer,
		RandomRoll = RandomRoll,
		random = random,
		GetAddOnInfo = GetAddOnInfo,
		GetAddOnDependencies = GetAddOnDependencies,
		GetAddOnMetadata = GetAddOnMetadata,
		GetNumAddOns = GetNumAddOns,
		LoadAddOn = LoadAddOn,
		GetBinding = GetBinding,
		GetBindingAction = GetBindingAction,
		GetBindingKey = GetBindingKey,
		GetBindingText = GetBindingText,
		GetCurrentBindingSet = GetCurrentBindingSet,
		GetNumBindings = GetNumBindings,
		IsModifierKeyDown = IsModifierKeyDown,
		IsModifiedClick = IsModifiedClick,
		IsMouseButtonDown = IsMouseButtonDown,

		-- Camera
		CameraZoomIn = CameraZoomIn,
		CameraZoomOut = CameraZoomOut,
		FlipCameraYaw = FlipCameraYaw,
		IsMouselooking = IsMouselooking,
		MouselookStart = MouselookStart,
		MouselookStop = MouselookStop,
		MoveViewDownStart = MoveViewDownStart,
		MoveViewDownStop = MoveViewDownStop,
		MoveViewUpStart = MoveViewUpStart,
		MoveViewUpStop = MoveViewUpStop,
		MoveViewInStart = MoveViewInStart,
		MoveViewInStop = MoveViewInStop,
		MoveViewOutStart = MoveViewOutStart,
		MoveViewOutStop = MoveViewOutStop,
		MoveViewLeftStart = MoveViewLeftStart,
		MoveViewLeftStop = MoveViewLeftStop,
		MoveViewRightStart = MoveViewRightStart,
		MoveViewRightStop = MoveViewRightStop,
		NextView = NextView,
		PrevView = PrevView,
		ResetView = ResetView,
		SaveView = SaveView,
		SetView = SetView,
		GetChannelList = GetChannelList,
		GetChannelName = GetChannelName,
		GetChatWindowChannels = GetChatWindowChannels,
		JoinChannelByName = JoinChannelByName,
		LeaveChannelByName = LeaveChannelByName,
		ListChannels = ListChannels,
		--SendChatMessage = print, --is being overwritten in actionAPI

		ChatFrame_AddMessage = ChatFrame_AddMessage,
		ChatFrame_AddMessage = ChatFrame_AddMessage,
		ChannelToggleAnnouncements = ChannelToggleAnnouncements,
		AddChatWindowChannel = AddChatWindowChannel,
		GetMoney = GetMoney,
		GetCurrentTitle = GetCurrentTitle,
		GetNumTitles = GetNumTitles,
		GetPlayerFacing = GetPlayerFacing,
		GetTitleName = GetTitleName,
		GetUnitPitch = GetUnitPitch,
		HasFullControl = HasFullControl,
		IsFalling = IsFalling,
		IsFlying = IsFlying,
		IsFlyableArea = IsFlyableArea,
		IsIndoors = IsIndoors,
		IsMounted = IsMounted,
		IsOutdoors = IsOutdoors,
		IsOutOfBounds = IsOutOfBounds,
		IsResting = IsResting,
		IsStealthed = IsStealthed,
		IsSwimming = IsSwimming,
		IsTitleKnown = IsTitleKnown,
		NotWhileDeadError = NotWhileDeadError,
		SetCurrentTitle = SetCurrentTitle,
		GetAutoCompleteResults = GetAutoCompleteResults,
		GetChatTypeIndex = GetChatTypeIndex,
		GetChatWindowChannels = GetChatWindowChannels,
		GetChatWindowInfo = GetChatWindowInfo,
		GetChatWindowMessages = GetChatWindowMessages,
		JoinChannelByName = JoinChannelByName,
		LoggingChat = LoggingChat,
		LoggingCombat = LoggingCombat,
		GetDefaultLanguage = GetDefaultLanguage,
		GetLanguageByIndex = GetLanguageByIndex,
		GetNumLaguages = GetNumLanguages,
		SendAddonMessage = SendAddonMessage,
		DoEmote = GHI_DoEmote;

		CallCompanion = CallCompanion,
		DismissCompanion = DismissCompanion,
		GetCompanionInfo = GetCompanionInfo,
		GetNumCompanions = GetNumCompanions,
		GetCompanionCooldown = GetCompanionCooldown,
		PickupCompanion = PickupCompanion,
		SummonRandomCritter = SummonRandomCritter,

		-- Container 
		ContainerIDToInventoryID = ContainerIDToInventoryID,
		GetBagName = GetBagName,
		GetContainerItemCooldown = GetContainerItemCooldown,
		GetContainerItemDurability = GetContainerItemDurability,
		GetContainerItemInfo = GetContainerItemInfo,
		GetContainerItemLink = GetContainerItemLink,
		GetContainerNumFreeSlots = GetContainerNumFreeSlots,
		GetContainerNumSlots = GetContainerNumSlots,
		HasKey = HasKey,
		OpenAllBags = OpenAllBags,
		CloseAllBags = CloseAllBags,
		PickupContainerItem = PickupContainerItem,
		PutItemInBackpack = PutItemInBackpack,
		PutItemInBag = PutItemInBag,
		ToggleBackpack = ToggleBackpack,
		ToggleBag = ToggleBag,
		AutoEquipCursorItem = AutoEquipCursorItem,
		ClearCursor = ClearCursor,
		CursorCanGoInSlot = CursorCanGoInSlot,
		CursorHasItem = CursorHasItem,
		CursorHasMoney = CursorHasMacro,
		CursorHasSpell = CursorHasSpell,
		DropCursorMoney = DropCursorMoney,
		EquipCursorItem = EquipCursorItem,
		GetCursorInfo = GetCursorInfo,
		GetCursorMoney = GetCursorMoney,
		GetCursorPosition = GetCursorPosition,
		HideRepairCursor = HideRepairCursor,
		InRepairMode = InRepairMode,
		PickupContainerItem = PickupContainerItem,
		PickupInventoryItem = PickupInventoryItem,
		PickupMacro = PickupMacro,
		PickupItem = PickupItem,
		PutItemInBackpack = PutItemInBackpack,
		PutItemInBag = PutItemInBag,
		ResetCursor = ResetCursor,
		SetCursor = SetCursor,
		ShowInspectCursor = ShowInspectCursor,
		SplitContainerItem = SplitContainerItem,
		ConsoleAddMessage = ConsoleAddMessage,
		debugprofilestart = debugprofilestart,
		debugprofilestop = debugprofilestop,
		debugstack = debugstack,
		FrameXML_Debug = FrameXML_Debug,
		GetDebugStats = GetDebugStats,
		getprinthandler = getprinthandler,
		print = print,
		setprinthandler = setprinthandler,
		tostringall = tostringall,
		wipe = wipe,
		DressUpItemLink = DressUpItemLink,
		DressUpItem = DressUpItem,
		GetNumEquipmentSets = GetNumEquipmentSets,
		GetEquipmentSetInfo = GetEquipmentSetInfo,
		GetEquipmentSetInfoByName = GetEquipmentSetInfoByName,
		GetEquipmentSetItemIDs = GetEquipmentSetItemIDs,
		GetEquipmentSetLocations = GetEquipmentSetLocations,
		EquipmentManager_UnpackLocation = EquipmentManager_UnpackLocation,
		PickupEquipmentSet = PickupEquipmentSet,
		PickupEquipmentSetByName = PickupEquipmentSetByName,
		EquipmentSetContainsLockedItems = EquipmentSetContainsLockedItems,
		UseEquipmentSet = UseEquipmentSet,
		EquipmentManagerIgnoreSlotForsave = EquipmentManagerIgnoreSlotForsave,
		EquipmentManagerUnignoreSlotForSave = EquipmentManagerUnignoreSlotForSave,
		EquipmentManagerClearIgnoredSlotsForSave = EquipmentManagerClearIgnoredSlotsForSave,
		SaveEquipmentSet = SaveEquipmentSet,
		RenameEquipmentSet = RenameEquipmentSet,
		DeleteEquipmentSet = DeleteEquipmentSet,
		GetEquipmentSetIconInfo = GetEquipmentSetIconInfo,
		CreateFrame = CreateFrame,
		CreateFont = CreateFont,
		MouseIsOver = MouseIsOver,
		ToggleDropDownMenu = ToggleDropDownMenu,
		UIFrameFadeIn = UIFrameFadeIn,
		UIFrameFadeOut = UIFrameFadeOut,
		UIFrameFlash = UIFrameFlash,
		AddFriend = AddFriend,
		GetFriendInfo = GetFriendInfo,
		SetFriendNotes = SetFriendNotes,
		ShowFriends = ShowFriends,
		ToggleFriendsFrame = ToggleFriendsFrame,
		InviteUnit = InviteUnit,
		IsPartyLeader = IsPartyLeader,
		CanEditGuildEvent = CanEditGuildEvent,
		CanEditGuildInfo = CanEditGuildInfo,
		CanEditMOTD = CanEditMOTD,
		CanEditOfficerNote = CanEditOfficerNote,
		CanEditPublicNote = CanEditPublicNote,
		CanGuildDemote = CanGuildDemote,
		CanGuildInvite = CanGuildInvite,
		CanGuildPromote = CanGuildPromote,
		CanGuildRemove = CanGuildRemove,
		CanViewOfficerNote = CanViewOfficerNote,
		GetGuildEventInfo = GetGuildEventInfo,
		GetGuildInfo = GetGuildInfo,
		GetGuildInfoText = GetGuildInfoText,
		GetGuildRosterInfo = GetGuildRosterInfo,
		GetGuildRosterLastOnline = GetGuildRosterLastOnline,
		GetGuildRosterMOTD = GetGuildRosterMOTD,
		GetGuildRosterSelection = GetGuildRosterSelection,
		GetGuildRosterShowOffline = GetGuildRosterShowOffline,
		GetNumGuildEvents = GetNumGuildEvents,
		GetNumGuildMembers = GetNumGuildMembers,
		GetTabardInfo = GetTabardInfo,
		GuildInfo = GuildInfo,
		GuildRoster = GuildRoster,
		GuildRosterSetOfficerNote = GuildRosterSetOfficerNote,
		GuildRosterSetPublicNote = GuildRosterSetPublicNote,
		GuildSetMOTD = GuildSetMOTD,
		IsGuildLeader = IsGuildLeader,
		IsInGuild = IsInGuild,
		QueryGuildEventLog = QueryGuildEventLog,
		SetGuildInfoText = SetGuildInfoText,
		SetGuildRosterSelection = SetGuildRosterSelection,
		SetGuildRosterShowOffline = SetGuildRosterShowOffline,
		SortGuildRoster = SortGuildRoster,

		-- guild Bank 
		AutoStoreGuildBankItem = AutoStoreGuildBankItem,
		CanWithdrawGuildBankMoney = CanWithdrawGuildBankMoney,
		CloseGuildBankFrame = CloseGuildBankFrame,
		DepositGuildBankMoney = DepositGuildBankMoney,
		GetCurrentGuildBankTab = GetCurrentGuildBankTab,
		GetGuildBankItemInfo = GetGuildBankItemInfo,
		GetGuildBankItemLink = GetGuildBankItemLink,
		GetGuildBankMoney = GetGuildBankMoney,
		GetGuildBankMoneyTransaction = GetGuildBankMoneyTransaction,
		GetGuildBankTabInfo = GetGuildBankTabInfo,
		GetGuildBankTabPermissions = GetGuildBankTabPermissions,
		GetGuildBankTransaction = GetGuildBankTransaction,
		GetGuildTabardFileNames = GetGuildTabardFileNames,
		GetNumGuildBankMoneyTransactions = GetNumGuildBankMoneyTransactions,
		GetNumGuildBankTabs = GetNumGuildBankTabs,
		GetNumGuildBankTransactions = GetNumGuildBankTransactions,
		PickupGuildBankItem = PickupGuildBankItem,
		QueryGuildBankLog = QueryGuildBankLog,
		QueryGuildBankTab = QueryGuildBankTab,
		SetCurrentGuildBankTab = SetCurrentGuildBankTab,
		SetGuildBankTabInfo = SetGuildBankTabInfo,
		SetGuildBankTabPermissions = SetGuildBankTabPermissions,
		SplitGuildBankItem = SplitGuildBankItem,
		AddIgnore = AddIgnore,
		GetIgnoreName = GetIgnoreName,
		GetNumIgnores = GetNumIgnores,
		GetSelectedIgnore = GetSelectedIgnore,
		SetSelectedIgnore = SetSelectedIgnore,
		CanInspect = CanInspect,
		NotifyInspect = NotifyInspect,
		InspectUnit = InspectUnit,
		IsInInstance = IsInInstance,
		AutoEquipCursorItem = AutoEquipCursorItem,
		EquipCursorItem = EquipCursorItem,
		GetInventoryItemID = GetInventoryItemID,
		GetInventoryItemCount = GetInventoryItemCount,
		GetInventoryItemTexture = GetInventoryItemTexture,
		GetInventorySlotInfo = GetInventorySlotInfo,
		HasWandEquipped = HasWandEquipped,
		IsInventoryItemLocked = IsInventoryItemLocked,
		PickupInventoryItem = PickupInventoryItem,
		EquipItemByName = EquipItemByName,
		GetItemCount = GetItemCount,
		GetItemFamily = GetItemFamily,
		GetItemIcon = GetItemIcon,
		GetItemInfo = GetItemInfo,
		GetItemQualityColor = GetItemQualityColor,
		IsEquippedItem = IsEquippedItem,
		IsItemInRange = IsItemInRange,
		ItemHasRange = ItemHasRange,
		OffhandHasWeapon = OffhandHasWeapon,
		SplitContainerItem = SplitContainerItem,
		SetItemRef = SetItemRef,
		CloseItemText = CloseItemText,
		ItemTextGetCreator = ItemTextGetCreator,
		ItemTextGetItem = ItemTextGetItem,
		ItemTextGetMaterial = ItemTextGetMaterial,
		ItemTextGetPage = ItemTextGetPage,
		ItemTextGetText = ItemTextGetText,
		ItemTextHasNextPage = ItemTextHasNextPage,
		ItemTextNextPage = ItemTextNextPage,
		ItemTextPrevPage = ItemTextPrevPage,

		-- location
		GetMiniMapZoneText = GetMiniMapZoneText,
		GetRealZoneText = GetRealZoneText,
		GetSubZoneText = GetSubZoneText,
		GetZonePVPInfo = GetZonePVPInfo,
		GetZoneText = GetZoneText,

		-- map		
		GetCurrentMapContinent = GetCurrentMapContinent,
		GetCurrentMapDungeonLevel = GetCurrentMapDungeonLevel,
		GetNumDungeonMapLevels = GetNumDungeonMapLevels,
		GetCurrentMapAreaID = GetCurrentMapAreaID,
		GetCurrentMapZone = GetCurrentMapZone,
		GetMapContinents = GetMapContinents,
		GetMapInfo = GetMapInfo,
		GetMapLandmarkInfo = GetMapLandmarkInfo,
		GetMapOverlayInfo = GetMapOverlayInfo,
		GetMapZones = GetMapZones,
		GetNumMapLandmarks = GetNumMapLandmarks,
		GetNumMapOverlays = GetNumMapOverlays,
		GetPlayerMapPosition = GetPlayerMapPosition,
		ProcessMapClick = ProcessMapClick,
		RequestBattlefieldPositions = RequestBattlefieldPositions,
		SetDungeonMapLevel = SetDungeonMapLevel,
		SetMapByID = SetMapByID,
		SetMapToCurrentZone = SetMapToCurrentZone,
		SetMapZoom = SetMapZoom,
		SetupFullscreenScale = SetupFullscreenScale,
		UpdateMapHighlight = UpdateMapHighlight,
		ZoomOut = ZoomOut,
		FollowUnit = FollowUnit,
		GetAddOnCPUUsage = GetAddOnCPUUsage,
		GetAddOnMemoryUsage = GetAddOnMemoryUsage,
		GetEventCPUUsage = GetEventCPUUsage,
		GetFrameCPUUsage = GetFrameCPUUsage,
		GetFunctionCPUUsage = GetFunctionCPUUsage,
		GetScriptCPUUsage = GetScriptCPUUsage,
		ResetCPUUsage = ResetCPUUsage,
		UpdateAddOnCPUUsage = UpdateAddOnCPUUsage,
		UpdateAddOnMemoryUsage = UpdateAddOnMemoryUsage,
		InCombatLockdown = InCombatLockdown,
		GetCVar = GetCVar,
		GetCVarDefault = GetCVarDefault,
		GetCurrentResolution = GetCurrentResolution,
		GetGamma = GetGamma,
		GetScreenResolutions = GetScreenResolutions,
		SetScreenResolution = SetScreenResolution,
		ShowCloak = ShowCloak,
		ShowHelm = ShowHelm,
		ShowingCloak = ShowingCloak,
		ShowingHelm = ShowingHelm,
		ShowNumericThreat = ShowNumericThreat,
		GetBuildInfo = GetBuildInfo,
		GetExistingLocales = GetExistingLocales,
		GetFramerate = GetFramerate,
		GetGameTime = GetGameTime,
		GetLocale = GetLocale,
		GetCursorPosition = GetCursorPosition,
		GetNetStats = GetNetStats,
		GetRealmName = GetRealmName,
		GetScreenHeight = GetScreenHeight,
		GetScreenWidth = GetScreenWidth,
		GetText = GetText,
		GetTime = GetTime,
		IsAltKeyDown = IsAltKeyDown,
		IsControlKeyDown = IsControlKeyDown,
		IsDebugBuild = IsDebugBuild,
		IsLeftAltKeyDown = IsLeftAltKeyDown,
		IsLeftControlKeyDown = IsLeftControlKeyDown,
		IsLeftShiftKeyDown = IsLeftShiftKeyDown,
		IsLinuxClient = IsLinuxClient,
		IsLoggedIn = IsLoggedIn,
		IsMacClient = IsMacClient,
		IsRightAltKeyDown = IsRightAltKeyDown,
		IsRightControlKeyDown = IsRightControlKeyDown,
		IsRightShiftKeyDown = IsRightShiftKeyDown,
		IsShiftKeyDown = IsShiftKeyDown,
		IsWindowsClient = IsWindowsClient,
		PlayMusic = PlayMusic,
		PlaySound = PlaySound,
		PlaySoundFile = PlaySoundFile,
		ReloadUI = ReloadUI,
		Screenshot = Screenshot,
		SecondsToTime = SecondsToTime,
		SecondsToTimeAbbrev = SecondsToTimeAbbrev,
		StopMusic = StopMusic,
		TakeScreenshot = TakeScreenshot,
		message = message,
		ToggleMinimap = ToggleMinimap,
		ToggleFramerate = ToggleFramerate,
		ToggleFriendsFrame = ToggleFriendsFrame,
		GetNumTrackingTypes = GetNumTrackingTypes,
		GetTrackingTexture = GetTrackingTexture,
		GetTrackingInfo = GetTrackingInfo,
		SetTracking = SetTracking,

		-- unit functions 
		CheckInteractDistance = CheckInteractDistance,
		GetUnitName = GetUnitName,
		GetUnitSpeed = GetUnitSpeed,
		IsUnitOnQuest = IsUnitOnQuest,
		UnitAura = UnitAura,
		UnitBuff = UnitBuff,
		UnitClass = UnitClass,
		UnitClassification = UnitClassification,
		UnitCreatureFamily = UnitCreatureFamily,
		UnitCreatureType = UnitCreatureType,
		UnitDebuff = UnitDebuff,
		UnitExists = UnitExists,
		UnitFactionGroup = UnitFactionGroup,
		UnitGUID = UnitGUID,
		GetPlayerInfoByGUID = GetPlayerInfoByGUID,
		UnitInParty = UnitInParty,
		UnitInRange = UnitInRange,
		UnitIsAFK = UnitIsAFK,
		UnitIsConnected = UnitIsConnected,
		UnitIsCorpse = UnitIsCorpse,
		UnitIsDead = UnitIsDead,
		UnitIsDeadOrGhost = UnitIsDeadOrGhost,
		UnitIsDND = UnitIsDND,
		UnitIsEnemy = UnitIsEnemy,
		UnitIsFeignDeath = UnitIsFeignDeath,
		UnitIsFriend = UnitIsFriend,
		UnitIsGhost = UnitIsGhost,
		UnitIsPlayer = UnitIsPlayer,
		UnitIsSameServer = UnitIsSameServer,
		UnitIsTrivial = UnitIsTrivial,
		UnitIsUnit = UnitIsUnit,
		UnitIsVisible = UnitIsVisible,
		UnitLevel = UnitLevel,
		UnitMana = UnitMana,
		UnitName = UnitName,
		UnitPlayerControlled = UnitPlayerControlled,
		UnitPlayerOrPetInParty = UnitPlayerOrPetInParty,
		UnitPlayerOrPetInRaid = UnitPlayerOrPetInRaid,
		UnitPVPName = UnitPVPName,
		UnitPVPRank = UnitPVPRank,
		UnitRace = UnitRace,
		UnitReaction = UnitReaction,
		UnitSex = UnitSex,
		SetPortraitTexture = SetPortraitTexture,
		SetPortraitToTexture = SetPortraitToTexture,

		-- who
		GetNumWhoResults = GetNumWhoResults,
		GetWhoInfo = GetWhoInfo,
		SendWho = SendWho,
		SetWhoToUI = SetWhoToUI,
		SortWho = SortWho,

		-- fonts
		SystemFont_Tiny = SystemFont_Tiny,
		SystemFont_Small = SystemFont_Small,
		SystemFont_Outline_Small = SystemFont_Outline_Small,
		SystemFont_Outline = SystemFont_Outline,
		SystemFont_Shadow_Small = SystemFont_Shadow_Small,
		SystemFont_InverseShadow_Small = SystemFont_InverseShadow_Small,
		SystemFont_Med1 = SystemFont_Med1,
		SystemFont_Shadow_Med1 = SystemFont_Shadow_Med1,
		SystemFont_Med2 = SystemFont_Med2,
		SystemFont_Shadow_Med2 = SystemFont_Shadow_Med2,
		SystemFont_Med3 = SystemFont_Med3,
		SystemFont_Shadow_Med3 = SystemFont_Shadow_Med3,
		SystemFont_Large = SystemFont_Large,
		SystemFont_Shadow_Large = SystemFont_Shadow_Large,
		SystemFont_Huge1 = SystemFont_Huge1,
		SystemFont_Shadow_Huge1 = SystemFont_Shadow_Huge1,
		SystemFont_OutlineThick_Huge2 = SystemFont_OutlineThick_Huge2,
		SystemFont_Shadow_Outline_Huge2 = SystemFont_Shadow_Outline_Huge2,
		SystemFont_Shadow_Huge3 = SystemFont_Shadow_Huge3,
		SystemFont_OutlineThick_Huge4 = SystemFont_OutlineThick_Huge4,
		SystemFont_OutlineThick_WTF = SystemFont_OutlineThick_WTF,
		NumberFont_Shadow_Small = NumberFont_Shadow_Small,
		NumberFont_OutlineThick_Mono_Small = NumberFont_OutlineThick_Mono_Small,
		NumberFont_Shadow_Med = NumberFont_Shadow_Med,
		NumberFont_Outline_Med = NumberFont_Outline_Med,
		NumberFont_Outline_Large = NumberFont_Outline_Large,
		NumberFont_Outline_Huge = NumberFont_Outline_Huge,
		QuestFont_Large = QuestFont_Large,
		QuestFont_Shadow_Huge = QuestFont_Shadow_Huge,
		QuestFont_Shadow_Small = QuestFont_Shadow_Small,
		GameTooltipHeader = GameTooltipHeader,
		MailFont_Large = MailFont_Large,
		SpellFont_Small = SpellFont_Small,
		InvoiceFont_Med = InvoiceFont_Med,
		InvoiceFont_Small = InvoiceFont_Small,
		Tooltip_Med = Tooltip_Med,
		Tooltip_Small = Tooltip_Small,
		AchievementFont_Small = AchievementFont_Small,
		ReputationDetailFont = ReputationDetailFont,
		FriendsFont_Normal = FriendsFont_Normal,
		FriendsFont_Small = FriendsFont_Small,
		FriendsFont_Large = FriendsFont_Large,
		FriendsFont_UserText = FriendsFont_UserText,
		GameFont_Gigantic = GameFont_Gigantic,
		ChatFrame_AddMessageEventFilter = ChatFrame_AddMessageEventFilter,
		ChatTypeInfo = ChatTypeInfo,
		ChatFrame_RemoveMessageEventFilter = ChatFrame_RemoveMessageEventFilter,
		ChatFrame_GetMessageEventFilters = ChatFrame_GetMessageEventFilters,

		--RegisterAddonMessagePrefix = RegisterAddonMessagePrefix,

		AcceptGroup = AcceptGroup,
		ConfirmReadyCheck = ConfirmReadyCheck,
		ConvertToRaid = ConvertToRaid,
		DeclineGroup = DeclineGroup,
		DoReadyCheck = DoReadyCheck,
		GetLootMethod = GetLootMethod,
		GetLootThreshold = GetLootThreshold,
		GetMasterLootCandidate = GetMasterLootCandidate,
		GetNumPartyMembers = GetNumPartyMembers,
		GetRealNumPartyMembers = GetRealNumPartyMembers,
		GetPartyLeaderIndex = GetPartyLeaderIndex,
		GetPartyMember = GetPartyMember,
		InviteUnit = InviteUnit,
		IsPartyLeader = IsPartyLeader,
		LeaveParty = LeaveParty,
		PromoteToLeader = PromoteToLeader,
		SetLootMethod = SetLootMethod,
		SetLootThreshold = SetLootThreshold,
		UninviteUnit = UninviteUnit,
		UnitInParty = UnitInParty,
		UnitIsPartyLeader = UnitIsPartyLeader,
		StaticPopup_Show = StaticPopup_Show,
		StaticPopup_Hide = StaticPopup_Hide,

		GetItemCooldown = GetItemCooldown,
		GetBindLocation = GetBindLocation,
		GetProfessions = GetProfessions,
		GetProfessionInfo = GetProfessionInfo,
		GetSpellInfo = GetSpellInfo,
		GetNumGroupMembers = GetNumGroupMembers,
		GetRaidRosterInfo = GetRaidRosterInfo,

		ToggleSheath = ToggleSheath,
		CastSpellByName = CastSpellByName,
		GetTradeSkillListLink = GetTradeSkillListLink,
		CloseTradeSkill = CloseTradeSkill,
		ChatFrame_AddChannel = function(frame,...)
			if frame == class.GetValue("DEFAULT_CHAT_FRAME") then
				frame = DEFAULT_CHAT_FRAME; -- use the global DEFAULT_CHAT_FRAME instead of the mirror in the environment
			end
			ChatFrame_AddChannel(frame,...);
		end,
		
		C_PetJournal = C_PetJournal,

		-- ===========  GHI API ===============
		-- General
		GHI_Message = GHI_Message,
		GHI_ReloadUI = GHI_ReloadUI,
		GHI_ColorStrings = GHI_ColorStrings,
		GHI_PrintArray = GHI_PrintArray,

		-- Actionbar
		GHI_GetActionBarData = GHI_GetActionBarData,
		GHI_SetActionBarData = GHI_SetActionBarData,
		GHI_ShowAllActionbars = GHI_ShowAllActionbars,
		GHI_HideUnusedActionbars = GHI_HideUnusedActionbars,

		-- Book
		GHI_BookNextPage = GHI_BookNextPage,
		GHI_BookPrevPage = GHI_BookPrevPage,
		GHI_ShowBook = GHI_ShowBook,
		GHI_TranscribeTextItem = GHI_TranscribeTextItem,
		GHI_TranscribeMailboxLetter = GHI_TranscribeMailboxLetter,

		-- Buff
		ApplyGHIBuff = ApplyGHIBuff,
		RemoveGHIBuff = RemoveGHIBuff,
		RemoveAllGHIBuffs = RemoveAllGHIBuffs,
		CountGHIBuff = CountGHIBuff,
		GHI_GetDelayCastData = GHI_GetDelayCastData,

		-- Communication
		GHI_SendLink = GHI_SendLink,
		GHI_SendAreaEffect = GHI_SendAreaEffect,
		GHI_SendAreaBuff = GHI_SendAreaBuff,
		GHI_SendItemData = GHI_SendItemData,
		GHI_SendPing = GHI_SendPing,

		-- Container
		GHI_GetContainerInfo = GHI_GetContainerInfo,
		GHI_GetNumContainers = GHI_GetNumContainers,
		GHI_GetContainerList = GHI_GetContainerList,
		GHI_GetContainerSize = GHI_GetContainerSize,
		GHI_GetSlotList = GHI_GetSlotList,
		GHI_ToggleBackpack = GHI_ToggleBackpack,
		GHI_updateContainerFrameAnchors = GHI_updateContainerFrameAnchors,
		GHI_UpdateContainers = GHI_UpdateContainers,
		GHI_NextMainBagPage = GHI_NextMainBagPage,
		GHI_PrevMainBagPage = GHI_PrevMainBagPage,
		GHI_SelectSecBag = GHI_SelectSecBag,
		GHI_MaintainMainBags = GHI_MaintainMainBags,
		GHI_IsBagEmpty = GHI_IsBagEmpty,
		GHI_GetBagID = GHI_GetBagID,
		GHI_GetFreeSpace = GHI_GetFreeSpace,
		GHI_FindItem = GHI_FindItem,
		GHI_CountItem = GHI_CountItem,
		GHI_ProduceItem = GHI_ProduceItem,
		GHI_InsertItem = GHI_InsertItem,
		GHI_ConsumeItem = GHI_ConsumeItem,

		-- create item
		GHI_CreateItem = GHI_CreateItem,
		GHI_GetItemInfo = GHI_GetItemInfo,
		GHI_GetRightClickInfo = GHI_GetRightClickInfo,
		GHI_IsOfficialItem = GHI_IsOfficialItem,
		GHI_GetVersions = GHI_GetVersions,
		GHI_IsCopyable = GHI_IsCopyable,
		GHI_IsEditable = GHI_IsEditable,
		GHI_ClearItemCatche = GHI_ClearItemCatche,
		GHI_GenerateID = GHI_GenerateID,
		GHI_ExportItem = GHI_ExportItem,
		GHI_ImportItem = GHI_ImportItem,


		-- cursor
		GHI_SetCursor = GHI_SetCursor,
		GHI_ResetCursor = GHI_ResetCursor,
		GHI_GetCursor = GHI_GetCursor,
		GHI_GetCursorPreDetails = GHI_GetCursorPreDetails,
		GHI_AddExternalPreDetails = GHI_AddExternalPreDetails,



		-- display
		GHI_SetCustomSlotInfo = GHI_SetCustomSlotInfo,
		GHI_GetPlayerEquipmentDisplay = GHI_GetPlayerEquipmentDisplay,
		GHI_ShowPlayerEquipmentDisplay = GHI_ShowPlayerEquipmentDisplay,
		GHI_SetTargetEqDisplay = GHI_SetTargetEqDisplay,
		GHI_CopyTargetEqDisplay = GHI_CopyTargetEqDisplay,
		GHI_ToggleTargetEqDisplay = GHI_ToggleTargetEqDisplay,


		-- links
		GHI_GenerateLink = GHI_GenerateLink,

		-- use item
		GHI_UseItem = GHI_UseItem,
		GHI_GetCurrentItem = GHI_GetCurrentItem,
		--GHI_DoEmote = print, --Is overwritten in ActionAPI
		GHI_DoSay = GHI_DoSay,
		GHI_IsStdEmote = GHI_IsStdEmote,
		GHI_DoScript = function(code,delay,guid) return class.ExecuteScript(code,delay,guid); end,
		GHI_GetItemUseInfo = GHI_GetItemUseInfo,
		GHI_CheckReq = GHI_CheckReq,
		GHI_TooFarAway = GHI_TooFarAway,
		GHI_CantUseItem = GHI_CantUseItem,
		GHI_EffectColors = GHI_EffectColors,
		GHI_ColorList = GHI_ColorList,
		GHI_EffectFrame = GHI_EffectFrame,
		GHI_EffectFrameEffect1 = GHI_EffectFrameEffect1,
		GHI_EffectFrameEffect1Texture = GHI_EffectFrameEffect1Texture,
		GHI_EffectFrameEffect2 = GHI_EffectFrameEffect2,
		GHI_EffectFrameEffect2Texture = GHI_EffectFrameEffect2Texture,
		GHI_EffectFrameEffect3 = GHI_EffectFrameEffect3,
		GHI_EffectFrameEffect3Texture = GHI_EffectFrameEffect3Texture,
		GHI_EffectFrameEffect4 = GHI_EffectFrameEffect4,
		GHI_EffectFrameEffect4Texture = GHI_EffectFrameEffect4Texture,

		--GHI_ItemData = GHI_ItemData,
		--GHI_ContainerData = GHI_ContainerData,
		--GHI_TradeItemsRecipient = GHI_TradeItemsRecipient,
		UIParent = GHUIParent,
		GHI_ColorString = GHI_ColorString,
		GHI_MiscData = GHI_MiscData,
		WorldFrame = GHWorldFrame,

		-- add message
		DEFAULT_CHAT_FRAME = { AddMessage = function(self, ...) DEFAULT_CHAT_FRAME:AddMessage(...); end },
		SELECTED_CHAT_FRAME = { AddMessage = function(self, ...) SELECTED_CHAT_FRAME:AddMessage(...); end },
		ChatFrame1 = { AddMessage = function(self, ...) ChatFrame1:AddMessage(...); end },
		ChatFrame2 = { AddMessage = function(self, ...) ChatFrame2:AddMessage(...); end },
		ChatFrame3 = { AddMessage = function(self, ...) ChatFrame3:AddMessage(...); end },
		ChatFrame4 = { AddMessage = function(self, ...) ChatFrame4:AddMessage(...); end },
		ChatFrame5 = { AddMessage = function(self, ...) ChatFrame5:AddMessage(...); end },
		ChatFrame6 = { AddMessage = function(self, ...) ChatFrame6:AddMessage(...); end },
		UIErrorsFrame = { AddMessage = function(self, ...) UIErrorsFrame:AddMessage(...); end },
		EquipItem = EquipItem,
		GHI_GET_LOOT = loc.GET_LOOT,

		-- classes
		GHI_Timer = GHI_Timer,
		GHI_Comm = GHI_Comm,
		GHI_Position = GHI_Position,
		GHI_SlashCmd = GHI_SlashCmd,
		GHI_ChannelComm = GHI_ChannelComm,
		GHI_AreaBuff = GHI_AreaBuff,
		GHI_AreaSound = GHI_AreaSound,
		GHI_Save = function(index, var) --print("  save",index)
			if not (type(GHI_MiscData.ScriptSave) == "table") then
				GHI_MiscData.ScriptSave = {};
			end
			GHI_MiscData.ScriptSave[index] = var;
		end,
		GHI_Load = function(index) --  print("   load",index)
			return (GHI_MiscData.ScriptSave or {})[index];
		end,

		-- StaticPopupDialogs support
		StaticPopupDialogs = {},
		StaticPopup_Show = function(name)
			local popups = class.GetValue("StaticPopupDialogs");
			if name and popups[name] then
				StaticPopupDialogs[ownerGuid..name] = popups[name];
				StaticPopup_Show(ownerGuid..name)
			end
		end,
		StaticPopup_Hide = function(name)
			StaticPopup_Hide(ownerGuid..(name or ""))
		end
	}



	if type(GHI_MiscData["WhiteList"]) == "table" then
		for _, var in pairs(GHI_MiscData["WhiteList"]) do
			environment[var] = _G[var];
		end
	end

	 --[string "test ab"]:1: '=' expected near 'ab'
	local handleError = function(err,code,startHeader,atRuntime)
		local runtime = "";
		if atRuntime then runtime = "at runtime"; end
		local _,hLineCount = string.gsub(startHeader,"\n","\n")
		local area,line,errMsg = string.match(err,"^%[string \"(.*)\"%]:(%d*):(.*)$");
		print("Syntax error in GHI item",runtime);
		print(errMsg or err);
		if line then
			print("Line:",line-hLineCount-1);
			print("\n"..code)
		end

	end

	local headers = {};

	local Execute = function(code, headerGuid)
		if headers[headerGuid] then
			code = (headers[headerGuid].start or "").."\n" .. code .. (headers[headerGuid]._end or "");
		end

		-- Insert item guid, if present
		code = gsub(code,'"ITEM_ID"','(stack.GetItemGuid() or "nil")')

		local codeFunc, err = loadstring(code);
		if not (codeFunc) then
			handleError(err,code,headers[headerGuid].start,false);
			return
		end

		setfenv(codeFunc, environment); --print("Execute:\n"..code)
		local ok,ret1,ret2,ret3,ret4,ret5 =  pcall(codeFunc);
		if ok then
			return ret1,ret2,ret3,ret4,ret5;
		else
			local startHeader = "";
			if headerGuid then
				startHeader = headers[headerGuid].start;
			end
			handleError(ret1 or "nil",code or "nil",startHeader,true);
		end
		return;
	end

	GHI_Timer(function()
		for i, v in pairs(delayedScripts) do
			if type(v) == "table" and (v.time or 0) <= time() then
				Execute(v.code, v.headerGuid);
				delayedScripts[i] = nil;
			end
		end
	end, 1);



	class.ExecuteScript = function(code, delay, headerGuid)
		if type(delay) == "number" and delay > 0 then
			table.insert(delayedScripts, { code = code, time = time() + delay, headerGuid = headerGuid });
			return
		end
		return Execute(code, headerGuid);
	end



	environment.DoScript = environment.GHI_DoScript;

	environment._G = environment;

	class.SetValue = function(name, val)
		GHCheck("GHI_ScriptEnviroment.SetValue", { "string", "any" }, { name, val });
		local codeFunc = function() _G[name] = val end;
		setfenv(codeFunc, environment);
		return codeFunc();
	end

	class.GetValue = function(name)
		GHCheck("GHI_ScriptEnviroment.GetValue", { "string" }, { name });
		local codeFunc = function() return _G[name]; end;
		setfenv(codeFunc, environment);
		return codeFunc();
	end


	class.GetAllValues = function(search)

		local codeFunc = function()
			local t = {};
			local len = strlen(search);
			for i, v in pairs(_G) do
				if strsub(i, 0, len) == search then
					t[i] = v;
				end
			end
			return t;
		end;
		setfenv(codeFunc, environment);
		return codeFunc();
	end

	local apiHandlers = {
		GHI_ActionAPI(),
		GHI_MiscAPI(),
		GHI_ContainerAPI(),
		GHI_GameWorldData(),
		GHI_ClassAPI(),
		GHI_CreateItemAPI(),
	}
	for _, handler in pairs(apiHandlers) do
		local api = handler.GetAPI(class);
		for i, v in pairs(api) do
			class.SetValue(i, v);
		end
	end


	class.SetHeaderApi = function(guid, headerCode, endCode)
		headers[guid] = { start = headerCode, _end = endCode };
	end

	class.GotHeaderApi = function(guid)
		if headers[guid] then return true; end
	end

	class.GetOwner = function()
		return ownerGuid;
	end

	return class;
end


