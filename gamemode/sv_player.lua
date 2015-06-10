-- Author: G-Force Connections (STEAM_0:1:19084184)

local Player = FindMetaTable( "Player" )

/*---------------------------------------------------------
   Name: ChangeTeam
   Desc: Called when a player changes Team, alert others do killstreak shit etc.
---------------------------------------------------------*/
function Player:ChangeTeam( t )
	if PK.FightInProgress then return end
	if self:Team() == t then return end
	
	local TEAM = Teams[ t ]
	if not TEAM then return end

	for _, v in pairs( player.GetAll() ) do
		v:Notify( self:Nick() .. " has become a " .. TEAM.name )
	end

	if PK.FightInProgress == true and table.HasValue( PK.Fighters, self ) then
		if ulx then
			ulx.fancyLogAdmin( self, "#A forfeited the fight against #T", self.Fighting )
		end

		self:FinishFighting( self.Fighting )
	end
	
	-- New owner.
	self:SetGNWVar( "killstreak", 0 )
	PK.Achievements.KillStreaks()
	
	self:SetTeam( t )
	
	self:Kill()

	self:Cleanup()
end

/*---------------------------------------------------------
   Name: Cleanup
   Desc: Removes the players props.
---------------------------------------------------------*/
function Player:Cleanup()
	if !self or !self:IsPlayer() then return end

	local dissolver = ents.Create( "env_entity_dissolver" )
    dissolver:SetKeyValue( "dissolvetype", 3 )
    dissolver:SetKeyValue( "magnitude", 1 )
    dissolver:SetKeyValue( "target", "prop_physics_" .. self:UniqueID() ) -- nurf nurf, must have this ;3
    dissolver:Spawn()
    dissolver:Fire( "Dissolve", v, 0 )
    dissolver:Fire( "Kill", "", 0.1 )
end

/*---------------------------------------------------------
   Name: Notify
   Desc: Send a sandbox notify to the player ;3
---------------------------------------------------------*/
function Player:Notify( msg )
	net.Start( "Notify" )
		net.WriteString( msg )
	net.Send( self )
end

/*---------------------------------------------------------
   Name: AddSKills
   Desc: Save kills / Send updated kills to players.
---------------------------------------------------------*/
function Player:AddSKills( kills )
	self:AddToScores( "Kills", self:GetScores( "Kills" ) + kills )
	self:SetGNWVar( "kills", self:GetScores( "Kills" ) )
end

/*---------------------------------------------------------
   Name: AddSDeaths
   Desc: Send deaths / Send updated deaths to players.
---------------------------------------------------------*/
function Player:AddSDeaths( deaths )
	self:AddToScores( "Deaths", self:GetScores( "Deaths" ) + deaths )
	self:SetGNWVar( "deaths", self:GetScores( "Deaths" ) )
end

/*---------------------------------------------------------
   Name: SetSKills
   Desc: Set the players kills.
---------------------------------------------------------*/
function Player:SetSKills( kills )
	self:AddToScores( "Kills", kills )
	self:SetGNWVar( "kills", kills )
end

/*---------------------------------------------------------
   Name: SetSDeaths
   Desc: Set the players deaths.
---------------------------------------------------------*/
function Player:SetSDeaths( deaths )
	self:AddToScores( "Deaths", deaths )
	self:SetGNWVar( "deaths", deaths )
end

/*---------------------------------------------------------
   Name: SendNotify
   Desc: Send the custom message shit above the hud.
---------------------------------------------------------*/
function Player:SendNotify( text, colour )
    if self:IsBot() then return end
    net.Start( "SendNotify" )
        net.WriteString( text )
        net.WriteString( util.TableToJSON( colour or Color( 194, 255, 72, 255 ) ) )
    net.Send( self )
end

/*---------------------------------------------------------
   Name: Kill
   Desc: Overwriting the old function so we can kill the player silently.
---------------------------------------------------------*/
function Player:Kill()
	self:SetGNWVar( "killstreak", 0 )
    self:KillSilent()
    PK.Achievements:KillStreaks( self, self )

    -- Clean up props for player.
    if PK.Cleanup then
    	timer.Simple( PK.CleanupTime or 2, self.Cleanup, self )
    end
end

/*---------------------------------------------------------
   Name: AddFrags
   Desc: We overwrite this so we can add Saved Kills too.
---------------------------------------------------------*/
if not Player.AddFragsOld then
	Player.AddFragsOld = Player.AddFragsOld or Player.AddFrags
