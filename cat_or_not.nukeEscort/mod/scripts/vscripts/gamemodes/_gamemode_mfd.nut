global function GamemodeMfd_Init
global function nukehim
global function GetPos

struct {
	entity nukeTitan
	entity comms
	entity rings
	table< string,array<vector> > SpawnLocationForMap
	table< string,array<vector> > CheckpointsForMap
	int current_checkpoint = 0
	bool reached_final_checkpoint = false
} file

void function GamemodeMfd_Init()
{
	Riff_ForceTitanAvailability( eTitanAvailability.Never )

	AddCallback_OnPlayerKilled( GiveScoreForPlayerKill )
	AddDeathCallback( "npc_titan", HededMaybe )
	AddDamageCallback( "npc_titan", HeddoomedMaybe )

	AddCallback_GameStateEnter( eGameState.Playing, StartGamemode )

	PrecacheModel( $"models/robots/mobile_hardpoint/mobile_hardpoint.mdl" )
	PrecacheModel( $"models/communication/terminal_com_station_tall.mdl" )
	// PrecacheModel($"models/props/generator_coop/generator_coop_rings_animated.mdl")

	file.SpawnLocationForMap["mp_box"] <- [ < -5083.19, 3617.83, 0.03125>, < -4070.36, -2836.09, 0.03125> ]
	file.CheckpointsForMap["mp_box"] <-[ < -2009.26, 3458.51, 0.03125>, < -5510.28, 219.015, 0.03125>, file.SpawnLocationForMap["mp_box"][1] ]
	file.SpawnLocationForMap["mp_colony02"] <- [ < -1248.18, -1308.96, 182.657>, <459.988, 3938.46, -30.933> ]
	file.CheckpointsForMap["mp_colony02"] <-[ < -6.55323, 565.952, 29.5333>, <1047.72, 3735.33, -4.69682>, file.SpawnLocationForMap["mp_colony02"][1] ]
}

void function GiveScoreForPlayerKill( entity victim, entity attacker, var damageInfo )
{
	if ( !( victim.IsPlayer() && attacker.IsPlayer() ) )
		return

	if ( victim != attacker || GetGameState() == eGameState.Playing )
		attacker.AddToPlayerGameStat( PGS_PILOT_KILLS, 1)
}

void function StartGamemode()
{
	// spawn locations
	vector TitanspawnPosition = <0,0,1>
	vector CommspawnPosition = <0,100,1>

	if ( GetMapName() in file.SpawnLocationForMap )
		TitanspawnPosition = file.SpawnLocationForMap[ GetMapName() ][0]
	
	if ( GetMapName() in file.SpawnLocationForMap )
		CommspawnPosition = file.SpawnLocationForMap[ GetMapName() ][1]
	
	// First we need to spawn the nuke titan

	file.nukeTitan = CreateNPCTitan( "npc_titan_ogre", TEAM_MILITIA, TitanspawnPosition, <0,0,0>, [] ) // why do I need []
	SetSpawnOption_NPCTitan( file.nukeTitan, TITAN_HENCH )
	SetSpawnOption_AISettings( file.nukeTitan, "npc_titan_ogre_minigun_nuke" )
    SetSpawnOption_Warpfall( file.nukeTitan )
	DispatchSpawn( file.nukeTitan )

	NPC_SetNuclearPayload( file.nukeTitan )
	SetTeam( file.nukeTitan, TEAM_MILITIA )
	
	Highlight_SetFriendlyHighlight( file.nukeTitan, "hunted_friendly" )
	Highlight_SetEnemyHighlight( file.nukeTitan ,"hunted_enemy" )
	
	thread NukeTianThink()

	// then we spawn a target
	
	file.comms = CreateEntity( "prop_dynamic" )
    file.comms.SetValueForModelKey( $"models/props/generator_coop/generator_coop.mdl" )
    file.comms.SetAngles( <0,0,0> )
    file.comms.SetOrigin( CommspawnPosition )
    file.comms.kv.solid = SOLID_VPHYSICS
	// file.comms.kv.modelscale = 2
    SetTeam( file.comms, TEAM_IMC )
    DispatchSpawn( file.comms )

	file.rings = CreateEntity( "prop_dynamic" )
    file.rings.SetValueForModelKey( $"models/props/generator_coop/generator_coop_rings_animated.mdl" )
    file.rings.SetAngles( <0,0,0> )
    file.rings.SetOrigin( CommspawnPosition )
    file.rings.kv.solid = SOLID_VPHYSICS
	// file.rings.kv.modelscale = 2
    SetTeam( file.rings, TEAM_IMC )
    DispatchSpawn( file.rings )
	file.rings.SetParent( file.comms )
	file.rings.Anim_Play( "generator_cycle_fast" )

}

void function NukeTianThink()
{
	bool mapInTable = false
	if ( GetMapName() in file.CheckpointsForMap )
		mapInTable = true
	try
	{

	for(;;)
	{
		if ( !mapInTable || file.current_checkpoint == file.CheckpointsForMap[ GetMapName() ].len() )
		{
			nukehim() // fix this
			if ( file.current_checkpoint == file.CheckpointsForMap[ GetMapName() ].len() )
			{
				file.reached_final_checkpoint = true
				PlayImpactFXTable( file.comms.GetOrigin(), file.comms, "titan_exp_ground" )
				EmitSoundOnEntity( file.comms, "diag_spectre_gs_LeechAborted_01_1" )
				file.rings.Anim_Play( "generator_rise" )
			}
			break
		}
		
		vector target = <0,0,0>

		if ( mapInTable )
			target = file.CheckpointsForMap[ GetMapName() ][file.current_checkpoint]
			
		file.nukeTitan.AssaultPoint( target )
		file.nukeTitan.AssaultSetGoalRadius( file.nukeTitan.GetMinGoalRadius() * 2 )

		WaitSignal( file.nukeTitan, "OnFinishedAssault", "OnEnterGoalRadius" )

		file.current_checkpoint += 1
	}

	}
	catch( exception )
	{
		print("he probably ded")
	}
}

void function HededMaybe( entity npc, var damageInfo )
{
	if ( npc != file.nukeTitan )
		return
	
	if ( file.reached_final_checkpoint )
	{
		SetWinner( TEAM_MILITIA )
		AddTeamScore( TEAM_MILITIA, 100 )
	}
	else
	{
		SetWinner( TEAM_IMC )
		AddTeamScore( TEAM_IMC, 100 )
	}
	
	SetRoundWinningKillReplayAttacker( file.nukeTitan )
}

void function HeddoomedMaybe( entity npc, var damageInfo )
{
	if ( npc != file.nukeTitan )
		return
	
	print( GetDoomedState( npc ) )

	if ( GetDoomedState( npc ) )
		nukehim()
}


void function nukehim()
{
	if ( IsValid( file.nukeTitan ) )
		thread AutoTitan_SelfDestruct( file.nukeTitan )
}

// sv_cheats 1 ;script foreach(entity player in GetPlayerArray()){ AutoTitan_SelfDestruct( player )}

void function GetPos()
{
	printl( GetPlayerArray()[0].GetOrigin() )
}

// might be usuful
// player.SetPlayerGameStat( PGS_ELIMINATED, 1 )
// PGS_DEFENSE_SCORE will be used to track the amount of time a player is defeding/attacking the tian 