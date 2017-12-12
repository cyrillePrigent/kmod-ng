-- Admin management.
-- From kmod lua script.

-- Global var

admin = {
    -- Admin list
    --  key   => admin guid
    --  value => admin name
    ["name"] = {},
    -- Admin levels
    --  key   => admin level (0 to maxAdminLevel cvar value)
    --  value => table with : key = guid and value = true / false
    ["level"] = {},
    -- Client cvar name used to set password (with setu)
    ["pwdCvar"] = et.trap_Cvar_Get("u_password_client_cvar"),
    -- Admin password
    ["pwd"] = et.trap_Cvar_Get("u_admin_password")
}

addSlashCommand("client", "admins", {"file", "/command/client/admins.lua"})

-- Function

-- Initializes admin data.
-- Load admin entry of admin.cfg file.
function loadAdmins()
    local funcStart = et.trap_Milliseconds()

    for i = 0, maxAdminLevel, 1 do
        admin["level"][i] = {}
    end

    if admin["pwd"] == "my_admin_password" then
        et.G_LogPrint(
            "uMod ERROR: <u_admin_password> cvar is the default value!\nPlease edit your config file!\n"
        )
        return
    end

    if admin["pwdCvar"] == "my_server_password" then
        et.G_LogPrint(
            "uMod ERROR: <u_password_client_cvar> cvar is the default value!\nPlease edit your config file!\n"
        )
        return
    end

    local fd, len = et.trap_FS_FOpenFile("admins.cfg", et.FS_READ)

    if len == -1 then
        et.G_LogPrint("uMod WARNING: admins.cfg file no found / not readable!\n")
    elseif len == 0 then
        et.G_Print("uMod: No admins's defined\n")
    else
        local fileStr = et.trap_FS_Read(fd, len)

        for level, guid, name
          in string.gfind(fileStr, "(%d+)%s%-%s(%x+)%s%-%s*([^%\r%\n]*)") do
            level = tonumber(level)

            if level <= maxAdminLevel then
                for i = 1, level, 1 do
                    admin["level"][i][guid] = true
                end
            end

            admin["name"][guid] = name
        end
    end

    et.trap_FS_FCloseFile(fd)
    et.G_LogPrintf("uMod: Loading admins in %d ms\n", et.trap_Milliseconds() - funcStart)
end

-- Remove admin if exist and return result.
--  guid is the client guid.
function removeAdminIfExist(guid)
    if admin["name"][guid] ~= nil then
        removeAdmin(guid)
        return true
    end

    return false
end

-- Set a admin.
--  params is parameters passed to the function executed in command file.
--  name is the admin name cleaned.
--  guid is the admin guid.
--  level is the admin level.
function setAdmin(name, guid, level)
    removeAdminIfExist(guid)

    if level <= maxAdminLevel then
        for i = 0, level, 1 do
            admin["level"][i][guid] = true
        end

        admin["name"][guid] = name

        local fd, len = et.trap_FS_FOpenFile("admins.cfg", et.FS_APPEND)

        if len == -1 then
            et.G_LogPrint("uMod WARNING: admins.cfg file no found / not readable!\n")
        else
            local adminsLine = level .. " - " .. guid .. " - " .. name .. "\n"
            et.trap_FS_Write(adminsLine, string.len(adminsLine), fd)
        end

        et.trap_FS_FCloseFile(fd)
    end
end

-- Remove a admin.
--  guid is the client guid.
function removeAdmin(guid)
    local fdIn, lenIn   = et.trap_FS_FOpenFile("admins.cfg", et.FS_READ)
    local fdOut, lenOut = et.trap_FS_FOpenFile("admins.tmp.cfg", et.FS_WRITE)

    if lenIn == -1 then
        et.G_LogPrint("uMod WARNING: admins.cfg file no found / not readable!\n")
    elseif lenOut == -1 then
        et.G_LogPrint("uMod WARNING: admins.tmp.cfg file no found / not readable!\n")
    elseif lenIn == 0 then
        et.G_Print("uMod : There is no admin to remove\n")
    else
        local fileStr = et.trap_FS_Read(fdIn, lenIn)

        for lvl, _guid, name
          in string.gfind(fileStr, "(%d+)%s%-%s(%x+)%s%-%s*([^%\n]*)") do
            if _guid == guid then
                for i = 0, maxAdminLevel, 1 do
                    admin["level"][i][guid] = false
                end

                admin["name"][guid] = nil
            else
                local adminsLine = lvl .. " - " .. _guid .. " - " .. name .. "\n"
                et.trap_FS_Write(adminsLine, string.len(adminsLine), fdOut)
            end
        end
    end

    et.trap_FS_FCloseFile(fdIn)
    et.trap_FS_FCloseFile(fdOut)
    et.trap_FS_Rename("admins.tmp.cfg", "admins.cfg")
end

-- Return admin level of client.
--  clientNum is the client slot id.
function getAdminLevel(clientNum)
    local guid = client[clientNum]["guid"]

    for i = maxAdminLevel, 1, -1 do
        if admin["level"][i][guid] then
            if admin["pwd"] == et.Info_ValueForKey(et.trap_GetUserinfo(clientNum), admin["pwdCvar"]) then
                return i
            else
                break
            end
        end
    end

    return 0
end

-- Add callback admin function.
addCallbackFunction({
    ["ReadConfig"] = "loadAdmins"
})
