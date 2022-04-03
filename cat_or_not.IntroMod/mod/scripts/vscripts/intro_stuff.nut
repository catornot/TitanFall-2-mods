untyped

global function CustomIntro_Setup
global function CustomIntro_GetLength

global const float CUSTOMINTRO_INTRO_PILOT_LENGTH = 6.0

const array<string> PossibleAnimation = [ 
    "pt_mp_execution_attacker_nb",
    "pt_mp_execution_attacker_stab",
    "pt_mp_execution_attacker_steal",
    "pt_mp_execution_attacker_mh",
    "pt_mp_execution_attacker_kick",
    "pt_mp_execution_attacker_phaseshift",
    "pt_mp_execution_attacker_stim",
    "pt_mp_execution_attacker_grapple",
    "pt_mp_execution_attacker_pulseblade",
    "pt_mp_execution_attacker_cloak",
    "pt_mp_execution_attacker_holo",
    "pt_mp_execution_attacker_awall"
    // "pt_mp_execution_attacker_nb",

]

const target_player_angle = <0,270,0>
const camera_angle = <0,90,0>



struct{
    array<entity> visited
    table<string,vector> playerLocations
    entity visiting
    entity camera
    entity mover
    bool IntroEnded = false
    bool noCustomIntros = false
} file 

void function CustomIntro_Setup()
{

	AddCallback_OnClientConnected( CustomIntro_SpawnPlayer )
	AddCallback_GameStateEnter( eGameState.Prematch, CustomIntro_Start )
    
    
    vector origin = <0,0,4000>
		
    file.camera = CreateEntity( "point_viewcontrol" )
	file.camera.kv.spawnflags = 56
    file.camera.kv.rendermode = 3

	file.camera.SetOrigin( origin )
	file.camera.SetAngles( <0,0,0> )
	DispatchSpawn( file.camera )

    file.mover = CreateExpensiveScriptMover()

    file.mover.SetOrigin( origin )
    
    
	file.mover.SetAngles( <0,0,0> )
    file.camera.SetParent( file.mover )
    
    if ( GetIntroRiff() )
		thread start_CustomIntro()
    else if ( GetMarvinRiff() )
		thread start_CustomMarvinIntro()
    else 
        file.noCustomIntros = true
}

float function CustomIntro_GetLength()
{
	if ( ShouldIntroSpawnAsTitan() )
		return TITAN_DROP_SPAWN_INTRO_LENGTH
	else
		return CUSTOMINTRO_INTRO_PILOT_LENGTH
		
	unreachable
}

void function CustomIntro_Start()
{
	ClassicMP_OnIntroStarted()

	foreach ( entity player in GetPlayerArray() )
		CustomIntro_SpawnPlayer( player )
		
	if ( ShouldIntroSpawnAsTitan() )
		wait TITAN_DROP_SPAWN_INTRO_REAL_LENGTH
	else
	{
		wait CUSTOMINTRO_INTRO_PILOT_LENGTH
		
		foreach ( entity player in GetPlayerArray() )
		{
			if ( !IsPrivateMatchSpectator( player ) )
			{
				player.UnfreezeControlsOnServer()
				RemoveCinematicFlag( player, CE_FLAG_CLASSIC_MP_SPAWNING )
			}
			
			TryGameModeAnnouncement( player )
		}
	}
	
	CustomIntro_OnIntroFinished()
}

void function CustomIntro_SpawnPlayer( entity player )
{
	if ( GetGameState() != eGameState.Prematch )
		return
	
	// if ( IsPrivateMatchSpectator( player ) ) // private match spectators use custom spawn logic
	// {
	// 	RespawnPrivateMatchSpectator( player )
	// 	return
	// }
	
	if ( IsAlive( player ) )
		player.Die()
	
	if ( ShouldIntroSpawnAsTitan() )
		thread ClassicMP_DefaultNoIntro_TitanSpawnPlayer( player )
	else if ( GetIntroRiff() )
		thread CustomIntro_PilotSpawnPlayer( player )
    else if ( GetMarvinRiff() )
		thread MarvinIntro_PilotSpawnPlayer( player )
    else
        thread NormalIntro_PilotSpawnPlayer( player )
        
}

// spawn as pilot for intro
void function NormalIntro_PilotSpawnPlayer( entity player )
{
    RespawnAsPilot( player )
    AddCinematicFlag( player, CE_FLAG_CLASSIC_MP_SPAWNING )
    ScreenFadeFromBlack( player, 0.5, 0.5 )
    player.FreezeControlsOnServer()
}

// spawn as titan for intro
void function ClassicMP_DefaultNoIntro_TitanSpawnPlayer( entity player )
{
	// blocking call
	RespawnAsTitan( player, false )
	TryGameModeAnnouncement( player )
    player.FreezeControlsOnServer()
    ScreenFadeFromBlack( player, 0.5, 0.5 )
}

// custom intro
void function CustomIntro_PilotSpawnPlayer( entity player )
{
	RespawnAsPilot( player )
	player.FreezeControlsOnServer()
	AddCinematicFlag( player, CE_FLAG_CLASSIC_MP_SPAWNING )
	ScreenFadeFromBlack( player, 0.5, 0.5 )
    player.SetAngles( target_player_angle )
    file.playerLocations[player.GetPlayerName()] <- player.GetOrigin() + player.GetForwardVector() * 100 + <0,0,50>
    
    player.EnableRenderAlways()
    print( file.playerLocations[ player.GetPlayerName() ])
    
    file.camera.Fire( "Enable", "!activator", 0, player )

    // AddCinematicFlag( player, CE_FLAG_TITAN_3P_CAM )
    player.MakeVisible()
    // player.AnimViewEntity_EnableThirdPersonCameraVisibilityChecks()

    player.SetModel( player.GetModelName() )
    player.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE
    // GetPlayerArray()[0].SetModel( $"models/titans/atlas/atlas_titan.mdl" )
}

