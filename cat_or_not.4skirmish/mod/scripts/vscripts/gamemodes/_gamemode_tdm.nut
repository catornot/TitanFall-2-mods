global function GamemodeTdm_Init
global function RateSpawnpoints_Directional

global const TEAM_GAMMA = 10
global const TEAM_ALPHA = 9

struct
{
	array<entity> Gamma
	array<entity> Alpha
	array<entity> Imc
	array<entity> Militia
} file

void function GamemodeTdm_Init()
{
	AddCallback_OnPlayerKilled( GiveScoreForPlayerKill )
	ScoreEvent_SetupEarnMeterValuesForMixedModes()
	SetTimeoutWinnerDecisionFunc( CheckScoreForDraw )
	
	AddCallback_GameStateEnter( eGameState.Playing, SetupMatch )
	AddCallback_GameStateEnter( eGameState.WinnerDetermined, HACK_PlaceEveryoneOnSameTeam )
}

void function GiveScoreForPlayerKill( entity victim, entity attacker, var damageInfo )
{
	if ( victim != attacker && victim.IsPlayer() && attacker.IsPlayer() && GetGameState() == eGameState.Playing )
		AddTeamScore( attacker.GetTeam(), 1 )
}

void function RateSpawnpoints_Directional( int checkclass, array<entity> spawnpoints, int team, entity player )
{
	// temp
	RateSpawnpoints_Generic( checkclass, spawnpoints, team, player )
}

int function CheckScoreForDraw()
{
	if ( GameRules_GetTeamScore( TEAM_IMC ) > GameRules_GetTeamScore( TEAM_MILITIA ) && GameRules_GetTeamScore( TEAM_IMC ) > GameRules_GetTeamScore( TEAM_GAMMA ) && GameRules_GetTeamScore( TEAM_IMC ) > GameRules_GetTeamScore( TEAM_ALPHA ) )
		return TEAM_IMC
	else if ( GameRules_GetTeamScore( TEAM_MILITIA ) > GameRules_GetTeamScore( TEAM_IMC ) && GameRules_GetTeamScore( TEAM_MILITIA ) > GameRules_GetTeamScore( TEAM_GAMMA ) && GameRules_GetTeamScore( TEAM_MILITIA ) > GameRules_GetTeamScore( TEAM_ALPHA ) )
		return TEAM_MILITIA
	else if ( GameRules_GetTeamScore( TEAM_GAMMA ) > GameRules_GetTeamScore( TEAM_IMC ) && GameRules_GetTeamScore( TEAM_MILITIA ) < GameRules_GetTeamScore( TEAM_GAMMA ) && GameRules_GetTeamScore( TEAM_GAMMA ) > GameRules_GetTeamScore( TEAM_ALPHA ) )
		return TEAM_GAMMA
	else if ( GameRules_GetTeamScore( TEAM_ALPHA ) > GameRules_GetTeamScore( TEAM_IMC ) && GameRules_GetTeamScore( TEAM_ALPHA ) > GameRules_GetTeamScore( TEAM_GAMMA ) && GameRules_GetTeamScore( TEAM_MILITIA ) < GameRules_GetTeamScore( TEAM_ALPHA ) )
		return TEAM_ALPHA

	return TEAM_UNASSIGNED
}

