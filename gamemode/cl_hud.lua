/*---------------------------------------------------------
   Name: cl_hud.lua
   Desc: This contains stuff from jdraw which is orginally from another gamemode Ive only modified the functions to work with my gamemode and show different stuff.
   Author: G-Force Connections (STEAM_0:1:19084184)
---------------------------------------------------------*/

local jdraw = {}
local matGradiantDown = surface.GetTextureID( "gui/gradient_down" )
local matGradiantUp = surface.GetTextureID( "gui/gradient_up" )

surface.CreateFont( "UiBold", {
		font    = "tahoma",
		size    = 12,
		weight  = 1000,
		antialias = true,
		shadow = false
	}
)

surface.CreateFont( "DamageIndicFont6", {
	font    = "coolvetica",
	size    = 35,
	weight  = 400,
	antialias = false,
	shadow = false
	}
)

function jdraw.NewPanel(tblParent, boolCopyStyle)
	local tblNewPanel = {}
	tblNewPanel.Position = {}
	tblNewPanel.Position.X = 0
	if tblParent then tblNewPanel.Position.X = tblParent.Position.X end
	tblNewPanel.Position.Y = 0
	if tblParent then tblNewPanel.Position.Y = tblParent.Position.Y end
	tblNewPanel.Size = {}
	tblNewPanel.Size.Width = 0
	tblNewPanel.Size.Height = 0
	function tblNewPanel:SetDemensions(intX, intY, intWidth, intHeight)
		tblNewPanel.Position.X = tblNewPanel.Position.X + intX
		tblNewPanel.Position.Y = tblNewPanel.Position.Y + intY
		tblNewPanel.Size.Width = intWidth
		tblNewPanel.Size.Height = intHeight
	end
	tblNewPanel.Radius = 0
	if tblParent && boolCopyStyle then tblNewPanel.Radius = tblParent.Radius end
	tblNewPanel.Color = Color(255, 255, 255, 255)
	if tblParent && boolCopyStyle then tblNewPanel.Color = tblParent.Color end
	function tblNewPanel:SetStyle(intRadius, clrColor)
		tblNewPanel.Radius = intRadius
		tblNewPanel.Color = clrColor
	end
	tblNewPanel.Boarder = 0
	if tblParent && boolCopyStyle then tblNewPanel.Boarder = tblParent.Boarder end
	tblNewPanel.BoarderColor = Color(255, 255, 255, 255)
	if tblParent && boolCopyStyle then tblNewPanel.BoarderColor = tblParent.BoarderColor end
	function tblNewPanel:SetBoarder(intBoarder, clrBoarderColor)
		tblNewPanel.Boarder = intBoarder
		tblNewPanel.BoarderColor = clrBoarderColor
	end
	return tblNewPanel
end

function jdraw.DrawPanel(tblPanelTable)
	local intRadius = tblPanelTable.Radius or 0
	local intBoarder = tblPanelTable.Boarder or 0
	local intX, intY = tblPanelTable.Position.X, tblPanelTable.Position.Y
	local intWidth, intHeight = tblPanelTable.Size.Width, tblPanelTable.Size.Height
	if tblPanelTable.Boarder > 0 then
		draw.RoundedBox(intRadius, intX, intY, intWidth, intHeight, tblPanelTable.BoarderColor)
		draw.RoundedBox(intRadius, intX + intBoarder, intY + intBoarder, intWidth - (intBoarder * 2), intHeight - (intBoarder * 2), tblPanelTable.Color)
	else
		draw.RoundedBox(intRadius, intX, intY, intWidth, intHeight, tblPanelTable.Color)
	end
end

