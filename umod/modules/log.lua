-- Log

addSlashCommand("client", "mt", {"function", "teamPrivateMessageSlashCommand"})
--addSlashCommand("console", "mt", {"function", "teamPrivateMessageSlashCommand"})

-- Function

function teamPrivateMessageSlashCommand(params)
    -- TODO
    --[[
    local time       = os.date("%x %I:%M:%S%p")
    local clientInfo = et.trap_GetUserinfo(clientNum)
    local ip         = string.upper(et.Info_ValueForKey(clientInfo, "ip"))
    local from       = "SERVER"

    if clientNum ~= 1022 then
        from = client[clientNum]["name"]
    end

    if not recipiant then
        local targetNum = client2id(target)

        if targetNum then
            local recipiant = client[targetNum]["name"]
        end
    end

    if recipiant then
        writeLog("(" .. time .. ") (IP: " .. ip .. " GUID: " .. client[clientNum]["guid"] .. ") " .. from .. " to " .. recipiant .. " (PRIVATE): " .. msg .. "\n")
    end
    --]]
end

-- Write a text in log file.
--  text is the text to write in log file.
function writeLog(text)
    local fd, len = et.trap_FS_FOpenFile("chat_log.log", et.FS_APPEND)
    et.trap_FS_Write(text, string.len(text) ,fd)
    et.trap_FS_FCloseFile(fd)
end

-- Log message in log file.
--  clientNum is the client slot id.
--  msg is the content of chat message.
--  msgType is the type of log message.
function logMessage(clientNum, msg, msgType)
    local time       = os.date("%x %I:%M:%S%p")
    local clientInfo = et.trap_GetUserinfo(clientNum)
    local ip         = string.upper(et.Info_ValueForKey(clientInfo, "ip"))
    local guid       = string.upper(client[clientNum]["guid"] )
    local name       = et.Q_CleanStr(client[clientNum]["name"])
    local logInfo    = "(" .. time .. ") (IP: " .. ip .. " GUID: " .. guid .. ") " .. name

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
function logChat(clientNum, mode, msg, pmId)
    local msgType = "NONE"

    if mode == et.SAY_ALL then
        msgType = "ALL"
    elseif mode == et.SAY_TEAM then
        msgType = "TEAM"
    elseif mode == et.SAY_BUDDY then
        msgType = "BUDDY"
    elseif mode == et.SAY_TEAMNL then
        msgType = "TEAM"
    elseif mode == "VSAY_TEAM" then
        msgType = "VSAY_TEAM"
    elseif mode == "VSAY_BUDDY" then
        msgType = "VSAY_BUDDY"
    elseif mode == "VSAY_ALL" then
        msgType = "VSAY"
    end

    if msgType ~= "NONE" then
        local msg        = et.Q_CleanStr(msg)
        local time       = os.date("%x %I:%M:%S%p")
        local clientInfo = et.trap_GetUserinfo(clientNum)
        local ip         = string.upper(et.Info_ValueForKey(clientInfo, "ip"))
        local guid       = string.upper(client[clientNum]["guid"] )
        local name       = et.Q_CleanStr(client[clientNum]["name"])
        local logInfo    = "(" .. time .. ") (IP: " .. ip .. " GUID: " .. guid .. ") " .. name

        if msgType == "ALL" then
            writeLog(logInfo .. ": " .. msg .. "\n")
        else
            writeLog(logInfo .. " (" .. msgType .. "): " .. msg .. "\n")
        end
    end
end


function logPrivateMessage(clientNum, msg, target, recipiant)
    local time       = os.date("%x %I:%M:%S%p")
    local clientInfo = et.trap_GetUserinfo(clientNum)
    local ip         = string.upper(et.Info_ValueForKey(clientInfo, "ip"))
    local guid       = string.upper(client[clientNum]["guid"] )
    local from       = "SERVER"

    if clientNum ~= 1022 then
        from = client[clientNum]["name"]
    end

    if not recipiant then
        local targetNum = client2id(target)

        if targetNum then
            recipiant = client[targetNum]["name"]
        end
    end

    if recipiant then
        writeLog("(" .. time .. ") (IP: " .. ip .. " GUID: " .. guid .. ") " .. from .. " to " .. recipiant .. " (PRIVATE): " .. msg .. "\n")
    end
end


function logAdminsPrivateMessage(clientNum, msg)
    local time = os.date("%x %I:%M:%S%p")
    local ip
    local guid
    local from

    if clientNum ~= 1022 then
        local clientInfo = et.trap_GetUserinfo(clientNum)
        ip   = string.upper(et.Info_ValueForKey(clientInfo, "ip"))
        guid = string.upper(client[clientNum]["guid"] )
        from = client[clientNum]["name"]
    else
        ip   = "127.0.0.1"
        guid = "NONE!"
        from = "SERVER"
    end

    writeLog("(" .. time .. ") (IP: " .. ip .. " GUID: " .. guid .. ") " .. from .. " to ADMINS (PRIVATE): " .. msg .. "\n")
end

-- Callback function when client begin.
--  vars is the local vars passed from et_ClientBegin function.
function logClientBegin(vars)
    local clientInfo = et.trap_GetUserinfo(vars["clientNum"])
    local ip   = string.upper(et.Info_ValueForKey(clientInfo, "ip"))
    local guid = string.upper(client[vars["clientNum"]]["guid"] )
    local name = et.Q_CleanStr(client[vars["clientNum"]]["name"])
    writeLog("*** " .. name .. " HAS ENTERED THE GAME  (IP: " .. ip .. " GUID: " .. guid .. ") ***\n")
end

-- Callback function when client disconnect.
--  vars is the local vars passed from et_ClientDisconnect function.
function logClientDisconnect(vars)
    local name = et.Q_CleanStr(client[vars["clientNum"]]["name"])
    writeLog("*** " .. name .. " HAS DISCONNECTED ***\n")
end

-- Callback function when qagame shuts down.
function logShutdownGame(vars)
    writeLog("\n***SERVER RESTART OR MAP CHANGE***\n\n")
end

-- Add callback mute function.
addCallbackFunction({
    ["ClientBegin"]      = "logClientBegin",
    ["ClientDisconnect"] = "logClientDisconnect",
    ["ShutdownGame"]     = "logShutdownGame"
})
