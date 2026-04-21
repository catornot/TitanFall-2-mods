global function GamemodeLts_Init

const array< array<string> > titan_combo =
[
	[ "npc_titan_auto_atlas", "npc_titan_auto_atlas_ion_prime" ],
	[ "npc_titan_auto_atlas", "npc_titan_auto_atlas_tone_prime" ],
	// [ "titan_stryder", "npc_titan_stryder_rocketeer" ],
	[ "npc_titan_auto_stryder", "npc_titan_auto_stryder_northstar_prime" ],
	[ "npc_titan_auto_stryder", "npc_titan_auto_stryder_northstar_prime" ],
	[ "npc_titan_auto_atlas", "npc_titan_auto_atlas_vanguard" ],
	[ "npc_titan_auto_ogre", "npc_titan_auto_ogre_scorch_prime" ],
	[ "npc_titan_auto_ogre", "npc_titan_auto_ogre_legion_prime" ]
]


struct
{
	entity mark
	entity soul
	int team
	table< string, vector > custom_spawnpoint
	entity signlEnt
	bool shouldHighlight = false
}
file

void function GamemodeLts_Init()
{
	RegisterSignal( "StopKillEveryone" )

	// SetScoreLimit( 5 )

	SetRoundBased( true )
	SetSwitchSidesBased( true )
	SetShouldUseRoundWinningKillReplay( true )
	SetRoundWinningKillReplayKillClasses( false, false )
	TrackTitanDamageInPlayerGameStat( PGS_KILLS )

	ClassicMP_ForceDisableEpilogue( true )
	SetTimeoutWinnerDecisionFunc( DecideWinner )

	AddCallback_GameStateEnter( eGameState.Playing, SpawnTitan )
	AddCallback_GameStateEnter( eGameState.Postmatch, KillEveryone )
	AddCallback_GameStateEnter( eGameState.WinnerDetermined, KillEveryone )
	AddCallback_OnRoundEndCleanup( Cleanup )

	AddCallback_OnNPCKilled( OnTitanDeath )
	AddCallback_OnPlayerKilled( OnPlayerKilled )

	ClassicMP_SetCustomIntro( ClassicMP_DefaultNoIntro_Setup, ClassicMP_DefaultNoIntro_GetLength() )

	file.custom_spawnpoint[ "mp_glitch" ] <- < -171, 93, -51 >
	file.custom_spawnpoint[ "mp_drydock" ] <- <226,81,403>
	file.custom_spawnpoint[ "mp_wargames" ] <- < -941, -821, -127 >

	file.signlEnt = CreateScriptMover()
}



void function AddTeamScoreForPlayerKilled( entity victim, entity attacker, var damageInfo )
{
	if ( victim == attacker || !victim.IsPlayer() || !attacker.IsPlayer() && GetGameState() == eGameState.Playing )
		return

	AddTeamScore( attacker.GetTeam(), 1 )
}

int function DecideWinner()
{
	if ( IsValid( file.soul ) && IsValid( file.soul.GetTitan() ) && IsAlive( file.soul.GetTitan() ) )
	{
		int team = file.soul.GetTitan().GetTeam()
		Cleanup()
		return team
	}

	if ( file.team == TEAM_UNASSIGNED )
		return file.team

	return GetOtherTeam( file.team )
}

void function SpawnTitan()
{
	Riff_ForceSetSpawnAsTitan( eSpawnAsTitan.Never )
	SetRespawnsEnabled( true )
	file.shouldHighlight = false
	file.signlEnt.Signal( "StopKillEveryone" )

	// print( "trying to drop a titan" )

	if ( GetPlayerArray().len() == 0 )
		return
	
	// print( "we have players" )

	vector pos = <0,0,0>
	foreach ( entity hardpoint in GetEntArrayByClass_Expensive( "info_hardpoint" ) )
	{
		if ( !hardpoint.HasKey( "hardpointGroup" ) )
			continue
			
		//if ( hardpoint.kv.hardpointGroup != "A" && hardpoint.kv.hardpointGroup != "B" && hardpoint.kv.hardpointGroup != "C" )
		if ( hardpoint.kv.hardpointGroup != "B" ) // roughly map center
			continue
			
		pos = hardpoint.GetOrigin()
	}

	entity spawnpoint = GetClosest( SpawnPoints_GetTitan(), pos )

	// print( "found good spawnpoint" )

	if ( !IsValid( spawnpoint ) )
	{
		ServerCommand( "map mp_lobby" )
		return
	}
	pos = spawnpoint.GetOrigin()

	if ( GetMapName() in file.custom_spawnpoint )
		pos = file.custom_spawnpoint[ GetMapName() ]

	Point SpawnPoint
	SpawnPoint.origin = pos
	SpawnPoint.angles = <0,0,0>

	entity player = GetPlayerArray().getrandom()

	// print( "found a player" )

	if ( !IsValid( player ) )
	{
		// print( "not valid player" )
		FastRoundRestart()
		return
	}

	thread CreateTitanForPlayerAndHotdrop( player, SpawnPoint )

	// print( "dropped a titan" )

	entity titan = player.GetPetTitan()

	if ( !IsValid( titan ) )
	{
		FastRoundRestart()
		return
	}

	file.signlEnt.Signal( "StopKillEveryone" )

	file.soul = titan.GetTitanSoul()

	titan.ClearBossPlayer()
	file.soul.ClearBossPlayer()
	player.SetPetTitan( null )
	
	SetTeam( titan, TEAM_UNASSIGNED )
	file.team = titan.GetTeam()

	titan.SetInvulnerable()
	Highlight_SetNeutralHighlight( titan, "enemy_boss_bounty" )
	titan.AssaultPoint( pos )

	// print( "titan is setup" )

	thread HandleTitanOwnerShip( titan )

	// print( "titan dropping" )
}

