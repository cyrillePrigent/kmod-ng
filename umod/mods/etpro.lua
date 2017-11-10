--[[

 ETpro fix

 * Prevent ws overrun exploit, crlf abuse
   TY McSteve

 * Limit fakeplayers DOS
    http://aluigi.altervista.org/fakep.htm
    Configuration:
     set ip_max_clients cvar as desired. If not set, defaults to the value DEF_IP_MAX_CLIENTS.
   TY Luigi Auriemma

 * Prevent etpro guid borkage
   TY pants

 * Prevent various borkage by invalid userinfo

 * Prevent team overrun exploit
   TY 

 Special thanks :
   - McSteve
--]]


-- Global var

DEF_IP_MAX_CLIENTS = 3

-- default to kick with no temp ban for now
DEF_GUIDCHECK_BANTIME = 0

userinfoCheck = {
    ["lastTime"]  = 0,
    ["clientNum"] = 0,
    ["frequency"] = 5000
}

-- names that can be used to exploit some log parsers 
--  note: only console log parsers or print hooks should be affected, 
--  game log parsers don't see these at the start of a line
-- "^etpro IAC" check is required for guid checking
-- comment/uncomment others as desired, or add your own
-- NOTE: these are patterns for string.find
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

addSlashCommand("client", "ws", {"function", "fixWsSlashCommand"})
addSlashCommand("client", "team", {"function", "fixTeamSlashCommand"}) 
addSlashCommand("client", "callvote", {"function", "fixCrlfAbuseSlashCommand"})
addSlashCommand("client", "ref", {"function", "fixCrlfAbuseSlashCommand"})
addSlashCommand("client", "sa", {"function", "fixCrlfAbuseSlashCommand"})
addSlashCommand("client", "semiadmin", {"function", "fixCrlfAbuseSlashCommand"})

ipMaxPerClients = tonumber(et.trap_Cvar_Get("ip_max_clients"))

if not ipMaxPerClients or ipMaxPerClients <= 0 then
    ipMaxPerClients = DEF_IP_MAX_CLIENTS
end

-- Function

-- Prevent ws overrun exploit.
-- Function executed when slash command is called in et_ClientCommand function.
--  params is parameters passed to the function executed in command file.
function fixWsSlashCommand(params)
    local n = tonumber(et.trap_Argv(1))

    if not n then
        et.G_LogPrintf("ws fix: client %d bad ws not a number [%s]\n", params.clientNum, tostring(et.trap_Argv(1)))
        return 1
    end

    if n < 0 or n > 21 then
        et.G_LogPrintf("ws fix: client %d bad ws %d\n", params.clientNum, n)
        return 1
    end

    return 0
end

-- Prevent team overrun exploit.
-- Function executed when slash command is called in et_ClientCommand function.
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
        et.G_LogPrintf("team fix: client %d bad team argument [%s]\n", params.clientNum, tostring(et.trap_Argv(1)))
        return 1
    end

    return 0
end

-- Prevent crlf abuse.
-- Function executed when slash command is called in et_ClientCommand function.
--  params is parameters passed to the function executed in command file.
function fixCrlfAbuseSlashCommand(params)
    local args = et.ConcatArgs(1)

    if string.find(args, "[\r\n]") then
        et.G_LogPrintf("crlf abuse fix: client %d bad %s [%s]\n", params.clientNum, params.cmd, args)
        return 1
    end

    return 0
end

---------------------------------------------------------------------------------------------------------

function getClientIp(userinfo)
    -- TODO listen servers may be 'localhost'
    if userinfo == "" then
        return ""
    end

    local ip = et.Info_ValueForKey(userinfo, "ip")

    -- find IP and strip port
    local ipstart, _, ipmatch = string.find(ip, "(%d+%.%d+%.%d+%.%d+)")

    -- don't error out if we don't match an ip
    if not ipstart then
        return ""
    end

    return ipmatch
end

function etProFixClientConnect(vars)
    local userinfo = et.trap_GetUserinfo(vars["clientNum"])

    -- userinfocheck stuff. Do this before IP limit
    local reason = checkUserinfo(userinfo)

    if reason then
        et.G_LogPrintf("userinfocheck connect: client %d bad userinfo %s\n", vars["clientNum"], reason)
        return "bad userinfo"
    end

    -- note IP validity should be enforced by userinfocheck stuff
    local ip    = getClientIp(userinfo)
    local count = 1 -- we count as the first one

    -- it's probably safe to only do this on firsttime, but checking
    -- every time doesn't hurt much

    -- validate userinfo to filter out the people blindly using luigi's code
