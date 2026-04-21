global function CodeCallback_MapInit

const ARC_TOOL_VIEW_MODEL = $"models/weapons/arc_tool_sp/v_arc_tool_sp.mdl"

struct
{
	entity player
	entity arcToolMarvin
	array<entity> logRollRoomEnemies
	int fanWallrunDeathCount
} file

void function CodeCallback_MapInit()
{
	// ShSpBeaconSpoke0CommonInit()
	// SPBeaconGlobals()
	// AddCallback_EntitiesDidLoad( EntitiesDidLoad )
	//DronePlatform_Init()

	FlagInit( "Fan1Enabled", true )
	FlagInit( "DisableSkitGruntBanter" )

	PrecacheModel( ARC_TOOL_VIEW_MODEL )
	PrecacheModel( ARC_TOOL_GHOST_WORLD_MODEL )
	PrecacheModel( $"models/titans/buddy/titan_buddy.mdl" )
	PrecacheParticleSystem( CHARGE_BEAM_GHOST_EFFECT )

	RegisterSignal( "AssemblyAdvance" )
	RegisterSignal( "StopAssemblyLineThink" )
	RegisterSignal( "MarvinStopWorkingArcTool" )
	RegisterSignal( "wallrun_start" )
	RegisterSignal( "wallrun_end" )
	RegisterSignal( "wind_tunnel_blend_out" )
	RegisterSignal( "marvin_shot_switch" )
	RegisterSignal( "doorknock" )
	RegisterSignal( "marvin_lose_arc_tool" )
	RegisterSignal( "attach_arc_tool" )
	RegisterSignal( "RestorePlayerFriction" )

	AddStartPoint( "Level Start", 				STARTHELEVEL, null, null )
	AddStartPoint( "First Fight", 				STARTHELEVEL, null, null )
	AddStartPoint( "Get Arc Tool", 				STARTHELEVEL, null, null )
	AddStartPoint( "Got Arc Tool", 				STARTHELEVEL, null, null )
	AddStartPoint( "Horizontal Fan", 			STARTHELEVEL, null, null )
	AddStartPoint( "Horizontal Fan Complete", 	STARTHELEVEL, null, null )
	AddStartPoint( "Fan Wallrun", 				STARTHELEVEL, null, null )

	// FlagSet( "FriendlyFireStrict" )

	Riff_ForceSetSpawnAsTitan( eSpawnAsTitan.Never )
	Riff_ForceTitanAvailability( eTitanAvailability.Never )

	array<vector> origins = [ <7400.72, -6027.4, -399.955>, <8991, -5016.79, -393.646>, <5403.64, -6113.4, -8.38532>, <6263.83, -7558.6, -399.969>, <6618.6, -4602.26, -318.767> ]

	foreach( vector origin in origins )
	{
		entity ref = CreateScriptRef( origin, < 0.0, 0.0, 0.0 > )
		ref.SetScriptName( "BrawlSpawnNode2" )
	}

	origins = [ <8627.94, -411.029, -398.967>, <8542.28, 1759.24, -399.969>, <6652.8, 188.732, -208.17>,  <9625.52, -541.99, -399.825> ]

	foreach( vector origin in origins )
	{
		entity ref = CreateScriptRef( origin, < 0.0, 0.0, 0.0 > )
		ref.SetScriptName( "BrawlSpawnNode3" )
	}
}

void function STARTHELEVEL( entity player )
{
	thread PutPlayerOnSpawnPoint( player )
}

