# FeverGames frontend patch profiles.
# Exact-byte validated. PowerShell 2.0 compatible.
#
# IMPORTANT:
# A folder version is not assumed to identify one binary layout.
# 1.18.42.14 is known to exist in at least two layouts.
# Profile selection therefore uses FolderBuild + all 5 exact target-byte checks.

[byte[]]$FG_Getter81 = @(
    0xC7,0x01,0x38,0x2E,0x31,0x00,
    0x48,0xC7,0x41,0x10,0x03,0x00,0x00,0x00,
    0x48,0xC7,0x41,0x18,0x0F,0x00,0x00,0x00,
    0x48,0x8B,0xC1,
    0xC3,
    0x90,0x90,0x90
)

[byte[]]$FG_Getter10 = @(
    0x66,0xC7,0x01,0x31,0x30,
    0xC6,0x41,0x02,0x00,
    0x48,0xC7,0x41,0x10,0x02,0x00,0x00,0x00,
    0x48,0xC7,0x41,0x18,0x0F,0x00,0x00,0x00,
    0x48,0x8B,0xC1,
    0xC3
)

$FeverGamesPatchProfiles = @{}

$FeverGamesPatchProfiles["1.18.42.12-A"] = @{
    Build = "1.18.42.12 / layout A"
    FolderBuild = "1.18.42.12"
    InstallerOriginalSha256 = ""
    Entries = @(
        @{
            Key="GateA"; Name="Gate A - central Win10 helper"; Offset=[Int64]0xA64460
            Original=[byte[]]@(0x40,0x53,0x48,0x81,0xEC,0x50)
            Patched=[byte[]]@(0xB8,0x01,0x00,0x00,0x00,0xC3)
        },
        @{
            Key="GateB"; Name="Gate B - checkSystemVersion caller"; Offset=[Int64]0x6EE624
            Original=[byte[]]@(0x0F,0x85,0xB3,0x00,0x00,0x00)
            Patched=[byte[]]@(0x90,0xE9,0xB3,0x00,0x00,0x00)
        },
        @{
            Key="NetLabel"; Name="download_check os-ver label Win7 -> Win8.1"; Offset=[Int64]0xA07B5C
            Original=[byte[]]@(0x48,0x8D,0x15,0xE5,0x79,0x4B,0x00)
            Patched=[byte[]]@(0x48,0x8D,0x15,0x05,0x7A,0x4B,0x00)
        },
        @{
            Key="NetMinor"; Name="download_check minor 1 -> 3"; Offset=[Int64]0xA07BD2
            Original=[byte[]]@(0x8B,0x55,0xA7)
            Patched=[byte[]]@(0x6A,0x03,0x5A)
        },
        @{
            Key="Getter"; Name="downloadIPC sysVer getter -> 8.1"; Offset=[Int64]0xA09220
            Original=[byte[]]@(
                0x48,0x89,0x4C,0x24,0x08,0x53,0x48,0x83,0xEC,0x20,0x48,0x8B,0xD9,
                0x8B,0x15,0x65,0x2B,0x23,0x04,0x65,0x48,0x8B,0x04,0x25,0x58,0x00,0x00,0x00,0xB9
            )
            Patched=$FG_Getter81
            AlternateBefore=$FG_Getter10
        }
    )
}

