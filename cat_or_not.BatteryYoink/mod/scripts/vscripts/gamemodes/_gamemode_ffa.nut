global function FFA_Init

struct {
	array<vector> current = []
	array<string> encouters = ["sarah","grunt","reaper","drones","grunt+drones","spectre+drones","spectre","stalker"]
	array<entity> target
	entity trader
	entity trigger
	array<entity> amped_players = []

} file

void function FFA_Init()
{
	SetShouldUseRoundWinningKillReplay( true )
	ClassicMP_ForceDisableEpilogue( true )
	Riff_ForceTitanAvailability( eTitanAvailability.Never )

	// AddCallback_GameStateEnter( eGameState.WinnerDetermined, OnWinnerDetermined )
	AddCallback_OnClientConnected( OnPlayerConnected )
	AddCallback_OnNPCKilled(OnBossNpcKilled)
	AddCallback_OnPlayerRespawned( PlayerRespawned )

	PrecacheModel($"models/robots/mobile_hardpoint/mobile_hardpoint.mdl")

	thread NPC_Init()

	PilotBattery_SetMaxCount( 3 )

}

void function NPC_Init(){
	wait(5)
	if (GetMapName() == "mp_coliseum"){
		file.current = [
			Vector(750,-12,0),
			Vector(-750,12,0),
			Vector(0,0,0),
		]
		thread spawn_obj()
	}
	else{
		foreach ( spawner in SpawnPoints_GetTitan() )
		{
			file.current.append( spawner.GetOrigin() )
		}

		WaitFrame()
		for ( int r = 0; r != getNpcSpawnAmount(); r += 1 ){
			thread spawn_obj()
		}
	}

	wait(1)
	thread SpawnShop()
}

void function spawn_obj(){
	wait(0.1)
	vector location = file.current.getrandom() + Vector(0,0,5)
	entity target
	
	switch (file.encouters.getrandom()) {

	case ("sarah"):
		target = SpawnNPC("npc_soldier", "npc_soldier_hero_sarah", 1, 100, location, Vector(0,0,0), 300, null)
		break;
	
	case ("grunt"):
		target = SpawnNPC("npc_soldier", "npc_soldier", 1, 100, location, Vector(0,0,0), 200, null)
		SpawnNPC("npc_soldier", "npc_soldier", 1, 100, location, Vector(0,0,0), 100, target)
		break;
	
	case ("reaper"):
	    target = SpawnNPC("npc_super_spectre", "npc_super_spectre", 1, 100, location, Vector(0,0,0), 1000, null)
		break;

	case ("drones"):
		target = SpawnNPC("npc_drone","npc_drone_beam", 1, 100, location, Vector(0,0,0), 200, null)
		SpawnNPC("npc_drone","npc_drone_plasma", 1, 100, location, Vector(0,0,0), 100, target)
		SpawnNPC("npc_drone","npc_drone_plasma", 1, 100, location, Vector(0,0,0), 100, target)
		SpawnNPC("npc_drone","npc_drone_plasma", 1, 100, location, Vector(0,0,0), 100, target)
		break;
	
	case ("grunt+drones"):
		target = SpawnNPC("npc_soldier","npc_soldier", 1, 100, location, Vector(0,0,0), 200, null)
		SpawnNPC("npc_drone","npc_drone_plasma", 1, 100, location, Vector(0,0,0), 100, target)
		SpawnNPC("npc_drone","npc_drone_plasma", 1, 100, location, Vector(0,0,0), 100, target)
		break;
	
	case ("spectre+drones"):
		target = SpawnNPC("npc_spectre","npc_spectre", 1, 100, location, Vector(0,0,0), 200, null)
		SpawnNPC("npc_drone","npc_drone_plasma", 1, 100, location, Vector(0,0,0), 100, target)
		SpawnNPC("npc_drone","npc_drone_plasma", 1, 100, location, Vector(0,0,0), 100, target)
		break;
	
	case ("spectre"):
		target = SpawnNPC("npc_spectre","npc_spectre", 1, 100, location, Vector(0,0,0), 200, null)
		break;
	
	case ("stalker"):
		target = SpawnNPC("npc_stalker","npc_stalker", 1, 100, location, Vector(0,0,0), 200, null)
		break;

	default:
		print("none")
		break;
	}
	Highlight_SetEnemyHighlight( target, "enemy_boss_bounty" )
	foreach( entity player in GetPlayerArray() )
		ApplyTrackerMark( target, player )
	file.target.append(target)
}

void function OnBossNpcKilled( entity victim, entity attacker, var damageInfo )
{
	for (int a=0 ; a < file.target.len() ; a += 1){
		if (file.target[a] == victim){
			// AddTeamScore( attacker.GetTeam(), 1 )
			// attacker.AddToPlayerGameStat( PGS_ASSAULT_SCORE, 1 )

			file.target.remove( a )
			entity battery = Rodeo_CreateBatteryPack()
            battery.SetOrigin( victim.GetOrigin() + Vector(0,0,5) )
			
			thread spawn_obj()
			
			break
		}
	}
	if (GetPlayerBatteryCount(attacker) > 1){
		Highlight_SetEnemyHighlight( attacker, "battery_thief" )
	}
}

