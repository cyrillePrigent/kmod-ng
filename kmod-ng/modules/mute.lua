-- Mutes

-- Global var

--[[
   Mute table :
     duration :
       key   => ip address
       value => duration in seconds, -1 for permanent mute

   Client data :
     client["muteEnd"] :
       key   => client ID
       value => mute end (in miliseconds)
     client["multipliers"] :
       key   => client ID
       value => mute duration multipliers
--]]
mute = {
    ["duration"] = {}
}

-- Set default client data.
clientDefaultData["muteEnd"]     = 0
clientDefaultData["multipliers"] = 0

-- Function

-- Initializes mutes data.
-- Load mutes entry of mutes.cfg file.
function loadMutes()
    local fd, len = et.trap_FS_FOpenFile(kmod_ng_path .. "mutes.cfg", et.FS_READ)

    if len == -1 then
        et.G_LogPrint("ERROR: mutes.cfg file not readable!\n")
    elseif len == 0 then
        et.G_Print("WARNING: No Mutes Defined!\n")
    else
        local fileStr = et.trap_FS_Read(fd, len)

        for time, ip in string.gfind(fileStr, "(%-*%d+)%s%-%s(%d+%.%d+%.%d+%.%d+)%s%-%s*") do
            mute["duration"][ip] = tonumber(time)
        end
    end

    et.trap_FS_FCloseFile(fd)
end

-- Open mutes.cfg file and append mute entry.
--  clientNum is the client slot id.
--  muteTime is the mute duration in seconds, -1 is permanently mute.
function writeMute(clientNum, muteTime)
    local fd, len = et.trap_FS_FOpenFile(kmod_ng_path .. "mutes.cfg", et.FS_APPEND)

    if len == -1 then
        et.G_LogPrint("ERROR: mutes.cfg file not writable!\n")
    else
        if client[clientNum]["muteEnd"] ~= 0 then
            local time = math.ceil(muteTime)
            local name = et.Q_CleanStr(et.Info_ValueForKey(et.trap_GetUserinfo(clientNum), "name"))
            local muteLine = time .. " - " .. ip .. " - " .. name .. "\n"
            et.trap_FS_Write(muteLine, string.len(muteLine), fd)
        end
    end

    et.trap_FS_FCloseFile(fd)
end

-- Set a mute.
--  clientNum is the client slot id.
--  muteTime is the mute duration in seconds, -1 is permanently mute.
function setMute(clientNum, muteTime)
    local edit = false
    local fd, len = et.trap_FS_FOpenFile(kmod_ng_path .. "mutes.cfg", et.FS_APPEND)
    local ip = string.upper(et.Info_ValueForKey(et.trap_GetUserinfo(clientNum), "ip"))
    local _, _, ip = string.find(ip, "(%d+%.%d+%.%d+%.%d+)")

    et.trap_FS_FCloseFile(fd)

    if len == -1 then
        et.G_LogPrint("ERROR: mutes.cfg file not writable!\n")
    elseif len == 0 then
        edit = true
    else
        if mute["duration"][ip] ~= nil then
            removeMute(clientNum)
            edit = true
        end

        if client[clientNum]["muteEnd"] > 0 or client[clientNum]["muteEnd"] == -1 then
            edit = true
        end
    end

    if edit then
        writeMute(clientNum, muteTime)
        loadMutes()
    end
end

-- Remove a mute.
--  clientNum is the client slot id.
function removeMute(clientNum)
    local fdIn, lenIn = et.trap_FS_FOpenFile(kmod_ng_path .. "mutes.cfg", et.FS_READ)
    local fdOut, lenOut = et.trap_FS_FOpenFile(kmod_ng_path .. "mutes.tmp.cfg", et.FS_WRITE)
    local ip = string.upper(et.Info_ValueForKey(et.trap_GetUserinfo(clientNum), "ip"))
    local _, _, ip = string.find(ip, "(%d+%.%d+%.%d+%.%d+)")

    if lenIn == -1 then
        et.G_LogPrint("ERROR: mutes.cfg file not readable!\n")
    elseif lenOut == -1 then
        et.G_LogPrint("ERROR: mutes.tmp.cfg file not writable!\n")
    elseif lenIn == 0 then
        et.G_Print("There is no Mutes to remove \n")
    else
        local fileStr = et.trap_FS_Read(fdIn, lenIn)

        for time, _ip, name in string.gfind(fileStr, "(%-*%d+)%s%-%s(%d+%.%d+%.%d+%.%d+)%s%-%s*([^%\n]*)") do
            if _ip ~= ip then
                local muteLine = time .. " - " .. _ip .. " - " .. name .. "\n"
                et.trap_FS_Write(muteLine, string.len(muteLine), fdOut)
            end
        end
    end

    et.trap_FS_FCloseFile(fdIn)
    et.trap_FS_FCloseFile(fdOut)
    et.trap_FS_Rename("mutes.tmp.cfg", "mutes.cfg")
    loadMutes()
