global function Init_TitanLimit
global function GiveTitanAll

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
    if ( CanPlayerHaveTitan( player ) )
    {
        if ( EarnMeterMP_IsTitanEarnGametype() )
        {
            SetTitanAvailable( player )
            //Remote_CallFunction_Replay( player, "ServerCallback_TitanReadyMessage" ) // broken for some reason
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
        
        SendHudMessage( player, "Too many titans on the battle field", -1, 0.2, 255, 0, 255, 0, 0.15, 2, 0.15 )
        
        ClearTitanAvailable( player )

        foreach( entity p in file.waitList )
        {
            if ( p == player )
                return
        }
        print( "added to list" )
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
            if ( ( player.GetTeam() == TEAM_MILITIA && MilitiaTf ) || ( player.GetTeam() == TEAM_IMC && ImcTf ) )
            {
                SendHudMessage( player, "There is now space for a titan", -1, 0.2, 255, 0, 255, 0, 0.15, 2, 0.15 )
                file.waitList.remove( i )
                PlayerEarnMeter_Reset( player )
                player.p.earnMeterOverdriveFrac = 1.0
                player.SetPlayerNetFloat( EARNMETER_EARNEDFRAC, 1.0 )
                PlayerEarnMeter_SetOwnedFrac( player, 1.0 )
                PlayerEarnMeter_SetRewardFrac( player, 1.0 )
            }
        }
        
        wait 0.01 
    }
}

void function GiveTitanAll()
{
    foreach( entity player in GetPlayerArray() )
    {
        player.p.earnMeterOverdriveFrac = 1.0
        player.SetPlayerNetFloat( EARNMETER_EARNEDFRAC, 1.0 )
        PlayerEarnMeter_SetOwnedFrac( player, 1.0 )
        PlayerEarnMeter_SetRewardFrac( player, 1.0 )
    }
}