void function GiveTeam( entity player )
{
	if ( !IsValid( player ) )
		return

	if ( file.Gamma.contains( player ) )
	{
		SetTeam( player, TEAM_GAMMA )
		return
	}
	else if ( file.Alpha.contains( player ) )
	{
		SetTeam( player, TEAM_ALPHA )
		return
	}
	else if ( file.Imc.contains( player ) )
	{
		SetTeam( player, TEAM_IMC )
		return
	}
	else if ( file.Militia.contains( player ) )
	{
		SetTeam( player, TEAM_MILITIA )
		return
	}

	if ( file.Gamma.len() < file.Alpha.len() || file.Gamma.len() < file.Imc.len() || file.Gamma.len() < file.Militia.len() )
	{
		SetTeam( player, TEAM_GAMMA )
		file.Gamma.append( player )
		return
	}
	else if ( file.Gamma.len() > file.Alpha.len() || file.Alpha.len() < file.Imc.len() || file.Alpha.len() < file.Militia.len() )
	{
		SetTeam( player, TEAM_ALPHA )
		file.Alpha.append( player )
		return
	}
	else if ( file.Imc.len() < file.Alpha.len() || file.Gamma.len() > file.Imc.len() || file.Imc.len() < file.Militia.len() )
	{
		SetTeam( player, TEAM_IMC )
		file.Imc.append( player )
		return
	}
	else if ( file.Militia.len() < file.Alpha.len() || file.Militia.len() < file.Imc.len() || file.Gamma.len() > file.Militia.len() )
	{
		SetTeam( player, TEAM_MILITIA )
		file.Militia.append( player )
		return
	}
	
	int team = [ TEAM_ALPHA, TEAM_GAMMA, TEAM_IMC, TEAM_MILITIA ].getrandom()
	SetTeam( player, team )

	Chat_ServerPrivateMessage( player, "Unbind scoreboard ;)", false )
	
	switch( team )
	{
		case TEAM_IMC:
			file.Imc.append( player )
			return
		case TEAM_MILITIA:
			file.Militia.append( player )
			return
		case TEAM_GAMMA:
			file.Gamma.append( player )
			return
		case TEAM_ALPHA:
			file.Alpha.append( player )
			return
	}
}

void function SetupMatch()
{
	thread ScoreDisplayThink()
	AddCallback_OnClientConnected( GiveTeam )
	AddCallback_OnPlayerRespawned( GiveTeam )

	foreach( entity player in GetPlayerArray() )
		GiveTeam( player )
}

void function ScoreDisplayThink()
{
	while( GetGameState() == eGameState.Playing )
	{
		foreach( entity player in GetPlayerArray() )
		{
			int s_gamma = GameRules_GetTeamScore( TEAM_GAMMA )
			int s_alpha = GameRules_GetTeamScore( TEAM_ALPHA )
			int s_imc = GameRules_GetTeamScore( TEAM_IMC )
			int s_militia = GameRules_GetTeamScore( TEAM_MILITIA )

			if ( !IsValid( player ) )
				continue
			
			if ( file.Gamma.contains( player ) )
				SendHudMessage( player, format( "< Gamma > : %d, Alpha : %d, IMC : %d, Militia : %d", s_gamma, s_alpha, s_imc, s_militia ) , -1, 0.2, 200, 200, 200, 0, 0, 10, 0 )
			else if ( file.Alpha.contains( player ) )
				SendHudMessage( player, format( "Gamma : %d, < Alpha > : %d, IMC : %d, Militia : %d", s_gamma, s_alpha, s_imc, s_militia ) , -1, 0.2, 200, 200, 200, 0, 0, 10, 0 )
			else if ( file.Imc.contains( player ) )
				SendHudMessage( player, format( "Gamma : %d, Alpha : %d, < IMC > : %d, Militia : %d", s_gamma, s_alpha, s_imc, s_militia ) , -1, 0.2, 200, 200, 200, 0, 0, 10, 0 )
			else if ( file.Militia.contains( player ) )
				SendHudMessage( player, format( "Gamma : %d, Alpha : %d, IMC : %d, < Militia > : %d", s_gamma, s_alpha, s_imc, s_militia ) , -1, 0.2, 200, 200, 200, 0, 0, 10, 0 )
		}

		wait 5
	}
}

void function HACK_PlaceEveryoneOnSameTeam()
{
	int winningTeam = CheckScoreForDraw()

	foreach( entity player in GetPlayerArray() )
	{
		if ( player.GetTeam() == winningTeam )
			Chat_ServerPrivateMessage( player, "You Won :)", false )
		else
			Chat_ServerPrivateMessage( player, "You Lost :(", false )

		SetTeam( player, 3 )
	}
}
