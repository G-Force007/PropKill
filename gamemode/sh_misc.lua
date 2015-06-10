/*---------------------------------------------------------
   Name: sh_misc.lua
   Desc: Misc stuff I couldnt find anywhere else to put
   Author: G-Force Connections (STEAM_0:1:19084184)
---------------------------------------------------------*/

/*---------------------------------------------------------
   Name: GetSetting
   Desc: Gets server settings.
---------------------------------------------------------*/
function GetSetting( key, default )
    local table = PK.Settings[ key ]
    return table and table.value or default
end