end

function Player:AddFrags( kills )
	self:AddFragsOld( kills )
	self:AddSKills( kills )
end

/*---------------------------------------------------------
   Name: AddDeaths
   Desc: We overwrite this so we can add Saved Deaths too.
---------------------------------------------------------*/
if not Player.AddDeathsOld then
	Player.AddDeathsOld = Player.AddDeathsOld or Player.AddDeaths
end

function Player:AddDeaths( deaths )
	self:AddDeathsOld( deaths )
	self:AddSDeaths( deaths )
end

/*---------------------------------------------------------
   Name: AddToScores
   Desc: Save Kills/Deaths with this function.
---------------------------------------------------------*/
function Player:AddToScores( key, value )
	PK.Scores[ self:SteamID() ][ key ] = value
end

/*---------------------------------------------------------
   Name: GetScores
   Desc: Gets Kills/Deaths with this function.
---------------------------------------------------------*/
function Player:GetScores( key )
	return PK.Scores[ self:SteamID() ][ key ] or 0
end

/*---------------------------------------------------------
   Name: SetAchievement
   Desc: Set achievements with this function.
---------------------------------------------------------*/
function Player:SetAchievement( key, value, dontinform )
	if self:GetScores( "Achievements" ) == 0 then self:AddToScores( "Achievements", {} ) end
	PK.Scores[ self:SteamID() ].Achievements[ key ] = value

	if dontinform then return end

	net.Start( "Achievement" )
		net.WriteEntity( self )
		net.WriteString( key )
		net.WriteInt( value, 15 )
	net.Send(self)
end

/*---------------------------------------------------------
   Name: GetAchievement
   Desc: Get achievements with this function.
---------------------------------------------------------*/
function Player:GetAchievement( key )
	if self:GetScores( "Achievements" ) == 0 then self:AddToScores( "Achievements", {} ) end

	return PK.Scores[ self:SteamID() ].Achievements[ key ] or 0
end

/*---------------------------------------------------------
   Name: GetAchievements
   Desc: Get all the achievements from the player with this function.
---------------------------------------------------------*/
function Player:GetAchievements()
	return PK.Scores[ self:SteamID() ].Achievements or {}
end

/*---------------------------------------------------------
   Name: CallAchievements
   Desc: This calls all the achievements for the player and victim.
---------------------------------------------------------*/
function Player:CallAchievements( victim )
	for _, v in pairs( PK.Achievements ) do
		v( self, victim )
	end
end

/*---------------------------------------------------------
   Name: PlayerKilledSelf
   Desc: Send the PlayerKilledSelf usermessage to the players.
---------------------------------------------------------*/
function Player:PlayerKilledSelf()
	net.Start( "PlayerKilledSelf" )
		net.WriteEntity( self )
	net.Broadcast()
end

/*---------------------------------------------------------
   Name: PlayerKilledByPlayer
   Desc: Send the PlayerKilledByPlayer usermessage to the players.
---------------------------------------------------------*/
function Player:PlayerKilledByPlayer( killer )
	net.Start( "PlayerKilledByPlayer" )
		net.WriteEntity( self )
		net.WriteString( "prop_physics" )
		net.WriteEntity( killer )
	net.Broadcast()
end

/*---------------------------------------------------------
   Name: FindClosestOwner
   Desc: Gets the closest props owner.
---------------------------------------------------------*/
function Player:FindClosestOwner()
	local entities = ents.FindInSphere( self:GetPos(), 200 )
	local entities2 = {}
	for _, v in pairs( entities ) do
		if v:GetClass() == "prop_physics" then
			table.insert( entities2, { v, v:GetPos():Distance( self:GetPos() ) } )
		end
	end
	table.sort( entities2, function( x, y ) return x[2] < y[2] end )

	return entities2[1][1].Owner or NULL
end

