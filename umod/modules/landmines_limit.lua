-- Landmines limit

--------------------------------------------------------------------------------
-- ETW_Mines -- Set the number of mines according to number of players
-- created by [ETW-FZ] Schnoog (http://etw-funzone.eu/)
--------------------------------------------------------------------------------
-- This script can be freely used and modified as long as [ETW-FZ] and the 
-- original authors are mentioned.
--------------------------------------------------------------------------------

-- TODO : Make maximum landmines configurable.

-- Global var

landminesLimit = {
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

    if et.trap_Cvar_Get(landminesLimit["maxLandminesCvar"]) == 0 then
        et.G_LogPrint("Landmines is disabled! Please enable it with " .. landminesLimit["maxLandminesCvar"] .. " cvar.\n")
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
        local maxMines

        if players["active"] > 8 then
            maxMines = 15
        elseif players["active"] > 6 then
            maxMines = 10
        elseif players["active"] > 4 then
            maxMines = 8
        else
            maxMines = 5
        end

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
