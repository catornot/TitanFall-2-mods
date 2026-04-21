global function GamemodeSpeedball_Init

struct {
	entity flagBase
	entity flag
	entity flagCarrier
	entity IMC_Holo_Master
	entity Militia_Holo_Master
	entity ref
} file

void function GamemodeSpeedball_Init()
{
	PrecacheModel( CTF_FLAG_MODEL )
	PrecacheModel( CTF_FLAG_BASE_MODEL )

	// gamemode settings
	SetRoundBased( true )
	SetRespawnsEnabled( false )
	SetShouldUseRoundWinningKillReplay( true )
	Riff_ForceTitanAvailability( eTitanAvailability.Never )
	Riff_ForceSetEliminationMode( eEliminationMode.Pilots )
	ScoreEvent_SetupEarnMeterValuesForMixedModes()
	
	AddSpawnCallbackEditorClass( "script_ref", "info_speedball_flag", CreateFlag )
	
	AddCallback_GameStateEnter( eGameState.Prematch, CreateFlagIfNoFlagSpawnpoint )
	AddCallback_GameStateEnter( eGameState.Playing, ResetFlag )
	AddCallback_GameStateEnter( eGameState.WinnerDetermined,GamemodeSpeedball_OnWinnerDetermined)
	AddCallback_GameStateEnter( 7, RemoveMasters )
	AddCallback_GameStateEnter( 4, GiveHolo )
	AddCallback_GameStateEnter( 4, SpawnPlayerOnHolo )
	AddCallback_OnTouchHealthKit( "item_flag", OnFlagCollected )
	AddCallback_OnPlayerKilled( OnPlayerKilled )
	AddCallback_OnPlayerRespawned( handleRespawning )
	SetTimeoutWinnerDecisionFunc( TimeoutCheckFlagHolder )
	AddCallback_OnRoundEndCleanup ( ResetFlag )

	ClassicMP_SetCustomIntro( ClassicMP_DefaultNoIntro_Setup, ClassicMP_DefaultNoIntro_GetLength() )
	ClassicMP_ForceDisableEpilogue( true )
}

void function CreateFlag( entity flagSpawn )
{ 
	entity flagBase = CreatePropDynamic( CTF_FLAG_BASE_MODEL, flagSpawn.GetOrigin(), flagSpawn.GetAngles() )
	
	entity flag = CreateEntity( "item_flag" )
	flag.SetValueForModelKey( CTF_FLAG_MODEL )
	flag.MarkAsNonMovingAttachment()
	DispatchSpawn( flag )
	flag.SetModel( CTF_FLAG_MODEL )
	flag.SetOrigin( flagBase.GetOrigin() + < 0, 0, flagBase.GetBoundingMaxs().z + 1 > )
	flag.SetVelocity( < 0, 0, 1 > )

	flag.Minimap_AlwaysShow( TEAM_IMC, null )
	flag.Minimap_AlwaysShow( TEAM_MILITIA, null )
	flag.Minimap_SetAlignUpright( true )

	file.flag = flag
	file.flagBase = flagBase

	file.IMC_Holo_Master = file.ref
	file.Militia_Holo_Master = file.ref
}	

bool function OnFlagCollected( entity player, entity flag )
{
	if ( !IsAlive( player ) || flag.GetParent() != null || player.IsTitan() || player.IsPhaseShifted() ) 
		return false
		
	GiveFlag( player )
	return false // so flag ent doesn't despawn
}

void function OnPlayerKilled( entity victim, entity attacker, var damageInfo )
{
	if ( file.flagCarrier == victim )
		DropFlag()
		
	if ( victim.IsPlayer() && GetGameState() == eGameState.Playing )
		if ( GetPlayerArrayOfTeam_Alive( victim.GetTeam() ).len() == 1 )
			foreach ( entity player in GetPlayerArray() )
				Remote_CallFunction_NonReplay( player, "ServerCallback_SPEEDBALL_LastPlayer", player.GetTeam() != victim.GetTeam() )
}

void function GiveFlag( entity player )
{
	file.flag.SetParent( player, "FLAG" )
	file.flagCarrier = player
	SetTeam( file.flag, player.GetTeam() )
	SetGlobalNetEnt( "flagCarrier", player )
	thread DropFlagIfPhased( player )
	
	EmitSoundOnEntityOnlyToPlayer( player, player, "UI_CTF_1P_GrabFlag" )
	foreach ( entity otherPlayer in GetPlayerArray() )
	{
		MessageToPlayer( otherPlayer, eEventNotifications.SPEEDBALL_FlagPickedUp, player )
		
		if ( otherPlayer.GetTeam() == player.GetTeam() )
			EmitSoundOnEntityToTeamExceptPlayer( file.flag, "UI_CTF_3P_TeamGrabFlag", player.GetTeam(), player )
	}
}

void function DropFlagIfPhased( entity player )
{
	player.EndSignal( "StartPhaseShift" )
	player.EndSignal( "OnDestroy" )
	
	OnThreadEnd( function() : ( player ) 
	{
		if ( file.flag.GetParent() == player )
			DropFlag()
	})
	
	while( file.flag.GetParent() == player )
		WaitFrame()
}