function jdraw.NewProgressBar(tblParent, boolCopyStyle)
	local tblNewPanel = jdraw.NewPanel(tblParent, boolCopyStyle)
	tblNewPanel.Value = 0
	tblNewPanel.MaxValue = 0
	function tblNewPanel:SetValue(intValue, intMaxValue)
		tblNewPanel.Value = intValue
		tblNewPanel.MaxValue = intMaxValue or 0
	end
	tblNewPanel.Font = "Default"
	tblNewPanel.Text = ""
	tblNewPanel.TextColor = Color(255, 255, 255, 255)
	function tblNewPanel:SetText(strFont, strText, clrtextColor)
		tblNewPanel.Font = strFont
		tblNewPanel.Text = strText
		tblNewPanel.TextColor = clrtextColor
	end
	return tblNewPanel
end

function jdraw.DrawProgressBar(tblPanelTable)
	local intRadius = tblPanelTable.Radius or 0
	local intBoarder = tblPanelTable.Boarder or 0
	local intX, intY = tblPanelTable.Position.X, tblPanelTable.Position.Y
	local intWidth, intHeight = tblPanelTable.Size.Width, tblPanelTable.Size.Height
	local intValue = tblPanelTable.Value
	local intMaxValue = tblPanelTable.MaxValue
	local intBarWidth = ((intWidth - (intBoarder * 2)) / intMaxValue) * intValue
	local strText = tblPanelTable.Text
	if intRadius > intBarWidth then intRadius = 1 end
	draw.RoundedBox(intRadius, intX, intY, intWidth, intHeight, tblPanelTable.BoarderColor)
	draw.RoundedBox(intRadius, intX + intBoarder, intY + intBoarder, intWidth  - (intBoarder * 2), intHeight - (intBoarder * 2), clrGray)
	surface.SetDrawColor(0, 0, 0, 70)
	surface.SetTexture(matGradiantDown)
	surface.DrawTexturedRect(intX, intY, intWidth, intHeight)
	if intValue > 0 then
		draw.RoundedBox(intRadius, intX + intBoarder, intY + intBoarder, intBarWidth, intHeight - (intBoarder * 2), tblPanelTable.Color)
		surface.SetDrawColor(0, 0, 0, 100)
		surface.SetTexture(matGradiantUp)
		surface.DrawTexturedRect(intX + intBoarder, intY + intBoarder, intBarWidth, intHeight - (intBoarder * 2))
	end
	if strText && strText != "" then
		draw.SimpleText(strText, tblPanelTable.Font, intX + (intWidth / 2), intY + (intHeight / 2), tblPanelTable.TextColor, 1, 1)
	end
end

function jdraw.DrawHealthBar(intHealth, intMaxHealth, intX, intY, intWidth, intHeight, strPreHealth)
	intHealth = math.Clamp(intHealth, 0, 9999)
	intMaxHealth = intMaxHealth or 100
	local clrBarColor = Color( PK.Settings[ "health_r" ]:GetInt(), PK.Settings[ "health_g" ]:GetInt(), PK.Settings[ "health_b" ]:GetInt(), 255 )
	local tblNewHealthBar = jdraw.NewProgressBar()
	tblNewHealthBar:SetDemensions(intX, intY, intWidth, intHeight)
	tblNewHealthBar:SetStyle(4, clrBarColor)
	tblNewHealthBar:SetBoarder(1, clrDrakGray)
	tblNewHealthBar:SetText("UiBold", (strPreHealth or "") .. intHealth, clrDrakGray)
	tblNewHealthBar:SetValue(intHealth, intMaxHealth)
	jdraw.DrawProgressBar(tblNewHealthBar)
end

function jdraw.DrawIcon(strIcon, intX, intY, intWidth, intHeight)
	strIcon = strIcon or "gui/player"
	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetTexture(surface.GetTextureID(strIcon))
	surface.DrawTexturedRect(intX, intY, intWidth, intHeight or intWidth)
end

function jdraw.QuickDrawPanel(clrColor, intX, intY, intWidth, intHeight)
	local tblNewPanel = jdraw.NewPanel()
	tblNewPanel:SetDemensions(intX, intY, intWidth, intHeight or intWidth)
	tblNewPanel:SetStyle(4, clrColor)
	tblNewPanel:SetBoarder(1, clrDrakGray)
	jdraw.DrawPanel(tblNewPanel)
end

