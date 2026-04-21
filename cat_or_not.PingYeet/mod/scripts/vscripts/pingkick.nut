global function Init_PingKick

struct {
    int maxping = 150
} file

void function Init_PingKick()
{
    ServerCommand("exec autoexec_max_ping")

    AddCallback_OnClientConnected( StartCountAveragePing )

    file.maxping = GetConVarInt("MaxPing")
}

void function StartCountAveragePing( entity player )
{
    thread CountAveragePingThink( player )
}

void function CountAveragePingThink( entity player )
{
    try
    {
    wait 10
    Chat_ServerPrivateMessage( player, "You are being test for OK ping", false )

    array<int> Pings = []
    for( int x; x < 5; x += 1 )
    {
        Pings.append( player.GetLatency().tointeger() )
        wait 5
    }

    int AveragePing = 0
    int SumPings = 0
    foreach ( int _ping in Pings  )
    {
        SumPings += _ping
    }
    AveragePing = SumPings / Pings.len()

    PrintArrayInt( Pings )
    print( AveragePing )
    print( SumPings )

    if ( AveragePing > file.maxping )
    {
        thread StartOverlyDramaticKick( player )
        return
    }
    Chat_ServerPrivateMessage( player, "You have OK ping", false )
    }
    catch( ohno )
    {
        print("someone left before they got tested :(")
    }

}

void function StartOverlyDramaticKick( entity player )
{
    Chat_ServerPrivateMessage( player, "You don't have OK ping", false )
    Chat_ServerPrivateMessage( player, "You will be kicked in", false )
    wait 1
    Chat_ServerPrivateMessage( player, "3", false )
    wait 1
    Chat_ServerPrivateMessage( player, "2", false )
    wait 1
    Chat_ServerPrivateMessage( player, "1, bye bye", false )
    wait 0.5
    ServerCommand( "kick " + player.GetUID() )
    Chat_ServerBroadcast( "A player had a ping that wasn't OK" )
}

void function PrintArrayInt( array<int> Printarray )
{
    foreach( int num in Printarray )
    {
        print( num )
    }
}