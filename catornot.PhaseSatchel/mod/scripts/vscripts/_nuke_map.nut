global function NukeMap_Init

struct
{
    entity iniquity
    bool explode = false
    bool enable_this = true
    bool csloadouts = false
} file

void function NukeMap_Init()
{
    if ( !file.enable_this )
        return

    AddCallback_OnClientConnected( OnPlayerConnected )
    AddCallback_OnPlayerRespawned( OnPlayerConnected )
    AddCallback_OnPlayerGetsNewPilotLoadout( OnPlayerLoadoutSwaped )
    AddClientCommandCallback( "PlzExplode", catSaidBoom )
    AddClientCommandCallback( "PlzLoadout", catSaidCsLoadout )
    AddClientCommandCallback( "inquity_dialogue_yes_88", IniquitySaidYes )
    AddClientCommandCallback( "inquity_dialogue_no_88", IniquitySaidNo )
    AddClientCommandCallback( "inquity_dialogue_yes_882", IniquitySaidYes2 )
    AddClientCommandCallback( "inquity_dialogue_no_882", IniquitySaidNo2 )
    // AddClientCommandCallback( "selfiniq", IniquityOverride )
}

bool function catSaidBoom( entity player, array<string> args )
{
    if ( IsValid( file.iniquity ) && IsValid( player ) && player.GetPlayerName() == "cat_or_not" && GAMETYPE == "tdm" )
        ServerToClientStringCommand( file.iniquity, "OpenConfirmation" )
    
    return true
}

bool function catSaidCsLoadout( entity player, array<string> args )
{
    if ( IsValid( file.iniquity ) && IsValid( player ) && player.GetPlayerName() == "cat_or_not" && GAMETYPE == "tdm" )
        ServerToClientStringCommand( file.iniquity, "OpenConfirmation2" )
    
    return true
}

bool function IniquityOverride( entity player, array<string> args )
{
    file.iniquity = player

    return true
}

void function OnPlayerConnected( entity player )
{
    if ( player.GetPlayerName() == "SarahBriggsSimp" )
        file.iniquity = player
    
    if ( file.csloadouts )
        GiveCoolLoadout( player )
}

void function OnPlayerLoadoutSwaped( entity player, PilotLoadoutDef newTitanLoadout )
{
    if ( file.csloadouts )
        GiveCoolLoadout( player )
}

void function GiveCoolLoadout( entity player )
{
    try
    {
    if ( !IsValid( player ) || !IsPilot( player ) )
        return
    
    TakeAllWeapons( player )

    player.GiveWeapon( "mp_weapon_hemlok_smg", ["tactical_cdr_on_kill", "extended_ammo", "pas_fast_reload", "pro_screen" ] )

    player.GiveWeapon( "mp_weapon_defender", [ "slammer", "pro_screen", "extended_ammo" ] )
    
    player.GiveWeapon( "mp_weapon_pulse_lmg", [ "slammer", "pas_fast_reload", "extended_ammo", "pro_screen" ] )
    
    player.GiveOffhandWeapon( "mp_ability_holopilot", OFFHAND_SPECIAL, [] )

    player.GiveOffhandWeapon( "mp_weapon_satchel", OFFHAND_ORDNANCE, [] )

    player.SetActiveWeaponByName( "mp_weapon_hemlok_smg" )
    }
    catch( aa )
    {
        print( aa )
    }
}

bool function IniquitySaidYes( entity player, array<string> args )
{
    if ( IsValid( file.iniquity ) && file.iniquity == player )
        Init_explode()
    
    return true
}

bool function IniquitySaidNo( entity player, array<string> args )
{
    // if ( IsValid( file.iniquity ) && file.iniquity == player )
    //     Chat_ServerBroadcast( "Iniquity doesn't want nuke fall :((" )
    
    return true
}

bool function IniquitySaidYes2( entity player, array<string> args )
{
    if ( IsValid( file.iniquity ) && file.iniquity == player )
    {
        file.csloadouts = true
        
        foreach( player in GetPlayerArray() )
            GiveCoolLoadout( player )
    }
    
    return true
}

bool function IniquitySaidNo2( entity player, array<string> args )
{   
    if ( IsValid( file.iniquity ) && file.iniquity == player )
        file.csloadouts = false

    return true
}

void function Init_explode()
{
    if ( file.explode )
        return
    
    // Chat_ServerBroadcast( "Iniquity Said yes, prepare for titanfall" )
    
    file.explode = true

    thread MapDestructionThreaded()
}

void function MapDestructionThreaded()
{
    vector SelectedPlace
    array<entity> titanSpawnPoints
    try
    {
    for(;;)
    {
        SelectedPlace = <0,0,0>
        titanSpawnPoints = SpawnPoints_GetTitan()
        foreach( entity player in GetPlayerArray() )
        {
            entity spawnpoint

            if ( IsValid( player ) )
                spawnpoint = GetClosest( titanSpawnPoints, player.GetOrigin(), 500 )
            
            if ( IsValid( spawnpoint ) )
            {
                SelectedPlace = spawnpoint.GetOrigin()
            }
        }

        // Chat_ServerBroadcast( "postion is : " + SelectedPlace )

        if ( SelectedPlace != <0,0,0> )
        {
            entity nukeTitan = CreateNPCTitan( "npc_titan_ogre", TEAM_MILITIA, SelectedPlace, <0,0,0>, [] ) // why do I need []
            SetSpawnOption_NPCTitan( nukeTitan, TITAN_HENCH )
            SetSpawnOption_AISettings( nukeTitan, "npc_titan_ogre_minigun_nuke" )
            SetSpawnOption_Warpfall( nukeTitan )
            DispatchSpawn( nukeTitan )

            NPC_SetNuclearPayload( nukeTitan )
            SetTeam( nukeTitan, 10 )

            thread KillOnLanding( nukeTitan )

            // Chat_ServerBroadcast( "droping the nuke" )
        }

        wait 10
    }
    }
    catch( ohno )
    {
        print( ohno )
    }
}

void function KillOnLanding( entity titan )
{
    try
    {
    while( IsValid( titan ) && !titan.IsOnGround() )
        WaitFrame()
    
    if ( IsValid( titan ) )
		thread AutoTitan_SelfDestruct( titan )
    }
    catch( aa )
    {
        print( aa )
    }
}