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

// Not Movment
global function PlayerStopJumpC
global function PlayerStopDuckC
global function PlayerStopFORWARDC
global function PlayerStopBACKC
global function PlayerStopRIGHTC
global function PlayerStopLEFTC

const int KJ = 0
const int KD = 1
const int KF = 2
const int KB = 3
const int KL = 4
const int KR = 5

const float EmbarkRadius = 15000.0
const vector originalOffsetPoint = <0,30,0>
const vector originalOffsetCam = < 0,-400,200>

global struct CARstruct
{
    entity car
    bool hasPlayer = false
    entity player = null
    vector offsetlocation = originalOffsetPoint
    entity CamMover
    entity camera
}

struct
{
    table< entity, array<bool> > keys
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

    CAR.car.SetValueForModelKey( $"models/vehicles_r2/vehicles/samson/samson.mdl" )
	CAR.car.kv.fadedist = 20000
	CAR.car.kv.renderamt = 255
	CAR.car.kv.rendercolor = "81 130 151"
	CAR.car.kv.solid = SOLID_VPHYSICS
	SetTeam( CAR.car, TEAM_BOTH )

	CAR.car.SetOrigin( origin )
	CAR.car.SetAngles( <0,0,0> )
	DispatchSpawn( CAR.car )
    
    thread CarUpdate( CAR )

    return CAR
}

