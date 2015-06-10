include( "player_row.lua" )
include( "player_frame.lua" )

surface.CreateFont( "suiscoreboardheader", {font="coolvetica", size=28, weight=100, antialiasing=true})
surface.CreateFont( "suiscoreboardsubtitle", {font="coolvetica", size=20, weight=100, antialiasing=true})
surface.CreateFont( "suiscoreboardlogotext", {font="coolvetica", size=75, weight=100, antialiasing=true})
surface.CreateFont( "suiscoreboardsuisctext", {font="verdana"   , size=12, weight=100, antialiasing=true})
surface.CreateFont( "SuiScoreboardPlayerName", {font = "verdana", size = 16, weight = 5, antialiasing = true})

local texGradient 	= surface.GetTextureID( "gui/center_gradient" )

local function ColorCmp( c1, c2 )
	if( !c1 || !c2 ) then return false end
	
	return (c1.r == c2.r) && (c1.g == c2.g) && (c1.b == c2.b) && (c1.a == c2.a)
end

local PANEL = {}

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:Init()

	SCOREBOARD = self

	self.Hostname = vgui.Create( "DLabel", self )
	self.Hostname:SetText( GetHostName() )

	self.Logog = vgui.Create( "DLabel", self )
	self.Logog:SetText( "g" )

	self.SuiSc = vgui.Create( "DLabel", self )
	self.SuiSc:SetText( "sui_scoreboard V2 by Suicidal.Banana" )
	
	self.Description = vgui.Create( "DLabel", self )
	self.Description:SetText( GAMEMODE.Name .. " - " .. GAMEMODE.Author )
	
	self.PlayerFrame = vgui.Create( "suiplayerframe", self )
	
	self.PlayerRows = {}

	self:UpdateScoreboard()
	
	// Update the scoreboard every 1 second
	timer.Create( "SuiScoreboardUpdater", 1, 0, self.UpdateScoreboard )
	
	self.lblPing = vgui.Create( "DLabel", self )
	self.lblPing:SetText( "Ping" )
	
	self.lblKills = vgui.Create( "DLabel", self )
	self.lblKills:SetText( "Kills" )
	
	self.lblDeaths = vgui.Create( "DLabel", self )
	self.lblDeaths:SetText( "Deaths" )
	
	self.lblSKills = vgui.Create( "DLabel", self )
	self.lblSKills:SetText( "Total Kills" )
	
	self.lblSDeaths = vgui.Create( "DLabel", self )
	self.lblSDeaths:SetText( "Total Deaths" )

	self.lblRatio = vgui.Create( "DLabel", self )
	self.lblRatio:SetText( "Ratio" )

	self.lblTeam = vgui.Create( "DLabel", self )
	self.lblTeam:SetText( "Team" )

end

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:AddPlayerRow( ply )

	local button = vgui.Create( "suiscoreplayerrow", self.PlayerFrame:GetCanvas() )
	button:SetPlayer( ply )
	self.PlayerRows[ ply ] = button

end

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:GetPlayerRow( ply )

	return self.PlayerRows[ ply ]

