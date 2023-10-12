util.AddNetworkString("save")

local saved_data = {}

hook.Add("PlayerInitialSpawn", "HealthChanger_AddTablePlayer", function(ply)
    saved_data[ply] = {["hp2maxhp"] = true}
end)

hook.Add("PlayerDisconnected", "HealthChanger_RemoveTablePlayer", function(ply)
    saved_data[ply] = nil
end)

hook.Add("PlayerLoadout", "HealthChanger_SpawnHealth", function(ply)
    if saved_data[ply] then
        if saved_data[ply]["maxhealth"] then
            if saved_data[ply]["hp2maxhp"] == true then
                ply:SetHealth(saved_data[ply]["maxhealth"])
            end
            ply:SetMaxHealth(saved_data[ply]["maxhealth"])
        end
        
        if saved_data[ply]["maxarmor"] then
            ply:SetMaxArmor(saved_data[ply]["maxarmor"])
        end
        
        if saved_data[ply]["godmode"] then
            ply:GodEnable()
        else
            ply:GodDisable()
        end
    end
end)

net.Receive("save", function(len, ply)
    local data = net.ReadTable()
    if ply:Alive() then
        if data.health then
            ply:SetHealth(data.health)
        end
        
        if data.maxhealth then
            ply:SetMaxHealth(data.maxhealth)
            saved_data[ply]["maxhealth"] = data.maxhealth
        end
        
        if data.armor then
            ply:SetArmor(data.armor)
        end
        
        if data.maxarmor then
            ply:SetMaxArmor(data.maxarmor)
            saved_data[ply]["maxarmor"] = data.maxarmor
        end
        
        if data.godmode then
            ply:GodEnable()
            saved_data[ply]["godmode"] = true
        else
            if data.godmode ~= nil and data.godmode == false then
                ply:GodDisable()
                saved_data[ply]["godmode"] = false 
            end
        end

        if data.hp2maxhp then
            saved_data[ply]["hp2maxhp"] = true
        else
            if data.hp2maxhp ~= nil and data.hp2maxhp == false then
                saved_data[ply]["hp2maxhp"] = false
            end
        end
    end
end)