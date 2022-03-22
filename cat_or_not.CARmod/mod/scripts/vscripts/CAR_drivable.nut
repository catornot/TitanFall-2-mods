untyped
global function SpawnCAR
global function AddPlayerToKeysList


// Movement
global function PlayerMoveJumpC
global function PlayerMoveDuckC
global function PlayerMoveFORWARDC
global function PlayerMoveBACKC
global function PlayerMoveRIGHTC
global function PlayerMoveLEFTC
global function PlayerMoveUSEC

// Not Movment
global function PlayerStopJumpC
global function PlayerStopDuckC
global function PlayerStopFORWARDC
global function PlayerStopBACKC
global function PlayerStopRIGHTC
global function PlayerStopLEFTC
global function PlayerStopUSEC

const int KJ = 0
const int KD = 1
const int KF = 2
const int KB = 3
const int KL = 4
const int KR = 5
const int KU = 6

const float EmbarkRadius = 15000.0
const vector originalOffsetPoint = <0,50,0>
const vector originalOffsetCam = < 0,-400,200>
const vector rayOffset = <0,0,30>
const vector rayClimbOffset = <0,0,20>
const vector turret_offset = <0,-100,50>

const array<vector> wheeloffsets = [ <30,100,0>, < -30,100,0>, <30,-100,0>, < -30,-100,0> ]

const float fallingSpeed = 50.0
const float risingSpeed = 20.0

global struct CARstruct
{
    entity car
    bool hasPlayer = false
    bool IsFalling = false
    entity player = null
    vector offsetlocation = originalOffsetPoint
    entity CARmover
    entity CamMover
    entity camera
    entity turret
    float acceleration = 0.85
    float health = 1000.0
    float time_enter
    vector vertical_offset
}

struct
{
    table< entity, array<bool> > keys
    table< entity, CARstruct > cars
} file

/*
███████╗███████╗████████╗██╗   ██╗██████╗ 
██╔════╝██╔════╝╚══██╔══╝██║   ██║██╔══██╗
███████╗█████╗     ██║   ██║   ██║██████╔╝
╚════██║██╔══╝     ██║   ██║   ██║██╔═══╝ 
███████║███████╗   ██║   ╚██████╔╝██║     
╚══════╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝     
                                          
*/


CARstruct function SpawnCAR( vector origin )
{
    CARstruct CAR
    CAR.car = CreateEntity( "prop_dynamic" )

    file.cars[CAR.car] <- CAR

    CAR.CARmover = CreateExpensiveScriptMover()

    CAR.car.SetValueForModelKey( $"models/vehicles_r2/vehicles/samson/samson.mdl" )
	CAR.car.kv.fadedist = 20000
	CAR.car.kv.renderamt = 255
	CAR.car.kv.rendercolor = "81 130 151"
	CAR.car.kv.solid = SOLID_VPHYSICS
    
    CAR.car.kv.health = 1000
    CAR.car.kv.max_health = 1000
    CAR.car.SetTakeDamageType( DAMAGE_YES )
	SetTeam( CAR.car, TEAM_BOTH )
	CAR.car.SetOrigin( origin )
	CAR.car.SetAngles( <0,0,0> )
	DispatchSpawn( CAR.car )
    CAR.car.SetUsable()
    CAR.car.SetUsableByGroup( "pilot" )
    CAR.car.SetUsePrompts( "Hold %use% to use CAR", "Press %use% to use CAR" )
    AddCallback_OnUseEntity( CAR.car, SetDriverForCAR )
    AddEntityCallback_OnDamaged(CAR.car, OnCARohNoItGetsDamagedWhatDoWeDoDoWeDieIDKmaybePetarknowsLetsAskHimNiceFunctionNameYouGotHereThought)

    CAR.car.SetTitle( "CAR" )

    CAR.CARmover.SetOrigin( origin )
    CAR.car.SetParent( CAR.CARmover )

    thread SetupTurretStuff( CAR, origin )
    thread CarUpdate( CAR )
    
    // CreateLightSprite( origin, <0,0,0>, "81 130 151", 300.0 )
    return CAR
}

