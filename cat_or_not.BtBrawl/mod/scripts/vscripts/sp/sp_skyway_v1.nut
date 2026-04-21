//spawn_test
global function InjectorFire
global function LightstripSounds

global function CodeCallback_MapInit

global function DoWorldRumble
global function InjectorLightUp
global function InjectorSpoolDown

const float FRAME_INTERVAL = .1
const FX_CANNON_BEAM 				= $"P_rail_fire_beam_scale"

//TORTURE ROOM ASSETS
const asset COMBAT_KNIFE = $"models/weapons/combat_knife/w_combat_knife.mdl"
const asset WINGMAN = $"models/Weapons/b3wing/b3_wingman_hero_static.mdl"

const asset STRATON_MODEL	= $"models/vehicle/straton/straton_imc_gunship_01.mdl"

//RISING WORLD RUN ASSETS
const asset ROCK_IMPACT_DUST = $"P_sw_rock_impact_XL"
const asset ROCK_IMPACT_DEBRIS = $"P_gate_smash"
const asset PHYS_ROCK_TRAIL = $"Rocket_Smoke_Trail_Large"

//SCULPTOR RING MODELS
const asset OUTER_RING_CHUNK_MAIN = $"models/levels_terrain/sp_skyway/sculpter_outer_ring_dmg.mdl"
const asset MIDDLE_RING_CHUNK_MAIN = $"models/levels_terrain/sp_skyway/sculpter_middle_ring_dmg.mdl"
const asset INNER_RING_CHUNK_MAIN = $"models/levels_terrain/sp_skyway/sculpter_inner_ring_dmg.mdl"

//CORE MODELS/FX
const asset CORE_ENERGY = $"models/props/core_energy/core_energy_animated.mdl"
const asset FX_CORE_FLARE = $"env_star_blue"
const asset FX_CORE_GLOW = $"P_sw_introom_core_light"

//WORLD RUN DEBRIS
const asset LARGE_BEAM = $"models/industrial/beam_curved_metal02.mdl"
const asset TRUCK = $"models/vehicle/vehicle_truck_modular/vehicle_truck_modular_closed_bed.mdl"

//GOBLIN PARTS
const asset GOBLIN_DEBRIS_CABIN = $"models/vehicle/goblin_dropship/goblin_dropship_dest_center.mdl"
const asset GOBLIN_DEBRIS_WING_LEFT = $"models/vehicle/goblin_dropship/goblin_dropship_dest_wing_l.mdl"
const asset GOBLIN_DEBRIS_WING_RIGHT = $"models/vehicle/goblin_dropship/goblin_dropship_dest_wing_r.mdl"

//ROCK CHUNKS
const asset SMALL_ROCK_01 =  $"models/rocks/rock_jagged_granite_small_01_phys.mdl"
const asset SMALL_ROCK_02 =  $"models/rocks/rock_jagged_granite_small_02_phys.mdl"
const asset SMALL_ROCK_03 =  $"models/rocks/rock_jagged_granite_small_03_phys.mdl"
const asset SMALL_ROCK_04 =  $"models/rocks/rock_jagged_granite_small_04_phys.mdl"
const asset SMALL_ROCK_05 =  $"models/rocks/rock_jagged_granite_small_05_phys.mdl"
const asset SMALL_ROCK_06 =  $"models/rocks/rock_jagged_granite_small_06_phys.mdl"
const asset SMALL_ROCK_07 =  $"models/rocks/rock_jagged_granite_small_07_phys.mdl"

//CHARACTER MODELS
const asset CROW_HERO_MODEL = $"models/vehicle/crow_dropship/crow_dropship_hero.mdl"
const asset SW_CROW = $"models/vehicle/crow_dropship/crow_dropship.mdl"
const asset SLONE_MODEL = $"models/Humans/heroes/imc_hero_slone.mdl"
const asset SW_BLISK_MODEL = $"models/Humans/heroes/imc_hero_blisk.mdl"
const asset SW_SARAH_MODEL = $"models/humans/heroes/mlt_hero_sarah.mdl"
const asset MARDER_HOLOGRAM_MODEL = $"models/humans/heroes/imc_hero_marder.mdl"
const asset TORTURE_HARNESS = $"models/props/skyway_harness_01_animated.mdl"

