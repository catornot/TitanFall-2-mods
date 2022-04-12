global function GamemodeMfd_Init


const table< str,array<vector> > SpawnLocationForMap =
{
	"mp_box": [<0,0,1>,<0,100,1>]
}

struct {
	entity nukeTitan
	entity harvester
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
	// spawn locations
	vector TitanspawnPosition = <0,0,1>
	vector HaversterspawnPosition = <0,100,1>

	if ( GetMapName() in SpawnLocationForMap )
		TitanspawnPosition = NukeTitanSpawnLocation[ GetMapName() ][0]
	
	if ( GetMapName() in SpawnLocationForMap )
		HaversterspawnPosition = NukeTitanSpawnLocation[ GetMapName() ][1]
	
	// First we need to spawn the nuke titan

	file.nukeTitan = CreateNPCTitan( "npc_titan_ogre", TEAM_MILITIA, TitanspawnPosition, <0,0,0>, [] ) // why do I need []
	SetSpawnOption_NPCTitan( file.nukeTitan, TITAN_HENCH )
	SetSpawnOption_AISettings( file.nukeTitan, "npc_titan_ogre_minigun_nuke" )
    SetSpawnOption_Warpfall( file.nukeTitan )
    // spawnNpc.ai.titanSpawnLoadout.setFile = name // good idea wold be to set a loadout
	// OverwriteLoadoutWithDefaultsForSetFile( file.nukeTitan.ai.titanSpawnLoadout )
	DispatchSpawn( file.nukeTitan )

	// TODO : add target
	// then we spawn a target
	
	file.harvester = CreateEntity( "prop_dynamic" )
    file.harvester.SetValueForModelKey( $"models/props/generator_coop/generator_coop.mdl" )
    // file.harvester.kv.health = 10000
    // file.harvester.kv.max_health = 10000
    file.harvester.SetAngles( <0,0,0> )
    file.harvester.SetOrigin( HaversterspawnPosition )
    file.harvester.kv.solid = SOLID_VPHYSICS
    // file.harvester.SetTakeDamageType( DAMAGE_YES )
    SetTeam(file.harvester, TEAM_IMC )
    DispatchSpawn( file.harvester )
    // Highlight_SetEnemyHighlight( file.harvester, "hunted_enemy" )
    // Highlight_SetFriendlyHighlight( file.harvester, "hunted_friendly" )
	// AddEntityCallback_OnDamaged( file.harvester, OHNODAMGED )

    entity Shield = CreateShieldWithSettings( HaversterspawnPosition, <0,0,0>,200,500,360,999999,1000, $"P_shield_hld_01_CP" )
    SetTeam( Shield, TEAM_IMC )
}

// might be usuful
// player.SetPlayerGameStat( PGS_ELIMINATED, 1 )
// PGS_DEFENSE_SCORE will be used to track the amount of time a player is defeding/attacking the tian 