--  Disarm from gw_ref lua script
--  By GhosT:McSteve, 3.12.06, www.ghostworks.co.uk
--  	Thanks to Fusion for his patience during the debugging.
--  	Credit to im2good4u for his noweapons script.


-- Global var

disarm = {
    ["samplerate"] = 2000,
    ["weapons"]    = {
        nil,	--// 1
        false,	--WP_LUGER,				// 2
        false,	--WP_MP40,				// 3
        false,	--WP_GRENADE_LAUNCHER,	// 4
        false,	--WP_PANZERFAUST,		// 5
        false,	--WP_FLAMETHROWER,		// 6
        false,	--WP_COLT,				// 7	// equivalent american weapon to german luger
        false,	--WP_THOMPSON,			// 8	// equivalent american weapon to german mp40
        false,	--WP_GRENADE_PINEAPPLE,	// 9
        false,	--WP_STEN,				// 10	// silenced sten sub-machinegun
        true,	--WP_MEDIC_SYRINGE,		// 11	// JPW NERVE -- broken out from CLASS_SPECIAL per Id request
        false,	--WP_AMMO,				// 12	// JPW NERVE likewise
        false,	--WP_ARTY,				// 13
        false,	--WP_SILENCER,			// 14	// used to be sp5
        false,	--WP_DYNAMITE,			// 15
        nil,	--// 16
        nil,	--// 17
        nil,		--// 18
        false,	--WP_MEDKIT,			// 19
        false,	--WP_BINOCULARS,		// 20
        nil,	--// 21
        nil,	--// 22
        false,	--WP_KAR98,				// 23	// WolfXP weapons
        false,	--WP_CARBINE,			// 24
        false,	--WP_GARAND,			// 25
        false,	--WP_LANDMINE,			// 26
        false,	--WP_SATCHEL,			// 27
        false,	--WP_SATCHEL_DET,		// 28
        nil,	--// 29
        false,	--WP_SMOKE_BOMB,		// 30
        false,	--WP_MOBILE_MG42,		// 31
        false,	--WP_K43,				// 32
        false,	--WP_FG42,				// 33
        nil,	--// 34
        false,	--WP_MORTAR,			// 35
        nil,	--// 36
        false,	--WP_AKIMBO_COLT,		// 37
        false,	--WP_AKIMBO_LUGER,		// 38
        nil,	--// 39
        nil,	--// 40
        false,	--WP_SILENCED_COLT,		// 41
        false,	--WP_GARAND_SCOPE,		// 42
        false,	--WP_K43_SCOPE,			// 43
        false,	--WP_FG42SCOPE,			// 44
        false,	--WP_MORTAR_SET,		// 45
        true,	--WP_MEDIC_ADRENALINE,	// 46
        false,	--WP_AKIMBO_SILENCEDCOLT,// 47
        false	--WP_AKIMBO_SILENCEDLUGER,// 48
    }
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
	if math.mod(vars["levelTime"], disarm["samplerate"]) ~= 0 then
        return
    end

	for i = 0, clientsLimit do
		if client[i]["disarm"] == 1 then
            -- Note : et.MAX_WEAPONS = 50
            for w = 1, 49, 1 do
                if not disarm["weapons"][w] then
                    et.gentity_set(i, "ps.ammoclip", w, 0)
                    et.gentity_set(i, "ps.ammo", w, 0)
                end
            end
		end
	end
end

-- Add callback disarm function.
addCallbackFunction({
    ["RunFrame"] = "checkDisarmRunFrame"
})
