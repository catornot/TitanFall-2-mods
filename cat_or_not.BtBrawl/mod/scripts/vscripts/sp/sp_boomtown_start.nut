const asset PANEL_MODEL = $"models/beacon/crane_room_monitor_console.mdl"


global function CodeCallback_MapInit

//WaterScreenEffect - flag when player is in water

void function CodeCallback_MapInit()
{
	if ( reloadingScripts )
		return

	AssemblyArmsInit()

	PrecacheModel( PANEL_MODEL )
	PrecacheModel( ARM_MODEL )
	PrecacheModel( ARM_MODEL_SMALL )

	PrecacheModel( "models/weapons/bullets/projectile_40mm.mdl" )

	Riff_ForceSetSpawnAsTitan( eSpawnAsTitan.Never )
	Riff_ForceTitanAvailability( eTitanAvailability.Never )

	// ShSpBoomtownStartCommonInit()

	// AddCallback_EntitiesDidLoad( Boomtown_EntitiesDidLoad )

	FlagInit( "DeleteIntroTurretsAndProwlers" )
	FlagInit( "PickupBT" )
	FlagInit( "IntroRadioResponseConversationDone" )
	//FlagInit( "HighSpeedDangerousArea" )

	// AddDeathCallback( "player", Boomtown_HandleSpecialDeathSounds )
	// AddDeathCallback( "npc_titan", Boomtown_HandleSpecialDeathSounds )

	AddStartPoint( "Intro",				STARTHELEVEL, null, null )
	AddStartPoint( "Prop House",		STARTHELEVEL, null, null )
	AddStartPoint( "Narrow Hallway", 	STARTHELEVEL, null, null )
	AddStartPoint( "Titan Arena", 		STARTHELEVEL, null, null )
	AddStartPoint( "Loading Dock", 		STARTHELEVEL, null, null )

	array<vector> origins = [ <398.467, -5242.31, 6996.27>, <1707.52, -5956.44, 7040.03>, <1445.25, -4909.27, 7040.03>, <3298.65, -4190.32, 7040.03> ]

	foreach( vector origin in origins )
	{
		entity ref = CreateScriptRef( origin, < 0.0, 0.0, 0.0 > )
		ref.SetScriptName( "BrawlSpawnNode2" )
	}

	origins = [ <494.202, -1479.39, 7040.03>, <2069.28, -1495.16, 7040.03>, <3124.58, -1540.45, 7040.03>, <2492.4, -2275.97, 7040.03>, <2054.55, -1001.91, 7040.03> ]

	foreach( vector origin in origins )
	{
		entity ref = CreateScriptRef( origin, < 0.0, 0.0, 0.0 > )
		ref.SetScriptName( "BrawlSpawnNode3" )
	}
}

void function STARTHELEVEL( entity player )
{
	// wait 3
	// thread PutPlayerOnSpawnPoint( player )
}