/*---------------------------------------------------------
   Name: StartFight
   Desc: Starts a fight with another player.
---------------------------------------------------------*/
function Player:StartFight( ply, limit )
	if not self:IsPlayer() then return end
	if PK.FightInProgress then return end
	
	PK.Fighters = { self, ply }
	PK.Fighter1 = self
	PK.Fighter2 = ply

	PK.Frags = limit or GetSetting( "DefaultFrags" )

	if not self:IsPlayer() or not ply:IsPlayer() then return end
	
	if self == ply then return end
	
	self.Fighting = ply
	ply.Fighting = self
	
	self:SetFrags( 0 )
	ply:SetFrags( 0 )
	self:SetDeaths( 0 )
	ply:SetDeaths( 0 )
	
	PK.FightInProgress = true -- Global variable

	if self:Team() ~= TEAM_BATTLER then
		self:SetTeam( TEAM_BATTLER )
		self:Spawn()
	end

	if ply:Team() ~= TEAM_BATTLER then
		ply:SetTeam( TEAM_BATTLER )
		ply:Spawn()
	end

	--Set the players skins back to normal
	gamemode.Call( "PlayerSetModel", self )
	gamemode.Call( "PlayerSetModel", ply )
	
	for _, v in pairs( player.GetAll() ) do
		if v ~= self and v ~= ply then
			v.TeamBeforeFight = v:Team()
			v:SetTeam( TEAM_SPECTATOR )
			v:KillSilent()
		end
	end
	SetGlobalBool( "FightInProgress", true )
	SetGlobalString( "Fighters", util.TableToJSON( PK.Fighters ) )
	SetGlobalEntity( "Fighter1", PK.Fighter1 )
	SetGlobalEntity( "Fighter2", PK.Fighter2 )
	CommandLog( Format( "%s<%s> started a battle with %s<%s>", ply:Nick(), ply:SteamID(), self:Nick(), self:SteamID() ) )
	
	if ulx then ulx.fancyLogAdmin( ply, "#A started a battle with #T", self ) end
end

/*---------------------------------------------------------
   Name: FinishFighting
   Desc: Finish fighting with a player or ending it.
---------------------------------------------------------*/
function Player:FinishFighting()
	if not PK.FightInProgress then return end
	if not self:IsPlayer() or not self.Fighting:IsPlayer() then return end

	if not table.HasValue( PK.Fighters, self ) then return end

	local ply = self.Fighting -- define it here so we don't need to always know who someone is fighting when calling this function :)
	
	PK.Fighters = {}
	PK.Figher1 = nil
	PK.Figher2 = nil

	self.Fighting = nil
	ply.Fighting = nil
	
	PK.FightInProgress = false

	for _, v in pairs( player.GetAll() ) do
		if v:Team() == TEAM_SPECTATOR then
			if v.TeamBeforeFight and v.TeamBeforeFight ~= 0 then
				v:SetTeam( v.TeamBeforeFight )
				v:Spawn() -- remember to respawn them, lol.
				v.TeamBeforeFight = 0
			end
		end
	end

	ply:SetFrags( 0 )
	ply:SetDeaths( 0 )

	self:SetFrags( 0 )
	self:SetDeaths( 0 )

	SetGlobalBool( "FightInProgress", false )
	SetGlobalString( "Fighters", "" )
	SetGlobalEntity( "Figher1", nil )
	SetGlobalEntity( "Figher2", nil )

	CommandLog( Format( "%s<%s> finished a battle with %s<%s>", ply:Nick(), ply:SteamID(), self:Nick(), self:SteamID() ) )

	if ulx then ulx.fancyLogAdmin( ply, "#A finished a battle with #T", self ) end
end

/*---------------------------------------------------------
   Name: ResetViewRoll
   Desc: some TTT shit for the spectator?
---------------------------------------------------------*/
function Player:ResetViewRoll()
	local ang = self:EyeAngles()

	if ang.r ~= 0 then
		ang.r = 0
		self:SetEyeAngles( ang )
	end
end
/*---------------------------------------------------------
   Name: GetFallDamage
   Desc: FallDamage, set custom or shit here.
---------------------------------------------------------*/
function GM:GetFallDamage( ply, flFallSpeed ) return 0 end

/*---------------------------------------------------------
   Name: PlayerDeathSound
   Desc: Return true to disable or false to enable the players death sound.
---------------------------------------------------------*/
function GM:PlayerDeathSound() return true end

/*---------------------------------------------------------
   Name: PlayerDeath
   Desc: Called after DoPlayerDeath, just used for preventing the player from spawning right after dying.
---------------------------------------------------------*/
function GM:PlayerDeath( Victim, Inflictor, Attacker )
	Victim.NextSpawnTime = CurTime() + tonumber( PK.Settings[ "DeathTime" ].value )
	Victim.DeathTime = CurTime()
end