void function CarUpdate( CARstruct CAR )
{
    array<bool> keys
    bool canMoveF
    bool canMoveB
    while( IsValid( CAR.car ) && CAR.health > 0.0 )
    {
        foreach( entity player in GetPlayerArray() )
        {
            
            bool InRadius = ( DistanceSqr( player.GetOrigin(), CAR.car.GetOrigin() ) <= EmbarkRadius )

            if ( CAR.player == player && file.keys[player][KU] && CAR.hasPlayer && ((CAR.time_enter + 0.5) < Time()) )
            {
                DestroyCameraAbove( CAR )
                player.ClearParent()
                player.SetOrigin( CAR.car.GetOrigin() + <0,0,150> ) // Because you spin it each time the rotation of the point around the other may add resulting in missing the destination, so I belive it is neceary to caculate it from a const point
                player.Show()
                CAR.hasPlayer = false
                ScreenFade( player, 0, 0, 0, 255, 0.3, 0.3, (FFADE_IN | FFADE_PURGE) )
            }
            else if ( InRadius && CAR.hasPlayer && file.keys[player][KD] && CAR.player != player )
            {
                player.SetParent( CAR.car )
            }
            else if ( player.GetParent() == CAR.car && CAR.player != player )
            {
                player.ClearParent()
            }

        }

        if ( CAR.hasPlayer && !CAR.IsFalling )
        {
            keys = file.keys[CAR.player]
            if ( keys[KF] || keys[KB] )
            {
                canMoveF = CanMoveF( CAR )
                canMoveB = CanMoveB( CAR )
                ProcessRising( CAR, [keys[KF],keys[KB]], [canMoveF,canMoveB] )
            }

            if ( keys[KF] && keys[KL] && canMoveF )
            {
                CAR.CARmover.RotateTo( CAR.CARmover.GetAngles() + <0,10,0>, 0.1, 0.05, 0.05 )
                CAR.offsetlocation = _PositionBasedOnAngle( originalOffsetPoint + CAR.car.GetOrigin(), -CAR.car.GetAngles().y - 10.0, CAR.car.GetOrigin() ) - CAR.car.GetOrigin()
                CAR.CARmover.MoveTo( CAR.vertical_offset + CAR.CARmover.GetOrigin() + CAR.offsetlocation  * CAR.acceleration, 0.1, 0.05, 0.05 )
            }
            else if ( keys[KF] && keys[KR] && canMoveF )
            {
                CAR.CARmover.RotateTo( CAR.CARmover.GetAngles() + <0,-10,0>, 0.1, 0.05, 0.05 )
                CAR.offsetlocation = _PositionBasedOnAngle( originalOffsetPoint + CAR.car.GetOrigin(), -CAR.car.GetAngles().y + 10.0, CAR.car.GetOrigin() ) - CAR.car.GetOrigin()
                CAR.CARmover.MoveTo( CAR.vertical_offset + CAR.CARmover.GetOrigin() + CAR.offsetlocation  * CAR.acceleration, 0.1, 0.05, 0.05 )
            }

            else if ( keys[KB] && keys[KL] && canMoveB )
            {
                CAR.CARmover.RotateTo( CAR.CARmover.GetAngles() + <0,-10,0>, 0.1, 0.05, 0.05 )
                CAR.offsetlocation = _PositionBasedOnAngle( originalOffsetPoint + CAR.car.GetOrigin(), -CAR.car.GetAngles().y + 10.0, CAR.car.GetOrigin() ) - CAR.car.GetOrigin()
                CAR.CARmover.MoveTo( CAR.vertical_offset + CAR.CARmover.GetOrigin() + -CAR.offsetlocation  * CAR.acceleration, 0.1, 0.05, 0.05 )
            }
            else if ( keys[KB] && keys[KR] && canMoveB )
            {
                CAR.CARmover.RotateTo( CAR.CARmover.GetAngles() + <0,10,0>, 0.1, 0.05, 0.05 )
                CAR.offsetlocation = _PositionBasedOnAngle( originalOffsetPoint + CAR.car.GetOrigin(), -CAR.car.GetAngles().y - 10.0, CAR.car.GetOrigin() ) - CAR.car.GetOrigin()
                CAR.CARmover.MoveTo( CAR.vertical_offset + CAR.CARmover.GetOrigin() + -CAR.offsetlocation  * CAR.acceleration, 0.1, 0.05, 0.05 )
            }
            else if ( keys[KF] && canMoveF )
            {
                CAR.CARmover.MoveTo( CAR.vertical_offset + CAR.CARmover.GetOrigin() + CAR.offsetlocation  * CAR.acceleration, 0.1, 0.05, 0.05 )
            }
            else if ( keys[KB] && canMoveB )
            {
                CAR.CARmover.MoveTo( CAR.vertical_offset + CAR.CARmover.GetOrigin() + -CAR.offsetlocation * CAR.acceleration, 0.1, 0.05, 0.05 )
            }
            else if (  !( CAR.acceleration - 0.85  <= 0.0 ) && CanMoveF( CAR ) )
            {
                CAR.CARmover.MoveTo( CAR.vertical_offset + CAR.CARmover.GetOrigin() + CAR.offsetlocation * ( CAR.acceleration - 0.85 ), 0.1, 0.05, 0.05 )
                DecreaseAcceleration( CAR )
            }
            
            if ( keys[KB] || keys[KF] )
            {
                IncreaseAcceleration( CAR )
            }
            else 
            {
                DecreaseAcceleration( CAR )
            }

            UpdatedCameraPosition( CAR )
        }
        else if ( CAR.IsFalling && CAR.hasPlayer )
        {
            ProcessFalling( CAR )
            CAR.CARmover.MoveTo( CAR.vertical_offset + CAR.CARmover.GetOrigin() + CAR.offsetlocation * ( CAR.acceleration - 0.85 ), 0.1, 0.05, 0.05 )
            UpdatedCameraPosition( CAR )
        }
        else if (  !( CAR.acceleration - 0.85  <= 0.0 ) && canMoveF )
        {
            CAR.CARmover.MoveTo( CAR.CARmover.GetOrigin() + CAR.offsetlocation * ( CAR.acceleration - 0.85 ), 0.1, 0.05, 0.05 )
            DecreaseAcceleration( CAR )
        }
        
        // DebugDrawLine( CAR.car.GetOrigin(), CAR.offsetlocation + CAR.car.GetOrigin(), 255, 0, 0, true, 200.0 )
        
        ProcessFalling( CAR )

        WaitFrame()
    }
    if ( IsValid( CAR.car ) )
    {
        vector origin = CAR.CARmover.GetOrigin()
        if ( CAR.hasPlayer )
        {
            DestroyCameraAbove( CAR )
            CAR.player.Show()
            CAR.player.SetOrigin( origin + <0,0,150> )
            CAR.player.SetVelocity( <0,0,2000> )
            CAR.player.ClearParent()
        }
        wait 0.1

        PlayImpactFXTable( origin, CAR.CamMover, "titan_exp_ground" )
        EmitSoundOnEntity( CAR.car, "diag_spectre_gs_LeechAborted_01_1" )

        CAR.car.UnsetUsable()
        wait 0.3

        if ( CAR.turret.GetOwner() != null )
        {
            entity player = CAR.turret.GetOwner()
            player.SetVelocity( _PositionBasedOnAngle( turret_offset, CAR.turret.GetAngles().y, <0,0,0> ) * 10 )
            ScreenFade( player, 0, 0, 0, 255, 0.3, 0.3, (FFADE_IN | FFADE_PURGE) )
        }
        wait 0.2
        CAR.turret.Die()

        ClearChildren( CAR.car )
        CAR.car.SetScriptName( "CAR ded" )
    }
}

