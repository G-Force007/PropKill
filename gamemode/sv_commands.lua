-- Author: G-Force Connections (STEAM_0:1:19084184)

/*---------------------------------------------------------
   Name: pk_chosenmodel
   Desc: Model youll spawn with when you pick a certain one from the F4 menu.
---------------------------------------------------------*/
concommand.Add( "pk_chosenmodel", function( ply, cmd, args )
    if not ply:IsPlayer() then return end

	if not args[1] then ply:Notify( "Enter a proper model." ) return end
	ply.ChosenModel = args[1]
end )

/*---------------------------------------------------------
   Name: pk_team
   Desc: Changes team
---------------------------------------------------------*/
concommand.Add( "pk_team", function( ply, cmd, args )
    if not ply:IsPlayer() or not args[1] then return end
    if ply.lastused and ply.lastused + 2 > CurTime() then return end
    ply.lastused = CurTime()

    for k, v in pairs( Teams ) do
        if v.command == args[1] then
            if PK.FightInProgress then ply:Notify( "There is a fight going on at the moment, if you're fighting then !leavefight and try again." ) return end
    
            ply:ChangeTeam( k )
            ply:Spawn()
            return
        end
    end
end )

/*---------------------------------------------------------
   Name: pk_setting
   Desc: Superadmins can use this command to change settings :)
---------------------------------------------------------*/
concommand.Add( "pk_setting", function( ply, cmd, args )
    if not ply:IsPlayer() or not args[1] then return end
    if not ply:IsSuperAdmin() then ply:Notify( "You need to be a super admin to use this command." ) return end

    if not PK.Settings[ args[1] ] then return end

    local type = PK.Settings[ args[1] ].type
    if type == SETTING_BOOLEAN then
		if PK.Settings[ args[1] ].value == tobool( args[2] ) then return end
        SetSetting( args[1], tobool( args[2] ), ply )
        ply:Notify( "Setting saved!" )

        -- My really shit way to notify the player if they've enabled the setting or not :D
        local setting_changed = "disabled"
        if tobool( args[2] ) then
            setting_changed = "enabled"
        end

        CommandLog( Format( "%s<%s> %s %s", ply:Nick(), ply:SteamID(), setting_changed, args[1] ) ) -- Name disabled/enabled setting name
    elseif type == SETTING_NUMBER then
		if PK.Settings[ args[1] ].value == tonumber( args[2] ) then return end
        if not ply.lastset or ply.lastset + .5 <= os.time() then -- numsliders send a lot of runcommands through, we check every half second xD
			local value = tonumber( args[2] )
			if value < PK.Settings[ args[1] ].min or value > PK.Settings[ args[1] ].max then return ply:Notify( "Invalid setting value." ) end -- Prevent going under min and over max of settings number :)
			ply.lastset = os.time()
            SetSetting( args[1], value, ply )
            ply:Notify( "Setting saved!" )

            CommandLog( Format( "%s<%s> set %s to %s", ply:Nick(), ply:SteamID(), args[1], args[2] ) )
        end
    end
end )