/*---------------------------------------------------------
   Name: DoPlayerDeath
   Desc: Called after a player dies, this handles who killed who and shtit like that.
---------------------------------------------------------*/
function GM:DoPlayerDeath( ply, killer, dmginfo )
	if not ply:IsValid() or not ply:IsPlayer() then return end

	local owner = killer
	ply.Dying = true

	if GetSetting( "DeathRagdolls" ) then
		ply:CreateRagdoll()

		local ragdoll = ply:GetRagdollEntity()
		ragdoll:SetKeyValue( "targetname", "ragdoll_" .. ply:UniqueID() )

		local dissolver = ents.Create( "env_entity_dissolver" )
	    dissolver:SetKeyValue( "dissolvetype", 1 )
	    dissolver:SetKeyValue( "magnitude", 1 )
	    dissolver:SetKeyValue( "target", "ragdoll_" .. ply:UniqueID() ) -- needed for awesome effects ;3
	    dissolver:Spawn()
	    dissolver:Fire( "Dissolve", v, 0 )
	    dissolver:Fire( "Kill", "", 0.5 )
	end -- make the player ragdoll :)

	if killer:IsValid() then
		if ply == killer then ulx.logSpawn( string.format( "%s<%s> suicided.", ply:Nick(), ply:SteamID() ) ) end
		
		if killer:GetClass() == "prop_physics" then
			owner = killer.Owner or NULL

			if owner:IsPlayer() then
				if owner ~= ply then -- player didnt kill themself.
					ulx.logSpawn( string.format( "%s<%s> was prop killed by %s<%s>", ply:Nick(), ply:SteamID(), owner:Nick(), owner:SteamID() ) )
				else
					owner = ply:FindClosestOwner()
					if owner == ply then
						ulx.logSpawn( string.format( "%s<%s> was prop killed by themself", ply:Nick(), ply:SteamID() ) )
					else
						ulx.logSpawn( string.format( "%s<%s> was prop killed by %s<%s>", ply:Nick(), ply:SteamID(), owner:Nick(), owner:SteamID() ) )
					end
				end
			end
		end
	elseif killer:GetClass() == "worldspawn" then
		owner = ply:FindClosestOwner()

		if owner == ply then
			ulx.logSpawn( string.format( "%s<%s> was prop killed by themself", ply:Nick(), ply:SteamID() ) )
		else
			ulx.logSpawn( string.format( "%s<%s> was prop killed by %s<%s>", ply:Nick(), ply:SteamID(), owner:Nick(), owner:SteamID() ) )
		end
	end

	--give the owner of the prop a frag
	if owner and owner ~= ply and owner:IsPlayer() then owner:AddFrags( 1 ) end

	ply:AddDeaths( 1 )
	ply:SetGNWVar( "killstreak", 0 ) -- Resetting the players killstreak

	if GetSetting( "Cleanup" ) then
		timer.Create( string.format( "Cleanup_%s", ply:SteamID() ), GetSetting( "CleanupTime" ) or 2, 1, function() ply:Cleanup() end )
	end
	
	if ply ~= owner and not PK.FightInProgress then owner:SetGNWVar( "killstreak", owner:GetGNWVar( "killstreak" ) + 1 ) end -- Up the players killstreak

	if ply ~= owner then ply:PlayerKilledByPlayer( owner ) else ply:PlayerKilledSelf() end

	if PK.FightInProgress then
		if ply:Deaths() >= PK.Frags then
			ulx.fancyLogAdmin( ply.Fighting, "#A won the fight against #T", ply )
			ply.Fighting:SetAchievement( "FightsWon" , ply.Fighting:GetAchievement( "FightsWon" ) + 1 )
			ply:SetAchievement( "FightsLost" , ply:GetAchievement( "FightsLost" ) + 1 )
			ply.Fighting:FinishFighting( ply )
		end
	end

	owner:CallAchievements( ply ) -- Call all the functions added to this rubbish list.
end

/*---------------------------------------------------------
   Name: ShowHelp
   Desc: Dont do anything when someone presses f1 for that school sandbox default shit.
---------------------------------------------------------*/
function GM:ShowHelp( ply ) return end

/*---------------------------------------------------------
   Name: ShowSpare2
   Desc: Called when a player presses F4
---------------------------------------------------------*/
util.AddNetworkString( "ChangeJobVGUI" )
function GM:ShowSpare2( ply ) net.Start( "ChangeJobVGUI" ) net.Send(ply) end

