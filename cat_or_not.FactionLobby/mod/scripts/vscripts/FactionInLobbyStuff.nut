untyped
global function Init_MylobbyStuff

const vector startAng = <0,-90,0>


const array< asset > Models = 
[
    $"models/humans/heroes/mlt_hero_sarah.mdl", 
    $"models/humans/heroes/imc_hero_blisk.mdl", 
    $"models/humans/heroes/imc_hero_ash.mdl", 
    $"models/humans/heroes/mlt_hero_barker.mdl", 
    $"models/humans/pilots/sp_medium_geist_f.mdl", 
    $"models/humans/heroes/imc_hero_marder.mdl", 
    $"models/robots/marvin/marvin.mdl",
    $"models/robots/marvin/marvin.mdl"
]

const array< string > Anims = 
[
    "Sarah_menu_pose",
    "Blisk_menu_pose_alt", //  pt_blisk_taunt_scene_blisk
    "Ash_menu_pose_alt",
    "Barker_menu_pose",
    "Gates_menu_pose",
    "Marder_menu_pose",
    "commander_MP_flyin_marvin_idle",
    "commander_MP_flyin_marvin_highfive" // "commander_MP_flyin_marvin_freestyle"
]  

void function Init_MylobbyStuff()
{
    ServerCommand("exec autoexec_faction_lobby")

    AddCallback_EntitiesDidLoad( StartFactionDisplay )   
}


void function StartFactionDisplay()
{
    if ( !IsLobby() )
        return
    
    thread FactionDisplay()
}

void function FactionDisplay()
{
    if ( !(GetConVarInt( "ModelID" ) < Anims.len() && GetConVarInt( "ModelID" ) < Models.len()) )
        return
    // if statment because Assert wouldn't work >:(

    asset model = Models[ GetConVarInt( "ModelID" ) ]
    string anim = Anims[ GetConVarInt( "ModelID" ) ]
    int speed = GetConVarInt( "SpinSpeed" )
    vector startPos = MyStringToVector( GetConVarString( "PropstartPostion" ) )

    entity spin_prop = CreatePropDynamic( model, startPos, startAng )

    if ( model == $"models/robots/marvin/marvin.mdl" )
    {
        spin_prop.SetSkin( 1 )
    }
    
    spin_prop.Anim_Play( anim )

    for(;;)
    {
        spin_prop.SetAngles( spin_prop.GetAngles() + <0,speed,0> )
        WaitFrame()
    }
}

vector function MyStringToVector( string strVector )
{
    array<string> VecArray = split( strVector, "," )
    return Vector( VecArray[0].tointeger(), VecArray[1].tointeger(), VecArray[2].tointeger() )
}
