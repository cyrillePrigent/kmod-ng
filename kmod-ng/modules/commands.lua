-- Commands

-- Global var

--[[
   Commands table :
     alias :
       key   => name of client command
       value => command file / rcon command / bind
     level :
       key   => name of client command
       value => admin level of client command
--]]
commands = {
    ["alias"] = {},
    ["level"] = {}
}

maxAdminLevel = 0

-- Function

-- Read command file and store command data.
function loadCommands()
    local fd, len = et.trap_FS_FOpenFile("commands.cfg", et.FS_READ)

    if len > 0 then
        local fileStr = et.trap_FS_Read(fd, len)

        for lvl, str in string.gfind(fileStr, "[^%#](%d)%s*%-%s*([^%\r%\n]*)") do
            local s, e, cmd, alias = string.find(str, "^([%w%_]*)%s*%=%s*([^%\r%\n]*)$")

            if s and e then
                cmd = "!" .. cmd
                lvl = tonumber(lvl)
                commands["alias"][cmd] = alias
                commands["level"][cmd] = lvl

                if lvl > maxAdminLevel then
                    maxAdminLevel = lvl
                end
            end

            local s, e, cmd = string.find(str, "^([^%=]*)$")

            if s and e then
                cmd = "!" .. cmd
                lvl = tonumber(lvl)
                commands["level"][cmd] = lvl

                if lvl > maxAdminLevel then
                    maxAdminLevel = lvl
                end
            end
        end
    end

    et.trap_FS_FCloseFile(fd)
end

-- Return a random slot id of connected player.
function randomClientFinder()
    local randomClient = {}
    local m = 0

    for i = 0, clientsLimit, 1 do
        if et.gentity_get(i, "pers.connected") == 2 then
            m = m + 1
            randomClient[m] = i
        end
    end

    return randomClient[math.random(1, m)]
end

-- Replace tag in command string.
--  params is parameters of client / console command.
--  str is the command to parse.
function parseClientCommand(params, str)
    local playerName          = et.gentity_get(params.clientNum, "pers.netname")
    local class               = tonumber(et.gentity_get(params.clientNum, "sess.latchPlayerType"))
    local lastVictimName      = ""
    local lastVictimNameClean = ""
    local lastKillerName      = ""
    local lastKillerNameClean = ""

    local teamList  = { "AXIS" , "ALLIES" , "SPECTATOR" }
    local classList = { [0] = "SOLDIER" , "MEDIC" , "ENGINEER" , "FIELD OPS" , "COVERT OPS" }

    if client[params.clientNum]["yourLastVictim"] == 1022 then
        lastVictimName      = "NO ONE"
        lastVictimNameClean = "NO ONE"
    else
        lastVictimName      = et.gentity_get(client[params.clientNum]["yourLastVictim"], "pers.netname")
        lastVictimNameClean = et.Q_CleanStr(lastVictimName)
    end

    if client[params.clientNum]["whoKilledYou"] == 1022 then
        lastKillerName      = "NO ONE"
        lastKillerNameClean = "NO ONE"
    else
        lastKillerName      = et.gentity_get(client[params.clientNum]["whoKilledYou"], "pers.netname")
        lastKillerNameClean = et.Q_CleanStr(lastKillerName)
    end

    local playerName2Id = client2id(params["arg1"])

    if not playerName2Id then
        playerName2Id = 1021
    end

    local pbPlayerName2Id = playerName2Id + 1
    local pbId            = params.clientNum + 1

    local randomC         = randomClientFinder()
    local randomTeam      = teamList[client[randomC]["team"]]
    local randomName      = et.gentity_get(randomC, "pers.netname")
    local randomNameClean = et.Q_CleanStr(randomName)
    local randomClass     = classList[tonumber(et.gentity_get(randomC, "sess.latchPlayerType"))]

    local str = string.gsub(str, "<CLIENT_ID>", params.clientNum)
    local str = string.gsub(str, "<GUID>", et.Info_ValueForKey(et.trap_GetUserinfo(params.clientNum), "cl_guid"))
    local str = string.gsub(str, "<COLOR_PLAYER>", playerName)
    local str = string.gsub(str, "<ADMINLEVEL>", getAdminLevel(params.clientNum))
    local str = string.gsub(str, "<PLAYER>", et.Q_CleanStr(playerName))
    local str = string.gsub(str, "<PLAYER_CLASS>", classList[class])
    local str = string.gsub(str, "<PLAYER_TEAM>", teamList[client[params.clientNum]["team"]])
    local str = string.gsub(str, "<PARAMETER>", params["arg1"] .. params["arg2"])
    local str = string.gsub(str, "<PLAYER_LAST_KILLER_ID>", client[params.clientNum]["whoKilledYou"])
    local str = string.gsub(str, "<PLAYER_LAST_KILLER_NAME>", lastKillerNameClean)
    local str = string.gsub(str, "<PLAYER_LAST_KILLER_CNAME>", lastKillerName)
    local str = string.gsub(str, "<PLAYER_LAST_KILLER_WEAPON>", client[params.clientNum]["victimWeapon"])
    local str = string.gsub(str, "<PLAYER_LAST_VICTIM_ID>", client[params.clientNum]["yourLastVictim"])
    local str = string.gsub(str, "<PLAYER_LAST_VICTIM_NAME>", lastVictimNameClean)
    local str = string.gsub(str, "<PLAYER_LAST_VICTIM_CNAME>", lastVictimName)
    local str = string.gsub(str, "<PLAYER_LAST_VICTIM_WEAPON>", client[params.clientNum]["killerWeapon"])
    local str = string.gsub(str, "<PNAME2ID>", playerName2Id)
    local str = string.gsub(str, "<PBPNAME2ID>", pbPlayerName2Id)
    local str = string.gsub(str, "<PB_ID>", pbId)
    local str = string.gsub(str, "<RANDOM_ID>", randomC)
    local str = string.gsub(str, "<RANDOM_CNAME>", randomName)
    local str = string.gsub(str, "<RANDOM_NAME>", randomNameClean)
    local str = string.gsub(str, "<RANDOM_CLASS>", randomClass)
    local str = string.gsub(str, "<RANDOM_TEAM>", randomTeam)
    --local classnumber = tonumber(et.gentity_get(params.clientNum, "sess.latchPlayerType"))

    return str
