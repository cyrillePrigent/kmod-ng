-- Log

-- Function

-- Write a text in log file.
--  text is the text to write in log file.
function writeLog(text)
    local fd, len = et.trap_FS_FOpenFile(kmod_ng_path .. "chat_log.log", et.FS_APPEND)
    et.trap_FS_Write(text, string.len(text) ,fd)
    et.trap_FS_FCloseFile(fd)
end

-- Log message in log file.
--  time is the current time and date of message.
--  clientNum is the client slot id.
--  msg is the content of chat message.
--  msgType is the type of log message.
function logMessage(time, clientNum, msg, msgType)
    local clientInfo = et.trap_GetUserinfo(clientNum)
    local ip = string.upper(et.Info_ValueForKey(clientInfo, "ip"))
    local guid = string.upper(et.Info_ValueForKey(clientInfo, "cl_guid"))
    local name = et.Q_CleanStr(et.gentity_get(clientNum, "pers.netname"))
    local logInfo = "(" .. time .. ") (IP: " .. ip .. " GUID: " .. guid .. ") " .. name

    if msgType then
        return logInfo .. " (" .. msgType .. "): " .. msg .. "\n"
    else
        return logInfo .. ": " .. msg .. "\n"
    end
end

-- Log chat message in log file.
--  clientNum is the client slot id.
--  mode is the type of chat message. (TEAM, BUDDY, VSAY_TEAM, VSAY_BUDDY OR VSAY)
--  msg is the content of chat message.
--  pmId is the slot id / partial or complete name of recipiant player.
-- TODO : Export private message intp separate function.
function logChat(clientNum, mode, msg, pmId)
    local msg = et.Q_CleanStr(msg)
    local fdadm, len = et.trap_FS_FOpenFile(kmod_ng_path .. "chat_log.log", et.FS_APPEND)
    local time = os.date("%x %I:%M:%S%p")
    local ip
    local guid
    local logLine

    if mode == et.SAY_ALL then
        logLine = logMessage(time, clientNum, msg)
    elseif mode == et.SAY_TEAM then
        logLine = logMessage(time, clientNum, msg, "TEAM")
    elseif mode == et.SAY_BUDDY then
        logLine = logMessage(time, clientNum, msg, "BUDDY")
    elseif mode == et.SAY_TEAMNL then
        logLine = logMessage(time, clientNum, msg, "TEAM")
    elseif mode == "VSAY_TEAM" then
        logLine = logMessage(time, clientNum, msg, "VSAY_TEAM")
    elseif mode == "VSAY_BUDDY" then
        logLine = logMessage(time, clientNum, msg, "VSAY_BUDDY")
    elseif mode == "VSAY_ALL" then
        logLine = logMessage(time, clientNum, msg, "VSAY")
    elseif mode == "PMESSAGE" then
        local clientInfo = et.trap_GetUserinfo(clientNum)
        ip = string.upper(et.Info_ValueForKey(clientInfo, "ip"))
        guid = string.upper(et.Info_ValueForKey(clientInfo, "cl_guid"))
        local from = "SERVER"

        if clientNum ~= 1022 then
            from = et.gentity_get(clientNum, "pers.netname")
        end

        local rec1 = client2id(pmId)

        if rec1 then
            local recipiant = et.gentity_get(rec1,"pers.netname")
            logLine = "(" .. time .. ") (IP: " .. ip .. " GUID: " .. guid .. ") " .. from .. " to " .. recipiant .. " (PRIVATE): " .. msg .. "\n"
        end
    elseif mode == "PMADMINS" then
        local from = "SERVER"

        if clientNum ~= 1022 then
            local clientInfo = et.trap_GetUserinfo(clientNum)
            ip = string.upper(et.Info_ValueForKey(clientInfo, "ip"))
            guid = string.upper(et.Info_ValueForKey(clientInfo, "cl_guid"))
            from = et.gentity_get(clientNum, "pers.netname")
        else
            ip = "127.0.0.1"
            guid = "NONE!"
        end

        local recipiant = "ADMINS"
        logLine = "(" .. time .. ") (IP: " .. ip .. " GUID: " .. guid .. ") " .. from .. " to " .. recipiant .. " (PRIVATE): " .. msg .. "\n"
    end

    writeLog(logLine)
end

-- Callback function when client begin.
--  vars is the local vars passed from et_ClientBegin function.
function logClientBegin(vars)
    local clientInfo = et.trap_GetUserinfo(vars["clientNum"])
    local ip   = string.upper(et.Info_ValueForKey(clientInfo, "ip"))
    local guid = string.upper(et.Info_ValueForKey(clientInfo, "cl_guid"))
    local name = et.Q_CleanStr(et.gentity_get(vars["clientNum"], "pers.netname"))
    writeLog("*** " .. name .. " HAS ENTERED THE GAME  (IP: " .. ip .. " GUID: " .. guid .. ") ***\n")
end

-- Callback function when client disconnect.
--  vars is the local vars passed from et_ClientDisconnect function.
function logClientDisconnect(vars)
    local name = et.Q_CleanStr(et.gentity_get(vars["clientNum"], "pers.netname"))
    writeLog("*** " .. name .. " HAS DISCONNECTED ***\n")
end

-- Callback function when qagame shuts down.
function logShutdownGame(vars)
    writeLog("\n    ***SERVER RESTART OR MAP CHANGE***\n\n")
end

-- Add callback mute function.
addCallbackFunction({
    ["ClientBegin"]      = "logClientBegin",
    ["ClientDisconnect"] = "logClientDisconnect",
    ["ShutdownGame"]     = "logShutdownGame"
})
