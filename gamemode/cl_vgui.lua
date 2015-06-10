/*---------------------------------------------------------
   Name: cl_vgui.lua
   Desc: This contains stuff for the F4 menu which is originally from DarkRP but has been modified skin wise and for different features, this also contains the right click spawn menu commands to Block/Unblock models and to work well with the most used props menu.
   Author: G-Force Connections (STEAM_0:1:19084184)
---------------------------------------------------------*/

local F4Menu  
local F4MenuTabs
local F4Tabs
local NoCloseF4 = CurTime()
local function ChangeJobVGUI()
	if not F4Menu or not F4Menu:IsValid() then
		F4Menu = vgui.Create("DFrame")
		F4Menu:SetSize(747, 580)
		F4Menu:Center()
		F4Menu:SetVisible( true )
		F4Menu:MakePopup( )
		F4Menu:SetTitle("Options menu")
		F4Tabs = { JobsTab(), PropKill(), FightMenu(), ClientSettingsMenu() }
		if LocalPlayer():IsSuperAdmin() then
			table.insert( F4Tabs, AdminMenu() )
		end
		F4Menu:SetSkin("DarkRP")
	else
		F4Menu:SetVisible( true )
		F4Menu:SetSkin("DarkRP")
	end
	NoCloseF4 = CurTime() + 0.6
	
	function F4Menu:Think()
		if input.IsKeyDown(KEY_F4) and NoCloseF4 < CurTime() then
			self:Close()
		end

		if (!self.Dragging) then return end 
		local x = gui.MouseX() - self.Dragging[1] 
		local y = gui.MouseY() - self.Dragging[2] 
		x = math.Clamp( x, 0, ScrW() - self:GetWide() ) 
		y = math.Clamp( y, 0, ScrH() - self:GetTall() ) 
		self:SetPos( x, y )
	end
	
	if not F4MenuTabs or not F4MenuTabs:IsValid() then
		F4MenuTabs = vgui.Create( "DPropertySheet", F4Menu)
		F4MenuTabs:SetPos(5, 25)
		F4MenuTabs:SetSize(737, 550)
		F4MenuTabs:AddSheet( "Teams", F4Tabs[1], "icon16/arrow_refresh.png", false, false )
		F4MenuTabs:AddSheet( "Prop Kill", F4Tabs[2], "icon16/plugin.png", false, false )
		F4MenuTabs:AddSheet( "FightMenu", F4Tabs[3], "icon16/application_view_tile.png", false, false )
		F4MenuTabs:AddSheet( "HUD", F4Tabs[4], "icon16/user.png", false, false )
		if LocalPlayer():IsSuperAdmin() then
			F4MenuTabs:AddSheet( "Admin Menu", F4Tabs[5], "icon16/wrench.png", false, false )
		end
	end

	for _, panel in pairs( F4Tabs ) do panel:Update() panel:SetSkin("DarkRP") end

 	function F4Menu:Close()
		F4Menu:SetVisible(false)
		F4Menu:SetSkin("DarkRP")
	end 

	F4Menu:SetSkin("DarkRP")
end
net.Receive("ChangeJobVGUI", ChangeJobVGUI)

