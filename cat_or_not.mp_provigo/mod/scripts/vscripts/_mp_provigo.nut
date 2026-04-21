global function CodeCallback_MapInit

struct ROCKS {
	int rock_id
	int rock_type
}

void function CodeCallback_MapInit()
{
	provigo_pickups_init()

	PrecacheModel( $"models/humans/pilots/pilot_medium_geist_m.mdl" )

	AddSpawnCallbackEditorClass( "script_ref", "script_pickup_weapon", TrackWeapon )
	AddCallback_OnPlayerRespawned( GiveMoney )

	AddCallback_OnClientConnected( Store_OnClientConnected )
	SetJoinInProgressBonus( 0 )
	SetLoadoutGracePeriodEnabled( false )
}

void function TrackWeapon( entity weapon )
{
	thread TrackWeaponThreaded( weapon )
}

void function TrackWeaponThreaded( entity weapon )
{
	entity player = WaitUntilPlayerPicksUp( weapon )

	weapon.SetOrigin( <0,0,-20000> )

	AddMoneyToPlayer( player, -100 )
}

void function GiveMoney( entity player )
{
	TakeAllWeapons( player )
	player.GiveOffhandWeapon( "melee_pilot_emptyhanded", OFFHAND_MELEE, [] )
	player.GiveOffhandWeapon( "mp_weapon_grenade_gravity", OFFHAND_RIGHT, [] )
	SetMoneyForPlayer( player, 1000 )
}