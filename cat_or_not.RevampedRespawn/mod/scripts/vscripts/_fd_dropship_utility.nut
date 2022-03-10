untyped
global function SpawnDropShipRespawn

global function MakePlayerRideDropShipR
global function MakePlayerRideDropShipL
global function DropshipMoveTo
global function DropshipDescend
global function DropshipAscend
global function WarpOutThenDestroyDropShip

const vector DoorRSitOffset = < -40,0,30 >
const vector DoorLSitOffset = < 40,0,30 >


global struct DropShipStruct
{
	entity ship
    entity mover
    vector MoveDirection = <0,0,0>
}

/*
███████╗███████╗████████╗██╗   ██╗██████╗ 
██╔════╝██╔════╝╚══██╔══╝██║   ██║██╔══██╗
███████╗█████╗     ██║   ██║   ██║██████╔╝
╚════██║██╔══╝     ██║   ██║   ██║██╔═══╝ 
███████║███████╗   ██║   ╚██████╔╝██║     
╚══════╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝     
                                          
*/


DropShipStruct function SpawnDropShipRespawn( vector origin, vector angles )
{
    DropShipStruct ship

    ship.ship = CreateEntity( "prop_dynamic" )
    
	ship.ship.SetValueForModelKey( $"models/vehicle/crow_dropship/crow_dropship_hero.mdl" )
	ship.ship.kv.solid = SOLID_VPHYSICS
    // ship.ship.kv.CollisionGroup = TRACE_COLLISION_GROUP_BLOCK_WEAPONS //  TRACE_COLLISION_GROUP_PLAYER
    ship.ship.kv.rendercolor = "81 130 151"
	ship.ship.SetOrigin( origin )
	ship.ship.SetAngles( angles )

	ship.ship.SetBlocksRadiusDamage( true )
	DispatchSpawn( ship.ship )
    SetTeam( ship.ship, TEAM_BOTH )

    ship.mover = CreateOwnedScriptMover( ship.ship )
    ship.ship.SetParent( ship.mover )

    return ship
}

/*
██╗   ██╗████████╗██╗██╗     ██╗████████╗██╗███████╗███████╗
██║   ██║╚══██╔══╝██║██║     ██║╚══██╔══╝██║██╔════╝██╔════╝
██║   ██║   ██║   ██║██║     ██║   ██║   ██║█████╗  ███████╗
██║   ██║   ██║   ██║██║     ██║   ██║   ██║██╔══╝  ╚════██║
╚██████╔╝   ██║   ██║███████╗██║   ██║   ██║███████╗███████║
 ╚═════╝    ╚═╝   ╚═╝╚══════╝╚═╝   ╚═╝   ╚═╝╚══════╝╚══════╝
                                                                                                
*/

void function MakePlayerRideDropShipR( entity player, DropShipStruct dropship )
{
    player.SetOrigin( dropship.mover.GetOrigin() + DoorRSitOffset )
    player.SetParent( dropship.mover )
    wait( 0.3 )
    dropship.ship.Anim_Play( "dropship_open_doorR" )
}

void function MakePlayerRideDropShipL( entity player, DropShipStruct dropship )
{
    player.SetOrigin( dropship.mover.GetOrigin() + DoorLSitOffset )
    player.SetParent( dropship.mover )
    wait( 0.3 )
    dropship.ship.Anim_Play( "dropship_open_doorL" )
}


void function DropshipMoveTo( DropShipStruct dropship, vector dest, float Time )
{
    dropship.mover.MoveTo( dest, Time, 0.1, 0.1 )
}

void function DropshipDescend( DropShipStruct dropship, vector dest, float TimePerNode )
{
    //math :)
    
    array<vector> Nodes
    vector appendVector

    for ( int y = 2000 ; y > 0 ; y-=100 )
    {
        appendVector = <0,y,0>

        appendVector.z = sqrt( ( pow(y,3) / pow(y,9) ) + 2000*y )
        appendVector.x = sqrt( ( pow(y,3) / pow(y,9) ) + 2000*y ) - 100

        Nodes.append( appendVector )
        print( appendVector )
    }

    foreach( node in Nodes )
    {
        DropshipMoveTo( dropship, dest + node, TimePerNode ) // the time is related to how many nodes are there
        wait( TimePerNode )
    }
        
}

void function DropshipAscend( DropShipStruct dropship, vector dest, float TimePerNode )
{
    //math :)
    
    array<vector> Nodes
    vector appendVector

    for ( int y = 100 ; y < 2000 ; y+=200 )
    {
        appendVector = <0,y,0>

        appendVector.z = sqrt( ( pow(y,3) / pow(y,9) ) + 5000*y )
        appendVector.x = sqrt( ( pow(y,3) / pow(y,9) ) + 2000*y ) - 100

        Nodes.append( appendVector )
        print( appendVector )
    }

    foreach( node in Nodes )
    {
        DropshipMoveTo( dropship, dest + node, TimePerNode ) // the time is related to how many nodes are there
        wait( TimePerNode )
    }
        
}

void function WarpOutThenDestroyDropShip( DropShipStruct dropship )
{
    entity fx = PlayFX( FX_GUNSHIP_CRASH_EXPLOSION_EXIT, dropship.ship.GetOrigin(), dropship.ship.GetAngles() )
    fx.FXEnableRenderAlways()
    fx.DisableHibernation()

    dropship.mover.Destroy()
}