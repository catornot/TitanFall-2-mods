global function dialog_Spawn

struct
{
    table<entity,int> team_selected

    table<entity,int> offset

    array< string > buttons_text = [
        "reaper",
        "grunt",
        "stalker",
        "spectre",
        "tick",
        "rocket_drone",
        "plasma_drone",
        "beam_drone",
        "shield_drone",
        "worker_drone",
        "drone",
        "gunship",
        "dropship",
        "turret_big",
        "turret",
        "turret_plasma",
        "marvin",
        "prowler",
        "ronin",
        "amped_ronin",
        "ronin_boss",
        "arc_titan",
        "northstar",
        "northstar_fd",
        "northstar_boss",
        "brute",
        "amped_brute",
        "tone",
        "tone_boss",
        "ion",
        "ion_boss",
        "monarch",
        "monarch_boss",
        "scorch",
        "scorch_boss",
        "legion",
        "legion_boss",
        "sarah",
        "battery"
    ]
} file

bool function dialog_Spawn( entity player, array<string> args )
{
    hadGift_Admin = false
	CheckAdmin(player)
	if (hadGift_Admin != true)
	{
		print("Admin permission not detected.")
		return true
	}

    // ServerDialogData dialog
    // dialog.header = "Team Select"
    // dialog.message = "Select the team for the npc"

    // AddDialogButton( dialog, "IMC", ButtonImcPressed )
    // AddDialogButton( dialog, "MILITIA", ButtonMilitiaPressed )
    // AddDialogButton( dialog, "NEUTRAL", ButtonNeutralPressed )
    // AddDialogButton( dialog, "OTHER", ButtonOtherPressed )


    // SendServerDialog( player, dialog )

    // if ( !( player in file.offset ) )
    //     file.offset[player] <- 0

    return true
}

void function ButtonImcPressed( entity player )
{
    handleGetTeam( player, TEAM_IMC )
}
void function ButtonMilitiaPressed( entity player )
{
    handleGetTeam( player, TEAM_MILITIA )
}
void function ButtonNeutralPressed( entity player )
{
    handleGetTeam( player, 1 )
}
void function ButtonOtherPressed( entity player )
{
    handleGetTeam( player, 4 )
}


void function handleGetTeam( entity player, int team )
{
    if ( player in file.team_selected )
        file.team_selected[player] = team
    else
        file.team_selected[player] <- team
    
    OpenEntitySelect( player )
}

void function OpenEntitySelect( entity player )
{
    // ServerDialogData dialog
    // dialog.header = "Npc Select"
    // dialog.message = "Select the Npc to spawn"
    // dialog.image = "rui/hud/gametype_icons/fd/onboard_boost_store"

    // AddDialogButton( dialog, file.buttons_text[file.offset[player]+0], Button1Pressed )
    // AddDialogButton( dialog, file.buttons_text[file.offset[player]+1], Button2Pressed )
    // AddDialogButton( dialog, file.buttons_text[file.offset[player]+2], Button3Pressed )
    // AddDialogButton( dialog, "Cycle Next", Button4Pressed )

    // SendServerDialog( player, dialog )
}

void function MoveMenuRight( entity player )
{
    if ( file.offset[player] + 4 < file.buttons_text.len() )
        file.offset[player] += 3
    else
        file.offset[player] = 0
    
    OpenEntitySelect( player )
}
void function MoveMenuLeft( entity player )
{
    if ( file.offset[player] - 4 >= 0 )
        file.offset[player] -= 3
    else
        file.offset[player] = file.offset.len() - 1
    
    OpenEntitySelect( player )
}

void function Button1Pressed( entity player )
{
    PerformCleenup( player, file.buttons_text[file.offset[player]] )
}
void function Button2Pressed( entity player )
{
    PerformCleenup( player, file.buttons_text[file.offset[player]+1] )
}
void function Button3Pressed( entity player )
{
    PerformCleenup( player, file.buttons_text[file.offset[player]+2] )
}
void function Button4Pressed( entity player )
{
    MoveMenuRight( player )
}

void function PerformCleenup( entity player, string npc )
{
    table<string,int> parms
    Spawn_Function( player, file.team_selected[player], 1, npc, parms )
}