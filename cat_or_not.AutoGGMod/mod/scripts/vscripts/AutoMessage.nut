global function InitAutoMessage

global float AutoMessageWaitTime
global string AutoMessageStartText
global string AutoMessageEndText
global bool DeathCallbackExists

void function InitAutoMessage()
{
    if ( IsMultiplayer() )
    {
        AddCallback_GameStateEnter( eGameState.Prematch, MatchStart )
        AddCallback_GameStateEnter( eGameState.WinnerDetermined, MatchEnd )
    }
}

void function MatchStart()
{
    AutoMessageWaitTime = GetConVarFloat( "auto_message_wait_time" )
    AutoMessageStartText = GetConVarString( "auto_message_start_text" )

    if ( AutoMessageStartText != "" )
        SendMessage( AutoMessageStartText )
    
}

void function MatchEnd()
{   
    wait 1 // This gives enough time for the gamestate to change from eGameState.WinnerDetermined to eGameState.Epilogue if there's an epilogue

    AutoMessageWaitTime = GetConVarFloat( "auto_message_wait_time" )
    AutoMessageEndText = GetConVarString( "auto_message_end_text" )

    if ( AutoMessageEndText != "" )
    {
        if ( GetGameState() == eGameState.WinnerDetermined ) // eGameState.WinnerDetermined here means there's no epilogue
        {
            // Adjust AutoMessageWaitTime for that 1 second wait from earlier
            if ( AutoMessageWaitTime < 1 )
                AutoMessageWaitTime = 0
            else
                AutoMessageWaitTime = AutoMessageWaitTime - 1.0
            
            SendMessage( AutoMessageEndText )
        }
        else if ( GetGameState() == eGameState.Epilogue ) // eGameState.Epilogue means there is epilogue
        {
            AddOnDeathCallback( "player", PlayerDiedDuringEpilogue )
            DeathCallbackExists = true
            // I don't really like using this, the best way to do it would be to write a function to check if there's a callback in the list that calls PlayerDiedDuringEpilogue, but I'm lazy

            AddCallback_GameStateEnter( eGameState.Postmatch, EpilogueOver ) // eGameState.Postmatch means game is over, showing scoreboard
        }
    }
}

void function PlayerDiedDuringEpilogue( entity player )
{
    if ( player == GetLocalClientPlayer() )
    {
        if ( DeathCallbackExists == true ) // I don't really like using this, the best way to do it would be to write a function to remove a callback in the list during EpilogueOver()
        {
            DeathCallbackExists = false
            thread SendMessage( AutoMessageEndText )
        }
    }
}

void function EpilogueOver()
{
    if ( DeathCallbackExists == true )
    {
        DeathCallbackExists = false //RemoveOnDeathCallback( "player" , PlayerDiedDuringEpilogue )//<-----------------------------------------------------------------------------------------

        AutoMessageWaitTime = 0
        SendMessage( AutoMessageEndText )
    }
}

void function SendMessage( string MessageText )
{
    wait AutoMessageWaitTime
    GetLocalClientPlayer().ClientCommand( "say " + MessageText )
}


// TODO
//
// HANDLE GAMEMODES WITH MULTIPLE ROUNDS - WINNERDETERMINED PLAYS AT END OF EACH ROUND
// then add "gh" option for eGameState.SwitchingSides
//
// write functions for managing death callbacks - one to check if it exists and one to remove it
