-- Mutes
-- From kmod script.

-- Global var

mute = {
    -- Mute duration list.
    --  key   => ip address
    --  value => duration in seconds, -1 for permanent mute
    ["duration"] = {},
    -- Time (in ms) of last mute check.
    ["time"] = 0,
    -- Interval (in ms) between 2 frame check.
    ["frameCheck"] = 1000 -- 1sec
}

-- Set default client data.
--
-- Mute end (in ms)
clientDefaultData["muteEnd"] = 0

-- Set module command.
cmdList["client"]["!pmute"] = "/command/client/pmute.lua"

periodicFrameCallback["checkMutePlayerRunFrame"] = "mute"

-- Function

-- Callback function when ReadConfig is called in et_InitGame function
-- and in the !readconfig client command.
-- Initializes mutes data.
-- Load mutes entry of mutes.cfg file.
function loadMutes()
    local funcStart = et.trap_Milliseconds()
    local fd, len   = et.trap_FS_FOpenFile("mutes.cfg", et.FS_READ)

    if len == -1 then
        et.G_LogPrint("uMod WARNING: mutes.cfg file no found / not readable!\n")
    elseif len == 0 then
        et.G_Print("uMod: No mutes defined\n")
    else
        local fileStr = et.trap_FS_Read(fd, len)

        for time, ip in string.gfind(fileStr, "(%-*%d+)%s%-%s(%d+%.%d+%.%d+%.%d+)%s%-%s*") do
            mute["duration"][ip] = tonumber(time)
        end
    end

    et.trap_FS_FCloseFile(fd)
    et.G_LogPrintf("uMod: Loading mutes in %d ms\n", et.trap_Milliseconds() - funcStart)
end

-- Add / edit a mute entry.
--  clientNum is the client slot id.
--  muteTime is the mute duration in seconds, -1 is permanently mute.
function setMute(clientNum, muteTime)
    local ip = getClientIp(clientNum)

    -- If mute entry exist, edit mute file...
    if mute["duration"][ip] ~= nil then
        local fdIn, lenIn = et.trap_FS_FOpenFile("mutes.cfg", et.FS_READ)
        local fdOut, lenOut = et.trap_FS_FOpenFile("mutes.tmp.cfg", et.FS_WRITE)

        if lenIn == -1 then
            et.G_LogPrint("WARNING: mutes.cfg file no found / not readable!\n")
        elseif lenOut == -1 then
            et.G_LogPrint("WARNING: mutes.tmp.cfg file no found / not readable!\n")
        elseif lenIn == 0 then
            et.G_Print("There is no Mutes to edit \n")
        else
            local fileStr = et.trap_FS_Read(fdIn, lenIn)

            for _time, _ip, _name in string.gfind(fileStr, "(%-*%d+)%s%-%s(%d+%.%d+%.%d+%.%d+)%s%-%s*([^%\n]*)") do
                if _ip ~= ip then
                    local muteLine = _time .. " - " .. _ip .. " - " .. _name .. "\n"
                    et.trap_FS_Write(muteLine, string.len(muteLine), fdOut)
                else
                    local time = math.ceil(muteTime)
                    local name = et.Q_CleanStr(et.Info_ValueForKey(et.trap_GetUserinfo(clientNum), "name"))
                    local muteLine = time .. " - " .. ip .. " - " .. name .. "\n"
                    et.trap_FS_Write(muteLine, string.len(muteLine), fdOut)
                end
            end
        end

        et.trap_FS_FCloseFile(fdIn)
        et.trap_FS_FCloseFile(fdOut)
        et.trap_FS_Rename("mutes.tmp.cfg", "mutes.cfg")

    -- ...Or append it to mute file.
    else
        local fd, len = et.trap_FS_FOpenFile("mutes.cfg", et.FS_APPEND)

        if len == -1 then
            et.G_LogPrint("ERROR: mutes.cfg file not writable!\n")
        else
            local time = math.ceil(muteTime)
            local name = et.Q_CleanStr(et.Info_ValueForKey(et.trap_GetUserinfo(clientNum), "name"))
            local muteLine = time .. " - " .. ip .. " - " .. name .. "\n"
            et.trap_FS_Write(muteLine, string.len(muteLine), fd)
        end

        et.trap_FS_FCloseFile(fd)
    end

    mute["duration"][ip] = muteTime
end

-- Remove a mute.
--  clientNum is the client slot id.
function removeMute(clientNum)
    local fdIn, lenIn = et.trap_FS_FOpenFile("mutes.cfg", et.FS_READ)
    local fdOut, lenOut = et.trap_FS_FOpenFile("mutes.tmp.cfg", et.FS_WRITE)
    local ip = getClientIp(clientNum)

    if lenIn == -1 then
        et.G_LogPrint("WARNING: mutes.cfg file no found / not readable!\n")
    elseif lenOut == -1 then
        et.G_LogPrint("WARNING: mutes.tmp.cfg file no found / not readable!\n")
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
    mute["duration"][ip] = nil
end

-- Check client mute.
--  clientNum is the client slot id.
function checkClientMute(clientNum)
    -- If player has not yet finished his mute sentance,
    -- edit it in mutes file.
    if client[clientNum]["muteEnd"] > 0 then
        setMute(clientNum, (client[clientNum]["muteEnd"] - time["frame"]) / 1000)

    -- Or if player has finished his mute sentance,
    -- remove it from mutes file.
    elseif client[clientNum]["muteEnd"] == 0 then
        local ip = getClientIp(clientNum)

        if mute["duration"][ip] ~= nil then
            removeMute(clientNum)
        end
    end
