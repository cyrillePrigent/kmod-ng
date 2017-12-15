-- Advanced private message
-- From kmod lua script.

-- Global var

addSlashCommand("client", "m", {"file", "/command/client/private_message.lua"})
addSlashCommand("client", "pm", {"file", "/command/client/private_message.lua"})
addSlashCommand("client", "msg", {"file", "/command/client/private_message.lua"})

addSlashCommand("console", "m2", {"file", "/command/console/private_message.lua"})

-- Function

-- Called when qagame initializes.
--  vars is the local vars of et_InitGame function.
function advancedPmInitGame(vars)
    if advancedPm == 1 then
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "b_privatemessages 0\n")
    else
        et.trap_SendConsoleCommand(et.EXEC_APPEND, "b_privatemessages 2\n")
    end
end

-- Add callback Advanced private message function.
addCallbackFunction({
    ["InitGame"] = "advancedPmInitGame"
})