void function HandleTitanOwnerShip( entity titan )
{
	EndSignal( file.soul, "PlayerEmbarkedTitan" )
	EndSignal( titan, "OnDeath" )

	SetRoundEndTime( 120.0 )

	// print( "Handling ownership rn" )

	file.signlEnt.Signal( "StopKillEveryone" )

	OnThreadEnd(
	function() : ( titan )
		{
			file.signlEnt.Signal( "StopKillEveryone" )

			entity p = titan.GetBossPlayer()

			Highlight_SetEnemyHighlight( titan, "enemy_boss_bounty" )
			Highlight_SetNeutralHighlight( titan, "enemy_boss_bounty" )
			Highlight_SetOwnedHighlight( titan, "enemy_boss_bounty" )
			Highlight_SetFriendlyHighlight( titan, "enemy_boss_bounty" )
			file.team = titan.GetTeam()

			thread ConfirmOwnerShip()
			
			file.shouldHighlight = true
			thread HighlightUpdate( file.soul, p )
			
			Riff_ForceSetSpawnAsTitan( eSpawnAsTitan.Always )

			if ( !IsValid( p ) )
			{
				if ( IsAlive( titan ) )
					titan.Die()
				return
			}
			else
			{
				file.team = p.GetTeam()
				SetTeam( titan, p.GetTeam() )
				Disembark_Disallow( p )
				thread DealayedClearInvulnerable( p )
			}

			foreach( entity player in GetPlayerArray() )
			{
				
				if ( ( !player.IsTitan() && player != p && IsValid( player ) && IsAlive( player ) ) )
					thread DelayedTitanGiveAway( player )

				if ( player.GetTeam() == p.GetTeam() && IsValid( player ) )
					SendHudMessage( player, "Your Team Captured the Titan; Defend it!", -1, 0.2, 255, 255, 0, 0, 0.15, 20, 0.15 )
				else if ( IsValid( player ) )
					SendHudMessage( player, "Your Team Lost the Titan; Destroy it!", -1, 0.2, 255, 255, 0, 0, 0.15, 20, 0.15 )
			}

			SetRoundEndTime( 120.0 )
		}
	)

	for(;;)
	{
		if ( GetPlayerArray().len() == 0 )
		{
			// print( "no enough players waiting" )
			wait 1
			continue
		}

		entity player = GetClosest( GetPlayerArray(), titan.GetOrigin() )

		if ( DistanceSqr( player.GetOrigin(), titan.GetOrigin() ) >= 6000.0 )
		{
			// print( "not enough close enough" )
			WaitFrame()
			continue
		}

		// print( "setting ownership" )

		entity previousOwner = GetPetTitanOwner( titan )
		if ( IsValid( previousOwner ) )
			previousOwner.SetPetTitan( null )
		
		if ( IsPlayerEmbarking( player ) )
			return
		
		player.SetPetTitan( titan )
		titan.SetBossPlayer( player )

		WaitFrame()

		// print( "set ownership" )
	}
}

void function DealayedClearInvulnerable( entity player )
{
	EndSignal( player, "OnDeath" )
	while( !player.IsTitan() )
		WaitFrame()
	player.SetInvulnerable()
	wait 5
	player.ClearInvulnerable()
}

void function ConfirmOwnerShip()
{
	wait 1
	
	foreach( entity player in GetPlayerArray() )
	{
		if ( GetSoulFromPlayer( player ) == file.soul )
		{
			if ( IsValid( file.soul.GetTitan() ) && file.soul.GetTitan().GetBossPlayer() != player  )
			{
				entity titan = file.soul.GetTitan()
				
				print( "WARNING: ownership assigning functions failed at its job, ConfirmOwnerShip Is trying to fix it" )
				Chat_ServerBroadcast( "WARNING: ownership assigning functions failed at its job, ConfirmOwnerShip Is trying to fix it" )
				
				entity previousOwner = GetPetTitanOwner( titan )
				if ( IsValid( previousOwner ) )
					previousOwner.SetPetTitan( null )

				if (titan.IsNPC())
				{
					player.SetPetTitan( titan )
					titan.SetBossPlayer( player )
				}
			}
		}
		else
			print( "ownership assigning functions didn't failed at its job" )
		return
	}
}

