/*---------------------------------------------------------
   Name: sv_networking.lua
   Desc: Serversided networking
   Author: G-Force Connections (STEAM_0:1:19084184)
---------------------------------------------------------*/

-- max short = 2^15 - 1 			= 32,767
-- max unsigned short = 2^16 - 1 	= 65,535
-- max int = 2^31 - 1 				= 2,147,483,647
-- max unsigned int = 2^32 - 1 		= 4,294,967,295

local VARTYPE_NONE 		= 0 	-- nil
local VARTYPE_ANGLE 	= 1 	-- Angle()
local VARTYPE_VECTOR 	= 2 	-- Vector()
local VARTYPE_BIT 		= 3 	-- 0/1
local VARTYPE_INT 		= 4 	-- -2,147,483,647 to 2,147,483,647
local VARTYPE_FLOAT		= 5 	-- Int's can not have .5 etc.
local VARTYPE_STRING	= 6 	-- "what"
local VARTYPE_ENTITY 	= 7 	-- Entity()
local VARTYPE_BOOLEAN   = 8		-- true/false
local VARTYPE_TABLE		= 9 	-- table!

----------------------------------------------------------
--				  Usermessage Pooling					--
----------------------------------------------------------

util.AddNetworkString( "SScore" )
util.AddNetworkString( "Achievement" )
util.AddNetworkString( "Achievements" )
util.AddNetworkString( "SendNotify" )
util.AddNetworkString( "GetDamage" )
util.AddNetworkString( "TopPlayers" )
util.AddNetworkString( "Setting" )
util.AddNetworkString( "PrecacheModels" )
util.AddNetworkString( "TopProps" )
util.AddNetworkString( "scoreboard" )
util.AddNetworkString( "Notify" )
util.AddNetworkString( "SendNotify" )
util.AddNetworkString( "FightPanel" )
util.AddNetworkString( "FightInvite" )
util.AddNetworkString( "PlayerKilledSelf" )
util.AddNetworkString( "PlayerKilledByPlayer" )
util.AddNetworkString( "pk_global" )
util.AddNetworkString( "pk_global_flush" )
util.AddNetworkString( "pk_private" )
util.AddNetworkString( "AddText" )

local function GetNWType( Value )
	if type( Value ) == "Angle" then
		return VARTYPE_ANGLE, net.WriteAngle
	elseif type( Value ) == "Vector" then
		return VARTYPE_VECTOR, net.WriteVector
	elseif type( Value ) == "number" and ( Value == 0 or Value == 1 ) then
		return VARTYPE_BIT, net.WriteBit
	elseif type( Value ) == "number" then
		if math.floor( Value ) ~= Value then
			return VARTYPE_FLOAT, net.WriteFloat
		end

		return VARTYPE_INT, net.WriteInt
	elseif type( Value ) == "string" then
		return VARTYPE_STRING, net.WriteString
	elseif type( Value ) == "NPC" or type( Value ) == "Entity" or type( Value ) == "Player" or type( Value ) == "Vehicle" then
		return VARTYPE_ENTITY, net.WriteEntity
	elseif type( Value ) == "boolean" then
		return VARTYPE_BOOLEAN, net.WriteBool
	elseif type( Value ) == "table" then
		return VARTYPE_TABLE
	end

	return VARTYPE_NONE
end

local function compressNWString( Value )
	local CompressedData = util.Compress( Value )
	net.WriteUInt( #CompressedData, 32 )
	net.WriteData( CompressedData, #CompressedData )
end

local function SendData( Type, Who, EntIndex, StringID, StringValue )
	local Enum, Func = GetNWType( StringValue )

	net.Start( Type )
		if Type == "pk_global" then net.WriteString( tostring( EntIndex ) ) end -- EntIndex

		net.WriteString( StringID )
		net.WriteInt( Enum, 8 )

		if Enum == VARTYPE_INT then
			net.WriteInt( StringValue, 32 )
		elseif Enum == VARTYPE_TABLE then
			compressNWString( util.TableToJSON( StringValue ) )
		else
			if Func then
				Func( StringValue )
			else
				if not StringValue == nil then
					ErrorNoHalt( "Missing ENUM: " .. type( StringValue ) .. " for " .. StringID .. "\n" )
				end
			end
		end

	if Type == "pk_global" and not Who then net.Broadcast() else net.Send( Who ) end
end

PK.GlobalData = PK.GlobalData or {} -- Global Entity Data

function SetGNWVar( StringID, StringValue )
	PK.GlobalData[ "Global" ] = PK.GlobalData[ "Global" ] or {}
	PK.GlobalData[ "Global" ][ StringID ] = StringValue

	if StringValue == nil then
		if table.Count( PK.GlobalData[ "Global" ] ) == 0 then
			PK.GlobalData[ "Global" ] = nil
		end
	end

	SendData( "pk_global", nil, "Global", StringID, StringValue )
end

function GetGNWVar( StringID, Default )
	return PK.GlobalData[ "Global" ] and PK.GlobalData[ "Global" ][ StringID ] or Default
end

local ENTITY = FindMetaTable( "Entity" )

function ENTITY:SetGNWVar( StringID, StringValue )
	local EntIndex = tostring( self:EntIndex() )

	PK.GlobalData[ EntIndex ] = PK.GlobalData[ EntIndex ] or {}
	PK.GlobalData[ EntIndex ][ StringID ] = StringValue

	if StringValue == nil then
		if table.Count( PK.GlobalData[ EntIndex ] ) == 0 then
			PK.GlobalData[ EntIndex ] = nil
		end
	end

	SendData( "pk_global", nil, EntIndex, StringID, StringValue )
end

function ENTITY:GetGNWVar( StringID, Default )
	local EntIndex = tostring( self:EntIndex() )

	return PK.GlobalData[ EntIndex ] and PK.GlobalData[ EntIndex ][ StringID ] or Default
end

function ENTITY:SendGNWVars()
	for EntIndex, Data in pairs( PK.GlobalData ) do
		if EntIndex ~= tostring( self:EntIndex() ) then
			for StringID, StringValue in pairs( Data ) do
				SendData( "pk_global", self, EntIndex, StringID, StringValue )
			end
		end
	end
end

hook.Add( "EntityRemoved", "GNWVarFlush", function( Entity )
	local EntIndex = tostring( Entity:EntIndex() )

	if not PK.GlobalData[ EntIndex ] then return end

	net.Start( "pk_global_flush" )
		net.WriteString( EntIndex )
	net.Broadcast()

	PK.GlobalData[ EntIndex ] = nil
end )

local PLAYER = FindMetaTable( "Player" )

function PLAYER:SetPNWVar( StringID, StringValue, DontSendToClient )
	self.PrivateData = self.PrivateData or {}

	self.PrivateData[ StringID ] = StringValue
	
	if not DontSendToClient then
		SendData( "pk_private", self, nil, StringID, StringValue )
	end
end

function PLAYER:GetPNWVar( StringID, Default )
	return self.PrivateData and self.PrivateData[ StringID ] or Default
end