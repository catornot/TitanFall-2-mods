global function CodeCallback_MapInit

const string MAP_GAMEMODE = "tdm"

void function CodeCallback_MapInit()
{
    
    if ( GAMETYPE != MAP_GAMEMODE )
    {
        GAMETYPE = MAP_GAMEMODE
        SetConVarString( "mp_gamemode", MAP_GAMEMODE )
        ServerCommand( "reload" )
    }
    
    // should be moved into a gamemode
    SetShouldUsePickLoadoutScreen( false )
    SetTimerBased( false )
    SetLoadoutGracePeriodEnabled( false )
	SetWeaponDropsEnabled( false )
    Riff_ForceTitanAvailability( eTitanAvailability.Never )
    
    DevPalacePrecache()
    Shared_mp_dev_palace()
    InitRespawnManager()
    InitRoomManager()
    InitHubRoom()
    InitDeathManager()
    InitBreakableWalls()
    InitPlayerManager()
}