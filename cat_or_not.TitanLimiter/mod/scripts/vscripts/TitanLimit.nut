global function Init_TitanLimit
global function GiveTitanAll
global function DEV_TitanChassieTest
global function DEV_TitanChassieTest2

struct {
    array<entity> waitList
    int maxTitans = 3
} file

void function Init_TitanLimit()
{
    ServerCommand("exec autoexec_max_titans")

    SetCallback_EarnMeterGoalEarned( EarnMeterMP_TitanEarned )

    thread RunTitanfallAvailabiltyCheck()

    file.maxTitans = GetConVarInt("TitanLimit")
}

void function EarnMeterMP_TitanEarned( entity player )
{
    if ( CanPlayerHaveTitan( player ) && CanDropTitanChassis( player ) )
    {
        if ( EarnMeterMP_IsTitanEarnGametype() )
        {
            SetTitanAvailable( player )
        }
        else
        {
            float oldRewardFrac = PlayerEarnMeter_GetRewardFrac( player )
            PlayerEarnMeter_Reset( player )
            PlayerEarnMeter_SetRewardFrac( player, oldRewardFrac )
            PlayerEarnMeter_EnableReward( player )

            if ( PlayerEarnMeter_GetRewardFrac( player ) != 0 )
                PlayerEarnMeter_EnableReward( player )
        }
    }
    else
    {
        float oldRewardFrac = PlayerEarnMeter_GetRewardFrac( player )
        PlayerEarnMeter_Reset( player )
        PlayerEarnMeter_SetRewardFrac( player, oldRewardFrac )
        PlayerEarnMeter_EnableReward( player )

        if ( PlayerEarnMeter_GetRewardFrac( player ) != 0 )
            PlayerEarnMeter_EnableReward( player )
        
        if ( CanDropTitanChassis( player ) )
            SendTooManyTitans( player )
        else
            SendTooManyTitansChassies( player )

        ClearTitanAvailable( player )

        foreach( entity p in file.waitList )
        {
            if ( p == player )
                return
        }
        file.waitList.append( player )
    } 
}

bool function CanPlayerHaveTitan( entity player )
{
    int team = player.GetTeam()
    int titanCount = 0

    foreach ( entity titan in GetEntArrayByClass_Expensive("npc_titan") )
    {
        if ( titan.GetTeam() == team )
        {
            titanCount += 1
        }
    }
    foreach ( entity p in GetPlayerArray() )
    {
        if ( p.GetTeam() == team && p.IsTitan() )
        {
            titanCount += 1
        }
    }
    return !(file.maxTitans <= titanCount)
}

bool function CanTeamHaveTitan( int team )
{
    int titanCount = 0

    foreach ( entity titan in GetEntArrayByClass_Expensive("npc_titan") )
    {
        if ( titan.GetTeam() == team )
        {
            titanCount += 1
        }
    }
    foreach ( entity p in GetPlayerArray() )
    {
        if ( p.GetTeam() == team && p.IsTitan() )
        {
            titanCount += 1
        }
    }
    return !(file.maxTitans <= titanCount)
}

void function RunTitanfallAvailabiltyCheck()
{
    entity player
    for(;;)
    {
        bool MilitiaTf = CanTeamHaveTitan( TEAM_MILITIA )
        bool ImcTf = CanTeamHaveTitan( TEAM_IMC )


        for ( int i = file.waitList.len() - 1; i >= 0; i-- )
        {
            player = file.waitList[i]
            if ( !IsValid( player ) || player.IsTitan() || IsValid( player.GetPetTitan() ) )
                file.waitList.remove( i )
            else if ( ( ( player.GetTeam() == TEAM_MILITIA && MilitiaTf ) || ( player.GetTeam() == TEAM_IMC && ImcTf ) ) && CanDropTitanChassis( player ) )
            {
                file.waitList.remove( i )
                SendTitanAvailable( player ) 
            }
        }

        wait 0.1
    }
}

string function GetRandomCallSign()
{
    string head = "rui/callsigns/"

    array<string> body = [
        "callsign_17_col",
        "callsign_23_col",
        "callsign_24_col",
        "callsign_26_col",
        "callsign_36_col",
        "callsign_45_col",
        "callsign_47_col",
        "callsign_66_col",
        "callsign_68_col",
        "callsign_92_col",
        "callsign_94_col",
        "callsign_97_col",
        "callsign_102_col",
        "callsign_144_col"
    ]

    return head + body.getrandom()
}

void function SendTitanAvailable( entity player ) 
{
    if ( player.IsTitan() || IsValid( player.GetPetTitan() ) )
        return

    NSSendLargeMessageToPlayer( player, "You can drop a titan", "There is now space for a titan", 5.0, GetRandomCallSign() )

    PlayerEarnMeter_Reset( player )
    player.p.earnMeterOverdriveFrac = 1.0
    player.SetPlayerNetFloat( EARNMETER_EARNEDFRAC, 1.0 )
    PlayerEarnMeter_SetOwnedFrac( player, 1.0 )
    PlayerEarnMeter_SetRewardFrac( player, 1.0 )
    SetTitanAvailable( player )
}

void function SendTooManyTitans( entity player ) 
{
    if ( player.IsTitan() || IsValid( player.GetPetTitan() ) )
        return

    NSSendLargeMessageToPlayer( player, "Titan gone", "Too many titans on the battlefield", 5.0, GetRandomCallSign() )
}

void function SendTooManyTitansChassies( entity player ) 
{
    if ( player.IsTitan() || IsValid( player.GetPetTitan() ) )
        return

    NSSendLargeMessageToPlayer( player, "Chassis gone", "This chassis is deployed too much on the battlefield", 5.0, GetRandomCallSign() )
}

void function GiveTitanAll()
{
    foreach( entity player in GetPlayerArray() )
    {
        player.p.earnMeterOverdriveFrac = 1.0
        player.SetPlayerNetFloat( EARNMETER_EARNEDFRAC, 1.0 )
        PlayerEarnMeter_SetOwnedFrac( player, 1.0 )
        PlayerEarnMeter_SetRewardFrac( player, 1.0 )
        SetTitanAvailable( player )
    }
}

void function DEV_TitanChassieTest()
{
    entity player = GetPlayerArray()[0]
    entity titan = player.GetPetTitan()
    entity soul = titan.GetTitanSoul()

    print( "sub class:" + GetSoulTitanSubClass( soul ) )
    print( "setting:" + GetSoulPlayerSettings( soul ) )
}

void function DEV_TitanChassieTest2()
{
    foreach ( entity titan in GetEntArrayByClass_Expensive("npc_titan") )
    {
        entity soul = titan.GetTitanSoul()

        print( "sub class:" + GetSoulTitanSubClass( soul ) )
        print( "setting:" + GetSoulPlayerSettings( soul ) )
    }
}