void function HighlightUpdate( entity soul, entity player )
{
	soul.EndSignal( "OnDeath" )
	soul.EndSignal( "OnDestroy" )
	svGlobal.levelEnt.EndSignal( "RoundEnd" )
	file.signlEnt.EndSignal( "StopKillEveryone" )
	
	if ( !IsValid( player ) )
		return

	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )

	soul.EndSignal( "PlayerEmbarkedTitan" )
	soul.EndSignal( "PlayerDisembarkedTitan" )

	wait 2

	entity target = soul.GetTitan()
	if ( player.IsTitan() )
		target = player

	Highlight_SetEnemyHighlight( target, "enemy_boss_bounty" )
	Highlight_SetNeutralHighlight( target, "enemy_boss_bounty" )
	Highlight_SetOwnedHighlight( target, "enemy_boss_bounty" )
	Highlight_SetFriendlyHighlight( target, "enemy_boss_bounty" )

	print( "new highlight" )

	OnThreadEnd(
	function() : ( soul, player )
		{
			print( "atempted new highlight" + ( !IsValid( soul ) || !IsValid( soul.GetTitan() ) || !IsValid( player ) || !file.shouldHighlight ) )

			if ( !IsValid( soul ) || !IsValid( soul.GetTitan() ) || !IsValid( player ) || !file.shouldHighlight )
				return

			thread HighlightUpdate( soul, player )
		}
	)

	WaitForever()
}

void function DelayedTitanGiveAway( entity player )
{
	wait RandomInt( 1 ) + 1

	player.p.earnMeterOverdriveFrac = 1.0
	player.SetPlayerNetFloat( EARNMETER_EARNEDFRAC, 1.0 )
	PlayerEarnMeter_SetOwnedFrac( player, 1.0 )
	PlayerEarnMeter_SetRewardFrac( player, 1.0 )
	SetTitanAvailable( player )
}

void function Cleanup()
{
	if ( IsValid( file.soul ) && IsValid( file.soul.GetTitan() ) )
	{
		file.soul.GetTitan().Die()
		file.soul.Destroy()
	}
	else if ( IsValid( file.soul ) )
		file.soul.Destroy()

	Riff_ForceSetSpawnAsTitan( eSpawnAsTitan.Never )
}

void function OnTitanDeath( entity victim, entity attacker, var damageInfo )
{
	// if ( attack )

	if ( IsValid( victim ) && victim.IsTitan() && victim.GetBossPlayer() == attacker )
		thread DelayedRoundEnd( attacker )
	else if ( !IsValid( file.soul ) || victim == file.soul.GetTitan() )
		thread DelayedRoundEnd( attacker )
	else if ( !IsValid( file.soul ) )
		thread DelayedRoundEnd( attacker )
}

void function OnPlayerKilled( entity victim, entity attacker, var damageInfo )
{
	if ( IsValid( file.soul ) && IsValid( GetSoulFromPlayer( victim ) ) && GetSoulFromPlayer( victim ) == file.soul )
		thread DelayedRoundEnd( attacker )
	else if ( !IsValid( file.soul ) )
		thread DelayedRoundEnd( attacker )
}

void function DelayedRoundEnd( entity ornull attacker )
{
	SetRespawnsEnabled( false )

	wait 2

	SetWinner( DecideWinner() )
	
	Riff_ForceSetSpawnAsTitan( eSpawnAsTitan.Never )

	if ( !IsValid( attacker ) )
		return
	expect entity( attacker )
	SetRoundWinningKillReplayAttacker( attacker )
}

void function FastRoundRestart()
{
	SetWinner( TEAM_UNASSIGNED )
	
	SetRespawnsEnabled( false )
	Riff_ForceSetSpawnAsTitan( eSpawnAsTitan.Never )
}

void function KillEveryone()
{
	SetRespawnsEnabled( false )
	thread KillEveryoneThreaded()
}

void function KillEveryoneThreaded()
{
	file.signlEnt.EndSignal( "StopKillEveryone" )

	for(;;)
	{
		foreach ( entity player in GetPlayerArray() )
		{
			if ( IsValid( player ) )
			{
				player.FreezeControlsOnServer()
				// ScreenFade( player, 0, 0, 0, 255, 0.3, 0.3, (FFADE_IN | FFADE_PURGE) )
			}
			else
			{
				RespawnAsPilot( player )
				player.FreezeControlsOnServer()
				// ScreenFade( player, 0, 0, 0, 255, 0.3, 0.3, (FFADE_IN | FFADE_PURGE) )
			}

			if ( IsAlive( player ) && player.IsTitan() )
			{
				// thread MakePlayerPilot( player, player.GetOrigin() )
				player.Die()
			}
		}
		WaitFrame()
	}
}

void function MakePlayerPilot( entity player, vector destination  )
{
	EndSignal( player, "OnDeath" )
	EndSignal( player, "OnDestroy" )

	entity titan = GetTitanFromPlayer( player )
	if ( player.IsTitan() && IsValid( titan ) )
	{
		ForcedTitanDisembark( player )

		while( player.IsTitan() || titan.IsPlayer() || IsPlayerDisembarking( player ) && IsPlayerEmbarking( player ) )
		{
			titan = GetTitanFromPlayer( player )
			wait 0.05
		}
		
		titan.Destroy()
		player.SetOrigin( destination )
	}
}