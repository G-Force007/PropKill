include( "admin_buttons.lua" )

local PANEL = {}

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:Init()

	self.InfoLabels = {}
	self.InfoLabels[ 1 ] = {}
	self.InfoLabels[ 2 ] = {}
	self.InfoLabels[ 3 ] = {}
	
	self.btnKick = vgui.Create( "suiplayerkickbutton", self )
	self.btnBan = vgui.Create( "suiplayerbanbutton", self )
	self.btnPBan = vgui.Create( "suiplayerpermbanbutton", self )

end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/

surface.CreateFont( "suiscoreboardcardinfo",{font="DefaultSmall", size=12, weight=0, antialiasing=true})
function PANEL:SetInfo( column, k )

	--if ( !v || v == "" ) then v = "N/A" end

	if ( !self.InfoLabels[ column ][ k ] ) then
	
		self.InfoLabels[ column ][ k ] = {}
		self.InfoLabels[ column ][ k ].Key 	= vgui.Create( "DLabel", self )
		--self.InfoLabels[ column ][ k ].Value 	= vgui.Create( "DLabel", self )
		self.InfoLabels[ column ][ k ].Key:SetText( k )
		self.InfoLabels[ column ][ k ].Key:SetColor(Color(0,0,0,255))
		self.InfoLabels[ column ][ k ].Key:SetFont("suiscoreboardcardinfo")
		self:InvalidateLayout()
	
	end
	
	--self.InfoLabels[ column ][ k ].Value:SetText( v )
	--self.InfoLabels[ column ][ k ].Value:SetColor(Color(0,0,0,255))
	--self.InfoLabels[ column ][ k ].Value:SetFont("suiscoreboardcardinfo")
	return true

end


/*---------------------------------------------------------
   Name: UpdatePlayerData
---------------------------------------------------------*/
function PANEL:SetPlayer( ply )

	self.Player = ply
	self:UpdatePlayerData()

end

/*---------------------------------------------------------
   Name: UpdatePlayerData
---------------------------------------------------------*/
function PANEL:UpdatePlayerData()
	if not self.Player then return end
	if not self.Player:IsValid() then return end
	if not self.Player.Achievements then self.Player.Achievements = {} end
	
	self:SetInfo( 1, Format( "Lost leader %i time(s)", self.Player.Achievements.LostLeader or 0 ) )
	self:SetInfo( 1, Format( "Killed %i leader(s)", self.Player.Achievements.LeaderKills or 0 ) )
	self:SetInfo( 1, Format( "Became leader %i time(s)", self.Player.Achievements.BecameLeader or 0  ) )
	self:SetInfo( 1, Format( "Killed themself %i time(s)", self.Player.Achievements.SelfKills or 0 ) )
	self:SetInfo( 1, Format( "Killed %i player(s) while in mid-air", self.Player.Achievements.OffFloor or 0 ) )
	self:SetInfo( 1, Format( "Longshotted %i player(s)", self.Player.Achievements.LongShots or 0 ) )
	self:SetInfo( 1, Format( "Won %i fight(s), Lost %i fight(s)", self.Player.Achievements.FightsWon or 0, self.Player.Achievements.FightsLost or 0 ) )
	
	self:InvalidateLayout()

end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:ApplySchemeSettings()
	for _k, column in pairs( self.InfoLabels ) do
		for k, v in pairs( column ) do
				--v.Key:SetFGColor( 50, 50, 50, 255 )
				v.Key:SetFGColor( 80, 80, 80, 255 )	
		end
	
	end

end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:Think()

	if ( self.PlayerUpdate && self.PlayerUpdate > CurTime() ) then return end
	self.PlayerUpdate = CurTime() + 0.25
	
	self:UpdatePlayerData()

end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:PerformLayout()	

	local x = 10

	for column, column in pairs( self.InfoLabels ) do
	
		local y = 0
		local RightMost = 0
	
		for k, v in pairs( column ) do
	
			v.Key:SetPos( x, y )
			v.Key:SizeToContents()
			
			--v.Value:SetPos( x + 60 , y )
			--v.Value:SizeToContents()
			
			y = y + v.Key:GetTall() + 2
			
			RightMost = math.max( RightMost, v.Key.x + v.Key:GetWide() )
		
		end
		
		//x = RightMost + 10
		if(x<100) then
		x = x + 205
		else
		x = x + 115
		end
	
	end
	
	if ( !self.Player or self.Player == LocalPlayer() or !LocalPlayer():IsAdmin() ) then 
		self.btnKick:SetVisible( false )
		self.btnBan:SetVisible( false )
		self.btnPBan:SetVisible( false )
	
	else
	
		self.btnKick:SetVisible( true )
		self.btnBan:SetVisible( true )
		self.btnPBan:SetVisible( true )
	
		self.btnKick:SetPos( self:GetWide() - 175, 85 - (22 * 2) )
		self.btnKick:SetSize( 46, 20 )

		self.btnBan:SetPos( self:GetWide() - 175, 85 - (22 * 1) )
		self.btnBan:SetSize( 46, 20 )
		
		self.btnPBan:SetPos( self:GetWide() - 175, 85 - (22 * 0) )
		self.btnPBan:SetSize( 46, 20 )
	
	end
	
end

function PANEL:Paint(w,h)
	return true
end


vgui.Register( "suiscoreplayerinfocard", PANEL, "Panel" )