--    if et.Info_ValueForKey(userinfo, "rate") == "15000" then
--    --and string.find(client[vars["clientNum"]]["guid"], "%d+%.%d+%.%d+%.%d+") == nil then
    
    if et.Info_ValueForKey(userinfo, "rate") == "1500" and string.find(client[vars["clientNum"]]["guid"], "%d+%.%d+%.%d+%.%d+") == nil then
        et.G_Printf("fake player limit: invalid userinfo from %s\n", ip)
        return "invalid connection"
    end

    for i = 0, clientsLimit do
        -- pers.connected is set correctly for fake players
        -- can't rely on userinfo being empty
        if i ~= vars["clientNum"] and et.gentity_get(i, "pers.connected") > 0 then
            local _userinfo = et.trap_GetUserinfo(i)

            if ip == getClientIp(_userinfo) then
                count = count + 1

                if count > ipMaxPerClients then
                    et.G_Printf("fake player limit: too many connections from %s\n", ip)
                    return string.format("only %d connections per IP are allowed on this server", ipMaxPerClients)
                end
            end
        end
    end
end

---------------------------------------------------------------------------------------------------------

function badGuid(clientNum, reason)
    local bantime = tonumber(et.trap_Cvar_Get("guidcheck_bantime"))

    if not bantime or bantime < 0 then
        bantime = DEF_GUIDCHECK_BANTIME
    end

    et.G_LogPrintf("guidcheck: client %d bad GUID %s\n", clientNum, reason)
    -- we don't send them the reason. They can figure it out for themselves.
    et.trap_DropClient(clientNum, "You are banned from this server", bantime)
end

function checkGuidLinePrint(vars)
    local text = vars["text"]
    -- find a GUID line
    local guid, netname
    local mstart, mend, clientNum = string.find(text, "^etpro IAC: (%d+) GUID %[")

    if not mstart then
        return
    end

    text = string.sub(text, mend + 1)

    --GUID] [NETNAME]\n
    mstart, mend, guid = string.find(text, "^([^%]]*)%] %[")

    if not mstart then
        badGuid(clientNum, "couldn't parse guid")
        return
    end

    --NETNAME]\n
    text = string.sub(text, mend + 1)
    mstart, mend = string.find(text, client[clientNum]["name"], 1, true)

    if not mstart or mstart ~= 1 then
        badGuid(clientNum, "couldn't parse name")
        return
    end

    text = string.sub(text, mend + 1)

    if text ~= "]\n" then
        badGuid(clientNum, "trailing garbage")
        return
    end

    -- {N} is too complicated!
    mstart, _ = string.find(guid, "^%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x$")

    if not mstart then
        badGuid(clientNum, "malformed")
        return
    end
end

function et_Print(text)
    -- TODO It'a a ETpro fix or fix stupid user config?
    --local t = ParseString(text)  --Vote Passed: Change map to suppLY
    --if t[2] == "Passed:" and t[4] == "map" then
    --    if string.find(t[6],"%u") == nil or t[6] ~= getCS() then return 1 end
    --    local mapfixed = string.lower(t[6])
    --    et.trap_SendConsoleCommand( et.EXEC_APPEND, "ref map " .. mapfixed .. "\n" )
    --end
end

---------------------------------------------------------------------------------------------------------

