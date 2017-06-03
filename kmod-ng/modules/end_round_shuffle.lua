-- End round shuffle

-- Function

-- Callback function when qagame runs a server frame. (pending end round)
--  vars is the local vars passed from et_RunFrame function.
function checkEndRoundShuffleRunFrameEndRound(vars)
    if not game["endRoundTrigger"] then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "ref shuffleteamsxp_norestart\n")
    end
end

-- Add callback end round shuffle function.
addCallbackFunction({
    ["RunFrameEndRound"] = "checkEndRoundShuffleRunFrameEndRound"
})