end

-- Callback function when qagame shuts down.
function checkMuteShutdownGame()
    for i = 0, clientsLimit, 1 do
        if et.gentity_get(i, "pers.connected") == 2 then
            if client[i]["muteEnd"] > 0 then
                setMute(i, (client[i]["muteEnd"] - time["frame"]) / 1000)
            elseif client[i]["muteEnd"] == 0 then
                local ip = et.Info_ValueForKey(et.trap_GetUserinfo(i), "ip")
                local _, _, ip = string.find(ip, "(%d+%.%d+%.%d+%.%d+)")

                if mute["duration"][ip] ~= 0 then
                    setMute(i, 0)
                end
            end
        end
    end
end

-- Callback function when qagame runs a server frame.
--  vars is the local vars passed from et_RunFrame function.
function checkMuteRunFrame(vars)
    for i = 0, clientsLimit, 1 do
        local muted = et.gentity_get(i, "sess.muted")

        if client[i]["muteEnd"] ~= nil then
            if client[i]["muteEnd"] > 0 then
                if time["frame"] > client[i]["muteEnd"] then
                    if muted == 1 then
                        et.trap_SendConsoleCommand(et.EXEC_APPEND, "ref unmute \"" .. i .. "\"\n")
                        et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay ^3CurseFilter: ^7" .. client[i]["name"] .." ^7has been auto unmuted.  Please watch your language!\n")
                    end

                    client[i]["muteEnd"] = 0
                elseif time["frame"] < client[i]["muteEnd"] then
                    if muted == 0 then
                        client[i]["muteEnd"] = 0
                        setMute(i, 0)
                    end
                elseif muted == 0 then
                    client[i]["muteEnd"] = 0
                end
            elseif client[i]["muteEnd"] == -1 then
                if muted == 0 then
                    client[i]["muteEnd"] = 0
                end
            end
        end
    end
end

-- Callback function when client begin.
--  vars is the local vars passed from et_ClientBegin function.
function checkMuteClientBegin(vars)
    local ip = et.Info_ValueForKey(et.trap_GetUserinfo(vars["clientNum"]), "ip")
    local _, _, ip = string.find(ip, "(%d+%.%d+%.%d+%.%d+)")

    local fd, len = et.trap_FS_FOpenFile(kmod_ng_path .. "mutes.cfg", et.FS_READ)

    client[vars["clientNum"]]["muteEnd"] = 0

    -- TODO : Really need here?
    loadMutes()

    if len == -1 then
        et.G_LogPrint("ERROR: mutes.cfg file not readable!\n")
    elseif len > 0 then
        local ref = tonumber(et.gentity_get(vars["clientNum"], "sess.referee"))
        local fileStr = et.trap_FS_Read(fd, len)

        for time in string.gfind(fileStr, "(%-*%d+)%s%-%s%d+%.%d+%.%d+%.%d+%s%-%s*") do
            if mute["duration"][ip] ~= nil and ref == 0 then
                if mute["duration"][ip] > 0 then
                    client[vars["clientNum"]]["muteEnd"] = time["frame"] + (mute["duration"][ip] * 1000)
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay ^3Curse Filter:  ^7" .. client[clientNum][vars["clientNum"]]["lastName"] .. "^7 has not yet finished his mute sentance.  (^1" .. mute["duration"][ip] .. "^7) seconds.\n")
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, "ref mute " .. vars["clientNum"] .. "\n")
                elseif mute["duration"][ip] == -1 then
                    client[vars["clientNum"]]["muteEnd"] = -1
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay ^3Curse Filter:  ^7" .. client[vars["clientNum"]]["lastName"] .. "^7 has been permanently muted\n")
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, "ref mute " .. vars["clientNum"] .. "\n")
                end
            end
        end
    end

    et.trap_FS_FCloseFile(fd)
end

-- Callback function when client disconnect.
--  vars is the local vars passed from et_ClientDisconnect function.
function checkMuteClientDisconnect(vars)
    if client[vars["clientNum"]]["muteEnd"] > 0 then
        setMute(vars["clientNum"], (client[vars["clientNum"]]["muteEnd"] - time["frame"]) / 1000)
        client[vars["clientNum"]]["muteEnd"] = 0
    elseif client[vars["clientNum"]]["muteEnd"] == 0 then
        setMute(vars["clientNum"], 0)
        client[vars["clientNum"]]["muteEnd"] = 0
    end
end

-- Add callback mute function.
addCallbackFunction({
    ["InitGame"]         = "loadMutes",
    ["ShutdownGame"]     = "checkMuteShutdownGame",
    ["RunFrame"]         = "checkMuteRunFrame",
    ["ClientDisconnect"] = "checkMuteClientDisconnect",
    ["ClientBegin"]      = "checkMuteClientBegin"
})
