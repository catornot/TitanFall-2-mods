untyped
global function PhaseSatchel_init


void function PhaseSatchel_init()
{
    // stuff for satchel mod
    AddPrivateMatchModeSettingEnum( "#MODE_SETTING_CATEGORY_PHASE_SATCHEL", "Satchel", [ "#SETTING_DISABLED", "#SETTING_ENABLED" ], "0" )
    AddPrivateMatchModeSettingEnum( "#MODE_SETTING_CATEGORY_PHASE_SATCHEL", "HOLO", [ "#SETTING_DISABLED", "#SETTING_ENABLED" ], "0" )
    
    #if SERVER 
    PrecacheModel($"models/props/turret_base/turret_base.mdl")
    PrecacheModel($"models/signs/flag_base_pole_ctf.mdl")

    if ( GetCurrentPlaylistVarInt("HOLO", 0) == 1 )
    {
        AddDamageCallback( "player_decoy", HoloDied )
        AddDeathCallback( "player_decoy", HoloDied )
    }

    if ( GetMapName() != "mp_relic02" )
        return

    AddCallback_EntitiesDidLoad( StartElevator )
    #endif
}

#if SERVER

void function StartElevator()
{   
    entity mover = CreateScriptMoverModel( $"models/props/turret_base/turret_base.mdl", < -40.5605, -1827.87, -223.944 >, <0,0,0>, SOLID_VPHYSICS, 1000 )
    mover.SetPusher( true )
    thread ElevatorThink( mover )
}

void function ElevatorThink( entity mover )
{
    for(;;)
    {
        mover.NonPhysicsMoveTo( < -35.4312, -1827.87, 523.046 >, 4.8, 0.1, 0.1 )
        wait 6

        mover.NonPhysicsMoveTo( < -35.4312, -1827.87, -223.944 >, 4.8, 0.1, 0.1 )
        wait 6
    }
}

void function HoloDied( entity decoy, var damageInfo )
{
    try
    {
    thread DecoyNukeDamage( decoy.GetTeam(), decoy.GetOrigin(), decoy )
    
    EmitSoundOnEntity( decoy, "explo_proximityemp_impact_3p" )
    }
    catch( aa )
    {
        print( aa )
    }
}

void function DecoyNukeDamage( int team, vector origin, entity attacker )
{
    try
    {
	entity inflictor = CreateExplosionInflictor( origin )

	OnThreadEnd(
		function() : ( inflictor )
		{
			if ( IsValid( inflictor ) )
				inflictor.Destroy()
		}
	)

	for ( int i = 0; i < 3; i++ )
	{

		entity explosionOwner
		if ( IsValid( attacker ) )
			explosionOwner = attacker
		else
			explosionOwner = GetTeamEnt( team )
        
        PlayImpactFXTable( origin, inflictor, "titan_exp_ground" )

		RadiusDamage_DamageDefSimple(
			damagedef_reaper_nuke,
			origin,								// origin
			explosionOwner,						// owner
			inflictor,							// inflictor
			0 )									// dist from attacker

		wait RandomFloatRange( 0.01, 0.21 )
	}
    }
    catch( aa )
    {
        print( aa )
    }
}

#endif

