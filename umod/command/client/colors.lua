-- Display all colors codes in client console.
--  params is parameters passed from et_ClientCommand function.
function execute_command(params)
    et.trap_SendServerCommand(
        params.clientNum,
        "chat \"" .. color1 .. msg .. "Check in your console\""
    )

    et.trap_SendServerCommand(params.clientNum, "print \"^11^22^33^44^55^66^77^88^99^00\"")
    et.trap_SendServerCommand(params.clientNum, "print \"^QQ^WW^EE^RR^TT^YY^UU^II^OO^PP\"")
    et.trap_SendServerCommand(params.clientNum, "print \"^!!^$$^%%^&&^**^((^))^__^++^@@\"")
    et.trap_SendServerCommand(params.clientNum, "print \"^AA^SS^DD^FF^GG^HH^JJ^KK^LL^::\"")
    et.trap_SendServerCommand(params.clientNum, "print \"^\\^ZZ^XX^CC^VV^BB^NN^MM^..^//\"")
    et.trap_SendServerCommand(params.clientNum, "print \"^{{^}}^--^==^[[^]]^''^##^??^||\"")
    et.trap_SendServerCommand(params.clientNum, "print \"^<<^>>\"")

    return 1
end
