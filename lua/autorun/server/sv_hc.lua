-- Thanks for help to folks from Garry's Mod discord server! :)

local tick = 0
local think_internal = 5

util.AddNetworkString("net_health")
util.AddNetworkString("net_suit")
util.AddNetworkString("net_god")
util.AddNetworkString("net_max_health")
util.AddNetworkString("net_max_suit")

local health = 100
local suit = 0
local god = false

hook.Add("Think", "update_health", function()
    tick = tick + 1

    if tick == think_internal then
        tick = 0
        net.Receive( "net_health", function(len, ply)

            health = net.ReadFloat()
            ply:SetHealth(health)

        end)

        net.Receive( "net_suit", function(len, ply)

            suit = net.ReadFloat()
            ply:SetArmor(suit)

            if suit <= 1 then
                ply:SetArmor(0)
            end

        end)

        net.Receive( "net_god", function(len, ply)

            god = net.ReadBool()

            if god then
                ply:GodEnable()
            else
                ply:GodDisable()
            end

        end)

        net.Receive( "net_max_health", function(len, ply)

            health_max = net.ReadFloat()
            ply:SetMaxHealth(health_max)

        end)

        net.Receive( "net_max_suit", function(len, ply)

            suit_max = net.ReadFloat()
            ply:SetMaxArmor(suit_max)

        end)

    end

end)
