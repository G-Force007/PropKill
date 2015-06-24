/*---------------------------------------------------------
   Name: sv_misc.lua
   Desc: Misc stuff I couldnt find anywhere else to put
   Author: G-Force Connections (STEAM_0:1:19084184)
---------------------------------------------------------*/

PK.Leading = NULL

COLOUR_DEFAULT = Color( 151, 211, 255, 255 )

/*---------------------------------------------------------
   Name: GetSetting
   Desc: Gets server settings.
---------------------------------------------------------*/
function GetSetting( key, default )
    local table = PK.Settings[ key ]
    return table and table.value or default
end

/*---------------------------------------------------------
   Name: SetSetting
   Desc: Sets server settings.
---------------------------------------------------------*/
function SetSetting( key, value, ply )
    if not PK.Settings[ key ] then return end

    PK.Settings[ key ].value = value

    -- Update all the superadmins on the server
    for _, v in pairs( player.GetAll() ) do
        if not PK.Settings[ key ].public and not v:IsSuperAdmin() then continue end

        local type = PK.Settings[ key ].type
        if type == SETTING_NUMBER then
            net.Start( "Setting" )
                net.WriteString( key ) -- name
                net.WriteInt( type, 32 )
                net.WriteString( PK.Settings[ key ].desc )
                net.WriteInt( value, 32 )
                net.WriteInt( PK.Settings[ key ].min, 32 )
                net.WriteInt( PK.Settings[ key ].max, 32 )
            net.Send( v )
        elseif type == SETTING_BOOLEAN then
            net.Start( "Setting", v )
                net.WriteString( key )
                net.WriteInt( type, 32 )
                net.WriteString( PK.Settings[ key ].desc )
                net.WriteBool( value )
            net.Send( v )
        end
    end

    WritePKSettings()
end