end

-- Check client command and execute it if founded.
--  params is parameters of client / console command.
--  lowBangCmd is the command execute if exist.
function checkClientCommand(params, lowBangCmd)
    --debug("DEBUG checkClientCommand params", params)

    if commands["level"][lowBangCmd] ~= nil then
        if commands["level"][lowBangCmd] <= getAdminLevel(params["clientNum"]) then
            if commands["alias"][lowBangCmd] == nil then
                if cmdList["client"][lowBangCmd] ~= nil then
                    if runCommandFile(lowBangCmd, params) == 1 then
                        return true
                    end
                end
            else
                local str = parseClientCommand(params, commands["alias"][lowBangCmd])
                et.trap_SendConsoleCommand(et.EXEC_APPEND, str .. "\n")

                local strPart = splitWord(str)

                if strPart[1] == "forcecvar" then
                    et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3etpro svcmd: ^7forcing client cvar [" .. strPart[2] .. "] to [" .. params["arg1"] .. "]\n")
                end
            end
        else
            et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^7Insufficient Admin status\n")
        end

        return true
    end

    --[[
    if commands["alias"][lowBangCmd] ~= nil then
        if commands["level"][lowBangCmd] <= getAdminLevel(params["clientNum"]) then
            local str = commands["alias"][lowBangCmd]

            if cmdList["client"][k_commandprefix .. str] ~= nil then
                if runCommandFile(k_commandprefix .. str, params) == 1 then
                    return true
                end
            end

            str = parseClientCommand(params, str)
            et.trap_SendConsoleCommand(et.EXEC_APPEND, str .. "\n")

            local strPart = splitWord(str)

            if strPart[1] == "forcecvar" then
                et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^3etpro svcmd: ^7forcing client cvar [" .. strPart[2] .. "] to [" .. params["arg1"] .. "]\n")
            end
        else
            et.trap_SendConsoleCommand(et.EXEC_APPEND, params.say .. " ^7Insufficient Admin status\n")
        end

        return true
    end
    --]]

    return false
end

-- Return admin level of client command.
--  cmd is the command name.
function getCommandLevel(cmd)
    if commands["level"][cmd] ~= nil then
        return commands["level"][cmd]
    end

    return maxAdminLevel + 1
end

-- Add callback command function.
addCallbackFunction({
    ["ReadConfig"] = "loadCommands"
})
