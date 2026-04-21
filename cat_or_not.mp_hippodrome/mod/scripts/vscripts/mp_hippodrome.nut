global function CodeCallback_MapInit

const int POINT_LEAD = 2 // 3 since > opperation

enum ePlayerArenaState
{
	LOBBY,
    PVP
}

struct {
    table<int,int> player_state
    table<int,string> player_arena
} file

struct ArenaGame {
    int score1
    int score2
}

void function CodeCallback_MapInit()
{
    InitKeyTracking()
    RegisterSignal( "EndedArena" )

    Riff_ForceTitanAvailability( eTitanAvailability.Never )
    ClassicMP_SetCustomIntro( ClassicMP_DefaultNoIntro_Setup, 1.0 )

    AddCallback_OnClientConnected( OnPlayerConnected )
    AddCallback_OnPlayerRespawned( OnRespawn )
    AddCallback_EntitiesDidLoad( EntitiesDidLoad )
    AddCallback_GameStateEnter( eGameState.Playing, SetTimeEndToMax )
}

void function EntitiesDidLoad()
{
    foreach( entity marvin in GetEntArrayByScriptName( "bar_marvins" ) )
    {
        // marvin.SetName( "Bartender" )
        marvin.Freeze()
    }
}

void function SetTimeEndToMax()
{
    SetGameEndTime( 999999999 )
}


void function OnPlayerConnected( entity player )
{
    player.SetUsable()
    player.SetUsableByGroup( "pilot" )
    player.SetUsePrompts( "Hold %use% to challenge them", "Press %use% to challenge them" )

    file.player_state[player.GetUID()] <- ePlayerArenaState.LOBBY
    file.player_arena[player.GetUID()] <- ""

    thread PlayerInvitesThink( player )
}

void function OnRespawn( entity player )
{
    switch( file.player_state[player.GetUID()] ) {
        case ePlayerArenaState.LOBBY:
            HolsterAndDisableWeapons( player )
            break
        case ePlayerArenaState.PVP:
            entity spawn = GetRandomSpawnForArena( player )
            player.SetOrigin( spawn.GetOrigin() )
            player.SetAngles( spawn.GetAngles() )
            break
    }
}

void function PlayerInvitesThink( entity player ) 
{
    EndSignal( player, "OnDestroy" )

    for(;;)
    {
        player.SetUsable()

        entity inviter = expect entity( player.WaitSignal( "OnPlayerUse" ).player )

        player.UnsetUsable()
        inviter.UnsetUsable()

        waitthread ProcessInvite( player, inviter )
    }
}

void function ProcessInvite( entity player, entity target )
{
    NSSendInfoMessageToPlayer( player, target.GetPlayerName() + " challenged you to a 1v1   crouch + use to cancel" )
    
    EndSignal( player, "EndedArena" )
    EndSignal( target, "EndedArena" )
    EndSignal( player, "OnDestroy" )
    EndSignal( target, "OnDestroy" )
    
    for( int x = 0; x < 5; x++ )
    {
        if ( GetPlayerKey( player, KD ) && GetPlayerKey( player, KU ) ) 
        {
            string message = "1v1 canceled"
            NSSendInfoMessageToPlayer( player, message )

            if ( IsValid( target ) )
            {
                NSSendInfoMessageToPlayer( target, message )
                target.SetUsable()
            }

            return
        }

        wait 1
    }

    entity ornull maybeArena = FindFreeArena()
    if ( maybeArena == null )
    {
        string message = "all arenas are full"
        NSSendInfoMessageToPlayer( player, message )

        if ( IsValid( target ) )
        {
            NSSendInfoMessageToPlayer( target, message )
            target.SetUsable()
        }
    }
    entity arena = expect entity( maybeArena )

    string name = arena.GetTargetName()

    DeployAndEnableWeapons( player )
    DeployAndEnableWeapons( target )
    file.player_state[player.GetUID()] <- ePlayerArenaState.PVP
    file.player_state[target.GetUID()] <- ePlayerArenaState.PVP
    file.player_arena[player.GetUID()] <- name
    file.player_arena[target.GetUID()] <- name
    SetTeam( player, 3 )
    SetTeam( target, 2 )
    player.UnsetUsable()
    target.UnsetUsable()

    OnRespawn( player )
    OnRespawn( target )

    ArenaGame game
    game.score1 = 0
    game.score2 = 0
    
    array<string> id_handles = [ UniqueString( "arena2" ), UniqueString( "arena1" ) ]

    NSCreateStatusMessageOnPlayer( player, "Score", game.score1 + "-" + game.score2, id_handles[0] )
    NSCreateStatusMessageOnPlayer( target, "Score", game.score2 + "-" + game.score1, id_handles[1] )

    thread TrackScore1( player, target, game, id_handles[0], id_handles[1] )
    thread TrackScore2( target, player, game, id_handles[1], id_handles[0] )

    OnThreadEnd(
		function() : ( arena)
		{
            arena.SetScriptName( StringReplace( arena.GetScriptName(), "taken", "free", true, true ) )
		}
	)

    WaitForever()
}