const string SFX_WORLD_RUMBLE_CLOSE 				= "Skyway_Explosion_Rumble_Close"
const string SFX_WORLD_RUMBLE_DISTANT 				= "Skyway_Explosion_Rumble_Dist"

const asset FLAK_FX = $"P_sw_impact_exp_flak"
const asset COCKPIT_LIGHT = $"P_sw_cockpit_dlight_damaged"//$"veh_interior_Dlight_cockpit"

global const STRATON_SB_MODEL	= $"models/vehicle/straton/straton_imc_gunship_01_1000x.mdl"

const FX_CARRIER_ATTACK 	= $"P_weapon_tracers_megalaser"
const FX_REDEYE_ATTACKS_CARRIER 	= $"P_Rocket_Phaser_Swirl"
const FX_EXP_BIRM_SML = $"p_exp_redeye_sml"
const FIRE_TRAIL = $"Rocket_Smoke_Swirl_LG"
const FX_REDEYE_WARPIN_SKYBOX = $"veh_red_warp_in_full_SB_1000"
const FX_BIRMINGHAM_WARPIN_SKYBOX = $"veh_birm_warp_in_full_SB_1000"
const FX_EXPLOSION_MED = $"P_exp_redeye_sml_elec"

const asset SKYBOX_TRACER = $"P_muzzleflash_MaltaGun_sw"
const asset SKYBOX_MFLASH = $"P_muzzleflash_MaltaGun_sw_NoTracer"

const asset FX_BT_ARM_DAMAGED 	= $"P_xo_arm_damaged"
const asset FX_BT_ARM_DAMAGED_POP 	= $"P_xo_arm_damaged_pop"
const asset FX_BT_ARM_DAMAGED_POP_SM = $"P_xo_arm_damaged_pop_SM"

const asset FX_BT_BODY_DAMAGED_POP 	= $"xo_spark_small"
const asset FX_BT_BODY_DAMAGED_POP_SM = $"P_xo_BT_damaged_elec"

const asset FX_BT_COCKPIT_SPARK 	= $"xo_cockpit_spark_01"

const asset CORE_MODEL = $"models/core_unit/core_unit.mdl"
const asset BT_EYE_CASE_MODEL = $"models/Titans/buddy/titan_buddy_hatch_eye.mdl"
const asset SMART_PISTOL_MODEL = $"models/weapons/p2011sp/w_p2011sp.mdl"
const asset CARD_MODEL = $"models/props/blisk_card_animated.mdl"

const asset CORE_GLOW_ON_FX = $"P_sw_core_hld_sm"

const asset LIGHTSTRIP_1 = $"models/levels_terrain/sp_skyway/sp_skyway_injector_lightstrips_01.mdl"
const asset LIGHTSTRIP_2 = $"models/levels_terrain/sp_skyway/sp_skyway_injector_lightstrips_02.mdl"
const asset LIGHTSTRIP_3 = $"models/levels_terrain/sp_skyway/sp_skyway_injector_lightstrips_03.mdl"
const asset LIGHTSTRIP_4 = $"models/levels_terrain/sp_skyway/sp_skyway_injector_lightstrips_04.mdl"

const asset BARREL = $"models/containers/barrel.mdl"

struct
{
	entity tortureRoomGrate
	entity bliskKnife
	entity TRBTCore
	entity TRSloneCore

	GunBatteryData& gunBattery01
	GunBatteryData& gunBattery02
	GunBatteryData& gunBattery03
	GunBatteryData& gunBattery04
	GunBatteryData& gunBattery06

	vector tortureFogOnPos
	vector tortureFogOffPos

	array<entity> bombardTargets
	array<entity> forcedBombardList

	int statusEffect
	string bombardString = "BOMBARD_"
	entity bombardGun

	int currentPhase
	int idealPhase

