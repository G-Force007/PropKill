/*---------------------------------------------------------
   Name: sh_scoreboard.lua
   Desc: This is the scoreboard :) Does everything it needs to do.
   Author: G-Force Connections (STEAM_0:1:19084184)
---------------------------------------------------------*/

if SERVER then

	AddCSLuaFile( "scoreboard/admin_buttons.lua" )
	AddCSLuaFile( "scoreboard/cl_tooltips.lua" )
	AddCSLuaFile( "scoreboard/player_frame.lua" )
	AddCSLuaFile( "scoreboard/player_infocard.lua" )
	AddCSLuaFile( "scoreboard/player_row.lua" )
	AddCSLuaFile( "scoreboard/scoreboard.lua" )
	
else
	include( "scoreboard/scoreboard.lua" )

	SuiScoreBoard = nil
	
	timer.Simple( 1.5, function()
		
		function GAMEMODE:CreateScoreboard()
		
			if ( ScoreBoard ) then
			
				ScoreBoard:Remove()
				ScoreBoard = nil
				
			end
			
			SuiScoreBoard = vgui.Create( "suiscoreboard" )
			
			return true

		end

		function GAMEMODE:ScoreboardShow()
		
			if not SuiScoreBoard then
				self:CreateScoreboard()
			end

			GAMEMODE.ShowScoreboard = true
			gui.EnableScreenClicker( true )

			SuiScoreBoard:SetVisible( true )
			SuiScoreBoard:UpdateScoreboard( true )
			
			return true

		end
		
		function GAMEMODE:ScoreboardHide()
		
			GAMEMODE.ShowScoreboard = false
			gui.EnableScreenClicker( false )

			SuiScoreBoard:SetVisible( false )
			
			return true
			
		end
		
	end )
end