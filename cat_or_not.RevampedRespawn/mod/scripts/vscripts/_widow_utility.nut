global function CreateWidow
global function CloseDoorL
global function CloseDoorR
global function OpenDoorL
global function OpenDoorR
global function doorCycle
global function TravelOnX
global function TravelOnY
global function TravelOnZ
global function TeleportWidow
global function WarpOutThenDestroyShip

const vector OffsetFloor = < -200,0,-50 >
const vector OffsetCeiling = < -200,0,450 >
const vector OffsetDoorL = < -200,180,200 >
const vector OffsetDoorR = < -200,-240,200 >
const vector OffsetBack = < -250,0,200 >
const vector OffsetFront = < 200,0,200 >
const int BOTHCLOSED = 0
const int RIGHTOPEN = 1
const int LEFTOPEN = 2
const int BOTHOPEN = 3
const float HullSize = 150000.0

global struct WidowStruct
{
	entity ship
    entity floor
    entity ceiling
    entity doorL
    entity doorR
    array<entity> back
    array<entity> front
    int DOORSTATE = BOTHCLOSED
}

/*
███████╗███████╗████████╗██╗   ██╗██████╗ 
██╔════╝██╔════╝╚══██╔══╝██║   ██║██╔══██╗
███████╗█████╗     ██║   ██║   ██║██████╔╝
╚════██║██╔══╝     ██║   ██║   ██║██╔═══╝ 
███████║███████╗   ██║   ╚██████╔╝██║     
╚══════╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝     
                                          
*/

WidowStruct function CreateWidow( entity player, vector origin, vector angles )
{
    WidowStruct ship

    ship.ship = CreateEntity( "prop_dynamic" )
    
	ship.ship.SetValueForModelKey( $"models/vehicle/widow/widow.mdl" )
	ship.ship.kv.solid = SOLID_VPHYSICS
    ship.ship.kv.CollisionGroup = TRACE_COLLISION_GROUP_BLOCK_WEAPONS //  TRACE_COLLISION_GROUP_PLAYER
    ship.ship.kv.rendercolor = "81 130 151"
	ship.ship.SetOrigin( origin )
	ship.ship.SetAngles( angles )

	ship.ship.SetBlocksRadiusDamage( true )
	DispatchSpawn( ship.ship )
    SetTeam( ship.ship, player.GetTeam() )

    ship.ship.Anim_Play( "wd_doors_closed_idle" )

    _CreateFloor( ship )
    _CreateCeiling( ship )
    CloseDoorR( ship )
    CloseDoorL( ship )
    _CreateFront( ship )
    _CreateBack( ship )

    return ship
}


void function _CreateFloor( WidowStruct widow )
{
    widow.floor =_CreateTitanProp( widow, widow.ship.GetOrigin() + OffsetFloor, widow.ship.GetAngles() )
}

void function _CreateCeiling( WidowStruct widow )
{
    widow.ceiling =_CreateTitanProp( widow, widow.ship.GetOrigin() + OffsetCeiling, widow.ship.GetAngles() )
}

void function _CreateFront( WidowStruct widow )
{
    _CreateSarahProp( widow, widow.ship.GetOrigin() + OffsetFront + < 0,-50,0>, widow.ship.GetAngles() + <0,90,0> )
    _CreateSarahProp( widow, widow.ship.GetOrigin() + OffsetFront + < 0,-50,100>, widow.ship.GetAngles() + <0,90,0> )
    _CreateSarahProp( widow, widow.ship.GetOrigin() + OffsetFront + <0,50,0>, widow.ship.GetAngles() + <0,90,0> )
    _CreateSarahProp( widow, widow.ship.GetOrigin() + OffsetFront + <0,50,100>, widow.ship.GetAngles() + <0,90,0> )
    _CreateSarahProp( widow, widow.ship.GetOrigin() + OffsetFront + <0,0,0>, widow.ship.GetAngles() + <0,90,0> )
    _CreateSarahProp( widow, widow.ship.GetOrigin() + OffsetFront + <0,0,100>, widow.ship.GetAngles() + <0,90,0> )
}

void function _CreateBack( WidowStruct widow )
{
    _CreateSarahProp( widow, widow.ship.GetOrigin() + OffsetBack + <0,-50,0>, widow.ship.GetAngles() + <0,90,0> )
    _CreateSarahProp( widow, widow.ship.GetOrigin() + OffsetBack + <0,-50,100>, widow.ship.GetAngles() + <0,90,0> )
    _CreateSarahProp( widow, widow.ship.GetOrigin() + OffsetBack + <0,50,0>, widow.ship.GetAngles() + <0,90,0> )
    _CreateSarahProp( widow, widow.ship.GetOrigin() + OffsetBack + <0,50,100>, widow.ship.GetAngles() + <0,90,0> )
    _CreateSarahProp( widow, widow.ship.GetOrigin() + OffsetBack + <0,0,0>, widow.ship.GetAngles() + <0,90,0> )
    _CreateSarahProp( widow, widow.ship.GetOrigin() + OffsetBack + <0,0,100>, widow.ship.GetAngles() + <0,90,0> )
}