	array<float> phaseDelays = [
		60.0,
		60.0,
		120.0,
		120.0,
		240.0,
		90.0
	]

	entity worldRunLandingNode
	entity dropship
	entity dropshipAnimNode
	entity core
	float pitch
	float lastPulldownTime

	float lastActionTime

	float lastPlayerActionTime
	bool glowDone = false
	int BtReunionChoice
	array<string> soundsToStop

	int heat
	int injectorFlapSet
	float extraDelay
} file

//Called when the map is initialized
void function CodeCallback_MapInit()
{
	AddCallback_EntitiesDidLoad( EntitiesDidLoad )

	PrecacheImpactEffectTable( "exp_medium" )
	PrecacheImpactEffectTable( CLUSTER_ROCKET_FX_TABLE )

	PrecacheModel( BARREL )

	PrecacheParticleSystem( CORE_GLOW_ON_FX )

	PrecacheParticleSystem( FX_CARRIER_ATTACK )
	PrecacheParticleSystem( FX_EXP_BIRM_SML )
	PrecacheParticleSystem( FIRE_TRAIL )

	PrecacheParticleSystem( FX_HORNET_DEATH )
	PrecacheParticleSystem( FX_EXPLOSION_MED )

	PrecacheParticleSystem( SKYBOX_MFLASH )
	PrecacheParticleSystem( SKYBOX_TRACER )

	PrecacheParticleSystem( FX_BT_ARM_DAMAGED )
	PrecacheParticleSystem( FX_BT_ARM_DAMAGED_POP )
	PrecacheParticleSystem( FX_BT_ARM_DAMAGED_POP_SM )

	PrecacheParticleSystem( FX_BT_BODY_DAMAGED_POP )
	PrecacheParticleSystem( FX_BT_BODY_DAMAGED_POP_SM )

	PrecacheParticleSystem( FX_BT_COCKPIT_SPARK )

	PrecacheParticleSystem( $"P_sw_core_weather" )
	PrecacheParticleSystem( $"P_bt_cockpit_dlight_skyway" )
	PrecacheParticleSystem( $"P_impact_exp_med_metal" )

	Init_SkywayUtility()
	Init_Bombardment()
	ShSpSkywayCommonInit()

	//START POINT END FLAGS
	FlagInit( "TitanHillDone" )
	FlagInit( "InjectorRoomDone" )
	FlagInit( "BliskFareweelDone" )
	FlagInit( "BliskFareweelPlayerGetup" )
	FlagInit( "BTSacrificeDone" )
	FlagInit( "RisingWorldRunDone" )

	//Flags for Torture Room
	FlagInit( "TR_StartBurn" )
	FlagInit( "slone_kill_bt" )
	FlagInit( "slone_exit_tr" )
	FlagInit( "PlayerStartedTortureRoomDrag" )
	FlagInit( "DropEyeCase" )
	FlagInit( "DroppingEyeCase" )
	FlagInit( "TRDoorHackable" )
	FlagInit( "TortureRoomDone" )
	FlagInit( "TorturePlayerResponded" )
	FlagInit( "TorturePlayerGetup" )
	FlagInit( "TortureBTAwake" )

	FlagInit( "TR_Burn_Stage_Black" )
	FlagInit( "TR_Burn_Stage_1" )
	FlagInit( "TR_Burn_Stage_2" )
	FlagInit( "TR_Burn_Stage_3" )
	FlagInit( "TR_Burn_Stage_4" )
	FlagInit( "TR_Burn_Stage_5" )

	FlagInit( "TR_PauseRoomTemp" )

	FlagInit( "sp_run_rocks_light" )
	FlagInit( "sp_run_rocks_heavy" )
	FlagInit( "InjectorReadyToFire" )

	RegisterSignal( "ClientCommand_RequestTitanFake" )
	RegisterSignal( "begin_torture_id" )
	RegisterSignal( "pre_impact_barrels" )
	RegisterSignal( "impact_barrels" )
	RegisterSignal( "impact_ground" )
	RegisterSignal( "start_fire" )
	RegisterSignal( "BTSacrificeDialogue_BTMemory" )
	RegisterSignal( "PullDown" )
	RegisterSignal( "OnStopPulldown" )
	RegisterSignal( "BT_Returns_ChoiceMade" )
	RegisterSignal( "BTSacrificeDialogue" )
	RegisterSignal( "MissionFailAfterDelay" )
	RegisterSignal( "InjectorSpoolDown" )
	RegisterSignal( "Init_BTLoadingBayClimb" )

	FlagInit( "PickUpEyeCase" )

	//Flags for BT Reunion
	FlagInit( "AcceptEye" )
	FlagInit( "EyeInserted" )
	FlagInit( "BTReunionConversationDone" )
	FlagInit( "BTStoodUp" )
	FlagInit( "injector_lighting_FX" )

	//RegisterSignal( "InsertEyeCore" )

	// Titan Hill
	FlagInit( "titan_hill_arena" )
	FlagInit( "titan_hill_arena_2" )
	FlagInit( "titan_hill_arena_3" )
	FlagInit( "titan_hill_arena_door_open" )
	FlagInit( "BombardDialogueEnabled" )
	FlagInit( "BombardPaused" )
	FlagInit( "music_skyway_10_titanhillwave02" )

	FlagInit( "StoppingInjector" )
	FlagInit( "BTSacrifice_BTExplodes" )
	FlagInit( "BTMemorySequenceDone" )
	FlagInit( "BliskFarewellRadioPlayDone" )
	FlagInit( "BTSacrificeEnteredInjector" )
	FlagInit( "InjectorInteractionAvailable" )

	FlagInit( "BT_Throws_Player" )

	//Flags for Rising World Run
	FlagInit( "SpawnRingChunk" )
	FlagInit( "slam_rocks_01" )
	FlagInit( "embed_droppod_01" )
	FlagInit( "StartRise" )
	FlagInit( "PreLandingAreaRise" )
	FlagInit( "StartLandingAreaRise" )
	FlagInit( "tilting_platform_end" )
	FlagInit( "HideWorldRunRandoms" )
	FlagInit( "rising_world_core_FX" )
	FlagInit( "rising_world_core_FX_end" )

	FlagInit( "HarmonySceneStart" )
	FlagInit( "HarmonyRadio2" )
	FlagInit( "HarmonyRadio3" )

	FlagInit( "InjectorConversationDone" )

	RegisterSignal( "RockStrike" )
	RegisterSignal( "DoWorldRumble" )
	RegisterSignal( "StopFlybys" )
	RegisterSignal( "StartNextPhase" )
	RegisterSignal( "ForceNextPhase" )
	RegisterSignal( "BT_GOODBYE_DIALOGUE" )

	PrecacheParticleSystem( $"ar_target_CP_controlled" )
	PrecacheParticleSystem( $"veh_carrier_warp_full" )
	PrecacheParticleSystem( FLAK_FX )
	PrecacheParticleSystem( FX_CANNON_BEAM )
	PrecacheParticleSystem( $"P_rail_fire_flash" )

	//PRECACHE TORTURE ROOM ASSETS
	PrecacheModel( MARDER_HOLOGRAM_MODEL )
	PrecacheModel( SW_BLISK_MODEL )
	PrecacheModel( SW_SARAH_MODEL )
	PrecacheModel( COMBAT_KNIFE )
	PrecacheModel( WINGMAN )
	PrecacheModel( CARD_MODEL )
	PrecacheModel( BT_EYE_CASE_MODEL )
	PrecacheModel( SMART_PISTOL_MODEL )
	PrecacheModel( SW_CROW )
	PrecacheModel( TORTURE_HARNESS )
	PrecacheModel( LIGHTSTRIP_1 )
	PrecacheModel( LIGHTSTRIP_2 )
	PrecacheModel( LIGHTSTRIP_3 )
	PrecacheModel( LIGHTSTRIP_4 )
	PrecacheModel( $"models/fx/xo_shield_coll_small.mdl" )

	//PRECACHE RISING WORLD RUN ASSETS
	PrecacheParticleSystem( ROCK_IMPACT_DEBRIS )
	PrecacheParticleSystem( $"hotdrop_radial_smoke" )
	PrecacheParticleSystem( ROCK_IMPACT_DUST )
	PrecacheParticleSystem( PHYS_ROCK_TRAIL )

	PrecacheModel( OUTER_RING_CHUNK_MAIN )
	PrecacheModel( MIDDLE_RING_CHUNK_MAIN )
	PrecacheModel( INNER_RING_CHUNK_MAIN )

	PrecacheModel( $"models/dev/editor_ref.mdl" )

	PrecacheModel( LARGE_BEAM )

	PrecacheModel( TRUCK )
	PrecacheModel( GOBLIN_DEBRIS_CABIN )
	PrecacheModel( GOBLIN_DEBRIS_WING_LEFT )
	PrecacheModel( GOBLIN_DEBRIS_WING_RIGHT )

	PrecacheModel( $"models/rocks/rock_jagged_granite_flat_02.mdl" )

	PrecacheModel( SMALL_ROCK_01 )
	PrecacheModel( SMALL_ROCK_02 )
	PrecacheModel( SMALL_ROCK_03 )
	PrecacheModel( SMALL_ROCK_04 )
	PrecacheModel( SMALL_ROCK_05 )
	PrecacheModel( SMALL_ROCK_06 )
	PrecacheModel( SMALL_ROCK_07 )

	PrecacheModel( STRATON_SB_MODEL )

	//SCULPTOR CORE ASSETS
	PrecacheModel( CORE_ENERGY )
	PrecacheParticleSystem( FX_CORE_FLARE )
	PrecacheParticleSystem( FX_CORE_GLOW )

	PrecacheParticleSystem( COCKPIT_LIGHT )

	//------------------
	// Start points
	//------------------
					//startPoint, 					mainFunc,							setupFunc							skipFunc
	AddStartPoint( "Level Start", 					STARTHELEVEL, null, null )
	AddStartPoint( "Torture Room B",				STARTHELEVEL, null, null )
	AddStartPoint( "Smart Pistol Run",				STARTHELEVEL, null, null )
	AddStartPoint( "Bridge Fight", 					STARTHELEVEL, null, null )
	AddStartPoint( "BT Reunion", 					STARTHELEVEL, null, null )
	AddStartPoint( "Titan Hill",					STARTHELEVEL, null, null )
	AddStartPoint( "Titan Smash Hallway",			STARTHELEVEL, null, null )
	AddStartPoint( "Sculptor Climb",				STARTHELEVEL, null, null )
	AddStartPoint( "Targeting Room",				STARTHELEVEL, null, null )
	AddStartPoint( "Injector Room",					STARTHELEVEL, null, null )
	AddStartPoint( "Blisk's Farewell",				STARTHELEVEL, null, null )
	AddStartPoint( "BT Sacrifice",					STARTHELEVEL, null, null )
	AddStartPoint( "Rising World Run",				STARTHELEVEL, null, null )
	AddStartPoint( "Rising World Jump",				STARTHELEVEL, null, null )
	AddStartPoint( "Exploding Planet",				STARTHELEVEL, null, null )
	AddStartPoint( "Harmony",						STARTHELEVEL, null, null )

	// FlagInit( "BreakWorld" )


	// AddScriptNoteworthySpawnCallback( "die_at_end", NPC_DieAtPathEnd )
	// AddScriptNoteworthySpawnCallback( "bridge_turrets", BridgeTurretsSpawnThink )
	// AddScriptNoteworthySpawnCallback( "no_self_damage", AISetNoSelfDamage )
	// AddScriptNoteworthySpawnCallback( "bombard_me", BombardTarget )
	// AddScriptNoteworthySpawnCallback( "bombard_me_instant", BombardTargetInstant )
	// AddScriptNoteworthySpawnCallback( "npc_bullseye", BullseyeSettings )

	// AddSpawnCallback_ScriptName( "titan_hill_turret", 	EnableMegaTurret )
	// AddSpawnCallback_ScriptName( "trigger_level_signal", TriggerSignal )
	// AddSpawnCallback_ScriptName( "disable_disembark_trigger", TriggerDisableDisembark )
	// AddSpawnCallback_ScriptName( "random_flying_chunks", RandomFlyingChunksThink )
	// AddSpawnCallback_ScriptName( "random_rotating_chunks", RandomRotatingChunksThink )
	// AddSpawnCallback_ScriptName( "world_run_sound_emitter", WorldRunSoundEmitterThink )
	// // AddSpawnCallback_ScriptName( "fake_guy_spawner", FakeGuySpawnerThink )

	// AddClientCommandCallback( "enable_jumpkit", ClientCommand_EnableJumpkit )
	// AddClientCommandCallback( "ClientCommand_RequestTitanFake", ClientCommand_RequestTitanFake )
	// AddClientCommandCallback( "ClientCommand_Pulldown", ClientCommand_Pulldown )
	// AddClientCommandCallback( "ClientCommand_StopPulldown", ClientCommand_StopPulldown )

	// AddDeathCallback( "npc_turret_mega", SpawnTitanBatteryOnDeath )
	// AddDamageCallbackSourceID( eDamageSourceId.bombardment, Bombardment_DamagedEntity )

	// AddCallback_OnLoadSaveGame( RestartInjectorSounds )

	// FlagSet( "DogFights" )
	// FlagSet( "FlightPath_TitanDrop" )

	// Credits_MapInit() //MUST BE THE LAST ENTRY

	array<vector> origins = [ <6683.55, -2433.11, 2906.24>, <6003.59, -3081.41, 2840.37>, <6805.31, -2863.7, 2813.38>, <8502.47, -3836.56, 2994.33>, <7418.28, -3329.43, 2794.07>, <8219.36, -3671.74, 2929.99>, <8094.24, -3246.91, 2896.91>, <7898.12, -1917.1, 3141.06> ]

	foreach( vector origin in origins )
	{
		entity ref = CreateScriptRef( origin, < 0.0, 0.0, 0.0 > )
		ref.SetScriptName( "BrawlSpawnNode2" )
	}

	origins = [ <11166.4, -783.351, 3521.98>, <9905.15, -323.603, 3543.7>, <10141.4, 975.395, 3738.8>, <9829.18, 829.99, 3768.68>, <9485.63, 1619.5, 3990.99>, <8984.73, 1263.57, 3983.4>, <10445.9, -21.0667, 3522.93> ]

	foreach( vector origin in origins )
	{
		entity ref = CreateScriptRef( origin, < 0.0, 0.0, 0.0 > )
		ref.SetScriptName( "BrawlSpawnNode3" )
	}
}

