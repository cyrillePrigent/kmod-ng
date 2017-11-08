-- Disabled vote

-- Global var

voteDisabled = {
    ["active"]   = false,
    ["mode"]     = tonumber(et.trap_Cvar_Get("u_dvmode")),
    ["modeTime"] = tonumber(et.trap_Cvar_Get("u_dvtime"))
}


-- Function

function disableVote()
    addSlashCommand("client", {"callvote", "shuffleteamsxp"}, {"function", "disableVoteSlashCommand"})
    addSlashCommand("client", {"callvote", "shuffleteamsxp_norestart"}, {"function", "disableVoteSlashCommand"})
    addSlashCommand("client", {"callvote", "nextmap"}, {"function", "disableVoteSlashCommand"})
    addSlashCommand("client", {"callvote", "swapteams"}, {"function", "disableVoteSlashCommand"})
    addSlashCommand("client", {"callvote", "matchreset"}, {"function", "disableVoteSlashCommand"})
    addSlashCommand("client", {"callvote", "maprestart"}, {"function", "disableVoteSlashCommand"})
    addSlashCommand("client", {"callvote", "map"}, {"function", "disableVoteSlashCommand"})
end

function enableVote()
    removeSlashCommand("client", {"callvote", "shuffleteamsxp"}, "disableVoteSlashCommand")
    removeSlashCommand("client", {"callvote", "shuffleteamsxp_norestart"}, "disableVoteSlashCommand")
    removeSlashCommand("client", {"callvote", "nextmap"}, "disableVoteSlashCommand")
    removeSlashCommand("client", {"callvote", "swapteams"}, "disableVoteSlashCommand")
    removeSlashCommand("client", {"callvote", "matchreset"}, "disableVoteSlashCommand")
    removeSlashCommand("client", {"callvote", "maprestart"}, "disableVoteSlashCommand")
    removeSlashCommand("client", {"callvote", "map"}, "disableVoteSlashCommand")
end

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
            disableVote()
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay XP-Shuffle / Map Restart / Swap Teams  / Match Reset and New Campaign votings are now DISABLED\n")
        end
    else
        if voteDisabled["active"] then
            enableVote()
            et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay XP-Shuffle / Map Restart / Swap Teams  / Match Reset and New Campaign votings have been reenabled due to timelimit change\n")
        end

        voteDisabled["active"] = false
    end
end

-- Add callback disabled vote function.
addCallbackFunction({
    ["RunFrame"] = "disableVoteRunFrame"
})
