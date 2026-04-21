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
    $"models/robots/marvin/marvin.mdl", 
    $"models/weapons/hemlock_br/w_hemlock_br.mdl", // weapons
    $"models/weapons/hemlok_smg/w_hemlok_smg.mdl",
    $"models/weapons/at_rifle/w_at_rifle.mdl",
    $"models/weapons/vinson/w_vinson.mdl",
    $"models/weapons/wingman_elite/w_wingman_elite.mdl",
    $"models/weapons/r97/w_r97.mdl",
    $"models/weapons/r101_sfp/w_r101_sfp_stow.mdl",
    $"models/weapons_r2/burn_card/burn_card.mdl"
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
    "commander_MP_flyin_marvin_highfive", // "commander_MP_flyin_marvin_freestyle"
    "",
    "",
    "",
    "",
    "",
    "",
    "",
    ""
]  

void function Init_MylobbyStuff()
{
    AddCallback_EntitiesDidLoad( StartFactionDisplay )   
}


void function StartFactionDisplay()
{
    GetLocalViewPlayer().ClientCommand( "exec autoexec_faction_lobby" )
    
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
    vector SpinSpeed = <0,0,0>
    SpinSpeed.x = GetConVarInt( "SpinSpeedX" ).tofloat()
    SpinSpeed.y = GetConVarInt( "SpinSpeedY" ).tofloat()
    SpinSpeed.z = GetConVarInt( "SpinSpeedZ" ).tofloat()
    SpinSpeed.Norm()
    SpinSpeed = GetConVarInt( "SpeedMultiplier" ) * SpinSpeed
    // Warning( SpinSpeed.tostring() )
    vector startPos = MyStringToVector( GetConVarString( "PropstartPostion" ) )

    entity spin_prop = CreateClientsideScriptMover( model, startPos, startAng )

    if ( model == $"models/robots/marvin/marvin.mdl" )
    {
        spin_prop.SetSkin( 1 )
    }
    else if ( model == $"models/weapons_r2/burn_card/burn_card.mdl" )
    {
        spin_prop.SetSkin( 1 )
        spin_prop.kv.modelscale = 5
    }

    if ( anim != "" )
        spin_prop.Anim_Play( anim )

    // GameRules_ChangeMap( "mp_s2s" , "fastball" )

    for(;;)
    {
        spin_prop.SetAngles( spin_prop.GetAngles() + SpinSpeed )
        WaitFrame()
    }
}

vector function MyStringToVector( string strVector )
{
    array<string> VecArray = split( strVector, "," )
    return Vector( VecArray[0].tointeger(), VecArray[1].tointeger(), VecArray[2].tointeger() )
}