entity ornull function FindFreeArena()
{
    array<entity> arenas = GetEntArrayByScriptName( "free_arena_1v1" )
    
    if ( arenas.len() == 0 )
        return null

    entity arena = GetEntArrayByScriptName( "free_arena_1v1" ).getrandom()
    arena.SetScriptName( "taken_arena_1v1" )
    return arena
}

entity function GetRandomSpawnForArena( entity player )
{
    return GetEntArrayByScriptName( file.player_arena[player.GetUID()] ).getrandom()
}

void function TrackScore1( entity player, entity other_player, ArenaGame game, string unique_id, string unique_id_other )
{
    EndSignal( player, "EndedArena" )
    EndSignal( other_player, "EndedArena" )
    EndSignal( player, "OnDestroy" )

    OnThreadEnd(
		function() : ( player, game, unique_id )
		{
            if ( IsValid( player ) )
            {
                if ( game.score1 < game.score2 )
                    NSSendAnnouncementMessageToPlayer( player, "You Won", ":D", <1,1,0>, 1, 0 )
                else 
                    NSSendAnnouncementMessageToPlayer( player, "You Lost", "D:", <1,1,0>, 1, 0 )

                CommonCleanUp( player, unique_id )
            }
		}
	)

    for(;;)
    {
        WaitSignal( player, "OnDeath" )
        game.score1 += 1

        NSEditStatusMessageOnPlayer( player, "Score", game.score1 + "-" + game.score2, unique_id )
        NSEditStatusMessageOnPlayer( other_player, "Score", game.score2 + "-" + game.score1, unique_id_other )

        wait 0

        GameRules_SetTeamScore( player.GetTeam(), 0 )

        if ( game.score1 - POINT_LEAD > game.score2 || game.score2 - POINT_LEAD > game.score1 )
            player.Signal( "EndedArena" )
        
    }
}

void function TrackScore2( entity player, entity other_player, ArenaGame game, string unique_id, string unique_id_other  )
{
    EndSignal( player, "EndedArena" )
    EndSignal( other_player, "EndedArena" )
    EndSignal( player, "OnDestroy" )

    OnThreadEnd(
		function() : ( player, game, unique_id )
		{
            if ( IsValid( player ) )
            {
                if ( game.score1 < game.score2 )
                    NSSendAnnouncementMessageToPlayer( player, "You Lost", "D:", <1,1,0>, 1, 0 )
                else 
                    NSSendAnnouncementMessageToPlayer( player, "You Won", ":D", <1,1,0>, 1, 0 )

                CommonCleanUp( player, unique_id )
            }
		}
	)

    for(;;)
    {
        WaitSignal( player, "OnDeath" )
        game.score2 += 1

        NSEditStatusMessageOnPlayer( player, "Score", game.score2 + "-" + game.score1, unique_id )
        NSEditStatusMessageOnPlayer( other_player, "Score", game.score1 + "-" + game.score2, unique_id_other )

        wait 0

        GameRules_SetTeamScore( player.GetTeam(), 0 )

        if ( game.score1 - POINT_LEAD > game.score2 || game.score2 - POINT_LEAD > game.score1 )
            player.Signal( "EndedArena" )
        
    }
}

void function CommonCleanUp( entity player, string unique_id )
{
    file.player_state[player.GetUID()] <- ePlayerArenaState.LOBBY
    NSDeleteStatusMessageOnPlayer( player, unique_id )
    player.SetUsable()

    if ( IsAlive( player ) )
        player.Die()
}