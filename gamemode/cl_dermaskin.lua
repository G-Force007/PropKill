/*---------------------------------------------------------
   Name: cl_dermaskin.lua
   Desc: This is the derma skin, this is originally BlackOps derma skin, I use it for the derma shit in the server, aka F4 menu.
   Author: BlackOps
---------------------------------------------------------*/
local surface = surface
local draw = draw
local Color = Color
local render = render

local SKIN = {}

SKIN.PrintName 		= "BlackOps Derma Skin"
SKIN.Author 		= "BlackOps7799"
SKIN.DermaVersion	= 1

SKIN.bg_color 					= Color( 110, 110, 110, 255 )
SKIN.bg_color_sleep 			= Color( 70, 70, 70, 255 )
SKIN.bg_color_dark				= Color( 50, 50, 50, 255 )
SKIN.bg_color_bright			= Color( 220, 220, 220, 255 )
SKIN.frame_border				= Color( 50, 50, 50, 255 )
SKIN.frame_title				= Color( 130, 130, 130, 255 )

surface.CreateFont( "Tahoma", {
		font    = "BlackSkinTitle",
		size    = 25,
		weight  = 1000,
		antialias = true,
		shadow = false
	}
)
surface.CreateFont( "Tahoma", {
		font    = "BlackButLabel",
		size    = 13,
		weight  = 700,
		antialias = false,
		shadow = false
	}
)
SKIN.fontFrame					= "BlackSkinTitle"

SKIN.Blue = Color( 0, 162, 232, 255 )

SKIN.control_color 				= Color( 120, 120, 120, 255 )
SKIN.control_color_highlight	= Color( 150, 150, 150, 255 )
SKIN.control_color_active 		= SKIN.Blue
SKIN.control_color_bright 		= Color( 255, 200, 100, 255 )
SKIN.control_color_dark 		= Color( 100, 100, 100, 255 )

SKIN.bg_alt1 					= Color( 50, 50, 50, 255 )
SKIN.bg_alt2 					= Color( 55, 55, 55, 255 )

SKIN.listview_hover				= Color( 70, 70, 70, 255 )
SKIN.listview_selected			= SKIN.Blue

SKIN.text_bright				= color_white
SKIN.text_normal				= Color( 180, 180, 180, 255 )
SKIN.text_dark					= Color( 20, 20, 20, 255 )
SKIN.text_highlight				= Color( 255, 20, 20, 255 )

SKIN.texGradientUp				= Material( "gui/gradient_up" )
SKIN.texGradientDown			= Material( "gui/gradient_down" )

SKIN.combobox_selected			= SKIN.listview_selected

SKIN.panel_transback			= Color( 255, 255, 255, 50 )
SKIN.tooltip					= Color( 255, 245, 175, 255 )

SKIN.colPropertySheet 			= Color( 170, 170, 170, 255 )
SKIN.colTab			 			= SKIN.colPropertySheet
SKIN.colTabInactive				= Color( 140, 140, 140, 255 )
SKIN.colTabShadow				= Color( 0, 0, 0, 170 )
SKIN.colTabText		 			= color_white
SKIN.colTabTextInactive			= Color( 150, 150, 150, 255 )
SKIN.fontTab					= "BlackButLabel"

SKIN.colCollapsibleCategory		= Color( 255, 255, 255, 20 )

SKIN.colCategoryText			= color_white
SKIN.colCategoryTextInactive	= Color( 200, 200, 200, 255 )
SKIN.fontCategoryHeader			= "BlackButLabel"

SKIN.colNumberWangBG			= Color( 255, 240, 150, 255 )
SKIN.colTextEntryBG				= Color( 240, 240, 240, 255 )
SKIN.colTextEntryBorder			= Color( 20, 20, 20, 255 )
SKIN.colTextEntryText			= Color( 20, 20, 20, 255 )
SKIN.colTextEntryTextHighlight	= Color( 20, 200, 250, 255 )
SKIN.colTextEntryTextHighlight	= Color( 20, 200, 250, 255 )