function checkUserinfo(userinfo)
    -- bad things can happen if it's full
    if string.len(userinfo) > 980 then
        return "oversized"
    end

    -- newlines can confuse various log parsers, and should never be there
    -- note this DOES NOT protect your log parsers, as the userinfo may
    -- already have been sent to the log
    if string.find(userinfo, "\n") then
        return "new line"
    end

    -- the game never seems to make userinfos without a leading backslash, 
    -- or with a trailing backslash, so reject those from the start
    if string.sub(userinfo, 1, 1) ~= "\\" then
        return "missing leading slash"
    end

    -- shouldn't really be possible, since the engine stuffs ip\ip:port on the end
    if string.sub(userinfo, -1, 1) == "\\" then
        return "trailing slash"
    end

    -- now that we know it is properly formed, count the slashes
    local n = 0

    for _ in string.gfind(userinfo, "\\") do
        n = n + 1
    end

    if math.mod(n, 2) == 1 then
        return "unbalanced"
    end

    local m
    local t = {}

    -- right number of slashes, check for dupe keys
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

    -- they might hose the userinfo in some way that prevents the ip from being
    -- obtained. If so -> dump
    local ip = et.Info_ValueForKey(userinfo, "ip")

    if ip == "" then
        return "missing ip"
    end

    -- make sure whatever is there is roughly valid while we are at it
    -- "localhost" may be present on a listen server. This module is not intended for listen servers.
    -- string.match 5.1.x
    -- string.find 5.0.x
    if string.find(ip, "^%d+%.%d+%.%d+%.%d+:%d+$") == nil then
        return "malformed ip"
    end

    -- check for this to prevent exploitation of guidcheck
    -- note the proper solution would be for chats to always have a prefix in the console. 
    -- Why the fuck does the server console need both
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

function etProFixRunFrame(vars)
    if userinfoCheck["lastTime"] + userinfoCheck["frequency"] > vars["levelTime"] then
        return
    end

    userinfoCheck["lastTime"] = vars["levelTime"]

-- TODO : Check if needed
-- globalconbined.lua start
--    if et.gentity_get(userinfoCheck["clientNum"], "pers.connected") ~= 0  then
--        if et.gentity_get(userinfoCheck["clientNum"], "ps.ping") ~= 0 then
-- globalconbined.lua end
            if et.gentity_get(userinfoCheck["clientNum"], "inuse") then
                local userinfo = et.trap_GetUserinfo(userinfoCheck["clientNum"])
                local reason = checkUserinfo(userinfo)

                if reason then
                    et.G_LogPrintf("userinfocheck frame: client %d bad userinfo %s\n", userinfoCheck["clientNum"], reason)
                    et.trap_SetUserinfo(userinfoCheck["clientNum"], "name\\badinfo")
                    et.trap_DropClient(userinfoCheck["clientNum"], "bad userinfo", 0)
                end
            end
--        end
--    end

    if userinfoCheck["clientNum"] >= clientsLimit then
        userinfoCheck["clientNum"] = 0
    else
        userinfoCheck["clientNum"] = userinfoCheck["clientNum"] + 1
    end
end

function badUserinfo(clientNum, reason)
    et.G_LogPrintf("userinfocheck infochanged: client %d bad userinfo %s\n", clientNum, reason)
    et.trap_SetUserinfo(vars["clientNum"], "name\\badinfo")
    et.trap_DropClient(vars["clientNum"], string.format("bad userinfo : %s", reason), 0)
end

function etProFixClientUserinfoChanged(vars)
    local userinfo = et.trap_GetUserinfo(vars["clientNum"])
    local reason   = checkUserinfo(userinfo)

    if reason then
        badUserinfo(vars["clientNum"], reason)
    end

-- TODO : Check if needed
-- globalconbined.lua start
--    local guid = string.upper(client[vars["clientNum"]]["guid"])
--    local name = client[vars["clientNum"]]["name"]
--
--    for i = 0, clientsLimit do
--        local player_userinfo = et.trap_GetUserinfo(client)
--        local player_guid     = string.upper(client[client]["guid"])
--
--        if client[i]["name"] == name and name ~= "ETPlayer" and name ~= "UnnamedPlayer" and vars["clientNum"] ~= i then
--            badUserinfo(vars["clientNum"], "duplicate name")
--        elseif player_guid == guid and player_guid ~= "NO_GUID" and player_guid ~= "UNKNOWN" and vars["clientNum"] ~= i then
--            badUserinfo(vars["clientNum"], "duplicate guid")
--        end
--    end
-- globalconbined.lua end
end

-- Add callback ETpro fix function.
addCallbackFunction({
    ["ClientConnect"]         = "etProFixClientConnect",
    ["ClientUserinfoChanged"] = "etProFixClientUserinfoChanged",
    ["RunFrame"]              = "etProFixRunFrame",
    ["Print"]                 = "checkGuidLinePrint"
})
