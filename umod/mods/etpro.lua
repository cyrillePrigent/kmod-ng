--[[

 ETpro fix

 * Prevent ws overrun exploit, crlf abuse
   TY McSteve

 * Limit fakeplayers DOS
    http://aluigi.altervista.org/fakep.htm
    Configuration:
     Set ip_max_clients cvar as desired. If not set, default value used is 3.
   TY Luigi Auriemma

 * Prevent etpro guid borkage
    Configuration:
     Set etproguidcheck_bantime cvar as desired. If not set, default value used is 0.
     Default to kick with no temp ban for now.
   TY pants

 * Prevent various borkage by invalid userinfo

 * Prevent team overrun exploit
   TY 

 Special thanks :
   - McSteve
--]]

-- http://www.crossfire.nu/journals/view/id/117075
-- http://www.crossfire.nu/threads/39602/bugs-in-et

-- Global var

etpro = {
    ["ipMaxPerClients"] = 3,
    ["banTime"]         = 0
}

userinfoCheck = {
    ["lastTime"]  = 0,
    ["clientNum"] = 0,
    ["frequency"] = 5000
}

-- Names that can be used to exploit some log parsers 
--  NOTE : Only console log parsers or print hooks should be affected, 
--  game log parsers don't see these at the start of a line
-- "^etpro IAC" check is required for guid checking
-- comment/uncomment others as desired, or add your own.
-- NOTE : these are patterns for string.find.
badNames = {
    -- '^ShutdownGame',
    -- '^ClientBegin',
    -- '^ClientDisconnect',
    -- '^ExitLevel',
    -- '^Timelimit',
    -- '^EndRound',
    '^etpro IAC',
    -- '^etpro privmsg',
-- "say" is relatively likely to have false positives
-- but can potentially be used to exploit things that use etadmin_mod style !commands
-- '^say',
    -- '^Callvote',
    -- '^broadcast',
    -- '^badinfo'
}

-- Set module command.
cmdList["client"]["!makeshoutcaster"]   = "/command/client/makeshoutcaster.lua"
cmdList["client"]["!removeshoutcaster"] = "/command/client/removeshoutcaster.lua"

addSlashCommand("client", "ws", {"function", "fixWsSlashCommand"})
addSlashCommand("client", "team", {"function", "fixTeamSlashCommand"}) -- TODO : Check nextteam command
addSlashCommand("client", "callvote", {"function", "fixCrlfAbuseSlashCommand"})
addSlashCommand("client", "ref", {"function", "fixCrlfAbuseSlashCommand"})
addSlashCommand("client", "sa", {"function", "fixCrlfAbuseSlashCommand"})
addSlashCommand("client", "semiadmin", {"function", "fixCrlfAbuseSlashCommand"})

-- Function

-- Called when qagame initializes.
-- Prepare death spree list.
--  vars is the local vars of et_InitGame function.
function etproFixInitGame(vars)
    local ipMaxPerClients = tonumber(et.trap_Cvar_Get("ip_max_clients"))

    if ipMaxPerClients ~= nil and ipMaxPerClients > 0 then
        etpro["ipMaxPerClients"] = ipMaxPerClients
    end

    local banTime = tonumber(et.trap_Cvar_Get("etproguidcheck_bantime"))

    if banTime ~= nil and banTime >= 0 then
        etpro["banTime"] = banTime
    end
end

-- Function executed when slash command is called in et_ClientCommand function.
-- Prevent ws overrun exploit.
--  params is parameters passed to the function executed in command file.
function fixWsSlashCommand(params)
    local n = tonumber(et.trap_Argv(1))

    if not n then
        et.G_LogPrintf(
            "uMod ws fix: client %d bad ws not a number [%s]\n",
            params.clientNum, tostring(et.trap_Argv(1))
        )

        return 1
    end

    if n < 0 or n > 21 then
        et.G_LogPrintf("uMod ws fix: client %d bad ws %d\n", params.clientNum, n)
        return 1
    end

    return 0
