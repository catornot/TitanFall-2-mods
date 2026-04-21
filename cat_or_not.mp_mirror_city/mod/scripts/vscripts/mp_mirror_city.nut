global function CodeCallback_MapInit

struct {
    float max = 0.0
    float mid_max = 0.0
    float min = 0.0
    float mid_min = 0.0
    entity ref
} file

void function CodeCallback_MapInit()
{
    SetConVarInt( "Flipside", 1 )

    ClassicMP_SetLevelIntro( ClassicMP_DefaultNoIntro_Setup, ClassicMP_DefaultNoIntro_GetLength() )
	
	FastballAddBuddySpawnForLevel( "mp_mirror_city", TEAM_IMC, <1011, -1519, 4096>, <0,125,0> )
	FastballAddBuddySpawnForLevel( "mp_mirror_city", TEAM_MILITIA, < -466, 981, 4096 >, <0,-60,0> )
	FastballAddPanelSpawnsForLevel( "mp_mirror_city", [
		< 1983, 2064, 3072 >, <0,90,0>,
		< -2064, -1282, -2559 >, <0,180,0>,
		< 1919, -2080, 4096 >, < 0, -90, 0 >
	])

    AddSpawnCallbackEditorClass( "script_ref", "top_kill_zone_point", SetMaxDeathZone )
    AddSpawnCallbackEditorClass( "script_ref", "bottom_kill_zone_point", SetMinDeathZone )
    AddCallback_EntitiesDidLoad( CheckforDeathZoneInterception )


    AddClientCommandCallback( "proto_swap", PROTO_Swap )
    AddCallback_OnPlayerRespawned( MoveToSpawnPointStart )
}

void function SetMaxDeathZone( entity ref )
{
    file.max = ref.GetOrigin().z
    file.mid_max = ref.GetOrigin().z / 2
}

void function SetMinDeathZone( entity ref )
{
    file.min = ref.GetOrigin().z
    file.mid_min = ref.GetOrigin().z / 2
}

void function CheckforDeathZoneInterception()
{
    thread CheckforDeathZoneInterceptionThread()
}

void function CheckforDeathZoneInterceptionThread()
{
    for(;;)
    {
        foreach( entity player in GetPlayerArray() )
        {
            float z = player.GetOrigin().z
            if ( IsValid( player ) && IsAlive( player ) && z > file.min && z < file.max )
            {
                if ( z < file.mid_max && z > file.mid_min )
                {
                    player.SetVelocity( <0,0,2000> )
                    player.Die()
                }
                else
                    player.TakeDamage( 5, file.ref, file.ref, eDamageSourceId.fall )
            }
        }
        wait 0
    }
}

bool function PROTO_Swap( entity player, array<string> args )
{
    const float EFFECT_DURATION_TOTAL = 0.5
    const float EFFECT_DURATION_EASE_OUT = 0.5
    StatusEffect_AddTimed( player, eStatusEffect.timeshift_visual_effect, 1.0, EFFECT_DURATION_TOTAL, EFFECT_DURATION_EASE_OUT )
    EmitSoundOnEntity( player, "Timeshift_Scr_DeviceShift2Present" )

    TraceResults results = TraceLine( player.GetOrigin() + Vector( 0, 0, 32 ), player.GetOrigin() + Vector( 0, 0, -200 ), [ player ], TRACE_MASK_NPCSOLID_BRUSHONLY | TRACE_MASK_WATER, TRACE_COLLISION_GROUP_NONE )
	if ( !results.startSolid && !results.allSolid )
		PlayImpactFXTable( FlipPos( results.endPos, player.IsTitan() ), player, "timeshift_impact" )

    player.SetOrigin( FlipPos( player.GetOrigin(), player.IsTitan() ) )
    return true
}

vector function FlipPos( vector origin, bool istitan = false )
{
    int offset = istitan ? 500 : 100
    return <origin.x,origin.y,-origin.z-offset>
}

void function MoveToSpawnPointStart( entity player )
{
    if ( GetGameState() == eGameState.Prematch )
    {
        entity spawn = FindSpawnPoint( player, player.IsTitan(), false )
        player.SetOrigin( spawn.GetOrigin() )
        player.SetAngles( spawn.GetAngles() )
    }
}