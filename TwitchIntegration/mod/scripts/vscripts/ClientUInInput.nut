global function ClientInit

struct{
    var rui = null 
} file

void function ClientInit()
{
    var topology = RuiTopology_CreateSphere( COCKPIT_RUI_OFFSET_1610_TEMP, <0, -1, 0>, <0, 0, -1>, COCKPIT_RUI_RADIUS, COCKPIT_RUI_WIDTH, COCKPIT_RUI_HEIGHT, COCKPIT_RUI_SUBDIV )

    file.rui = RuiCreate($"ui/cockpit_console_text_top_right.rpak", topology, RUI_DRAW_COCKPIT, 0)

    // AddClientCommandCallback("SetText", SetTextCommand)
    // AddClientCommandCallback("ResetText", SetTextCommand)

    thread RuiSetup()
    thread ButtonsInit()
}

void function ButtonsInit(){
    WaitFrame()
    RegisterButtonPressedCallback(KEY_P, P_pressed)
    RegisterButtonPressedCallback(KEY_L, L_pressed)
    RegisterButtonPressedCallback(KEY_M, M_pressed)
    RegisterButtonPressedCallback(KEY_O, O_pressed)
}

void function P_pressed( entity player){
    GetPlayerArray()
}
void function L_pressed( entity player){
    GetPlayerArray()
}
void function M_pressed( entity player){
    GetLocalClientPlayer().ClientCommand( GetConVarString("AddGToCodon") )
}
void function O_pressed( entity player ){
    GetLocalClientPlayer().ClientCommand( GetConVarString("AddGToCodon") )
}

// if nuclei == "A":
//     nuclei = "p"
// elif nuclei == "U":
//     nuclei = "l"
// elif nuclei == "G":
//     nuclei = "O"
// elif nuclei == "C":
//     nuclei = "M"
// else:

// void function SetTextCommand(entity player, array<string> args)
// {
//     print("SetText: was kalled with " + args)
//     RuiSetString(rui, "msgText", format( "%s %s", "Next Event :", args[0] ) ) 
// }
// void function ResetTextCommand(entity player, array<string> args)
// {
//     print("ResetText: was kalled with " + args)
//     RuiSetString(rui, "msgText", format( "%s %s", "Next Event : Waiting" ) )
// }


void function RuiSetup()
{
    while(IsLobby() && IsMenuLevel()){
        wait( 1 )
	}

    RuiSetInt(file.rui, "lineNum", 1)
    RuiSetFloat2(file.rui, "msgPos", <0.8, 0.16, 0.0>)
    RuiSetString(file.rui, "msgText", "Next Event : Waiting")
    RuiSetFloat(file.rui, "msgFontSize", 25)
    RuiSetFloat(file.rui, "msgAlpha", 0.5)
    RuiSetFloat(file.rui, "thicken", 1.0)
    RuiSetFloat3(file.rui, "msgColor", <1.0, 1.0, 1.0> )
}

void function RuiRun()
{
    while( !IsLobby() && !IsMenuLevel() )
    {
    }
    // for(;;)
    // {
    //     foreach( entity prop in GetEnt( "prop_dynamic" ) )
    //     {
    //         if ( prop.GetTargetName() == "E")
    //             RuiSetString(file.rui, "msgText", "Next Event : E" )
    //     }
    //     WaitFrame()
    // }
}

//trigger_hurt