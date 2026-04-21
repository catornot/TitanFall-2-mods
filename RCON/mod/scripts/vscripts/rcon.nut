global function RCONCommand

void function RCONCommand()
{
	AddClientCommandCallback("rcon", RCON);
	AddClientCommandCallback("uids", UIDS);
	AddClientCommandCallback("kick2", KICK);
	AddClientCommandCallback("sayserver", SAY);
}


bool function UIDS(entity player, array<string> args){

	entity playerOrig = player;

	print("UIDS");
	foreach ( entity player in GetPlayerArray()){
		print( player.GetPlayerName() + " | " + player.GetUID() );
	}
	
	return true;
}


bool function SAY(entity player, array<string> args){
	print("say")

	entity playerOrig = player;

	hasRCONAdmin = false;
	CheckRCONAdmin(player)
	if (hasRCONAdmin == false){
		print("Admin permission not detected.");
		return true;
	}

	if (args.len() == 0){
		print("Give a valid argument.");
		print("Example: kick <nickname>");
		return true;
	}

	string newString = "";
	
	foreach (string arguments in args)
	{
		newString += (arguments.tostring() + " ");
	}
	
	printt(newString)

		foreach ( entity player in GetPlayerArray() ){
			SendHudMessage( player, newString, -1, 0.2, 255, 255, 255, 0, 0.15, 5, 1 );
		}

	return true;
}

bool function KICK(entity player, array<string> args){
	print("kick")
	
	hasRCONAdmin = false;
	CheckRCONAdmin(player)
	if (hasRCONAdmin == false){
		print("Admin permission not detected.");
		return true;
	}

	if (args.len() == 0){
		print("Give a valid argument.");
		print("Example: kick <nickname>");
		return true;
	}
	
	if (args.len() > 2){
		print("Too many arguments for kick.");
		print("Example: kick <nickname>");
		return true;
	}

	string playername = ""
	foreach (string argument in args){
		playername = argument.tostring()
	}
	
	array<entity> players = GetPlayerArray()
	foreach ( player in players){
		if( (player.GetPlayerName()) == playername ){
			print("kicking "+playername)
			print("UID:"+player.GetUID())
			ServerCommand("kickid "+ player.GetUID());
			return true;
		}
	}
	//foreach(player2 in GetPlayerArray().GetUID){
	//	print(player2.GetUID)
	//}
	return true;
}

bool function RCON(entity player, array<string> args)
{
	#if SERVER
	
	hasRCONAdmin = false;
	CheckRCONAdmin(player)
	if (hasRCONAdmin == false)
	{
		print("Admin permission not detected.");
		return true;
	}
	
	if (args.len() == 0)
	{
		print("Give a valid argument.");
		print("Example: rcon <arguments>");
		return true;
	}
	string newString = "";
	
	foreach (string arguments in args)
	{
		newString += (arguments.tostring() + " ");
	}
	
	print("rcon " + newString);
	
	ServerCommand(newString);
	#endif
	return true;
}