function jdraw.QuickDrawGrad(clrColor, intX, intY, intWidth, intHeight, intDir)
	surface.SetDrawColor(clrColor)
	surface.SetTexture(matGradiantUp)
	if intDir == -1 then surface.SetTexture(matGradiantDown) end
	surface.DrawTexturedRect(intX, intY, intWidth, intHeight)
end

PK.MessageToRender = {}
PK.DamageToRender = {}
local ShowLastMessage
local Target

clrGray = Color(97, 95, 90, 255)
clrGreen = Color(194, 255, 72, 255)
clrOrange = Color(255, 137, 44, 255)
clrPurple = Color(135, 81, 201, 255)
clrBlue = Color(59, 142, 209, 255)
clrRed = Color(191, 75, 37, 255)
clrTan = Color(178, 161, 126, 255)
clrCream = Color(245, 255, 154, 255)
clrMooca = Color(107, 97, 78, 255)
clrWhite = Color(242, 242, 242, 255)

GM.PlayerHUDBarWidth = 300
local intCrossHairAngle = 45
local function fncGetAnglesCos(intAngle, intSize)
	return math.cos(math.rad(intAngle)) * intSize
end
local function fncGetAnglesSin(intAngle, intSize)
	return math.sin(math.rad(intAngle)) * intSize
end
local function fncDrawAngleLine(intPosX, intPosY, intAngle, intSize)
	surface.DrawLine(intPosX, intPosY, intPosX + fncGetAnglesCos(intAngle, intSize), intPosY + fncGetAnglesSin(intAngle, intSize))
end

