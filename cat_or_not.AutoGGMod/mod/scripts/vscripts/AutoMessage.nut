global function InitAutoMessage

void function InitAutoMessage() {
    // thread WaitUntilMacth()
    AddCallback_GameStateEnter( eGameState.WinnerDetermined, SendMessageOnMacthEnd )
}

void function SendMessageOnMacthEnd(){
    GetLocalClientPlayer().ClientCommand( "say " + GetConVarString("Message") )
}

// void function WaitUntilMacth()
// {
//     while(true){
//         if( GetGameState() == eGameState.WinnerDetermined ){
//             GetLocalClientPlayer().ClientCommand( "say" + GetConVarString("Message") )
//             wait( 5 )
//         }
//     }

//     // wait( GameMode_GetRoundTimeLimit( GAMETYPE ) - 10 )
    
// }