void function OnCARohNoItGetsDamagedWhatDoWeDoDoWeDieIDKmaybePetarknowsLetsAskHimNiceFunctionNameYouGotHereThought( entity car, var damageInfo )
{
    print( DamageInfo_GetDamage( damageInfo ) )

    if ( car in file.cars )
    {
        file.cars[car].health -= DamageInfo_GetDamage( damageInfo )
        print( file.cars[car].health )
        if ( file.cars[car].health < 0 )
            return
    }
    entity attacker = DamageInfo_GetAttacker( damageInfo )
    attacker.NotifyDidDamage( car, 0, DamageInfo_GetDamagePosition( damageInfo ), DamageInfo_GetCustomDamageType( damageInfo ), DamageInfo_GetDamage( damageInfo ), DamageInfo_GetDamageFlags( damageInfo ), DamageInfo_GetHitGroup( damageInfo ), DamageInfo_GetWeapon( damageInfo ), DamageInfo_GetDistFromAttackOrigin( damageInfo ) )
}

function SetDriverForCAR( car, player )
{
    Assert( player.IsPlayer() )
    expect entity( player )
    expect entity( car )
    
    if ( car in file.cars )
    {
        CARstruct CAR = file.cars[car]
        if ( !CAR.hasPlayer && CAR.turret.GetOwner() != player )
        {
             // PlayAnim( player, "ptpov_rodeo_panel_aim_idle" ) // "pt_mp_execution_attacker_grapple" )
            CAR.time_enter = Time()
            player.SetOrigin( CAR.car.GetOrigin() + <0,0,50> )
            player.SetParent( CAR.car )
            player.Hide()
            CAR.player = player
            CAR.hasPlayer = true
            SpawnCameraAbove( CAR.player, CAR )
            ScreenFade( player, 0, 0, 0, 255, 0.3, 0.3, (FFADE_IN | FFADE_PURGE) )

            // MessageToPlayer( player, "You entered CAR", player ) // :(
        }
    }
}

