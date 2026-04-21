global function CodeCallback_MapInit

void function CodeCallback_MapInit()
{
    try {
        SetFlightBounds( 500000, 20000 )
    }
    catch(e) {
        printt("no dropship mod :( " + e)
    }

    AddCallback_EntitiesDidLoad( EntitiesDidLoad )
}

void function EntitiesDidLoad()
{
    thread DelayedEntitiesDidLoad()


    PrecacheModel( $"models/vehicles_r2/spacecraft/draconis/draconis_flying_1000x.mdl" )
    PrecacheModel( $"models/vehicles_r2/spacecraft/draconis/draconis_flying_hero.mdl" )
    PrecacheModel( $"models/levels_terrain/sp_s2s/s2s_malta_ramair_1024.mdl" )
    PrecacheModel( $"models/levels_terrain/sp_s2s/malta_s2s_engine_large.mdl" )
}

void function DelayedEntitiesDidLoad()
{
    print( "DelayedEntitiesDidLoad" )

    wait 1

    // thread PlayAnim( GetEnt( "draconis_model" ), "ve_arc_loading_draconis_idle" )
    // thread PlayAnim( GetEnt( "draconis_model" ), "ve_arc_loading_draconis_idle", GetEnt( "draconis_model" ) )
    
    // print( "DelayedEntitiesDidLoad is disabled" )
    // return

    print( "DelayedEntitiesDidLoad waited" )

    array<entity> dropship_spawns = GetEntArrayByScriptName( "DropShipBusSpawn" )

    foreach ( entity spawn in dropship_spawns  )
    {
        vector origin = spawn.GetOrigin()
        vector angles = spawn.GetAngles()
        int team = spawn.GetTeam()

        if ( !spawn.HasKey( "editorclass" ) )
        {
            spawn.Destroy()
            continue
        }
        string editorclass = GetEditorClass( spawn )

        thread DropshipBusThink( SpawnDropShipLight( WorldToLocalOrigin( origin ), angles, team, true ), editorclass )

        spawn.Destroy()
    }
}

void function DropshipBusThink( ShipStruct ship, string name )
{
    entity model = ship.model
    int dir = 1
    int pos = 0

    model.SetPusher( true )
    ShipSetInvulnerable( ship )

    for(;;)
    {
        if ( pos == -1 )
        {
            pos = 0
            dir = -dir
            WaitFrame()
        }

        entity node = GetEnt( name + "_" + pos )

        if ( !IsValid( node ) )
        {
            dir = -dir
            pos += dir
            pos += dir

            WaitFrame()
            continue
        }

        ShipFlyToPos( ship, WorldToLocalOrigin( node.GetOrigin() ), node.GetAngles() )

        WaitSignal( ship, "Goal" )

        pos += dir

        WaitFrame()

        if ( !node.HasKey( "delay" ) )
            continue
        
        int delay = node.GetValueForKey( "delay" ).tointeger()

        wait delay

        WaitFrame()
    }
}