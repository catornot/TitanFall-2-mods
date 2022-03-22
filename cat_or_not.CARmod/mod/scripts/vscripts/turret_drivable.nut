untyped

global function SetupTurretStuff

const vector turret_offset = <0,-100,50>

const array<int> MYOWNTURRET_CANCEL_BUTTONS =
[
	IN_USE
]

struct
{
    table<entity,entity> turretsPerPlayer
} file

void function SetupTurretStuff( CARstruct CAR, vector origin )
{
    CAR.turret = CreateNPC( "npc_turret_sentry", TEAM_BOTH, origin + turret_offset, <0,90,0> )
    SetSpawnOption_AISettings( CAR.turret, "npc_turret_sentry")
	CAR.turret.kv.teamnumber = 0
    CAR.turret.kv.modelscale = 2
	CAR.turret.kv.origin = origin + turret_offset
	CAR.turret.kv.angles = <0,90,0>
	DispatchSpawn( CAR.turret )

    CAR.turret.EnableTurret()
    thread FinalTurretSetup( CAR )
}

void function FinalTurretSetup( CARstruct CAR )
{
    CAR.turret.SetUsable()
    CAR.turret.SetUsableByGroup( "pilot" )
    CAR.turret.SetUsePrompts( "Hold %use% to use Turret", "Press %use% to use Turret" )
    AddCallback_OnUseEntity( CAR.turret, playerDriveTurret )
    CAR.turret.SetParent( CAR.CARmover )
    CAR.turret.SetTitle( "" )
    WaitFrame()
    CAR.turret.DisableTurret()

}

function playerDriveTurret( turret, player )
{
    Assert( player.IsPlayer() )
    expect entity( player )
    expect entity( turret )

    print( player.GetPlayerName() )

    if ( turret.GetOwner() == player )
	{
		DismebarkTurret( player )
        print( player.GetPlayerName() )
	}
	else
	{
		if ( turret.GetOwner() == null )
		{
            player.ForceStand()
            entity playerMover = CreateOwnedScriptMover( player )
            player.SetParent( playerMover, "ref", true )
            vector forward = turret.GetForwardVector()
            vector basePos = turret.GetOrigin() + (forward * -30) + <0,0,30>
            vector startOrigin = player.GetOrigin()
            float moveTime = 0.1
            playerMover.NonPhysicsMoveTo( basePos, moveTime, 0.0, 0.0 )
            playerMover.NonPhysicsRotateTo( turret.GetAngles(), moveTime, 0, 0 )
            // player.FreezeControlsOnServer()
            turret.SetOwner( player )

            if ( !(player in file.turretsPerPlayer) )
            {
                file.turretsPerPlayer[player] <- turret
            }
            else
            {
                file.turretsPerPlayer[player] = turret
            }
        

            StorePilotWeapons( player )
            
			AddEntityCallback_OnDamaged( player, playerDamagedOnTurret )
			
            player.GiveWeapon( "mp_weapon_arena1", [] )
            player.SetActiveWeaponByName( "mp_weapon_arena1" )

            thread ClearPlayerFromTurretOnDeathAndOtherStuff( turret, player )
		}
		else
		{
			SendHudMessage( player, "Turret in use.", -1, 0.4, 255, 255, 0, 255, 0.0, 0.5, 0.0 )
		}
	}
}

void function ClearPlayerFromTurretOnDeathAndOtherStuff( entity turret, entity player )
{
    wait 0.5
    // player.UnfreezeControlsOnServer()
    foreach( int button in MYOWNTURRET_CANCEL_BUTTONS )
        AddButtonPressedPlayerInputCallback( player, button, DismebarkTurret )
    
    entity Pmover = player.GetParent()
    vector MoverOffset 
    
    for(;;)
    {
        if ( !IsValid( turret ) || !IsAlive( turret ) )
        {
            player.ClearParent()
            Pmover.Destroy()
            player.Die()
            break
        }

        MoverOffset = turret.GetOrigin() + (turret.GetForwardVector() * -30) + <0,0,50>
            
        if ( !IsAlive( player ) )
            break

        if ( turret.GetOwner() != player )
            return
        
        if ( player.EyeAngles().y != turret.GetAngles().y ) // this does turret spin uwu
        {
            vector angle = <0,player.EyeAngles().y,0>
            turret.SetAngles( angle )
            // Pmover.RotateTo( angle, 0.1, 0.05, 0.05 )
            player.SetOrigin( MoverOffset )
        }

        Pmover.MoveTo( MoverOffset, 0.1, 0.05, 0.05 )

        WaitFrame()
    }

	if ( IsValid( turret ) && IsAlive( turret ) )
        turret.SetOwner( null )

    if ( IsValid( player ) )
    {
        foreach( int button in MYOWNTURRET_CANCEL_BUTTONS )
            RemoveButtonPressedPlayerInputCallback( player, button, DismebarkTurret )
    }
}