/*---------------------------------------------------------
   Name: pk_top
   Desc: Sends the top players to a player. 
---------------------------------------------------------*/
concommand.Add( "pk_top", function( ply, cmd, args )
    local top10 = util.Compress( util.TableToJSON( table.sortTopPlayers( PK.Scores, 20 ) ) )

    net.Start( "TopPlayers" )
        net.WriteUInt( #top10, 32 )
        net.WriteData( top10, #top10 )
    net.Send( ply )
end )

/*---------------------------------------------------------
   Name: pk_cleanup
   Desc: Scoreboard admin command to cleanup players props.
---------------------------------------------------------*/
concommand.Add( "pk_cleanup", function( ply, cmd, args )
    if not ply:IsPlayer() or not args[1] then return end
    if not ply:IsAdmin() then ply:Notify( "You need to be an admin to use this command." ) return end

    local target = player.GetByUniqueID( args[1] )
    target:Cleanup()

    for _, v in pairs( player.GetAll() ) do v:Notify( target:Nick() .. "'s props were cleaned up by admin " .. ply:Nick() ) end

    CommandLog( Format( "%s<%s> ran command pk_cleanup on player %s<%s>", ply:Nick(), ply:SteamID(), target:Nick(), target:Nick() ) )
end )

/*---------------------------------------------------------
   Name: pk_setteam
   Desc: Scoreboard admin command to set players teams.
---------------------------------------------------------*/
concommand.Add( "pk_setteam", function( ply, cmd, args )
    if not ply:IsPlayer() or not args[1] then return end
    if not ply:IsAdmin() then ply:Notify( "You need to be an admin to use this command." ) return end

    local target = player.GetByUniqueID( args[1] )
    target:ChangeTeam( tonumber( args[2] ) ) -- tonumber because it makes it .00 after the number :/

    CommandLog( Format( "%s<%s> ran command pk_setteam on player %s<%s>", ply:Nick(), ply:SteamID(), target:Nick(), target:SteamID() ) )
end )

/*---------------------------------------------------------
   Name: pk_startfight
   Desc: This isnt called by the player themself, the derma menu will call this for them.
---------------------------------------------------------*/
concommand.Add( "pk_startfight", function( ply, cmd, args )
    if not ply:IsPlayer() then return end
    if ply:Team() == TEAM_SPECTATOR then ply:Notify( "You can't fight someone while in spectator!" ) return end

    if PK.LastFight and PK.LastFight > os.time() then
        ply:Notify( "Please wait another " .. string.FormattedTime( PK.LastFight - os.time(), "%02i:%02i" ) .. " minutes before trying to start a fight again." )
        return
    end

    if PK.FightInProgress then ply:Notify( "There's already a fight going on, wait your turn." ) return end

    if not args[1] then ply:Notify( "Couldn't find the player." ) return end

    local target = player.GetByUniqueID( args[1] )
    if not target:IsPlayer() then ply:Notify( "Couldn't find the player." ) return end

    if ply == target then ply:Notify( "You can't verse yourself." ) return end
    target.RequestedFight = true
    target.Fightie = ply
    target.Limit = math.Round( tonumber( args[2] ) )
    
    target.Limit = math.Clamp( target.Limit, 5, 20 )
    ply:Notify( Format( "You sent a battle invite to %s to %s kills.", target:Nick(), target.Limit ) )
	
    net.Start( "FightInvite", target )
        net.WriteString( ply:Nick() )
        net.WriteInt( target.Limit, 8 )
    net.Send(target)
end )
 
/*---------------------------------------------------------
   Name: pk_acceptfight
   Desc: This command will get called when you accept the fight in the derma menu.
---------------------------------------------------------*/
concommand.Add( "pk_acceptfight", function( ply )
    if not ply:IsPlayer() then return end
    if not ply.RequestedFight or not ply.Fightie:IsPlayer() then ply:Notify( "No one has offered a fight with you." ) return end

    ply.RequestedFight = false
    PK.LastFight = os.time() + GetSetting( "FightCoolDown" ) -- Minutes

    ply:StartFight( ply.Fightie, ply.Limit )
end )

/*---------------------------------------------------------
   Name: undoall
   Desc: Removes all the players props.
---------------------------------------------------------*/
concommand.Add( "undoall", function( ply )
    if not ply:IsPlayer() then return end

    local count = 0
    for _, v in pairs( ents.FindByClass( "prop_physics" ) ) do
		local owner = v.Owner or NULL
        if owner == ply then
            v:Remove()
            count = count + 1
        end
    end

    if count ~= 0 then
        if count == 1 then
            ply:Notify( "Cleaned up " .. count .. " prop!" )
        else
            ply:Notify( "Cleaned up " .. count .. " props!" )
        end
    end
end )

/*---------------------------------------------------------
   Name: pk_blockmodel
   Desc: Prevents the model from being spawned.
---------------------------------------------------------*/
concommand.Add( "pk_blockmodel", function( ply, cmd ,args )
    if not ply:IsPlayer() or not args[1] then return end
    if not ply:IsSuperAdmin() then ply:Notify( "You need to be a superadmin to use this command." ) return end

    local model = string.lower( args[1] )
    model = string.Replace( model, "\\", "/" )

    if table.HasValue( PK.BlockedModels, model ) then ply:Notify( "This model is already blocked." ) return end
    table.insert( PK.BlockedModels, model )
    ply:Notify( "You have blocked the model successfully!" )

    -- Find and remove props that have the same model :)
    for _, v in pairs( ents.FindByClass( "prop_physics" ) ) do
        if v:GetClass() == model then
            v:Remove()
            v.Owner:Notify( "One of your props has been removed because its been blocked." )
        end
    end

    file.Write( "propkill/blockedmodels.txt", util.TableToJSON( PK.BlockedModels ) )

    CommandLog( Format( "%s<%s> ran command pk_blockmodel on model %s", ply:Nick(), ply:SteamID(), model ) )
end )

/*---------------------------------------------------------
   Name: pk_unblockmodel
   Desc: Unblocks models from being spawned.
---------------------------------------------------------*/
concommand.Add( "pk_unblockmodel", function( ply, cmd, args )
    if not ply:IsPlayer() or not args[1] then return end
    if not ply:IsSuperAdmin() then ply:Notify( "You need to be a superadmin to use this command." ) return end

    local model = string.lower( args[1] )
    model = string.Replace( model, "\\", "/")

    if not table.HasValue( PK.BlockedModels, model ) then ply:Notify( "This model is not blocked." ) return end

    for k, v in pairs( PK.BlockedModels ) do
        if v == model then
            table.remove( PK.BlockedModels, k )
        end
    end
    ply:Notify( "You have unblocked the model successfully!" )

    file.Write( "propkill/blockedmodels.txt", util.TableToJSON( PK.BlockedModels ) )

    CommandLog( Format( "%s<%s> ran command pk_unblockmodel on model %s", ply:Nick(), ply:SteamID(), model ) )
end )

/*---------------------------------------------------------
   Name: Default sandbox cleanup commands for admins
   Desc: This will prevent admins abusing these commands to add default map props back into game.
---------------------------------------------------------*/
concommand.Add( "gmod_admin_cleanup", function() end )
concommand.Add( "gmod_cleanup", function() end )