void function OnPlayerKilled( entity victim, entity attacker, var damageInfo )
{

	attacker.AddToPlayerGameStat( PGS_PILOT_KILLS, 1 )

	if (GetPlayerBatteryCount(attacker) > 1){
		Highlight_SetEnemyHighlight( attacker, "battery_thief" )
	}
}

entity function SpawnNPC(string name,string aiName, int amount, int team, vector spawnPos, vector spawnAng, int health, entity petOwner)
{
    int a = amount
    entity spawnNpc

    while(a>0)
    {
    a-=1;

    spawnNpc = CreateNPC( name, team, spawnPos, spawnAng);
    SetSpawnOption_AISettings( spawnNpc, aiName);
    DispatchSpawn( spawnNpc );

	if (health > 0)
	{
		spawnNpc.SetMaxHealth(health)
		spawnNpc.SetHealth(health)
	}
	if (petOwner != null)
	{
		int followBehavior = GetDefaultNPCFollowBehavior( spawnNpc )
		spawnNpc.InitFollowBehavior( petOwner, followBehavior )
		spawnNpc.EnableBehavior( "Follow" )
		spawnNpc.SetTitle( "minion")
	}
	else{
		// InitMinimapSettings( spawnNpc )
		// spawnNpc.Minimap_SetCustomState( spawnNpc.GetObjectiveIndex() )
		// spawnNpc.Minimap_AlwaysShow( TEAM_MILITIA, null )
		// spawnNpc.Minimap_AlwaysShow( TEAM_IMC, null )
		// spawnNpc.Minimap_SetAlignUpright( true )
	}

    }
	return spawnNpc
}

void function SpawnShop(){

	entity Prop = CreateEntity( "prop_dynamic" )
    
	Prop.SetValueForModelKey( $"models/robots/mobile_hardpoint/mobile_hardpoint.mdl" )
	Prop.kv.solid = SOLID_VPHYSICS
    Prop.kv.rendercolor = "81 130 151"
    Prop.kv.contents = (int(Prop.kv.contents) | CONTENTS_NOGRAPPLE)
	Prop.SetOrigin( file.current.getrandom() )
	Prop.SetAngles( Vector( 0, 0, 0 ) )

	Prop.SetBlocksRadiusDamage( true )
	DispatchSpawn( Prop )
    SetTeam( Prop, 99 )
	Prop.SetTitle( "Shop")
	// highlight = Highlight_SetEnemyHighlight( Prop, "sp_objective_entity" ) this needs untyped :(
	// HighlightContext_SetRadius( highlight, 10000 )
	Highlight_SetEnemyHighlight( Prop, "hunted_enemy" )

	// Prop.Minimap_SetCustomState( Prop.GetObjectiveIndex() ) // I guess this doesn't work
	// Prop.Minimap_AlwaysShow( TEAM_MILITIA, null )
	// Prop.Minimap_AlwaysShow( TEAM_IMC, null )
	// Prop.Minimap_SetAlignUpright( true )

	file.trader = Prop

	//setup a trigger for text
	// CreateScriptCylinderTrigger( vector origin, float radius, float ornull top = null, float ornull bottom = null )
	entity trigger = CreateTriggerRadiusMultiple( file.trader.GetOrigin() , 100.0 )

	// set up trigger functions
	AddCallback_ScriptTriggerEnter( trigger, OnEnterShopArea )
	// AddCallback_ScriptTriggerLeave( trigger, OnLeaveShopArea )
	file.trigger = trigger

	//starting a timer to move the shop
	thread MoveShop()
}

void function MoveShop(){
	wait( getShopMovingTime() )
	file.trader.Destroy()
	file.trader = null

	file.trigger.Destroy()
	file.trigger = null

	thread SpawnShop()

	//notification 
	foreach ( entity p in GetPlayerArray() ){
		SendHudMessage( p, "The shop moved!", -1, 0.2, 255, 255, 0, 0, 0.15, 10, 0.15 )
	}
}

void function OnEnterShopArea( entity trigger, entity player ){
	SendHudMessage( player, "Jump to get points or crouch to get weapon amped weapon near the shop", -1, 0.2, 255, 255, 0, 0, 0.15, 10, 0.15 )
}

void function OnPlayerConnected( entity player )
{
	AddButtonPressedPlayerInputCallback( player, IN_DUCK , Player_crouch)
	AddButtonPressedPlayerInputCallback( player, IN_JUMP , Player_jump)

	thread tutorial(player)
}

void function tutorial( entity player ){
	wait(2)
	//, x_pos, y_pos, R, G, B, A, fade_in_time, hold_time, fade_out_time 
	SendHudMessage( player, "Hello, This is BatteryYoink, In this gamemode you kill NPCs and collect there batteries.\nTo score a point You need to go to a shop and jump near it.\nYou can also get better wepons if you crouch near a shop", -1, 0.2, 255, 255, 0, 0, 0.15, 20, 0.15 )
}

