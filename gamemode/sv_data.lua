/*---------------------------------------------------------
   Name: sv_data.lua
   Desc: This loads every shit it needs to load up, scores, props, blocked models and precaches shit.
   Author: G-Force Connections (STEAM_0:1:19084184)
---------------------------------------------------------*/

if not file.IsDir( "propkill", "DATA" ) then file.CreateDir( "propkill" ) end

/*---------------------------------------------------------
   Name: CommandLog
   Desc: Saves logs from players.
---------------------------------------------------------*/
function CommandLog( message )
    file.Append( "propkill/logs.txt", message .. "\r\n" )

    ServerLog( "Pkv2: LOG: " .. message .. "\n" )
end

/*---------------------------------------------------------
   Name: WritePKSettings
   Desc: This saves settings to a file.
---------------------------------------------------------*/
function WritePKSettings()
    file.Write( "propkill/settings.txt", util.TableToJSON( PK.Settings ) )
    Msg( "PKv2: Saved settings.\n" )
end

/*---------------------------------------------------------
   Name: WritePKCustomSpawns
   Desc: Saves custom spawns
---------------------------------------------------------*/
function WritePKCustomSpawns()
    file.Write( "propkill/customspawns.txt", util.TableToJSON( PK.CustomSpawns ) )
    Msg( "PKv2: Saved custom spawns.\n" )
end

/*---------------------------------------------------------
   Name: AutoSaveTimer
   Desc: Saves data every 5 minutes
---------------------------------------------------------*/
timer.Create( "AutoSaveTimer", 300, 0, function()
	Msg( "PKv2: Saving stats...\n" )

	file.Write( "propkill/sscores.txt", util.TableToJSON( PK.Scores ) )
    Msg( "PKv2: Saved player stats...\n" )

	file.Write( "propkill/propspawns.txt", util.TableToJSON( PK.PropSpawns ) )
	Msg( "PKv2: Saved prop spawns...\n" )

	Msg( "PKv2: Completed saving stats...\n" )
end )

/*---------------------------------------------------------
   Name: Scores
   Desc: Loads players scores.
---------------------------------------------------------*/
PK.Scores = {}

if file.Exists( "propkill/sscores.txt", "DATA" ) then
	PK.Scores = util.JSONToTable( file.Read( "propkill/sscores.txt", "DATA" ) )
	Msg( "PKv2: Successfully loaded " .. table.Count( PK.Scores ) .. " users.\n" )
end

/*---------------------------------------------------------
   Name: Settings
   Desc: Loads the settings for the gamemode.
---------------------------------------------------------*/
PK.Settings = {}

