-- Disabled vote

-- Global var

voteDisabled = {
    ["active"]   = false,
    ["mode"]     = tonumber(et.trap_Cvar_Get("k_dvmode")),
    ["modeTime"] = tonumber(et.trap_Cvar_Get("k_dvtime"))
}

addSlashCommand("client", {"callvote", "shuffleteamsxp"}, {"function", "disableVoteSlashCommand"})
addSlashCommand("client", {"callvote", "shuffleteamsxp_norestart"}, {"function", "disableVoteSlashCommand"})
addSlashCommand("client", {"callvote", "nextmap"}, {"function", "disableVoteSlashCommand"})
addSlashCommand("client", {"callvote", "swapteams"}, {"function", "disableVoteSlashCommand"})
addSlashCommand("client", {"callvote", "matchreset"}, {"function", "disableVoteSlashCommand"})
addSlashCommand("client", {"callvote", "maprestart"}, {"function", "disableVoteSlashCommand"})
addSlashCommand("client", {"callvote", "map"}, {"function", "disableVoteSlashCommand"})

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
    local cancelTime

    if voteDisabled["mode"] == 1 then
        cancelTime = (tonumber(et.trap_Cvar_Get("timelimit")) - voteDisabled["modeTime"]) * 60
    elseif voteDisabled["mode"] == 3 then
        cancelTime = voteDisabled["modeTime"] * 60
    else
        cancelTime = (tonumber(et.trap_Cvar_Get("timelimit")) * (voteDisabled["modeTime"] / 100)) * 60
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