SKIN.colMenuBG					= Color( 255, 255, 255, 200 )
SKIN.colMenuBorder				= Color( 0, 0, 0, 200 )

SKIN.colButtonText				= color_white
SKIN.colButtonTextDisabled		= Color( 255, 255, 255, 55 )
SKIN.colButtonBorder			= Color( 20, 20, 20, 255 )
SKIN.colButtonBorderHighlight	= Color( 255, 255, 255, 50 )
SKIN.colButtonBorderShadow		= Color( 0, 0, 0, 100 )
SKIN.fontButton					= "BlackButLabel"


/*---------------------------------------------------------
   DrawGenericBackground
---------------------------------------------------------*/
function SKIN:DrawGenericBackground( x, y, w, h, color )

	local rounded = h < 12 and h/2 or 6
	draw.RoundedBox( rounded, x, y, w, h, color )

end

/*---------------------------------------------------------
   DrawButtonBorder
---------------------------------------------------------*/
function SKIN:DrawButtonBorder( x, y, w, h, depressed )

	if ( !depressed ) then
	
		// Highlight
		surface.SetDrawColor( self.colButtonBorderHighlight )
		surface.DrawRect( x+1, y+1, w-2, 1 )
		surface.DrawRect( x+1, y+1, 1, h-2 )
		
		// Corner
		surface.DrawRect( x+2, y+2, 1, 1 )
	
		// Shadow
		surface.SetDrawColor( self.colButtonBorderShadow )
		surface.DrawRect( w-2, y+2, 1, h-2 )
		surface.DrawRect( x+2, h-2, w-2, 1 )
		
	else
	
		local col = self.colButtonBorderShadow
	
		for i=1, 5 do
		
			surface.SetDrawColor( col.r, col.g, col.b, (255 - i * (255/5) ) )
			surface.DrawOutlinedRect( i, i, w-i, h-i )
		
		end
		
	end	

	surface.SetDrawColor( self.colButtonBorder )
	surface.DrawOutlinedRect( x, y, w, h )

end

/*---------------------------------------------------------
   DrawDisabledButtonBorder
---------------------------------------------------------*/
function SKIN:DrawDisabledButtonBorder( x, y, w, h, depressed )

	surface.SetDrawColor( 0, 0, 0, 150 )
	surface.DrawOutlinedRect( x, y, w, h )
	
end

local matBlurScreen = Material( "pp/blurscreen" )

/*---------------------------------------------------------
	Frame
---------------------------------------------------------*/
function SKIN:PaintFrame( panel )

	if MaxPlayers then -- Menu doesn't support the render functions
		
		surface.SetMaterial( matBlurScreen )    
		surface.SetDrawColor( 255, 255, 255, 255 )
		
		local x, y = panel:LocalToScreen( 0, 0 )
			
		for i=0.33, 1, 0.33 do
			matBlurScreen:SetMaterialFloat( "$blur", 5 * i )
			render.UpdateScreenEffectTexture()
			surface.DrawTexturedRect( x * -1, y * -1, ScrW(), ScrH() )
		end
		
	end

	surface.SetDrawColor( Color( 100, 100, 100, 100 ) )
	surface.DrawRect( 0, 22, panel:GetWide(), panel:GetTall() - 22 )
	
	surface.SetMaterial( self.texGradientDown )
	surface.SetDrawColor( 0, 0, 0, 150 )
	surface.DrawTexturedRect( 0, 22, panel:GetWide(), panel:GetTall() - 22 )
	
	surface.SetDrawColor( color_black )
	surface.DrawOutlinedRect( 0, 0, panel:GetWide(), 22 )
	
	surface.SetDrawColor( Color( 0, 0, 0, 200 ) )
	surface.DrawRect( 0, 0, panel:GetWide(), 22 )
		
	surface.SetMaterial( self.texGradientDown )
	surface.SetDrawColor( 100, 100, 100, 150 )
	surface.DrawTexturedRect( 0, 0, panel:GetWide(), 22/3 )
