-- Last blood
-- From kmod script.

-- Global var

lastBlood = {
    -- Last killer name of the round.
    ["killerName"] = "",
    -- Last blood message content.
    ["message"] = et.trap_Cvar_Get("u_lb_message")
}

-- Function

-- Callback function when a player kill a enemy.
-- Set last killer name.
--  vars is the local vars of et_Obituary function.
function setLastKillerName(vars)
    lastBlood["killerName"] = vars["killerName"]
end

-- Callback function when qagame runs a server frame. (pending end round)
-- At end of round, display last blood message.
--  vars is the local vars passed from et_RunFrame function.
function checkLastBloodRunFrameEndRound(vars)
    if not game["endRoundTrigger"] and lastBlood["killerName"] ~= "" then
        local msg = string.gsub(lastBlood["message"], "#killer#", lastBlood["killerName"])

        et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay " .. msg .. "\n")

        removeCallbackFunction("RunFrameEndRound", "checkLastBloodRunFrameEndRound")
    end
end

-- Add callback last blood function.
addCallbackFunction({
    ["ObituaryEnemyKill"] = "setLastKillerName",
    ["RunFrameEndRound"]  = "checkLastBloodRunFrameEndRound"
})
