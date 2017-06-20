-- Admins

-- Global var

--[[
   Admin table :
     name :
       key   => admin guid
       value => admin name
     level :
       key   => admin level (0 to maxAdminLevel cvar value)
       value => table with : key = guid and value = true / false
--]]
admin = {
    ["name"]  = {},
    ["level"] = {}
}

-- Function

-- Initializes admin data.
-- Load admin entry of admin.cfg file.
function loadAdmins()
    for i = 0, maxAdminLevel, 1 do
        admin["level"][i] = {}
    end

    local fd, len = et.trap_FS_FOpenFile("shrubbot.cfg", et.FS_READ)

    if len == -1 then
        et.G_LogPrint("WARNING: shrubbot.cfg file no found / not readable!\n")
    elseif len == 0 then
        et.G_Print("WARNING: No Admins's Defined!\n")
    else
        local fileStr = et.trap_FS_Read(fd, len)

        for level, guid, name in string.gfind(fileStr, "(%d+)%s%-%s(%x+)%s%-%s*([^%\r%\n]*)") do
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
end

-- Remove admin if exist and return result.
--  clientNum is the client slot id.
--  guid is the client guid.
function removeAdminIfExist(clientNum, guid)
    if admin["name"][guid] ~= nil then
        removeAdmin(clientNum)
        return true
    end

    return false
end

-- Set a regular user (level 0).
--  params is parameters passed to the function executed in command file.
--  clientNum is the client slot id.
function setRegularUser(params, clientNum)
    local userInfo = et.trap_GetUserinfo(clientNum)
    local name     = et.Q_CleanStr(et.Info_ValueForKey(userInfo, "name"))
    local guid     = et.Info_ValueForKey(userInfo, "cl_guid")

    if removeAdminIfExist(clientNum, guid) then
        printCmdMsg(params, name .. " is now a regular user!\n")
    else
        printCmdMsg(params, name .. " is already a regular user!\n")
    end
end

-- Open shrubbot.cfg file and append admin entry.
--  level is the admin level.
--  guid is the admin guid
--  name is the admin name.
function writeAdmin(level, guid, name)
    local shrubbotLine = level .. " - " .. guid .. " - " .. name .. "\n"
    local fd, len = et.trap_FS_FOpenFile("shrubbot.cfg", et.FS_APPEND)

    if len == -1 then
        et.G_LogPrint("WARNING: shrubbot.cfg file no found / not readable!\n")
    else
        et.trap_FS_Write(shrubbotLine, string.len(shrubbotLine), fd)
    end

    et.trap_FS_FCloseFile(fd)
end

-- Set a admin.
--  params is parameters passed to the function executed in command file.
--  clientNum is the client slot id.
--  level is the admin level.
function setAdmin(params, clientNum, level)
    local userInfo = et.trap_GetUserinfo(clientNum)
    local name     = et.Q_CleanStr(et.Info_ValueForKey(userInfo, "name"))
    local guid     = et.Info_ValueForKey(userInfo, "cl_guid")
    --local ip = et.Info_ValueForKey(userinfo, "ip")

    removeAdminIfExist(clientNum, guid)

    if level <= maxAdminLevel then
        for i = 0, level, 1 do
            admin["level"][i][guid] = true
        end

        admin["name"][guid] = name

        writeAdmin(level, guid, name)
    end

    printCmdMsg(params, name .. " is now a level ^1" .. level .. " ^7user!\n")
end

-- Remove a admin.
--  clientNum is the client slot id.
function removeAdmin(clientNum)
    local fdIn, lenIn = et.trap_FS_FOpenFile("shrubbot.cfg", et.FS_READ)
    local fdOut, lenOut = et.trap_FS_FOpenFile("shrubbot.tmp.cfg", et.FS_WRITE)
    local guid = et.Info_ValueForKey(et.trap_GetUserinfo(clientNum), "cl_guid")

    if lenIn == -1 then
        et.G_LogPrint("WARNING: shrubbot.cfg file no found / not readable!\n")
    elseif lenOut == -1 then
        et.G_LogPrint("WARNING: shrubbot.tmp.cfg file no found / not readable!\n")
    elseif lenIn == 0 then
        et.G_Print("There is no Power User IP to remove \n")
    else
        local fileStr = et.trap_FS_Read(fdIn, lenIn)

        for lvl, _guid, name in string.gfind(fileStr, "(%d+)%s%-%s(%x+)%s%-%s*([^%\n]*)") do
            if _guid == guid then
                for i = 0, maxAdminLevel, 1 do
                    admin["level"][i][guid] = false
                end

                admin["name"][guid] = nil
            else
                local shrubbotLine = lvl .. " - " .. _guid .. " - " .. name .. "\n"
                et.trap_FS_Write(shrubbotLine, string.len(shrubbotLine), fdOut)
            end
        end
    end

    et.trap_FS_FCloseFile(fdIn)
    et.trap_FS_FCloseFile(fdOut)
    et.trap_FS_Rename("shrubbot.tmp.cfg", "shrubbot.cfg")
end

-- Test admin level and return result.
-- Used for finger & admintest command.
--  params is parameters passed to the function executed in command file.
function adminStatus(params)
    local userInfo = et.trap_GetUserinfo(params.clientNum)
    local guid     = et.Info_ValueForKey(userInfo, "cl_guid")
    local name     = et.gentity_get(params.clientNum, "pers.netname")
    local cmd      = params.bangCmd or params.cmd

    for i = maxAdminLevel, 0, -1 do
        if params.bangCmd == k_commandprefix .. "finger" then
            if admin["level"][i][guid] and i ~= 0 then
                et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Finger: ^7" .. name .. " ^7is an admin \[lvl " .. i .. "\]\n")
                break
            elseif i == 0 then
                et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Finger: ^7" .. name .. " ^7is a guest \[lvl 0\]\n")
                break
            end
        elseif params.bangCmd == k_commandprefix .. "admintest" then
            if admin["level"][i][guid] and i ~= 0 then
                et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Admintest: ^7You are an admin \[lvl " .. i .. "\]\n")
                break
            elseif i == 0 then
                et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3Admintest: ^7You are a guest \[lvl 0\]\n")
                break
            end
        end
    end
end

-- Return admin level of client.
--  clientNum is the client slot id.
function getAdminLevel(clientNum)
    if clientNum ~= -1 then
        local guid = et.Info_ValueForKey(et.trap_GetUserinfo(clientNum), "cl_guid")

        for i = maxAdminLevel, 1, -1 do
            if admin["level"][i][guid] then
                return i
            end
        end
    end

    return 0
end

-- Add callback admin function.
addCallbackFunction({
    ["ReadConfig"] = "loadAdmins"
})
