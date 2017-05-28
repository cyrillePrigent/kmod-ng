-- Disabled vote

-- Global var

voteDisabled = {
    ["active"]   = false,
    ["mode"]     = tonumber(et.trap_Cvar_Get("k_dvmode")),
    ["modeTime"] = tonumber(et.trap_Cvar_Get("k_dvtime"))
}

slashCommand["callvote"]["shuffleteamsxp"]           = { "function", "disableVoteSlashCommand" }
slashCommand["callvote"]["shuffleteamsxp_norestart"] = { "function", "disableVoteSlashCommand" }
slashCommand["callvote"]["nextmap"]                  = { "function", "disableVoteSlashCommand" }
slashCommand["callvote"]["swapteams"]                = { "function", "disableVoteSlashCommand" }
slashCommand["callvote"]["matchreset"]               = { "function", "disableVoteSlashCommand" }
slashCommand["callvote"]["maprestart"]               = { "function", "disableVoteSlashCommand" }
slashCommand["callvote"]["map"]                      = { "function", "disableVoteSlashCommand" }



-- Function

-- Function executed when slash command is called in et_ClientCommand function.
--  params is parameters passed to the function executed in command file.
function disableVoteSlashCommand(params)
    if getAdminLevel(params.clientNum) < 3 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "cancelvote ; qsay Voting has been disabled!\n")
        return 1
    end

    return 0
end

-- Callback function when qagame runs a server frame.
--  vars is the local vars passed from et_RunFrame function.
function disableVoteRunFrame(vars)
    if voteDisabled["mode"] == 1 then
        local cancelTime = (tonumber(et.trap_Cvar_Get("timelimit")) - voteDisabled["modeTime"]) * 60
    elseif voteDisabled["mode"] == 3 then
        local cancelTime = voteDisabled["modeTime"] * 60
    else
        local cancelTime = (tonumber(et.trap_Cvar_Get("timelimit")) * (voteDisabled["modeTime"] / 100)) * 60
    end

    if time["counter"] >= cancelTime then
        if not voteDisabled["active"] then
            voteDisabled["active"] = true
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay XP-Shuffle / Map Restart / Swap Teams  / Match Reset and New Campaign votings are now DISABLED\n")
        end
    else
        if voteDisabled["active"] then
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay XP-Shuffle / Map Restart / Swap Teams  / Match Reset and New Campaign votings have been reenabled due to timelimit change\n")
        end

        voteDisabled["active"] = false
    end
end

-- Add callback disabled vote function.
addCallbackFunction({
    ["RunFrame"] = "disableVoteRunFrame"
})
