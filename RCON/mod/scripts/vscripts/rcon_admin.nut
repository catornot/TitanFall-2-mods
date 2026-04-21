global function RCON_Init
global function CheckRCONAdmin
global bool hasRCONAdmin = false;

struct {
	array<string> RCON
	string RCONStringLastVal
} file

void function RCON_Init()
{
	UpdateRCONList()
}

void function UpdateRCONList()
{
	string cvar = GetConVarString( "rcon_admin" )
	if ( file.RCONStringLastVal == cvar )
		return
	
	file.RCON = split( cvar, "," )
	foreach ( string admin in file.RCON )
		StringReplace( admin, " ", "" )

}

void function CheckRCONAdmin( entity player )
{
	UpdateRCONList()
	if ( file.RCON.len() == 0 )
		return
	
	if ( file.RCON.contains( player.GetPlayerName().tolower() ) )
	{
		hasRCONAdmin = true;
	}
	if ( file.RCON.contains( player.GetPlayerName() ) )
	{
		hasRCONAdmin = true;
	}
	if ( file.RCON.contains( player.GetUID() ) )
	{
		hasRCONAdmin = true;
		return;
	}
}