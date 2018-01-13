-- Display all admins name and level in server console.
-- From kmod script.
-- Require : admins module
--  params is parameters passed from et_ConsoleCommand function.
function execute_command(params)
    local fd, len = et.trap_FS_FOpenFile("admins.cfg", et.FS_READ)

    if len == -1 then
        et.G_LogPrint("uMod WARNING: admins.cfg file no found / not readable!\n")
    elseif len == 0 then
        et.G_Print("uMod : No admins's defined\n")
    else
        local fileStr = et.trap_FS_Read(fd, len)

        for level, name in string.gfind(fileStr, "(%d)%s%-%s%x+%s%-%s*([^%\n]*)") do
            et.G_Print("Name  = " .. name .. "\nLevel = " .. level .. "\n\n")
        end
    end

    et.trap_FS_FCloseFile(fd)

    return 1
end
