global function CanDropTitanChassis

bool function CanDropTitanChassis( entity player )
{
    string chassis = playerToChassis( player )
    int titanCount = 0


    foreach ( entity titan in GetEntArrayByClass_Expensive("npc_titan") )
    {
        if ( titan.GetTeam() == player.GetTeam() && chassis == GetChassis( titan )  )
        {
            titanCount += 1
        }
    }
    foreach ( entity p in GetPlayerArray() )
    {
        if ( p.GetTeam() == player.GetTeam() && p.IsTitan() && chassis == GetChassis( p ) )
        {
            titanCount += 1
        }
    }

    return titanCount < GetChassisLimit( chassis )
}

int function GetChassisLimit( string chassis )
{
    switch ( chassis )
    {        
        case "ronin":
            return GetConVarInt("RoninLimit")
        case "northstar":
            return GetConVarInt("NorthstarLimit")
        case "tone":
            return GetConVarInt("ToneLimit")
        case "ion":
            return GetConVarInt("IonLimit")
        case "scorch":
            return GetConVarInt("ScorchLimit")
        case "legion":
            return GetConVarInt("LegionLimit")
        case "vanguard":
            return GetConVarInt("MonarchLimit")
        case "npc":
            return 0
    }
    return 0
}

string function playerToChassis( entity player )
{
    return GetActiveTitanLoadout( player ).titanClass
}

string function GetChassis( entity titan )
{
    if ( !IsValid( titan ) )
        return "npc"
    entity soul = titan.GetTitanSoul()
    if ( !IsValid( soul ) )
        return "npc"
    return StandardiseChassis( GetSoulPlayerSettings( soul ) )
}

string function StandardiseChassis( string chassis )
{
    switch ( chassis )
    {
        case "titan_stryder_arc":
        case "titan_stryder_leadwall":
        case "titan_stryder_ronin_prime":
            return "ronin"
        case "titan_stryder_sniper":
        case "titan_stryder_northstar_prime":
            return "northstar"
        case "titan_atlas_tracker":
        case "titan_atlas_tone_prime":
            return "tone"
        case "titan_atlas_vanguard":
            return "vanguard"
        case "titan_atlas_stickybomb":
        case "titan_atlas_ion_prime":
            return "ion"
        case "titan_ogre_meteor":
        case "titan_ogre_scorch_prime":
            return "scorch"
        case "titan_ogre_minigun":
        case "titan_ogre_legion_prime":
            return "legion"
        case "titan_ogre_fighter":
            return "npc"
    }
    return "npc"
}