-- Advanced private message
-- From kmod script.

-- Global var

-- Override private messages slash command.
addSlashCommand("client", "m", {"file", "/command/client/private_message.lua"})
addSlashCommand("client", "pm", {"file", "/command/client/private_message.lua"})
addSlashCommand("client", "msg", {"file", "/command/client/private_message.lua"})

addSlashCommand("console", "m2", {"file", "/command/console/private_message.lua"})

-- TODO : /mt is missing !

-- Function

-- Called when qagame initializes.
-- Disable original private message for advanced private message.
--  vars is the local vars of et_InitGame function.
function advancedPmInitGame(vars)
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "b_privatemessages 0\n")
end

-- Add callback advanced private message function.
addCallbackFunction({
    ["InitGame"] = "advancedPmInitGame"
})