/*
██╗   ██╗████████╗██╗██╗     ██╗████████╗██╗███████╗███████╗
██║   ██║╚══██╔══╝██║██║     ██║╚══██╔══╝██║██╔════╝██╔════╝
██║   ██║   ██║   ██║██║     ██║   ██║   ██║█████╗  ███████╗
██║   ██║   ██║   ██║██║     ██║   ██║   ██║██╔══╝  ╚════██║
╚██████╔╝   ██║   ██║███████╗██║   ██║   ██║███████╗███████║
 ╚═════╝    ╚═╝   ╚═╝╚══════╝╚═╝   ╚═╝   ╚═╝╚══════╝╚══════╝                                                                                              
*/

bool function CanMoveB( CARstruct CAR )
{
    try {
    TraceResults traceResult = TraceLine( CAR.CARmover.GetOrigin() + rayOffset, -CAR.offsetlocation * 3 + CAR.CARmover.GetOrigin() + rayOffset, [ CAR.car, CAR.camera, CAR.player, CAR.CamMover, CAR.CARmover, CAR.turret ], TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE )
    
    vector otheroffset = _PositionBasedOnAngle( originalOffsetPoint + CAR.car.GetOrigin(), -CAR.car.GetAngles().y + 10, CAR.car.GetOrigin() ) - CAR.car.GetOrigin()
    TraceResults traceResult2 = TraceLine( CAR.CARmover.GetOrigin() + rayOffset, -otheroffset * 3 + CAR.CARmover.GetOrigin() + rayOffset, [ CAR.car, CAR.camera, CAR.player, CAR.CamMover, CAR.CARmover, CAR.turret ], TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE )

    otheroffset = _PositionBasedOnAngle( originalOffsetPoint + CAR.car.GetOrigin(), -CAR.car.GetAngles().y - 10, CAR.car.GetOrigin() ) - CAR.car.GetOrigin()
    TraceResults traceResult3 = TraceLine( CAR.CARmover.GetOrigin() + rayOffset, -otheroffset * 3 + CAR.CARmover.GetOrigin() + rayOffset, [ CAR.car, CAR.camera, CAR.player, CAR.CamMover, CAR.CARmover, CAR.turret ], TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE )
    
    if ( traceResult.hitEnt == null && traceResult2.hitEnt == null && traceResult3.hitEnt == null )
    {
        return true
    }
    else if ( ( traceResult.hitEnt.IsNPC() || traceResult2.hitEnt.IsNPC() || traceResult3.hitEnt.IsNPC() ) || ( traceResult.hitEnt.IsPlayer() || traceResult2.hitEnt.IsPlayer() || traceResult3.hitEnt.IsPlayer() ) )
    {
        foreach ( TraceResults result in [ traceResult, traceResult2, traceResult3 ] )
        {
            if ( result.hitEnt.IsNPC() || result.hitEnt.IsPlayer() )
                result.hitEnt.Die()
        }
    }

    return false
    }
    catch ( exception )
    {
        return false
    }
}
bool function CanMoveF( CARstruct CAR )
{
    try {
    TraceResults traceResult = TraceLine( CAR.CARmover.GetOrigin() + rayOffset, CAR.offsetlocation * 3 + CAR.CARmover.GetOrigin() + rayOffset, [ CAR.car, CAR.camera, CAR.player, CAR.CamMover, CAR.CARmover, CAR.turret ], TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE )
    
    vector otheroffset = _PositionBasedOnAngle( originalOffsetPoint + CAR.car.GetOrigin(), -CAR.car.GetAngles().y + 10, CAR.car.GetOrigin() ) - CAR.car.GetOrigin()
    TraceResults traceResult2 = TraceLine( CAR.CARmover.GetOrigin() + rayOffset, otheroffset * 3 + CAR.CARmover.GetOrigin() + rayOffset, [ CAR.car, CAR.camera, CAR.player, CAR.CamMover, CAR.CARmover, CAR.turret ], TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE )

    otheroffset = _PositionBasedOnAngle( originalOffsetPoint + CAR.car.GetOrigin(), -CAR.car.GetAngles().y - 10, CAR.car.GetOrigin() ) - CAR.car.GetOrigin()
    TraceResults traceResult3 = TraceLine( CAR.CARmover.GetOrigin() + rayOffset, otheroffset * 3 + CAR.CARmover.GetOrigin() + rayOffset, [ CAR.car, CAR.camera, CAR.player, CAR.CamMover, CAR.CARmover, CAR.turret ], TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE )
    
    
    if ( traceResult.hitEnt == null && traceResult2.hitEnt == null && traceResult3.hitEnt == null )
    {
        return true
    }
    else if ( ( traceResult.hitEnt.IsNPC() || traceResult2.hitEnt.IsNPC() || traceResult3.hitEnt.IsNPC() ) || ( traceResult.hitEnt.IsPlayer() || traceResult2.hitEnt.IsPlayer() || traceResult3.hitEnt.IsPlayer() ) )
    {
        foreach ( TraceResults result in [ traceResult, traceResult2, traceResult3 ] )
        {
            if ( result.hitEnt.IsNPC() || result.hitEnt.IsPlayer() )
                result.hitEnt.Die()
        }
    }

    return false
    }
    catch ( exception )
    {
        return false
    }
}

