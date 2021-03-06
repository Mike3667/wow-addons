--[[
	frame.lua
		A specialized version of the bagnon frame for void storages
--]]

local Bagnon = LibStub('AceAddon-3.0'):GetAddon('Bagnon')
local Frame = Bagnon:NewClass('VaultFrame', 'Frame', Bagnon.Frame)


--[[ Events ]]--

function Frame:OnShow()
	PlaySound('UI_EtherealWindow_Open')

	self:UpdateLook()
	self:UpdateEvents()
	self:RegisterMessage('SHOW_TRANSFER_FRAME')
	self:RegisterMessage('SHOW_ITEM_FRAME')
	self:SHOW_ITEM_FRAME()
end

function Frame:OnHide()
	PlaySound('UI_EtherealWindow_Close')
	StaticPopup_Hide('BAGNON_CANNOT_PURCHASE_VAULT')
	StaticPopup_Hide('BAGNON_COMFIRM_TRANSFER')
	StaticPopup_Hide('BAGNON_VAULT_PURCHASE')
	StaticPopup_Hide('VOID_DEPOSIT_CONFIRM')
	CloseVoidStorageFrame()

	self:UpdateEvents()
	self:SendMessage('VOID_STORAGE_CLOSED')

	--fix issue where a frame is hidden, but not via bagnon controlled methods (ie, close on escape)
	if self:IsFrameShown() then
		self:HideFrame()
	end
end


--[[ Messages ]]--

function Frame:SHOW_TRANSFER_FRAME()
	self:FadeFrames()
	self:FadeInFrame(self:GetTransferFrame())
	
	local dialog = StaticPopup_Show('BAGNON_COMFIRM_TRANSFER')
	dialog.data = self
end

function Frame:SHOW_ITEM_FRAME()
	self:FadeFrames()
	self:FadeInFrame(self:GetItemFrame())
end

function Frame:FadeFrames()
	self:FadeOutFrame(self.transferFrame)
	self:FadeOutFrame(self.itemFrame)
end


--[[ Transfer Frame ]]--

function Frame:CreateTransferFrame()
	local item = self:GetItemFrame()
	local frame = Bagnon.TransferFrame:New(self:GetFrameID(), self)
	frame:SetAllPoints(item)
	
	self.transferFrame = frame
	return frame
end

function Frame:GetTransferFrame()
	return self.transferFrame or self:CreateTransferFrame()
end


--[[ Other Components ]]--

function Frame:CreateItemFrame()
	local f = Bagnon.VaultItemFrame:New(self:GetFrameID(), self, 'vault')
	self.itemFrame = f
	return f
end

function Frame:CreateMoneyFrame()
	local f = Bagnon.TransferButton:New(self:GetFrameID(), self)
	self.moneyFrame = f
	return f
end

function Frame:PlaceBrokerDisplayFrame()
	if self:HasBrokerDisplay() then
		local frame = self:GetBrokerDisplay() or self:CreateBrokerDisplay()
		frame:ClearAllPoints()
		frame:SetPoint('BOTTOMLEFT', self, 'BOTTOMLEFT', 16, 20)

		if self:HasMoneyFrame() then
			frame:SetPoint('RIGHT', self:GetMoneyFrame(), 'LEFT', -8, 10)
		else
			frame:SetPoint('BOTTOMRIGHT', self, 'BOTTOMRIGHT', -8, 20)
		end

		frame:Show()
		return frame:GetWidth(), 24
	end

	local frame = self:GetBrokerDisplay()
	if frame then
		frame:Hide()
	end
	return 0, 0
end

function Frame:HasBagFrame()
	return nil
end