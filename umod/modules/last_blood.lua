-- Last blood

-- Global var

lastBlood = {
    ["killerName"] = "",
    ["message"]    = et.trap_Cvar_Get("u_lb_message")
}

-- Function

-- Callback function when a player kill a enemy.
--  vars is the local vars of et_Obituary function.
function setLastKillerName(vars)
    lastBlood["killerName"] = vars["killerName"]
end

-- Callback function when qagame runs a server frame. (pending end round)
--  vars is the local vars passed from et_RunFrame function.
function checkLastBloodRunFrameEndRound(vars)
    if not game["endRoundTrigger"] and lastBlood["killerName"] ~= "" then
        local str = string.gsub(lastBlood["message"], "#killer#", lastBlood["killerName"])
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay " .. str .. "\n")
    end
end

-- Add callback last blood function.
addCallbackFunction({
    ["ObituaryEnemyKill"] = "setLastKillerName",
    ["RunFrameEndRound"]  = "checkLastBloodRunFrameEndRound"
})