void function Player_jump( entity player )
{
	if (file.trader != null)
	{
	if ( DistanceSqr( player.GetOrigin(), file.trader.GetOrigin() ) <= 30000.0 ){
		if  ( PlayerHasBattery( player ) ){
			// crouch adds you jump
			AddTeamScore( player.GetTeam(), GetPlayerBatteryCount( player ) )
			player.AddToPlayerGameStat( PGS_ASSAULT_SCORE, GetPlayerBatteryCount( player ) )
			// print(GetPlayerBatteryCount( player ))
			// double if has 3 batteries
			if ( GetPlayerBatteryCount( player ) == 3 )
				AddTeamScore( player.GetTeam(), GetPlayerBatteryCount( player ) )
			// rm battery
			Rodeo_RemoveAllBatteriesOffPlayer( player )	
			// sound
			EmitSoundOnEntityOnlyToPlayer( player, player, "UI_TitanBattery_Pilot_Give_TitanBattery" )
		}
	}
	}
}
void function Player_crouch( entity player )
{
	if (file.trader != null)
	{
	if ( DistanceSqr( player.GetOrigin(), file.trader.GetOrigin() ) <= 30000.0 ){
		if  ( PlayerHasBattery( player ) && IsAlive(player) ){

			int loadoutIndex = GetActivePilotLoadoutIndex(player)
			PilotLoadoutDef loadout = GetPilotLoadoutFromPersistentData(player, loadoutIndex)
			array<entity> weapons = player.GetMainWeapons()
			//add melee
			loadout.melee = "melee_pilot_kunai"
			GivePilotLoadout(player, loadout)
			// crouch gives weapon based the battery count
			switch (GetPlayerBatteryCount( player )) {

				case (1):
					//add to amped list
					thread AddPlayerToAmped( player )
					//give amped weapon
					GivePlayerAmpedWeapon( player ,weapons[0].GetWeaponClassName() )
					break;

				case (2):
					//add to amped list
					thread AddPlayerToAmped( player )

					thread threaded_powerWeaponDelete( player, weapons[0].GetWeaponClassName(), 60 )

					loadout.primary = "mp_titanweapon_leadwall" 
					loadout.primaryAttachments = []
					loadout.primaryMods = []

					loadout.ordnance = "mp_titanability_phase_dash"

					GivePilotLoadout(player, loadout)

					AddTeamScore( player.GetTeam(), 1 )
					player.AddToPlayerGameStat( PGS_ASSAULT_SCORE, 1 )
					break;

				case (3):
					//add to amped list
					thread AddPlayerToAmped( player )
					//start thread to rm the weapon later
					thread threaded_powerWeaponDelete( player, weapons[0].GetWeaponClassName(), 40 )
					
					loadout.primary = "mp_titanweapon_flightcore_rockets"
					loadout.primaryAttachments = []
					loadout.primaryMods = []
					GivePilotLoadout(player, loadout)
					AddTeamScore( player.GetTeam(), 1 )
					player.AddToPlayerGameStat( PGS_ASSAULT_SCORE, 1 )
					break;

				default:
					print("none")
					break;
			}
			// rm battery
			Rodeo_RemoveAllBatteriesOffPlayer( player )		
			// sound
			EmitSoundOnEntityOnlyToPlayer( player, player, "UI_TitanBattery_Pilot_Give_TitanBattery" )
		}
	}
	}
}

void function threaded_powerWeaponDelete( entity player, string last_weapon, int _time ){
	foreach ( entity p in GetPlayerArray() ){
		SendHudMessage( p, player.GetPlayerName() + " got a power weapon for " + _time + " seconds", -1, 0.2, 255, 100, 100, 0, 0.15, 1, 0.15 )
	}
	int num = 1
	while(1){
		if (num >= _time){
			try
			{
				GivePlayerAmpedWeapon( player , last_weapon )
			}
			catch(exception){
				continue;
			}
			break;
		}
		wait(1)
		num += 1
		int time_left = _time - num 
		SendHudMessage( player, "You have " + time_left.tostring() + " seconds left" , -1, 0.2, 255, 100, 100, 0, 0.15, 1, 0.15 )

		//check if alive
		if ( ! IsAlive(player) ) break;
	}

}

void function AddPlayerToAmped( entity player){
	bool in_list = false
	foreach ( entity p in file.amped_players ){
		if ( ( p == player ) ){
			in_list = true
		}
	}
	if ( in_list ) print(" someone is in the amped list")
	if ( ! in_list ) file.amped_players.append( player )
}
void function PlayerRespawned( entity player ){
	thread PlayerRespawned_thread( player )
}

void function PlayerRespawned_thread( entity player ){
	WaitFrame()
	print("respawn")
	foreach( entity p in file.amped_players ){
		if ( p == player ){
			if ( IsAlive(player) ){
				array<entity> weapons = player.GetMainWeapons()
				GivePlayerAmpedWeapon( player ,weapons[0].GetWeaponClassName() )
				print("Giving")
			}
		}
	}
}