void function ProcessFalling( CARstruct CAR )
{
   if ( IsFalling( CAR ) )
   {
       CAR.IsFalling = true
       vector origin = CAR.CARmover.GetOrigin()
       if ( origin.z - OriginToGround( origin ).z < fallingSpeed )
       {
            // CAR.CARmover.MoveTo( OriginToGround( origin ), 0.05,0,0 )
            CAR.vertical_offset = <0,0,-(OriginToGround( origin ).z-origin.z)>
            CAR.IsFalling = false
            CAR.vertical_offset = <0,0,0>
            // print( "landing" ) // :trol:
            IsFalling( CAR )
            return
       }
       else
       {
        //    CAR.CARmover.MoveTo( origin - <0,0,fallingSpeed>, 0.05,0,0 )
            CAR.vertical_offset = <0,0,-fallingSpeed>
       }

       if ( !CAR.hasPlayer )
       {
            CAR.CARmover.MoveTo( origin + CAR.vertical_offset, 0.05,0,0 )
       }
   } 
   else
   {
       CAR.IsFalling = false
       CAR.vertical_offset = <0,0,0>
   }
}

bool function IsFalling( CARstruct CAR )
{
    TraceResults traceResult
    vector NewWheeloffset
    foreach( vector wheeloffset in wheeloffsets )
    {
        NewWheeloffset = _PositionBasedOnAngle( wheeloffset, -CAR.car.GetAngles().y, <0,0,0> )
        traceResult = TraceLine( CAR.CARmover.GetOrigin() + NewWheeloffset, CAR.CARmover.GetOrigin() + NewWheeloffset - <0,0,30>, [ CAR.car, CAR.CARmover, CAR.turret ], TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE )

        if ( traceResult.hitEnt != null )
        {
            return false
        }
    }
    return true
}