/* Default settings
   Format is
   PK.DefaultSettings[ "UNIQUENAME" ] = { value = 1/true/string, type = SETTING_NUMBER/STRING/BOOLEAN, desc = [[Some fancy description for the setting]] }

   Adding public = true to the table makes it so EVERY player will know this setting, this is not recommended. You should only use this in such cases EVERY client needs to know the setting, like for no-colide hooks.
*/
PK.DefaultSettings = {}
PK.DefaultSettings[ "Cleanup" ] = { value = true, type = SETTING_BOOLEAN, desc = [[Clean up players props after they die?]] }
PK.DefaultSettings[ "CleanupTime" ] = { value = 2, min = 2, max = 20, type = SETTING_NUMBER, desc = [[Clean up time before a players props are cleaned up?]] }
PK.DefaultSettings[ "CleanupOnStart" ] = { value = true, type = SETTING_BOOLEAN, desc = [[Clean the servers props, aka doors and other rubbish at map change?]] }
PK.DefaultSettings[ "CleanupOnDisconnect" ] = { value = true, type = SETTING_BOOLEAN, desc = [[Clean up the players props when they leave?]] }
PK.DefaultSettings[ "DenyDeadSpawning" ] = { value = true, type = SETTING_BOOLEAN, desc = [[Deny spawning props while a player is dead?]] }
PK.DefaultSettings[ "DeathRagdolls" ] = { value = true, type = SETTING_BOOLEAN, desc = [[Have ragdolls spawn when a player dies?]] }
PK.DefaultSettings[ "DefaultFrags" ] = { value = 15, min = 5, max = 15, type = SETTING_NUMBER, desc = [[Default kills required before a fight is ended.]] }
PK.DefaultSettings[ "PlayerSpawnHealth" ] = { value = 100, min = 1, max = 100, type = SETTING_NUMBER, public = true, desc = [[Spawn health of a player]] }
PK.DefaultSettings[ "WalkSpeed" ] = { value = 300, min = 300, max = 500, type = SETTING_NUMBER, desc = [[Players walking speed, NO SHIFT]] }
PK.DefaultSettings[ "RunSpeed" ] = { value = 500, min = 500, max = 700, type = SETTING_NUMBER, desc = [[Players running speed, WITH SHIFT]] }
PK.DefaultSettings[ "FightCoolDown" ] = { value = 300, min = 60, max = 600, type = SETTING_NUMBER, desc = [[Cool down before another player can fight]] }
PK.DefaultSettings[ "GodPlayerAtSpawn" ] = { value = true, type = SETTING_BOOLEAN, desc = [[God a player at their spawn?]] }
PK.DefaultSettings[ "GodPlayerAtSpawnTime" ] = { value = 1.2, min = 1, max = 10, type = SETTING_NUMBER, desc = [[How long should the player be goded when spawned?]] }
PK.DefaultSettings[ "DenySpawningWhileSpawnGoded" ] = { value = true, type = SETTING_BOOLEAN, desc = [[Deny spawning props while a player is goded after spawn?]] }
PK.DefaultSettings[ "NocolidePlayers" ] = { value = true, type = SETTING_BOOLEAN, public = true, desc = [[Allow players to walk through each other?]] }
PK.DefaultSettings[ "DeathTime" ] = { value = 1, min = 1, max = 10, type = SETTING_NUMBER, desc = [[How long a player has to stay dead before being able to respawn again.]] }

if file.Exists( "propkill/settings.txt", "DATA" ) then
	PK.Settings = util.JSONToTable( file.Read( "propkill/settings.txt", "DATA" ) )
	Msg( "PKv2: Successfully loaded " .. table.Count( PK.Settings ) .. " settings.\n" )

	-- Make sure any new settings added are will be saved.
	local changed = false

	for k, v in pairs( PK.DefaultSettings ) do
		if not PK.Settings[ k ] then
			PK.Settings[ k ] = v
			changed = true
		end
		--um1sg.PoolString( v.desc ) -- Bandwidth saving and limit saving shit right here :)
	end

	-- we need to cleanup old/removed configuration settings also so we'll check if PK.Settings also has the setting.
	for k, v in pairs( PK.Settings ) do if not PK.DefaultSettings[ k ] then PK.Settings[ k ] = nil changed = true end end

	if changed then
		ErrorNoHalt( "PKv2: New setting(s) or default missing setting(s) has been added to PK.Settings, saving file...\n" )
		WritePKSettings()
	end -- modified it with default commands so save the file.
else
	Msg( "PKv2: There is no propkill/settings.txt, writing a new one with default settings.\n" )
	PK.Settings = PK.DefaultSettings
	WritePKSettings() -- Save these settings.
end

/*---------------------------------------------------------
   Name: BlockedModels
   Desc: Loads players Blocked Models.
---------------------------------------------------------*/
PK.BlockedModels = {}

