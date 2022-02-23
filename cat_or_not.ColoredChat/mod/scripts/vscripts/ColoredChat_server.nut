global function InitServerColoreChat

struct
{
	table< entity, array<string> > ColorsPerPlayer
} file

void function InitServerColoreChat()
{
    AddClientCommandCallback("SetMessageColor", SetMessageColorForPlayer)
    AddCallback_OnReceivedSayTextMessage( CallBackMessage )
}

ClServer_MessageStruct function CallBackMessage(ClServer_MessageStruct message) {

    entity player = message.player
    // print("=======================================")
    // print(message.message)

    if ( message.message.len() == 0 ){
        return message
    }

    if ( message.message[0] == 63 ) {

        message.shouldBlock = true

        if ( message.message.len() == 1 ){
            return message
        }
        
        string MessageWithoutCommandSign = message.message.slice( 1, message.message.len() - 1 )
        array<string> SplicedMessage = split( MessageWithoutCommandSign, " " )

        // if ( SplicedMessage[0] == "Wisper" && GetConVarInt("ActivateWispering") == 1 ) ){

        //     try
        //     {
        //         Chat_PrivateMessage( player, FindPlayerByName( name ), ArrayToString( SplicedMessage[1:]  ) )
        //     }
        //     catch( exception )
        //     {
        //         Chat_ServerPrivateMessage( player, " ?Wisper_<message> ", true )
        //     }
        // }
        
        // print( MessageWithoutCommandSign )
        // foreach(s in SplicedMessage ){
        //     print( s )
        // }

        if ( SplicedMessage.len() < 2 ){
            return message
        }
        
        if ( SplicedMessage[0] == "SetColor" && GetConVarInt("ActivateColoredChat") == 1 ){
            
            // print( SplicedMessage.len() )

            // print( SplicedMessage.slice( 1, SplicedMessage.len() - 1 ) )

            try
            {
                SetMessageColorForPlayer( player, SplicedMessage.slice( 1, SplicedMessage.len() - 1 ) )
            }
            catch( exception )
            {
                print(" could not run the SetColor")
                // Chat_ServerPrivateMessage( player, " ?SetColor_<r>_<g>_<b> ", true )
            }
        }
    }
    else{
        if ( player in file.ColorsPerPlayer ){

            array<string> colors = file.ColorsPerPlayer[player]

            string formatedstring = format( "added = " + "\x1b[38;2;%s%s%s%s%xs", colors[0], ";", colors[1], ";", colors[2], "m" )
            
            // print( formatedstring )
            
            message.message = message.message + formatedstring
        }
        
    }
    
    // print(message.message)
    // print("=======================================")
    return message
}

bool function SetMessageColorForPlayer(entity player, array<string> args)
{
    string red
    string green
    string blue

    try
    {
        red = args[0]
        green = args[1]
        blue = args[2]
    }
    catch( exception ){
        return false
    }

    if ( player in file.ColorsPerPlayer ){
        file.ColorsPerPlayer[player][0] =  red
        file.ColorsPerPlayer[player][0] =  green
        file.ColorsPerPlayer[player][0] =  blue 
    }
    else{
        file.ColorsPerPlayer[player] <- []
        file.ColorsPerPlayer[player].append( red )
        file.ColorsPerPlayer[player].append( green )
        file.ColorsPerPlayer[player].append( blue )
    }

    return true
}

entity function FindPlayerByName( string name ){
    foreach ( player in GetPlayerArray() )
    {
        if ( player.GetPlayerName().find( name ) != null ){
            return player
        }
    }

    unreachable
}

string function ArrayToString( array<string> Array )
{
    string String
    
    foreach ( Part in Array )
    {
        String += Part
    }

    return String
}