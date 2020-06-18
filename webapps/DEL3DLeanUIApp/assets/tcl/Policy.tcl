###############################################################################
#
# 3DLeanSchemaInstallR420.tcl
# Description:  This file contains the mql to create the types, relations and
#               attributes that are required to support the R420 3DLean
# Dependencies: ENOVIA Task should be installed
###############################################################################

###############################################################################
#                                                                             #
#   Copyright (c) 2017 Dassault Systemes.  All Rights Reserved.          	  #
#   This program contains proprietary and trade secret information of         #
#   Dassault Systemes.  Copyright notice is precautionary only and does not   #
#   evidence any actual or intended publication of such program.              #
#                                                                             #
###############################################################################
tcl;
eval {
###############################################################################
#
# Procedure:    utLoad
#
# Description:  Procedure to load other tcl utilities procedures.
#
# Parameters:   sProgram                - Tcl file to load
#
# Returns:      sOutput                 - Filtered tcl file
#               glUtLoadProgs           - List of loaded programs
#
###############################################################################

proc utLoad { sProgram } {

    global glUtLoadProgs env

    if { ! [ info exists glUtLoadProgs ] } {
        set glUtLoadProgs {}
    }

    if { [ lsearch $glUtLoadProgs $sProgram ] < 0 } {
        lappend glUtLoadProgs $sProgram
    } else {
        return ""
    }

    if { [ catch {
        set sDir "$env(TCL_LIBRARY)/mxTclDev"
        set pFile [ open "$sDir/$sProgram" r ]
        set sOutput [ read $pFile ]
        close $pFile

    } ] == 0 } { return $sOutput }
    set  sOutput [ mql print program "$sProgram" select code dump ]
    return $sOutput
}
# end utload

###############################################################################
###############################################################################
#
# Procedure:    AppInstallAdmin
#
# Description:  Procedure to execute mql cmds on admin objects.
#
# Parameters:   sProgram                - Tcl file to load
#
# Returns:      sOutput                 - Filtered tcl file
#               glUtLoadProgs           - List of loaded programs
#
###############################################################################

proc eAppInstallAdmin { lCmdList } {

    mql verbose on

    # set directory
    set sRegProgName    "eServiceSchemaVariableMapping.tcl"
        set mqlall        0

    foreach lElement $lCmdList {

        # check for correct format of input list being processed
        if {[llength $lElement] < 5} {

            puts stdout ">ERROR       : eAppInstallAdmin"
            puts stdout ">Incorrect format"
            puts stdout ">$lElement"
            set mqlall 1
            continue
        }

        set mqlret 0
        set sAction                     [ string trim [lindex $lElement 0] ]
        set sItemName           [ string trim [lindex $lElement 1] ]
        set sDec                        [ string trim [lindex $lElement 2] ]
        set sSymName            [ string trim [lindex $lElement 3] ]
        set sItemCmd            [ string trim [lindex $lElement 4] ]

        set sCmd $sItemCmd
        puts stdout "$sDec $sItemName"
        set mqlret [ catch {eval $sCmd} outStr ]
        if {$mqlret != 0} {
                puts stdout ">ERROR       : eAppInstallAdmin"
                puts stdout ">$outStr"
                set mqlall 1
                continue
        }
        if {$sAction == "ADD RELATIONSHIP"} {
                set sCmd {mql add property "$sSymName" on program "$sRegProgName" to relationship "$sItemName"}

                set mqlret [ catch {eval $sCmd} outStr ]
                if {$mqlret != 0} {
                        puts stdout ">ERROR       : eAppInstallAdmin"
                        puts stdout ">$outStr"
                        set mqlall 1
                        continue
                }
        }
        if {$sAction == "ADD TYPE"} {
                set sCmd {mql add property "$sSymName" on program "$sRegProgName" to type "$sItemName"}

                set mqlret [ catch {eval $sCmd} outStr ]
                if {$mqlret != 0} {
                        puts stdout ">ERROR       : eAppInstallAdmin"
                        puts stdout ">$outStr"
                        set mqlall 1
                        continue
                }
        }
        if {$sAction == "ADD ATTRIBUTE"} {
                set sCmd {mql add property "$sSymName" on program "$sRegProgName" to attribute "$sItemName"}

                set mqlret [ catch {eval $sCmd} outStr ]
                if {$mqlret != 0} {
                        puts stdout ">ERROR       : eAppInstallAdmin"
                        puts stdout ">$outStr"
                        set mqlall 1
                        continue
                }
        }
        if {$sAction == "ADD INTERFACE"} {
                set sCmd {mql add property "$sSymName" on program "$sRegProgName" to interface "$sItemName"}

                set mqlret [ catch {eval $sCmd} outStr ]
                if {$mqlret != 0} {
                        puts stdout ">ERROR       : eAppInstallAdmin"
                        puts stdout ">$outStr"
                        set mqlall 1
                        continue
                }
        }
        if {$sAction == "ADD POLICY"} {
                set sCmd {mql add property "$sSymName" on program "$sRegProgName" to policy "$sItemName"}

                set mqlret [ catch {eval $sCmd} outStr ]
                if {$mqlret != 0} {
                        puts stdout ">ERROR       : eAppInstallAdmin"
                        puts stdout ">$outStr"
                        set mqlall 1
                        continue
                }
        }
}

return $mqlall
}

set sRegProgName    "eServiceSchemaVariableMapping.tcl"

# Load Utility function
eval [utLoad $sRegProgName]

mql verbose on;
mql trigger off;
		######################################################
        #       POLICY DEFINITION
        ######################################################
        set lList_AddPolDEL3DLPolicy\
        [ list  {ADD POLICY} \
                        {DEL3DL_Policy} \
                        {ADD POLICY} \
                        {policy_DEL3DLPolicy} \
                        {mql add policy "DEL3DL_Policy" \
                        allstate type DEL3DL_Abstract_Element,\
                        DEL3DL_Abstract_Static,\
                        DEL3DL_Abstract_Floatable,\
                        DEL3DL_Abstract_Leanget,\
                        DEL3DL_Page,\
                        DEL3DL_Session,\
                        DEL3DL_Sticker,\
                        DEL3DL_Sticky_Note,\
                        DEL3DL_Sticky_Member,\
                        DEL3DL_Team,\
                        DEL3DL_Team_Pad,\
                        DEL3DL_Action_Log,\
                        DEL3DL_Safety,\
                        DEL3DL_5S_FollowUp,\
                        DEL3DL_EHS_Cross,\
                        DEL3DL_Tip_Of_The_Day,\
                        DEL3DL_KPI,\
                        DEL3DL_Sketch, \
                        DEL3DL_Web_Viewer; \
                        } \
        ]
        set lCmd [ list $lList_AddPolDEL3DLPolicy ]

set mqlret [eAppInstallAdmin $lCmd]

return -code $mqlret ""
}