/*---------------------------------------------------------
   Name: PlayerInitialSpawn
   Desc: When a player first connects to the server we send heaps of information to the player themself and everyone else.
---------------------------------------------------------*/
function GM:PlayerInitialSpawn( ply )
	self.BaseClass:PlayerInitialSpawn( ply )
	
	-- MUST ALWAYS SET TEAM OR YOU GO TO 1001 :D
	ply:SetTeam( TEAM_SPECTATOR )

	ulx.fancyLogAdmin( ply, "#A joined the server #s", "(" .. ply:SteamID() .. ")" )

	if not PK.Scores[ ply:SteamID() ] then
		PK.Scores[ ply:SteamID() ] = {}
		ply:AddToScores( "Name", ply:Nick() )
		ply:AddToScores( "Kills", 0 )
		ply:AddToScores( "Deaths", 0 )
		--WritePKScores()
	elseif PK.Scores[ ply:SteamID() ].Name ~= ply:Nick() then
		ply:AddToScores( "Name", ply:Nick() )
		--WritePKScores()
	end

	ply:SetGNWVar( "kills", ply:GetScores( "Kills" ) or 0 )
	ply:SetGNWVar( "deaths", ply:GetScores( "Deaths" ) or 0 )
	ply:SendGNWVars()

	if ply:IsBot() then return end -- Don't even waste the bandwidth, not worth it lol.

	timer.Create( Format( "UpdateInfo_%s", ply:SteamID() ) , 1, 1, function( )
		if not ply:IsPlayer() then return end
		-- player left?

		local data = util.Compress( util.TableToJSON( PK.Precachables ) )
		net.Start( "PrecacheModels" )
			net.WriteUInt( #data, 32 )
			net.WriteData( data, #data )
		net.Send( ply )

		-- Is the player a super admin? if so then send them the info about settings.
		for k, v in pairs( PK.Settings ) do
			if not v.public and not ply:IsSuperAdmin() then continue end

			local type = v.type
			if type == SETTING_NUMBER then 
				net.Start( "Setting" )
					net.WriteString( k ) -- name
					net.WriteInt( type, 32 ) -- obivously type...
					net.WriteString( v.desc or "" ) -- description
					net.WriteInt( v.value, 32 ) -- number
					net.WriteInt( v.min, 32 ) -- min number
					net.WriteInt( v.max, 32 ) -- max number
				net.Send( ply )
			elseif type == SETTING_BOOLEAN then
				net.Start( "Setting" )
					net.WriteString( k ) -- name
					net.WriteInt( type, 32 ) -- obviously type...
					net.WriteString( v.desc or "" ) -- description
					net.WriteBit( v.value ) -- bool :)
				net.Send( ply )
			end
		end

		-- Sending the players achievements to everyone on the server, including themself.
		for _, v in pairs( player.GetAll() ) do
			if v:IsBot() then continue end
			net.Start( "Achievements" )
				net.WriteEntity( ply )
				net.WriteString( util.TableToJSON( ply:GetAchievements() ) )
			net.Send( v )
		end

		-- Sending the new player everyones achievements on the server
		for _, v in pairs( player.GetAll() ) do
			if v == ply or v:IsBot() then continue end
			net.Start( "Achievements", ply )
				net.WriteEntity( v )
				net.WriteString( util.TableToJSON( v:GetAchievements() ) )
			net.Broadcast()
		end
	end, ply )
end

/*---------------------------------------------------------
   Name: CanPlayerSuicide
   Desc: Called when a player tries to suicide, aka a Spectator.
---------------------------------------------------------*/
function GM:CanPlayerSuicide( ply )
	return ply:Team() ~= TEAM_SPECTATOR
end

/*---------------------------------------------------------
   Name: PlayerSpawn
   Desc: Called when a player spawns.
---------------------------------------------------------*/
function GM:PlayerSpawn( ply )
	ply:CrosshairEnable()
	ply:UnSpectate() -- We need this incase you are in spectator :)

	ply:SetHealth( GetSetting( "PlayerSpawnHealth" ) or 100 )

	local col = ply:GetInfo( "cl_playercolor" )
	ply:SetPlayerColor( Vector( col ) )

	local col = ply:GetInfo( "cl_weaponcolor" )
	ply:SetWeaponColor( Vector( col ) )

	ply.Dying = false

	if ply:Team() == TEAM_SPECTATOR then
		-- ULX god the player.
		ply:GodEnable()
		ply.ULXHasGod = true

		ply:SetColor( Color( 255, 255, 255, 0 ) )
		ply:SetGNWVar( "IsSpectating", true )
		ply:SetMoveType( MOVETYPE_NOCLIP )
		ply:Spectate( OBS_MODE_ROAMING )
	else
		ply:SetGNWVar( "IsSpectating", false )
		ply:SetColor( Color( 255, 255, 255, 255 ) )
		if GetSetting( "GodPlayerAtSpawn" ) then
			ply:GodEnable()
			ply:SetColor( Color( 0, 0, 0, 0 ) )
			ply.SpawnGoded = true

			local function UngodPlayer( ply )
				if not ply or not ply:IsPlayer() then return end
				ply:GodDisable()
				ply:SetColor( Color( 255, 255, 255, 255 ) )
				
				ply:Give( "weapon_physgun" )
				ply.SpawnGoded = nil
			end

			timer.Create( string.format( "Ungod_%s", ply:SteamID() ), GetSetting( "GodPlayerAtSpawnTime" ) or 5, 1, function() UngodPlayer(ply) end )
		else
			if ply.ULXHasGod then
				ply:GodDisable()
				ply.ULXHasGod = false
			end

			ply:Give( "weapon_physgun" )
		end

		-- custom spawns
		local pos, angle = self:PlayerSelectSpawn( ply )
		ply:SetPos( pos )
		if angle then ply:SetEyeAngles( angle ) end
	end
	
	self:SetPlayerSpeed( ply, GetSetting( "WalkSpeed" ) or 400, GetSetting( "RunSpeed" ) or 500 )
	self:PlayerSetModel( ply )
