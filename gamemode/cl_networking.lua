/*---------------------------------------------------------
   Name: cl_networking.lua
   Desc: Clientsided networking
   Author: G-Force Connections (STEAM_0:1:19084184)
---------------------------------------------------------*/

PK.GlobalData = PK.GlobalData or {}

local VARTYPE_NONE 		= 0
local VARTYPE_ANGLE 	= 1
local VARTYPE_VECTOR 	= 2
local VARTYPE_BIT 		= 3
local VARTYPE_INT 		= 4
local VARTYPE_FLOAT		= 5
local VARTYPE_STRING	= 6
local VARTYPE_ENTITY 	= 7
local VARTYPE_BOOLEAN = 8
local VARTYPE_TABLE 	= 9


local function GetNWType( Value )
	if Value == VARTYPE_ANGLE then
		return VARTYPE_ANGLE, net.ReadAngle
	elseif Value == VARTYPE_VECTOR then
		return VARTYPE_VECTOR, net.ReadVector
	elseif Value == VARTYPE_BIT then
		return VARTYPE_BIT, net.ReadBit
	elseif Value == VARTYPE_INT then
		return VARTYPE_INT, net.ReadInt
	elseif Value == VARTYPE_FLOAT then
		return VARTYPE_FLOAT, net.ReadFloat
	elseif Value == VARTYPE_STRING then
		return VARTYPE_STRING, net.ReadString
	elseif Value == VARTYPE_ENTITY then
		return VARTYPE_ENTITY, net.ReadEntity
  elseif Value == VARTYPE_BOOLEAN then
    return VARTYPE_BOOLEAN, net.ReadBool
	elseif Value == VARTYPE_TABLE then
		return VARTYPE_TABLE
	end
	
	return VARTYPE_NONE
end

net.Receive( "pk_global", function()
	local EntIndex 	= net.ReadString()
	local ID 		    = net.ReadString()
	local Type 		  = net.ReadInt( 8 )
	local Value

	local Enum, Func = GetNWType( Type )

	if Enum == VARTYPE_INT then
		Value = net.ReadInt( 32 )
	elseif Enum == VARTYPE_TABLE then
		Value = util.JSONToTable( util.Decompress( net.ReadData( net.ReadUInt( 32 ) ) ) )
	elseif Func then
		Value = Func()
	end

	PK.GlobalData[ EntIndex ] = PK.GlobalData[ EntIndex ] or {}
	PK.GlobalData[ EntIndex ][ ID ] = Value

	if Value == nil then
		if table.Count( PK.GlobalData[ EntIndex ] ) == 0 then
			PK.GlobalData[ EntIndex ] = nil
		end
	end
end )

function GetGNWVar( StringID, Default )
	return PK.GlobalData[ "Global" ] and PK.GlobalData[ "Global" ][ StringID ] or Default
end

local ENTITY = FindMetaTable( "Entity" )

function ENTITY:GetGNWVar( StringID, Default )
	local EntIndex = tostring( self:EntIndex() )

	return PK.GlobalData[ EntIndex ] and PK.GlobalData[ EntIndex ][ StringID ] or Default
end

net.Receive( "pk_global_flush", function()
	PK.GlobalData[ net.ReadString() ] = nil
end )

PK.PrivateData = PK.PrivateData or {}

net.Receive( "pk_private", function()
	local ID 	= net.ReadString()
	local Type 	= net.ReadInt( 4 )
	local Value

	local Enum, Func = GetNWType( Type )

	if Enum == VARTYPE_INT then
		Value = net.ReadInt( 32 )
	elseif Func then
		Value = Func()
	end

	PK.PrivateData[ ID ] = Value
end )

local PLAYER = FindMetaTable( "Player" )

function PLAYER:GetPNWVar( ID, Default )
	return PK.PrivateData[ ID ] or Default
end

