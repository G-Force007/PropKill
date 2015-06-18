/*---------------------------------------------------------
   Name: sv_achievements.lua
   Desc: These arent really Achievements but logs shit you do, "Fancy" shit.
   Author: G-Force Connections (STEAM_0:1:19084184)
---------------------------------------------------------*/

PK.Achievements = PK.Achievements or {}

local Stuff = PK.Achievements

function Stuff.Init( ply, victim )
	-- This just reports who killed who :)
	if ply == victim then return end
	ply:SendNotify( Format( "You killed %s.", victim:Nick() ), Color( 238, 59, 59, 255 ) )
	victim:SendNotify( Format( "%s killed you.", ply:Nick() ), Color( 238, 59, 59, 255 ) )
	SendNotifyAll( Format( "%s killed %s.", ply:Nick(), victim:Nick() ), { ply, victim }, Color( 238, 59, 59, 255 ) )
end

function Stuff.SelfKills( ply, victim )
	-- When you kill yourself
	if ply == victim then
		ply:SetAchievement( "SelfKills", ply:GetAchievement( "SelfKills" ) + 1 )
		ply:SendNotify( "You killed yourself." )
		SendNotifyAll( Format( "%s killed themself.", ply:Nick() ), ply )
	end
end

function Stuff.LongShots( ply, victim )
	-- When you longshot someone
	if ply ~= victim and victim:GetPos():Distance( ply:GetPos() ) >= 2000 then
		ply:SetAchievement( "LongShots", ply:GetAchievement( "LongShots" ) + 1 )
		ply:SendNotify( Format( "You longshotted %s.", victim:Nick() ) )
		victim:SendNotify( Format( "You were longshotted by %s.", ply:Nick() ) )
		SendNotifyAll( Format( "%s longshotted %s.", ply:Nick(), victim:Nick() ), { ply, victim } )
	end
end

function Stuff.LeaderKills( ply, victim )
	if PK.FightInProgress then return end
	-- When you take leader from someone
	if ply ~= victim and victim == PK.Leading then
		ply:SetAchievement( "LeaderKills", ply:GetAchievement( "LeaderKills" ) + 1 )
		ply:SendNotify( Format( "You have killed the leader %s.", victim:Nick() ), Color( 205, 55, 0, 255 ) )
		victim:SendNotify( Format( "%s has killed you as leader.", ply:Nick() ), Color( 205, 55, 0, 255 ) )
		SendNotifyAll( Format( "%s has killed the leader %s.", ply:Nick(), victim:Nick() ), { ply, victim }, Color( 205, 55, 0, 255 ) )

		gamemode.Call( "PlayerSetModel", victim )
	end
end

function Stuff.BecameLeader( ply, victim )
	if PK.FightInProgress then return end
	-- when you become a leader.
	if PK.PreviousLeader and PK.PreviousLeader ~= ply and PK.Leading == ply then
		ply:SetAchievement( "BecameLeader", ply:GetAchievement( "BecameLeader" ) + 1 )
		ply:SendNotify( "You are now leading.", Color( 255, 110, 180, 255 ) )
		SendNotifyAll( Format( "%s is now leading.", ply:Nick() ), ply, Color( 255, 110, 180, 255 ) )

		-- promote the leader... to leader. LOL :)
		local vPoint = ply:GetShootPos() + Vector(0,0,50)
		local effectdata = EffectData()
		effectdata:SetEntity( ply )
		effectdata:SetStart( vPoint ) -- Not sure if we need a start and origin (endpoint) for this effect, but whatever
		effectdata:SetOrigin( vPoint )
		effectdata:SetScale( 1 )
		util.Effect( "entity_remove", effectdata )
		ply:SetModel( "models/player/alyx.mdl" )
	end
end

function Stuff.LostLeader( ply )
	if PK.FightInProgress then return end
	if ply == PK.Leading and ply.Dying then
		ply:SetAchievement( "LostLeader", ply:GetAchievement( "LostLeader" ) + 1 )
		ply:SendNotify( "You are no longer leading.", Color( 205, 55, 0, 255 ) )
		SendNotifyAll( Format( "%s is no longer leading.", ply:Nick() ), ply, Color( 205, 55, 0, 255 ) )
	end
end

function Stuff.OffFloor( ply, victim )
	-- When the victim is in mid air.
	if ply ~= victim and not victim:OnGround() then
		ply:SendNotify( Format( "You killed %s while they were in mid-air.", victim:Nick() ) )
		victim:SendNotify( Format( "%s killed you while you were in mid-air.", ply:Nick() ) )
		SendNotifyAll( Format( "%s has killed %s while they were in mid-air.", ply:Nick(), victim:Nick() ), { ply, victim } )
		ply:SetAchievement( "OffFloor", ply:GetAchievement( "OffFloor" ) + 1 )
	end
end

function Stuff.DeathKills( ply, victim )
	-- When you kill someone while dead.
	if not ply:Alive() then
		ply:SendNotify( Format( "You killed %s while you were dead!", victim:Nick() ) )
		victim:SendNotify( Format( "%s killed you while they were dead!", ply:Nick() ) )
		SendNotifyAll( Format( "%s killed %s while they were dead!", ply:Nick(), victim:Nick() ), { ply, victim } )
		ply:SetAchievement( "DeathKills" , ply:GetAchievement( "DeathKills" ) + 1 )
	end
end

-- Rewrite this function, TODO :)
function Stuff.KillStreaks( ply, victim )
	if PK.FightInProgress then SetGNWVar( "Leader", NULL ) return end

	Stuff.LeaderKills( ply, victim ) -- Calling this function because this ISNT always called before KillSteaks function
	
	PK.PreviousLeader = PK.Leading
    local ksplayers = {}
    local ksplayerks = {}
    for _, v in pairs( player.GetAll() ) do
        local killstreaks = v:GetGNWVar( "killstreak" ) or 0
        if v:Team() ~= TEAM_SPECTATOR and killstreaks >= 1 then
            table.insert( ksplayers, v )
            table.insert( ksplayerks, killstreaks )
        end
    end

    local highest = table.GetWinningKey( ksplayerks )
    if highest then
		if PK.PreviousLeader ~= ksplayers[ highest ] then
			if ksplayers[ highest ]:IsPlayer() and PK.PreviousLeader ~= NULL then
				PK.PreviousLeader:SendNotify( Format( "%s has taken over you in leading!", ksplayers[ highest ]:Nick() ), Color( 255, 110, 180, 255 ) )
				ksplayers[ highest ]:SendNotify( Format( "You have taken over %s in leading!", PK.PreviousLeader:Nick() ), Color( 255, 110, 180, 255 ) )
                SendNotifyAll( Format( "%s has taken over %s in leading!", ksplayers[ highest ]:Nick(), PK.PreviousLeader:Nick() ), { PK.PreviousLeader, ksplayers[ highest ] }, Color( 255, 110, 180, 255 ) )

                gamemode.Call( "PlayerSetModel", PK.PreviousLeader )
			end
		end
		PK.Leading = ksplayers[ highest ]
        SetGNWVar( "Leader", PK.Leading or NULL )
    end

    if #ksplayers == 0 then
    	if PK.PreviousLeader:IsPlayer() then
    		Stuff.LostLeader( PK.PreviousLeader ) -- Killstreak gets called AFTER this function, fuck all and call it twice.
    		PK.Leading = NULL
    	end
    end
    SetGNWVar( "Leader", PK.Leading or NULL )
end