global function ClientInit

int nucleoA_KEY = KEY_F4
int nucleoT_KEY = KEY_F5
int nucleoG_KEY = KEY_F6
int nucleoC_KEY = KEY_F7

struct{
    var rui = null
    string DNA_send_command = "SENDDNA"
    array<string> DNA = []
    array<string> codon = []
} file

void function ClientInit()
{
    var topology = RuiTopology_CreateSphere( COCKPIT_RUI_OFFSET_1610_TEMP, <0, -1, 0>, <0, 0, -1>, COCKPIT_RUI_RADIUS, COCKPIT_RUI_WIDTH, COCKPIT_RUI_HEIGHT, COCKPIT_RUI_SUBDIV )

    file.rui = RuiCreate($"ui/cockpit_console_text_top_right.rpak", topology, RUI_DRAW_COCKPIT, 0)

    AddServerToClientStringCommandCallback("SetText", SetTextCommand)
    AddServerToClientStringCommandCallback("ResetText", ResetTextCommand)

    AddServerToClientStringCommandCallback("SetCommands", SetCommands)

    thread RuiSetup()
    ButtonsInit()

    thread SendClientAlert()
}

void function SendClientAlert()
{
    wait 1
    GetLocalClientPlayer().ClientCommand( "IHaveRui0101" )
}

void function ButtonsInit(){
    RegisterButtonPressedCallback(nucleoA_KEY, pressedA)
    RegisterButtonPressedCallback(nucleoT_KEY, pressedT)
    RegisterButtonPressedCallback(nucleoG_KEY, pressedG)
    RegisterButtonPressedCallback(nucleoC_KEY, pressedC)
}

void function pressedA( entity player){
    AddNucleotideToDNA("A")
}
void function pressedT( entity player){
    AddNucleotideToDNA("T")
}
void function pressedG( entity player){
    AddNucleotideToDNA("G")
}
void function pressedC( entity player ){
    AddNucleotideToDNA("C")
}

void function AddNucleotideToDNA(string nucleotide){
    file.codon.append( nucleotide )

    if ( ArrayToString( file.codon ) + nucleotide == "GGG" ) // GGG is end codon so it should never be added by code so we have 63 char instead of 64
    {
        GetLocalClientPlayer().ClientCommand( format( "%s %s", file.DNA_send_command, ArrayToString( file.DNA ) ) )
        file.DNA.clear()
        return
    }

    if ( file.codon.len() == 3 ){
        file.DNA.append( ArrayToString( file.codon ) )
        Chat_GameWriteLine( ArrayToString( file.codon ) )
        file.codon.clear()
    }
}

void function SetCommands( array<string> args )
{
    // it goes A,U,G,C
    if ( args.len() >= 1 )
    {
        file.DNA_send_command = args[0]
    }
}

void function SetTextCommand( array<string> args )
{
    print( "SetText: was called with " + args[0] )
    RuiSetString( file.rui, "msgText", format( "%s %s", "Current Event :", ArrayToString( args, true ) ) ) 
}
void function ResetTextCommand( array<string> args )
{
    print( "ResetText: was called with " + args[0] )
    RuiSetString( file.rui, "msgText", format( "%s %s", "Current Event : Waiting" ) )
}


void function RuiSetup()
{
    while(IsLobby() && IsMenuLevel()){
        wait 1 
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