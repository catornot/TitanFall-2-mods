global function RoomInit

const array<asset> ModelsLoaded =
[
    $"models/floating_village/hut_panel_01.mdl",
    $"models/timeshift/timeshift_kitchen_cabinet_close_big_01.mdl",
    $"models/timeshift/timeshift_kitchen_cabinet_close_multi_01.mdl",
    $"models/timeshift/timeshift_kitchen_cabinet_close_small_01.mdl",
    $"models/timeshift/timeshift_kitchen_cabinet_open_01.mdl",
    $"models/timeshift/timeshift_kitchen_counter_end_a_01.mdl",
    $"models/timeshift/timeshift_kitchen_counter_mid_01.mdl",
    $"models/kodai/kodai_white_board.mdl",
    $"models/kodai/white_board_postits_01.mdl",
    $"models/kodai/white_board_postits_02.mdl",
    $"models/homestead/homestead_floor_panel_01.mdl",
    $"models/homestead/homestead_floor_panel_closed_02.mdl",
    $"models/homestead/homestead_floor_panel_open_02.mdl",
    $"models/homestead/homestead_floor_panel_open_03.mdl",
]

void function RoomInit()
{
    PrecacheAll()
    MakeModelDisplay()
    // AddCallback_OnClientConnected( giveTf )
}

void function PrecacheAll()
{
    PrecacheModel($"models/floating_village/hut_panel_01.mdl")
    PrecacheModel($"models/timeshift/timeshift_kitchen_cabinet_close_big_01.mdl")
    PrecacheModel($"models/timeshift/timeshift_kitchen_cabinet_close_multi_01.mdl")
    PrecacheModel($"models/timeshift/timeshift_kitchen_cabinet_close_small_01.mdl")
    PrecacheModel($"models/timeshift/timeshift_kitchen_cabinet_open_01.mdl")
    PrecacheModel($"models/timeshift/timeshift_kitchen_counter_end_a_01.mdl")
    PrecacheModel($"models/timeshift/timeshift_kitchen_counter_mid_01.mdl")
    PrecacheModel($"models/kodai/kodai_white_board.mdl")
    PrecacheModel($"models/kodai/white_board_postits_01.mdl")
    PrecacheModel($"models/kodai/white_board_postits_02.mdl")
    PrecacheModel($"models/homestead/homestead_floor_panel_01.mdl")
    PrecacheModel($"models/homestead/homestead_floor_panel_closed_02.mdl")
    PrecacheModel($"models/homestead/homestead_floor_panel_open_02.mdl")
    PrecacheModel($"models/homestead/homestead_floor_panel_open_03.mdl")
}


void function MakeModelDisplay()
{
    foreach( int x, asset Model in ModelsLoaded )
    {
        CreatePropDynamic( Model, <x*100-1000,0,-3005>, <0,0,0>, SOLID_VPHYSICS )
    }
}

void function giveTf( entity player )
{
    TitanLoadoutDef loadout = GetTitanLoadoutForCurrentMap()

	entity titan = CreateAutoTitanForPlayer_FromTitanLoadout( player, loadout, <0,0,-3005>, <0,0,0> )
	SetSpawnOption_Titanfall( titan )
	DispatchSpawn( titan )
	player.SetPetTitan( titan )

	titan.DisableHibernation()
}
