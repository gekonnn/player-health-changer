-- Made by Chlebak

if CLIENT then

    local godmode = CreateConVar( "god_enabled", "0", FCVAR_NONE, "Godmode enabled", 0, 1 )
    local health = CreateConVar( "health_value", "100", FCVAR_NONE, "Player's health", 0, 99999999, function()
        print("Changed hp")
        health_savesettings()
    end)
    local suit = CreateConVar( "armor_value", "0", FCVAR_NONE, "Player's armor level", -1, 99999999 )

    local print_message = CreateConVar( "health_chatprint", "1", FCVAR_NONE, "Print message to chat once saving health", 0, 1 )

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
        size = 14
    } )

    local scrw, scrh = ScrW(), ScrH()

    local frame_w, frame_h = 300, 130
    local frame_color = Color( 45, 55, 65, 255 )

    local btn_close_w, btn_close_h = 20, 20
    local btn_close_x, btn_close_y = frame_w - 25, frame_h - frame_h + 5
    local btn_close_color = Color( 255, 100, 100 )
    local btn_close_textcolor = Color( 0, 0, 0 )

    local title_x, title_y = 10, 5
    local title_w, title_h = 300, 22
    local title_text = "Health Changer"

    local btn_save_x, btn_save_y = 10, frame_h - 25
    local btn_save_width, btn_save_height = frame_w / 2 - 10, 15
    local btn_save_text = "Save health"
    local btn_save_color = Color( 0, 185, 45 )

    local btn_save_max_x, btn_save_max_y = 160, frame_h - 25
    local btn_save_max_width, btn_save_max_height = 130, 15
    local btn_save_max_text = "Save max. health"
    local btn_save_max_color = Color( 0, 185, 45 )

    concommand.Add("health_menu", function( ply, cmd, args )

        drawhud()

    end)

    concommand.Add("health_save", function( ply, cmd, args )

        health_savesettings()

    end)

    -- Create icon in "C" menu
    function draw_c_button()
        list.Set( "DesktopWindows", "hc_menu", {
        title = "Health Changer",
        icon = "materials/icon64/healthchanger.png",
        init = function( icon, window )
            drawhud()
        end
    } )
    end

    function health_savesettings()

        net.Start( "net_health" )
        net.WriteFloat( health:GetInt() )
        net.SendToServer()

        net.Start( "net_suit" )
        net.WriteFloat( suit:GetInt() )
        net.SendToServer()

        net.Start( "net_god" )
        net.WriteBool( godmode:GetBool() )
        net.SendToServer()

        print("Saved player's health")
        if print_message:GetBool() then
            chat.AddText( Color( 40, 215, 80 ), "Saved ", LocalPlayer(), "'s health")
        end

    end

    draw_c_button()

    function health_save_max()

        net.Start( "net_max_health" )
        net.WriteFloat( health:GetInt() )
        net.SendToServer()

        net.Start( "net_max_suit" )
        net.WriteFloat( suit:GetInt() )
        net.SendToServer()
        print("Saved player's maximum health")

        if print_message:GetBool() then
            chat.AddText( Color( 40, 215, 80 ), "Saved ", LocalPlayer(), "'s max health")
        end


    end

    function drawhud()

        -- Frame
        local frame = vgui.Create( "DFrame" )
        frame:SetSize( frame_w, frame_h )
        frame:SetPos( scrw / 2 - ( frame_w / 2 ), scrh )
        frame:MoveTo( scrw / 2 - ( frame_w / 2 ), scrh / 2 - ( frame_h / 2 ), 1, 0, .1 )
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
        local healthslider = vgui.Create( "DNumSlider", frame )
        healthslider:SetPos( 10, 40 )
        healthslider:SetSize( 300, 10 )
        healthslider:SetText( "Health" )
        healthslider:SetMin( 1 )
        healthslider:SetMax( 10000 )
        healthslider:SetConVar( "health_value" )
        healthslider:SetDecimals( 0 )

        -- Armor slider
        local armor = vgui.Create( "DNumSlider", frame )
        armor:SetPos( 10, 60 )
        armor:SetSize( 300, 10 )
        armor:SetText( "Armor" )
        armor:SetMin( 1 )
        armor:SetMax( 10000 )
        armor:SetConVar( "armor_value" )
        armor:SetDecimals( 0 )

        -- Godmode
        local god_checkbox = frame:Add( "DCheckBoxLabel" )
        god_checkbox:SetPos( 10, 80 )
        god_checkbox:SetText( "God Mode" )
        god_checkbox:SetConVar( "god_enabled" )
        god_checkbox:SizeToContents()

        -- Save button
        local savebtn = vgui.Create( "DButton", frame )
        savebtn:SetText( "" )
        savebtn:SetPos( btn_save_x, btn_save_y )
        savebtn:SetSize( btn_save_width, btn_save_height )
        savebtn.DoClick = function()
            health_savesettings()
        end

        savebtn.Paint = function()
            draw.RoundedBox( 5, 0, 0, btn_save_width, btn_save_height, btn_save_color )
        end

        -- Save button text
        local savebtntext = vgui.Create( "DLabel", frame )
        savebtntext:SetPos( btn_save_x + ( btn_save_width / 2 - 30 ), btn_save_y )
        savebtntext:SetSize( 100, 14 )
        savebtntext:SetText( btn_save_text )
        savebtntext:SetFont( "save_roboto" )
        savebtntext:SetColor( Color( 0, 0, 0 ) )

        -- Save maximum health button
        local savemax = vgui.Create( "DButton", frame )
        savemax:SetText( "" )
        savemax:SetPos( btn_save_max_x, btn_save_max_y )
        savemax:SetSize( btn_save_max_width, btn_save_max_height )
        savemax.DoClick = function()
            health_save_max()
        end

        savemax.Paint = function()
            draw.RoundedBox( 5, 0, 0, btn_save_max_width, btn_save_max_height, btn_save_max_color )
        end

        -- Save button text
        local savemaxtext = vgui.Create( "DLabel", frame )
        savemaxtext:SetPos( btn_save_max_x + ( btn_save_max_width / 2 - 40 ), btn_save_max_y )
        savemaxtext:SetSize( btn_save_max_width, btn_save_max_height )
        savemaxtext:SetText( btn_save_max_text )
        savemaxtext:SetFont( "save_roboto" )
        savemaxtext:SetColor( Color( 0, 0, 0 ) )

end

end