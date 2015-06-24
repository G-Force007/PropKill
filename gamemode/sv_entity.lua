-- Author: G-Force Connections (STEAM_0:1:19084184)

/*---------------------------------------------------------
   Name: PhysgunPickup
   Desc: This allows/disallows you to pick a prop, is called everytime you try picking up a prop.
---------------------------------------------------------*/
function GM:PhysgunPickup( ply, ent )
	if ent:IsPlayer() or ent.Owner ~= ply then return false end

	return true
end

-- Remove ULX's access to pickup players.
if ulx then
	timer.Create( "Pickupaccessremove", 5, 0, function()
		local hooks = hook.GetTable()[ "PhysgunPickup" ]

		if hooks and hooks[ "ulxPlayerPickup" ] then
			hook.Remove( "PhysgunPickup", "ulxPlayerPickup" )
			timer.Destroy( "Pickupaccessremove" )
		end
	end )
end

/*---------------------------------------------------------
   Name: OnPhysgunFreeze
   Desc: This allows/disallows you to freeze a prop, is called everytime you try freezing a prop.
---------------------------------------------------------*/
function GM:OnPhysgunFreeze( weapon, phys, ent, ply )
	if ent.Owner ~= ply then return false end
	self.BaseClass:OnPhysgunFreeze( weapon, phys, ent, ply )
end

/*---------------------------------------------------------
   Name: OnPhysgunReload
   Desc: This is meant to be called when you try to press the reload button twice to unfreeze all constrained props, but since there isnt any because you get no toolgun, I leave it at false.
---------------------------------------------------------*/
function GM:OnPhysgunReload() return false end

/*---------------------------------------------------------
   Name: EntityRemoved
   Desc: Called when you remove a prop, and is meant to cleanup seen props.
---------------------------------------------------------*/
function GM:EntityRemoved( ent )
	if ent:IsPlayer() then return end -- do i need to explain? lol
end

/*---------------------------------------------------------
   Name: PlayerSpawnProp
   Desc: Allows/disallows you to spawn a prop.
---------------------------------------------------------*/
function GM:PlayerSpawnProp( ply, model )
	if not self.BaseClass:PlayerSpawnProp( ply, model ) then return false end

	-- credits to DarkRP
	model = string.lower( model or "" )
	model = string.Replace( model, "\\", "/" )
	model = string.gsub( model, "[\\/]+", "/" )

	-- blocked model
	if table.HasValue( PK.BlockedModels, string.lower( model ) ) then 
		ply:Notify( "This is a blocked model!" )
		return false
	end

	-- exploitable?
	if string.find( model, "../", 1, true ) then
		ply:Notify( "Nice try!" )
		return false
	end

	if GetSetting( "DenyDeadSpawning" ) then
		if not ply:Alive() or ply:GetGNWVar( "IsSpectating", false ) or ply:Team() == TEAM_SPECTATOR then
			if not ply:Alive() then
				ply:Notify( "Can't spawn props while dead!" )
			elseif ply:GetGNWVar( "IsSpectating", false ) or ply:Team() == TEAM_SPECTATOR then
				ply:Notify( "Can't spawn props while spectating!" )
			end

			return false
		end
	end

	if GetSetting( "DenySpawningWhileSpawnGoded" ) then
		if ply.SpawnGoded then ply:Notify( "Can't spawn props while spawn goded!" ) return false end
	end

	local ModelData = PK.PropSpawns[ model ]

	-- Update the models spawned etc, for most spawned models :)
	if not ModelData then
		ModelData = { Spawns = 1, LastSpawn = os.time() }
        PK.PropSpawns[ model ] = ModelData
    else
        ModelData.Spawns = ModelData.Spawns + 1
        ModelData.LastSpawn = os.time()
    end

    PK.SaveData = true -- save changes

	return true
end

/*---------------------------------------------------------
   Name: PlayerSpawnedProp
   Desc: Sets the owner of the prop you spawned and extra shit.
---------------------------------------------------------*/
function GM:PlayerSpawnedProp( ply, model, ent )
	self.BaseClass:PlayerSpawnedProp( ply, model, ent )

	-- Save the owner
	ent.Owner = ply
	ent:SetGNWVar( "owner", ply );

	-- We add a new key value to the prop so we can remove the prop with come custom effects ;3
	ent:SetKeyValue( "targetname", "prop_physics_" .. ply:UniqueID() .. ply:Deaths() )

	ply:SetAchievement( "PropsSpawned" , ply:GetAchievement( "PropsSpawned" ) + 1, true )
