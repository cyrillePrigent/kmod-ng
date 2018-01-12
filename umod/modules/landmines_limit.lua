-- Landmines limit

--------------------------------------------------------------------------------
-- ETW_Mines -- Set the number of mines according to number of players
-- created by [ETW-FZ] Schnoog (http://etw-funzone.eu/)
--------------------------------------------------------------------------------
-- This script can be freely used and modified as long as [ETW-FZ] and the 
-- original authors are mentioned.
--------------------------------------------------------------------------------

-- Global var

landminesLimit = {
    -- Landmines limit list.
    --  key   => active players amount
    --  value => number of landmines allowed
    ["list"] = {},
    -- Landmines limit status.
    ["enabled"] = false,
    -- Current maximum landmines value.
    ["maxMines"] = 0,
    -- Landmines limit message position.
    ["msgPosition"] = et.trap_Cvar_Get("u_landmines_limit_msg_position"),
    -- Time (in ms) of last landmines limit check.
    ["time"] = 0,
    -- Interval (in ms) between 2 frame check.
    ["frameCheck"] = 3000 -- 3secs
}

-- Function

-- Called when qagame initializes.
-- Check if landmines is enabled.
--  vars is the local vars of et_InitGame function.
function landminesLimitInitGame(vars)
    if etMod == "etpro" then
        landminesLimit["maxLandminesCvar"] = "team_maxmines"
    elseif etMod == "etlegacy" then
        landminesLimit["maxLandminesCvar"] = "team_maxLandmines"
    end

    local landminesMin = tonumber(et.trap_Cvar_Get("u_landmines_limit_min"))

    if landminesMin == nil then
        et.G_LogPrint(
            "uMod Landmines limit: <u_landmines_limit_min> cvar don't exist !\n"
        )
    end

    local nbValue  = 0
    local lastValue = landminesMin

    for nbPlayers = 1, clientsLimit, 1 do
        local nbLandmines = tonumber(
            et.trap_Cvar_Get("u_lm_for_more_than_" .. nbPlayers .. "_players")
        )

        landminesLimit["list"][nbPlayers] = lastValue

        if nbLandmines ~= nil then
            nbValue = nbValue + 1
            lastValue = nbLandmines
        end
    end

    if nbValue < 1 then
        et.G_LogPrint(
            "uMod Landmines limit: One or more <u_lm_for_more_than_X_players>"
            " cvar(s) must be set in umod.cfg!\n"
        )
    else
        landminesLimit["enabled"] = true

        addCallbackFunction({["RunFrame"] = "checkLandminesLimitRunFrame"})
    end
end


-- Callback function when qagame runs a server frame.
-- Check number of players and set the number of mines according.
--  vars is the local vars passed from et_RunFrame function.
function checkLandminesLimitRunFrame(vars)
    if vars["levelTime"] - landminesLimit["time"] > landminesLimit["frameCheck"] then
        local maxMines = landminesLimit["list"][players["active"]]

        if landminesLimit["maxMines"] ~= maxMines then
            et.trap_Cvar_Set(landminesLimit["maxLandminesCvar"], maxMines)
    
            sayClients(
                landminesLimit["msgPosition"],
                color1 .. "Max. " .. color4 .. maxMines .. " mines allowed."
            )

            landminesLimit["maxMines"] = maxMines
        end

        landminesLimit["time"] = vars["levelTime"]
    end
end

-- Add callback landmines limit function.
addCallbackFunction({
    ["InitGame"] = "landminesLimitInitGame"
})