void function ProcessRising( CARstruct CAR, array<bool> keys, array<bool> canMove )
{
    print(CanRise( CAR, 1 ) && canMove[0] && keys[0] && !CAR.IsFalling)
    if ( CanRise( CAR, 1 ) && canMove[0] && keys[0] && !CAR.IsFalling )
    {
        CAR.vertical_offset = <0,0,risingSpeed>
    }
    else if ( CanRise( CAR, -1 ) && canMove[1] && keys[1] && !CAR.IsFalling )
    {
        CAR.vertical_offset = <0,0,risingSpeed>
    } 
    else if ( !CAR.IsFalling )
    {
        CAR.vertical_offset = <0,0,0>
    }
}

bool function CanRise( CARstruct CAR, int direction )
{
    TraceResults traceResult
    vector NewRayClimbOffset
    foreach( float angle in [10.0,0.0,-10.0] )
    {
        NewRayClimbOffset = _PositionBasedOnAngle( rayClimbOffset + CAR.offsetlocation * direction, -CAR.car.GetAngles().y + angle, <0,0,0> )
        traceResult = TraceLine( CAR.car.GetOrigin() + NewRayClimbOffset * 3, CAR.car.GetOrigin() + NewRayClimbOffset * 3, [ CAR.car, CAR.CARmover, CAR.turret ], TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE )

        if ( traceResult.hitEnt != null )
        {
            return true
        }
    }
    return false
}

void function IncreaseAcceleration( CARstruct CAR )
{
    if ( CAR.acceleration < 1.26 )
    {
        CAR.acceleration += 0.01
    }
}
void function DecreaseAcceleration( CARstruct CAR )
{
    if ( CAR.acceleration > 0.85 )
    {
        CAR.acceleration -= 0.02
    }
}

void function SpawnCameraAbove( entity player, CARstruct CAR )
{
    vector origin = _PositionBasedOnAngle( originalOffsetCam, -CAR.car.GetAngles().y, <0,0,0> )

    CAR.player.SnapEyeAngles( CAR.car.GetAngles() )
    entity viewControl = CreateEntity( "point_viewcontrol" )
	viewControl.kv.spawnflags = 56 // infinite hold time, snap to goal angles, make player non-solid

	viewControl.SetOrigin( origin + CAR.car.GetOrigin() )
	viewControl.SetAngles( CAR.car.GetAngles() )
	DispatchSpawn( viewControl )

    viewControl.Fire( "Enable", "!activator", 0, player )
    entity mover = CreateExpensiveScriptMover()
    CAR.player.SnapEyeAngles( CAR.car.GetAngles() )
    mover.SetOrigin( origin + CAR.car.GetOrigin() )
	mover.SetAngles( CAR.car.GetAngles() )
    viewControl.SetParent( mover )

    CAR.CamMover = mover
    CAR.camera = viewControl
    
    CAR.player.SetAngles( CAR.car.GetAngles() + <0,90,0> )
    HolsterAndDisableWeapons( CAR.player )
    player.PlayerCone_SetLerpTime( 0.5 )
    CAR.player.PlayerCone_FromAnim()
	CAR.player.PlayerCone_SetMinYaw( 0 )
	CAR.player.PlayerCone_SetMaxYaw( 0 )
	CAR.player.PlayerCone_SetMinPitch( 0 )
	CAR.player.PlayerCone_SetMaxPitch( 0 )
}

void function DestroyCameraAbove( CARstruct CAR )
{
    CAR.camera.Fire( "Disable", "!activator", 0, CAR.player )
    CAR.player.ClearParent()
    CAR.camera.Destroy()
    CAR.CamMover.Destroy()
    DeployAndEnableWeapons( CAR.player )
    ViewConeFree( CAR.player )
}

