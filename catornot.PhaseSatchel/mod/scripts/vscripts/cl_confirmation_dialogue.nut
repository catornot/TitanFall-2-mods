global function conClient_Init

void function conClient_Init()
{
    AddServerToClientStringCommandCallback( "OpenConfirmation", OpenConfirmation )
}

void function OpenConfirmation( array<string> args )
{
    RunUIScript( "conDialogue_Make" )
}