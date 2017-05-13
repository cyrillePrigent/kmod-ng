

function execute_command(params)
    local fd, len = et.trap_FS_FOpenFile(kmod_ng_path .. "shrubbot.cfg", et.FS_READ)

    if len <= 0 then
        et.G_Print("WARNING: No Admins's Defined! \n")
    else
        local filestr = et.trap_FS_Read(fd, len)

        -- TODO Remove guid
        for level, guid, name in string.gfind(filestr, "(%d)%s%-%s(%x+)%s%-%s*([^%\n]*)") do
            -- upcase for exact matches
            --GUID = string.upper(guid)
            et.G_Print("Name  = " .. name .. "\nLevel = " .. level .. "\n\n")
        end
    end

    et.trap_FS_FCloseFile(fd)

    return 1
end
