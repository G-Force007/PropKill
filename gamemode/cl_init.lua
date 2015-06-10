/*---------------------------------------------------------
   Name: cl_init.lua
   Desc: Loads everything for clientside.
   Author: G-Force Connections (STEAM_0:1:19084184)
---------------------------------------------------------*/
PK = PK or {}

PK.Settings = PK.Settings or {}
PK.HudSettings = PK.HudSettings or {}

-- health bar colours ;3
PK.HudSettings[ "health_r" ] = CreateClientConVar( "pk_health_r", "194", true, true )
PK.HudSettings[ "health_g" ] = CreateClientConVar( "pk_health_g", "255", true, true )
PK.HudSettings[ "health_b" ] = CreateClientConVar( "pk_health_b", "72", true, true )
PK.HudSettings[ "health_a" ] = CreateClientConVar( "pk_health_a", "255", true, true )

-- kd bar colours
PK.HudSettings[ "kd_r" ] = CreateClientConVar( "pk_kd_r", "59", true, true )
PK.HudSettings[ "kd_g" ] = CreateClientConVar( "pk_kd_g", "142", true, true )
PK.HudSettings[ "kd_b" ] = CreateClientConVar( "pk_kd_b", "209", true, true )
PK.HudSettings[ "kd_a" ] = CreateClientConVar( "pk_kd_a", "255", true, true )

-- back panel of the hud in the left bottom corner
PK.HudSettings[ "panel_r" ] = CreateClientConVar( "pk_panel_r", "43", true, true )
PK.HudSettings[ "panel_g" ] = CreateClientConVar( "pk_panel_g", "42", true, true )
PK.HudSettings[ "panel_b" ] = CreateClientConVar( "pk_panel_b", "39", true, true )
PK.HudSettings[ "panel_a" ] = CreateClientConVar( "pk_panel_a", "255", true, true )

-- text colour outside of health & kd
PK.HudSettings[ "text_r" ] = CreateClientConVar( "pk_text_r", "242", true, true )
PK.HudSettings[ "text_g" ] = CreateClientConVar( "pk_text_g", "242", true, true )
PK.HudSettings[ "text_b" ] = CreateClientConVar( "pk_text_b", "242", true, true )
PK.HudSettings[ "text_a" ] = CreateClientConVar( "pk_text_a", "255", true, true )

include( "sh_teams.lua" ) -- sh_teams.lua needs to be loaded before sh_init.lua
include( "sh_init.lua" )
include( "sh_misc.lua" )
include( "cl_hud.lua" )
include( "cl_networking.lua" )
include( "cl_vgui.lua" )
--include( "cl_dermaskin.lua" )
include( "sh_scoreboard.lua" )

CreateClientConVar( "pk_playermodel", "", true, true )

-- Higher rates!
RunConsoleCommand( "cl_cmdrate", 100 )
RunConsoleCommand( "cl_updaterate", 100 )
RunConsoleCommand( "rate", 35000 )

-- Falco's rotate :3
concommand.Add( "falco_rotate1", function()
	local a = LocalPlayer():EyeAngles()
	LocalPlayer():SetEyeAngles( Angle( a.p, a.y - 180, a.r ) )
end )

concommand.Add( "falco_rotate2", function()
	local a = LocalPlayer():EyeAngles()
	LocalPlayer():SetEyeAngles( Angle( a.p - a.p - a.p, a.y - 180, a.r ) )
	RunConsoleCommand( "+jump" )
	timer.Simple( 0.2, function() RunConsoleCommand("-jump") end )
end )

-- Remove propspawn effects
hook.Add( "PostGamemodeLoaded", "PostGamemodeLoaded.OverridePropEffect", function()
	_G.DoPropSpawnedEffect = function( ent ) end
	effects.Register( { Init = function() end, Think = function() end, Render = function() end }, "propspawn" )
end )

function GM:ShouldCollide( ent1, ent2 )
	if ent1:IsPlayer() and ent2:IsPlayer() and PK.Settings[ "NocolidePlayers" ] and PK.Settings[ "NocolidePlayers" ].value then return false end

	return true -- colide if they're not a player :)
end

Msg( [[/==================================================/
GPropKill v]], PK.Version, [[ loaded Successfully
Coded By G-Force Connections (STEAM_0:1:19084184)
/==================================================/
]] )