end

function SKIN:LayoutFrame( panel )

	panel.lblTitle:SetFont( self.fontFrame )
	
	panel.btnClose:SetPos( panel:GetWide() - 22, 4 )
	panel.btnClose:SetSize( 18, 18 )
	
	panel.lblTitle:SetPos( 22, 1 )
	panel.lblTitle:SetSize( panel:GetWide() - 25, 20 )
	
	panel.lblTitle:SetExpensiveShadow( 2, color_black )

end

/*---------------------------------------------------------
	SysButton
---------------------------------------------------------*/
function SKIN:PaintPanel( panel )

	if ( panel.m_bPaintBackground ) then
	
		local w, h = panel:GetSize()
		self:DrawGenericBackground( 0, 0, w, h, panel.m_bgColor or self.panel_transback )
		
	end	

end

/*---------------------------------------------------------
	SysButton
---------------------------------------------------------*/
function SKIN:PaintSysButton( panel )

	self:PaintButton( panel )
	self:PaintOverButton( panel ) // Border

end

function SKIN:SchemeSysButton( panel )

	panel:SetFont( "Marlett" )
	DLabel.ApplySchemeSettings( panel )
	
end


/*---------------------------------------------------------
	ImageButton
---------------------------------------------------------*/
function SKIN:PaintImageButton( panel )

	self:PaintButton( panel )

end

/*---------------------------------------------------------
	ImageButton
---------------------------------------------------------*/
function SKIN:PaintOverImageButton( panel )

	self:PaintOverButton( panel )

end
function SKIN:LayoutImageButton( panel )

	if ( panel.m_bBorder ) then
		panel.m_Image:SetPos( 1, 1 )
		panel.m_Image:SetSize( panel:GetWide()-2, panel:GetTall()-2 )
	else
		panel.m_Image:SetPos( 0, 0 )
		panel.m_Image:SetSize( panel:GetWide(), panel:GetTall() )
	end

end

/*---------------------------------------------------------
	PaneList
---------------------------------------------------------*/
function SKIN:PaintPanelList( panel )

	if ( panel.m_bBackground ) then
		local rounded = panel:GetTall() < 16 and panel:GetTall()/2 or 8
		draw.RoundedBox( rounded, 0, 0, panel:GetWide(), panel:GetTall(), self.bg_color_dark )
	end

end

function SKIN:SchemeMenuOption( panel )

	panel:SetFGColor( 40, 40, 40, 255 )
	
end

/*---------------------------------------------------------
	TextEntry
---------------------------------------------------------*/
function SKIN:PaintTextEntry( panel )

	if ( panel.m_bBackground ) then
	
		surface.SetDrawColor( self.colTextEntryBG )
		surface.DrawRect( 0, 0, panel:GetWide(), panel:GetTall() )
	
	end
	
	panel:DrawTextEntryText( panel.m_colText, panel.m_colHighlight, panel.m_colCursor )
	
	if ( panel.m_bBorder ) then
	
		surface.SetDrawColor( self.colTextEntryBorder )
		surface.DrawOutlinedRect( 0, 0, panel:GetWide(), panel:GetTall() )
	
	end

	
end
function SKIN:SchemeTextEntry( panel )

	panel:SetTextColor( self.colTextEntryText )
	panel:SetHighlightColor( self.colTextEntryTextHighlight )
	panel:SetCursorColor( Color( 0, 0, 100, 255 ) )

end

/*---------------------------------------------------------
	Label
---------------------------------------------------------*/
function SKIN:PaintLabel( panel )
	return false
end

function SKIN:SchemeLabel( panel )

	local col = nil

	if ( panel.Hovered && panel:GetTextColorHovered() ) then
		col = panel:GetTextColorHovered()
	else
		col = panel:GetTextColor()
	end
	
	if ( col ) then
		panel:SetFGColor( col.r, col.g, col.b, col.a )
	else
		panel:SetFGColor( 200, 200, 200, 255 )
	end

