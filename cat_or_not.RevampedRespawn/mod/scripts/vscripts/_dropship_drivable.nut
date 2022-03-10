global function SpawnDropShipRidable
global function MakePlayerDriveDropShip
global function ExitPlayerFromDropShip

// Movement
global function PlayerMoveJump
global function PlayerMoveDuck
global function PlayerMoveFORWARD
global function PlayerMoveBACK
global function PlayerMoveRIGHT
global function PlayerMoveLEFT

// Not Movment
global function PlayerStopJump
global function PlayerStopDuck
global function PlayerStopFORWARD
global function PlayerStopBACK
global function PlayerStopRIGHT
global function PlayerStopLEFT

const vector RideOffset = < 60,0,-10 >
const vector RideOffsetShip = < -200,0,0 >
const float Speed = 30

struct{
    array<DropShipStruct> Dropships
} DropshipsRidable

/*
███████╗███████╗████████╗██╗   ██╗██████╗ 
██╔════╝██╔════╝╚══██╔══╝██║   ██║██╔══██╗
███████╗█████╗     ██║   ██║   ██║██████╔╝
╚════██║██╔══╝     ██║   ██║   ██║██╔═══╝ 
███████║███████╗   ██║   ╚██████╔╝██║     
╚══════╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝     
                                          
*/


DropShipStruct function SpawnDropShipRidable( vector origin, vector angles, entity player )
{
    DropShipStruct ship = SpawnDropShipRespawn( origin, angles )
    
    ship.ship.ClearParent()
    ship.ship.SetOrigin( ship.ship.GetOrigin() + RideOffsetShip )
    ship.ship.SetParent( ship.mover )

    ship.mover.SetScriptName( "RidableDropShipMover" )
    ship.ship.SetScriptName( "RidableDropShip" )

    DropshipsRidable.Dropships.append( ship )

    thread MoveDropShip( ship, player )

    return ship
}

void function MoveDropShip( DropShipStruct dropship, entity player )
{
    float alpha
    vector newVec
    while( IsValid( dropship.mover ) )
    {
        alpha = player.GetAngles().x * 0.01745329
        newVec = <0,0,dropship.MoveDirection.z>

        newVec.x = alpha * sin( dropship.MoveDirection.x )
        newVec.y = alpha * -cos( dropship.MoveDirection.y )
        dropship.mover.SetOrigin( dropship.mover.GetOrigin() + dropship.MoveDirection )
        dropship.mover.SetAngles( <0, player.EyeAngles().y - dropship.mover.GetAngles().y,0> )
        
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

void function MakePlayerDriveDropShip( entity player, DropShipStruct dropship )
{
    wait( 1 )
    player.SetOrigin( dropship.mover.GetOrigin() + RideOffset )
    player.SetParent( dropship.mover )

    player.SetInvulnerable()

    dropship.mover.SetScriptName( "RidableDropShipMover" + player.GetPlayerName() )
    dropship.ship.SetScriptName( "RidableDropShip"  + player.GetPlayerName() )

    dropship.MoveDirection = <0,0,0>
}

void function ExitPlayerFromDropShip( entity player, DropShipStruct dropship )
{
    player.ClearParent()
    player.SetInvulnerable()

    dropship.mover.SetScriptName( "RidableDropShipMover" )
    dropship.ship.SetScriptName( "RidableDropShip" )

    dropship.MoveDirection = <0,0,0>
}

void function ChangeMovement( entity player, vector movement )
{
    foreach( dropship in DropshipsRidable.Dropships )
    {
        if ( dropship.mover.GetScriptName() == "RidableDropShipMover" + player.GetPlayerName() )
        {
            dropship.MoveDirection = dropship.MoveDirection + movement
            print( dropship.MoveDirection )
        }
    }
}

// Movement

void function PlayerMoveJump( entity player )
{
    ChangeMovement( player, <0,0,Speed> )
}
void function PlayerMoveDuck( entity player )
{
    ChangeMovement( player, <0,0,-Speed> )
}
void function PlayerMoveFORWARD( entity player )
{
    ChangeMovement( player, <0,Speed,0> )
}
void function PlayerMoveBACK( entity player )
{
    ChangeMovement( player, <0,-Speed,0> )
}
void function PlayerMoveLEFT( entity player )
{
    ChangeMovement( player, < Speed,0,0> )
}
void function PlayerMoveRIGHT( entity player )
{
    ChangeMovement( player, < -Speed,0,0> )
}


// Not Movement

void function PlayerStopJump( entity player )
{
    ChangeMovement( player, <0,0,-Speed> )
}
void function PlayerStopDuck( entity player )
{
    ChangeMovement( player, <0,0,Speed> )
}
void function PlayerStopFORWARD( entity player )
{
    ChangeMovement( player, <0,-Speed,0> )
}
void function PlayerStopBACK( entity player )
{
    ChangeMovement( player, <0,Speed,0> )
}
void function PlayerStopLEFT( entity player )
{
    ChangeMovement( player, < -Speed,0,0> )
}
void function PlayerStopRIGHT( entity player )
{
    ChangeMovement( player, < Speed,0,0> )
}