void function LightstripSounds()
{

}

void function DoWorldRumble( entity player )
{

}

void function InjectorSpoolDown( entity player, float delayBetweenFlaps = 0.3 )
{

}

void function InjectorFire( bool fireSound = true )
{

}

void function InjectorLightUp( entity player, float delayBetweenFlaps = 0.3, bool doFlash = false )
{

}

void function Init_FloatingWorldStuff()
{
	entity runDriverS = GetEntByScriptName( "run_driver_starting_area" )
	entity runDriver = GetEntByScriptName( "run_driver" )
	entity runDriver2 = GetEntByScriptName( "run_driver_02" )
	entity runDriver3 = GetEntByScriptName( "run_driver_03" )
	entity runDriver4 = GetEntByScriptName( "run_driver_04" )

	array<entity> debrisMid = GetEntArrayByScriptName( "floating_debris" )
	HideAllInArray( debrisMid )

	entity startingArea = GetEntByScriptName( "starting_boulder" )

	entity node = GetEntByScriptName( "rising_world_run_landing_node" )
	entity mover = CreateScriptMover()
	vector fwd = AnglesToForward( node.GetAngles() )
	mover.SetOrigin( node.GetOrigin() + < 0,0,-37 >  )
	mover.SetAngles( node.GetAngles() )
	mover.SetParent( startingArea )
	file.worldRunLandingNode = mover

	thread FloatingIslandThread( startingArea, true, runDriverS, "StartLandingAreaRise", < 360, 0, 360 > )

	array<entity> islands = GetEntArrayByScriptName( "floating_island" )
	foreach ( entity island in islands )
	{
		thread FloatingIslandThread( island, true, runDriver )
	}

	array<entity> islands2 = GetEntArrayByScriptName( "floating_island_grp_2" )
	foreach ( entity island2 in islands2 )
	{
		thread FloatingIslandThread( island2, true, runDriver2 )
	}

	entity island2BreakLoose = GetEntByScriptName( "floating_island_grp_2_break_loose" )
	entity breakLooseRock = GetEntByScriptName( "rock_break_loose_01" )
	breakLooseRock.SetParent( island2BreakLoose, "", true )
	thread FloatingIslandThread( island2BreakLoose, true, runDriver2 )

	array<entity> islands3 = GetEntArrayByScriptName( "floating_island_grp_3" )
	foreach ( entity island3 in islands3 )
	{
		thread FloatingIslandThread( island3, true, runDriver3 )
	}

	array<entity> islands4 = GetEntArrayByScriptName( "floating_island_grp_4" )
	foreach ( entity island4 in islands4 )
	{
		thread FloatingIslandThread( island4, true, runDriver4 )
	}

	entity redirectIsland = GetEntByScriptName( "floating_island_redirect" )
	thread FloatingIslandThread( redirectIsland, true, runDriver2 )

	entity tiltingIsland = GetEntByScriptName( "floating_island_turning" )
	thread FloatingIslandThread( tiltingIsland, true, runDriver4 )

	entity destroyedIsland = GetEntByScriptName( "floating_island_destroyed" )
	thread FloatingIslandThread( destroyedIsland, true, runDriver )

	entity destroyedIsland2 = GetEntByScriptName( "floating_island_destroyed_2" )
	thread FloatingIslandThread( destroyedIsland2, true, runDriver3 )

	entity fogTrigger = GetEntByScriptName( "world_run_fog_trigger" )
	fogTrigger.SetOrigin( fogTrigger.GetOrigin() - <0,0,10000> )
}

