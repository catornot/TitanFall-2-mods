global function GamemodeMfd_Init


const table<str,vector> NukeTitanSpawnLocation =
{
	"mp_box": <0,0,100>
}

struct {
	entity nukeTitan
	entity harvester
} file

void function GamemodeMfd_Init()
{
	Riff_ForceTitanAvailability( eTitanAvailability.Never )

	GameMode_SetName( "mdf", "Nuke Escort" )
	GameMode_SetIcon( "mdf", $"ui/menu/playlist/tdm" )
	GameMode_SetDefaultScoreLimits( "mdf", 100, 100 )
	GameMode_SetDesc( "mdf", "Nuke titan tries to destroy the harvester" )
	GameMode_SetGameModeAnnouncement( "mdf", "Nuke Escort" )
	GameMode_SetGameModeDefendAnnouncement( "mdf", "Defend the harvester from the nuke titan" )
	GameMode_SetDefendDesc( "mdf", "Defending team defends the harvester from the nuke titan" )
	GameMode_SetGameModeAttackAnnouncement( "mdf", "Escort The nuke tian to the harvester" )
	GameMode_SetAttackDesc( "mdf", "Attacking team escorts The nuke tian to the harvester" )

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

	file.nukeTitan = CreateNPCTitan( "npc_titan_ogre", TEAM_MILITIA, spawnPosition, <0,0,0>, [] ) // why do I need []
	SetSpawnOption_NPCTitan( file.nukeTitan, TITAN_HENCH )
	SetSpawnOption_AISettings( file.nukeTitan, "npc_titan_ogre_minigun_nuke" )
    SetSpawnOption_Warpfall( file.nukeTitan )
    // spawnNpc.ai.titanSpawnLoadout.setFile = name // good idea wold be to set a loadout
	// OverwriteLoadoutWithDefaultsForSetFile( nukeTitan.ai.titanSpawnLoadout )
	DispatchSpawn( file.nukeTitan )

	// TODO : add target
	// then we spawn a target
}

// might be usuful
// player.SetPlayerGameStat( PGS_ELIMINATED, 1 )