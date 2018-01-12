-- Commands
-- From kmod script.

-- Global var

commands = {
    -- Command alias list :
    --  key   => name of client command
    --  value => command file / rcon command / bind
    ["alias"] = {},
    -- Command level list :
    --  key   => name of client command
    --  value => admin level of client command
    ["level"] = {}
}

-- Highest admin level
maxAdminLevel = 0

-- Function

-- Callback function when ReadConfig is called in et_InitGame function
-- and in the !readconfig client command.
-- Read command file and store command data.
function loadCommands()
    local funcStart = et.trap_Milliseconds()
    local fd, len   = et.trap_FS_FOpenFile("commands.cfg", et.FS_READ)

    if len == -1 then
        et.G_LogPrint("uMod WARNING: commands.cfg file no found / not readable!\n")
    elseif len == 0 then
        et.G_Print("uMod: No commands defined\n")
    else
        local fileStr = et.trap_FS_Read(fd, len)

        for lvl, str in string.gfind(fileStr, "[^%#](%d+)%s*%-%s*([^%\r%\n]*)") do
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
    et.G_LogPrintf("uMod: Loading commands in %d ms\n", et.trap_Milliseconds() - funcStart)
end

-- Return a random slot id of connected player.
function randomClientFinder()
    local randomClient = {}
    local m = 0

    for p = 0, clientsLimit, 1 do
        if et.gentity_get(p, "pers.connected") == 2 then
            m = m + 1
            randomClient[m] = p
        end
    end

    return randomClient[math.random(1, m)]
end

-- Replace tag in command string.
--  params is parameters of client / console command.
--  str is the command to parse.
function parseClientCommand(params, str)
    local class               = tonumber(et.gentity_get(params.clientNum, "sess.latchPlayerType"))
    local lastVictimName      = ""
    local lastVictimNameClean = ""
    local lastKillerName      = ""
    local lastKillerNameClean = ""

    local teamList  = { "Axis" , "Allies" , "Spectator" }
    local classList = { [0] = "Soldier" , "Medic" , "Engineer" , "Field Ops" , "Covert Ops" }

    lastVictimName      = client[client[params.clientNum]["yourLastVictim"]]["name"]
    lastVictimNameClean = et.Q_CleanStr(lastVictimName)

    if client[params.clientNum]["whoKilledYou"] == 1022 then
        lastKillerName      = "The world"
        lastKillerNameClean = "The world"
    else
        lastKillerName      = client[client[params.clientNum]["whoKilledYou"]]["name"]
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
    local randomName      = client[randomC]["name"]
    local randomNameClean = et.Q_CleanStr(randomName)
    local randomClass     = classList[tonumber(et.gentity_get(randomC, "sess.latchPlayerType"))]

    str = string.gsub(str, "<CLIENT_ID>", params.clientNum)
    str = string.gsub(str, "<GUID>", client[params.clientNum]["guid"])
    str = string.gsub(str, "<COLOR_PLAYER>", client[params.clientNum]["name"])
    str = string.gsub(str, "<ADMINLEVEL>", getAdminLevel(params.clientNum))
    str = string.gsub(str, "<PLAYER>", et.Q_CleanStr(client[params.clientNum]["name"]))
    str = string.gsub(str, "<PLAYER_CLASS>", classList[class])
    str = string.gsub(str, "<PLAYER_TEAM>", teamList[client[params.clientNum]["team"]])
    str = string.gsub(str, "<PARAMETER>", params["arg1"] .. params["arg2"])
    str = string.gsub(str, "<PLAYER_LAST_KILLER_ID>", client[params.clientNum]["whoKilledYou"])
    str = string.gsub(str, "<PLAYER_LAST_KILLER_NAME>", lastKillerNameClean)
    str = string.gsub(str, "<PLAYER_LAST_KILLER_CNAME>", lastKillerName)
    str = string.gsub(str, "<PLAYER_LAST_KILLER_WEAPON>", client[params.clientNum]["victimWeapon"])
    str = string.gsub(str, "<PLAYER_LAST_VICTIM_ID>", client[params.clientNum]["yourLastVictim"])
    str = string.gsub(str, "<PLAYER_LAST_VICTIM_NAME>", lastVictimNameClean)
    str = string.gsub(str, "<PLAYER_LAST_VICTIM_CNAME>", lastVictimName)
    str = string.gsub(str, "<PLAYER_LAST_VICTIM_WEAPON>", client[params.clientNum]["killerWeapon"])
    str = string.gsub(str, "<PNAME2ID>", playerName2Id)
    str = string.gsub(str, "<PBPNAME2ID>", pbPlayerName2Id)
    str = string.gsub(str, "<PB_ID>", pbId)
    str = string.gsub(str, "<RANDOM_ID>", randomC)
    str = string.gsub(str, "<RANDOM_CNAME>", randomName)
    str = string.gsub(str, "<RANDOM_NAME>", randomNameClean)
    str = string.gsub(str, "<RANDOM_CLASS>", randomClass)
    str = string.gsub(str, "<RANDOM_TEAM>", randomTeam)
    --local classnumber = tonumber(et.gentity_get(params.clientNum, "sess.latchPlayerType"))

    return str
end

-- Check client command and execute it if founded.
--  params is parameters of client / console command.
--  lowBangCmd is the command execute if exist.
function checkClientCommand(params, lowBangCmd)
    if commands["level"][lowBangCmd] == nil then
        return false
    end

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
                et.trap_SendConsoleCommand(
                    et.EXEC_APPEND,
                    params.say .. color2 .. " etpro svcmd: " .. color1 ..
                    "forcing client cvar [" .. strPart[2] .. "] to [" ..
                    params["arg1"] .. "]\n"
                )
            end
        end
    else
        et.trap_SendConsoleCommand(
            et.EXEC_APPEND,
            params.say .. color1 .. " Insufficient Admin status\n"
        )
    end

    return true
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
