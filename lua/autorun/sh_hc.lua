-- Made by Chlebak

if CLIENT then
    local ply = LocalPlayer()
    
    local cv_health = CreateClientConVar( "hc_health", "100", false, false, "Sets player's health to specified value", 0, 99999999 )
    local cv_maxhealth = CreateClientConVar( "hc_maxhealth", "100", false, false, "Sets player's max health to specified value", 0, 99999999 )
    local cv_armor = CreateClientConVar( "hc_armor", "0", false, false, "Sets player's armor level to specified value", 0, 99999999 )
    local cv_maxarmor = CreateClientConVar( "hc_maxarmor", "0", false, false, "Sets player's max armor level to specified value", 0, 99999999 )
    local cv_godmode = CreateClientConVar( "hc_godmode", "0", false, false, "Toggles godmode", 0, 1 )

    surface.CreateFont( "close_roboto", {
        font = "Roboto",
        size = 13
    } )
    surface.CreateFont( "title_roboto", {
        font = "Roboto",
        size = 22
    } )
    surface.CreateFont( "reset_roboto", {
        font = "Roboto",
        size = 12
    } )
    surface.CreateFont( "save_roboto", {
        font = "Roboto",
        size = 16,
        weight = 550
    } )

    local scrw, scrh = ScrW(), ScrH()

    local frame_w, frame_h = 300, 105
    local frame_pos_x = scrw / 2 - ( frame_w / 2 )
    local frame_pos_y = scrh / 2 - ( frame_h / 2 )
    local frame_color = Color( 45, 55, 65, 255 )

    local btn_close_w, btn_close_h = 20, 20
    local btn_close_x, btn_close_y = frame_w - 25, frame_h - frame_h + 5
    local btn_close_color = Color( 255, 100, 100 )
    local btn_close_textcolor = Color( 0, 0, 0 )

    local btn_reset_w, btn_reset_h = 16, 16
    local btn_reset_x, btn_reset_y = frame_w - 50, frame_h - frame_h + 7

    local title_x, title_y = 10, 5
    local title_w, title_h = 300, 22
    local title_text = "Health Changer"

    local btn_save_x, btn_save_y = 10, frame_h - 25
    local btn_save_width, btn_save_height = frame_w / 2 - 10, 15
    local btn_save_text = "Set values"
    local btn_save_color = Color( 0, 185, 45 )

    local btn_save_max_x, btn_save_max_y = 160, frame_h - 25
    local btn_save_max_width, btn_save_max_height = 130, 15
    local btn_save_max_text = "Save max."
    local btn_save_max_color = Color( 0, 185, 45 )

    local savedhealth = 100
    local savedarmor = 0
    local savedgodmode = false
    local savedhptomaxhp = true

    cvars.AddChangeCallback( "hc_health", function(cv, oldValue, newValue)
        net.Start("save")
        net.WriteTable( { health = newValue} )
        net.SendToServer()
        savedhealth = newValue
    end)
    cvars.AddChangeCallback( "hc_maxhealth", function(cv, oldValue, newValue)
        net.Start("save")
        net.WriteTable( { maxhealth = newValue} )
        net.SendToServer()
    end)
    cvars.AddChangeCallback( "hc_armor", function(cv, oldValue, newValue)
        net.Start("save")
        net.WriteTable( { armor = newValue} )
        net.SendToServer()
        savedarmor = savedarmor
    end)
    cvars.AddChangeCallback( "hc_maxarmor", function(cv, oldValue, newValue)
        net.Start("save")
        net.WriteTable( { maxarmor = newValue} )
        net.SendToServer()
    end)
    cvars.AddChangeCallback( "hc_godmode", function(cv, oldValue, newValue)
        if newValue == "1" then
            net.Start("save")
            net.WriteTable( { godmode = true } )
            net.SendToServer()
        elseif newValue == "0" then
            net.Start("save")
            net.WriteTable( { godmode = false } )
            net.SendToServer()
        end
    end)

    concommand.Add("hc_menu", function( ply, cmd, args )
        drawhud()
    end)

    list.Set( "DesktopWindows", "hc_menu", 
    {
        title = "Health Changer",
        icon = "materials/icon64/healthchanger.png",
        init = function( icon, window )
            drawhud()
        end
    } )

    function drawhud()
        -- Frame
        local frame = vgui.Create( "DFrame" )
        frame:SetSize( frame_w, frame_h )
        frame:SetPos( frame_pos_x, scrh )
        frame:MoveTo( frame_pos_x, frame_pos_y, 1, 0, .1 )
        
        frame:ShowCloseButton( false )
        frame:SetTitle( "" )
        frame:MakePopup()
        frame.Paint = function()
            surface.SetDrawColor( frame_color )
            surface.DrawRect( 0, 0, frame_w, frame_h )
        end

        -- Close button
        local closebtn = vgui.Create( "DButton", frame )
        closebtn:SetText( "" )
        closebtn:SetPos( btn_close_x, btn_close_y )
        closebtn:SetSize( btn_close_w, btn_close_h )
        closebtn.DoClick = function()
            frame:Close()
        end

        closebtn.Paint = function()
            draw.RoundedBox( 5, 0, 0, btn_close_w, btn_close_h, btn_close_color )
        end

        -- Close button text
        local closebtn_text = vgui.Create( "DLabel", frame )
        closebtn_text:SetPos( btn_close_x + 7, btn_close_y + 1 )
        closebtn_text:SetText( "X" )
        closebtn_text:SetFont( "close_roboto" )
        closebtn_text:SetColor( btn_close_textcolor )

        -- Title text
        local title = vgui.Create( "DLabel", frame )
        title:SetPos( title_x, title_y )
        title:SetSize( title_w, title_h )
        title:SetText( title_text )
        title:SetFont( "title_roboto" )
        title:SetColor( Color( 255, 255, 255 ) )

        -- Health slider
        local slider_health = vgui.Create( "DNumSlider", frame )
        slider_health:SetPos( 10, 40 )
        slider_health:SetSize( 260, 10 )
        slider_health:SetText( "Health" )
        slider_health:SetMin( 0 )
        slider_health:SetMax( 10000 )
        slider_health:SetValue( savedhealth )
        slider_health:SetDecimals( 0 )

        slider_health.Slider.Knob.Paint = function(panel, width, height)
            surface.SetDrawColor(255,255,255,255)
            surface.SetMaterial( Material("icon16/heart.png") )
            surface.DrawTexturedRect( 0, 0, 16, 16)
        end

        -- armor slider
        local slider_armor = vgui.Create( "DNumSlider", frame )
        slider_armor:SetPos( 10, 60 )
        slider_armor:SetSize( 260, 10 )
        slider_armor:SetText( "Armor" )
        slider_armor:SetMin( 0 )
        slider_armor:SetMax( 10000 )
        slider_armor:SetValue( savedarmor )
        slider_armor:SetDecimals( 0 )

        slider_armor.Slider.Knob.Paint = function(panel, width, height)
            surface.SetDrawColor(255,255,255,255)
            surface.SetMaterial( Material("icon16/lightning.png") )
            surface.DrawTexturedRect( 0, 0, 16, 16)
        end

        -- -- Save button
        -- local savebtn = vgui.Create( "DButton", frame )
        -- savebtn:SetText( "" )
        -- savebtn:SetPos( btn_save_x, btn_save_y )
        -- savebtn:SetSize( btn_save_width, btn_save_height )
        -- savebtn.DoClick = function()
        --     -- health_savesettings()
        -- end

        -- savebtn.Paint = function()
        --     draw.RoundedBox( 5, 0, 0, btn_save_width, btn_save_height, btn_save_color )
        -- end

        -- -- Save button text
        -- local savebtntext = vgui.Create( "DLabel", frame )
        -- savebtntext:SetPos( btn_save_x + ( btn_save_width / 2 - 30 ), btn_save_y )
        -- savebtntext:SetSize( 100, 14 )
        -- savebtntext:SetText( btn_save_text )
        -- savebtntext:SetFont( "save_roboto" )
        -- savebtntext:SetColor( Color( 0, 0, 0 ) )

        -- -- Save maximum health button
        -- local savemax = vgui.Create( "DButton", frame )
        -- savemax:SetText( "" )
        -- savemax:SetPos( btn_save_max_x, btn_save_max_y )
        -- savemax:SetSize( btn_save_max_width, btn_save_max_height )
        -- savemax.DoClick = function()
        --     -- health_save_max()
        -- end

        -- savemax.Paint = function()
        --     draw.RoundedBox( 5, 0, 0, btn_save_max_width, btn_save_max_height, btn_save_max_color )
        -- end

        -- -- Save max button text
        -- local savemaxtext = vgui.Create( "DLabel", frame )
        -- savemaxtext:SetPos( btn_save_max_x + ( btn_save_max_width / 2 - 40 ), btn_save_max_y - 1 )
        -- savemaxtext:SetSize( btn_save_max_width, btn_save_max_height )
        -- savemaxtext:SetText( btn_save_max_text )
        -- savemaxtext:SetFont( "save_roboto" )
        -- savemaxtext:SetColor( Color( 0, 0, 0 ) )

        -- Save health button
        local save_health_btn = vgui.Create( "DImageButton", frame )
        save_health_btn:SetPos( 255, 38 )
        save_health_btn:SetSize( 16, 16 )
        save_health_btn:SetImage( "icon16/accept.png" )
        save_health_btn:SetTooltip('Set health.')

        -- Save max health button
        local save_max_health_btn = vgui.Create( "DImageButton", frame )
        save_max_health_btn:SetPos( 275, 38 )
        save_max_health_btn:SetSize( 16, 16 )
        save_max_health_btn:SetImage( "icon16/add.png" )
        save_max_health_btn:SetTooltip('Set max health.')

        -- Save health button
        local save_armor_btn = vgui.Create( "DImageButton", frame )
        save_armor_btn:SetPos( 255, 58 )
        save_armor_btn:SetSize( 16, 16 )
        save_armor_btn:SetImage( "icon16/accept.png" )
        save_armor_btn:SetTooltip('Set armor.')

        -- Save max health button
        local save_max_armor_btn = vgui.Create( "DImageButton", frame )
        save_max_armor_btn:SetPos( 275, 58 )
        save_max_armor_btn:SetSize( 16, 16 )
        save_max_armor_btn:SetImage( "icon16/add.png" )
        save_max_armor_btn:SetTooltip('Set max armor.')

        -- Godmode
        local checkbox_godmode = frame:Add( "DCheckBoxLabel" )
        checkbox_godmode:SetPos( 10, 80 )
        checkbox_godmode:SetText( "God mode" )
        -- checkbox_godmode:SetConVar( "hc_godmode" )
        checkbox_godmode:SizeToContents()
        checkbox_godmode:SetChecked( savedgodmode )
        function checkbox_godmode:OnChange(bVal)
            savedgodmode = bVal
            net.Start("save")
            net.WriteTable( { godmode = bVal } )
            net.SendToServer()
        end

        -- Godmode
        local checkbox_hp2maxhp = frame:Add( "DCheckBoxLabel" )
        checkbox_hp2maxhp:SetPos( 90, 80 )
        checkbox_hp2maxhp:SetText( "Set HP to Max HP on spawn" )
        checkbox_hp2maxhp:SizeToContents()
        checkbox_hp2maxhp:SetChecked( savedhptomaxhp )
        function checkbox_hp2maxhp:OnChange(bVal)
            savedhptomaxhp = bVal
            net.Start("save")
            net.WriteTable( { hp2maxhp = bVal } )
            net.SendToServer()
        end

        -- Reset button
        local resetbtn = vgui.Create( "DImageButton", frame )
        resetbtn:SetPos( btn_reset_x, btn_reset_y )
        resetbtn:SetSize( 16, 16 )
        resetbtn:SetImage( "icon16/arrow_undo.png" )
        resetbtn:SetTooltip('Restore default settings')
        resetbtn.DoClick = function()
            slider_health:SetValue(100)
            slider_armor:SetValue(0)
            checkbox_godmode:SetValue(false)
        end

        save_health_btn.DoClick = function()
            net.Start("save")
            net.WriteTable( { health = slider_health:GetTextArea():GetInt() } )
            net.SendToServer()
            savedhealth = slider_health:GetValue()
        end

        save_max_health_btn.DoClick = function()
            net.Start("save")
            net.WriteTable( { maxhealth = slider_health:GetTextArea():GetInt()} )
            net.SendToServer()
        end

        save_armor_btn.DoClick = function()
            net.Start("save")
            net.WriteTable( { armor = slider_armor:GetTextArea():GetInt()} )
            net.SendToServer()
            savedarmor = slider_armor:GetValue()
        end

        save_max_armor_btn.DoClick = function()
            net.Start("save")
            net.WriteTable( { maxarmor = slider_armor:GetTextArea():GetInt()} )
            net.SendToServer()
        end
    end
end