end

/*---------------------------------------------------------
   Name: OnEntityCreated
   Desc: When an entity it created
---------------------------------------------------------*/
function GM:OnEntityCreated( entity )
	self.BaseClass:OnEntityCreated( entity )

	entity:AddCallback( "PhysicsCollide", function( entity, data )
		local physobj = data.HitObject
		local physobj2 = data.PhysObject
		local entity2 = data.HitEntity

		-- Only worry about props!!!
		if entity:GetClass() ~= "prop_physics" or entity2:GetClass() ~= "prop_physics" then return end

		if physobj:IsPenetrating() or physobj2:IsPenetrating() then
			physobj:EnableMotion( false )
			physobj2:EnableMotion( false )
		end
	end )
end

/*---------------------------------------------------------
   Name: EntityTakeDamage
   Desc: When an entity takes damage
---------------------------------------------------------*/
function GM:EntityTakeDamage( entity, dmginfo )
	self.BaseClass:EntityTakeDamage( entity, dmginfo )

	if entity:GetClass() == "prop_physics" then
		dmginfo:SetDamage( 0 )
	end
end

/*---------------------------------------------------------
   Name: InitPostEntity
   Desc: Removes props/doors etc when the map is loaded because we do not need all this extra useless shit to lag the server.
---------------------------------------------------------*/
function GM:InitPostEntity()
	local physData = physenv.GetPerformanceSettings()
	if physData then
		-- limit world space linear velocity to this (in / s)
		physData.MaxVelocity = 2200

		-- limit world space angular velocity to this (degrees / s)
		physData.MaxAngularVelocity	= 3636

		-- object will be frozen after this many collisions (visual hitching vs. CPU cost)
		physData.MaxCollisionsPerObjectPerTimestep = 100

		-- predict collisions this far (seconds) into the future
		physData.LookAheadTimeObjectsVsObject = 1

		physenv.SetPerformanceSettings( physData )
	end

	if not PK or not GetSetting( "CleanupOnStart" ) then return end

	for _, v in pairs( ents.GetAll() ) do
		if not v:IsPlayer() and string.find( v:GetClass(), "prop_physics" ) or
			string.find( v:GetClass(), "prop_dynamic" ) or
			string.find( v:GetClass(), "prop_door" ) or
			string.find( v:GetClass(), "func_breakable_surf" ) or
			string.find( v:GetClass(), "func_door" ) or
			string.find( v:GetClass(), "func_useableladder" ) or
			string.find( v:GetClass(), "func_illusionary" ) or
			string.find( v:GetClass(), "beam" ) or
			string.find( v:GetClass(), "env_sprite" ) then
			v:Remove()
		end
	end
end

/*---------------------------------------------------------
   Name: Sandbox functions
   Desc: Prevent spawning any items other than props.
---------------------------------------------------------*/
function GM:PlayerSpawnSENT( ply, model ) ply:Notify( "You can only spawn props." ) return false end
function GM:PlayerSpawnSWEP( ply, model ) ply:Notify( "You can only spawn props." ) return false end
function GM:PlayerGiveSWEP( ply, model ) ply:Notify( "You can only spawn props." ) return false end
function GM:PlayerSpawnEffect( ply, model ) ply:Notify( "You can only spawn props." ) return false end
function GM:PlayerSpawnVehicle( ply, model ) ply:Notify( "You can only spawn props." ) return false end
function GM:PlayerSpawnNPC( ply, model ) ply:Notify( "You can only spawn props." ) return false end
function GM:PlayerSpawnRagdoll( ply, model ) ply:Notify( "You can only spawn props." ) return false end
function GM:PlayerSpawnSENT( ply, model ) ply:Notify( "You can only spawn props." ) return false end
function GM:CanProperty( ply, cmd, ent ) ply:Notify( "You can't do that." ) return false end