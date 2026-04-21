global function initSmartPistolTears


void function initSmartPistolTears()
{
    AddCallback_OnReceivedSayTextMessage( Tears )
}

ClServer_MessageStruct function Tears( ClServer_MessageStruct message )
{
    if ( message.message.tolower().find("smart pistol") == null )
		return message

	foreach( entity player in GetPlayerArray() )
	{
		if ( player == message.player || !IsValid( player ) || !IsAlive( player ) )
			continue
		else if ( player.GetActiveWeapon().GetWeaponClassName() == "mp_weapon_smart_pistol" )
			RestockPlayerAmmo( player, true )
	}

    return message
}