entity function _CreateSarahProp( WidowStruct widow, vector origin, vector angles )
{
    entity Prop = CreateEntity( "prop_dynamic" )
    
	Prop.SetValueForModelKey( $"models/humans/heroes/mlt_hero_sarah.mdl" )
	Prop.kv.solid = SOLID_BBOX
    Prop.kv.rendercolor = "81 130 151"
	Prop.SetOrigin( origin )
	Prop.SetAngles( angles )
    Prop.SetParent( widow.ship )

	Prop.SetBlocksRadiusDamage( true )
	DispatchSpawn( Prop )

    Prop.Hide()

    return Prop
}

entity function _CreateTitanProp( WidowStruct widow, vector origin, vector angles )
{
    entity Prop = CreateEntity( "prop_dynamic" )
    
	Prop.SetValueForModelKey( $"models/titans/medium/titan_medium_ajax.mdl" )
	Prop.kv.solid = SOLID_BBOX
    Prop.kv.rendercolor = "81 130 151"
	Prop.SetOrigin( origin )
	Prop.SetAngles( angles )
    Prop.SetParent( widow.ship )

	Prop.SetBlocksRadiusDamage( true )
	DispatchSpawn( Prop )

    Prop.Hide()

    return Prop
}

/*
██╗   ██╗████████╗██╗██╗     ██╗████████╗██╗███████╗███████╗
██║   ██║╚══██╔══╝██║██║     ██║╚══██╔══╝██║██╔════╝██╔════╝
██║   ██║   ██║   ██║██║     ██║   ██║   ██║█████╗  ███████╗
██║   ██║   ██║   ██║██║     ██║   ██║   ██║██╔══╝  ╚════██║
╚██████╔╝   ██║   ██║███████╗██║   ██║   ██║███████╗███████║
 ╚═════╝    ╚═╝   ╚═╝╚══════╝╚═╝   ╚═╝   ╚═╝╚══════╝╚══════╝
                                                                                                
*/


void function CloseDoorL( WidowStruct widow )
{
    switch ( widow.DOORSTATE )
    {
        case BOTHCLOSED:
            widow.doorL = _CreateTitanProp( widow, widow.ship.GetOrigin() + OffsetDoorL, widow.ship.GetAngles() + <90,0,0> )
            break
		case RIGHTOPEN:
            widow.doorL = _CreateTitanProp( widow, widow.ship.GetOrigin() + OffsetDoorL, widow.ship.GetAngles() + <90,0,0> )
            break
        case LEFTOPEN:
            widow.doorL = _CreateTitanProp( widow, widow.ship.GetOrigin() + OffsetDoorL, widow.ship.GetAngles() + <90,0,0> )
            widow.ship.Anim_Play( "wd_doors_closing" )
            widow.DOORSTATE = BOTHCLOSED
            break
        case BOTHOPEN:
            widow.doorL = _CreateTitanProp( widow, widow.ship.GetOrigin() + OffsetDoorL, widow.ship.GetAngles() + <90,0,0> )
            widow.ship.Anim_Play( "wd_doors_closing_L" )
            widow.ship.Anim_Play( "wd_doors_opening_R" )
            widow.DOORSTATE = RIGHTOPEN
            break
    }
}

void function OpenDoorL( WidowStruct widow )
{
    switch ( widow.DOORSTATE )
    {
        case BOTHCLOSED:
            widow.doorL.Destroy()
            widow.doorL = null
            widow.ship.Anim_Play( "wd_doors_opening_L" )
            widow.DOORSTATE = LEFTOPEN
            break
		case RIGHTOPEN:
            widow.doorL.Destroy()
            widow.doorL = null
            widow.ship.Anim_Play( "wd_doors_opening" )
            widow.DOORSTATE = BOTHOPEN
            break
        case LEFTOPEN:
            break
        case BOTHOPEN:
            break
    }
}

void function CloseDoorR( WidowStruct widow )
{
    switch ( widow.DOORSTATE )
    {
        case BOTHCLOSED:
            widow.doorR = _CreateTitanProp( widow, widow.ship.GetOrigin() + OffsetDoorR, widow.ship.GetAngles() + <90,0,0> )
            break
		case RIGHTOPEN:
            widow.doorR = _CreateTitanProp( widow, widow.ship.GetOrigin() + OffsetDoorR, widow.ship.GetAngles() + <90,0,0> )
            widow.ship.Anim_Play( "wd_doors_closing" )
            widow.DOORSTATE = BOTHCLOSED
            break
        case LEFTOPEN:
            widow.doorR = _CreateTitanProp( widow, widow.ship.GetOrigin() + OffsetDoorR, widow.ship.GetAngles() + <90,0,0> )
            break
        case BOTHOPEN:
            widow.doorR = _CreateTitanProp( widow, widow.ship.GetOrigin() + OffsetDoorR, widow.ship.GetAngles() + <90,0,0> )
            widow.ship.Anim_Play( "wd_doors_closing_R" )
            widow.ship.Anim_Play( "wd_doors_opening_L" )
            widow.DOORSTATE = LEFTOPEN
            break
    }
}