end

function SKIN:LayoutLabel( panel )

	panel:ApplySchemeSettings()
	
	if ( panel.m_bAutoStretchVertical ) then
		panel:SizeToContentsY()
	end
	
end

/*---------------------------------------------------------
	CategoryHeader
---------------------------------------------------------*/
function SKIN:PaintCategoryHeader( panel )
		
end

function SKIN:SchemeCategoryHeader( panel )
	
	panel:SetTextInset( 5 )
	panel:SetFont( self.fontCategoryHeader )
	
	if ( panel:GetParent():GetExpanded() ) then
		panel:SetTextColor( self.colCategoryText )
	else
		panel:SetTextColor( self.colCategoryTextInactive )
	end
	
end

/*---------------------------------------------------------
	CategoryHeader
---------------------------------------------------------*/
function SKIN:PaintCollapsibleCategory( panel )
	
	draw.RoundedBox( 4, 0, 0, panel:GetWide(), panel:GetTall(), self.colCollapsibleCategory )
	
end

/*---------------------------------------------------------
	Tab
---------------------------------------------------------*/
function SKIN:PaintTab( panel )

	if ( panel:GetPropertySheet():GetActiveTab() == panel ) then
		draw.RoundedBox( 8, 0, 0, panel:GetWide(), panel:GetTall() + 8, self.colTabShadow )
		draw.RoundedBox( 8, 1, 1, panel:GetWide()-2, panel:GetTall() + 8, self.colTab )
	else
		draw.RoundedBox( 8, 0, 1, panel:GetWide(), panel:GetTall() + 8, self.colTabShadow )
		draw.RoundedBox( 8, 1, 2, panel:GetWide()-2, panel:GetTall() + 8, self.colTabInactive  )
	end
	
end
function SKIN:SchemeTab( panel )

	panel:SetFont( self.fontTab )
	panel:SetExpensiveShadow( 1, color_black )

	local ExtraInset = 10

	if ( panel.Image ) then
		ExtraInset = ExtraInset + panel.Image:GetWide()
	end
	
	panel:SetTextInset( ExtraInset )
	panel:SizeToContents()
	panel:SetSize( panel:GetWide() + 10, panel:GetTall() + 8 )
	
	local Active = panel:GetPropertySheet():GetActiveTab() == panel
	
	if ( Active ) then
		panel:SetTextColor( self.colTabText )
	else
		panel:SetTextColor( self.colTabTextInactive )
	end
	
	panel.BaseClass.ApplySchemeSettings( panel )
		
end

function SKIN:LayoutTab( panel )

	panel:SetTall( 22 )

	if ( panel.Image ) then
	
		local Active = panel:GetPropertySheet():GetActiveTab() == panel
		
		local Diff = panel:GetTall() - panel.Image:GetTall()
		panel.Image:SetPos( 7, Diff * 0.6 )
		
		if ( !Active ) then
			panel.Image:SetImageColor( Color( 170, 170, 170, 155 ) )
		else
			panel.Image:SetImageColor( Color( 255, 255, 255, 255 ) )
		end
	
	end	
	
end



/*---------------------------------------------------------
	PropertySheet
---------------------------------------------------------*/
function SKIN:PaintPropertySheet( panel )

	local ActiveTab = panel:GetActiveTab()
	local Offset = 0
	if ( ActiveTab ) then Offset = ActiveTab:GetTall() end
	
	// This adds a little shadow to the right which helps define the tab shape..
	draw.RoundedBox( 8, 0, Offset, panel:GetWide(), panel:GetTall() - Offset, self.colPropertySheet )
	
end

/*---------------------------------------------------------
	ListView
---------------------------------------------------------*/
function SKIN:PaintListView( panel )

	if ( panel.m_bBackground ) then
		self:DrawGenericBackground( 0, 0, panel:GetWide(), panel:GetTall(), self.bg_color_dark )
	end
	
