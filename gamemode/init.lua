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
AddCSLuaFile( "cl_dermaskin.lua" )
AddCSLuaFile( "sh_init.lua" )
AddCSLuaFile( "sh_scoreboard.lua" )
AddCSLuaFile( "sh_teams.lua" )

include( "sh_teams.lua" ) -- sh_teams needs to be loaded before sh_init.lua
include( "sh_init.lua" )
include( "sv_commands.lua" )
include( "sv_misc.lua" )
include( "sv_data.lua" )
include( "sv_player.lua" )
include( "sh_scoreboard.lua" )
include( "sv_entity.lua" )
include( "sv_achievements.lua" )
include( "sv_networking.lua")

----------------------------------------------------------
--					FastDL 								--
----------------------------------------------------------

resource.AddFile( "materials/gui/silkicons/emoticon_smile.vmt" )
resource.AddFile( "materials/gui/silkicons/exclamation.vmt" )
resource.AddFile( "materials/gui/silkicons/heart.vmt" )
resource.AddFile( "materials/gui/silkicons/palette.vmt" )
resource.AddFile( "materials/gui/silkicons/star.vmt" )
resource.AddFile( "materials/gui/silkicons/user.vmt" )
resource.AddFile( "materials/gui/silkicons/wrench.vmt" )
	
----------------------------------------------------------
--					Default Commands					--
----------------------------------------------------------

RunConsoleCommand( "g_ragdoll_maxcount", 0 )
RunConsoleCommand( "prop_active_gib_limit", 1 )
RunConsoleCommand( "prop_active_gib_max_fade_time", 1 )
RunConsoleCommand( "props_break_max_pieces", 0 )
RunConsoleCommand( "props_break_max_pieces_perframe", 0 )

--RunConsoleCommand( "sbox_maxprops", 10 )
--RunConsoleCommand( "sbox_noclip", 0 )
--RunConsoleCommand( "sbox_godmode", 0 )
--RunConsoleCommand( "sbox_plpldamage", 0 )

function GM:ShutDown()
	Msg( "PKv2: Saving stats...\n" )
	file.Write( "propkill/sscores.txt", util.TableToJSON( PK.Scores ) )
    Msg( "PKv2: Saved player stats...\n" )

    Msg( "PKv2: Saving prop spawns...\n" )
	file.Write( "propkill/propspawns.txt", util.TableToJSON( PK.PropSpawns ) )
	Msg( "PKv2: Saved prop spawns...\n" )

	Msg( "PKv2: Completed saving gamemode...\n" )

	Msg( "PKv2: Successfully shut down/changed level, your files have been saved.\n" )
end


Msg( [[/==================================================/
GPropKill v]], PK.Version, [[ loaded Successfully
Coded By G-Force Connections (STEAM_0:1:19084184)
/==================================================/
]] )