void function OpenDoorR( WidowStruct widow )
{
    switch ( widow.DOORSTATE )
    {
        case BOTHCLOSED:
            widow.doorR.Destroy()
            widow.doorR = null
            widow.ship.Anim_Play( "wd_doors_opening_R" )
            widow.DOORSTATE = RIGHTOPEN
            break
		case RIGHTOPEN:
            break
        case LEFTOPEN:
            widow.doorR.Destroy()
            widow.doorR = null
            widow.ship.Anim_Play( "wd_doors_opening" )
            widow.DOORSTATE = BOTHOPEN
            break
        case BOTHOPEN:
            break
    }
}

void function doorCycle( WidowStruct widow, float Time )
{
    for( int x=0; x<50 ; x++ )
    {
        wait( Time )
        if ( x % 2 == 0 ){
            OpenDoorL( widow )
        }
        else{
            CloseDoorL( widow )
        }
    }
}

void function TravelOnX( WidowStruct widow, int XDistance, int SpeedPerFrame )
{
    int AbsDistance = abs(XDistance)
    for(;;)
    {
        if ( AbsDistance <= 0 )
            break
        AbsDistance -= abs(SpeedPerFrame)
        widow.ship.SetOrigin( widow.ship.GetOrigin() + Vector(SpeedPerFrame,0,0) )
        
        foreach( player in GetPlayerArray() )
        {
            if ( DistanceSqr( player.GetOrigin(), widow.ship.GetOrigin() ) <= HullSize )
            {
                player.SetOrigin( player.GetOrigin() + Vector(SpeedPerFrame,0,0) )
            }
        }

        WaitFrame()
    }
}
void function TravelOnY( WidowStruct widow, int YDistance, int SpeedPerFrame )
{
    int AbsDistance = abs(YDistance)
    for(;;)
    {
        if ( AbsDistance <= 0 )
            break
        AbsDistance -= abs(SpeedPerFrame)
        widow.ship.SetOrigin( widow.ship.GetOrigin() + Vector(0,SpeedPerFrame,0) )

        foreach( player in GetPlayerArray() )
        {
            if ( DistanceSqr( player.GetOrigin(), widow.ship.GetOrigin() ) <= HullSize )
            {
                player.SetOrigin( player.GetOrigin() + Vector(0,SpeedPerFrame,0) )
            }
        }

        WaitFrame()
    }
}
void function TravelOnZ( WidowStruct widow, int ZDistance, int SpeedPerFrame )
{
    int AbsDistance = abs(ZDistance)
    for(;;)
    {
        if ( AbsDistance <= 0 )
            break
        AbsDistance -= abs(SpeedPerFrame)
        widow.ship.SetOrigin( widow.ship.GetOrigin() + Vector(0,0,SpeedPerFrame) )
        
        foreach( player in GetPlayerArray() )
        {
            if ( DistanceSqr( player.GetOrigin(), widow.ship.GetOrigin() ) <= HullSize )
            {
                player.SetOrigin( player.GetOrigin() + Vector(0,0,SpeedPerFrame) )
            }
        }

        WaitFrame()
    }
}

void function TeleportWidow( WidowStruct widow, vector destination, vector angles )
{
    entity fx = PlayFX( FX_GUNSHIP_CRASH_EXPLOSION_EXIT, widow.ship.GetOrigin(), widow.ship.GetAngles() )
    fx.FXEnableRenderAlways()
    fx.DisableHibernation()

    foreach( player in GetPlayerArray() )
    {
       if ( DistanceSqr( player.GetOrigin(), widow.ship.GetOrigin() ) <= HullSize )
       {
           player.SetOrigin( destination + <0,0,200> )
       }
    //    print( player )
    //    print( DistanceSqr( player.GetOrigin(), widow.ship.GetOrigin() ) <= HullSize )
    }

    widow.ship.SetOrigin( destination )

    entity fx2 = PlayFX( FX_GUNSHIP_CRASH_EXPLOSION_ENTRANCE, widow.ship.GetOrigin(), widow.ship.GetAngles() )
    fx2.FXEnableRenderAlways()
    fx2.DisableHibernation()
}

void function WarpOutThenDestroyShip( WidowStruct widow )
{
    entity fx = PlayFX( FX_GUNSHIP_CRASH_EXPLOSION_EXIT, widow.ship.GetOrigin(), widow.ship.GetAngles() )
    fx.FXEnableRenderAlways()
    fx.DisableHibernation()

    CloseDoorL( widow )
    CloseDoorR( widow )
    widow.floor.Destroy()
    widow.ceiling.Destroy()
    widow.ship.Destroy()
}