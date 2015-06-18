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

include( "player_infocard.lua" )

local texGradient = surface.GetTextureID( "gui/center_gradient" )

local PANEL = {}

--- Paint
function PANEL:Paint(w,h)
	local color = Color( 100, 100, 100, 255 )

	if self.Armed then
		color = Color( 125, 125, 125, 255 )
	end
	
	if self.Selected then
		color = Color( 125, 125, 125, 255 )
	end
	
	if self.Player:IsValid() then
		if self.Player:Team() == TEAM_CONNECTING then
			color = Color( 100, 100, 100, 155 )
		elseif self.Player:IsValid() then
			if self.Player:Team() == TEAM_UNASSIGNED then
				color = Color( 100, 100, 100, 255 )
			else	
			  if evolve == nil then
				  tcolor = team.GetColor(self.Player:Team())
				  color = Color(tcolor.r,tcolor.g,tcolor.b,225)				
				else
				 tcolor = evolve.ranks[ ply:EV_GetRank() ].Color
				 color = Color(tcolor.r,tcolor.g,tcolor.b,225)
				end
			end
		elseif self.Player:IsAdmin() then
			color = Color( 255, 155, 0, 255 )
		end
		
		if self.Player == LocalPlayer() then		
        if evolve == nil then
          tcolor = team.GetColor(self.Player:Team())
          color = Color(tcolor.r,tcolor.g,tcolor.b,225)       
        else
         tcolor = evolve.ranks[ self.Player:EV_GetRank() ].Color
         color = Color(tcolor.r,tcolor.g,tcolor.b,225)
        end
		end	
	end

	if self.Open or self.Size ~= self.TargetSize then	
		draw.RoundedBox( 4, 18, 16, self:GetWide()-36, self:GetTall() - 16, color )
		draw.RoundedBox( 4, 20, 16, self:GetWide()-40, self:GetTall() - 16 - 2, Color( 225, 225, 225, 150 ) )
		
		surface.SetTexture( texGradient )
		surface.SetDrawColor( 255, 255, 255, 100 )
		surface.DrawTexturedRect( 20, 16, self:GetWide()-40, self:GetTall() - 16 - 2 ) 	
	end
	
	draw.RoundedBox( 4, 18, 0, self:GetWide()-36, 38, color )
	
	surface.SetTexture( texGradient )
	surface.SetDrawColor( 255, 255, 255, 150 )
	surface.DrawTexturedRect( 0, 0, self:GetWide()-36, 38 ) 
		
	return true
end

--- SetPlayer
function PANEL:SetPlayer( ply )
	self.Player = ply	
	self.infoCard:SetPlayer( ply )	
	self:UpdatePlayerData()	
	self.imgAvatar:SetPlayer( ply )
end

--- UpdatePlayerData
function PANEL:UpdatePlayerData()
	if not self.Player:IsValid() then 
		return false
	end

	self.lblName:SetText( self.Player:Nick() )
	self.lblFrags:SetText( self.Player:Frags() )
	self.lblDeaths:SetText( self.Player:Deaths() )
	self.lblSFrags:SetText( self.Player:GetGNWVar( "kills", 0 ) )
	self.lblSDeaths:SetText( self.Player:GetGNWVar( "deaths", 0 ) )
	self.lblPing:SetText( self.Player:Ping() )
	
	-- Change the icon of the mute button based on state
	if  self.Muted == nil or self.Muted ~= self.Player:IsMuted() then
		self.Muted = self.Player:IsMuted()
		if self.Muted then
			self.lblMute:SetImage( "icon32/muted.png" )
		else
			self.lblMute:SetImage( "icon32/unmuted.png" )
		end

		self.lblMute.DoClick = function() self.Player:SetMuted( not self.Muted ) end
	end	

    local k = self.Player:Frags()
    local d = self.Player:Deaths()
    local kdr = "--   "
    
	if d ~= 0 then
		kdr = k/d
		local y,z = math.modf(kdr)
		z = string.sub(z, 1, 5)
		
		if y ~= 0 then
			kdr = string.sub(y+z,1,5)
		else
			kdr =  z
		end
		
		kdr = kdr .. ":1"		
		if k == 0 then 
			kdr = k .. ":" .. d
		end
	end

	self.lblRatio:SetText( kdr )
end

--- Int
function PANEL:Init()
	self.Size = 38
	self:OpenInfo( false )	
	self.infoCard = vgui.Create( "suiscoreplayerinfocard", self )
	
	self.lblName = vgui.Create( "DLabel", self )
	self.lblFrags = vgui.Create( "DLabel", self )
	self.lblDeaths = vgui.Create( "DLabel", self )
	self.lblSFrags = vgui.Create( "DLabel", self )
	self.lblSDeaths = vgui.Create( "DLabel", self )
	self.lblRatio = vgui.Create( "DLabel", self )
	self.lblPing = vgui.Create( "DLabel", self )
	self.lblMute = vgui.Create( "DImageButton", self)
	self.imgAvatar = vgui.Create("AvatarImage", self)
	self.lblAvatarFix = vgui.Create( "DLabel", self )
	self.lblAvatarFix:SetText("")
	self.lblAvatarFix:SetCursor( "hand" )
	self.lblAvatarFix.DoClick = function  () self.Player:ShowProfile() end
	
	-- If you don't do this it'll block your clicks
	self.lblName:SetMouseInputEnabled( false )
	self.lblFrags:SetMouseInputEnabled( false )
	self.lblDeaths:SetMouseInputEnabled( false )
	self.lblSFrags:SetMouseInputEnabled( false )
	self.lblSDeaths:SetMouseInputEnabled( false )
	self.lblRatio:SetMouseInputEnabled( false )
	self.lblPing:SetMouseInputEnabled( false )
	self.imgAvatar:SetMouseInputEnabled( false )
	self.lblMute:SetMouseInputEnabled( true )
	self.lblAvatarFix:SetMouseInputEnabled( true )