end

/*---------------------------------------------------------
   Name: isEmpty
   Desc: Called from the function below, also taken from DarkRP lol.
---------------------------------------------------------*/
function isEmpty( vector, ignore )
    ignore = ignore or {}

    local point = util.PointContents( vector )
    local a = point ~= CONTENTS_SOLID
          and point ~= CONTENTS_MOVEABLE
          and point ~= CONTENTS_LADDER
          and point ~= CONTENTS_PLAYERCLIP
          and point ~= CONTENTS_MONSTERCLIP

    local b = true

    for k, v in pairs( ents.FindInSphere( vector, 35 ) ) do
        if ( v:IsNPC() or v:IsPlayer() or v:GetClass() == "prop_physics" ) and not table.HasValue( ignore, v ) then
            b = false
            break
        end
    end

    return a and b
end

/*---------------------------------------------------------
   Name: ShouldCollide
   Desc: Nocolide with players ;3
---------------------------------------------------------*/
function GM:ShouldCollide( ent1, ent2 )
	if ent1:IsPlayer() and ent2:IsPlayer() and GetSetting( "NocolidePlayers" ) then return false end

	return true -- don't let props fall through worldspawn :P
end

/*---------------------------------------------------------
   Name: PlayerSelectSpawn
   Desc: Called when a player spawns to set their position.
---------------------------------------------------------*/
function GM:PlayerSelectSpawn( ply )
	local spawn = self.BaseClass:PlayerSelectSpawn( ply )

	local POS
	if spawn and spawn.GetPos then 
		POS = spawn:GetPos()
	else
		POS = ply:GetPos()
	end

	local CustomSpawns = PK.CustomSpawns[ game.GetMap() ]
	if CustomSpawns and CustomSpawns[ Teams[ ply:Team() ].command ] and #CustomSpawns[ Teams[ ply:Team() ].command ] >= 1 then
		local spawnpoint = math.random( 1, #CustomSpawns[ Teams[ ply:Team() ].command ] )
		POS = CustomSpawns[ Teams[ ply:Team() ].command ][ spawnpoint ][ "Pos" ]
		ANGLE = CustomSpawns[ Teams[ ply:Team() ].command ][ spawnpoint ][ "Angle" ]
	end

	local step = 30
	local ignore = { ply }
	local distance = 600
	local area = Vector( 16, 16, 64 )

	if isEmpty( POS, ignore ) and isEmpty( POS + area, ignore ) then
		return POS
	end

	for j = step, distance, step do
		for i = -1, 1, 2 do -- alternate in direction
			local k = j * i

			-- Look North/South
			if isEmpty( POS + Vector( k, 0, 0 ), ignore ) and isEmpty( POS + Vector( k, 0, 0 ) + area, ignore ) then
				return POS + Vector( k, 0, 0 )
			end

			-- Look East/West
			if isEmpty( POS + Vector( 0, k, 0 ), ignore ) and isEmpty( POS + Vector( 0, k, 0 ) + area, ignore ) then
				return POS + Vector( 0, k, 0 )
			end

			-- Look Up/Down
			if isEmpty( POS + Vector( 0, 0, k ), ignore ) and isEmpty( POS + Vector( 0, 0, k ) + area, ignore ) then
				return POS + Vector( 0, 0, k )
			end
		end
	end

	return POS, ANGLE
end

/*---------------------------------------------------------
   Name: PlayerSetModel
   Desc: Called after PlayerSpawn to set the players model.
---------------------------------------------------------*/
function GM:PlayerSetModel( ply )
	print("Called for "..ply:Nick())
	local EndModel = ""
	local TEAM = Teams[ ply:Team() ]
	
	if TEAM and type( TEAM.model ) == "table" then
		local ChosenModel = ply.ChosenModel or ply:GetInfo( "pk_playermodel" )
		ChosenModel = string.lower( ChosenModel )

		local found
		for _, Models in pairs( TEAM.model ) do
			if ChosenModel == string.lower( Models ) then
				EndModel = Models
				found = true
				break
			end
		end
		
		if not found then
			EndModel = TEAM.model[ math.random( #TEAM.model ) ]
		end
	else
		EndModel = "models/player/group01/male_01.mdl"
	end

	ply:SetModel( EndModel )
end

/*---------------------------------------------------------
   Name: PlayerDisconnected
   Desc: Called when a player leaves.
---------------------------------------------------------*/
function GM:PlayerDisconnected( ply )
	if PK.FightInProgress then
		if table.HasValue( PK.Fighters, ply ) then
			ply:FinishFighting( ply.Fighting )
			ulx.fancyLogAdmin( ply, "#A forfeited the fight against #T", ply.Fighting )
		end
	end

	if PK.Leading == ply then
		PK.Leading = NULL
		SetGlobalEntity( "Leader", PK.Leading or NULL )
	end -- Remove leader.

	ulx.fancyLogAdmin( ply, "#A left the server (#s)", ply:SteamID() )

	-- Remove the players props
	if GetSetting( "CleanupOnDisconnect" ) then ply:Cleanup() end
	for _, v in pairs( player.GetAll() ) do v:Notify( Format( "Cleaned up %s's stuff.", ply:Nick() ) ) end

	self.BaseClass:PlayerDisconnected( ply )
end

/*---------------------------------------------------------
   Name: EntityTakeDamage
   Desc: Should prevent team kills.
---------------------------------------------------------*/
--function GM:EntityTakeDamage( ent, inflictor, attacker, amount, dmginfo )
function GM:EntityTakeDamage( ent, dmginfo )
	if ent:IsPlayer() then
		if ent:Team() ~= TEAM_SPECTATOR and ent:Team() ~= TEAM_BATTLER then
			if dmginfo:GetAttacker():IsValid() then
				if dmginfo:GetAttacker():GetClass() == "prop_physics" then
					local owner = dmginfo:GetAttacker().Owner or NULL
					if ent ~= owner and ent:Team() == owner:Team() then
						dmginfo:SetDamage( 0 )
						return
					end
				end
			elseif dmginfo:GetAttacker():GetClass() == "worldspawn" then
				local owner = ent:FindClosestOwner()
				if ent ~= owner and ent:Team() == owner:Team() then
					dmginfo:SetDamage( 0 )
					return
				end
			end
		end

		-- get the owner of the prop that hit the player
		if dmginfo:GetAttacker():IsValid() and dmginfo:GetAttacker():GetClass() == "prop_physics" then
			local owner = dmginfo:GetAttacker().Owner or NULL

			if owner:IsPlayer() and owner ~= ent then
				local IndicPos = 0
				     
				if dmginfo:GetDamagePosition() == Vector( 0, 0, 0 ) or dmginfo:IsExplosionDamage() then
				    IndicPos = ent:GetPos() + Vector( 0, 0, 50 )
				else
				    IndicPos = dmginfo:GetDamagePosition() + Vector( 0, 0, 10 )
				end

				net.Start( "GetDamage" ) -- alert the owner only.
				    net.WriteVector( IndicPos )
				    net.WriteInt( dmginfo:GetDamage(), 32 )
				    net.WriteInt( CurTime() + 3, 32 )
				net.Send(owner)
			end
		end
    end
end