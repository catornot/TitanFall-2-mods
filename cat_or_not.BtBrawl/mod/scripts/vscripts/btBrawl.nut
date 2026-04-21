global function Init_BtBrawl
global function BtBrawlRespawn
global function PutPlayerOnSpawnPoint

struct 
{
    array<entity> TeamChosen
} file

void function Init_BtBrawl()
{
    AddCallback_EntitiesDidLoad( Init_OnEntitiesLoaded )
}

void function Init_OnEntitiesLoaded()
{
    thread Init_BtBrawlThreaded()
}

void function Init_BtBrawlThreaded()
{

    thread WaitForNodesWithTimeOut( 10, "This may be the wrong map" )
    waitthread WaitForNodes()

    AddMakeSpecifcRespawns( GetMapName(), BtBrawlRespawn )

    DisableOnePlayerRestart()

    AddCallback_OnClientConnected( playerConnected )

    AddSpawnCallback( "npc_titan", DeleteExtratitans )
}

void function WaitForNodesWithTimeOut( int timeout, string message )
{
    while( timeout != 0 )
    {
        wait 1

        if ( GetEntArrayByScriptName( "BrawlSpawnNode1" ).len() + GetEntArrayByScriptName( "BrawlSpawnNode2" ).len() > 0 )
        {
            return
        }

        timeout--
    }

    Chat_ServerBroadcast( message )
}

void function WaitForNodes()
{
    for(;;)
    {
        WaitFrame()

        if ( GetEntArrayByScriptName( "BrawlSpawnNode2" ).len() + GetEntArrayByScriptName( "BrawlSpawnNode3" ).len() > 0 )
        {
            return
        }
    }
}

void function BtBrawlRespawn( entity player )
{
    if ( !IsAlive( player ) && IsValid( player ) )
    {
        DoRespawnPlayer( player, null )

        Disembark_Disallow( player )

        thread PutPlayerOnSpawnPoint( player )

        ScreenFadeFromBlack( player, 1.0, 0.0 )
    }
}

void function PutPlayerOnSpawnPoint( entity player )
{
    if ( IsAlive( player ) && IsValid( player ) )
    {
        array<entity> nodes = GetEntArrayByScriptName( format( "BrawlSpawnNode%d", player.GetTeam() ) )
        
        if ( nodes.len() == 0 )
            return

        nodes.randomize()
        nodes.randomize()

        waitthread MakePlayerTitan( player, nodes[0].GetOrigin() )

        entity soul = GetSoulFromPlayer( player )
        if ( soul == null )
            return

        soul.EndSignal( "OnTitanDeath" )
        soul.EndSignal( "OnDestroy" )
        soul.EndSignal( "TitanBrokeBubbleShield" )

        float duration = 3.0

        thread CreateParentedBubbleShield( player, player.GetOrigin(), player.GetAngles(), duration )

        OnThreadEnd(
        function() : ( soul )
            {
                if ( IsValid( soul ) )
                {
                    if ( IsValid( soul.soul.bubbleShield ) )
                        soul.soul.bubbleShield.Destroy()
                }
            }
        )

        wait 5
    }
}

void function JoinCheck( entity player )
{
    if ( !file.TeamChosen.contains( player ) )
    {
        int militia = 0
        int imc = 0
        foreach ( entity p in GetPlayerArray() )
        {
            if ( p.GetTeam() == TEAM_IMC && p != player )
                imc++
            else if ( p != player )
                militia++
        }

        if ( imc < militia )
            SetTeam( player, TEAM_IMC )
        else if ( imc > militia )
            SetTeam( player, TEAM_MILITIA )
        else
            SetTeam( player, RandomIntRange( TEAM_IMC, TEAM_MILITIA ) )
    }
}

void function playerConnected( entity player )
{
    SpawnBt( player )

    JoinCheck( player )

    thread PutPlayerOnSpawnPoint( player )

    Disembark_Disallow( player )
}

void function SpawnBt( entity player )
{
    if ( IsValid( player ) )
    {
        entity titan = player.GetPetTitan()
        if ( !IsValid( titan ) )
        {
            CreatePetTitanAtLocation( player, player.GetOrigin(), player.GetAngles() )
            titan = player.GetPetTitan()
            if ( titan != null )
                titan.kv.alwaysAlert = false
        }
        else 
        {
            titan.SetOrigin( player.GetOrigin() )
        }
    }
}

void function DeleteExtratitans( entity titan )
{
    thread DeleteExtratitansThreaded( titan )
}

void function DeleteExtratitansThreaded( entity titan )
{
    wait 2
    if ( IsValid( titan ) && !titan.IsPlayer() )
        titan.Die()
}