untyped // because of IsCrouched

global function Init_Sped

void function Init_Sped()
{
	AddCallback_OnPlayerRespawned( OnPlayerRespawned )

	thread FrictionConstantApply()
}

void function OnPlayerRespawned( entity player )
{
	player.SetGroundFrictionScale( 0 )

	thread CrouchSlowDown( player )
}

void function FrictionConstantApply()
{
	for(;;)
	{
		foreach( entity player in GetPlayerArray() )
		{
			if ( IsValid( player ) && IsAlive( player ) )
				player.SetGroundFrictionScale( 0 )
		}
		wait 1
	}
}

void function CrouchSlowDown( entity player )
{
	EndSignal( player, "OnDeath" )
	EndSignal( player, "OnDestroy" )

	for(;;)
	{
		if ( player.IsCrouched() && player.IsOnGround() )
			player.SetVelocity( <0,0,player.GetVelocity().z> )
		WaitFrame()
	}
}