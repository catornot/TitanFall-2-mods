global function InitAutoMessage

void function InitAutoMessage() {
    if ( IsMultiplayer() )
    {
        if ( GetLocalClientPlayer() != null )
            GetLocalClientPlayer().ClientCommand("exec AutoMessage")

        AddCallback_GameStateEnter( eGameState.WinnerDetermined, SendMessageOnMacthEnd )
    }
}

void function SendMessageOnMacthEnd(){
    GetLocalClientPlayer().ClientCommand( "say " + GetConVarString("Message") )
}