include( "player_infocard.lua" )

local texGradient = surface.GetTextureID( "gui/center_gradient" )

local texRatings = {}
texRatings[ 'none' ] 		= surface.GetTextureID( "gui/silkicons/user" )
texRatings[ 'smile' ] 		= surface.GetTextureID( "gui/silkicons/emoticon_smile" )
texRatings[ 'lol' ] 		= surface.GetTextureID( "gui/silkicons/emoticon_smile" )
texRatings[ 'gay' ] 		= surface.GetTextureID( "gui/gmod_logo" )
texRatings[ 'stunter' ] 	= surface.GetTextureID( "gui/inv_corner16" )
texRatings[ 'god' ] 		= surface.GetTextureID( "gui/gmod_logo" )
texRatings[ 'curvey' ] 		= surface.GetTextureID( "gui/corner16" )
texRatings[ 'best_landvehicle' ]	= surface.GetTextureID( "gui/faceposer_indicator" )
texRatings[ 'best_airvehicle' ] 		= surface.GetTextureID( "gui/arrow" )
texRatings[ 'naughty' ] 	= surface.GetTextureID( "gui/silkicons/exclamation" )
texRatings[ 'friendly' ]	= surface.GetTextureID( "gui/silkicons/user" )
texRatings[ 'informative' ]	= surface.GetTextureID( "gui/info" )
texRatings[ 'love' ] 		= surface.GetTextureID( "gui/silkicons/heart" )
texRatings[ 'artistic' ] 	= surface.GetTextureID( "gui/silkicons/palette" )
texRatings[ 'gold_star' ] 	= surface.GetTextureID( "gui/silkicons/star" )
texRatings[ 'builder' ] 	= surface.GetTextureID( "gui/silkicons/wrench" )

surface.GetTextureID( "gui/silkicons/emoticon_smile" )
local PANEL = {}


/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:Paint(w,h)

	local color = Color( 100, 100, 100, 255 )

	if ( self.Armed ) then
		color = Color( 125, 125, 125, 255 )
	end
	
	if ( self.Selected ) then
		color = Color( 125, 125, 125, 255 )
	end
	
	if ( self.Player:Team() == TEAM_CONNECTING ) then
		color = Color( 100, 100, 100, 155 )
	elseif ( self.Player:IsValid() ) then
		//if ( team.GetName(self.Player:Team() ) == Unassigned) then
		if ( tostring(self.Player:Team()) == tostring("1001") ) then
			color = Color( 100, 100, 100, 255 )
		else	
			tcolor = team.GetColor(self.Player:Team())
			color = Color(tcolor.r,tcolor.g,tcolor.b,225)
			
		end
	elseif ( self.Player:IsAdmin() ) then
		color = Color( 255, 155, 0, 255 )
	end
	
	if ( self.Player == LocalPlayer() ) then
	
		tcolor = team.GetColor(self.Player:Team())
		color = Color(tcolor.r,tcolor.g,tcolor.b,255)
	
	end

	if ( self.Open || self.Size != self.TargetSize ) then
	
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
	
	//surface.SetTexture( self.texRating )
	//surface.SetDrawColor( 255, 255, 255, 255 )
	//surface.DrawTexturedRect( 20, 4, 16, 16 ) 
	
	return true

end

/*---------------------------------------------------------
   Name: SetPlayer
---------------------------------------------------------*/
function PANEL:SetPlayer( ply )

	self.Player = ply
	
	self.infoCard:SetPlayer( ply )
	
	self:UpdatePlayerData()
	
	self.imgAvatar:SetPlayer( ply )

end