end
	
/*---------------------------------------------------------
	ListViewLine
---------------------------------------------------------*/
function SKIN:PaintListViewLine( panel )

	local Col = nil
	
	if ( panel:IsSelected() ) then
	
		Col = self.listview_selected
		
	elseif ( panel.Hovered ) then
	
		Col = self.listview_hover
		
	elseif ( panel.m_bAlt ) then
	
		Col = self.bg_alt2
		
	else
	
		return
				
	end
		
	draw.RoundedBox( 4, 0, 0, panel:GetWide(), panel:GetTall(), Col )
	
end


/*---------------------------------------------------------
	ListViewLabel
---------------------------------------------------------*/
function SKIN:SchemeListViewLabel( panel )

	panel:SetTextInset( 3 )
	panel:SetTextColor( color_white ) 
	
end



/*---------------------------------------------------------
	Form
---------------------------------------------------------*/
function SKIN:PaintForm( panel )

	local color = self.bg_color_sleep

	self:DrawGenericBackground( 0, 9, panel:GetWide(), panel:GetTall()-9, self.bg_color )

end
function SKIN:SchemeForm( panel )

	panel.Label:SetFont( "TabLarge" )
	panel.Label:SetTextColor( color_white )

end
function SKIN:LayoutForm( panel )

end


/*---------------------------------------------------------
	MultiChoice
---------------------------------------------------------*/
function SKIN:LayoutMultiChoice( panel )

	panel.TextEntry:SetSize( panel:GetWide(), panel:GetTall() )
	
	panel.DropButton:SetSize( panel:GetTall(), panel:GetTall() )
	panel.DropButton:SetPos( panel:GetWide() - panel:GetTall(), 0 )
	
	panel.DropButton:SetZPos( 1 )
	panel.DropButton:SetDrawBackground( false )
	panel.DropButton:SetDrawBorder( false )
	
	panel.DropButton:SetTextColor( Color( 30, 100, 200, 255 ) )
	panel.DropButton:SetTextColorHovered( Color( 50, 150, 255, 255 ) )
	
end


/*
NumberWangIndicator
*/

function SKIN:DrawNumberWangIndicatorText( panel, wang, x, y, number, alpha )

	local alpha = math.Clamp( alpha ^ 0.5, 0, 1 ) * 255
	local col = self.text_dark
	
	// Highlight round numbers
	local dec = (wang:GetDecimals() + 1) * 10
	if ( number / dec == math.ceil( number / dec ) ) then
		col = self.text_highlight
	end

	draw.SimpleText( number, "Default", x, y, Color( col.r, col.g, col.b, alpha ) )
	
end



function SKIN:PaintNumberWangIndicator( panel )
	
	/*
	
		Please excuse the crudeness of this code.
	
	*/

	if ( panel.m_bTop ) then
		surface.SetMaterial( self.texGradientUp )
	else
		surface.SetMaterial( self.texGradientDown )
	end
	
	surface.SetDrawColor( self.colNumberWangBG )
	surface.DrawTexturedRect( 0, 0, panel:GetWide(), panel:GetTall() )
	
	local wang = panel:GetWang()
	local CurNum = math.floor( wang:GetFloatValue() )
	local Diff = CurNum - wang:GetFloatValue()
		
	local InsetX = 3
	local InsetY = 5
	local Increment = wang:GetTall()
	local Offset = Diff * Increment
	local EndPoint = panel:GetTall()
	local Num = CurNum
	local NumInc = 1
	
	if ( panel.m_bTop ) then
	
		local Min = wang:GetMin()
		local Start = panel:GetTall() + Offset
		local End = Increment * -1
		
		CurNum = CurNum + NumInc
		for y = Start, Increment * -1, End do
	
			CurNum = CurNum - NumInc
			if ( CurNum < Min ) then break end
					
			self:DrawNumberWangIndicatorText( panel, wang, InsetX, y + InsetY, CurNum, y / panel:GetTall() )
		
		end
	
	else
	
		local Max = wang:GetMax()
		
		for y = Offset - Increment, panel:GetTall(), Increment do
			
			self:DrawNumberWangIndicatorText( panel, wang, InsetX, y + InsetY, CurNum, 1 - ((y+Increment) / panel:GetTall()) )
			
			CurNum = CurNum + NumInc
			if ( CurNum > Max ) then break end
		
		end
	
	end
	

