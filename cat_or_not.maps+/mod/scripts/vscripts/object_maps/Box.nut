global function placeBoxObjects
#if RecAnTest
global function testRecAnTestRec
global function testRecAnTestPlay
global function testRecAnTestBot
#endif

const vector weaponsSpawn = < -1730, -3060, 100 >

void function placeBoxObjects()
{
	PrecacheModel( $"models/northstartee/winter_holiday_tree.mdl" )
    CreatePropDynamic( $"models/northstartree/winter_holiday_tree.mdl", < -0, 0, 0 >, < 0, 0, 0 >, SOLID_BBOX, 1000 )

    if ( GetDisabledElements().contains( "box_test" ) )
        return

    InitKeyTracking()
    entity button = CreateSimpleButton( weaponsSpawn, <90, 90, 0>, "to spawn weapons", callback_WeaponsButtonTriggered )
    entity button2 = CreateSimpleButton( weaponsSpawn - <1000,0,0>, <90, 90, 0>, "to spawn a dropship", callback_dropShipButtonTriggered, 10.0 )
    CreateSimpleButton( weaponsSpawn - <1100,0,0>, <90, 90, 0>, "to become a pilot", callback_pilotButtonTRiggered, 10.0 )
    CreateSimpleButton( weaponsSpawn - <1200,0,0>, <90, 90, 0>, "to become a titan", callback_titanButtonTRiggered, 10.0 )
    CreateSimpleButton( weaponsSpawn - <1300,0,0>, <90, 90, 0>, "test decoy", callback_decoyTest, 1.0 )
    CreateSimpleButton( < -144, -1175, 352 >, <0, 90, 0>, "to start testing", callback_TestingButtonPressed, 10.0 )
    CreateNessyMessager( button2.GetOrigin() + <0,30,-300>, <0,180,0>, "" )
    CreateSimpleButton( < -5037, 3318 ,0 >, <0, 0, 0>, "to train you aim XD", callback_AimTrainner, 30.0 )

    CreateSimpleButton( < -4000, 3318 ,0 >, <0, 0, 0>, "spawn clone", callback_cloneSpawn, 30.0 )

    CreateNessy( <0, 2214, 576>, <0, 60, 0>, 9 )

    SpawnWeapons()

    entity mover = CreateExpensiveScriptMoverModel( $"models/communication/terminal_usable_imc_01.mdl", <100, 2214, 576>, <0,0,0>, SOLID_VPHYSICS, 5000 )
    mover.kv.contents = ( int( mover.kv.contents ) | CONTENTS_MOVEABLE )

    CreatePropDynamic( $"models/ball/sphere_conv.mdl", <100, 2214, 700> )

    AddCallback_EntitiesDidLoad( EntitiesDidLoad )

    entity ref = CreateScriptMover()
    ref.SetOrigin( <500, 2214, 576> )
    ref.SetScriptName("wewewe")
}

void function EntitiesDidLoad()
{
 //    entity brush = CreateEntity( "func_train" )
	// brush.SetValueForModelKey( $"models/robots/mobile_hardpoint/mobile_hardpoint.mdl" )
 //    DispatchSpawn( brush )
 //    brush.SetOrigin( <100, 2214, 600> )

    thread RunRecordingLoop()
}

void function SpawnWeapons()
{
    array<string> weapons = GetAllWeaponsByType( [ eItemTypes.PILOT_PRIMARY, eItemTypes.PILOT_SECONDARY ] )

    for ( int x = 0; x < weapons.len(); x++ )
    {
        entity weapon = CreateWeaponEntityByNameConstrained( weapons[x], weaponsSpawn + < ( x + 1 )*-30, 0, 0 >, <90,90,0> )
        weapon.SetScriptName( "weapon_pickup" )
    }      
}

void function DestoryWeapons()
{
    foreach( entity weapon in GetEntArrayByScriptName( "weapon_pickup" ) )
    {
        if ( !IsValid( weapon.GetParent() ) )
            weapon.Destroy()
    }
}

void function callback_WeaponsButtonTriggered( entity button, entity player )
{
    DestoryWeapons()
    SpawnWeapons()
}

void function callback_pilotButtonTRiggered( entity button, entity player )
{
    if ( !player.IsTitan() )
        return
    
    entity t = CreateAutoTitanForPlayer_ForTitanBecomesPilot( player )
		
    TitanBecomesPilot( player, t )
    t.Destroy()
}

void function callback_titanButtonTRiggered( entity button, entity player )
{
    if ( player.IsTitan() )
        return

    entity t = player.GetPetTitan()
    if ( !IsValid( player.GetPetTitan() ) )
    {
        t = CreateAutoTitanForPlayer_FromTitanLoadout( player, GetTitanLoadoutForPlayer( player ), player.GetOrigin(), <0,0,0> )
        DispatchSpawn( t )
    }

    PilotBecomesTitan( player, t )

    t.Destroy()
}

void function callback_decoyTest( entity button, entity player )
{
    if ( !player.IsPlayer() )
        return

	entity decoy = CreateHoloPilotDecoys( player )
    printt(decoy)
    thread decoyTestThreaded( decoy, player )
}

