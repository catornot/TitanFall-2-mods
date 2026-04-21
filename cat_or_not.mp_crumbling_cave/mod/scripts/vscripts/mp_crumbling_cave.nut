global function CodeCallback_MapInit

void function CodeCallback_MapInit()
{
    Riff_ForceTitanAvailability( eTitanAvailability.Never )
    ClassicMP_SetCustomIntro( ClassicMP_DefaultNoIntro_Setup, 1.0 )

    AddSpawnCallback( "func_brush_lightweight", SetupBreakableWall )
}

void function SetupBreakableWall( entity wall )
{
    wall.SetMaxHealth( 300 )
	wall.SetHealth( 300 )
	wall.SetTakeDamageType( DAMAGE_YES )
    wall.SetDamageNotifications( true )

    AddEntityCallback_OnDamaged( wall, WallOnDamaged )
}

void function WallOnDamaged( entity wall, var damageInfo )
{
	float damage = DamageInfo_GetDamage( damageInfo )
    float newHealth = wall.GetHealth() - damage
    entity attacker = DamageInfo_GetAttacker( damageInfo )

    // if ( !(DamageInfo_GetCustomDamageType( damageInfo ) & DF_EXPLOSION) )
    //     return

    if ( damage >= wall.GetHealth() - damage )
    {
        wall.Hide()
        wall.kv.solid = 0
        wall.SetTakeDamageType( DAMAGE_NO )
        wall.SetDamageNotifications( false )

        DamageInfo_SetDamage( damageInfo, 0 )
    }
    
    EmitSoundOnEntity( wall, "breakable_glass" )
    
    if ( !attacker.IsPlayer() )
        return

    attacker.NotifyDidDamage( wall, 0, wall.GetOrigin(), 0, damage, DF_NO_HITBEEP, 0, null, 0 )
}