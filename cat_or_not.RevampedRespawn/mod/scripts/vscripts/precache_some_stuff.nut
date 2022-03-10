global function PrecacheStuff

const array<asset> models = [ 
    $"models/humans/heroes/mlt_hero_sarah.mdl",
    $"models/vehicles_r2/vehicles/samson/samson.mdl",
    $"models/vehicle/vehicle_truck_modular/vehicle_truck_modular_closed_bed.mdl",
    $"models/vehicle/vehicle_w3_hatchback/tire_w3_hatch_bnw.mdl"

]

void function PrecacheStuff()
{
    #if SERVER
    print( "-------------------------" )
    print( "-------------------------" )
    print( "-------------------------" )
    foreach( asset model in models )
    {
        print( "Before :" + ModelIsPrecached( model ) )
        if ( !ModelIsPrecached( model ) )
        {
            PrecacheModel( model )
        }
        print( "After :" + ModelIsPrecached( model ) )
    }
    print( "-------------------------" )
    print( "-------------------------" )
    print( "-------------------------" )
    #endif
}