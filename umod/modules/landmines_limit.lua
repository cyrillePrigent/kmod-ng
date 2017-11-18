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
    ["time"]        = 0,
    ["maxMines"]    = 0,
    ["msgPosition"] = et.trap_Cvar_Get("u_landmines_limit_msg_position")
}

-- Function

-- Callback function when qagame runs a server frame.
--  vars is the local vars passed from et_RunFrame function.
function checkMaxMinesRunFrame(vars)
    if vars["levelTime"] - landminesLimit["time"] > 3 then
        local maxMines
        
        if players > 8 then
            maxMines = 15
        elseif players > 6 then
            maxMines = 10
        elseif players > 4 then
            maxMines = 8
        else
            maxMines = 5
        end

        if landminesLimit["maxMines"] ~= maxMines then
            et.trap_Cvar_Set("team_maxmines", maxMines)
            sayClients(landminesLimit["msgPosition"], string.format("Max. %d mines allowed.", maxMines))
            landminesLimit["maxMines"] = maxMines
        end

        landminesLimit["time"] = vars["levelTime"] -- Next checking in 3 seconds.
    end
end

-- Add callback landmines limit function.
addCallbackFunction({
    ["RunFrame"] = "checkMaxMinesRunFrame"
})