end

function SKIN:LayoutNumberWangIndicator( panel )

	panel.Height = 200

	local wang = panel:GetWang()
	local x, y = wang:LocalToScreen( 0, wang:GetTall() )
	
	if ( panel.m_bTop ) then
		y = y - panel.Height - wang:GetTall()
	end
	
	panel:SetPos( x, y )
	panel:SetSize( wang:GetWide() - wang.Wanger:GetWide(), panel.Height)

end

/*---------------------------------------------------------
	CheckBox
---------------------------------------------------------*/
function SKIN:PaintCheckBox( panel )

	local w, h = panel:GetSize()

	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawRect( 1, 1, w-2, h-2 )

	surface.SetDrawColor( 30, 30, 30, 255 )
	//=
	surface.DrawRect( 1, 0, w-2, 1 )
	surface.DrawRect( 1, h-1, w-2, 1 )
	//||
	surface.DrawRect( 0, 1, 1, h-2 )
	surface.DrawRect( w-1, 1, 1, h-2 )
	
	surface.DrawRect( 1, 1, 1, 1 )
	surface.DrawRect( w-2, 1, 1, 1 )
	
	surface.DrawRect( 1, h-2, 1, 1 )
	surface.DrawRect( w-2, h-2, 1, 1 )

end

--[[function SKIN:SchemeCheckBox( panel )

	panel:SetTextColor( color_black )
	DSysButton.ApplySchemeSettings( panel )
	
end]]



/*---------------------------------------------------------
	Slider
---------------------------------------------------------*/
function SKIN:PaintSlider( panel )

end


/*---------------------------------------------------------
	NumSlider
---------------------------------------------------------*/
function SKIN:PaintNumSlider( panel )

	local w, h = panel:GetSize()
	
	self:DrawGenericBackground( 0, 0, w, h, Color( 255, 255, 255, 20 ) )
	
	surface.SetDrawColor( 0, 0, 0, 200 )
	surface.DrawRect( 3, h/2, w-6, 1 )
	
end


/*---------------------------------------------------------
	NumSlider
---------------------------------------------------------*/
function SKIN:PaintComboBoxItem( panel )

	if ( panel:GetSelected() ) then
		local col = self.combobox_selected
		surface.SetDrawColor( col.r, col.g, col.b, col.a )
		panel:DrawFilledRect()
	end

end

function SKIN:SchemeComboBoxItem( panel )
	panel:SetTextColor( color_black )
end

/*---------------------------------------------------------
	ComboBox
---------------------------------------------------------*/
function SKIN:PaintComboBox( panel )
	
	surface.SetDrawColor( 255, 255, 255, 255 )
	panel:DrawFilledRect()
		
	surface.SetDrawColor( 0, 0, 0, 255 )
	panel:DrawOutlinedRect()
	
end


/*---------------------------------------------------------
	Tree
---------------------------------------------------------*/
function SKIN:PaintTree( panel )

	if ( panel.m_bBackground ) then
		surface.SetDrawColor( self.bg_color_bright.r, self.bg_color_bright.g, self.bg_color_bright.b, self.bg_color_bright.a )
		panel:DrawFilledRect()
	end

end



/*---------------------------------------------------------
	TinyButton
---------------------------------------------------------*/
function SKIN:PaintTinyButton( panel )

	if ( panel.m_bBackground ) then
	
		surface.SetDrawColor( 255, 255, 255, 255 )
		panel:DrawFilledRect()
	
	end
	
	if ( panel.m_bBorder ) then

		surface.SetDrawColor( 0, 0, 0, 255 )
		panel:DrawOutlinedRect()
	
	end

