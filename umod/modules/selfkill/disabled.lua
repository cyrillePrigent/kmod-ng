-- Disabled selfkill

-- From nokill script.
-- Version 1.1
-- (c) 2005 infty -- guidebot@gmx.net

-- Override kill slash command.
addSlashCommand("client", "kill", {"function", "selfkillDisabledSlashCommand"})

-- Function

-- Function executed when slash command is called in et_ClientCommand function.
-- Disable selfkill when kill slash command is used.
--  params is parameters passed to the function executed in command file.
function selfkillDisabledSlashCommand(params)
    if client[params.clientNum]["team"] ~= 3 and et.gentity_get(params.clientNum, "health") > 0 then
        et.trap_SendServerCommand(
            params.clientNum,
            "cp \"^1Sorry, selfkilling is disabled on this server.\""
        )
    end

    return 1
end