void function playerDamagedOnTurret( entity player, var damageInfo )
{
    DismebarkTurret( player )
}

void function DismebarkTurret( entity player )
{
    if ( IsValid( player ) )
    {
        RetrievePilotWeapons( player )
        entity Pmover = player.GetParent()
        player.ClearParent()
        player.UnforceStand()
        // PutEntityInSafeSpot( player, player, null, player.GetOrigin(), player.GetOrigin() )
        ScreenFade( player, 0, 0, 0, 255, 0.3, 0.3, (FFADE_IN | FFADE_PURGE) )

        foreach( int button in MYOWNTURRET_CANCEL_BUTTONS )
            RemoveButtonPressedPlayerInputCallback( player, button, DismebarkTurret )
        
        try{
            Pmover.Destroy()
            RemoveEntityCallback_OnDamaged( player, playerDamagedOnTurret )
        }
        catch( exception )
        {
            print( exception )
        }
    }

    if ( player in file.turretsPerPlayer )
    {
        if ( !IsAlive( file.turretsPerPlayer[player] ) )
            return

        if ( file.turretsPerPlayer[player].GetOwner() == player )
            file.turretsPerPlayer[player].SetOwner( null )
    }
}

// function TurretPanelActivateThread( turret, player )
// {
// 	expect entity( turret )
// 	expect entity( player )

//     player.SetOrigin( vector origin = _PositionBasedOnAngle( <0,20,0>, turret.GetAngles().y, <0,0,0> ) + turret.GetOrigin() )

// 	string tag = "camera_glow"
// 	asset effect
// 	entity fx
// 	int fxId
// 	int attachId = turret.LookupAttachment( tag )

// 	array<entity> fxArray = []

// 	effect = REMOTE_TURRET_AIM_FX_ENEMY
// 	fxId = GetParticleSystemIndex( effect )
// 	fx = StartParticleEffectOnEntity_ReturnEntity( turret, fxId, FX_PATTACH_POINT_FOLLOW, attachId )
// 	fx.kv.VisibilityFlags = ENTITY_VISIBLE_TO_ENEMY
// 	fx.SetOwner( player )
// 	SetTeam( fx, player.GetTeam() )
// 	fxArray.append( fx )

// 	effect = REMOTE_TURRET_AIM_FX_FRIENDLY
// 	fxId = GetParticleSystemIndex( effect )
// 	fx = StartParticleEffectOnEntity_ReturnEntity( turret, fxId, FX_PATTACH_POINT_FOLLOW, attachId )
// 	fx.kv.VisibilityFlags = ENTITY_VISIBLE_TO_FRIENDLY
// 	fx.SetOwner( player )
// 	SetTeam( fx, player.GetTeam() )
// 	fxArray.append( fx )

// 	vector originalLocalAngles = player.GetLocalAngles()

// 	RemoteTurretSettings info = expect RemoteTurretSettings( turret.remoteturret.settings )

// 	vector turretAngles = turret.GetAngles()

// 	turret.SetDriver( player )
// 	player.p.controllingTurret = true
// 	SetTeam( turret, player.GetTeam() )
// 	turret.SetBossPlayer( player )

// 	vector centerViewAngles = turretAngles + < info.viewStartPitch, 0, 0>

// 	ScreenFade( player, 0, 0, 0, 255, 0.3, 0.3, (FFADE_IN | FFADE_PURGE) )
// 	float frac = float( turret.GetHealth() ) / float( turret.GetMaxHealth() )
// 	turret.remoteturret.statusEffectID = StatusEffect_AddEndless( player, eStatusEffect.emp, 1.0-frac )

// 	// Panel should already have been marked in-use:

// 	int originalUseValue = expect int( oldUsableValue )

