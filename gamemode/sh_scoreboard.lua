/*---------------------------------------------------------
   Name: sh_scoreboard.lua
   Desc: This is the scoreboard :) Does everything it needs to do.
   Author: G-Force Connections (STEAM_0:1:19084184)
---------------------------------------------------------*/

Scoreboard = {}

if SERVER then
	-- Add to the pool
	util.AddNetworkString("SUIScoreboardPlayerColor")

	-- Send required files to client
	AddCSLuaFile("scoreboard/scoreboard.lua")
	AddCSLuaFile("scoreboard/admin_buttons.lua")
	AddCSLuaFile("scoreboard/tooltips.lua")
	AddCSLuaFile("scoreboard/player_frame.lua")
	AddCSLuaFile("scoreboard/player_infocard.lua")
	AddCSLuaFile("scoreboard/player_row.lua")
	AddCSLuaFile("scoreboard/scoreboard.lua")
	AddCSLuaFile("scoreboard/library.lua")
	AddCSLuaFile("scoreboard/net_client.lua")

	Scoreboard.SendColor = function (ply)
	if evolve == nil then
			tColor = team.GetColor( ply:Team() )      
		else
			tColor = evolve.ranks[ ply:EV_GetRank() ].Color
		end

		net.Start("SUIScoreboardPlayerColor")
		net.WriteTable(tColor)
		net.Send(ply)
	end

	--- When the player joins the server we need to restore the NetworkedInt's
	Scoreboard.PlayerSpawn = function ( ply )
		Scoreboard.SendColor(ply)
	end
else
	Scoreboard.vgui = nil
	Scoreboard.playerColor = Color(255, 155, 0, 255)
	include( "scoreboard/library.lua" )
	include( "scoreboard/scoreboard.lua" )
	include( "scoreboard/net_client.lua" )

	 timer.Simple( 1.5, function()
		function GAMEMODE:CreateScoreboard()
			if Scoreboard.vgui then
				Scoreboard.vgui:Remove()
				Scoreboard.vgui = nil
			end

			Scoreboard.vgui = vgui.Create( "suiscoreboard" )

			return true
		end

		function GAMEMODE:ScoreboardShow()
			if not Scoreboard.vgui then
				self:CreateScoreboard()
			end

			GAMEMODE.ShowScoreboard = true
			gui.EnableScreenClicker( true )

			Scoreboard.vgui:SetVisible( true )
			Scoreboard.vgui:UpdateScoreboard( true )

			return true
		end

		function GAMEMODE:ScoreboardHide()
			GAMEMODE.ShowScoreboard = false
			gui.EnableScreenClicker( false )

			Scoreboard.vgui:SetVisible( false )

			return true
		end
	end )
end