global function conClient_Init

void function conClient_Init()
{
    AddServerToClientStringCommandCallback( "OpenConfirmation", OpenConfirmation )
    AddServerToClientStringCommandCallback( "OpenConfirmation2", OpenConfirmation2 )
}

void function OpenConfirmation( array<string> args )
{
    RunUIScript( "conDialogue_Make" )
}

void function OpenConfirmation2( array<string> args )
{
    RunUIScript( "conDialogue_Make2" )
}