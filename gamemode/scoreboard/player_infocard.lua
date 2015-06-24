--[[

SUI Scoreboard v2.6 by .Z. Nexus is licensed under a Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
----------------------------------------------------------------------------------------------------------------------------
Copyright (c) 2014 .Z. Nexus <http://www.nexusbr.net> <http://steamcommunity.com/profiles/76561197983103320>

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/deed.en_US.
----------------------------------------------------------------------------------------------------------------------------
This Addon is based on the original SUI Scoreboard v2 developed by suicidal.banana.
Copyright only on the code that I wrote, my implementation and fixes and etc, The Initial version (v2) code still is from suicidal.banana.
----------------------------------------------------------------------------------------------------------------------------

$Id$
Version 2.6.2 - 12-06-2014 05:33 PM(UTC -03:00)

]]--

include( "admin_buttons.lua" )

local PANEL = {}

surface.CreateFont(  "suiscoreboardcardinfo", { font = "DefaultSmall", size = 12, weight = 0, antialiasing = true} )

--- Init
function PANEL:Init()
	self.InfoLabels = {}
	self.InfoLabels[ 1 ] = {}
	self.InfoLabels[ 2 ] = {}
	self.InfoLabels[ 3 ] = {}

	self.btnReset = vgui.Create( "suiplayerresetbutton", self )
	self.btnReset2 = vgui.Create( "suiplayerreset2button", self )
	self.btnKick = vgui.Create( "suiplayerkickbutton", self )
	self.btnBan = vgui.Create( "suiplayerbanbutton", self )
	self.btnPBan = vgui.Create( "suiplayerpermbanbutton", self )
end

--- SetInfo
function PANEL:SetInfo( column, k, v )
	if !self.InfoLabels[ column ][ k ] then
		self.InfoLabels[ column ][ k ] = {}
		self.InfoLabels[ column ][ k ].Key 	= vgui.Create( "DLabel", self )

		self.InfoLabels[ column ][ k ].Key:SetText( k )
		self.InfoLabels[ column ][ k ].Key:SetColor(Color(0,0,0,255))
		self.InfoLabels[ column ][ k ].Key:SetFont("suiscoreboardcardinfo")
		self:InvalidateLayout()
	end

	return true
end

--- SetPlayer
function PANEL:SetPlayer( ply )
	self.Player = ply
	self:UpdatePlayerData()
end

--- UpdatePlayerData
function PANEL:UpdatePlayerData()
	if not self.Player then return end
	if not self.Player:IsValid() then return end
	if not self.Player.Achievements then return end
	
	self:SetInfo( 1, Format( "Lost leader %i time(s)", self.Player.Achievements.LostLeader or 0 ) )
	self:SetInfo( 1, Format( "Killed %i leader(s)", self.Player.Achievements.LeaderKills or 0 ) )
	self:SetInfo( 1, Format( "Became leader %i time(s)", self.Player.Achievements.BecameLeader or 0  ) )
	self:SetInfo( 1, Format( "Killed themself %i time(s)", self.Player.Achievements.SelfKills or 0 ) )
	self:SetInfo( 1, Format( "Killed %i player(s) while in mid-air", self.Player.Achievements.OffFloor or 0 ) )
	self:SetInfo( 1, Format( "Longshotted %i player(s)", self.Player.Achievements.LongShots or 0 ) )
	self:SetInfo( 1, Format( "Won %i fight(s), Lost %i fight(s)", self.Player.Achievements.FightsWon or 0, self.Player.Achievements.FightsLost or 0 ) )
	
	self:InvalidateLayout()
end

--- ApplySchemeSettings
function PANEL:ApplySchemeSettings()
	for _k, column in pairs( self.InfoLabels ) do
		for k, v in pairs( column ) do
			v.Key:SetFGColor( 80, 80, 80, 255 )
		end	
	end
end

--- Think
function PANEL:Think()
	if self.PlayerUpdate and self.PlayerUpdate > CurTime() then return end
	self.PlayerUpdate = CurTime() + 0.25
	
	self:UpdatePlayerData()
end

--- PerformLayout
function PANEL:PerformLayout()	
	local x = 5

	for column, column in pairs( self.InfoLabels ) do
	
		local y = 0
		local RightMost = 0
	
		for k, v in pairs( column ) do	
			v.Key:SetPos( x, y )
			v.Key:SizeToContents()
			
			y = y + v.Key:GetTall() + 2
			
			RightMost = math.max( RightMost, v.Key.x + v.Key:GetWide() )		
		end
		
		if x<100 then
			x = x + 205
		else
			x = x + 115
		end	
	end
	
	if not LocalPlayer():IsAdmin() then
		self.btnReset:SetVisible( false )
		self.btnReset2:SetVisible( false )
		self.btnKick:SetVisible( false )
		self.btnBan:SetVisible( false )
		self.btnPBan:SetVisible( false )	
	else
		if ulx then
			self.btnReset:SetVisible( true )
			self.btnReset2:SetVisible( true )
		end
		self.btnKick:SetVisible( true )
		self.btnBan:SetVisible( true )
		self.btnPBan:SetVisible( true )

		self.btnReset:SetPos( self:GetWide() - 85, 85 - (22 * 4) )
		self.btnReset:SetSize( 80, 20 )

		self.btnReset2:SetPos( self:GetWide() - 85, 85 - (22 * 3) )
		self.btnReset2:SetSize( 80, 20 )
	
		self.btnKick:SetPos( self:GetWide() - 85, 85 - (22 * 2) )
		self.btnKick:SetSize( 80, 20 )

		self.btnBan:SetPos( self:GetWide() - 85, 85 - (22 * 1) )
		self.btnBan:SetSize( 80, 20 )
		
		self.btnPBan:SetPos( self:GetWide() - 85, 85 - (22 * 0) )
		self.btnPBan:SetSize( 80, 20 )	

		self.btnReset.DoClick = function() Scoreboard.reset( self.Player ) end
		self.btnReset2.DoClick = function() Scoreboard.reset2( self.Player ) end
		self.btnKick.DoClick = function () Scoreboard.kick( self.Player ) end
		self.btnPBan.DoClick = function () Scoreboard.pBan( self.Player ) end
		self.btnBan.DoClick = function () Scoreboard.ban( self.Player ) end		
	end
end

--- Paint
function PANEL:Paint(w,h)
	return true
end

vgui.Register( "suiscoreplayerinfocard", PANEL, "Panel" )