global function GamemodeMfd_Init


const table<str,vector> NukeTitanSpawnLocation =
{
	"mp_box": <0,0,100>
}

struct {
} file

void function GamemodeMfd_Init()
{
	Riff_ForceTitanAvailability( eTitanAvailability.Never )

	AddCallback_OnPlayerKilled( GiveScoreForPlayerKill )

	AddCallback_GameStateEnter( eGameState.Playing, StartGamemode )

	PrecacheModel($"models/robots/mobile_hardpoint/mobile_hardpoint.mdl")
}

void function GiveScoreForPlayerKill( entity victim, entity attacker, var damageInfo )
{
	if ( victim != attacker && victim.IsPlayer() && attacker.IsPlayer() || GetGameState() != eGameState.Playing )
		attacker.AddToPlayerGameStat( PGS_PILOT_KILLS, 1)
}

void function StartGamemode()
{
	// First we need to spawn the nuke titan
	
	vector spawnPosition = <0,0,100>

	if ( GetMapName() in NukeTitanSpawnLocation )
		spawnPosition = NukeTitanSpawnLocation[ GetMapName() ]

	entity nukeTitan = CreateNPCTitan( "npc_titan_ogre", TEAM_MILITIA, spawnPosition, <0,0,0>, [] ) // why do I need []
	SetSpawnOption_NPCTitan( nukeTitan, TITAN_HENCH )
	SetSpawnOption_AISettings( nukeTitan, "npc_titan_ogre" )
    SetSpawnOption_Titanfall( nukeTitan )
    // spawnNpc.ai.titanSpawnLoadout.setFile = name // good idea wold be to set a loadout
	// OverwriteLoadoutWithDefaultsForSetFile( nukeTitan.ai.titanSpawnLoadout )
	DispatchSpawn( nukeTitan )

	// TODO : add target
	// then we spawn a target
}

// might be usuful
// player.SetPlayerGameStat( PGS_ELIMINATED, 1 )