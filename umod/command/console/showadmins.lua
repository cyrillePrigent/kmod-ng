-- Display all admins name and level in server console.
--  params is parameters passed from et_ConsoleCommand function.
function execute_command(params)
    local fd, len = et.trap_FS_FOpenFile("shrubbot.cfg", et.FS_READ)

    if len == -1 then
        et.G_LogPrint("WARNING: shrubbot.cfg file no found / not readable!\n")
    elseif len == 0 then
        et.G_Print("WARNING: No Admins's Defined!\n")
    else
        local filestr = et.trap_FS_Read(fd, len)

        for level, name in string.gfind(filestr, "(%d)%s%-%s%x+%s%-%s*([^%\n]*)") do
            et.G_Print("Name  = " .. name .. "\nLevel = " .. level .. "\n\n")
        end
    end

    et.trap_FS_FCloseFile(fd)

    return 1
end
