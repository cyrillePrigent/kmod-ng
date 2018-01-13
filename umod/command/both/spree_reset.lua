-- Reset spree record.
-- From kmod script.
-- Require : killing spree module
--  params is parameters passed from et_ClientCommand / et_ConsoleCommand function.
function execute_command(params)
    params.say = "chat"
    
    local fd, _ = et.trap_FS_FOpenFile("sprees/spree_record.dat", et.FS_WRITE)
    et.trap_FS_Write("", 0, fd)
    et.trap_FS_FCloseFile(fd)

    spree = {
        ["killsRecord"] = 0,
        ["msg"]         = {
            ["oldShort"] = color2 .. "[Old: " .. color1 .. "N/A" .. color2 .. "]",
            ["oldLong"]  = color2 .. "Spree Record: " .. color1 .. "There is no current spree record",
            ["current"]  = "Current spree record: " .. color1 .. "N/A"
        }
    }

    printCmdMsg(params, "Spree record has been reset!\n")

    return 1
end