end

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:Paint(w,h)

	draw.RoundedBox( 10, 0, 0, self:GetWide(), self:GetTall(), Color( 50, 50, 50, 205 ) )
	surface.SetTexture( texGradient )
	surface.SetDrawColor( 100, 100, 100, 155 )
	surface.DrawTexturedRect( 0, 0, self:GetWide(), self:GetTall() ) 
	
	// White Inner Box
	draw.RoundedBox( 6, 15, self.Description.y - 8, self:GetWide() - 30, self:GetTall() - self.Description.y - 6, Color( 230, 230, 230, 100 ) )
	surface.SetTexture( texGradient )
	surface.SetDrawColor( 255, 255, 255, 50 )
	surface.DrawTexturedRect( 15, self.Description.y - 8, self:GetWide() - 30, self:GetTall() - self.Description.y - 8 )
	
	// Sub Header
	draw.RoundedBox( 6, 108, self.Description.y - 4, self:GetWide() - 128, self.Description:GetTall() + 8, Color( 100, 100, 100, 155 ) )
	surface.SetTexture( texGradient )
	surface.SetDrawColor( 255, 255, 255, 50 )
	surface.DrawTexturedRect( 108, self.Description.y - 4, self:GetWide() - 128, self.Description:GetTall() + 8 ) 
	
	// Logo!
	if( ColorCmp( team.GetColor(21), Color( 255, 255, 100, 255 ) ) ) then
		tColor = Color( 255, 155, 0, 255 )
	else
  		tColor = team.GetColor(21) 		
 	end
	
	if (tColor.r < 255) then
		tColorGradientR = tColor.r + 15
	else 
		tColorGradientR = tColor.r
	end
	if (tColor.g < 255) then
		tColorGradientG = tColor.g + 15
	else 
		tColorGradientG = tColor.g
	end
	if (tColor.b < 255) then
		tColorGradientB = tColor.b + 15
	else 
		tColorGradientB = tColor.b
	end
	draw.RoundedBox( 8, 24, 12, 80, 80, Color( tColor.r, tColor.g, tColor.b, 200 ) )
	surface.SetTexture( texGradient )
	surface.SetDrawColor( tColorGradientR, tColorGradientG, tColorGradientB, 225 )
	surface.DrawTexturedRect( 24, 12, 80, 80 ) 
	
	
	
	//draw.RoundedBox( 4, 10, self.Description.y + self.Description:GetTall() + 6, self:GetWide() - 20, 12, Color( 0, 0, 0, 50 ) )

end


/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:PerformLayout()

	self:SetSize( ScrW() * 0.75, ScrH() * 0.65 )
	
	self:SetPos( (ScrW() - self:GetWide()) / 2, (ScrH() - self:GetTall()) / 2 )
	
	self.Hostname:SizeToContents()
	self.Hostname:SetPos( 115, 17 )
	
	self.Logog:SetSize( 80, 80 )
	self.Logog:SetPos( 45, 5 )
	self.Logog:SetColor( Color(30, 30, 30, 255) )

	self.SuiSc:SetSize( 400, 15 )
	self.SuiSc:SetPos( (self:GetWide() - 220), (self:GetTall() - 15) )
	
	self.Description:SizeToContents()
	self.Description:SetPos( 115, 60 )
	self.Description:SetColor( Color(30, 30, 30, 255) )
	
	self.PlayerFrame:SetPos( 5, self.Description.y + self.Description:GetTall() + 20 )
	self.PlayerFrame:SetSize( self:GetWide() - 10, self:GetTall() - self.PlayerFrame.y - 20 )
	
	local y = 0
	
	local PlayerSorted = {}
	
	for k, v in pairs( self.PlayerRows ) do
	
		table.insert( PlayerSorted, v )
		
	end
	
	table.sort( PlayerSorted, function ( a , b) return a:HigherOrLower( b ) end )
	
	for k, v in ipairs( PlayerSorted ) do
	
		v:SetPos( 0, y )	
		v:SetSize( self.PlayerFrame:GetWide(), v:GetTall() )
		
		self.PlayerFrame:GetCanvas():SetSize( self.PlayerFrame:GetCanvas():GetWide(), y + v:GetTall() )
		
		y = y + v:GetTall() + 1
	
	end
	
	self.Hostname:SetText( GetGlobalString( "ServerName", "Garry's Mod 13" ) )
	
	self.lblPing:SizeToContents()
	self.lblKills:SizeToContents()
	self.lblRatio:SizeToContents()
	self.lblSKills:SizeToContents()
	self.lblSDeaths:SizeToContents()
	self.lblDeaths:SizeToContents()
	self.lblTeam:SizeToContents()
	
	self.lblPing:SetPos( self:GetWide() - 45 - self.lblPing:GetWide()/2, self.PlayerFrame.y - self.lblPing:GetTall() - 3  )
	self.lblRatio:SetPos( self:GetWide() - 45*2.4 - self.lblDeaths:GetWide()/2, self.PlayerFrame.y - self.lblPing:GetTall() - 3  )
	self.lblDeaths:SetPos( self:GetWide() - 45*3.8 - self.lblDeaths:GetWide()/2, self.PlayerFrame.y - self.lblPing:GetTall() - 3  )
	self.lblKills:SetPos( self:GetWide() - 45*4.8 - self.lblKills:GetWide()/2, self.PlayerFrame.y - self.lblPing:GetTall() - 3  )
	self.lblSDeaths:SetPos( self:GetWide() - 45*7 - self.lblDeaths:GetWide()/2, self.PlayerFrame.y - self.lblPing:GetTall() - 3  )
	self.lblSKills:SetPos( self:GetWide() - 45*8.8 - self.lblKills:GetWide()/2, self.PlayerFrame.y - self.lblPing:GetTall() - 3  )
	self.lblTeam:SetPos( self:GetWide() - 45*12.2 - self.lblKills:GetWide()/2, self.PlayerFrame.y - self.lblPing:GetTall() - 3  )
	
	//self.lblKills:SetFont( "DefaultSmall" )
	//self.lblDeaths:SetFont( "DefaultSmall" )