void function FloatingIslandThread( entity island, bool useSyncedRot, entity runDriver, string startFlag = "StartRise", vector rotArc = < 360, 360, 360 >, vector startOff = <0.0,0.0,0.0>, vector startRotOff = <0.0,0.0,0.0> )
{

	island.EndSignal( "OnDestroy" )
	island.EndSignal( "RockStrike" )

	float time = RandomFloatRange( 0, 10 )
	float spinXMod = RandomFloatRange( -1, 1 )
	float spinYMod = RandomFloatRange( -1, 1 )
	float spinZMod = RandomFloatRange( -1, 1 )

	//float sinkDist = 2048
	float sinkDist = 4096
	float riseSpeed = 32
	float riseSpeadIncrement = 1.01
	float spinSpeed = .75
	//float sinkDist = RandomFloatRange( 2048, 4096 )

	vector startingPos = island.GetOrigin()
	vector startingAngles = island.GetAngles()
	vector sinkPos = startingPos - < 0, 0, -sinkDist >

	entity collision = island
	if ( island.GetLinkEnt() != null )
	{
		collision = island.GetLinkEnt()
		collision.SetParent( island )
	}

	string editorClass = GetEditorClass( island )
	if ( editorClass == "script_mover" || editorClass == "script_mover_lightweight" || editorClass == "script_rotator" )
	{
		island.SetPusher( true )
	}

	//entity mover = CreateScriptMover( startingPos, < 0, 0, 0 >, 0 )
	entity mover = CreateScriptMover( startingPos, startingAngles, 0 )
	island.SetParent( mover, "", true )
	mover.SetPusher( true )

	//vector startingAngles = mover.GetAngles()
	bool rise = false
	//mover.SetOrigin( < startingPos.x, startingPos.y, startingPos.z - sinkDist > )

	mover.EndSignal( "OnDestroy" )
	//runDriver.SetModel( $"models/dev/editor_ref.mdl" )
	//runDriver.Show()

	entity hideRef = GetEntByScriptName( "run_stuff_hide_ref" )

	mover.SetOrigin( hideRef.GetOrigin() )

	FlagWait( startFlag )

	mover.SetOrigin( startingPos - < startOff.x, startOff.y, sinkDist> )
	mover.SetAngles( mover.GetAngles() + startRotOff )

	while ( true )
	{
		time += .1
		entity player = GetPlayerByIndex( 0 )

		if ( IsValid( player ) )
		{

			//mover.SetModel( $"models/dev/editor_ref.mdl" )
			//mover.Show()

			float dist2 = DistanceSqr( runDriver.GetOrigin(), startingPos )
			float dist2Start = DistanceSqr( mover.GetOrigin(), startingPos )
			float dist2Clamped = clamp( dist2, 0, sinkDist * sinkDist )
			float modSinkDist = dist2Clamped / ( sinkDist * sinkDist )
			float modSpinRate = dist2 / ( sinkDist * sinkDist )

			float bob = sin( time )
			//float spin = 360 * modSpinRate
			float spinX = rotArc.x * modSpinRate
			float spinY = rotArc.y * modSpinRate
			float spinZ = rotArc.z * modSpinRate

			float xSpin = clamp( ( spinX * spinSpeed ) , 0, 360 )
			float ySpin = clamp( ( spinY * spinSpeed ) , 0, 360 )
			float zSpin = clamp( ( spinZ * spinSpeed ) , 0, 360 )
			vector spinVector = < xSpin, ySpin, zSpin >
			//printt( modSinkDist )

			vector playerDir = Normalize( player.GetOrigin() - mover.GetOrigin() )
			playerDir *= 32 //< playerDir.x * 32, playerDir.y * 32, playerDir.z * 128 >

			if ( dist2 <= 300 * 300 && dist2Start <= 300 * 300 )
				rise = true

			if ( rise )
			{
				//mover.NonPhysicsMoveTo( mover.GetOrigin() + < 0, 0, riseSpeed >, .5, 0, .1 )
				//riseSpeed *= riseSpeadIncrement
				//mover.NonPhysicsMoveTo( ( startingPos + playerDir ) + < bob * 16, bob * 16, ( sinkDist * modSinkDist ) + ( bob * 64 ) >, .5, 0, .1 )
				mover.NonPhysicsMoveTo( ( startingPos + playerDir ) + < 0, 0, ( sinkDist * modSinkDist ) >, .5, 0, 0 )
				spinVector *= -1
			}
			else
			{
				//mover.NonPhysicsMoveTo( ( startingPos + playerDir ) - < bob * 16, bob * 16, ( sinkDist * modSinkDist ) + ( bob * 64 ) >, .5, 0, .1 )
				mover.NonPhysicsMoveTo( ( startingPos + playerDir ) - < 0, 0, ( sinkDist * modSinkDist ) > , .5, 0, 0 )
			}

			if ( !useSyncedRot )
			{
				mover.NonPhysicsRotate( < bob / 2, bob / 2, bob / 2 >, 5 )
			}
			else
			{
				vector angles = startingAngles + spinVector
				angles.x = AngleNormalize( angles.x )
				angles.y = AngleNormalize( angles.y )
				angles.z = AngleNormalize( angles.z )
				mover.NonPhysicsRotateTo( angles, .5, 0, .1 )
			}

			if ( mover.GetOrigin().z - startingPos.z >= sinkDist )
			{
				return
				//island.ClearParent()
				//island.Destroy()
				//mover.Destroy()
			}

		}

		wait( .1 )
	}
}

//Callback checking if the map entities loaded
void function EntitiesDidLoad()
{
	FlagInit( "aiskit_dontbreakout" )
	FlagInit( "bombardment_env_target_01" )
	FlagInit( "bombardment_titan_target_01" )
	FlagInit( "bombardment_target_01" )
	Init_FloatingWorldStuff()


}

void function STARTHELEVEL( entity player )
{
	thread PutPlayerOnSpawnPoint( player )
}
