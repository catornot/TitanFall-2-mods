global function InitAutoMessage

void function InitAutoMessage() {
    if ( IsMultiplayer() )
        AddCallback_GameStateEnter( eGameState.WinnerDetermined, SendMessageOnMacthEnd )
}

void function SendMessageOnMacthEnd(){
    GetLocalClientPlayer().ClientCommand( "say " + GetConVarString("Message") )
}