end

-- Callback function when qagame shuts down.
-- Check client mute before next map or server restart.
--  vars is the local vars passed from et_ShutdownGame function.
function checkMuteShutdownGame(vars)
    for p = 0, clientsLimit, 1 do
        if et.gentity_get(0, "inuse") then
            checkClientMute(p)
        end
    end
end

-- Callback function when qagame runs a server frame in player loop
-- pending warmup, round and end of round.
-- Check muted player if he will be unmuted.
--  clientNum is the client slot id.
--  vars is the local vars passed from et_RunFrame function.
function checkMuteRunPlayerFrame(clientNum, vars)
    -- If client is muted for a certain duration...
    if client[clientNum]["muteEnd"] > 0 then
        -- If client has finished his mute sentance...
        if time["frame"] > client[clientNum]["muteEnd"] then
            if et.gentity_get(clientNum, "sess.muted") == 1 then
                et.trap_SendConsoleCommand(
                    et.EXEC_APPEND,
                    "ref unmute \"" .. clientNum .. "\"\n"
                )

                et.trap_SendConsoleCommand(
                    et.EXEC_APPEND,
                    "qsay " .. color2 .. "Mute: " .. color1 .. client[clientNum]["name"] ..
                    color1 .. " has been auto unmuted.  Please watch your language!\n"
                )
            end

            client[clientNum]["muteEnd"] = 0
            removeMute(clientNum)

        -- If client has not yet finished his mute sentance...
        elseif time["frame"] < client[clientNum]["muteEnd"] then
            if et.gentity_get(clientNum, "sess.muted") == 0 then
                client[clientNum]["muteEnd"] = 0
                removeMute(clientNum)

                et.trap_SendConsoleCommand(
                    et.EXEC_APPEND,
                    "qsay " .. color2 .. "Mute: " .. color1 .. client[clientNum]["name"] ..
                    color1 .. " has been unmuted.\n"
                )
            end

        -- If client is unmuted...
        elseif et.gentity_get(clientNum, "sess.muted") == 0 then
            client[clientNum]["muteEnd"] = 0
            removeMute(clientNum)

            et.trap_SendConsoleCommand(
                et.EXEC_APPEND,
                "qsay " .. color2 .. "Mute: " .. color1 .. client[clientNum]["name"] ..
                color1 .. " has been unmuted.\n"
            )
        end
    -- If client is muted permanently...
    elseif client[clientNum]["muteEnd"] == -1 then
        if et.gentity_get(clientNum, "sess.muted") == 0 then
            client[clientNum]["muteEnd"] = 0
            removeMute(clientNum)

            et.trap_SendConsoleCommand(
                et.EXEC_APPEND,
                "qsay " .. color2 .. "Mute: " .. color1 .. client[clientNum]["name"] ..
                color1 .. " has been unmuted.\n"
            )
        end
    end
end

-- Callback function when client begin.
-- Check if client is muted and display his mute status.
--  vars is the local vars passed from et_ClientBegin function.
function checkMuteClientBegin(vars)
    local ip = getClientIp(vars["clientNum"])

    -- If client isn't referee and his ip address is muted, check it...
    if mute["duration"][ip] ~= nil
      and tonumber(et.gentity_get(vars["clientNum"], "sess.referee")) == 0 then
          -- If client is muted for a certain duration...
          if mute["duration"][ip] > 0 then
            client[vars["clientNum"]]["muteEnd"] = time["frame"] + (mute["duration"][ip] * 1000)

            et.trap_SendConsoleCommand(
                et.EXEC_APPEND,
                "qsay " .. color2 .. "Mute: " .. color1 .. client[vars["clientNum"]]["lastName"] ..
                color1 .. " has not yet finished his mute sentance.  (" ..
                second2readeableTime(mute["duration"][ip]) .. ")\n"
            )

            et.trap_SendConsoleCommand(
                et.EXEC_APPEND,
                "ref mute " .. vars["clientNum"] .. "\n"
            )

        -- If client is muted permanently...
        elseif mute["duration"][ip] == -1 then
            client[vars["clientNum"]]["muteEnd"] = -1

            et.trap_SendConsoleCommand(
                et.EXEC_APPEND,
                "qsay " .. color2 .. "Mute: " .. color1 .. client[vars["clientNum"]]["lastName"] ..
                color1 .. " has been permanently muted\n"
            )

            et.trap_SendConsoleCommand(
                et.EXEC_APPEND,
                "ref mute " .. vars["clientNum"] .. "\n"
            )
        end
    end
end

-- Callback function when client disconnect.
-- Check client mute before client disconnect.
--  vars is the local vars passed from et_ClientDisconnect function.
function checkMuteClientDisconnect(vars)
    checkClientMute(vars["clientNum"])
end

-- Add callback mute function.
addCallbackFunction({
    ["InitGame"]                   = "loadMutes",
    ["ShutdownGame"]               = "checkMuteShutdownGame",
    ["RunFramePlayerLoop"]         = "checkMuteRunPlayerFrame",
    ["RunFramePlayerLoopEndRound"] = "checkMuteRunPlayerFrame",
    ["ClientDisconnect"]           = "checkMuteClientDisconnect",
    ["ClientBegin"]                = "checkMuteClientBegin"
})
