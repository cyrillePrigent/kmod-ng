-- Based on RoadKillPuppy's PlaySound / etpro lua module
-- ex. 'rcon rconpass playsound sound/etpro/hit.wav'
--     'rcon rconpass playsound_env sound/etpro/hit.wav'
--
-- copypasted 99% of the code from ReyalP's wolfwiki page
-- thx r0f`deej for testing...  May your sprees be remembered!
--
-- 0.1 rkp
-- 0.2 rkp: dirty implementation of -1 parameter used by etadminmod [REMOVED]
-- 0.3 rkp: workaround for etpro beta racecondition
-- 0.4 rkp: cleaned-up version for etpro 3.2.3
-- 0.5 rkp: added playsound_env command

-- Plays a sound that you can hear in the proximity of the player with slot -playerslot-
--  params is parameters passed from et_ConsoleCommand function.
--   * params["arg1"] => client
--   * params["arg2"] => path to wav sound file
function execute_command(params)
    if params.nbArg < 3 then
        et.G_Print("Useage: playsound_env [partname/id#] [path_to_sound.wav]\n")
    else
        clientNum = client2id(params["arg1"], params)

        if clientNum ~= nil then
            et.G_ClientSound(clientNum, params["arg2"])
        end
    end

    return 1
end