end

-- Function executed when slash command is called in et_ClientCommand function.
-- Prevent team overrun exploit.
--  params is parameters passed to the function executed in command file.
function fixTeamSlashCommand(params)
    local allowedArg = {
        -- spectator
        ["spectator"] = true,
        ["s"]         = true,
        -- axis
        ["red"]       = true,
        ["r"]         = true,
        ["axis"]      = true,
        -- allies
        ["blue"]      = true,
        ["b"]         = true,
        ["allies"]    = true
    }

    local teamArg = et.trap_Argv(1)

    if teamArg and not allowedArg[teamArg] then
        et.G_LogPrintf(
            "uMod team fix: client %d bad team argument [%s]\n",
            params.clientNum, tostring(et.trap_Argv(1))
        )

        return 1
    end

    return 0
end

-- Function executed when slash command is called in et_ClientCommand function.
-- Prevent crlf abuse.
--  params is parameters passed to the function executed in command file.
function fixCrlfAbuseSlashCommand(params)
    local args = et.ConcatArgs(1)

    if string.find(args, "[\r\n]") then
        et.G_LogPrintf(
            "uMod crlf abuse fix: client %d bad %s [%s]\n",
            params.clientNum, params.cmd, args
        )

        return 1
    end

    return 0
end

-- Callback function when a client connect.
--  * Check client userinfo (userinfocheck).
--  * Check client IP (fake player limit).
-- * Check duplicate guid
--  vars is the local vars passed from et_ClientConnect function.
function etProFixClientConnect(vars)
    local userinfo = et.trap_GetUserinfo(vars["clientNum"])

    -- userinfocheck stuff. Do this before IP limit.
    local reason = checkUserinfo(userinfo)

    if reason then
        et.G_LogPrintf(
            "uMod userinfocheck connect: client %d bad userinfo %s\n",
            vars["clientNum"], reason
        )

        return "bad userinfo"
    end

    -- NOTE : IP validity should be enforced by userinfocheck stuff.
    local ip    = getClientIp(et.Info_ValueForKey(userinfo, "ip"))
    local count = 1 -- We count as the first one

    -- It's probably safe to only do this on firsttime, but checking
    -- every time doesn't hurt much.

    -- Validate userinfo to filter out the people blindly using luigi's code.
--    if et.Info_ValueForKey(userinfo, "rate") == "15000" then
--      and string.find(client[vars["clientNum"]]["guid"], "%d+%.%d+%.%d+%.%d+") == nil then
    
    if et.Info_ValueForKey(userinfo, "rate") == "1500"
      and string.find(client[vars["clientNum"]]["guid"], "%d+%.%d+%.%d+%.%d+") == nil then
        et.G_Printf("uMod fake player limit: invalid userinfo from %s\n", ip)
        return "invalid connection"
    end

    local guid = string.upper(client[vars["clientNum"]]["guid"])

    for p = 0, clientsLimit do
        local playerGuid = string.upper(client[p]["guid"])

        if playerGuid == guid and playerGuid ~= "NO_GUID"
          and playerGuid ~= "UNKNOWN" and vars["clientNum"] ~= p then
            et.G_LogPrintf(
                "uMod userinfocheck infochanged: client %d bad userinfo duplicate guid\n",
                vars["clientNum"]
            )

            et.trap_SetUserinfo(vars["clientNum"], "name\\badinfo")
            return "bad userinfo : duplicate guid"
        end
        
        
        -- pers.connected is set correctly for fake players.
        -- Can't rely on userinfo being empty.
        if p ~= vars["clientNum"] and et.gentity_get(p, "pers.connected") > 0 then
            if ip == getClientIp(et.Info_ValueForKey(et.trap_GetUserinfo(p), "ip")) then
                count = count + 1

                if count > etpro["ipMaxPerClients"] then
                    et.G_Printf(
                        "uMod fake player limit: too many connections from %s\n",
                        ip
                    )

                    return string.format(
                        "only %d connections per IP are allowed on this server",
                        etpro["ipMaxPerClients"]
                    )
                end
            end
        end
    end