end

function SKIN:SchemeTinyButton( panel )

	panel:SetFont( "Default" )
	
	if ( panel:GetDisabled() ) then
		panel:SetTextColor( Color( 0, 0, 0, 50 ) )
	else
		panel:SetTextColor( color_black )
	end
	
	DLabel.ApplySchemeSettings( panel )
	
	panel:SetFont( "DefaultSmall" )

end

/*---------------------------------------------------------
	TinyButton
---------------------------------------------------------*/
function SKIN:PaintTreeNodeButton( panel )

	if ( panel.m_bSelected ) then

		surface.SetDrawColor( 50, 200, 255, 150 )
		panel:DrawFilledRect()
	
	elseif ( panel.Hovered ) then

		surface.SetDrawColor( 255, 255, 255, 100 )
		panel:DrawFilledRect()
	
	end
	
	

end

function SKIN:SchemeTreeNodeButton( panel )

	DLabel.ApplySchemeSettings( panel )

end

/*---------------------------------------------------------
	VoiceNotify
---------------------------------------------------------*/

function SKIN:PaintVoiceNotify( panel )

	local w, h = panel:GetSize()
	
	self:DrawGenericBackground( 0, 0, w, h, panel.Color )
	self:DrawGenericBackground( 1, 1, w-2, h-2, Color( 60, 60, 60, 240 ) )

end

function SKIN:SchemeVoiceNotify( panel )

	panel.LabelName:SetFont( "TabLarge" )
	panel.LabelName:SetContentAlignment( 4 )
	panel.LabelName:SetColor( color_white )
	
	panel:InvalidateLayout()
	
end

function SKIN:LayoutVoiceNotify( panel )

	panel:SetSize( 200, 40 )
	panel.Avatar:SetPos( 4, 4 )
	panel.Avatar:SetSize( 32, 32 )
	
	panel.LabelName:SetPos( 44, 0 )
	panel.LabelName:SizeToContents()
	panel.LabelName:CenterVertical()

end

derma.DefineSkin( "DarkRP", "", SKIN )

/*   _                                
    ( )                               
   _| |   __   _ __   ___ ___     _ _ 
 /'_` | /'__`\( '__)/' _ ` _ `\ /'_` )
( (_| |(  ___/| |   | ( ) ( ) |( (_| |
`\__,_)`\____)(_)   (_) (_) (_)`\__,_) 

*/

local PANEL = {}

function PANEL:Init()

	self:SetTitle( "Derma Initiative Control Test" )
	self.ContentPanel = vgui.Create( "DPropertySheet", self )
	
	self:InvalidateLayout( true )
	local w, h = self:GetSize()
	
	local Controls = table.Copy( derma.GetControlList() )
		
	for id, ctrl in pairs( Controls ) do
	
		local Ctrls = _G[ ctrl.ClassName ]
		if ( Ctrls && Ctrls.GenerateExample ) then
		
			Ctrls:GenerateExample( ctrl.ClassName, self.ContentPanel, w, h )
		
		end
	
	end
	

end


function PANEL:PerformLayout()

	self:SetSize( 600, 450 )
	
	self.ContentPanel:StretchToParent( 4, 24, 4, 4 )
	
	DFrame.PerformLayout( self )

end


local vguiExampleWindow = vgui.RegisterTable( PANEL, "DFrame" )

//
// This is all to open the actual window via concommand
//
local DermaExample = nil

local function OpenTestWindow()

	if ( DermaExample && DermaExample:IsValid() ) then return end
	
	DermaExample = vgui.CreateFromTable( vguiExampleWindow )
	DermaExample:SetSkin( "DarkRP" )
	DermaExample:MakePopup()
	DermaExample:Center()

end

concommand.Add( "derma_controls_gm", OpenTestWindow )