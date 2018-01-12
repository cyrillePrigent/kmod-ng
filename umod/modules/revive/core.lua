-- Revive module

-- Global var

revive = {
    -- List of callback function called in checkRevivePrint function.
    ["printCallbackFunction"] = {},
    -- Revive announce status.
    ["announce"] = tonumber(et.trap_Cvar_Get("u_revive_announce")),
}

if tonumber(et.trap_Cvar_Get("u_revive_spree")) == 1 then
    dofile(umod_path .. "/modules/revive/spree.lua")
    table.insert(revive["printCallbackFunction"], "checkReviveSpree")
end

if tonumber(et.trap_Cvar_Get("u_multi_revive")) == 1 then
    dofile(umod_path .. "/modules/revive/multi.lua")
    table.insert(revive["printCallbackFunction"], "checkMultiRevive")
end

-- Function

-- Callback function whenever the server or qagame prints a string to the console.
-- Check medic revive line, display revive announce if enabled.
-- Check revive spree and multi revive if modules are enabled.
--  vars is the local vars of et_Print function.
function checkRevivePrint(vars)
    if vars["arg"][1] == "Medic_Revive:" then
        local medic  = tonumber(vars["arg"][2])
        local zombie = tonumber(vars["arg"][3])
        local tk     = (et.gentity_get(zombie, "enemy") == medic)

        for _, functionName in pairs(revive["printCallbackFunction"]) do
            result = _G[functionName](medic, zombie, tk)
        end

        -- Display revive announce.
        if revive["announce"] == 1 then
--             et.trap_SendServerCommand(
--                 -1,
--                 "cpm \"" .. client[zombie]["name"] .. color1 .. " was revived by " ..
--                 client[medic]["name"] .. "\""
--             )
        else
            return nil
        end
    end
end

-- Add callback revive function.
addCallbackFunction({
    ["Print"] = "checkRevivePrint"
})