/*---------------------------------------------------------
   Name: Achievement
   Desc: This usermessage will be called apon a player getting new scores for their Achievements, instead of using the function above, it will only have a few less information rather than a massive table.
---------------------------------------------------------*/
net.Receive( "Achievement", function()
    local ply = net.ReadEntity()
    local key = net.ReadString()
    local value = net.ReadInt( 15 )
    if not ply.Achievements then ply.Achievements = {} end -- remember to setup the achievements table here.
    ply.Achievements[ key ] = value
end )

/*---------------------------------------------------------
   Name: Achievements
   Desc: This usermessage will only be called when you first join the server or when another player joins the server, the information you get in this will return all of the players Achievement scores which then can be viewed in Scoreboard, the function below will be called instead every Achievement changed.
---------------------------------------------------------*/
net.Receive( "Achievements", function()
    local ply = net.ReadEntity()
    if not ply or not ply:IsPlayer() then return end -- Sadly, this player is unavailable :(

    if not ply.Achievements then ply.Achievements = {} end -- remember to setup the achievements table here.
    local achievements = util.JSONToTable( net.ReadString() )
    for k, v in pairs( achievements ) do
        ply.Achievements[ k ] = v
    end
end )

/*---------------------------------------------------------
   Name: Setting
   Desc: This will get the settings needed for the admin panel :)
   SETTING_NUMBER n shit is set up in sh_init.lua
---------------------------------------------------------*/
PK.Settings = PK.Settings or {}

net.Receive( "Setting", function()
    local name = net.ReadString()
    local type = net.ReadInt( 32 )
    local desc = net.ReadString()
    local exists = PK.Settings[ name ]

    PK.Settings[ name ] = {}
    PK.Settings[ name ].type = type
    PK.Settings[ name ].desc = desc

    if type == SETTING_NUMBER then
        PK.Settings[ name ].value = net.ReadInt(32)
        PK.Settings[ name ].min = net.ReadInt(32) or PK.Settings[ name ].min
        PK.Settings[ name ].max = net.ReadInt(32) or PK.Settings[ name ].max
    elseif type == SETTING_BOOLEAN then
        PK.Settings[ name ].value = net.ReadBool()
    end

    if not exists then
      GAMEMODE:Msg( Format( "Registered setting ID: %s Value: %s", name, tostring( PK.Settings[ name ].value ) ) )
    else
      GAMEMODE:Msg( Format( "Updated setting ID: %s Value: %s", name, tostring( PK.Settings[ name ].value ) ) )
    end
end )

/*---------------------------------------------------------
   Name: SendNotify
   Desc: This usermessage is called when a player kills someone or does something to do with achievements and is the little text on the right bottom corner which alerts you when shit happens. This gets put into a global table and called at different times so they dont all clog up.
---------------------------------------------------------*/
net.Receive( "SendNotify", function()
    local Message = {}
    Message.text = net.ReadString()
    Message.colour = util.JSONToTable( net.ReadString() )
    Message.posx = 13
    Message.posy = ScrH() - ( 26 * 5 )
    table.insert( PK.MessageToRender, Message )

    GAMEMODE:Msg( Message.text )
end )

/*---------------------------------------------------------
   Name: GetDamage
   Desc: This will show the damage done in the HUD like the SendNotify above :D
---------------------------------------------------------*/
net.Receive( "GetDamage", function()
   local Dmg = {}
   Dmg.Pos = net.ReadVector()
   Dmg.Amount = math.Round( net.ReadInt( 32 ) )
   Dmg.RemoveTime = net.ReadInt( 32 )
   table.insert( PK.DamageToRender, Dmg )
end )

/*---------------------------------------------------------
   Name: PrecacheModel
   Desc: This function will send you the most used models which is mostly just 20 and then precaches all of them and puts into the most used table because the player would like to see which are the most used. Since the server will have lots of players spawning lots of props, the "MostUsedProps" wont change, much.
---------------------------------------------------------*/
PK.MostUsedProps = PK.MostUsedProps or {}

net.Receive( "PrecacheModels", function()
  local data = util.JSONToTable( util.Decompress( net.ReadData( net.ReadUInt( 32 ) ) ) )
  if not data then return end

  for _, v in pairs( data ) do
    util.PrecacheModel( v )
    table.insert( PK.MostUsedProps, v )
  end
end )

/*---------------------------------------------------------
   Name: Notify
   Desc: Instead of using LuaRun shit on serverside, Ive made a usermessage that gets sent to the client which is much easier.
---------------------------------------------------------*/
net.Receive( "Notify", function()
    GAMEMODE:AddNotify( net.ReadString(), NOTIFY_HINT, 5 )
    surface.PlaySound( "buttons/button15.wav" )
end )

/*---------------------------------------------------------
   Name: TopPlayer
   Desc: Adds a player listing to the F4 top10 derma.
---------------------------------------------------------*/
net.Receive( "TopPlayers", function()
  local data = util.JSONToTable( util.Decompress( net.ReadData( net.ReadUInt( 32 ) ) ) )
  if not data then return end

  for k, v in pairs( data ) do
    local result
    if v.Kills == 0 or v.Deaths == 0 then
        result = "1:1"
    else
        result = math.Round( v.Kills / v.Deaths, 2 ) .. ":1"
    end

    Top10Players:AddLine( v.Name, v.Kills, v.Deaths, result )
  end

  Top10Players:SortByColumn( 4, true )
end )

/*---------------------------------------------------------
   Name: FightInvite
   Desc: You will get this usermessage which opens a menu in the middle of your screen so you can either accept/deny a fight with someone.
---------------------------------------------------------*/
local open = false
local auto_close = 45
local F

net.Receive( "FightInvite", function()
    if open then
        F:Remove()
        timer.Destroy( "pushLink" )
    end

    F = vgui.Create( "DFrame" )
    F:SetTitle( "Fight Invite" )
    F:SetSize( 200, 135 )
    F:SetVisible( true )
    F:MakePopup()
    F:SetDraggable( false )
    F:ShowCloseButton( false )
    F:SetSkin( "DarkRP" )
    F:Center( true )

    local DPanelList = vgui.Create( "DPanelList", F )
    DPanelList:SetPos( 4, 25 )
    DPanelList:SetSize( 192, 106 )
    DPanelList.Paint = function()
        surface.SetDrawColor( 50, 50, 50, 255 )
        surface.DrawRect( 0, 0, DPanelList:GetWide(), DPanelList:GetTall() )
    end
    DPanelList:SetSpacing( 5 )

    local text = vgui.Create( "DLabel" )
    text:SetText( net.ReadString() ) -- Player name
    text:SetWrap( true )
    DPanelList:AddItem( text )

    local text = vgui.Create( "DLabel" )
    text:SetText( Format( "wants to fight with you to %i deaths!", net.ReadInt( 8 ) ) )
    text:SetWrap(true)
    DPanelList:AddItem( text )

    local link_button = vgui.Create( "DButton" )
    link_button:SetText( "Fight" )
    link_button.DoClick = function()
        RunConsoleCommand( "pk_acceptfight" )
        F:Remove()
        open = false
    end
    DPanelList:AddItem( link_button )

    local close_button = vgui.Create( "DButton" )
    close_button:SetPos( F:GetWide() - 50, 110 )
    close_button:SetText( "Ignore" )
    close_button.DoClick = function()
        F:Remove()
        open = false
    end
    DPanelList:AddItem( close_button )

    open = true

    timer.Create( "pushLink", auto_close, 1, function()
        if open then
            F:Remove()
            open = false
        end
    end )
end )

net.Receive( "AddText", function()
  local argc = net.ReadInt( 32 )
  local args = {}

  for i = 1, argc / 2, 1 do
    table.insert( args, net.ReadColor() )
    table.insert( args, net.ReadString() )
  end

  chat.AddText( unpack( args ) )
end )