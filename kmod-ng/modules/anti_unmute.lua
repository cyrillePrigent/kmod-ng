-- Anti unmute

-- Global var

addSlashCommand("client", {"callvote", "unmute"}, {"function", "antiUnmuteSlashCommand"})

-- Function

-- Function executed when slash command is called in et_ClientCommand function.
--  params is parameters passed to the function executed in command file.
function antiUnmuteSlashCommand(params)
    if et.gentity_get(client2id(et.trap_Argv(2)), "sess.muted") == 1 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "cancelvote ; qsay Cannot vote to unmute a muted person!\n")
        return 1
    end

    return 0
end