void function DropFlag()
{
	file.flag.ClearParent()
	file.flag.SetAngles( < 0, 0, 0 > )
	SetTeam( file.flag, TEAM_UNASSIGNED )
	SetGlobalNetEnt( "flagCarrier", file.flag )
	
	if ( IsValid( file.flagCarrier ) )
		EmitSoundOnEntityOnlyToPlayer( file.flagCarrier, file.flagCarrier, "UI_CTF_1P_FlagDrop" )
	
	foreach ( entity player in GetPlayerArray() )
		MessageToPlayer( player, eEventNotifications.SPEEDBALL_FlagDropped, file.flagCarrier )
	
	file.flagCarrier = null
}

void function CreateFlagIfNoFlagSpawnpoint()
{
	if ( IsValid( file.flag ) )
		return
	
	foreach ( entity hardpoint in GetEntArrayByClass_Expensive( "info_hardpoint" ) )
	{
		if ( GetHardpointGroup(hardpoint) == "B" )
		{
			CreateFlag( hardpoint )
			return
		}
	}
}

void function ResetFlag()
{
	file.flag.ClearParent()
	file.flag.SetAngles( < 0, 0, 0 > )
	file.flag.SetVelocity( < 0, 0, 1 > ) // hack: for some reason flag won't have gravity if i don't do this
	file.flag.SetOrigin( file.flagBase.GetOrigin() + < 0, 0, file.flagBase.GetBoundingMaxs().z * 2 > )
	SetTeam( file.flag, TEAM_UNASSIGNED )
	file.flagCarrier = null
	SetGlobalNetEnt( "flagCarrier", file.flag )
}

int function TimeoutCheckFlagHolder()
{
	if ( file.flagCarrier == null )
		return TEAM_UNASSIGNED
		
	return file.flagCarrier.GetTeam()
}

void function GamemodeSpeedball_OnWinnerDetermined()
{
	if(IsValid(file.flagCarrier))
		file.flagCarrier.AddToPlayerGameStat( PGS_ASSAULT_SCORE, 1 )
}

string function GetHardpointGroup(entity hardpoint) //Hardpoint Entity B on Homestead is missing the Hardpoint Group KeyValue
{
	if((GetMapName()=="mp_homestead")&&(!hardpoint.HasKey("hardpointGroup")))
		return "B"

	return string(hardpoint.kv.hardpointGroup)
}

void function handleRespawning( entity player )
{
	if ( GetGameState() != 3 )
		return
	
	thread handleRespawningThreaded( player )
}

void function handleRespawningThreaded( entity player )
{
	EndSignal( player, "OnDestroy" )
	
	wait RandomFloat( 1.0 )

	switch( player.GetTeam() )
	{
		case TEAM_IMC:
			if ( IsValid( player ) && file.IMC_Holo_Master == file.ref )
				file.IMC_Holo_Master = player
			else if ( IsValid( player ) )
				thread DieOnMatchStart( player )
			break
		case TEAM_MILITIA:
			if ( IsValid( player ) && file.Militia_Holo_Master == file.ref  )
				file.Militia_Holo_Master = player
			else if ( IsValid( player ) )
				thread DieOnMatchStart( player )
			break
	}
}

void function DieOnMatchStart( entity player )
{
	EndSignal( player, "OnDestroy" )
	EndSignal( player, "OnDeath" )

	while( GetGameState() == 3 )
		WaitFrame()
	
	player.Die()
}

void function RemoveMasters()
{
	file.IMC_Holo_Master = file.ref
	file.Militia_Holo_Master = file.ref
}

void function GiveHolo()
{
	if ( file.IMC_Holo_Master != file.ref && IsValid( file.IMC_Holo_Master ) && IsAlive( file.IMC_Holo_Master ) )
	{
		file.IMC_Holo_Master.TakeOffhandWeapon( OFFHAND_SPECIAL )
		file.IMC_Holo_Master.GiveOffhandWeapon( "mp_ability_holopilot", OFFHAND_SPECIAL, [ "pas_power_cell" ] )
	}

	if ( file.Militia_Holo_Master != file.ref && IsValid( file.Militia_Holo_Master ) && IsAlive( file.Militia_Holo_Master ) )
	{
		file.Militia_Holo_Master.TakeOffhandWeapon( OFFHAND_SPECIAL )
		file.Militia_Holo_Master.GiveOffhandWeapon( "mp_ability_holopilot", OFFHAND_SPECIAL, [ "pas_power_cell" ] )
	}
}

void function SpawnPlayerOnHolo()
{
	entity holo
	while( GetGameState() == 4 )
	{
		holo = GetEnt( "player_decoy" )
		#if HOLOMIMIC
			holo = GetEnt( "npc_pilot_elite" )
		#endif
		if ( IsValid( holo ) && IsAlive( holo) )
		{
			SpawnPlayerOnHolo2( holo )
		}
		WaitFrame()
	}
}
void function SpawnPlayerOnHolo2( entity holo )
{
	foreach( entity player in GetPlayerArray() )
	{
		printt( "teams", player.GetTeam() == holo.GetTeam() )
		printt( "team holo", holo.GetTeam() )
		printt( "team player", player.GetTeam() )
		if ( player.GetTeam() == holo.GetTeam() && !IsAlive( player ) && IsValid( player ) )
		{
			Chat_ServerBroadcast( player.GetPlayerName() + " respawned" )
			DoRespawnPlayer( player, null )
			player.SetOrigin( holo.GetOrigin() )
			player.SetAngles( holo.GetAngles() )
			player.TakeOffhandWeapon( OFFHAND_SPECIAL )
			holo.Die()
			return
		}
	}
}