void function CarUpdate( CARstruct CAR )
{
    // FirstPersonSequenceStruct sequence
    // sequence.

    while( IsValid( CAR.car ) )
    {
        foreach( entity player in GetPlayerArray() )
        {
            
            bool InRadius = ( DistanceSqr( player.GetOrigin(), CAR.car.GetOrigin() ) <= EmbarkRadius )

            if ( InRadius && file.keys[player][KD] && !CAR.hasPlayer )
            {
                // PlayAnim( player, "ptpov_rodeo_panel_aim_idle" ) // "pt_mp_execution_attacker_grapple" )
                
                player.SetOrigin( CAR.car.GetOrigin() + <0,0,50> )
                player.SetParent( CAR.car )
                player.Hide()
                CAR.player = player
                CAR.hasPlayer = true
                SpawnCameraAbove( CAR.player, CAR )

                // MessageToPlayer( player, "You entered CAR", player )
            }
            else if ( CAR.player == player && file.keys[player][KD] && CAR.hasPlayer )
            {
                DestroyCameraAbove( CAR )
                player.ClearParent()
                player.SetOrigin( CAR.car.GetOrigin() + <0,0,150> ) // Because you spin it each time the rotation of the point around the other may add resulting in missing the destination, so I belive it is neceary to caculate it from a const point
                player.Show()
                CAR.hasPlayer = false
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

        if ( CAR.hasPlayer )
        {
            if ( file.keys[CAR.player][KF] && file.keys[CAR.player][KL] )
            {
                CAR.offsetlocation = _PositionBasedOnAngle( originalOffsetPoint + CAR.car.GetOrigin(), -CAR.car.GetAngles().y, CAR.car.GetOrigin() ) - CAR.car.GetOrigin()
                CAR.car.SetOrigin( CAR.car.GetOrigin() + CAR.offsetlocation )
                CAR.car.SetAngles( CAR.car.GetAngles() + <0,5,0> )
            }
            else if ( file.keys[CAR.player][KF] && file.keys[CAR.player][KR] )
            {
                CAR.offsetlocation = _PositionBasedOnAngle( originalOffsetPoint + CAR.car.GetOrigin(), -CAR.car.GetAngles().y, CAR.car.GetOrigin() ) - CAR.car.GetOrigin()
                CAR.car.SetOrigin( CAR.car.GetOrigin() + CAR.offsetlocation )
                CAR.car.SetAngles( CAR.car.GetAngles() + <0,-5,0> )
            }

            else if ( file.keys[CAR.player][KB] && file.keys[CAR.player][KL] )
            {
                CAR.offsetlocation = _PositionBasedOnAngle( originalOffsetPoint + CAR.car.GetOrigin(), -CAR.car.GetAngles().y, CAR.car.GetOrigin() ) - CAR.car.GetOrigin()
                CAR.car.SetOrigin( CAR.car.GetOrigin() + -CAR.offsetlocation )
                CAR.car.SetAngles( CAR.car.GetAngles() + <0,-5,0> )
            }
            else if ( file.keys[CAR.player][KB] && file.keys[CAR.player][KR] )
            {
                CAR.offsetlocation = _PositionBasedOnAngle( originalOffsetPoint + CAR.car.GetOrigin(), -CAR.car.GetAngles().y, CAR.car.GetOrigin() ) - CAR.car.GetOrigin()
                CAR.car.SetOrigin( CAR.car.GetOrigin() + -CAR.offsetlocation )
                CAR.car.SetAngles( CAR.car.GetAngles() + <0,5,0> )
            }
            else if ( file.keys[CAR.player][KF] )
            {
                CAR.car.SetOrigin( CAR.car.GetOrigin() + CAR.offsetlocation )
            }
            else if ( file.keys[CAR.player][KB] )
            {
                CAR.car.SetOrigin( CAR.car.GetOrigin() + -CAR.offsetlocation )
            }

            // print( "CAR origin :" + CAR.car.GetOrigin() )
            // print( "CAR angles :" + CAR.car.GetAngles() )
            // print( "offset :" + CAR.offsetlocation )

            UpdatedCameraPosition( CAR )
        }
        
        DebugDrawLine( CAR.car.GetOrigin(), CAR.offsetlocation + CAR.car.GetOrigin(), 255, 0, 0, true, 200.0 )

        WaitFrame()
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

void function SpawnCameraAbove( entity player, CARstruct CAR )
{
    vector origin = _PositionBasedOnAngle( originalOffsetCam, CAR.car.GetAngles().y, <0,0,0> )

    entity viewControl = CreateEntity( "point_viewcontrol" )
	viewControl.kv.spawnflags = 56 // infinite hold time, snap to goal angles, make player non-solid

	viewControl.SetOrigin( origin + CAR.car.GetOrigin() )
	viewControl.SetAngles( CAR.car.GetAngles() )
	DispatchSpawn( viewControl )

    viewControl.Fire( "Enable", "!activator", 0, player )
    // viewControl.FireNow( "Disable", "!activator", null, player )
    entity mover = CreateScriptMover()
    mover.SetOrigin( origin + CAR.car.GetOrigin() )
	mover.SetAngles( CAR.car.GetAngles() )
    viewControl.SetParent( mover )

    CAR.CamMover = mover
    CAR.camera = viewControl
}

void function DestroyCameraAbove( CARstruct CAR )
{
    CAR.camera.Fire( "Disable", "!activator", 0, CAR.player )
    CAR.player.ClearParent()
    CAR.CamMover.Destroy()
    CAR.player.EnableWeapon()
    CAR.player.EnableWeaponViewModel()
    CAR.player.ClearInvulnerable()
    // CAR.player
}

void function UpdatedCameraPosition( CARstruct CAR )
{
    vector origin = _PositionBasedOnAngle( originalOffsetCam, CAR.car.GetAngles().y + 180, <0,0,0> )
    CAR.CamMover.MoveTo( origin + CAR.car.GetOrigin(), 0.3, 0.05, 0.05 )
	// CAR.CamMover.RotateTo( CAR.car.GetAngles(), 0.3, 0.05, 0.05 )
    CAR.camera.SetAngles( CAR.car.GetAngles() )
    CAR.camera.RotateTo( CAR.car.GetAngles(), 0.3, 0.05, 0.05 )

    print( CAR.CamMover.GetOrigin() )
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
    file.keys[player] <- [ false, false, false, false, false, false ]
}

// void function MakePlayerDriveDropShip( entity player, DropShipStruct dropship )
// {
//     wait( 1 )
//     player.SetOrigin( dropship.mover.GetOrigin() + RideOffset )
//     player.SetParent( dropship.mover )

//     player.SetInvulnerable()

//     dropship.mover.SetScriptName( "RidableDropShipMover" + player.GetPlayerName() )
//     dropship.ship.SetScriptName( "RidableDropShip"  + player.GetPlayerName() )

//     dropship.MoveDirection = <0,0,0>
// }

// void function ExitPlayerFromDropShip( entity player, DropShipStruct dropship )
// {
//     player.ClearParent()
//     player.SetInvulnerable()

//     dropship.mover.SetScriptName( "RidableDropShipMover" )
//     dropship.ship.SetScriptName( "RidableDropShip" )

//     dropship.MoveDirection = <0,0,0>
// }

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


// vector playerOrg = player.GetOrigin()
// vector playerEyeForward = player.GetViewVector()
// vector playerEyePos = player.EyePosition()
// vector playerEyeAngles = player.EyeAngles()
// float yaw = playerEyeAngles.y