$FeverGamesPatchProfiles["1.18.42.14-A"] = @{
    Build = "1.18.42.14 / layout A"
    FolderBuild = "1.18.42.14"
    InstallerOriginalSha256 = "4ce71c80f24f585e599e2f4c1bbd5c66a41e46eb3f3c613d62a854cafad00433"
    Entries = @(
        @{
            Key="GateA"; Name="Gate A - central Win10 helper"; Offset=[Int64]0xA64C70
            Original=[byte[]]@(0x40,0x53,0x48,0x81,0xEC,0x50)
            Patched=[byte[]]@(0xB8,0x01,0x00,0x00,0x00,0xC3)
        },
        @{
            Key="GateB"; Name="Gate B - checkSystemVersion caller"; Offset=[Int64]0x6EE624
            Original=[byte[]]@(0x0F,0x85,0xB3,0x00,0x00,0x00)
            Patched=[byte[]]@(0x90,0xE9,0xB3,0x00,0x00,0x00)
        },
        @{
            Key="NetLabel"; Name="download_check os-ver label Win7 -> Win8.1"; Offset=[Int64]0xA0836C
            Original=[byte[]]@(0x48,0x8D,0x15,0x35,0x74,0x4B,0x00)
            Patched=[byte[]]@(0x48,0x8D,0x15,0x55,0x74,0x4B,0x00)
        },
        @{
            Key="NetMinor"; Name="download_check minor 1 -> 3"; Offset=[Int64]0xA083E2
            Original=[byte[]]@(0x8B,0x55,0xA7)
            Patched=[byte[]]@(0x6A,0x03,0x5A)
        },
        @{
            Key="Getter"; Name="downloadIPC sysVer getter -> 8.1"; Offset=[Int64]0xA09A30
            Original=[byte[]]@(
                0x48,0x89,0x4C,0x24,0x08,0x53,0x48,0x83,0xEC,0x20,0x48,0x8B,0xD9,
                0x8B,0x15,0x35,0x23,0x23,0x04,0x65,0x48,0x8B,0x04,0x25,0x58,0x00,0x00,0x00,0xB9
            )
            Patched=$FG_Getter81
            AlternateBefore=$FG_Getter10
        }
    )
}

$FeverGamesPatchProfiles["1.18.42.14-B"] = @{
    Build = "1.18.42.14 / layout B"
    FolderBuild = "1.18.42.14"
    InstallerOriginalSha256 = "0a2a9568ac788227f0815e3c23761cadc11b51ee4ba9b86336cb2abf61e178e9"
    Entries = @(
        @{
            Key="GateA"; Name="Gate A - central Win10 helper"; Offset=[Int64]0xA64C50
            Original=[byte[]]@(0x40,0x53,0x48,0x81,0xEC,0x50)
            Patched=[byte[]]@(0xB8,0x01,0x00,0x00,0x00,0xC3)
        },
        @{
            Key="GateB"; Name="Gate B - checkSystemVersion caller"; Offset=[Int64]0x6EE614
            Original=[byte[]]@(0x0F,0x85,0xB3,0x00,0x00,0x00)
            Patched=[byte[]]@(0x90,0xE9,0xB3,0x00,0x00,0x00)
        },
        @{
            Key="NetLabel"; Name="download_check os-ver label Win7 -> Win8.1"; Offset=[Int64]0xA0834C
            Original=[byte[]]@(0x48,0x8D,0x15,0x35,0x74,0x4B,0x00)
            Patched=[byte[]]@(0x48,0x8D,0x15,0x55,0x74,0x4B,0x00)
        },
        @{
            Key="NetMinor"; Name="download_check minor 1 -> 3"; Offset=[Int64]0xA083C2
            Original=[byte[]]@(0x8B,0x55,0xA7)
            Patched=[byte[]]@(0x6A,0x03,0x5A)
        },
        @{
            Key="Getter"; Name="downloadIPC sysVer getter -> 8.1"; Offset=[Int64]0xA09A10
            Original=[byte[]]@(
                0x48,0x89,0x4C,0x24,0x08,0x53,0x48,0x83,0xEC,0x20,0x48,0x8B,0xD9,
                0x8B,0x15,0x75,0x23,0x23,0x04,0x65,0x48,0x8B,0x04,0x25,0x58,0x00,0x00,0x00,0xB9
            )
            Patched=$FG_Getter81
            AlternateBefore=$FG_Getter10
        }
    )
}

