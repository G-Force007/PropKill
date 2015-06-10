/*---------------------------------------------------------
   Name: sh_teams.lua
   Desc: Originally based off DarkRP, the AddTeam function is from DarkRP but modified.
   Author: G-Force Connections (STEAM_0:1:19084184)
---------------------------------------------------------*/

Teams = {}
function AddTeam( Name, color, model, Description, command, admin )
    local CustomTeam = { name = Name, model = model, Des = Description, command = command }
    table.insert( Teams, CustomTeam )
    team.SetUp( #Teams, Name, color )
    local Team = #Teams

    if type( model ) == "table" then
        for _, v in pairs( model ) do util.PrecacheModel( v ) end
    else 
        util.PrecacheModel( model )
    end

    return Team
end