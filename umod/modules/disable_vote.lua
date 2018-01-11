-- Disabled vote
-- From kmod script.

-- NOTE : We can't disable RESTART MAP button in vote menu ! :<

-- TODO : Check if custom vote menu is possible.

-- Global var

voteDisabled = {
    -- Vote disabled status.
    ["active"] = false,
    -- Vote disabled mode.
    ["mode"] = tonumber(et.trap_Cvar_Get("u_dv_mode")),
    -- Vote disabled mode time. (see config file)
    ["modeTime"] = tonumber(et.trap_Cvar_Get("u_dv_time")),
    -- Server cvar backup.
    ["cvarBackup"] = {
        ["vote_allow_shuffleteamsxp"] = 0,
        ["vote_allow_nextmap"]        = 0,
        ["vote_allow_swapteams"]      = 0,
        ["vote_allow_matchreset"]     = 0,
        ["vote_allow_map"]            = 0
    },
    -- Time (in ms) of last vote disabled check.
    ["time"] = 0,
    -- Interval (in ms) between 2 frame check.
    ["frameCheck"] = 250
}


-- Function

-- Disable vote (slash command & user menu)
function disableVote()
    addSlashCommand("client", {"callvote", "shuffleteamsxp"}, {"function", "disableVoteSlashCommand"})
    addSlashCommand("client", {"callvote", "shuffleteamsxp_norestart"}, {"function", "disableVoteSlashCommand"})
    addSlashCommand("client", {"callvote", "nextmap"}, {"function", "disableVoteSlashCommand"})
    addSlashCommand("client", {"callvote", "swapteams"}, {"function", "disableVoteSlashCommand"})
    addSlashCommand("client", {"callvote", "matchreset"}, {"function", "disableVoteSlashCommand"})
    addSlashCommand("client", {"callvote", "maprestart"}, {"function", "disableVoteSlashCommand"})
    addSlashCommand("client", {"callvote", "map"}, {"function", "disableVoteSlashCommand"})

    local fd, len = et.trap_FS_FOpenFile(
        "disable_vote_settings.cfg", et.FS_WRITE
    )

    if len == -1 then
        et.G_LogPrint(
            "uMod WARNING: disable_vote_settings.cfg file no found / not readable!\n"
        )
    else
        for cvar, _ in pairs(voteDisabled["cvarBackup"]) do
            local backupLine = cvar .. " \""
                .. tonumber(et.trap_Cvar_Get(cvar)) .. "\"\n"

            et.trap_FS_Write(backupLine, string.len(backupLine), fd)

            et.trap_SendConsoleCommand(et.EXEC_APPEND, cvar .. " \"0\"\n")
        end
    end

    et.trap_FS_FCloseFile(fd)
end

-- Enable vote (slash command & user menu)
function enableVote()
    removeSlashCommand("client", {"callvote", "shuffleteamsxp"}, "disableVoteSlashCommand")
    removeSlashCommand("client", {"callvote", "shuffleteamsxp_norestart"}, "disableVoteSlashCommand")
    removeSlashCommand("client", {"callvote", "nextmap"}, "disableVoteSlashCommand")
    removeSlashCommand("client", {"callvote", "swapteams"}, "disableVoteSlashCommand")
    removeSlashCommand("client", {"callvote", "matchreset"}, "disableVoteSlashCommand")
    removeSlashCommand("client", {"callvote", "maprestart"}, "disableVoteSlashCommand")
    removeSlashCommand("client", {"callvote", "map"}, "disableVoteSlashCommand")

    et.trap_SendConsoleCommand(
        et.EXEC_APPEND,
        "exec disable_vote_settings.cfg\n"
    )
end

-- Function executed when slash command is called in et_ClientCommand function.
-- Disable vote when callvote slash command is used.
--  params is parameters passed to the function executed in command file.
function disableVoteSlashCommand(params)
    if getAdminLevel(params.clientNum) < 3 then
        et.trap_SendConsoleCommand(
            et.EXEC_APPEND,
            "cancelvote ; qsay " .. color1 .. "Voting has been disabled!\n"
        )

        return 1
    end

    return 0
end

-- Called when qagame initializes.
-- Restore vote settings.
--  vars is the local vars of et_InitGame function.
function disableVoteInitGame(vars)
    et.trap_SendConsoleCommand(
        et.EXEC_APPEND,
        "exec disable_vote_settings.cfg\n"
    )
end

-- Callback function when qagame runs a server frame.
-- Check round time and disable votes after a specified length of time.
--  vars is the local vars passed from et_RunFrame function.
function disableVoteRunFrame(vars)
    if vars["levelTime"] - voteDisabled["time"] >= voteDisabled["frameCheck"] then
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
                et.trap_SendConsoleCommand(
                    et.EXEC_APPEND,
                    "qsay XP-Shuffle / Map Restart / Swap Teams / Match Reset and New Campaign votings are now DISABLED\n"
                )
            end
        else
            if voteDisabled["active"] then
                enableVote()
                et.trap_SendConsoleCommand(
                    et.EXEC_APPEND,
                    "qsay XP-Shuffle / Map Restart / Swap Teams / Match Reset and New Campaign votings have been reenabled due to timelimit change\n"
                )
            end

            voteDisabled["active"] = false
        end

        voteDisabled["time"] = vars["levelTime"]
    end
end

-- Add callback disabled vote function.
addCallbackFunction({
    ["InitGame"] = "disableVoteInitGame",
    ["RunFrame"] = "disableVoteRunFrame"
})