function GM:HUDPaint()
	clrDrakGray = Color( PK.HudSettings[ "panel_r" ]:GetInt(), PK.HudSettings[ "panel_g" ]:GetInt(), PK.HudSettings[ "panel_b" ]:GetInt(), PK.HudSettings[ "panel_a" ]:GetInt() )

	self.PlayerBox = jdraw.NewPanel()
	self.PlayerBox:SetDemensions(40, ScrH() - 100, GAMEMODE.PlayerHUDBarWidth, 77)
	self.PlayerBox:SetStyle(4, clrDrakGray)
	self.PlayerBox:SetBoarder(1, clrDrakGray)
	self:DrawPropOwner()
	jdraw.DrawPanel(self.PlayerBox)

	Target = LocalPlayer():GetObserverTarget()

	self:DrawHealthBar()
	self:DrawKDBar()

	local intSize = 4
	local intLines = 4
	local intRate = 0
	local intX = ScrW() / 2.0
	local intY = LocalPlayer():GetEyeTraceNoCursor().HitPos:ToScreen().y
	surface.SetDrawColor(clrGreen)
	intCrossHairAngle = intCrossHairAngle + intRate
	for i = 0, (intLines - 1) do
		fncDrawAngleLine(intX, intY, intCrossHairAngle + ((i / intLines) * 360), intSize)
	end

	self.BaseClass:HUDPaint() -- Call all the other shit ;3

	if PK.MessageToRender and #PK.MessageToRender > 0 then
		for k, v in pairs( PK.MessageToRender ) do
			if not v.Sent or v.Sent ~= 1 then -- v.Sent == 0 or ~= 1
				if ShowLastMessage and ShowLastMessage + .3 > SysTime() then return end -- returns because it's not yet time for the other notify to be called.
				ShowLastMessage = SysTime() -- now it is this ones turn, so we set the new variable of when it was called.
				v.Sent = 1 -- Making sure we set that its been sent so we don't repeat this stupid process again.
				v.dietime = SysTime() + 3
			end
			if SysTime() >= v.dietime then
				table.remove( PK.MessageToRender, k )
			else
				local remaining = math.ceil( v.dietime - SysTime() )					
				local fade = math.Clamp( ( remaining * 255 ) / 2, 0, 255 )
					
				if v.up and v.up >= 300 then
					if v.right then
						v.left = ( v.left or 0 ) - 5
					else
						v.left = ( v.left or 0 ) + 5
					end
				else
					v.up = ( v.up or 0 ) + 1
				end
				
				draw.DrawText( v.text, "Trebuchet24", v.posx - ( v.left or 0 ), v.posy - ( v.up or 0 ), Color( v.colour.r, v.colour.g, v.colour.b, fade ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )	
			end
		end
	end

	if PK.DamageToRender and #PK.DamageToRender > 0 then
		for k, v in pairs( PK.DamageToRender ) do
	        if CurTime() + v.RemoveTime <= CurTime() then table.remove( PK.DamageToRender, k ) continue end

	        local Ang = LocalPlayer():EyeAngles()
	        Ang:RotateAroundAxis( Ang:Forward(), 90 )
	        Ang:RotateAroundAxis( Ang:Right(), 90 )
	         
	        local IndicPos = v.Pos
	        local IndicToScreen = v.Pos:ToScreen()
	        local Amount = v.Amount
	        local RemoveTime = v.RemoveTime
	      
	        if v.Alpha == nil then
	           v.Alpha = 255
	        end   
	      
	        if v.Alpha > 0 then
	           local DistA = v.Alpha - 0
	           local DistB = v.Alpha - 50
	           v.Alpha = math.Clamp(v.Alpha - RealFrameTime() * 150, 0 , 255)
	           if v.Alpha > 150 then
	              IndicPos.z = IndicPos.z + RealFrameTime() * (DistB * 0.3)
	           else
	              IndicPos.z = IndicPos.z - RealFrameTime() * (DistA * 0.2)
	           end   
	           if v.RandX == nil or v.RandY == nil then
	              local RandForce = 40
	              v.RandX = math.random(0, RandForce)
	              v.RandY = math.random(0, RandForce)
	              if math.random(1,2) == 1 then
	                 v.Inverse = false
	              else
	                 v.Inverse = true
	              end
	           end
	           if v.Inverse == false then
	              IndicPos.y = IndicPos.y + RealFrameTime() * v.RandY
	              IndicPos.x = IndicPos.x + RealFrameTime() * v.RandX
	           else
	              IndicPos.y = IndicPos.y - RealFrameTime() * v.RandY
	              IndicPos.x = IndicPos.x - RealFrameTime() * v.RandX
	           end
	        end
	      
			if v.Alpha > 0 then
	           local color = Color(255, 255, 255, v.Alpha)
	      
	           if Amount >= 100 then
	              color = Color(255, 0, 0, v.Alpha)
	           end
			   
	           surface.SetFont("DamageIndicFont6")
	           draw.DrawText(Amount, "DamageIndicFont6", IndicToScreen.x, IndicToScreen.y, color, TEXT_ALIGN_CENTER )
	       end
	    end
	end
end

function GM:DrawPropOwner()
    local tr = util.TraceLine(util.GetPlayerTrace(LocalPlayer()))
    if tr.HitNonWorld then
        if tr.Entity:IsValid() and not tr.Entity:IsPlayer() and not LocalPlayer():InVehicle() then
			local owner = tr.Entity:GetGNWVar("owner")
			local name = owner and owner:Nick() or "Disconnected Player"

        	if owner then
	            local PropOwner = "Owner: " .. name
	            self.SkillBar = jdraw.NewProgressBar(self.PlayerBox, true)
	            
	            self.SkillBar:SetStyle(4, clrDrakGray)
	            self.SkillBar:SetDemensions(3, -21, string.len( PropOwner ) + 200, 23)
	            self.SkillBar:SetText("UiBold", PropOwner, clrDrakGray)
	            jdraw.DrawProgressBar(self.SkillBar)
	        end
        end
    end
end

function GM:DrawHealthBar()
	local Health = LocalPlayer():Health()
	local MaxHealth = GetSetting("PlayerSpawnHealth", 100)

	if LocalPlayer():GetGNWVar( "IsSpectating", false ) then Health = 0 end

	if Target and Target:IsPlayer() then
		Health = Target:Health()
	end

	self.HealthBar = jdraw.NewProgressBar(self.PlayerBox, true)
	self.HealthBar:SetDemensions(3, 3, self.PlayerBox.Size.Width - 6, 20)
	self.HealthBar:SetStyle( 4, Color( PK.HudSettings[ "health_r" ]:GetInt(), PK.HudSettings[ "health_g" ]:GetInt(), PK.HudSettings[ "health_b" ]:GetInt(), PK.HudSettings[ "health_a" ]:GetInt() ) )
	self.HealthBar:SetValue( math.Clamp( Health, 0, MaxHealth ), MaxHealth )
	self.HealthBar:SetText("UiBold", "Health " .. Health, clrDrakGray)
	jdraw.DrawProgressBar(self.HealthBar)
end

function GM:DrawKDBar()
	local SKills, SDeaths = LocalPlayer():GetGNWVar( "kills", 1 ), LocalPlayer():GetGNWVar( "deaths", 1 )

	if Target and Target:IsPlayer() then
		SKills = Target:GetGNWVar( "kills", 1 )
		SDeaths = Target:GetGNWVar( "deaths", 1 )
	end

	if SKills == 0 then SKills = 1 end
	if SDeaths == 0 then SDeaths = 1 end
	self.HealthBar = jdraw.NewProgressBar(self.PlayerBox, true)
	self.HealthBar:SetDemensions(3, 25, self.PlayerBox.Size.Width - 6, 20)
	self.HealthBar:SetStyle( 4, Color( PK.HudSettings[ "kd_r" ]:GetInt(), PK.HudSettings[ "kd_g" ]:GetInt(), PK.HudSettings[ "kd_b" ]:GetInt(), PK.HudSettings[ "kd_a" ]:GetInt() ) )
	self.HealthBar:SetValue( math.Clamp( SKills / SDeaths, 0, 1 ) , 1)
	self.HealthBar:SetText("UiBold", "Total KD Ratio " .. math.Round( SKills / SDeaths, 2 ) .. ":1", clrDrakGray)
	jdraw.DrawProgressBar(self.HealthBar)

	local fighting = GetGlobalBool( "FightInProgress" )

	local WHITECOLOUR = Color( PK.HudSettings[ "text_r" ]:GetInt(), PK.HudSettings[ "text_g" ]:GetInt(), PK.HudSettings[ "text_b" ]:GetInt(), PK.HudSettings[ "text_a" ]:GetInt() )

	if fighting then
		local fighter1 = GetGlobalEntity( "Fighter1" )
		local fighter2 = GetGlobalEntity( "Fighter2" )
		draw.SimpleText( "Fighter1: " .. fighter1:Nick() .. " (" .. fighter2:Deaths() .. ")", "UiBold", 48, ScrH() - 47, WHITECOLOUR, 0, 1)
		draw.SimpleText( "Fighter2: " .. fighter2:Nick() .. " (" .. fighter1:Deaths() .. ")", "UiBold", 48, ScrH() - 35, WHITECOLOUR, 0, 1)
	else
		local winning = GetGlobalEntity( "Leader" )
		local leading = "No one"
		if winning and winning ~= NULL and winning ~= nil then
			if winning:IsPlayer() and winning:IsValid() then
				if winning == LocalPlayer() then
					leading = "You are"
				else
					leading = winning:Nick() .. " (" .. winning:GetGNWVar( "killstreak" ) .. ")"
				end
			end
		end

		draw.SimpleText( "Killstreak: " .. LocalPlayer():GetGNWVar( "killstreak", 0 ), "UiBold", 48, ScrH() - 47, WHITECOLOUR, 0, 1)
		draw.SimpleText( "Leader: " .. leading, "UiBold", 48, ScrH() - 35, WHITECOLOUR, 0, 1)
	end
end

function GM:HUDShouldDraw( name )
	local Blocked = { "CHudHealth", "CHudBattery", "CHudAmmo", "CHudSecondaryAmmo", "CHudWeaponSelection" }
	if table.HasValue( Blocked, name ) then
		return false
	end
	return true
end