

function execute_command(params)
    local fdadm, len = et.trap_FS_FOpenFile(kmod_ng_path .. "sprees/spree_record.dat", et.FS_WRITE)

    SPREE = ''

    et.trap_FS_Write(SPREE, string.len(SPREE) ,fdadm)
    et.trap_FS_FCloseFile(fdadm)
    et.trap_SendConsoleCommand(et.EXEC_APPEND, "qsay ^3Spree record: ^7Spree record has been reset!\n")
    loadspreerecord()
end