# FeverGames 1.18.43.22 / layout A
# Verified on Windows 7: install, full game download and game launch succeeded.
# FeverGamesInstaller.exe SHA256:
# d86f38ea0ab650b94e467dfc7a3c0f01587fa90d6d079d9f04f5b87ae5579c27
$FeverGamesPatchProfiles["1.18.43.22-A"] = @{
    Build = "1.18.43.22 / layout A"
    FolderBuild = "1.18.43.22"
    InstallerOriginalSha256 = "d86f38ea0ab650b94e467dfc7a3c0f01587fa90d6d079d9f04f5b87ae5579c27"
    Entries = @(
        @{
            Key="GateA"; Name="Gate A - central Win10 helper"; Offset=[Int64]0xA9C4A0
            Original=[byte[]]@(0x40,0x53,0x48,0x81,0xEC,0x50)
            Patched=[byte[]]@(0xB8,0x01,0x00,0x00,0x00,0xC3)
        },
        @{
            Key="GateB"; Name="Gate B - checkSystemVersion caller"; Offset=[Int64]0x6F564D
            Original=[byte[]]@(0x0F,0x85,0xD6,0x00,0x00,0x00)
            Patched=[byte[]]@(0x90,0xE9,0xD6,0x00,0x00,0x00)
        },
        @{
            Key="NetLabel"; Name="download_check os-ver label Win7 -> Win8.1"; Offset=[Int64]0xA3FB5C
            Original=[byte[]]@(0x48,0x8D,0x15,0xE5,0xED,0x4C,0x00)
            Patched=[byte[]]@(0x48,0x8D,0x15,0x05,0xEE,0x4C,0x00)
        },
        @{
            Key="NetMinor"; Name="download_check minor 1 -> 3"; Offset=[Int64]0xA3FBD2
            Original=[byte[]]@(0x8B,0x55,0xA7)
            Patched=[byte[]]@(0x6A,0x03,0x5A)
        },
        @{
            Key="Getter"; Name="downloadIPC sysVer getter -> 8.1"; Offset=[Int64]0xA41220
            Original=[byte[]]@(
                0x48,0x89,0x4C,0x24,0x08,0x53,0x48,0x83,0xEC,0x20,0x48,0x8B,0xD9,
                0x8B,0x15,0x75,0x16,0x26,0x04,0x65,0x48,0x8B,0x04,0x25,0x58,0x00,0x00,0x00,0xB9
            )
            Patched=$FG_Getter81
            AlternateBefore=$FG_Getter10
        }
    )
}

# FeverGames 1.18.44.2 / layout A
# Verified on Windows 7 SP1 x64: patch install, full game download,
# game launch and entering a world succeeded.
# FeverGamesInstaller.exe SHA256:
# 99b71ce13933694f7eaba85a8e9890d4a3f93fe09c73ab4a3c42da33b1b04aaf
$FeverGamesPatchProfiles["1.18.44.2-A"] = @{
    Build = "1.18.44.2 / layout A"
    FolderBuild = "1.18.44.2"
    InstallerOriginalSha256 = "99b71ce13933694f7eaba85a8e9890d4a3f93fe09c73ab4a3c42da33b1b04aaf"
    Entries = @(
        @{
            Key="GateA"; Name="Gate A - central Win10 helper"; Offset=[Int64]0xABD2B0
            Original=[byte[]]@(0x40,0x53,0x48,0x81,0xEC,0x50)
            Patched=[byte[]]@(0xB8,0x01,0x00,0x00,0x00,0xC3)
        },
        @{
            Key="GateB"; Name="Gate B - checkSystemVersion caller"; Offset=[Int64]0x70F0AD
            Original=[byte[]]@(0x0F,0x85,0xD6,0x00,0x00,0x00)
            Patched=[byte[]]@(0x90,0xE9,0xD6,0x00,0x00,0x00)
        },
        @{
            Key="NetLabel"; Name="download_check os-ver label Win7 -> Win8.1"; Offset=[Int64]0xA605DC
            Original=[byte[]]@(0x48,0x8D,0x15,0x95,0x46,0x4E,0x00)
            Patched=[byte[]]@(0x48,0x8D,0x15,0xB5,0x46,0x4E,0x00)
        },
        @{
            Key="NetMinor"; Name="download_check minor 1 -> 3"; Offset=[Int64]0xA60652
            Original=[byte[]]@(0x8B,0x55,0xA7)
            Patched=[byte[]]@(0x6A,0x03,0x5A)
        },
        @{
            Key="Getter"; Name="downloadIPC sysVer getter -> 8.1"; Offset=[Int64]0xA61CA0
            Original=[byte[]]@(
                0x48,0x89,0x4C,0x24,0x08,0x53,0x48,0x83,0xEC,0x20,0x48,0x8B,0xD9,
                0x8B,0x15,0x65,0x28,0x28,0x04,0x65,0x48,0x8B,0x04,0x25,0x58,0x00,0x00,0x00,0xB9
            )
            Patched=$FG_Getter81
            AlternateBefore=$FG_Getter10
        }
    )
}