function chatAddText( ... )
  local arg = { ... }

  if type( arg[1] ) == "Player" then ply = arg[1] end
  
  net.Start( "AddText" )
  net.WriteInt( #arg, 32 )
  for _, v in pairs( arg ) do
    if type( v ) == "string" then
      net.WriteString( v )
    elseif type( v ) == "table" then
      net.WriteColor( v )
    end
  end
  if not ply then net.Broadcast() else net.Send( ply ) end
end

/*---------------------------------------------------------
   Name: sortTopPlayers
   Desc: This is what orders the top10 players.
---------------------------------------------------------*/
function table.sortTopPlayers( tbl, count )
    local tbl2 = {}

    for _, v in pairs( tbl ) do
        if v.Name == nil or v.Name == "" or v.Kills == nil or v.Deaths == nil or v.Kills == 0 or v.Deaths == 0 then continue end
        table.insert( tbl2, v )
    end
	
    table.sort( tbl2, function( x, y )
        return tonumber( x.Kills ) / tonumber( x.Deaths ) > tonumber( y.Kills ) / tonumber( y.Deaths )
    end )
	
    local tbl3 = {}
    for i = 1, count do
        table.insert( tbl3, tbl2[ i ] )
    end
	
    return tbl3
end

/*---------------------------------------------------------
   Name: SendNotifyAll
   Desc: This sends a message to every player.
---------------------------------------------------------*/
function SendNotifyAll( text, ignore, colour )
    for _, v in pairs( player.GetAll() ) do
        if v:IsBot() then continue end
        if type( ignore ) == "table" then if table.HasValue( ignore, v ) then continue end end
        if type( ignore ) == "Player" then if v == ignore then continue end end

        net.Start( "SendNotify" )
            net.WriteString( text )
            net.WriteString( util.TableToJSON( colour or Color( 194, 255, 72, 255 ) ) )
        net.Send( v )
    end
end

/*---------------------------------------------------------
   Name: sortSpawns
   Desc: This sorts most spawned props for Precache and Most used props.
---------------------------------------------------------*/
function table.sortSpawns( tbl, count )
    local tbl = tbl
    local tbl2 = {}
    for k, v in pairs( tbl ) do
        v.Model = k
        table.insert( tbl2, v )
    end
    
    -- I use tonumber because the number turns into a string for some weird reason.
    table.sort( tbl2, function( x, y ) return tonumber( x.Spawns ) > tonumber( y.Spawns ) end )

    -- remove model from table, redudant...
    local tbl3 = {}
    for i = 1, count do
      if not tbl2[ i ] then continue end
      tbl3[ tbl2[ i ].Model ] = tbl2[ i ]
      tbl3[ tbl2[ i ].Model ].Model = nil
    end

    return tbl3
end

/*---------------------------------------------------------
   Name: NotifyPlayersAboutSpec
   Desc: If youre spectator this will be sent to you every 45 seconds.
---------------------------------------------------------*/
timer.Create( "NotifyPlayersAboutSpec", 45, 0, function()
	if PK.FightInProgress then return end
    for _, v in pairs( player.GetAll() ) do
        if v:IsBot() then continue end
        if v:Team() == TEAM_SPECTATOR then
            v:Notify( "You have to join a team by pressing F4!" )
        end
    end
end )

/*---------------------------------------------------------
   Name: TTT SHIT
   Desc: Copied from TTT, this helps spectate players.
---------------------------------------------------------*/
function GetAlivePlayers()
    local aliveplayers = {}
    for _, v in pairs( player.GetAll() ) do
        if v:Alive() and v:Team() ~= TEAM_SPECTATOR then table.insert( aliveplayers, v ) end
    end
    return aliveplayers or nil
end

function GetNextAlivePlayer( ply )
   local alive = GetAlivePlayers()
   
   if #alive < 1 then return nil end

   local prev = nil
   local choice = nil

   if IsValid( ply ) then
      for k, p in pairs( alive ) do
         if prev == ply then
            choice = p
         end

         prev = p
      end
   end

   if not IsValid( choice ) then
      choice = alive[1]
   end

   return choice
end

hook.Add( "KeyPress", "gspec.KeyPress", function( ply, key )
   if not IsValid( ply ) then return end

   -- Spectator keys
   if ply:GetGNWVar( "IsSpectating", false ) then

      ply:ResetViewRoll()

      if key == IN_ATTACK then
         -- snap to random guy
         ply:Spectate( OBS_MODE_ROAMING )
         ply:SpectateEntity( nil )

         local alive = GetAlivePlayers()

         if #alive < 1 then return end

         local target = table.Random( alive )
         if IsValid( target ) then
            ply:SetPos( target:EyePos() )
         end
      elseif key == IN_ATTACK2 then
         -- spectate either the next guy or a random guy in chase
         local target = GetNextAlivePlayer( ply:GetObserverTarget() )

         if IsValid( target ) then
            ply:Spectate( ply.spec_mode or OBS_MODE_CHASE )
            ply:SpectateEntity( target )
         end
      elseif key == IN_DUCK then
         local pos = ply:GetPos()
         local ang = ply:EyeAngles()

         local target = ply:GetObserverTarget()
         if IsValid( target ) and target:IsPlayer() then
            pos = target:EyePos()
            ang = target:EyeAngles()
         end

         -- reset
         ply:Spectate( OBS_MODE_ROAMING )
         ply:SpectateEntity( nil )

         ply:SetPos( pos )
         ply:SetEyeAngles( ang )
         return true
      elseif key == IN_JUMP then
         -- unfuck if you're on a ladder etc
         if not ( ply:GetMoveType() == MOVETYPE_NOCLIP ) then
            ply:SetMoveType( MOVETYPE_NOCLIP )
         end
      elseif key == IN_RELOAD then
         local tgt = ply:GetObserverTarget()
         if not IsValid( tgt ) or not tgt:IsPlayer() then return end

         if not ply.spec_mode or ply.spec_mode == OBS_MODE_CHASE then
            ply.spec_mode = OBS_MODE_IN_EYE
         elseif ply.spec_mode == OBS_MODE_IN_EYE then
            ply.spec_mode = OBS_MODE_CHASE
         end
         -- roam stays roam

         ply:Spectate( ply.spec_mode )
      end
   end
end )