end

-- Log and drop client for bad guid.
--  clientNum is the client slot id.
--  reason is the descriptive string reason reported to clients.
function badEtproGuid(clientNum, reason)
    et.G_LogPrintf("uMod etproguidcheck: client %d bad etpro GUID %s\n", clientNum, reason)
    -- We don't send them the reason. They can figure it out for themselves.
    et.trap_DropClient(clientNum, "You are banned from this server", etpro["banTime"])
end

-- Callback function whenever the server or qagame prints a string to the console.
-- Check printed etpro guid line.
--  vars is the local vars of et_Print function.
function checkEtproGuidLinePrint(vars)
    local text = vars["text"]
    local etproGuid

    -- Find a GUID line and extract client slot ID.
    local mstart, mend, clientNum = string.find(text, "^etpro IAC: (%d+) GUID %[")

    if not mstart then
        return
    end

    -- Extract client etpro guid.
    --GUID] [NETNAME]\n
    text = string.sub(text, mend + 1)
    mstart, mend, etproGuid = string.find(text, "^([^%]]*)%] %[")

    if not mstart then
        badEtproGuid(clientNum, "couldn't parse etpro guid")
        return
    end

    -- Extract client name.
    --NETNAME]\n
    text = string.sub(text, mend + 1)
    mstart, mend = string.find(text, client[clientNum]["name"], 1, true)

    if not mstart or mstart ~= 1 then
        badEtproGuid(clientNum, "couldn't parse name")
        return
    end

    -- Check if rest of string is not malformed.
    text = string.sub(text, mend + 1)

    if text ~= "]\n" then
        badEtproGuid(clientNum, "trailing garbage")
        return
    end

    -- Check the etpro guid is 40 chars and hex.
    -- {N} is too complicated!
    mstart, _ = string.find(
        etproGuid,
        "^%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x$"
    )

    if not mstart then
        badEtproGuid(clientNum, "malformed")
        return
    end
end

-- function ParseString(inputString)
--     local i = 1
--     local t = {}
--     for w in string.gfind(inputString, "([^%s]+)%s*") do
--         t[i]=w
--         i=i+1
--     end
--     return t
-- end

-- function getCS()
--     local cs = et.trap_GetConfigstring(et.CS_VOTE_STRING)
--     local t = ParseString(cs)
--     return t[4]
-- end

--function et_Print(text)
    -- TODO It'a a ETpro fix or fix stupid user config?
    --local t = ParseString(text)  --Vote Passed: Change map to suppLY
    --if t[2] == "Passed:" and t[4] == "map" then
    --    if string.find(t[6],"%u") == nil or t[6] ~= getCS() then return 1 end
    --    local mapfixed = string.lower(t[6])
    --    et.trap_SendConsoleCommand( et.EXEC_APPEND, "ref map " .. mapfixed .. "\n" )
    --end
--end

