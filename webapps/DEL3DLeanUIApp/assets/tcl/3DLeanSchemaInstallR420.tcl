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
        ######################################################
        #       ATTRIBUTES DEFINITION
        ######################################################
        set lList_AddAttrDEL3DLTitle\
        [ list  {ADD ATTRIBUTE} \
                        {V_DEL3DL_Title} \
                        {ADD ATTRIBUTE} \
                        {attribute_DEL3DLTitle} \
                        {mql add attribute "V_DEL3DL_Title" type string; \
                        } \
        ]
		set lList_AddAttrDEL3DLGridSizeX \
        [ list  {ADD ATTRIBUTE} \
                        {V_DEL3DL_Grid_Size_X} \
                        {ADD ATTRIBUTE} \
                        {attribute_DEL3DLGridSizeX} \
                        {mql add attribute "V_DEL3DL_Grid_Size_X" type integer; \
                        } \
        ]
        set lList_AddAttrDEL3DLGridSizeY \
        [ list  {ADD ATTRIBUTE} \
                        {V_DEL3DL_Grid_Size_Y} \
                        {ADD ATTRIBUTE} \
                        {attribute_DEL3DLGridSizeX} \
                        {mql add attribute "V_DEL3DL_Grid_Size_Y" type integer; \
                        } \
        ]
        set lList_AddAttrDEL3DLPeriod \
        [ list  {ADD ATTRIBUTE} \
                        {V_DEL3DL_Period} \
                        {ADD ATTRIBUTE} \
                        {attribute_DEL3DLPeriod} \
                        {mql add attribute "V_DEL3DL_Period" type integer; \
                        } \
        ]
        set lList_AddAttrDEL3DLDescription \
        [ list  {ADD ATTRIBUTE} \
                        {V_DEL3DL_Description} \
                        {ADD ATTRIBUTE} \
                        {attribute_DEL3DLDescription} \
                        {mql add attribute "V_DEL3DL_Description" type string; \
                        } \
        ]
        set lList_AddAttrDEL3DLState \
        [ list  {ADD ATTRIBUTE} \
                        {V_DEL3DL_State} \
                        {ADD ATTRIBUTE} \
                        {attribute_DEL3DLState} \
                        {mql add attribute "V_DEL3DL_State" type string; \
                        } \
        ]
        set lList_AddAttrDEL3DLPreferences \
        [ list  {ADD ATTRIBUTE} \
                        {V_DEL3DL_Preferences} \
                        {ADD ATTRIBUTE} \
                        {attribute_DEL3DLPreferences} \
                        {mql add attribute "V_DEL3DL_Preferences" type string; \
                        } \
        ]
        set lList_AddAttrDEL3DLData \
        [ list  {ADD ATTRIBUTE} \
                        {V_DEL3DL_Data} \
                        {ADD ATTRIBUTE} \
                        {attribute_DEL3DLData} \
                        {mql add attribute "V_DEL3DL_Data" type string; \
                        } \
        ]
        set lList_AddAttrDEL3DLSketchImage \
        [ list  {ADD ATTRIBUTE} \
                        {V_DEL3DL_Sketch_Image} \
                        {ADD ATTRIBUTE} \
                        {attribute_DEL3DLSketchImage} \
                        {mql add attribute "V_DEL3DL_Sketch_Image" type string; \
                        } \
        ]
        set lList_AddAttrDEL3DLX \
        [ list  {ADD ATTRIBUTE} \
                        {V_DEL3DL_X} \
                        {ADD ATTRIBUTE} \
                        {attribute_DEL3DLX} \
                        {mql add attribute "V_DEL3DL_X" type real; \
                        } \
        ]
        set lList_AddAttrDEL3DLY \
        [ list  {ADD ATTRIBUTE} \
                        {V_DEL3DL_Y} \
                        {ADD ATTRIBUTE} \
                        {attribute_DEL3DLY} \
                        {mql add attribute "V_DEL3DL_Y" type real; \
                        } \
        ]
        set lList_AddAttrDEL3DLSizeX \
        [ list  {ADD ATTRIBUTE} \
                        {V_DEL3DL_Size_X} \
                        {ADD ATTRIBUTE} \
                        {attribute_DEL3DLSizeX} \
                        {mql add attribute "V_DEL3DL_Size_X" type real; \
                        } \
        ]
        set lList_AddAttrDEL3DLSizeY \
        [ list  {ADD ATTRIBUTE} \
                        {V_DEL3DL_Size_Y} \
                        {ADD ATTRIBUTE} \
                        {attribute_DEL3DLSizeY} \
                        {mql add attribute "V_DEL3DL_Size_Y" type real; \
                        } \
        ]
        set lList_AddAttrDEL3DLCategory \
        [ list  {ADD ATTRIBUTE} \
                        {V_DEL3DL_Category} \
                        {ADD ATTRIBUTE} \
                        {attribute_DEL3DLCategory} \
                        {mql add attribute "V_DEL3DL_Category" type string; \
                        } \
        ]
        set lList_AddAttrDEL3DLBackgroundColor \
        [ list  {ADD ATTRIBUTE} \
                        {V_DEL3DL_Background_Color} \
                        {ADD ATTRIBUTE} \
                        {attribute_DEL3DLBackgroundColor} \
                        {mql add attribute "V_DEL3DL_Background_Color" type string; \
                        } \
        ]
        ######################################################
        #       TYPE DEFINITION
        ######################################################
       set lList_AddTypeDEL3DLAElement \
        [ list  {ADD TYPE} \
                        {DEL3DL_Abstract_Element} \
                        {ADD TYPE} \
                        {type_DEL3DLAElement} \
                        {mql add type "DEL3DL_Abstract_Element" \
                        abstract TRUE \
                        attribute "V_DEL3DL_Data"; \
                        } \
		]
		set lList_AddTypeDEL3DLAStatic \
        [ list  {ADD TYPE} \
                        {DEL3DL_Abstract_Static} \
                        {ADD TYPE} \
                        {type_DEL3DLAStatic} \
                        {mql add type "DEL3DL_Abstract_Static"\
                        abstract TRUE \
                        derived "DEL3DL_Abstract_Element" \
                        attribute "V_DEL3DL_Title"; \
                        } \
		]
		set lList_AddTypeDEL3DLAFloatable \
        [ list  {ADD TYPE} \
                        {DEL3DL_Abstract_Floatable} \
                        {ADD TYPE} \
                        {type_DEL3DLAFloatable} \
                        {mql add type "DEL3DL_Abstract_Floatable"\
                        abstract TRUE \
                        derived "DEL3DL_Abstract_Element"; \
                        } \
        ]
        set lList_AddTypeDEL3DLALeanget \
        [ list  {ADD TYPE} \
                        {DEL3DL_Abstract_Leanget} \
                        {ADD TYPE} \
                        {type_DEL3DLALeanget} \
                        {mql add type "DEL3DL_Abstract_Leanget"\
                        abstract TRUE \
                        derived "DEL3DL_Abstract_Static" \
                        attribute "V_DEL3DL_Period" \
                        attribute "V_DEL3DL_Description" \
                        attribute "V_DEL3DL_State" \
                        attribute "V_DEL3DL_Preferences"; \
                        } \
        ]
        set lList_AddTypeDEL3DLPage \
        [ list  {ADD TYPE} \
                        {DEL3DL_Page} \
                        {ADD TYPE} \
                        {type_DEL3DLPage} \
                        {mql add type "DEL3DL_Page"\
                        abstract FALSE \
                        derived "DEL3DL_Abstract_Static" \
                        attribute "V_DEL3DL_Grid_Size_X" \
                        attribute "V_DEL3DL_Grid_Size_Y"; \
                        } \
        ]
        set lList_AddTypeDEL3DLSession \
        [ list  {ADD TYPE} \
                        {DEL3DL_Session} \
                        {ADD TYPE} \
                        {type_DEL3DLSession} \
                        {mql add type "DEL3DL_Session"\
                        abstract FALSE \
                        derived "DEL3DL_Page"; \
                        } \
        ]
        set lList_AddTypeDEL3DLSticker \
        [ list  {ADD TYPE} \
                        {DEL3DL_Sticker} \
                        {ADD TYPE} \
                        {type_DEL3DLSticker} \
                        {mql add type "DEL3DL_Sticker"\
                        abstract FALSE \
                        derived "DEL3DL_Abstract_Floatable"; \
                        } \
        ]
        set lList_AddTypeDEL3DLStickyNote \
        [ list  {ADD TYPE} \
                        {DEL3DL_Sticky_Note} \
                        {ADD TYPE} \
                        {type_DEL3DLStickyNote} \
                        {mql add type "DEL3DL_Sticky_Note"\
                        abstract FALSE \
                        derived "DEL3DL_Abstract_Floatable" \
                        attribute "V_DEL3DL_Sketch_Image" \
                        attribute "V_DEL3DL_Category" \
                        attribute "V_DEL3DL_Background_Color"; \
                        } \
        ]
        set lList_AddTypeDEL3DLStickyMember \
        [ list  {ADD TYPE} \
                        {DEL3DL_Sticky_Member} \
                        {ADD TYPE} \
                        {type_DEL3DLStickyMember} \
                        {mql add type "DEL3DL_Sticky_Member"\
                        abstract FALSE \
                        derived "DEL3DL_Abstract_Floatable"; \
                        } \
        ]
        set lList_AddTypeDEL3DLTeam \
        [ list  {ADD TYPE} \
                        {DEL3DL_Team} \
                        {ADD TYPE} \
                        {type_DEL3DLTeam} \
                        {mql add type "DEL3DL_Team"\
                        abstract FALSE \
                        derived "DEL3DL_Abstract_Leanget"; \
                        } \
        ]
        set lList_AddTypeDEL3DLTeamPad \
        [ list  {ADD TYPE} \
                        {DEL3DL_Team_Pad} \
                        {ADD TYPE} \
                        {type_DEL3DLTeamPad} \
                        {mql add type "DEL3DL_Team_Pad"\
                        abstract FALSE \
                        derived "DEL3DL_Page"; \
                        } \
        ]
        set lList_AddTypeDEL3DLActionLog \
        [ list  {ADD TYPE} \
                        {DEL3DL_Action_Log} \
                        {ADD TYPE} \
                        {type_DEL3DLActionLog} \
                        {mql add type "DEL3DL_Action_Log"\
                        abstract FALSE \
                        derived "DEL3DL_Abstract_Leanget"; \
                        } \
        ]
        set lList_AddTypeDEL3DLSafety \
        [ list  {ADD TYPE} \
                        {DEL3DL_Safety} \
                        {ADD TYPE} \
                        {type_DEL3DLSafety} \
                        {mql add type "DEL3DL_Safety"\
                        abstract FALSE \
                        derived "DEL3DL_Abstract_Leanget"; \
                        } \
        ]
        set lList_AddTypeDEL3DLWebViewer \
        [ list  {ADD TYPE} \
                        {DEL3DL_Web_Viewer} \
                        {ADD TYPE} \
                        {type_DEL3DLWebViewer} \
                        {mql add type "DEL3DL_Web_Viewer"\
                        abstract FALSE \
                        derived "DEL3DL_Abstract_Leanget"; \
                        } \
        ]
        set lList_AddTypeDEL3DL5SFollowUp \
        [ list  {ADD TYPE} \
                        {DEL3DL_5S_FollowUp} \
                        {ADD TYPE} \
                        {type_DEL3DL5SFollowUp} \
                        {mql add type "DEL3DL_5S_FollowUp"\
                        abstract FALSE \
                        derived "DEL3DL_Abstract_Leanget"; \
                        } \
        ]
        set lList_AddTypeDEL3DLEHSCross \
        [ list  {ADD TYPE} \
                        {DEL3DL_EHS_Cross} \
                        {ADD TYPE} \
                        {type_DEL3DLEHSCross} \
                        {mql add type "DEL3DL_EHS_Cross"\
                        abstract FALSE \
                        derived "DEL3DL_Abstract_Leanget"; \
                        } \
        ]
        set lList_AddTypeDEL3DLTipOfTheDay \
        [ list  {ADD TYPE} \
                        {DEL3DL_Tip_Of_The_Day} \
                        {ADD TYPE} \
                        {type_DEL3DLTipOfTheDay} \
                        {mql add type "DEL3DL_Tip_Of_The_Day"\
                        abstract FALSE \
                        derived "DEL3DL_Abstract_Leanget"; \
                        } \
        ]
        set lList_AddTypeDEL3DLKPI \
        [ list  {ADD TYPE} \
                        {DEL3DL_KPI} \
                        {ADD TYPE} \
                        {type_DEL3DLKPI} \
                        {mql add type "DEL3DL_KPI"\
                        abstract FALSE \
                        derived "DEL3DL_Abstract_Leanget"; \
                        } \
        ]
        set lList_AddTypeDEL3DLSketch \
        [ list  {ADD TYPE} \
                        {DEL3DL_Sketch} \
                        {ADD TYPE} \
                        {type_DEL3DLSketch} \
                        {mql add type "DEL3DL_Sketch"\
                        abstract FALSE \
                        derived "DEL3DL_Abstract_Leanget"; \
                        } \
        ]
		 ######################################################
        #       RELATIONSHIP DEFINITION
        ######################################################
		set lList_AddRelDEL3DLCoord \
        [ list  {ADD RELATIONSHIP} \
                        {DEL3DL_Coord} \
                        {ADD RELATIONSHIP} \
                        {relationship_DEL3DLCoord} \
                        {mql add relationship "DEL3DL_Coord" \
                        description "Coord For Abstract Element" \
                        abstract FALSE \
                        attribute "V_DEL3DL_X" \
                        attribute "V_DEL3DL_Y" \
                        attribute "V_DEL3DL_Size_X" \
                        attribute "V_DEL3DL_Size_Y" \
                        attribute "V_DEL3DL_Data" \
                        from type "DEL3DL_Abstract_Element" meaning "Contains" revision none clone none cardinality many  \
                        to type "DEL3DL_Abstract_Element" meaning "Is contained in" revision none clone none cardinality many nothidden notpreventduplicates; \
                        } \
        ]
        set lList_AddRelDEL3DLLink \
        [ list  {ADD RELATIONSHIP} \
                        {DEL3DL_Link} \
                        {ADD RELATIONSHIP} \
                        {relationship_DEL3DLLink} \
                        {mql add relationship "DEL3DL_Link" \
                        description "Link For Any Objects" \
                        abstract FALSE \
                        attribute "V_DEL3DL_Data" \
                        from type all meaning "Contains" revision none clone none cardinality many  \
                        to type all meaning "Is contained in" revision none clone none cardinality many nothidden notpreventduplicates; \
                        } \
        ]
        set lCmd [ list $lList_AddAttrDEL3DLTitle \
						$lList_AddAttrDEL3DLGridSizeX \
                        $lList_AddAttrDEL3DLGridSizeY \
                        $lList_AddAttrDEL3DLPeriod \
                        $lList_AddAttrDEL3DLDescription \
                        $lList_AddAttrDEL3DLState \
                        $lList_AddAttrDEL3DLPreferences \
                        $lList_AddAttrDEL3DLData \
                        $lList_AddAttrDEL3DLSketchImage \
                        $lList_AddAttrDEL3DLX \
                        $lList_AddAttrDEL3DLY \
                        $lList_AddAttrDEL3DLSizeX \
                        $lList_AddAttrDEL3DLSizeY \
                        $lList_AddAttrDEL3DLCategory \
                        $lList_AddAttrDEL3DLBackgroundColor \
                        $lList_AddTypeDEL3DLAElement \
						$lList_AddTypeDEL3DLAStatic \
						$lList_AddTypeDEL3DLAFloatable \
                        $lList_AddTypeDEL3DLALeanget \
                        $lList_AddTypeDEL3DLPage \
                        $lList_AddTypeDEL3DLSession \
                        $lList_AddTypeDEL3DLSticker \
                        $lList_AddTypeDEL3DLStickyNote \
                        $lList_AddTypeDEL3DLStickyMember \
                        $lList_AddTypeDEL3DLTeam \
                        $lList_AddTypeDEL3DLTeamPad \
                        $lList_AddTypeDEL3DLActionLog \
                        $lList_AddTypeDEL3DLSafety \
                        $lList_AddTypeDEL3DLWebViewer \
                        $lList_AddTypeDEL3DL5SFollowUp \
                        $lList_AddTypeDEL3DLEHSCross \
                        $lList_AddTypeDEL3DLTipOfTheDay \
                        $lList_AddTypeDEL3DLKPI \
                        $lList_AddTypeDEL3DLSketch \
                        $lList_AddRelDEL3DLCoord \
                        $lList_AddRelDEL3DLLink \
                        $lList_AddPolDEL3DLPolicy \
                        ]

set mqlret [eAppInstallAdmin $lCmd]

return -code $mqlret ""
}
