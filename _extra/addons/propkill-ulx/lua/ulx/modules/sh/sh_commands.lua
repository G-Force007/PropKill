/*---------------------------------------------------------
   Name: ULX Shit
   Desc: Commands and shit, thatll soon be changed due to stuff going in F4 menu.
---------------------------------------------------------*/

local CATEGORY_NAME = "Utility"

------------------------------ Cleanup ------------------------------
function ulx.cleanup( calling_ply )
    for _, v in pairs( ents.GetAll() ) do
        if not v:IsPlayer() and string.find( v:GetClass(), "prop_physics" ) or string.find( v:GetClass(), "prop_dynamic" ) then
            v:Remove()
        end
    end

    ulx.fancyLogAdmin( calling_ply, "#A cleaned up the server" )
end
local cleanup = ulx.command( CATEGORY_NAME, "ulx cleanup", ulx.cleanup, "!cleanup" )
cleanup:defaultAccess( ULib.ACCESS_ADMIN )
cleanup:help( "Cleanup the server" )

------------------------------ Reset ------------------------------
function ulx.reset( calling_ply, target_plys )
    local affected_plys = {}

    for i=1, #target_plys do
        local v = target_plys[ i ]
        v:SetFrags( 0 )
        v:SetDeaths( 0 )
        table.insert( affected_plys, v )
    end
	ulx.fancyLogAdmin( calling_ply, "#A reset the score of #T", affected_plys )
end
local reset = ulx.command( CATEGORY_NAME, "ulx reset", ulx.reset, "!reset" )
reset:addParam{ type=ULib.cmds.PlayersArg }
reset:defaultAccess( ULib.ACCESS_ADMIN )
reset:help( "Resets score" )

------------------------------ Saved Scores Reset ------------------------------
function ulx.sreset( calling_ply, target_plys )
    local affected_plys = {}

    for i=1, #target_plys do
        local v = target_plys[ i ]
        v:SetSKills( 0, false )
        v:SetSDeaths( 0, true )
        table.insert( affected_plys, v )
    end
	ulx.fancyLogAdmin( calling_ply, "#A reset the saved score of #T", affected_plys )
end
local sreset = ulx.command( CATEGORY_NAME, "ulx sreset", ulx.sreset, "!sreset" )
sreset:addParam{ type=ULib.cmds.PlayersArg }
sreset:defaultAccess( ULib.ACCESS_ADMIN )
sreset:help( "Resets saved score" )

------------------------------ Saved Kills ------------------------------
function ulx.skills( calling_ply, target_plys, score )
    local affected_plys = {}
    
    for i=1, #target_plys do
        local v = target_plys[ i ]
        v:SetSKills( score, true )
        table.insert( affected_plys, v )
    end
	ulx.fancyLogAdmin( calling_ply, "#A set the saved kills score of #T to #i", affected_plys, score )
end
local skills = ulx.command( CATEGORY_NAME, "ulx skills", ulx.skills, "!skills" )
skills:addParam{ type=ULib.cmds.PlayersArg }
skills:addParam{ type=ULib.cmds.NumArg, min=0, default=0, hint="the score", ULib.cmds.optional, ULib.cmds.round }
skills:defaultAccess( ULib.ACCESS_ADMIN )
skills:help( "Changes their saved kills" )

------------------------------ Saved Deaths ------------------------------
function ulx.sdeaths( calling_ply, target_plys, score )
    local affected_plys = {}

    for i=1, #target_plys do
        local v = target_plys[ i ]
        v:SetSDeaths( score, true )
        table.insert( affected_plys, v )
    end
	ulx.fancyLogAdmin( calling_ply, "#A set the saved deaths score of #T to #i", affected_plys, score )
end
local sdeaths = ulx.command( CATEGORY_NAME, "ulx sdeaths", ulx.sdeaths, "!sdeaths" )
sdeaths:addParam{ type=ULib.cmds.PlayersArg }
sdeaths:addParam{ type=ULib.cmds.NumArg, min=0, default=0, hint="the score", ULib.cmds.optional, ULib.cmds.round }
sdeaths:defaultAccess( ULib.ACCESS_ADMIN )
sdeaths:help( "Changes their saved deaths" )

------------------------------ Speed ------------------------------
function ulx.speed( calling_ply, speed )
	RunConsoleCommand( "sv_airaccelerate", speed )
	
	ulx.fancyLogAdmin( calling_ply, "#A set the air acceleration speed to #i", speed )
