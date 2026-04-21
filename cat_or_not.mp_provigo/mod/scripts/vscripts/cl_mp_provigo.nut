global function ClientCodeCallback_MapInit

struct {
	var moneyRui
} file


void function ClientCodeCallback_MapInit()
{
    AddCallback_EntitiesDidLoad( CreateProvigoUI )
}

void function CreateProvigoUI()
{
    entity player = GetLocalClientPlayer()

	var rui = CreateCockpitRui( $"ui/fd_score_splash.rpak", 500 )
	RuiTrackInt( rui, "pointValue", player, RUI_TRACK_SCRIPT_NETWORK_VAR_INT, GetNetworkedVariableIndex( "FD_money" ) )
	RuiTrackInt( rui, "pointStack", player, RUI_TRACK_SCRIPT_NETWORK_VAR_INT, GetNetworkedVariableIndex( "FD_money256" ) )
	file.moneyRui = rui
}