-- Disarm
-- From gw_ref lua script.
-- By GhosT:McSteve, 3.12.06, www.ghostworks.co.uk
--     Thanks to Fusion for his patience during the debugging.
--     Credit to im2good4u for his noweapons script.


-- Global var

disarm = {
    ["time"]    = 0,
    ["weapons"] = {
        nil,    --  1
        false,  --  2 WP_LUGER
        false,  --  3 WP_MP40
        false,  --  4 WP_GRENADE_LAUNCHER
        false,  --  5 WP_PANZERFAUST
        false,  --  6 WP_FLAMETHROWER
        false,  --  7 WP_COLT              // equivalent american weapon to german luger
        false,  --  8 WP_THOMPSON          // equivalent american weapon to german mp40
        false,  --  9 WP_GRENADE_PINEAPPLE
        false,  -- 10 WP_STEN              // silenced sten sub-machinegun
        true,   -- 11 WP_MEDIC_SYRINGE     // JPW NERVE -- broken out from CLASS_SPECIAL per Id request
        false,  -- 12 WP_AMMO              // JPW NERVE likewise
        false,  -- 13 WP_ARTY
        false,  -- 14 WP_SILENCER          // used to be sp5
        false,  -- 15 WP_DYNAMITE
        nil,    -- 16
        nil,    -- 17
        nil,    -- 18
        false,  -- 19 WP_MEDKIT
        false,  -- 20 WP_BINOCULARS
        nil,    -- 21
        nil,    -- 22
        false,  -- 23 WP_KAR98             // WolfXP weapons
        false,  -- 24 WP_CARBINE
        false,  -- 25 WP_GARAND
        false,  -- 26 WP_LANDMINE
        false,  -- 27 WP_SATCHEL
        false,  -- 28 WP_SATCHEL_DET
        nil,    -- 29
        false,  -- 30 WP_SMOKE_BOMB
        false,  -- 31 WP_MOBILE_MG42
        false,  -- 32 WP_K43
        false,  -- 33 WP_FG42
        nil,    -- 34
        false,  -- 35 WP_MORTAR
        nil,    -- 36
        false,  -- 37 WP_AKIMBO_COLT
        false,  -- 38 WP_AKIMBO_LUGER
        nil,    -- 39
        nil,    -- 40
        false,  -- 41 WP_SILENCED_COLT
        false,  -- 42 WP_GARAND_SCOPE
        false,  -- 43 WP_K43_SCOPE
        false,  -- 44 WP_FG42SCOPE
        false,  -- 45 WP_MORTAR_SET
        true,   -- 46 WP_MEDIC_ADRENALINE
        false,  -- 47 WP_AKIMBO_SILENCEDCOLT
        false   -- 48 WP_AKIMBO_SILENCEDLUGER
    },
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
--  vars is the local vars passed from et_RunFrame function.
function checkDisarmRunFrame(vars)
    if vars["levelTime"] - disarm["time"] > 2000 then
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