PK.DefaultBlockedModels = {
	"models/props_combine/combinetrain02b.mdl",
	"models/props_combine/combinetrain02a.mdl",
	"models/props_combine/combinetrain01.mdl",
	"models/cranes/crane_frame.mdl",
	"models/props_junk/trashdumpster02.mdl",
	"models/props_canal/canal_bridge02.mdl",
	"models/props_canal/canal_bridge01.mdl",
	"models/props_canal/canal_bridge03a.mdl",
	"models/props_canal/canal_bridge03b.mdl",
	"models/props_wasteland/cargo_container01c.mdl",
	"models/props_wasteland/cargo_container01b.mdl",
	"models/props_combine/combine_mine01.mdl",
	"models/props_junk/glassjug01.mdl",
	"models/props_c17/paper01.mdl",
	"models/props_junk/garbage_takeoutcarton001a.mdl",
	"models/props_c17/trappropeller_engine.mdl",
	"models/props/cs_office/microwave.mdl",
	"models/items/item_item_crate.mdl",
	"models/props_junk/gascan001a.mdl",
	"models/props_c17/consolebox01a.mdl",
	"models/props_buildings/building_002a.mdl",
	"models/props_phx/cannonball.mdl",
	"models/props_phx/ball.mdl",
	"models/props_phx/amraam.mdl",
	"models/props_phx/misc/flakshell_big.mdl",
	"models/props_phx/ww2bomb.mdl",
	"models/props_phx/torpedo.mdl",
	"models/props/de_train/biohazardtank.mdl",
	"models/props_buildings/project_building01.mdl",
	"models/props_combine/prison01c.mdl",
	"models/props/cs_militia/silo_01.mdl",
	"models/props_phx/huge/evildisc_corp.mdl",
	"models/props_phx/misc/potato_launcher_explosive.mdl",
	"models/props_combine/combine_citadel001.mdl",
	"models/props_phx/oildrum001_explosive.mdl",
	"models/props_combine/prison01.mdl",
	"models/props_phx/mk-82.mdl",
	"models/props_c17/oildrum001_explosive.mdl",
	"models/props_wasteland/cargo_container01.mdl",
	"models/props_phx/misc/potato_launcher_chamber.mdl"
}

if file.Exists( "propkill/blockedmodels.txt", "DATA" ) then
	PK.BlockedModels = util.JSONToTable( file.Read( "propkill/blockedmodels.txt", "DATA" ) )
	Msg( "PKv2: Successfully loaded " .. table.Count( PK.BlockedModels ) .. " blocked models.\n" )
else
	PK.BlockedModels = PK.DefaultBlockedModels
	ErrorNoHalt( "PKv2: There is no propkill/blockedmodels.txt, writing a new one with default blocked models.\n" )

	file.Write( "propkill/blockedmodels.txt", util.TableToJSON( PK.BlockedModels ) )
end

/*---------------------------------------------------------
   Name: Precachables and PropSpawns
   Desc: Loads precachables and spawned Props
---------------------------------------------------------*/

PK.PropSpawns = {}
PK.Precachables = {}

if file.Exists( "propkill/propspawns.txt", "DATA" ) then
	PK.PropSpawns = util.JSONToTable( file.Read( "propkill/propspawns.txt", "DATA" ) )
	Msg( "PKv2: Successfully loaded " .. table.Count( PK.PropSpawns ) .. " spawned props.\n" )
end

-- delete blocked models from the list :D
for k, v in pairs( PK.PropSpawns ) do
	if PK.BlockedModels[ k ] then
		PK.BlockedModels[ k ] = nil
	end
end

local precaches = table.sortSpawns( PK.PropSpawns, 20 ) -- table.sortSpawns is in sv_misc.lua

for k, v in pairs( precaches ) do
	util.PrecacheModel( k )
	table.insert( PK.Precachables, k )
end

/*---------------------------------------------------------
   Name: Custom spawns for maps
   Desc: New feature made for PoKi Lua, good suggestion V1 had it, now V2 will also have it :)
---------------------------------------------------------*/

PK.CustomSpawns = {}

if file.Exists( "propkill/customspawns.txt", "DATA" ) then
	PK.CustomSpawns = util.JSONToTable( file.Read( "propkill/customspawns.txt", "DATA" ) )
	Msg( "PKv2: Successfully loaded custom spawns for " .. table.Count( PK.CustomSpawns ) .. " map(s).\n" )
end