/*---------------------------------------------------------
   Name: UpdatePlayerData
---------------------------------------------------------*/
function PANEL:UpdatePlayerData()

	if ( !self.Player ) then return end
	if ( !self.Player:IsValid() ) then return end

	self.lblName:SetText( self.Player:Nick() )
	self.lblName:SizeToContents()	
	self.lblTeam:SetText( team.GetName(self.Player:Team()) )
	self.lblTeam:SizeToContents()	
	self.lblFrags:SetText( self.Player:Frags() )
	self.lblDeaths:SetText( self.Player:Deaths() )
	self.lblSFrags:SetText( self.Player:GetGNWVar( "kills", 0 ) )
	self.lblSDeaths:SetText( self.Player:GetGNWVar( "deaths", 0 ) )
	self.lblPing:SetText( self.Player:Ping() )

	    local k = self.Player:Frags()
                        local d = self.Player:Deaths()
                        local kdr = "--   "
                        if d != 0 then
                           kdr = k/d
                           local y,z = math.modf(kdr)
                           z = string.sub(z, 1, 5)
                           if y != 0 then kdr = string.sub(y+z,1,5) else kdr =  z end
                           kdr = kdr .. ":1"
						   if k == 0 then kdr = k .. ":" .. d end
                        end

	self.lblRatio:SetText( kdr ) 
end

/*---------------------------------------------------------
   Name: Init
---------------------------------------------------------*/
function PANEL:Init()

	self.Size = 38
	self:OpenInfo( false )
	
	self.infoCard	= vgui.Create( "suiscoreplayerinfocard", self )
	
	self.lblName 	= vgui.Create( "DLabel", self )
	self.lblTeam 	= vgui.Create( "DLabel", self )
	self.lblFrags 	= vgui.Create( "DLabel", self )
	self.lblDeaths 	= vgui.Create( "DLabel", self )
	self.lblSFrags 	= vgui.Create( "DLabel", self )
	self.lblSDeaths = vgui.Create( "DLabel", self )
	self.lblRatio 	= vgui.Create( "DLabel", self )
	self.lblPing 	= vgui.Create( "DLabel", self )
	
	// If you don't do this it'll block your clicks
	self.lblName:SetMouseInputEnabled( false )
	self.lblTeam:SetMouseInputEnabled( false )
	self.lblFrags:SetMouseInputEnabled( false )
	self.lblDeaths:SetMouseInputEnabled( false )
	self.lblSFrags:SetMouseInputEnabled( false )
	self.lblSDeaths:SetMouseInputEnabled( false )
	self.lblRatio:SetMouseInputEnabled( false )
	self.lblPing:SetMouseInputEnabled( false )
	
	self.imgAvatar = vgui.Create("AvatarImage", self)

end

/*---------------------------------------------------------
   Name: ApplySchemeSettings
---------------------------------------------------------*/
function PANEL:ApplySchemeSettings()

	self.lblName:SetFont( "SuiScoreboardPlayerName" )
	self.lblTeam:SetFont( "SuiScoreboardPlayerName" )
	self.lblFrags:SetFont( "SuiScoreboardPlayerName" )
	self.lblDeaths:SetFont( "SuiScoreboardPlayerName" )
	self.lblSFrags:SetFont( "SuiScoreboardPlayerName" )
	self.lblSDeaths:SetFont( "SuiScoreboardPlayerName" )
	self.lblRatio:SetFont( "SuiScoreboardPlayerName" )
	self.lblPing:SetFont( "SuiScoreboardPlayerName" )
	
	local namecolor = Color(0,0,0,255)
	
	self.lblName:SetColor( namecolor )
	self.lblTeam:SetColor( namecolor )
	self.lblFrags:SetColor( namecolor )
	self.lblDeaths:SetColor( namecolor )
	self.lblSFrags:SetColor( namecolor )
	self.lblSDeaths:SetColor( namecolor )
	self.lblRatio:SetColor( namecolor )
	self.lblPing:SetColor( namecolor )
	
	self.lblName:SetFGColor( Color( 0, 0, 0, 255 ) )
	self.lblTeam:SetFGColor( Color( 0, 0, 0, 255 ) )
	self.lblFrags:SetFGColor( Color( 0, 0, 0, 255 ) )
	self.lblDeaths:SetFGColor( Color( 0, 0, 0, 255 ) )
	self.lblSFrags:SetFGColor( Color( 0, 0, 0, 255 ) )
	self.lblSDeaths:SetFGColor( Color( 0, 0, 0, 255 ) )
	self.lblRatio:SetFGColor( Color( 0, 0, 0, 255 ) )
	self.lblPing:SetFGColor( Color( 0, 0, 0, 255 ) )

