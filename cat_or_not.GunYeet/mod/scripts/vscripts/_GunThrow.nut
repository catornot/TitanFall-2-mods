global function GunTrow_init

struct
{
    entity marvin
}
file

void function GunTrow_init()
{
    if ( IsLobby() || GetCurrentPlaylistVarInt( "GUNYEET", 0 ) == 0 )
        return

    AddCallback_OnClientConnected( OnPlayerConnected )
    // AddCallback_EntitiesDidLoad( EntitiesDidLoad )
}

void function EntitiesDidLoad()
{
    entity mover = CreateScriptMover( <0,1000,0> )

    entity marvin = CreateMarvin( TEAM_ANY, <0,1000,0>, <0,0,0> )
    DispatchSpawn( marvin )
    marvin.SetParent( mover )
    marvin.SetInvulnerable()
    marvin.MakeInvisible()
    HideName( marvin )
	thread PlayAnim( marvin, "commander_MP_flyin_marvin_idle", mover )

    TakeAllWeapons( marvin )
    // marvin.GiveWeapon( "mp_titanweapon_rocketeer_rocketstream" )
    // marvin.SetActiveWeaponByName( "mp_titanweapon_rocketeer_rocketstream" )
    marvin.GiveOffhandWeapon( "mp_weapon_grenade_emp", OFFHAND_ORDNANCE, [] )

    file.marvin = marvin
}

void function OnPlayerConnected( entity player )
{
    AddButtonPressedPlayerInputCallback( player, IN_USE, PlayerUSE )
    AddButtonPressedPlayerInputCallback( player, IN_USE_AND_RELOAD, PlayerUSE )
}

void function PlayerUSE( entity player )
{
    thread HandleUsePressForGunThrow( player )
}

void function HandleUsePressForGunThrow( entity player )
{

    if ( !IsValid( player ) || !IsAlive( player ) || player.IsTitan() || IsValid( player.GetParent() ) )
        return
    
    EndSignal( player, "OnDeath" )
    EndSignal( player, "OnDestroy" )
    EndSignal( player, "PlayerEmbarkedTitan" )
	EndSignal( player, "PlayerDisembarkedTitan" )

    EmitSoundOnEntityOnlyToPlayer( player, player, "weapon_fraggrenade_pinpull" )

    entity weapon = player.GetActiveWeapon()
    if ( !IsValid( weapon ) )
        return
    
    for( int x = 0; x < 3; x++ )
    {
        if ( !player.IsInputCommandHeld( IN_USE ) && !player.IsInputCommandHeld( IN_USE_AND_RELOAD ) )
            return
        
        if ( IsValid( player.GetParent() ) )
            return
        
        EmitSoundOnEntityOnlyToPlayer( player, player, "weapon_fraggrenade_pinpull" )

        wait 0.5
    }

    if ( !player.IsInputCommandHeld( IN_USE ) && !player.IsInputCommandHeld( IN_USE_AND_RELOAD )  )
        return
    
    if ( IsValid( player.GetParent() ) )
            return
    
    EmitSoundOnEntityOnlyToPlayer( player, player, "UI_PlayerDialogue_Notification" )
    
    TryFireWeapon( player )
}

void function TryFireWeapon( entity player )
{
	entity pweapon = player.GetActiveWeapon()
    if ( !IsValid( pweapon ) )
        return

    asset model = pweapon.GetModelName()
	
    entity owner = player
	entity weapon = owner.GetOffhandWeapon( OFFHAND_ORDNANCE )

    if ( !IsValid( weapon ) )
        return

    WaitFrame()
    
	bool shouldPredict = weapon.ShouldPredictProjectiles()

	vector attackDir = player.GetViewVector()
    print( attackDir )
	vector attackPos = player.EyePosition()

    EmitSoundAtPosition( player.GetTeam(), player.GetOrigin(), "weapon_r101_unequip" )

	entity nade = weapon.FireWeaponGrenade( attackPos, attackDir * 20, attackDir, 0.5, damageTypes.projectileImpact, damageTypes.explosive, false, true, false )

	if ( nade )
	{
        nade.SetModel( model )
		nade.SetOwner( player )
        SetTeam( nade, player.GetTeam() )
    }
    
    if ( !IsValid( pweapon ) )
        return
    
    try{
        player.TakeWeapon( pweapon.GetWeaponClassName() )
    }
    catch( aaa )
    {
        print( aaa )
    }
    
}