function JobsTab()
	local hordiv = vgui.Create("DHorizontalDivider")
	hordiv:SetLeftWidth(370)
	function hordiv.m_DragBar:OnMousePressed() end
	hordiv.m_DragBar:SetCursor("none")
	local Panel
	local Information
	function hordiv:Update()
		if Panel and Panel:IsValid() then
			Panel:Remove()
		end
		Panel = vgui.Create( "DPanelList")
		Panel:SetSize(370, 540)
		Panel:SetSpacing(1)
		Panel:EnableHorizontal( true )
		Panel:EnableVerticalScrollbar( true )
		Panel:SetSkin("DarkRP")
		
		local Info = {}
		local model
		local modelpanel
		local function UpdateInfo(a)
			if Information and Information:IsValid() then
				Information:Remove()
			end
			Information = vgui.Create( "DPanelList" )
			Information:SetPos(378,0)
			Information:SetSize(370, 540)
			Information:SetSpacing(10)
			Information:EnableHorizontal( false )
			Information:EnableVerticalScrollbar( true )
			Information:SetSkin("DarkRP")
			function Information:Rebuild() -- YES IM OVERRIDING IT AND CHANGING ONLY ONE LINE BUT I HAVE A FUCKING GOOD REASON TO DO IT!
				local Offset = 0
				if ( self.Horizontal ) then
					local x, y = self.Padding, self.Padding;
					for k, panel in pairs( self.Items ) do
						local w = panel:GetWide()
						local h = panel:GetTall()
						if ( x + w  > self:GetWide() ) then
							x = self.Padding
							y = y + h + self.Spacing
						end
						panel:SetPos( x, y )
						x = x + w + self.Spacing
						Offset = y + h + self.Spacing
					end
				else
					for k, panel in pairs( self.Items ) do
						if not panel:IsValid() then return end
						panel:SetSize( self:GetCanvas():GetWide() - self.Padding * 2, panel:GetTall() )
						panel:SetPos( self.Padding, self.Padding + Offset )
						panel:InvalidateLayout( true )
						Offset = Offset + panel:GetTall() + self.Spacing
					end
					Offset = Offset + self.Padding	
				end
				self:GetCanvas():SetTall( Offset + (self.Padding) - self.Spacing ) 
			end
			
			if type(Info) == "table" and #Info > 0 then
				for k,v in ipairs(Info) do
					local label = vgui.Create("DLabel")
					label:SetText(v)
					label:SizeToContents()
					if label:IsValid() then
						Information:AddItem(label)
					end
				end
			end

			if model and type(model) == "string" and a ~= false then
				modelpanel = vgui.Create("DModelPanel")
				modelpanel:SetModel(model)
				modelpanel:SetSize(90,230)
				modelpanel:SetAnimated(true)
				modelpanel:SetFOV(90)
				modelpanel:SetAnimSpeed(1)
				if modelpanel:IsValid() then
					Information:AddItem(modelpanel)
				end
			end
			hordiv:SetLeft(Panel)
			hordiv:SetRight(Information)
		end
		UpdateInfo()
		
		local function AddIcon(Model, name, description, command)
			local icon = vgui.Create("SpawnIcon")
			local IconModel = Model
			if type(Model) == "table" then
				IconModel = Model[math.random(#Model)]
			end
			icon:SetModel(IconModel)
			
			icon:SetSize(120, 120)
			icon:SetToolTip()
			icon.OnCursorEntered = function()
				icon.PaintOverOld = icon.PaintOver 
				icon.PaintOver = icon.PaintOverHovered
				Info[1] = "Class: ".. name 
				Info[2] = "Description: " .. description
				model = IconModel
				UpdateInfo()
			end
			icon.OnCursorExited = function()
				if ( icon.PaintOver == icon.PaintOverHovered ) then 
					icon.PaintOver = icon.PaintOverOld 
				end
				Info = {}
				if modelpanel and modelpanel:IsValid() and icon:IsValid() then
					modelpanel:Remove()
					UpdateInfo(false)
				end
			end
			
			icon.DoClick = function()
				local function DoChatCommand(frame)
					RunConsoleCommand( "pk_team", command )
					frame:Close()
				end
				
				if type(Model) == "table" and #Model > 0 then
					hordiv:GetParent():GetParent():Close()
					local frame = vgui.Create( "DFrame" )
					frame:SetTitle( "Choose model" )
					frame:SetVisible(true)
					frame:MakePopup()
					frame:SetSkin("DarkRP")
					
					local levels = 1
					local IconsPerLevel = math.floor(ScrW()/64)
					
					while #Model * (64/levels) > ScrW() do
						levels = levels + 1
					end
					frame:SetSize(math.Min(#Model * 64, IconsPerLevel*64), math.Min(90+(64*(levels-1)), ScrH()))
					frame:Center()
					
					local CurLevel = 1
					for k,v in pairs(Model) do
						local icon = vgui.Create("SpawnIcon", frame)
						if (k-IconsPerLevel*(CurLevel-1)) > IconsPerLevel then
							CurLevel = CurLevel + 1
						end
						icon:SetPos((k-1-(CurLevel-1)*IconsPerLevel) * 64, 25+(64*(CurLevel-1)))
						icon:SetModel(v)
						icon:SetSize(64, 64)
						icon:SetToolTip()
						icon.DoClick = function()
							RunConsoleCommand( "pk_playermodel", v )
							RunConsoleCommand( "pk_chosenmodel", v )
							DoChatCommand(frame)
						end
					end
				else
					DoChatCommand(hordiv:GetParent():GetParent())
				end
			end
			
			if icon:IsValid() then
				Panel:AddItem(icon)
			end
		end
		
		for k,v in ipairs(Teams) do
			if LocalPlayer():Team() ~= k then
				local nodude = true				
				if nodude then
					if not v.model or not v.name or not v.Des or not v.command then chat.AddText( Color( 255, 0, 0, 255 ), "Incorrect team! Fix your sh_init.lua!" ) return end
					AddIcon( v.model, v.name, v.Des, v.command )
				end
			end
		end
	end
	hordiv:Update()

	return hordiv
end

function PropKill()
	local Menu = vgui.Create( "DPanelList" )
	function Menu:Update()
		self:Clear(true)
		local SpawnMenu = vgui.Create( "DCollapsibleCategory" )
		local IconList = vgui.Create( "DPanelList" ) 
		IconList:SetAutoSize(true)
		IconList:EnableVerticalScrollbar( true ) 
		IconList:EnableHorizontal( true ) 
		IconList:SetPadding( 4 ) 
		--IconList:SetSize( 0, 150 )

		for _, v in pairs( PK.MostUsedProps ) do
			local icon = vgui.Create( "SpawnIcon", IconList ) 
			icon:SetModel( v )
			IconList:AddItem( icon )
			icon.DoClick = function( icon ) surface.PlaySound( "ui/buttonclickrelease.wav" ) RunConsoleCommand( "gm_spawn", v ) end
		end
		Menu:AddItem( SpawnMenu )

		SpawnMenu:SetLabel( "Top Used Props" )
		SpawnMenu:SetContents( IconList )

		RunConsoleCommand( "pk_top" ) -- Get the list.
	
		local DermaPanel = vgui.Create( "DCollapsibleCategory" )
		local DPanelList = vgui.Create( "DPanelList" )
		DPanelList:SetAutoSize(true)
		Top10Players = vgui.Create( "DListView" )
		Top10Players:SetParent( DermaPanel )
		Top10Players:SetPos( 25, 25 )
		Top10Players:SetSize( 450, 225 )
		Top10Players:SetMultiSelect( false )
		Top10Players:AddColumn( "Name" )
		Top10Players:AddColumn( "Kills" )
		Top10Players:AddColumn( "Deaths" )
		Top10Players:AddColumn( "KDR" )

		Menu:AddItem( DermaPanel )
		DermaPanel:SetLabel( "Leaderboard" )
		DPanelList:AddItem( Top10Players )
		DermaPanel:SetContents( DPanelList )
	end

	return Menu
end

function FightMenu()
	local Menu = vgui.Create( "DPanelList" )

	function Menu:Update()
		self:Clear(true)
		local FightMenu = vgui.Create( "DCollapsibleCategory" )
		local DPanelList = vgui.Create( "DPanelList" )
		DPanelList:SetAutoSize( true )
		DPanelList:SetSpacing( 5 )
		 
		local List = vgui.Create( "DComboBox" )
		List:SetText( "Select a player" )
		List:Center()
		DPanelList:AddItem( List )

		local NumSlider = vgui.Create( "DNumSlider" )
		NumSlider:SetWide( 150 )
		NumSlider:SetText( "Kills" )
		NumSlider:SetMin( 5 )
		NumSlider:SetMax( 15 )
		NumSlider:SetValue( 5 )
		NumSlider:SetDecimals( 0 )
		DPanelList:AddItem( NumSlider )

		local count = 0
		for _, v in pairs( player.GetAll() ) do
			if v ~= LocalPlayer() then
				count = count + 1
				List:AddChoice( v:Nick() )
			end
		end

		if not count then
			List:SetDisabled( true )
			List:SetText( "No players available" )
		end

		local button = vgui.Create( "DButton" )
		
		button:SetText( "I'm Ready!" )
		button.DoClick = function( button )
			if List:GetValue() ~= "" and List:GetValue() ~= "Select a player" then
				-- hack shit here bro
				local uniqueid = NULL
				for _, v in pairs( player.GetAll() ) do if v:Nick() == List:GetValue() then uniqueid = v:UniqueID() end end

				RunConsoleCommand( "pk_startfight", uniqueid, NumSlider:GetValue() )
				F4Menu:SetVisible( false )
			else
				chat:AddText( Color( 100, 255, 255, 255 ), "Select a player before fighting." )
			end
		end
		DPanelList:AddItem( button )
		Menu:AddItem( DPanelList )
		Menu:AddItem( FightMenu )
		FightMenu:SetLabel( "Fight Players" )
		FightMenu:SetContents( DPanelList )
	end

	return Menu
end

function ClientSettingsMenu()
	local Menu = vgui.Create( "DScrollPanel" )

	function Menu:Update()
		self:Clear( true )

		local ScrollPanel = vgui.Create( "DListLayout" )
		ScrollPanel:SetSize(720, 550)
		self:AddItem( ScrollPanel )

		local HealthColour = vgui.Create( "DCollapsibleCategory" )
		HealthColour:SetLabel( "Health Colour" )
		HealthColour:SetExpanded( true )

		local HealthColourPanel = vgui.Create( "DListLayout" )
		HealthColourPanel:SetTall( 100 )

		local ColourHealthMenu = vgui.Create( "DColorMixer" )
		ColourHealthMenu:SetConVarR( "pk_health_r" )
		ColourHealthMenu:SetConVarG( "pk_health_g" )
		ColourHealthMenu:SetConVarB( "pk_health_b" )
		ColourHealthMenu:SetConVarA( "pk_health_a" )
		HealthColourPanel:Add( ColourHealthMenu )
		ColourHealthMenu:SizeToContents()

		HealthColour:SetContents( HealthColourPanel )

		ScrollPanel:Add( HealthColour )

		local KDColour = vgui.Create( "DCollapsibleCategory" )
		KDColour:SetLabel( "KD Ratio Colour" )
		KDColour:SetExpanded( false )

		local KDColourPanel = vgui.Create( "DListLayout" )
		KDColourPanel:SetTall( 130 )

		local ColourKDMenu = vgui.Create( "DColorMixer" )
		ColourKDMenu:SetConVarR( "pk_kd_r" )
		ColourKDMenu:SetConVarG( "pk_kd_g" )
		ColourKDMenu:SetConVarB( "pk_kd_b" )
		ColourKDMenu:SetConVarA( "pk_kd_a" )
		KDColourPanel:Add( ColourKDMenu )

		KDColour:SetContents( KDColourPanel )

		ScrollPanel:Add( KDColour )

		local TextColour = vgui.Create( "DCollapsibleCategory" )
		TextColour:SetLabel( "Text Colour" )
		TextColour:SetExpanded( false )

		local TextColourPanel = vgui.Create( "DListLayout" )
		TextColourPanel:SetTall( 130 )

		local ColourTextMenu = vgui.Create( "DColorMixer" )
		ColourTextMenu:SetConVarR( "pk_text_r" )
		ColourTextMenu:SetConVarG( "pk_text_g" )
		ColourTextMenu:SetConVarB( "pk_text_b" )
		ColourTextMenu:SetConVarA( "pk_text_a" )
		TextColourPanel:Add( ColourTextMenu )

		TextColour:SetContents( TextColourPanel )

		ScrollPanel:Add( TextColour )

		local PanelColour = vgui.Create( "DCollapsibleCategory" )
		PanelColour:SetLabel( "Panel Background" )
		PanelColour:SetExpanded( false )

		local ColourPanel = vgui.Create( "DListLayout" )
		ColourPanel:SetTall( 130 )

		local ColourPanelMenu = vgui.Create( "DColorMixer" )
		ColourPanelMenu:SetConVarR( "pk_panel_r" )
		ColourPanelMenu:SetConVarG( "pk_panel_g" )
		ColourPanelMenu:SetConVarB( "pk_panel_b" )
		ColourPanelMenu:SetConVarA( "pk_panel_a" )
		ColourPanel:Add( ColourPanelMenu )

		PanelColour:SetContents( ColourPanel )

		ScrollPanel:Add( PanelColour )

		local ResetColours = vgui.Create( "DButton" )
		ResetColours:SetText( "Reset all to default colours" )
		ResetColours.DoClick = function()
			RunConsoleCommand( "pk_health_r", "194" )
			RunConsoleCommand( "pk_health_g", "255" )
			RunConsoleCommand( "pk_health_b", "72" )
			RunConsoleCommand( "pk_health_a", "255" )

			RunConsoleCommand( "pk_kd_r", "59" )
			RunConsoleCommand( "pk_kd_g", "142" )
			RunConsoleCommand( "pk_kd_b", "209" )
			RunConsoleCommand( "pk_kd_a", "255" )

			RunConsoleCommand( "pk_text_r", "242" )
			RunConsoleCommand( "pk_text_g", "242" )
			RunConsoleCommand( "pk_text_b", "242" )
			RunConsoleCommand( "pk_text_a", "255" )

			RunConsoleCommand( "pk_panel_r", "43" )
			RunConsoleCommand( "pk_panel_g", "42" )
			RunConsoleCommand( "pk_panel_b", "39" )
			RunConsoleCommand( "pk_panel_a", "255" )
		end

		ScrollPanel:Add( ResetColours )
	end

	return Menu
end

function AdminMenu()
	local Menu = vgui.Create( "DPanelList" )

	function Menu:Update()
		self:Clear( true )
		local SettingMenu = vgui.Create( "DCollapsibleCategory" )
		SettingMenu:SetLabel( "Gamemode Settings" )

		local Settings = vgui.Create( "DPanelList" )
		--Settings:SetPos( 5, 35 )
		Settings:SetAutoSize( true )
		Settings:SetSpacing( 5 )

		for k, v in pairs( PK.Settings ) do
			if v.type == SETTING_NUMBER then
				local NumSlider = vgui.Create( "DNumSlider" )
				NumSlider.Text = k
				NumSlider:SetText( v.desc )
				NumSlider:SetMin( v.min )
				NumSlider:SetMax( v.max )
				NumSlider:SetValue( math.Round( v.value ) )
				NumSlider:SetDecimals( 0 )

				NumSlider.OnValueChanged = function( panel, value )
					RunConsoleCommand( "pk_setting", panel.Text, math.Round( value ) )
					PK.Settings[ panel.Text ].value = value -- must save clientside wise.
					panel:SetValue( value )
				end

				Settings:AddItem( NumSlider )
			elseif v.type == SETTING_BOOLEAN then
				local CheckBox = vgui.Create( "DCheckBoxLabel" )
				CheckBox:SetText( v.desc )
				CheckBox.Text = k
				CheckBox:SetValue( v.value )

				CheckBox.OnChange = function( panel, value )
					RunConsoleCommand( "pk_setting", panel.Text, tostring( value ) )
					PK.Settings[ panel.Text ].value = value -- must save clientside wise.
				end

				Settings:AddItem( CheckBox )
			end
		end

		SettingMenu:SetContents( Settings )
		Menu:AddItem( SettingMenu )

		local ModelMenu = vgui.Create( "DCollapsibleCategory" )
		ModelMenu:SetLabel( "Model blocklist" )

		Menu:AddItem( ModelMenu )
	end

	return Menu
end