end

--- ApplySchemeSettings
function PANEL:ApplySchemeSettings()
	self.lblName:SetFont( "suiscoreboardplayername" )
	self.lblFrags:SetFont( "suiscoreboardplayername" )
	self.lblDeaths:SetFont( "suiscoreboardplayername" )
	self.lblSFrags:SetFont( "suiscoreboardplayername" )
	self.lblSDeaths:SetFont( "suiscoreboardplayername" )
	self.lblRatio:SetFont( "suiscoreboardplayername" )
	self.lblPing:SetFont( "suiscoreboardplayername" )
	self.lblAvatarFix:SetFont( "suiscoreboardplayername" ) 
	
	local namecolor = Color(0,0,0,255)
	
	self.lblName:SetColor( namecolor )
	self.lblFrags:SetColor( namecolor )
	self.lblDeaths:SetColor( namecolor )
	self.lblSFrags:SetColor( namecolor )
	self.lblSDeaths:SetColor( namecolor )
	self.lblRatio:SetColor( namecolor )
	self.lblPing:SetColor( namecolor)
	self.lblAvatarFix:SetColor( namecolor)
	
	self.lblName:SetFGColor( Color( 0, 0, 0, 255 ) )
	self.lblFrags:SetFGColor( Color( 0, 0, 0, 255 ) )
	self.lblDeaths:SetFGColor( Color( 0, 0, 0, 255 ) )
	self.lblSFrags:SetFGColor( Color( 0, 0, 0, 255 ) )
	self.lblDeaths:SetFGColor( Color( 0, 0, 0, 255 ) )
	self.lblRatio:SetFGColor( Color( 0, 0, 0, 255 ) )
	self.lblPing:SetFGColor( Color( 0, 0, 0, 255 ) )
	self.lblAvatarFix:SetFGColor( Color( 0, 0, 0, 0 ) )
end

--- DoClick
function PANEL:DoClick()
	if self.Open then
		surface.PlaySound( "ui/buttonclickrelease.wav" )
	else
		surface.PlaySound( "ui/buttonclick.wav" )
	end

	self:OpenInfo( not self.Open )
end

--- OpenInfo
function PANEL:OpenInfo( bool )
	if bool then
		self.TargetSize = 154
	else
		self.TargetSize = 38
	end

	self.Open = bool
end

--- Think
function PANEL:Think()
	if not IsValid( self.Player ) then
		for k, v in pairs( Scoreboard.vgui.PlayerRows ) do	
			if not k:IsValid() then		
				v:Remove()
				Scoreboard.vgui.PlayerRows[ k ] = nil			
			end	
		end

		Scoreboard.vgui:PerformLayout()
		Scoreboard.vgui:InvalidateLayout()

		return
	end

	if self.Size ~= self.TargetSize then	
		self.Size = math.Approach( self.Size, self.TargetSize, (math.abs( self.Size - self.TargetSize ) + 1) * 10 * FrameTime() )
		self:PerformLayout()
		Scoreboard.vgui:InvalidateLayout()
	end
	
	if not self.PlayerUpdate or self.PlayerUpdate < CurTime() then	
		self.PlayerUpdate = CurTime() + 0.5
		self:UpdatePlayerData()		
	end
end

--- PerformLayout
function PANEL:PerformLayout()
	self:SetSize( self:GetWide(), self.Size ) 
	
	self.lblName:SizeToContents()
	self.lblName:SetPos( 60, 3 )
	self.lblMute:SetSize( 32, 32 )
	
	self.imgAvatar:SetPos( 21, 4 ) 
 	self.imgAvatar:SetSize( 32, 32 )
 	self.lblAvatarFix:SetPos( 21, 4 ) 
 	self.lblAvatarFix:SetSize( 32, 32 )

	local COLUMN_SIZE = 45
	
	self.lblMute:SetPos( self:GetWide() - COLUMN_SIZE - 8, 0 )
	self.lblPing:SetPos( self:GetWide() - COLUMN_SIZE * 2, 0 )
	self.lblRatio:SetPos( self:GetWide() - COLUMN_SIZE * 3.4, 0 )
	self.lblDeaths:SetPos( self:GetWide() - COLUMN_SIZE * 4.4, 0 )
	self.lblFrags:SetPos( self:GetWide() - COLUMN_SIZE * 5.4, 0 )
	self.lblSFrags:SetPos( self:GetWide() - COLUMN_SIZE * 8.8, 0 )
	self.lblSDeaths:SetPos( self:GetWide() - COLUMN_SIZE * 7, 0 )
	
	if self.Open or self.Size ~= self.TargetSize then	
		self.infoCard:SetVisible( true )
		self.infoCard:SetPos( 18, self.lblName:GetTall() + 27 )
		self.infoCard:SetSize( self:GetWide() - 36, self:GetTall() - self.lblName:GetTall() + 5 )	
	else	
		self.infoCard:SetVisible( false )	
	end
end

--- HigherOrLower
function PANEL:HigherOrLower( row )
	if self.Player:Team() == TEAM_CONNECTING then 
		return false
	end

	if self.Player:Team() ~= row.Player:Team() then
		return self.Player:Team() > row.Player:Team()
	end
	
	if self.Player:Frags() == row.Player:Frags() then	
		return self.Player:Deaths() < row.Player:Deaths()	
	end

	return self.Player:Frags() > row.Player:Frags()
end

vgui.Register( "suiscoreplayerrow", PANEL, "Button" )