end

/*---------------------------------------------------------
   Name: DoClick
---------------------------------------------------------*/
function PANEL:DoClick()

	if ( self.Open ) then
		surface.PlaySound( "ui/buttonclickrelease.wav" )
	else
		surface.PlaySound( "ui/buttonclick.wav" )
	end

	self:OpenInfo( !self.Open )

end

/*---------------------------------------------------------
   Name: OpenInfo
   ---------------------------------------------------------*/
function PANEL:OpenInfo( bool )

	if ( bool ) then
		self.TargetSize = 154
	else
		self.TargetSize = 38     //*********************************************
	end
	
	self.Open = bool

end

/*---------------------------------------------------------
   Name: Think
---------------------------------------------------------*/
function PANEL:Think()

	if ( self.Size != self.TargetSize ) then
	
		self.Size = math.Approach( self.Size, self.TargetSize, (math.abs( self.Size - self.TargetSize ) + 1) * 10 * FrameTime() )
		self:PerformLayout()
		SCOREBOARD:InvalidateLayout()
	//	self:GetParent():InvalidateLayout()
	
	end
	
	if ( !self.PlayerUpdate || self.PlayerUpdate < CurTime() ) then
	
		self.PlayerUpdate = CurTime() + 0.5
		self:UpdatePlayerData()
		
	end

end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:PerformLayout()

	self:SetSize( self:GetWide(), self.Size )        //***************************************************************************
	
	self.lblName:SizeToContents()
	self.lblName:SetPos( 60, 3 )
	self.lblTeam:SizeToContents()	
	
	self.imgAvatar:SetPos( 21, 4 ) 
 	self.imgAvatar:SetSize( 32, 32 )
	//self.lblRatio:SizeToContents()
	local COLUMN_SIZE = 45
	
	self.lblPing:SetPos( self:GetWide() - COLUMN_SIZE * 1, 0 )
	self.lblRatio:SetPos( self:GetWide() - COLUMN_SIZE * 2.6, 0 )
	self.lblDeaths:SetPos( self:GetWide() - COLUMN_SIZE * 3.8, 0 )
	self.lblFrags:SetPos( self:GetWide() - COLUMN_SIZE * 4.8, 0 )
	self.lblSDeaths:SetPos( self:GetWide() - COLUMN_SIZE * 7, 0 )
	self.lblSFrags:SetPos( self:GetWide() - COLUMN_SIZE * 8.8, 0 )
	self.lblTeam:SetPos( self:GetWide() - COLUMN_SIZE * 12.2, 3 )
	
	if ( self.Open || self.Size != self.TargetSize ) then
	
		self.infoCard:SetVisible( true )
		self.infoCard:SetPos( 18, self.lblName:GetTall() + 27 )
		self.infoCard:SetSize( self:GetWide() - 36, self:GetTall() - self.lblName:GetTall() + 5 )
	
	else
	
		self.infoCard:SetVisible( false )
	
	end
	
	

end

/*---------------------------------------------------------
   Name: HigherOrLower
---------------------------------------------------------*/
function PANEL:HigherOrLower( row )

	if ( self.Player:Team() == TEAM_CONNECTING ) then return false end
	if ( row.Player:Team() == TEAM_CONNECTING ) then return true end
	
	if ( self.Player:Team() ~= row.Player:Team() ) then
		return self.Player:Team() < row.Player:Team()
	end
	
	if ( self.Player:Frags() == row.Player:Frags() ) then
	
		return self.Player:Deaths() < row.Player:Deaths()
	
	end

	return self.Player:Frags() > row.Player:Frags()

end


vgui.Register( "suiscoreplayerrow", PANEL, "Button" )