void function decoyTestThreaded( entity decoy, entity player )
{
    decoy.EndSignal("OnDestroy")
    player.EndSignal("OnDestroy")
    decoy.EndSignal("OnDeath")

    #if BP_ORT
    // for(int i = 0; i < 13 * 100; i++) {
    //     print("setting state " + i % 13)
    //     SendHudMessage( player, "setting state " + i % 13, -1, 0.4, 255, 69, 0, 255, 0, 2, 0 )
    //     wait 1
    //     DecoySetState(decoy, i % 13)
    //     // wait 0.1
    // }    

    int i = 7;
    SendHudMessage( player, "setting state " + i, -1, 0.4, 255, 69, 0, 255, 0, 2, 0 )
    wait 1
    // DecoySetState(decoy, i)
    #endif
}

void function callback_TestingButtonPressed( entity button, entity player )
{
    if ( !IsAlive( player ) )
        return

    ReplacePlayerOrdnance( player, "mp_weapon_satchel", [] )
    ServerCommand("sv_cheats 1")
    // ServerCommand("script print(__CallHookTrampoline(\"EntityShouldStick\", GetPlayerArray()[0],GetPlayerArray()[0])) ")
    ServerCommand("script __CallHookTrampoline(\"SimpleFunc\", 1)")
    // ServerCommand("script TestHookCall(SimpleFunc_Hook) ")
    
    #if RecAnTest || RANIM
    thread QuickRecTest()
    #endif
}

void function RunRecordingLoop()
{
    for(;;)
    {
        waitthread PlayRecoding_recording_loop()
    }
}

void function callback_AimTrainner( entity button, entity player )
{
    thread PlayRecoding_recording_aim()
}

#if RecAnTest || RANIM
void function QuickRecTest() {
    wait 0.1

    waitthread testRecAnTestRec()

    wait 0.5

    thread testRecAnTestPlay()
}

void function testRecAnTestRec() {
    entity player = GetPlayerByIndex(0)
    entity ref = GetEntArrayByScriptName("wewewe")[0]

    player.StartRecordingAnimation( ref.GetOrigin(), ref.GetAngles() )

    while (!GetPlayerKeysList( player )[KU])
    { 
        wait 0
    }

    wait 1

    var recording = player.StopRecordingAnimation()

    player.PlayRecordedAnimation( recording, <0,0,0>, <0,0,0>, DEFAULT_SCRIPTED_ANIMATION_BLEND_TIME, GetEntArrayByScriptName("wewewe")[0] )

    print(recording)

    // WriteTestAnim(recording)
    RSaveRecordedAnimation( recording, "test" )
}

void function testRecAnTestPlay() {
    entity player = GetPlayerByIndex(0)
    entity decoy = CreateElitePilot( player.GetTeam(), player.GetOrigin(), player.GetAngles() )
    decoy.SetModel( player.GetModelName() )
    DispatchSpawn( decoy )
    decoy.SetModel( player.GetModelName() )

    decoy.SetTitle( player.GetPlayerName() )
    decoy.SetScriptName( player.GetPlayerName() + "_decoy" )

    OnThreadEnd(
		function() : ( decoy )
		{
			if ( IsAlive( decoy ) )
				decoy.Die()
		}
	)

    // var recording = ReadTestAnim()
    var recording = RReadRecordedAnimation( "test" )

    decoy.PlayRecordedAnimation( recording, <0,0,0>, <0,0,0>, DEFAULT_SCRIPTED_ANIMATION_BLEND_TIME, GetEntArrayByScriptName("wewewe")[0] )
    wait GetRecordedAnimationDuration( recording ) + 5
}

void function testRecAnTestBot() {
    entity decoy = GetPlayerByIndex(1)

    // var recording = ReadTestAnim()
    var recording = RReadRecordedAnimation( "test" )

    decoy.PlayRecordedAnimation( recording, <0,0,0>, <0,0,0>, DEFAULT_SCRIPTED_ANIMATION_BLEND_TIME, GetEntArrayByScriptName("wewewe")[0] )
    wait GetRecordedAnimationDuration( recording ) + 5
}

void function callback_cloneSpawn( entity button, entity player ) {
    thread callback_cloneSpawnThreaded( player, button )
}

void function callback_cloneSpawnThreaded( entity player, entity ref ) {
	TitanLoadoutDef loadout = GetTitanLoadoutForPlayer( player )
	entity decoy = CreateAutoTitanForPlayer_FromTitanLoadout( player, loadout, player.GetOrigin() + <0,0,1000>, player.GetAngles())
	DispatchSpawn( decoy )

    decoy.SetTitle( player.GetPlayerName() )
    decoy.SetScriptName( player.GetPlayerName() + "_decoy" )
   
	decoy.SetDeathNotifications( true )
	decoy.SetPassThroughThickness( 0 )
	decoy.SetNameVisibleToOwner( true )
	decoy.SetNameVisibleToFriendly( true )
	decoy.SetNameVisibleToEnemy( true )
    decoy.Freeze()

    OnThreadEnd(
		function() : ( decoy )
		{
			if ( IsAlive( decoy ) )
				decoy.Die()
		}
	)

    wait 2

    player.StartRecordingAnimation( ref.GetOrigin(), ref.GetAngles() )
	player.EndSignal( "OnDeath" )

    while (!GetPlayerKeysList( player )[KU])
    { 
        wait 0
    }

    wait 1

    var recording = player.StopRecordingAnimation()

    decoy.Unfreeze()
    for(;;) {
        decoy.PlayRecordedAnimation( recording, <0,0,0>, <0,0,0>, DEFAULT_SCRIPTED_ANIMATION_BLEND_TIME, ref )
        wait GetRecordedAnimationDuration( recording ) + 0.1
    }    
}


#endif