void function UpdatedCameraPosition( CARstruct CAR )
{
    vector origin = _PositionBasedOnAngle( originalOffsetCam, -CAR.car.GetAngles().y, <0,0,0> )
    CAR.CamMover.MoveTo( origin + CAR.car.GetOrigin(), 0.3, 0.05, 0.05 )
	CAR.CamMover.RotateTo( CAR.car.GetAngles() + <0,90,0>, 0.3, 0.05, 0.05 )

    CAR.player.SnapEyeAngles( CAR.CamMover.GetAngles() )
}

vector function _PositionBasedOnAngle( vector CurrentPosition, float angle, vector origin ) //////// aaaaaaaaaaaaaaaaaaaaaaaaa
{
	float X = CurrentPosition.x
	float Y = CurrentPosition.y
	float offset_X = origin.x
    float offset_Y = origin.y
    float radians = angle * 0.017453

    float adjusted_x = (X - offset_X)
    float adjusted_y = (Y - offset_Y)
    float cos_rad = cos(radians)
    float sin_rad = sin(radians)
    float qx = offset_X + cos_rad * adjusted_x + sin_rad * adjusted_y
    float qy = offset_Y + -sin_rad * adjusted_x + cos_rad * adjusted_y

    CurrentPosition.x = qx
    CurrentPosition.y = qy

    return CurrentPosition
}

void function AddPlayerToKeysList( entity player )
{
    file.keys[player] <- [ false, false, false, false, false, false, false ]
}

/*
███╗   ███╗ ██████╗ ██╗   ██╗███████╗███╗   ███╗███████╗███╗   ██╗████████╗
████╗ ████║██╔═══██╗██║   ██║██╔════╝████╗ ████║██╔════╝████╗  ██║╚══██╔══╝
██╔████╔██║██║   ██║██║   ██║█████╗  ██╔████╔██║█████╗  ██╔██╗ ██║   ██║   
██║╚██╔╝██║██║   ██║╚██╗ ██╔╝██╔══╝  ██║╚██╔╝██║██╔══╝  ██║╚██╗██║   ██║   
██║ ╚═╝ ██║╚██████╔╝ ╚████╔╝ ███████╗██║ ╚═╝ ██║███████╗██║ ╚████║   ██║   
╚═╝     ╚═╝ ╚═════╝   ╚═══╝  ╚══════╝╚═╝     ╚═╝╚══════╝╚═╝  ╚═══╝   ╚═╝   
*/

void function _AddMovement( entity player, int MovementIndex )
{
    file.keys[player][MovementIndex] = true
} 
void function _RmMovement( entity player, int MovementIndex )
{
    file.keys[player][MovementIndex] = false
}

void function PlayerMoveJumpC( entity player )
{
    _AddMovement( player, KJ )
}
void function PlayerMoveDuckC( entity player )
{
    _AddMovement( player, KD )
}
void function PlayerMoveFORWARDC( entity player )
{
    _AddMovement( player, KF )
}
void function PlayerMoveBACKC( entity player )
{
    _AddMovement( player, KB )
}
void function PlayerMoveLEFTC( entity player )
{
    _AddMovement( player, KL )
}
void function PlayerMoveRIGHTC( entity player )
{
    _AddMovement( player, KR )
}
void function PlayerMoveUSEC( entity player )
{
    _AddMovement( player, KU )
}

// Not Movement

void function PlayerStopJumpC( entity player )
{
    _RmMovement( player, KJ )
}
void function PlayerStopDuckC( entity player )
{
    _RmMovement( player, KD )
}
void function PlayerStopFORWARDC( entity player )
{
    _RmMovement( player, KF )
}
void function PlayerStopBACKC( entity player )
{
    _RmMovement( player, KB )
}
void function PlayerStopLEFTC( entity player )
{
    _RmMovement( player, KL )
}
void function PlayerStopRIGHTC( entity player )
{
    _RmMovement( player, KR )
}
void function PlayerStopUSEC( entity player )
{
    _RmMovement( player, KU )
}


// vector playerOrg = player.GetOrigin()
// vector playerEyeForward = player.GetViewVector()
// vector playerEyePos = player.EyePosition()
// vector playerEyeAngles = player.EyeAngles()
// float yaw = playerEyeAngles.y