// 	OnThreadEnd(
// 	function() : ( player, turret, info, originalLocalAngles, fxArray, originalUseValue )
// 		{
// 			foreach ( fx in fxArray )
// 			{
// 				if ( IsValid( fx ) )
// 				{
// 					EffectStop( fx )
// 				}
// 			}

// 		 	if ( IsValid( player ) )
// 		 	{
// 				player.p.controllingTurret = false
// 				foreach( int button in MYOWNTURRET_CANCEL_BUTTONS )
// 					RemoveButtonPressedPlayerInputCallback( player, button, DisembarkButtonCallback )

// 				if ( info.viewClampEnabled )
// 					ViewConeFree( player )
// 				player.SetLocalAngles( originalLocalAngles )
// 		 	}

// 		 	if ( IsValid( turret ) )
// 		 	{
// 				turret.ClearDriver()
// 				SetTeam( turret, TEAM_UNASSIGNED )
// 				turret.SetTitle( "" )
// 				turret.ClearBossPlayer()

// 				if ( IsValid( player ) )
// 				{
// 					ScreenFade( player, 0, 0, 0, 255, 2, 0.2, (FFADE_IN | FFADE_PURGE) )
// 					StatusEffect_Stop( player, turret.remoteturret.statusEffectID )
// 				}
// 		 	}
// 		}
// 	)

// 	player.SnapEyeAngles( centerViewAngles )

// 	wait 0.3

// 	foreach( int button in MYOWNTURRET_CANCEL_BUTTONS )
// 		AddButtonPressedPlayerInputCallback( player, button, DisembarkButtonCallback )

// 	WaitForever()
//

// function MonitorPilot( entity turret, entity player )
// {

// 	player.EndSignal( "OnDestroy" )
// 	player.EndSignal( "DismebarkATTurret")
// 	turret.EndSignal( "OnDestroy" )

// 	player.ForceStand()
// 	entity playerMover = CreateOwnedScriptMover( player )
// 	player.SetParent( playerMover, "ref", true )
// 	vector forward = turret.GetForwardVector()
// 	vector basePos = turret.GetOrigin() + forward * -25
// 	vector startOrigin = player.GetOrigin()
// 	float moveTime = 0.1
// 	playerMover.NonPhysicsMoveTo( basePos, moveTime, 0.0, 0.0 )
// 	playerMover.NonPhysicsRotateTo( turret.GetAngles() + <0,30,0>, moveTime, 0, 0 )
// 	player.FreezeControlsOnServer()

// 	StorePilotWeapons( player )

// 	OnThreadEnd(
// 	function() : ( turret, player, playerMover, startOrigin )
// 		{
// 		 	if ( IsValid( player ) )
// 		 	{
// 				player.ClearParent()
// 				player.UnforceStand()
// 				ClearPlayerAnimViewEntity( player )
// 				player.UnfreezeControlsOnServer()
// 				RetrievePilotWeapons( player )
// 				ViewConeZeroInstant( player )
// 				foreach( int button in MYOWNTURRET_CANCEL_BUTTONS )
// 					RemoveButtonPressedPlayerInputCallback( player, button, PROTO_DisembarkATTurret )
// 				RemoveEntityCallback_OnDamaged( player, PlayerDamagedWhileOnTurret )
// 				player.p.PROTO_UseDebounceEndTime = Time() + USE_DEBOUNCE_TIME
// 				PutEntityInSafeSpot( player, turret, null, startOrigin, player.GetOrigin() )
// 		 	}

// 		 	if ( IsValid( turret ) )
// 		 	{
// 		 		// turret.EnableDraw()
// 		 		// turret.Solid()
// 				// SetShieldWallCPointOrigin( turret.e.shieldWallFX, AT_TURRET_SHIELD_COLOR )
// 		 		turret.SetOwner( null )
// 		 	}

// 		 	playerMover.Destroy()
// 		}
// 	)

// 	wait moveTime

// 	// player.PlayerCone_SetSpecific( forward )
// 	// ViewConeZeroInstant( player )

// 	// PROTO: Supporting ability to pick different turret weapons for turrets in LevelEd and the legacy Defender prototype turret
// 	// We need a predator cannon style turret in SP.
	

// 	wait 0.1

// 	player.UnfreezeControlsOnServer()

// 	// ViewConeLockedForward( player )

//  	player.WaitSignal( "OnDeath" )
// }