end

/*---------------------------------------------------------
   Name: ApplySchemeSettings
---------------------------------------------------------*/
function PANEL:ApplySchemeSettings()

	self.Hostname:SetFont( "suiscoreboardheader" )
	self.Description:SetFont( "suiscoreboardsubtitle" )
	self.Logog:SetFont( "suiscoreboardlogotext" )
	self.SuiSc:SetFont( "suiscoreboardsuisctext" )
	
	if (ColorCmp( team.GetColor(21), Color( 255, 255, 100, 255 ))) then
		tColor = Color( 255, 155, 0, 255 )
	else
  		tColor = team.GetColor(21) 		
 	end 
	
	self.Hostname:SetFGColor( Color( tColor.r, tColor.g, tColor.b, 255 ) )
	self.Description:SetFGColor( Color( 55, 55, 55, 255 ) )
	self.Logog:SetFGColor( Color( 0, 0, 0, 255 ) )
	self.SuiSc:SetFGColor( Color( 200, 200, 200, 200 ) )
	
	self.lblPing:SetFont( "DefaultSmall" )
	self.lblKills:SetFont( "DefaultSmall" )
	self.lblDeaths:SetFont( "DefaultSmall" )
	self.lblSKills:SetFont( "DefaultSmall" )
	self.lblSDeaths:SetFont( "DefaultSmall" )
	self.lblTeam:SetFont( "DefaultSmall" )
	self.lblRatio:SetFont( "DefaultSmall" )
	
	self.lblPing:SetColor( Color( 0, 0, 0, 255 ) )
	self.lblKills:SetColor( Color( 0, 0, 0, 255 ) )
	self.lblDeaths:SetColor( Color( 0, 0, 0, 255 ) )
	self.lblSKills:SetColor( Color( 0, 0, 0, 255 ) )
	self.lblSDeaths:SetColor( Color( 0, 0, 0, 255 ) )
	self.lblTeam:SetColor( Color( 0, 0, 0, 255 ) )
	self.lblRatio:SetColor( Color( 0, 0, 0, 255 ) )
	
	self.lblPing:SetFGColor( Color( 0, 0, 0, 255 ) )
	self.lblKills:SetFGColor( Color( 0, 0, 0, 255 ) )
	self.lblDeaths:SetFGColor( Color( 0, 0, 0, 255 ) )
	self.lblSKills:SetFGColor( Color( 0, 0, 0, 255 ) )
	self.lblSDeaths:SetFGColor( Color( 0, 0, 0, 255 ) )
	self.lblTeam:SetFGColor( Color( 0, 0, 0, 255 ) )
	self.lblRatio:SetFGColor( Color( 0, 0, 0, 255 ) )

end


function PANEL:UpdateScoreboard( force )
if self then 
	if ( !force and !self:IsVisible() ) then return end

	for k, v in pairs( self.PlayerRows ) do
	
		if ( !k:IsValid() ) then
		
			v:Remove()
			self.PlayerRows[ k ] = nil
			
		end
	
	end
	
	local PlayerList = player.GetAll()	
	for id, pl in pairs( PlayerList ) do
		
		if ( !self:GetPlayerRow( pl ) ) then
		
			self:AddPlayerRow( pl )
		
		end
		
	end
	
	// Always invalidate the layout so the order gets updated
	self:InvalidateLayout()
end
end

vgui.Register( "suiscoreboard", PANEL, "Panel" )