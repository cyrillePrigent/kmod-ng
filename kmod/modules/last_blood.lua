-- Last blood

-- Global var

lastBlood = {
    ["message"]   = et.trap_Cvar_Get("k_lb_message"),
    ["location"]  = getMessageLocation(tonumber(et.trap_Cvar_Get("k_lb_location")))
}

-- Function

-- Callback function when qagame runs a server frame. (pending end round)
--  vars is the local vars passed from et_RunFrame function.
function checkLastBloodRunFrameEndRound(vars)
    if not game["endRoundTrigger"] and obituary["lastKillerName"] then
        local str = string.gsub(lastBlood["message"], "#killer#", obituary["lastKillerName"])
        et.trap_SendConsoleCommand(et.EXEC_APPEND, lastBlood["location"] .. " " .. str .. "\n")
    end
end

-- Add callback last blood function.
addCallbackFunction({
    ["RunFrameEndRound"] = "checkLastBloodRunFrameEndRound"
})