void function start_CustomIntro()
{
    entity target_player
    entity player
    entity visited
    int x
    for( ;; )
    {
        
        if ( file.IntroEnded )
        {
            break
        }
        waitthread waitUntilPlayersJoined()

        array<entity> possible_player_list = GetPlayerArray()

        PrintEntityArray( possible_player_list )
        
        foreach ( visited in file.visited )
        {
            for( x = 0; x < possible_player_list.len(); x += 1 )
            {
                if ( possible_player_list[x] == visited )
                {
                    possible_player_list.remove( x )
                }
            }
        }

        if ( possible_player_list.len() == 0 )
        {
            PrintEntityArray( possible_player_list )
            possible_player_list = GetPlayerArray()
        }

        target_player = possible_player_list.getrandom()
        file.visited.append( target_player )
        
        waitthread waitUntilPlayerIsInArray( target_player )

        print( file.playerLocations[target_player.GetPlayerName()] )

        file.mover.MoveTo( file.playerLocations[target_player.GetPlayerName() ], 0.3, 0.05, 0.05 )
        file.mover.RotateTo( camera_angle, 0.3, 0.05, 0.05 )
        
        target_player.SetAngles( target_player_angle )
        target_player.Anim_Play( PossibleAnimation.getrandom() ) // GetPlayerArray()[0].Anim_Play( "ogpov_melee_armrip_attacker" )
        target_player.Show()

        foreach( player in GetPlayerArray() )
        {
            ScreenFadeFromBlack( player, 0.1, 0.1 )
        }
        WaittillAnimDone( target_player )
        wait 0.3
    }
}

// custom intro
void function MarvinIntro_PilotSpawnPlayer( entity player )
{
    RespawnAsPilot( player )
	player.FreezeControlsOnServer()
	AddCinematicFlag( player, CE_FLAG_CLASSIC_MP_SPAWNING )
	ScreenFadeFromBlack( player, 0.5, 0.5 )
    
    file.camera.Fire( "Enable", "!activator", 0, player )
}

void function start_CustomMarvinIntro()
{
    file.mover.SetOrigin( <0,0,3000> )

    // script GetPlayerArray()[0].SetOrigin( <0,0,3000> )
    // script GetPlayerArray()[0].SetAngles( <0,180,0> )

    vector marvin_spawn = file.mover.GetOrigin() + file.mover.GetForwardVector() * 200 + <0,0,-50>

    entity marvin = CreatePropDynamic( $"models/robots/marvin/marvin.mdl", marvin_spawn, <0,180,0>, 1, 2000 )
    // entity marvin2 = CreatePropDynamic( $"models/robots/marvin/marvin.mdl", marvin_spawn, <0,180,0>, 1, 2000 )

    entity mover = CreateExpensiveScriptMover()
    mover.SetOrigin( marvin_spawn )
    marvin.SetParent( mover )

    EmitSoundOnEntity( marvin, MARVIN_EMOTE_SOUND_HAPPY )
    marvin.SetSkin( 2 )

    mover.MoveTo( file.mover.GetOrigin() + file.mover.GetForwardVector() * 1 + <0,0,-50>, 7, 0.1, 0.1 )
    
    wait 6.5
    
    EmitSoundOnEntity( marvin, MARVIN_EMOTE_SOUND_PAIN )
    foreach( entity player in GetPlayerArray() )
    {
        ScreenFadeFromBlack( player, 1, 1 )
    }
    wait 7
    mover.Destroy()
}

void function CustomIntro_OnIntroFinished()
{
    SetGameState( eGameState.Playing )

    foreach( entity player in GetPlayerArray() )
    {
        DeployAndEnableWeapons( player )
        player.UnfreezeControlsOnServer()
    }

    if ( file.noCustomIntros )
        return

    foreach( entity player in GetPlayerArray() )
    {
        file.camera.Fire( "Disable", "!activator", 0, player )
        file.camera.FireNow( "Disable", "!activator", null, player )
        // RemoveCinematicFlag( player, CE_FLAG_TITAN_3P_CAM )
        // player.Fire( "Enable", "!activator", 0, player )
        player.DisableRenderAlways()
        player.ClearParent()
        DeployAndEnableWeapons( player )
        player.Die()
        player.RespawnPlayer( null )
        ScreenFadeFromBlack( player, 0.2, 0.2 )
    }
    file.mover.Destroy()
    file.camera.Destroy()
    file.IntroEnded = true
}

void function waitUntilPlayersJoined()
{
    while( GetPlayerArray().len() == 0 )
    {
        WaitFrame()
    }
    WaitFrame()
    WaitFrame()
}

void function waitUntilPlayerIsInArray( entity player )
{
    while( !(player.GetPlayerName() in ( file.playerLocations )) )
    {
        WaitFrame()
    }
}

void function PrintEntityArray( array<entity> Array )
{
    string PrintString = ""
    foreach( element in Array )
    {
        PrintString = format( "%s%s", PrintString, element.GetPlayerName() )
    }
    print( PrintString )
}