-- Based on RoadKillPuppy's PlaySound / etpro lua module
-- ex. 'rcon rconpass playsound -1 sound/etpro/hit.wav'
--     'rcon rconpass playsound_env 10 sound/etpro/hit.wav'
--
-- copypasted 99% of the code from ReyalP's wolfwiki page
-- thx r0f`deej for testing...  May your sprees be remembered!
--
-- 0.1 rkp
-- 0.2 rkp: dirty implementation of -1 parameter used by etadminmod [REMOVED]
-- 0.3 rkp: workaround for etpro beta racecondition
-- 0.4 rkp: cleaned-up version for etpro 3.2.3
-- 0.5 rkp: added playsound_env command

slashCommandConsole["playsound"]     = { "function", "playsoundSlashCommand" }
slashCommandConsole["playsound_env"] = { "function", "playsoundEnvSlashCommand" }

-- Function

-- Function executed when slash command is called in et_ConsoleCommand function.
--  params is parameters passed to the function executed in command file.
function playsoundSlashCommand(params)
    if params["nbArg"] ~= 3 then
        et.G_Print("playsound plays a sound that everybody on the server can hear\n")
        et.G_Print("usage: playsound path_to_sound.wav\n")
    else
        et.G_globalSound(params["arg1"])
    end

    return 1
end

-- Function executed when slash command is called in et_ConsoleCommand function.
--  params is parameters passed to the function executed in command file.
function playsoundEnvSlashCommand(params)
    if params["nbArg"] ~= 3 then
        et.G_Print("playsound_env plays a sound that you can hear in the proximity of the player with slot -playerslot-\n")
        et.G_Print("usage: playsound_env playerslot path_to_sound.wav\n")
    else
        et.G_Sound(params["arg1"] , et.G_SoundIndex(params["arg2"]))
    end

    return 1
end
