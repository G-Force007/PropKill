/*---------------------------------------------------------
   Name: init.lua
   Desc: Includes everything, does everything. The gamemode DEPENDS on this.
   Author: G-Force Connections (STEAM_0:1:19084184)
---------------------------------------------------------*/

PK = PK or {}

DeriveGamemode( "sandbox" )

----------------------------------------------------------
--					Including Files						--
----------------------------------------------------------

-- Doesn't need to be in order.
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_vgui.lua" )
AddCSLuaFile( "cl_hud.lua" )
AddCSLuaFile( "cl_networking.lua" )
AddCSLuaFile( "sh_init.lua" )
AddCSLuaFile( "sh_scoreboard.lua" )
AddCSLuaFile( "sh_teams.lua" )

include( "sh_teams.lua" ) -- sh_teams needs to be loaded before sh_init.lua
include( "sh_init.lua" )
include( "sv_commands.lua" )
include( "sv_data.lua" )
include( "sv_misc.lua" )
include( "sv_player.lua" )
include( "sh_scoreboard.lua" )
include( "sv_entity.lua" )
include( "sv_achievements.lua" )
include( "sv_networking.lua")
	
----------------------------------------------------------
--					Default Commands					--
----------------------------------------------------------

RunConsoleCommand( "g_ragdoll_maxcount", 0 )
RunConsoleCommand( "prop_active_gib_limit", 1 )
RunConsoleCommand( "prop_active_gib_max_fade_time", 1 )
RunConsoleCommand( "props_break_max_pieces", 0 )
RunConsoleCommand( "props_break_max_pieces_perframe", 0 )

RunConsoleCommand( "sbox_maxprops", 10 )
RunConsoleCommand( "sbox_noclip", 0 )
RunConsoleCommand( "sbox_godmode", 0 )

function GM:ShutDown()
	self:Msg( "Saving stats..." )
	file.Write( "propkill/sscores.txt", util.TableToJSON( PK.Scores ) )
    self:Msg( "Saved player stats..." )

    self:Msg( "Saving prop spawns..." )
	file.Write( "propkill/propspawns.txt", util.TableToJSON( PK.PropSpawns ) )
	self:Msg( "Saved prop spawns..." )

	self:Msg( "Completed saving gamemode..." )

	self:Msg( "Successfully shut down/changed level, your files have been saved." )
end


Msg( [[/==================================================/
GPropKill v]], PK.Version, [[ loaded Successfully
Coded By G-Force Connections (STEAM_0:1:19084184)
/==================================================/
]] )