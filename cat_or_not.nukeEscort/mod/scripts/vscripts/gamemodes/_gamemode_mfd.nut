global function GamemodeMfd_Init

struct {
} file

void function GamemodeMfd_Init()
{
	Riff_ForceTitanAvailability( eTitanAvailability.Never )

	AddCallback_OnPlayerKilled( GiveScoreForPlayerKill )

	PrecacheModel($"models/robots/mobile_hardpoint/mobile_hardpoint.mdl")
}

void function GiveScoreForPlayerKill( entity victim, entity attacker, var damageInfo )
{
	if ( victim != attacker && victim.IsPlayer() && attacker.IsPlayer() || GetGameState() != eGameState.Playing )
		attacker.AddToPlayerGameStat( PGS_PILOT_KILLS, 1)
}

// might be usuful
// player.SetPlayerGameStat( PGS_ELIMINATED, 1 )