end
local speed = ulx.command( CATEGORY_NAME, "ulx speed", ulx.speed, "!speed" )
speed:addParam{ type=ULib.cmds.NumArg, min=0, max=200, default=200, hint="turn speed", ULib.cmds.optional, ULib.cmds.round }
speed:defaultAccess( ULib.ACCESS_ADMIN )
speed:help( "Change turning speed" )

------------------------------ Leave Fight ------------------------------
function ulx.leavefight( calling_ply )
    if not PK.FightInProgress then calling_ply:Notify( "There's no fight going on." ) return end

    if not table.HasValue( PK.Fighters, calling_ply ) then calling_ply:Notify( "You're not in the fight." ) return end

    local fighter = NULL

    if calling_ply == PK.Fighters[1] then
        fighter = PK.Fighters[2]
        calling_ply:FinishFighting( PK.Fighters[2] )
    elseif calling_ply == PK.Fighters[2] then
        fighter = PK.Fighters[1]
        calling_ply:FinishFighting( PK.Fighters[1] )
    end

    ulx.fancyLogAdmin( calling_ply, "#A forfeited the fight against #T", fighter )
end
local leavefight = ulx.command( CATEGORY_NAME, "ulx leavefight", ulx.leavefight, "!leavefight" )
leavefight:defaultAccess( ULib.ACCESS_ALL )
leavefight:help( "Stop the fight you currently are in" )

------------------------------ Stop Fight ------------------------------
function ulx.stopfight( calling_ply )
    if not PK.FightInProgress then calling_ply:Notify( "There's no fight going on." ) return end

    local fighter = NULL

    PK.Fighters[1]:FinishFighting( PK.Fighters[2] )

    ulx.fancyLogAdmin( calling_ply, "#A cancelled the fight between the fight against #T", PK.Fighters )
end
local stopfight = ulx.command( CATEGORY_NAME, "ulx stopfight", ulx.stopfight, "!stopfight" )
stopfight:defaultAccess( ULib.ACCESS_ADMIN )
stopfight:help( "Stop the fight" )

------------------------------ Add Custom Spawn ------------------------------
function ulx.addcustomspawn( calling_ply, team )
    if string.lower( team ) == "spectator" then calling_ply:Notify( "You can't set Spectator's spawn point." ) end

    for k, v in pairs( Teams ) do
        if v.command == string.lower( team ) then
            if not PK.CustomSpawns[ game.GetMap() ] then PK.CustomSpawns[ game.GetMap() ] = {} end
            if not PK.CustomSpawns[ game.GetMap() ][ v.command  ] then PK.CustomSpawns[ game.GetMap() ][ v.command  ] = {} end

            local TABLE = {}
            TABLE[ "Pos" ] = calling_ply:GetPos()
            TABLE[ "Angle" ] = calling_ply:EyeAngles()
            table.insert( PK.CustomSpawns[ game.GetMap() ][ v.command ], TABLE )

            calling_ply:Notify( "Successfully added team spawn for " .. v.command .. " at your location." )

            WritePKCustomSpawns()

            return
        end
    end
    calling_ply:Notify( "Failed to find team " .. team )
end
local addcustomspawn = ulx.command( CATEGORY_NAME, "ulx addcustomspawn", ulx.addcustomspawn, "!addcustomspawn" )
addcustomspawn:addParam{ type=ULib.cmds.StringArg, hint="team", ULib.cmds.takeRestOfLine }
addcustomspawn:defaultAccess( ULib.ACCESS_ALL )
addcustomspawn:help( "Add a custom spawn for the map you're currently on" )

------------------------------ Reset Custom Spawns ------------------------------
function ulx.resetcustomspawns( calling_ply, team )
    if string.lower( team ) == "spectator" then calling_ply( "You can't reset Spectator's spawn point." ) end

    for k, v in pairs( Teams ) do
        if v.command == string.lower( team )then
            PK.CustomSpawns[ game.GetMap() ][ v.command  ] = nil
            calling_ply:Notify( "Successfully removed " .. v.command .. "'s custom spawns." )

            WritePKCustomSpawns()
            return
        end
    end
    calling_ply:Notify( "Failed to find team " .. team )
end
local resetcustomspawns = ulx.command( CATEGORY_NAME, "ulx resetcustomspawns", ulx.resetcustomspawns, "!resetcustomspawns" )
resetcustomspawns:addParam{ type=ULib.cmds.StringArg, hint="team", ULib.cmds.takeRestOfLine }
resetcustomspawns:defaultAccess( ULib.ACCESS_ALL )
resetcustomspawns:help( "Reset all custom spawns on the map you're currently on" )