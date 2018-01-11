-- Disarm
-- From gw_ref script.
-- By GhosT:McSteve, 3.12.06, www.ghostworks.co.uk
--     Thanks to Fusion for his patience during the debugging.
--     Credit to im2good4u for his noweapons script.


-- Global var

disarm = {
    -- Time (in ms) of last disarm check.
    ["time"]    = 0,
    -- Weapons list to disarm player.
    ["weapons"] = {
                [2]  = false,  -- Luger
                [3]  = false,  -- MP40
                [4]  = false,  -- Grenade launcher (Axis grenade)
                [5]  = false,  -- Panzerfaust
                [6]  = false,  -- Flamethrower
                [7]  = false,  -- Colt
                [8]  = false,  -- Thompson
                [9]  = false,  -- Grenade pineapple (Allies grenade)
                [10] = false,  -- Sten
                [11] = true,   -- Medic syringe
                [14] = false,  -- Silenced Luger
                [23] = false,  -- K43
                [24] = false,  -- M1 Garand
                [25] = false,  -- Silenced M1 Garand
                [31] = false,  -- Mobile MG42
                [32] = false,  -- Silenced K43
                [33] = false,  -- FG42
                [35] = false,  -- Mortar
                [37] = false,  -- Akimbo Colt
                [38] = false,  -- Akimbo Luger
                [40] = false,  -- Riffle
                [41] = false,  -- Silenced colt
                [42] = false,  -- M1 Garand scope
                [43] = false,  -- K43 scope
                [44] = false,  -- FG42 scope
                [46] = true,   -- Medic adrenaline
                [47] = false,  -- Akimbo silenced Colt
                [48] = false   -- Akimbo silenced Luger
    },
    -- Number of disarmed players.
    ["count"]   = 0
}

-- Set default client data.
clientDefaultData["disarm"] = 0

-- Set module command.
cmdList["client"]["!disarm"]        = "/command/both/disarm.lua"
cmdList["client"]["!rearm"]         = "/command/both/rearm.lua"
cmdList["client"]["!disarm_reset"]  = "/command/both/disarm_reset.lua"
cmdList["console"]["!disarm"]       = "/command/both/disarm.lua"
cmdList["console"]["!rearm"]        = "/command/both/rearm.lua"
cmdList["console"]["!disarm_reset"] = "/command/both/disarm_reset.lua"

-- Function

-- Callback function when qagame runs a server frame.
-- Check all playes and disarm it if needed.
--  vars is the local vars passed from et_RunFrame function.
function checkDisarmRunFrame(vars)
    if vars["levelTime"] - disarm["time"] >= 2000 then
        for i = 0, clientsLimit do
            if client[i]["disarm"] == 1 then
                -- NOTE : et.MAX_WEAPONS = 50
                for w = 1, 49, 1 do
                    if not disarm["weapons"][w] then
                        et.gentity_set(i, "ps.ammoclip", w, 0)
                        et.gentity_set(i, "ps.ammo", w, 0)
                    end
                end
            end
        end

        disarm["time"] = vars["levelTime"] -- Next checking in 2 seconds.
    end
end