-- Check userinfo string of client.
--  userinfo is the userinfo string of client to check.
function checkUserinfo(userinfo)
    -- Bad things can happen if it's full.
    if string.len(userinfo) > 980 then
        return "oversized"
    end

    -- Newlines can confuse various log parsers, and should never be there.
    -- NOTE : this DOES NOT protect your log parsers, as the userinfo may
    -- already have been sent to the log.
    if string.find(userinfo, "\n") then
        return "new line"
    end

    -- The game never seems to make userinfos without a leading backslash, 
    -- or with a trailing backslash, so reject those from the start.
    if string.sub(userinfo, 1, 1) ~= "\\" then
        return "missing leading slash"
    end

    -- Shouldn't really be possible, since the engine stuffs ip\ip:port on the end.
    if string.sub(userinfo, -1, 1) == "\\" then
        return "trailing slash"
    end

    -- Now that we know it is properly formed, count the slashes.
    local n = 0

    for _ in string.gfind(userinfo, "\\") do
        n = n + 1
    end

    if math.mod(n, 2) == 1 then
        return "unbalanced"
    end

    local t = {}

    -- Right number of slashes, check for dupe keys.
    for m in string.gfind(userinfo, "\\([^\\]*)\\") do
        if string.len(m) == 0 then
            return "empty key"
        end

        m = string.lower(m)

        if t[m] then
            return "duplicate key"
        end

        t[m] = true
    end

    -- They might hose the userinfo in some way that prevents the ip from being obtained.
    -- If so -> dump
    local ip = et.Info_ValueForKey(userinfo, "ip")

    if ip == "" then
        return "missing ip"
    end

    -- Make sure whatever is there is roughly valid while we are at it
    -- "localhost" may be present on a listen server.
    -- This module is not intended for listen servers.
    if string.find(ip, "^%d+%.%d+%.%d+%.%d+:%d+$") == nil then
        return "malformed ip"
    end

    -- Check for this to prevent exploitation of guidcheck
    -- NOTE : the proper solution would be for chats to always have a prefix in the console. 
    -- Why the fuck does the server console need both.
    -- say: [NW]reyalP: blah
    -- [NW]reyalP: blah
    local name = et.Info_ValueForKey(userinfo, "name")

    if name == "" then
        return "missing name"
    end

    for _, badnamepat in ipairs(badNames) do
        local mstart, _, _ = string.find(name, badnamepat)

        if mstart then
            return "name abuse"
        end
    end
end

-- Callback function when qagame runs a server frame (pending warmup, round and end of round).
-- Check periodically userinfo of a client.
--  vars is the local vars passed from et_RunFrame function.
function etProFixRunFrame(vars)
    if userinfoCheck["lastTime"] + userinfoCheck["frequency"] > vars["levelTime"] then
        return
    end

    userinfoCheck["lastTime"] = vars["levelTime"]

    if et.gentity_get(userinfoCheck["clientNum"], "inuse") then
        local userinfo = et.trap_GetUserinfo(userinfoCheck["clientNum"])
        local reason   = checkUserinfo(userinfo)

        if reason then
            et.G_LogPrintf(
                "uMod userinfocheck frame: client %d bad userinfo %s\n",
                userinfoCheck["clientNum"], reason
            )

            et.trap_SetUserinfo(userinfoCheck["clientNum"], "name\\badinfo")
            et.trap_DropClient(userinfoCheck["clientNum"], "bad userinfo", 0)
        end
    end

    if userinfoCheck["clientNum"] >= clientsLimit then
        userinfoCheck["clientNum"] = 0
    else
        userinfoCheck["clientNum"] = userinfoCheck["clientNum"] + 1
    end
end

-- Callback function when a client’s Userinfo string has changed.
-- When client’s Userinfo string has change, check it.
--  vars is the local vars of et_ClientUserinfoChanged function.
function etProFixClientUserinfoChanged(vars)
    local userinfo = et.trap_GetUserinfo(vars["clientNum"])
    local reason   = checkUserinfo(userinfo)

    if reason then
        et.G_LogPrintf(
            "userinfocheck infochanged: client %d bad userinfo %s\n",
            vars["clientNum"], reason
        )

        et.trap_SetUserinfo(vars["clientNum"], "name\\badinfo")
        et.trap_DropClient(vars["clientNum"], string.format("bad userinfo : %s", reason), 0)
    end
end

-- Add callback ETpro fix function.
addCallbackFunction({
    ["ClientConnect"]         = "etProFixClientConnect",
    ["ClientUserinfoChanged"] = "etProFixClientUserinfoChanged",
    ["RunFrame"]              = "etProFixRunFrame",
    ["RunFrameEndRound"]      = "etProFixRunFrame",
    ["Print"]                 = "checkEtproGuidLinePrint"
})
