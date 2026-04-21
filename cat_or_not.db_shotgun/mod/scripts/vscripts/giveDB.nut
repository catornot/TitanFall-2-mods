global function Init_GiveDB

void function Init_GiveDB()
{
    if ( IsLobby() )
        return
    
    AddCallback_OnPlayerRespawned( GiveDBConditional )
    AddCallback_OnPlayerGetsNewPilotLoadout( OnPlayerLoadoutSwaped )
}

void function GiveDBConditional( entity player )
{
    thread GiveDBConditionalThreaded( player )
}

void function GiveDBConditionalThreaded( entity player )
{
    EndSignal( player, "OnDeath" )
    EndSignal( player, "OnDestroy" )
    EndSignal( player, "PlayerEmbarkedTitan" )

    wait 1

    int loadoutIndex = GetActivePilotLoadoutIndex(player)
    PilotLoadoutDef loadout = GetPilotLoadoutFromPersistentData(player, loadoutIndex)

    if ( loadout.primary != "mp_weapon_mastiff" ) 
        return
    
    if ( player.IsTitan() ) 
        return
        
    if ( !loadout.primaryMods.contains("pas_fast_ads") ) // !loadout.primaryAttachments.contains("pas_fast_ads") && 
        return
    
    // player.TakeWeaponNow( "mp_weapon_shotgun_doublebarrel" )
    TakePrimaryWeapon( player )
    player.GiveWeapon( "mp_weapon_shotgun_doublebarrel" )
}

void function OnPlayerLoadoutSwaped( entity player, PilotLoadoutDef newTitanLoadout )
{
    GiveDBConditional( player )
}

void function printarray(array<string> arr)
{
    foreach( string s in arr )
        printt( s )
}

