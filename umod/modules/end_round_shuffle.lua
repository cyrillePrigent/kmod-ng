-- End round shuffle
-- From kmod script.

-- Function

-- Callback function when qagame runs a server frame. (pending end round)
-- At end of round, shuffle the teams.
--  vars is the local vars passed from et_RunFrame function.
function checkEndRoundShuffleRunFrameEndRound(vars)
    if not game["endRoundTrigger"] then
        et.trap_SendConsoleCommand(
            et.EXEC_APPEND,
            "ref shuffleteamsxp_norestart\n"
        )

        removeCallbackFunction("RunFrameEndRound", "checkEndRoundShuffleRunFrameEndRound")
    end
end

-- Add callback end round shuffle function.
addCallbackFunction({
    ["RunFrameEndRound"] = "checkEndRoundShuffleRunFrameEndRound"
})
