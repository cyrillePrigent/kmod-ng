-- Reset spree record.
-- Require : killing spree module
--  params is parameters passed from et_ClientCommand / et_ConsoleCommand function.
function execute_command(params)
    params.say = msgCmd["chatArea"]
    
    local fd, _ = et.trap_FS_FOpenFile("sprees/spree_record.dat", et.FS_WRITE)
    et.trap_FS_Write("", 0, fd)
    et.trap_FS_FCloseFile(fd)

    spree = {
        ["killsRecord"] = 0,
        ["msg"]         = {
            ["oldShort"] = "^3[Old: ^7N/A^3]",
            ["oldLong"]  = "^3Spree Record: ^7There is no current spree record",
            ["current"]  = "Current spree record: ^7N/A"
        }
    }

    printCmdMsg(params, "Spree record has been reset!\n")

    return 1
end
